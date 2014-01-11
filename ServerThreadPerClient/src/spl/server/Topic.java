package spl.server;

import java.util.Vector;

import spl.server.protocols.stomp.StompProtocol;
import spl.server.protocols.stomp.frames.ServerMessageFrame;

public class Topic {
	private String _topicName;
	private Vector<User> _users;
	
	public Topic(String topicName) {
		_topicName = topicName;
		_users = new Vector<>();
	}

	public void addUser(User user) {
		_users.add(user);
	}
	
	public void removeUser(User user){
		for (int i = 0; i < _users.size(); i++) {
			if(user.equals(_users.get(i)) ){
				_users.remove(i);
				return;
			}
		}
	}

	public void addMessage(String message) {
		for (User user : _users) {
			user.sendMessage(_topicName,message);
		}
	}

	public String getName() {
		
		return _topicName;
	}
}
