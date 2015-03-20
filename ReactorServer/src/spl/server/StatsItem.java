package spl.server;

/**
 * utility object to help calculate server statistics
 *
 */
public class StatsItem {
	private UsersDatabase _usersDB;
	
	private User _mostFamousUser;
	private User _maxTweetsUser;
	private User _maxMentioningUser;
	private User _maxMentionedUser;
	
	public StatsItem(UsersDatabase usersDB) {
		_usersDB = usersDB;
	}
	public void compute(){
		_mostFamousUser = computeMostFamousUser();
		_maxTweetsUser = computeMaxTweetsUser();
		_maxMentioningUser = computeMaxMentioningUser();
		_maxMentionedUser = computeMaxMentionedUser();
	}
	
	private User computeMostFamousUser(){
		return _usersDB.computeMostFamousUser();
	}

	private User computeMaxTweetsUser(){
		return _usersDB.computeMaxTweetsUser();
	}
	
	private User computeMaxMentioningUser(){
		return _usersDB.computeMaxMentioningUser();
	}	
	
	private User computeMaxMentionedUser(){
		return _usersDB.computeMaxMentionedUser();
	}
	
	
	public User getMostFamousUser() {
		return _mostFamousUser;
	}

	public User getMaxTweetsUser() {
		return _maxTweetsUser;
	}

	public User getMaxMentioningUser() {
		return _maxMentioningUser;
	}

	public User getMaxMentionedUser() {
		return _maxMentionedUser;
	}
}
