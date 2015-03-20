package spl.server.stomp.frames;

import java.util.HashMap;
import java.util.Map;


public class ConnectedFrame extends StompFrame {



	@Override
	public String getEncodedString() {
		Map<String, String> map = new HashMap<>();
		map.put("version","1.2");

		return makeFrame("CONNECTED", map, "");
	}


}
