package spl.server.stomp.frames;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;


public class ServerMessageFrame extends StompFrame {
	private String _destination;
	private String _subscriptionId;
	private String _messageId;
	private String _body;
	private String _time;
	public ServerMessageFrame(String destination,String subscriptionId,String body) {
		_destination = destination;
		_messageId = ServerMessageFrame.generateMessageId();
		_subscriptionId = subscriptionId;
		_body=body;
		_time = new SimpleDateFormat("dd.MM.yyyy HH:mm:ss").format(new Date());
	}
	
	private static String generateMessageId()
	{
		return Long.toString(messageIdCounter++);
	}

	public void setSubscriptionId(String id){
		_subscriptionId = id;
	}
	

	
	@Override
	public String getEncodedString() {
		Map<String, String> map = new HashMap<>();
		map.put("destination",_destination);
		map.put("subscription",_subscriptionId);
		map.put("message-id",_messageId);
		map.put("time",_time);

		return makeFrame("MESSAGE", map, _body);
	}

	static private volatile long messageIdCounter=0;

}
