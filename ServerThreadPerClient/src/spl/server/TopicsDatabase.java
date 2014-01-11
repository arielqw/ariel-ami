package spl.server;

import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

public class TopicsDatabase {
	private Map<String, Topic> _entries;
	private UsersDatabase _users;
	
	public TopicsDatabase(UsersDatabase usersDatabase) {
		_entries = new ConcurrentHashMap<>();
		_users = usersDatabase;
	}
	
	private Topic addTopic(String topicName){
		Topic topic = new Topic(topicName);
		_entries.put(topicName, topic);
		return topic;
	}
	
	private Topic getTopic(String topicName){
		Topic topic = _entries.get(topicName);
		if( topic == null){ //topic not found -> create it.
			topic = addTopic(topicName);
		}
		return topic;
	}
	public Topic addUserToTopic(String topicName,String username){
		Topic topic = getTopic(topicName);
		topic.addUser( _users.getUser(username) );
		return topic;
	}

	public void addMessageToTopic(String topicName, String message) {
		Topic topic = getTopic(topicName);
		topic.addMessage(message);
	}
}
