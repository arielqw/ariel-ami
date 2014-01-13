package reactor;

import java.nio.ByteBuffer;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Logger;

import protocol.AsyncServerProtocol;
import spl.server.Statistics;
import spl.server.Topic;
import spl.server.TopicsDatabase;
import spl.server.User;
import spl.server.UsersDatabase;
import spl.server.stomp.frames.ConnectFrame;
import spl.server.stomp.frames.ConnectedFrame;
import spl.server.stomp.frames.DisconnectFrame;
import spl.server.stomp.frames.ErrorFrame;
import spl.server.stomp.frames.ReceiptFrame;
import spl.server.stomp.frames.SendFrame;
import spl.server.stomp.frames.ServerMessageFrame;
import spl.server.stomp.frames.StompFrame;
import spl.server.stomp.frames.SubscribeFrame;
import spl.server.stomp.frames.UnsubscribeFrame;
import tokenizer.StringMessage;

public class TweeterProtocol implements AsyncServerProtocol<StringMessage>
{
	private final static Logger LOGGER = Logger.getGlobal();

    private boolean _shouldClose;
    private UsersDatabase _usersDatabase;
    private TopicsDatabase _topicsDatabase;
    private String _username;
	private ConnectionHandler _connectionHandler;
	private Statistics _statistics;
	
    public TweeterProtocol(UsersDatabase usersDatabase, TopicsDatabase entriesDatabase, Statistics statistics) {
        _shouldClose = false;
        _usersDatabase = usersDatabase;
        _topicsDatabase = entriesDatabase;
        _username = null;
        _connectionHandler = null;
        _statistics = statistics;
        
    }
 
    /**
     * gets an array of strings representing the rows of the msg
     * and returns the value of a provided key according to stomp msg specs
     * @param strArr
     * @param stringToFind is the key
     * @return
     */
    protected String getValueFromArray(String[] strArr,String stringToFind){
    	for (String string : strArr) {
    		if(string.length() >= stringToFind.length()){
    			if(string.substring(0,stringToFind.length()).equals(stringToFind)){
					return string.substring(stringToFind.length()+1);
				}
    		}
		}
    	return "not_found";
    }
    
    /**
     * gets an array of strings representing the rows of the msg
     * and returns the body of the msg according to stomp specs
     * @param strArr
     * @return the body of the msg
     */
    protected String getBody(String[] strArr){
    	for (int i = 0; i < strArr.length; i++) {
			if(i!=0 && strArr[i].equals("")&& i+1 < strArr.length){
				return strArr[i+1];
			}
			
		}
    	return "no_message";
    }
    
		
	@Override
    public boolean processMessage(StringMessage strMsg){

		String msg = strMsg.getMessage();
		    	
    	String[] splited = msg.split("\n");
    	String command = splited[0];
    	if(command.equals("") && splited.length >1) command = splited[1];
    	
    	switch (command) {
    	
		case "CONNECT":
			String host = getValueFromArray(splited, "host");
			String version = getValueFromArray(splited, "accept-version");
			String username = getValueFromArray(splited, "login");
			String password = getValueFromArray(splited, "passcode");
			connect( new ConnectFrame(version, host, username, password) );
			break;
			
		case "DISCONNECT":
			String receipt = getValueFromArray(splited, "receipt");
			disconnect( new DisconnectFrame(receipt) );
			break;

		case "SUBSCRIBE":
			String destination = getValueFromArray(splited, "destination");
			String subscribeId = getValueFromArray(splited, "id");
			if( subscribe( new SubscribeFrame(destination,subscribeId) )){ //[twitter] success following user
				_usersDatabase.getUser(destination).incrementFollowers();
				//_connectionHandler.send(new ServerMessageFrame(_username,"-1","following "+destination).getEncodedString());
				_connectionHandler.addOutData(ByteBuffer.wrap(new ServerMessageFrame(_username,"-1","following "+destination).getBytes()));
			}
			break;
			
		case "UNSUBSCRIBE":
			String unsubscribeId = getValueFromArray(splited, "id");
			unsubscribe( new UnsubscribeFrame(unsubscribeId) );
			break;

		case "SEND":
			String sendDestination = getValueFromArray(splited, "destination");
			String message = getBody(splited);
			return processSendFrameFromUser( new SendFrame(sendDestination,message) );
			//break;

		default:
			break;
		}

        return false;
    }
 
	/**
	 * processes SendFrame from a user
	 * @param sendFrame
	 * @return
	 */
    private boolean processSendFrameFromUser(SendFrame sendFrame) {
    	Long currentTime = System.currentTimeMillis();
		LOGGER.info("[<<] [request=send] [username='"+_username+"'] [destination="+sendFrame.getDestination()+"] [message="+sendFrame.getMessage()+"]");
		String toUser = sendFrame.getDestination();
		String message = sendFrame.getMessage();

		_usersDatabase.incrementTweets(toUser); //user tweets ++
		
		if(toUser.equals("server")){
			//speical server command received from user
	    	String[] splited = message.split(" ");
	    	switch (splited[0]) {
			case "clients":
				//user should now get back a list of all the registered clients in the system
				boolean online = false;
				if(splited.length > 1 && splited[1].equals("online")){
					//user should now get all online users
					online = true;
				}
				String listOfUsers = getListOfUsers(online);
				_topicsDatabase.addMessageToTopic("server",listOfUsers);
				break;
			case "stats":
				//users should get all gathered statistics
				_topicsDatabase.addMessageToTopic("server",_statistics.generateStatisticsInformation());
				break;
			case "stop":
				return true;
			default:
				break;
			}
		}
		else{
			//regular msg from a user to a topic
			_statistics.addTweet();
			_topicsDatabase.addMessageToTopic(toUser,message);
			handleMentionedUsers(sendFrame); //[twitter] send to attached users '@otheruser'
			_statistics.addTweetPassTime(System.currentTimeMillis()-currentTime);
			//TODO: this is not really sending so this measurement will be very low
		}
		return false;
		
    }


	private String getListOfUsers(boolean online) {
		StringBuilder usersList = new StringBuilder();
		usersList.append("[");
		if(online) usersList.append("online ");
		usersList.append("users] ");

		usersList.append(_usersDatabase.printUsers(online));
			
		return usersList.toString();
	}

	/**
	 * checks the msg for mentionings of other users and tags them
	 * @param sendFrame
	 */
	private void handleMentionedUsers(SendFrame sendFrame) {
		List<String> users = getMentionedUsers(sendFrame.getMessage());
		int numOfMentions = 0;
		for (String user : users) {
			_usersDatabase.incrementMentions(user);
			_topicsDatabase.addMessageToTopic(user,sendFrame.getMessage());
			numOfMentions++;
		}
		_usersDatabase.incrementMentioning(sendFrame.getDestination(),numOfMentions);
	}

	private List<String> getMentionedUsers(String message) {
		List<String> users = new ArrayList<String>();
		
		int from=0;
		boolean found = false;
		for (int i = 0; i < message.length(); i++) {
			if(!found){
				if(message.charAt(i) == '@'){
					from = i;
					found = true;
				}
			}
			else if(found){
				if(message.charAt(i) == ' '){
					users.add(message.substring(from+1,i));
					found = false;
				}
				if(message.charAt(i) == '@'){
					users.add(message.substring(from+1,i));
					from = i;
				}
			}
			
		}
		if(found){
			users.add(message.substring(from+1,message.length()));
		}
		return users;
	}


	private void unsubscribe(UnsubscribeFrame unsubscribeFrame){
		String unsubscribeId = unsubscribeFrame.getId();
		LOGGER.info("[<<] [request=unsubscribe] [username='"+_username+"'] [id="+unsubscribeId+"]");

		User user = _usersDatabase.getUser(_username);
		String userToUnfollow = user.getTopicName(unsubscribeId);
		
		int success = user.removeTopic(unsubscribeId);
		
		switch (success) { //[twitter] unfollow errors
		case -1: //trying to unfollow myself
			writeToHandler(new ErrorFrame("Trying to unfollow itself", "You can not unfollow yourself"));
			break;
		case 0: //success
			_usersDatabase.getUser(userToUnfollow).decreaseFollowers();
			writeToHandler(new ServerMessageFrame(_username,"-1","No longer following "+userToUnfollow));
			break;
		case 1: // trying to unfollow user that im not following
			writeToHandler(new ErrorFrame("Not following this user", ""));
			break;

		default:
			break;
		}

	}

	private boolean subscribe(SubscribeFrame subscribeFrame) {
		boolean success = true;
		LOGGER.info("[<<] [request=subscribe] [username='"+_username+"'] [topic="+subscribeFrame.getDestination()+"] [id="+subscribeFrame.getId()+"]");
		Topic topic = _topicsDatabase.addUserToTopic(subscribeFrame.getDestination(), _username);
		if(topic == null){ //[twitter] username not found!
			writeToHandler(new ErrorFrame("Wrong username", ""));
			success = false;
		}
		boolean allreadyFollowing = _usersDatabase.getUser(_username).addTopic( topic,subscribeFrame.getId() );
		if(allreadyFollowing){ //[twitter] already following user
			writeToHandler(new ErrorFrame("Already following username", ""));
			success = false;
		}
		return success;
	}

	public boolean isEnd(String msg) {
        return msg.equalsIgnoreCase("bye");
    }

	private void connect(ConnectFrame connectFrame){
		LOGGER.info("[<<] [request=login] [username='"+connectFrame.getUsername()+"'] [password="+connectFrame.getPassword()+"]");

		UsersDatabase.Status status = _usersDatabase.login(connectFrame.getUsername(), connectFrame.getPassword(),_connectionHandler,_topicsDatabase);
		
		switch (status) {
		case ALLREADY_LOGGED_IN:
			LOGGER.info("[error] [type=login failed] [username='"+_username+"'] [reason=user already logged in]");

			writeToHandler(new ErrorFrame("User allready logged in",""));
			break;
		case INVALID_PASSWORD:
			LOGGER.info("[error] [type=login failed] [username='"+_username+"'] [reason=wrong password]");
			writeToHandler( new ErrorFrame("Wrong password",""));
			break;
		case LOGIN_SUCCESS:
			_username = connectFrame.getUsername();
			LOGGER.info("[info] [login success] [username='"+_username+"']");
			writeToHandler(new ConnectedFrame());
			_usersDatabase.getUser( connectFrame.getUsername() ).sendUnreadMessages();
			break;

		default:
			break;
		}
	}
	
	private void writeToHandler(StompFrame frame)
	{
		_connectionHandler.addOutData(ByteBuffer.wrap(frame.getBytes()));
	}
	
	private void disconnect(DisconnectFrame disconnectFrame) {
		LOGGER.info("[<<] [request=disconnect] [username='"+_username+"'][receipt="+disconnectFrame.getReceipt()+"]");
		if(_username != null){
			_usersDatabase.logout(_username);
			writeToHandler(new ReceiptFrame(disconnectFrame.getReceipt()));
		}
		else{
			LOGGER.info("[error] [logout failed] [username='"+_username+"'] [reason=user not logged in");

			writeToHandler(new ErrorFrame("User not logged in",""));
		}
	}

	public void setConnectionHanlder(ConnectionHandler connectionHandler) {
		_connectionHandler = connectionHandler;
		
	}

	public String getUsername() {
		return _username;
	}
	
	
	@Override
	public boolean isEnd(StringMessage msg)
	{
		//unused method
		return false;
	}

	@Override
	public boolean shouldClose()
	{
		return _shouldClose;
	}

	@Override
	public void connectionTerminated()
	{
		_shouldClose = true;

	}


	@Override
	public void setConnectionHandler(ConnectionHandler connectionHandler)
	{
		_connectionHandler = connectionHandler;
		
	}

}
