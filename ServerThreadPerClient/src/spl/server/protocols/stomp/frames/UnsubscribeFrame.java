package spl.server.protocols.stomp.frames;

import java.util.HashMap;
import java.util.Map;


public class UnsubscribeFrame extends StompFrame {

	private String _id;
	public UnsubscribeFrame(String id) {
		_id = id;
	}

	public String getId(){
		return _id;
	}
	
	@Override
	public String getEncodedString() {
		Map<String, String> map = new HashMap<>();
		map.put("id",_id);

		return makeFrame("UNSUBSCRIBE", map, "");
	}

}
