package spl.server;

import java.util.ArrayList;
import java.util.List;

public class Statistics {
	private UsersDatabase _userDB;
	private TopicsDatabase _topicsDB;
	private long _serverStartingTime;
	private List<Long> _tweets;
	private List<Long> _tweetsPassTime;
	
	public Statistics(UsersDatabase userDB, TopicsDatabase topicsDB) { 
		_userDB = userDB;
		_topicsDB = topicsDB;
		_tweets = new ArrayList<Long>();
		_tweetsPassTime = new ArrayList<Long>();
		_serverStartingTime = System.currentTimeMillis();
	}
 	
	public synchronized void addTweet(){
		_tweets.add(System.currentTimeMillis());
	}
	
	public synchronized void addTweetPassTime(Long time){
		_tweetsPassTime.add(time);
	}
	
	public synchronized String generateStatisticsInformation(){
		StringBuilder builder = new StringBuilder();
		builder.append(String.format("[Max tweets per 5 secs=%d] \n", computeMaxNumberOfTweetsPer5Seconds()));
		builder.append(String.format("[Avg. tweets per 5 secs=%.4f] \n", computeAvgNumberOfTweetsPer5Seconds()));
		builder.append(String.format("[Avg. tweet pass time=%d] \n", computeAvgTweetPassTime()));
		
		StatsItem stats = new StatsItem(_userDB);
		stats.compute();

		builder.append(String.format("[most followers=%s][followers=%s] \n", stats.getMostFamousUser().getUsername() ,stats.getMostFamousUser().getNumOfFollowers()));
		builder.append(String.format("[max mentions by others=%s] \n", stats.getMaxMentionedUser().getUsername()));
		builder.append(String.format("[max mentioning in his tweets=%s] \n", stats.getMaxMentioningUser().getUsername()));
		return builder.toString();
	}

	private long computeAvgTweetPassTime() {
		Long totalTime = 0l;
		
		for (Long time : _tweetsPassTime) {
			totalTime += time;
		}
		if( _tweetsPassTime.size() == 0 ) return 0; 
		return totalTime/_tweetsPassTime.size();
	}

	private double computeAvgNumberOfTweetsPer5Seconds() {
		long totalRunningTime = System.currentTimeMillis() - _serverStartingTime;
		totalRunningTime /= 1000;
		int totalTweets = _tweets.size();
		return (double)(((double)(totalTweets*5.0))/(double)totalRunningTime);
	}

	private int computeMaxNumberOfTweetsPer5Seconds() {
		int maxNumOfTweetsPer5Seconds = 0;
		long toTime;
		for (int i = 0; i < _tweets.size(); i++) {
			toTime = _tweets.get(i)+5000;
			
			int numOfTweetsPer5Seconds=0;
			for (int j = i; j < _tweets.size(); j++) {
				if(_tweets.get(j) <= toTime){
					numOfTweetsPer5Seconds++;
				}
				else{
					break;
				}
			}
			if(numOfTweetsPer5Seconds > maxNumOfTweetsPer5Seconds){
				maxNumOfTweetsPer5Seconds = numOfTweetsPer5Seconds;
			}
		}
		
		return maxNumOfTweetsPer5Seconds;
	}
}