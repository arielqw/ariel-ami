package spl.server;

import java.io.IOException;
import java.util.Map;
import java.util.Queue;
import java.util.Set;
import java.util.Map.Entry;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ConcurrentLinkedQueue;

import spl.server.protocols.stomp.StompProtocol;
import spl.server.protocols.stomp.frames.ServerMessageFrame;

public class User {
	private String _username;
	private String _password;
	private boolean _isLoggedIn;
	private ConnectionHandler _connectionHanlder;
	private Queue<MessageFrame> _myMessages;
	private Map<String, Topic> _myEntries;
	
	public User(String username, String password) {
		_username = username;
		_password = password;
		_isLoggedIn = true;
		_connectionHanlder = null;
		_myMessages = new ConcurrentLinkedQueue<>();
		_myEntries = new ConcurrentHashMap<String, Topic>();
	}
	
	public void login(ConnectionHandler connectionHandler){
		_isLoggedIn = true;
		_connectionHanlder = connectionHandler;
	}
	
	public void logout(){
		_isLoggedIn = false;
		_connectionHanlder = null;
	}
	
	public boolean checkPassword(String password){
		return password.equals(_password);
	}
	
	public boolean isLoggedIn(){
		return _isLoggedIn;
	}

	public String getPw() {
		// TODO Auto-generated method stub
		return _password;
	}

	public void setConnectionHanlder(ConnectionHandler connectionHanlder) {
		_connectionHanlder = connectionHanlder;
	}
	
	public void sendMessage(String destination, String message){
		String subscriptionId = getSubscriptionId(destination);
		if(subscriptionId.equals("not found")) return;
		
		ServerMessageFrame serverMessageFrame = new ServerMessageFrame(destination, subscriptionId, message);
		
		if(_isLoggedIn){
			try { //send it
				_connectionHanlder.send(serverMessageFrame.getEncodedString());
			} catch (IOException e) {
				e.printStackTrace();
			}
		}
		else{ //not logged in -> push to queue
			_myMessages.add(serverMessageFrame);
		}
	}
	
	private String getSubscriptionId(String destination) {
		Set<Entry<String, Topic>> entries = _myEntries.entrySet();
		for (Entry<String, Topic> entry : entries)
		{
			if(entry.getValue().getName().equals(destination)){
				return entry.getKey();
			}
		}
		return "not_found";
	}

	public void sendUnreadMessages(){
		while(!_myMessages.isEmpty()){
			try {
				_connectionHanlder.send(_myMessages.poll().getEncodedString());
			} catch (IOException e) {
				e.printStackTrace();
			}
		}
	}
	
	@Override
	public boolean equals(Object other) {
		if(other instanceof User)
			return _username.equals(((User)other)._username);
		else{
			return false;
		}
	}

	public void addTopic(Topic topic, String id) {
		_myEntries.put(id, topic);
	}
	
	public boolean removeTopic(String id) {
		Topic topic = _myEntries.get(id);
		if(topic != null){
			_myEntries.remove(id);
			topic.removeUser(this);
			return true;
		}
		return false;
	}

}
