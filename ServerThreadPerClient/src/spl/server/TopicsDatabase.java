package spl.server;

import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

/**
 * Database of topics ('users' in tweeter)
 *
 */
public class TopicsDatabase {
	private Map<String, Topic> _topics;
	private UsersDatabase _users;
	
	public TopicsDatabase(UsersDatabase usersDatabase) {
		_topics = new ConcurrentHashMap<>();
		_users = usersDatabase;
		
		//[twitter] server fake username
		addUserToTopic("server", "server"); 
	}
	
	private Topic addTopic(String topicName){
		Topic topic = new Topic(topicName);
		_topics.put(topicName, topic);
		return topic;
	}
	
	/**
	 * handling follow option in tweeter
	 * @param topicName username to follow
	 * @param username follower username
	 * @return topic (user) to follow
	 */
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
	
	/**
	 * add tweet to a user
	 * @param topicName username
	 * @param message tweet
	 */
	public void addMessageToTopic(String topicName, String message) {
		Topic topic = _topics.get(topicName);
		if(topic != null) topic.addMessage(message); //[twitter] can't tweet to a new topic
	}
}
