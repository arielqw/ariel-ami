package protocol;

import reactor.TweeterProtocol;
import spl.server.Statistics;
import spl.server.TopicsDatabase;
import spl.server.UsersDatabase;
import tokenizer.StringMessage;

public class TweeterProtocolFactory implements ServerProtocolFactory<StringMessage>
{
	public TweeterProtocolFactory() {	
		_users = new UsersDatabase();
		_topics = new TopicsDatabase(_users);
		_stats = new Statistics(_users, _topics);
	}
    private final UsersDatabase _users;
    private final TopicsDatabase _topics;
    private final Statistics _stats;
	
	@Override
	public AsyncServerProtocol<StringMessage> create()
	{
		return new TweeterProtocol(_users, _topics, _stats);
	}

}
