package spl.server;

import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

public class TopicsDatabase {
	private Map<String, Topic> _topics;
	private UsersDatabase _users;
	
	public TopicsDatabase(UsersDatabase usersDatabase) {
		_topics = new ConcurrentHashMap<>();
		_users = usersDatabase;
		
		//[twitter] server fake username
		Topic topic = addUserToTopic("server", "server"); 
	}
	
	private Topic addTopic(String topicName){
		Topic topic = new Topic(topicName);
		_topics.put(topicName, topic);
		return topic;
	}
	

	public Topic addUserToTopic(String topicName,String username){
		Topic topic = _topics.get(topicName);
		if(topic == null){ //not found
			if( topicName == username){ //[twitter] registering new user = topic
				topic = addTopic(username);
			}
			else{ //error
				return null;
			}
		}
		topic.addUser( _users.getUser(username) );
		return topic;
	}

	public void addMessageToTopic(String topicName, String message) {
		Topic topic = _topics.get(topicName);
		if(topic != null) topic.addMessage(message); //[twitter] can't tweet to a new topic
	}
}
