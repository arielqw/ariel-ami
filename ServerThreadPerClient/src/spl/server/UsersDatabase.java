package spl.server;

import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

import spl.server.protocols.stomp.frames.ErrorFrame;

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
		if( !userExists(username) ){
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
			user.addTopic( topic,"-0");
		}
		user.login(connectionHandler);
		return Status.LOGIN_SUCCESS;
	}
	
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
	
}
