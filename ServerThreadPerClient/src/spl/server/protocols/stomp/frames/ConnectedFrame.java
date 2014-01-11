package spl.server.protocols.stomp.frames;

import java.util.HashMap;
import java.util.Map;

import spl.server.MessagingProtocol;

public class ConnectedFrame extends StompFrame {

	@Override
	public String getEncodedString() {
		Map<String, String> map = new HashMap<>();
		map.put("version","1.2");

		return makeFrame("CONNECTED", map, "");
	}


}
