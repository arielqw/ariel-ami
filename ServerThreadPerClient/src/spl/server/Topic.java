package spl.server;

import java.util.Vector;

/**
 * a topic which users can subscribe to. in tweeter, a username to follow
 *
 */
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
			if(!user.isServer()){
				user.sendMessage(_topicName,message);
			}
		}
	}

	public String getName() {
		return _topicName;
	}
}
