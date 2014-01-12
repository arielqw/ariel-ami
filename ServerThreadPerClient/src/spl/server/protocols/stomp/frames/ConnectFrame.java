package spl.server.protocols.stomp.frames;

import java.util.HashMap;
import java.util.Map;

import spl.server.MessagingProtocol;
import spl.server.protocols.stomp.StompProtocol;


public class ConnectFrame extends StompFrame {
	private String _hostIP;
	private String _username;
	private String _password;
	private String _version;
	
	public ConnectFrame(String version,String host, String username,String password) {
		_hostIP = host;
		_username = username;
		_password = password;
		_version = version;
	}


	@Override
	public String getEncodedString() {
		Map<String, String> map = new HashMap<>();
		map.put("accept-version","1.2");
		map.put("host",_hostIP);
		map.put("login",_username);
		map.put("passcode",_password);

		return makeFrame("CONNECT", map, "");
	}

	public String getPassword() {
		return _password;
	}
	public String getUsername() {
		return _username;
	}

}
