package spl.server.protocols.stomp.frames;

import java.util.HashMap;
import java.util.Map;

public class SendFrame extends StompFrame {
	private String _destination;
	private String _message;
	
	public SendFrame(String destination,String message) {
		_destination = destination;
		_message = message;
	}
	
	@Override
	public String getEncodedString() {
		Map<String, String> map = new HashMap<>();
		map.put("destination",_destination);

		return makeFrame("SEND", map, _message);
	}
	
	public String getDestination(){
		return _destination;
	}
	
	public String getMessage(){
		return _message;
	}

}
