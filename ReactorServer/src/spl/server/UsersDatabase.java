package spl.server;

import java.util.Map;
import java.util.Map.Entry;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;

import reactor.ConnectionHandler;

/** 
 * Database of users
 *
 */
public class UsersDatabase {
	private Map<String, User> _db;
	
	public enum Status{
	    LOGIN_SUCCESS, USER_NOT_FOUND, INVALID_PASSWORD, ALLREADY_LOGGED_IN,
	    LOGGED_OUT_SUCCESS,NOT_LOGGED_IN
	}
	
	public UsersDatabase() {
		_db = new ConcurrentHashMap<>();
		register("server", "h4rdP455W0rd"); //[twitter] fake username server 
	}
	
	private User register(String username, String password){
		User user = null;
		if( !userExists(username) ){ //register a new user or return existing user
			user = new User(username, password);
			_db.put(username, user);
		}
		return user;
	}
	
	private boolean userExists(String username){
		if( _db.get( username ) == null){
			return false;
		}
		return true;
	}
	
	/**
	 * login method
	 * @param username
	 * @param password
	 * @param connectionHandler
	 * @param topicsDatabase
	 * @return INVALID_PASSWORD \ ALLREADY_LOGGED_IN \ LOGIN_SUCCESS
	 */
	public UsersDatabase.Status login(String username, String password, ConnectionHandler connectionHandler, TopicsDatabase topicsDatabase){
		User user = null;
		if( userExists(username) ){
			user = _db.get(username);
			if( !user.checkPassword(password) ){
				return Status.INVALID_PASSWORD;
			}
			else{
				if( user.isLoggedIn() ){
					return Status.ALLREADY_LOGGED_IN;
				}
			}
		}
		else{ //user doesn't exists -> register
			user = register(username, password);
			
			// [Twitter] - follow myself
			Topic topic = topicsDatabase.addUserToTopic(username, username);
			user.addTopic( topic,"-1");
		}
		user.login(connectionHandler);
		return Status.LOGIN_SUCCESS;
	}
	
	/**
	 * logout
	 * @param username
	 * @return NOT_LOGGED_IN \ LOGGED_OUT_SUCCESS \ USER_NOT_FOUND
	 */
	public UsersDatabase.Status logout(String username){
		User user = null;
		if( userExists(username) ){
			user = _db.get(username);
			
			if( !user.isLoggedIn() ){ //not logged in
				return Status.NOT_LOGGED_IN;
			}
			else{
				user.logout();
				return Status.LOGGED_OUT_SUCCESS;
			}
		}
		else{ //user doesn't exists 
			return Status.USER_NOT_FOUND;
		}
	}

	public User getUser(String username) {
		return _db.get(username);
	}

	/**
	 * printing a list of users {online}
	 * @param online
	 * @return
	 */
	public Object printUsers(boolean online) {
		StringBuilder builder = new StringBuilder();

		Set<Entry<String, User>> entries = _db.entrySet();
		for (Entry<String, User> entry : entries)
		{
			if((!online || entry.getValue().isLoggedIn()) && !entry.getKey().equals("server")){
				builder.append(String.format("%s ", entry.getKey()));
			}
		}

		return builder.toString();
	}


	public void incrementTweets(String username) {
		User user = getUser(username);
		if(user != null){
			user.incrementMyTweets();
		}
		
	}

	public void incrementMentions(String username) {
		User user = getUser(username);
		if(user != null){
			user.incrementMentionsOfMe();
		}		
	}

	public void incrementMentioning(String username, int numOfMentions) {
		User user = getUser(username);
		if(user != null){
			user.incrementMentionsIwrote(numOfMentions);
		}		
	}

	public User computeMostFamousUser() {
		User mostFamousUser=null;
		
		Set<Entry<String, User>> entries = _db.entrySet();
		for (Entry<String, User> entry : entries)
		{
			if(entry.getKey().equals("server")) continue;
			
			User tmpUser = entry.getValue();
			if(mostFamousUser == null){
				mostFamousUser = tmpUser;
				continue;
			}
			
			if( tmpUser.getNumOfFollowers() > mostFamousUser.getNumOfFollowers() ){
				mostFamousUser = tmpUser;
			}
		}		

		return mostFamousUser;
	}

	public User computeMaxTweetsUser() {
		User maxTweetsUser=null;
		
		Set<Entry<String, User>> entries = _db.entrySet();
		for (Entry<String, User> entry : entries)
		{
			if(entry.getKey().equals("server")) continue;
			
			User tmpUser = entry.getValue();
			if(maxTweetsUser == null){
				maxTweetsUser = tmpUser;
				continue;
			}
			
			if( tmpUser.getNumOfTweets() > maxTweetsUser.getNumOfTweets() ){
				maxTweetsUser = tmpUser;
			}
		}		

		return maxTweetsUser;
	}

	public User computeMaxMentioningUser() {
		User maxMentioningUser=null;
		
		Set<Entry<String, User>> entries = _db.entrySet();
		for (Entry<String, User> entry : entries)
		{
			if(entry.getKey().equals("server")) continue;
			
			User tmpUser = entry.getValue();
			if(maxMentioningUser == null){
				maxMentioningUser = tmpUser;
				continue;
			}
			
			if( tmpUser.getNumOfMentionsIwrote() > maxMentioningUser.getNumOfMentionsIwrote() ){
				maxMentioningUser = tmpUser;
			}
		}		

		return maxMentioningUser;
	}

	public User computeMaxMentionedUser() {
		User maxMentionedUser=null;
		
		Set<Entry<String, User>> entries = _db.entrySet();
		for (Entry<String, User> entry : entries)
		{
			if(entry.getKey().equals("server")) continue;
			
			User tmpUser = entry.getValue();
			if(maxMentionedUser == null){
				maxMentionedUser = tmpUser;
				continue;
			}
			
			if( tmpUser.getNumOfMentionsOfMe() > maxMentionedUser.getNumOfMentionsOfMe() ){
				maxMentionedUser = tmpUser;
			}
		}		

		return maxMentionedUser;
	}
	
}
