package spl.server.protocols.stomp.frames;

import java.util.HashMap;
import java.util.Map;

public class ErrorFrame extends StompFrame {

	private String _shortDescription;
	private String _body;
	public ErrorFrame(String shortDescription ,String body) {
		_shortDescription = shortDescription;
		_body = body;
	}
	@Override
	public String getEncodedString() {
		Map<String, String> map = new HashMap<>();
		map.put("message",_shortDescription);

		return makeFrame("ERROR", map, _body);
	}


}
