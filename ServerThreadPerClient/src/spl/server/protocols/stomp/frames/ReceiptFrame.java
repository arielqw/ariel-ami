package spl.server.protocols.stomp.frames;

import java.util.HashMap;
import java.util.Map;

public class ReceiptFrame extends StompFrame {
	private String _receipt;

	public ReceiptFrame(String receipt) {
		_receipt = receipt;
	}

	@Override
	public String getEncodedString() {
		Map<String, String> map = new HashMap<>();
		map.put("receipt-id", _receipt);

		return makeFrame("RECEIPT", map, "");
	}

	public String getReceipt() {
		return _receipt;
	}

}
