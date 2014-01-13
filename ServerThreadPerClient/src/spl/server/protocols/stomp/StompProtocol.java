package spl.server.protocols.stomp;
import java.io.IOException;
import java.util.Vector;
import java.util.logging.Logger;

import spl.server.ConnectionHandler;
import spl.server.MessagingProtocol;
import spl.server.Server;
import spl.server.Statistics;
import spl.server.Topic;
import spl.server.TopicsDatabase;
import spl.server.User;
import spl.server.UsersDatabase;
import spl.server.protocols.stomp.frames.ConnectFrame;
import spl.server.protocols.stomp.frames.ConnectedFrame;
import spl.server.protocols.stomp.frames.DisconnectFrame;
import spl.server.protocols.stomp.frames.ErrorFrame;
import spl.server.protocols.stomp.frames.ReceiptFrame;
import spl.server.protocols.stomp.frames.SendFrame;
import spl.server.protocols.stomp.frames.ServerMessageFrame;
import spl.server.protocols.stomp.frames.StompFrame;
import spl.server.protocols.stomp.frames.SubscribeFrame;
import spl.server.protocols.stomp.frames.UnsubscribeFrame;
public class StompProtocol implements MessagingProtocol {
	private final static Logger LOGGER = Logger.getGlobal();

    private boolean _shouldClose;
    private int _lineNumber;
    private UsersDatabase _usersDatabase;
    private TopicsDatabase _topicsDatabase;
    private String _username;
	private ConnectionHandler _connectionHandler;
	static private volatile long messageIdCounter=0;
	private Server _server;
	private Statistics _statistics;
	
    public StompProtocol(UsersDatabase usersDatabase, TopicsDatabase entriesDatabase, Server server, Statistics statistics) {
        _shouldClose = false;
        _lineNumber = 0;
        _usersDatabase = usersDatabase;
        _topicsDatabase = entriesDatabase;
        _username = null;
        _connectionHandler = null;
        _server = server;
        _statistics = statistics;
        
    }
 
    public boolean shouldClose() {
        return _shouldClose;
    }
 
    public void connectionTerminated() {
        _shouldClose = true;
    }
    
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
    protected String getBody(String[] strArr){
    	for (int i = 0; i < strArr.length; i++) {
			if(i!=0 && strArr[i].equals("")&& i+1 < strArr.length){
				return strArr[i+1];
			}
			
		}
    	return "no_message";
    }
    
    /**
     * Processing messages recieved from clients
     */
    public boolean processMessage(String msg) throws IOException{
    	
    	//splitting to chunks
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
				_usersDatabase.getUser(destination).incrementFollowers(); //user followers++
				_connectionHandler.send(new ServerMessageFrame(_username,"-1","following "+destination).getEncodedString()); // following msg to client
			}
			break;
			
		case "UNSUBSCRIBE":
			String unsubscribeId = getValueFromArray(splited, "id");
			unsubscribe( new UnsubscribeFrame(unsubscribeId) );
			break;

		case "SEND":
			String sendDestination = getValueFromArray(splited, "destination");
			String message = getBody(splited);
			return (send( new SendFrame(sendDestination,message) ));
			//break;

		default:
			break;
		}

        return false;
    }
 
    /**
     * handling 'tweets' from client
     * @param sendFrame
     * @return true if needs to shutdown server
     */
    private boolean send(SendFrame sendFrame) {
    	Long currentTime = System.currentTimeMillis(); //tweet hanlding start time
		LOGGER.info("[<<] [request=send] [username='"+_username+"'] [destination="+sendFrame.getDestination()+"] [message="+sendFrame.getMessage()+"]");
		String toUser = sendFrame.getDestination();
		String message = sendFrame.getMessage();

		_usersDatabase.incrementTweets(toUser); //user tweets ++
		
		//server control commands
		if(toUser.equals("server")){
	    	String[] splited = message.split(" ");
	    	switch (splited[0]) {
	    	
	    	//command clients {online}
			case "clients":
				boolean online = false;
				if(splited.length > 1 && splited[1].equals("online")){
					online = true;
				}
				String listOfUsers = getListOfUsers(online);
				_topicsDatabase.addMessageToTopic("server",listOfUsers);
				break;
				
			//command stats -generate statistics
			case "stats":
				_topicsDatabase.addMessageToTopic("server",_statistics.generateStatisticsInformation());
				break;
			
			//command stop - shutdown server
			case "stop":
				stopServer();
				return true;
				//break;

			default:
				break;
			}
		}
		else{
			_statistics.addTweet(); //for handling statistics
			
			_topicsDatabase.addMessageToTopic(toUser,message); //sending tweet to relevant user
			handleMentionedUsers(sendFrame); //[twitter] send to attached users '@otheruser'
			
			_statistics.addTweetPassTime(System.currentTimeMillis()-currentTime);
		}
		return false;
    }

	private void stopServer() {
		LOGGER.info("[<<] [request=stop server] [username='"+_username+"']");
		_usersDatabase.closeConnections();
		_server.shutdown();
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
	 * sends tweet to all users attached in the message (@user)
	 * @param sendFrame
	 */
	private void handleMentionedUsers(SendFrame sendFrame) {
		Vector<String> users = getMentionedUsers(sendFrame.getMessage());
		int numOfMentions = 0;
		for (String user : users) {
			_usersDatabase.incrementMentions(user);
			_topicsDatabase.addMessageToTopic(user,sendFrame.getMessage());
			numOfMentions++;
		}
		_usersDatabase.incrementMentioning(sendFrame.getDestination(),numOfMentions);
	}

	private Vector<String> getMentionedUsers(String message) {
		Vector<String> users = new Vector<>();
		
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

	/**
	 * generating a unique message id
	 * @return id
	 */
	public static String generateMessageId() {
		String id = Long.toString(StompProtocol.messageIdCounter);
		StompProtocol.messageIdCounter++;
		return id;
	}

	
	private void unsubscribe(UnsubscribeFrame unsubscribeFrame) throws IOException{
		String unsubscribeId = unsubscribeFrame.getId();
		LOGGER.info("[<<] [request=unsubscribe] [username='"+_username+"'] [id="+unsubscribeId+"]");

		User user = _usersDatabase.getUser(_username);
		String userToUnfollow = user.getTopicName(unsubscribeId);
		
		int success = user.removeTopic(unsubscribeId);
		
		switch (success) { //[twitter] unfollow errors
		case -1: //trying to unfollow myself
			_connectionHandler.send(new ErrorFrame("Trying to unfollow itself", "You can not unfollow yourself").getEncodedString());
			break;
		case 0: //success
			_usersDatabase.getUser(userToUnfollow).decreaseFollowers();
			_connectionHandler.send(new ServerMessageFrame(_username,"-1","No longer following "+userToUnfollow).getEncodedString());
			break;
		case 1: // trying to unfollow user that im not following
			_connectionHandler.send(new ErrorFrame("Not following this user", "").getEncodedString());
			break;

		default:
			break;
		}

	}

	private boolean subscribe(SubscribeFrame subscribeFrame) throws IOException {
		boolean success = true;
		LOGGER.info("[<<] [request=subscribe] [username='"+_username+"'] [topic="+subscribeFrame.getDestination()+"] [id="+subscribeFrame.getId()+"]");
		
		Topic topic = _topicsDatabase.addUserToTopic(subscribeFrame.getDestination(), _username);
		
		if(topic == null){ //[twitter] username not found!
			_connectionHandler.send(new ErrorFrame("Wrong username", "").getEncodedString());
			success = false;
		}
		
		boolean allreadyFollowing = _usersDatabase.getUser(_username).addTopic( topic,subscribeFrame.getId() );
		
		if(allreadyFollowing){ //[twitter] already following user
			_connectionHandler.send(new ErrorFrame("Already following username", "").getEncodedString());
			success = false;
		}
		return success;
	}

	public boolean isEnd(String msg) {
		//unused
        return msg.equalsIgnoreCase("bye");
    }

	/**
	 * hanlding connect request from client
	 * @param connectFrame
	 * @throws IOException
	 */
	private void connect(ConnectFrame connectFrame) throws IOException{
		LOGGER.info("[<<] [request=login] [username='"+connectFrame.getUsername()+"'] [password="+connectFrame.getPassword()+"]");

		StompFrame ans = null;
		UsersDatabase.Status status = _usersDatabase.login(connectFrame.getUsername(), connectFrame.getPassword(),_connectionHandler,_topicsDatabase);
		
		switch (status) {
		
		case ALLREADY_LOGGED_IN:
			LOGGER.info("[error] [type=login failed] [username='"+_username+"'] [reason=user already logged in]");

			ans = new ErrorFrame("User allready logged in","");
			_connectionHandler.send(ans.getEncodedString());
			break;
		case INVALID_PASSWORD:
			LOGGER.info("[error] [type=login failed] [username='"+_username+"'] [reason=wrong password]");
			ans = new ErrorFrame("Wrong password","");
			_connectionHandler.send(ans.getEncodedString());
			break;
		case LOGIN_SUCCESS:
			_username = connectFrame.getUsername();
			LOGGER.info("[info] [login success] [username='"+_username+"']");
			ans = new ConnectedFrame();
			_connectionHandler.send(ans.getEncodedString());
			_usersDatabase.getUser( connectFrame.getUsername() ).sendUnreadMessages(); //sending unread tweets to user
			break;

		default:
			break;
		}
	}
	
	private void disconnect(DisconnectFrame disconnectFrame) throws IOException {
		LOGGER.info("[<<] [request=disconnect] [username='"+_username+"'][receipt="+disconnectFrame.getReceipt()+"]");
		StompFrame ans = null;
		if(_username != null){
			_usersDatabase.logout(_username);
			ans = new ReceiptFrame(disconnectFrame.getReceipt());
		}
		else{
			LOGGER.info("[error] [logout failed] [username='"+_username+"'] [reason=user not logged in");

			ans = new ErrorFrame("User not logged in","");
		}
		_connectionHandler.send(ans.getEncodedString());
	}

	@Override
	public void setConnectionHanlder(ConnectionHandler connectionHandler) {
		_connectionHandler = connectionHandler;
		
	}

	@Override
	public void terminate() {
		_shouldClose = true;
		
	}

	@Override
	public String getUsername() {
		return _username;
	}

}