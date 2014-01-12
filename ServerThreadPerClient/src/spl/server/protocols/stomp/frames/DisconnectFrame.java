package spl.server.protocols.stomp.frames;

import java.util.HashMap;
import java.util.Map;

public class DisconnectFrame extends StompFrame {
	private String _receipt;
	
	public DisconnectFrame(String receipt) {
		_receipt = receipt;
	}
	@Override
	public String getEncodedString() {
		Map<String, String> map = new HashMap<>();
		map.put("receipt",_receipt);

		return makeFrame("DISCONNECT", map, "");
	}
	
	public String getReceipt() {
		return _receipt;
	}
	
	

}
