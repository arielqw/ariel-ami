package spl.server.protocols.stomp.frames;

import java.util.HashMap;
import java.util.Map;

public class SubscribeFrame extends StompFrame {
	private String _destination;
	private String _id;
	public SubscribeFrame(String destination, String id) {
		_destination = destination;
		_id = id;
	}

	public String getId(){
		return _id;
	}
	
	public String getDestination(){
		return _destination;
	}

	@Override
	public String getEncodedString() {
		Map<String, String> map = new HashMap<>();
		map.put("destination",_destination);
		map.put("id",_id);

		return makeFrame("SUBSCRIBE", map, "");
	}

}
