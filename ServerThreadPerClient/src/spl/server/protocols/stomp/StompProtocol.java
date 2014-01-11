package spl.server.protocols.stomp;

import java.io.IOException;
import java.util.Date;

import spl.server.ConnectionHandler;
import spl.server.TopicsDatabase;
import spl.server.Topic;
import spl.server.MessageFrame;
import spl.server.MessagingProtocol;
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
import spl.server.UsersDatabase;
public class StompProtocol implements MessagingProtocol {
 
    private boolean _shouldClose;
    private int _lineNumber;
    private UsersDatabase _usersDatabase;
    private TopicsDatabase _entriesDatabase;
    private String _username;
	private ConnectionHandler _connectionHandler;
	static private volatile long messageIdCounter=0;
	
    public StompProtocol(UsersDatabase usersDatabase, TopicsDatabase entriesDatabase) {
        _shouldClose = false;
        _lineNumber = 0;
        _usersDatabase = usersDatabase;
        _entriesDatabase = entriesDatabase;
        _username = null;
        _connectionHandler = null;
        
    }
 
    public boolean shouldClose() {
        return _shouldClose;
    }
 
    public void connectionTerminated() {
        _shouldClose = true;
    }
    private String getValueFromArray(String[] strArr,String stringToFind){
    	for (String string : strArr) {
    		if(string.length() >= stringToFind.length()){
    			if(string.substring(0,stringToFind.length()).equals(stringToFind)){
					return string.substring(stringToFind.length()+1);
				}
    		}
		}
    	return "not_found";
    }
    private String getBody(String[] strArr){
    	for (int i = 0; i < strArr.length; i++) {
			if(i!=0 && strArr[i].equals("")&& i+1 < strArr.length){
				return strArr[i+1];
			}
			
		}
    	return "no_message";
    }
    
    public boolean processMessage(String msg) throws IOException{

    	MessageFrame ans = null;
    	
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
			subscribe( new SubscribeFrame(destination,subscribeId) );
			break;
			
		case "UNSUBSCRIBE":
			String unsubscribeId = getValueFromArray(splited, "id");
			unsubscribe( new UnsubscribeFrame(unsubscribeId) );
			break;

		case "SEND":
			String sendDestination = getValueFromArray(splited, "destination");
			String message = getBody(splited);
			send( new SendFrame(sendDestination,message) );
			break;

		default:
			break;
		}

        return false;
    }
 
    private void send(SendFrame sendFrame) {
		System.out.println("[send request][destination="+sendFrame.getDestination()+"][message="+sendFrame.getMessage()+"]");
		_entriesDatabase.addMessageToTopic(sendFrame.getDestination(),sendFrame.getMessage());
    }

	public static String generateMessageId() {
		String id = Long.toString(StompProtocol.messageIdCounter);
		StompProtocol.messageIdCounter++;
		return id;
	}

	private void unsubscribe(UnsubscribeFrame unsubscribeFrame) {
		System.out.println("[unsubscribe request][id="+unsubscribeFrame.getId()+"]");
		_usersDatabase.getUser(_username).removeTopic(unsubscribeFrame.getId());
	}

	private void subscribe(SubscribeFrame subscribeFrame) {
		System.out.println("[subscribe request][topic="+subscribeFrame.getDestination()+"][id="+subscribeFrame.getId()+"]");

		Topic topic = _entriesDatabase.addUserToTopic(subscribeFrame.getDestination(), _username);
		_usersDatabase.getUser(_username).addTopic( topic,subscribeFrame.getId() );
	}

	public boolean isEnd(String msg) {
        return msg.equalsIgnoreCase("bye");
    }

	private void connect(ConnectFrame connectFrame) throws IOException{
		System.out.println("[login request][username="+connectFrame.getUsername()+"][password="+connectFrame.getPassword()+"]");

		StompFrame ans = null;
		UsersDatabase.Status status = _usersDatabase.login(connectFrame.getUsername(), connectFrame.getPassword(),_connectionHandler);
		
		switch (status) {
		case ALLREADY_LOGGED_IN:
			System.out.println("[login failed][reason=already logged in]");
			ans = new ErrorFrame("User allready logged in","");
			_connectionHandler.send(ans.getEncodedString());
			break;
		case INVALID_PASSWORD:
			System.out.println("[login failed][reason=wrong password]");
			ans = new ErrorFrame("Wrong password","");
			_connectionHandler.send(ans.getEncodedString());
			break;
		case LOGIN_SUCCESS:
			System.out.println("[login success]");
			_username = connectFrame.getUsername();
			ans = new ConnectedFrame();
			_connectionHandler.send(ans.getEncodedString());
			_usersDatabase.getUser( connectFrame.getUsername() ).sendUnreadMessages();
			break;

		default:
			System.out.println("[DEFUALT]");
			break;
		}
	}
	
	private void disconnect(DisconnectFrame disconnectFrame) throws IOException {
		System.out.println("[disconnect request][receipt="+disconnectFrame.getReceipt()+"]");

		StompFrame ans = null;
		if(_username != null){
			_usersDatabase.logout(_username);
			ans = new ReceiptFrame(disconnectFrame.getReceipt());
		}
		else{
			System.out.println("[logout failed][reason=user not logged in]");
			ans = new ErrorFrame("User not logged in","");
		}
		_connectionHandler.send(ans.getEncodedString());
	}

	@Override
	public void setConnectionHanlder(ConnectionHandler connectionHandler) {
		_connectionHandler = connectionHandler;
		
	}

}