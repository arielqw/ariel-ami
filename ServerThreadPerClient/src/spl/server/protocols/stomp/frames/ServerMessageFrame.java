package spl.server.protocols.stomp.frames;

import java.util.HashMap;
import java.util.Map;

import spl.server.protocols.stomp.StompProtocol;

public class ServerMessageFrame extends StompFrame {
	private String _destination;
	private String _subscriptionId;
	private String _messageId;
	private String _body;
	
	public ServerMessageFrame(String destination,String subscriptionId,String body) {
		_destination = destination;
		_messageId = StompProtocol.generateMessageId();
		_subscriptionId = subscriptionId;
		_body=body;
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

		return makeFrame("MESSAGE", map, _body);
	}

}
