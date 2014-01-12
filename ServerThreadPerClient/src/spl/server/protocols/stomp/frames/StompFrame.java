package spl.server.protocols.stomp.frames;

import java.util.Map;
import java.util.Map.Entry;
import java.util.Set;



import spl.server.MessageFrame;


public abstract class StompFrame extends MessageFrame
{	
	protected String makeFrame(String header, Map<String, String> map, String body)
	{
		StringBuilder builder = new StringBuilder();
		builder.append(header);
		builder.append("\n");
		Set<Entry<String, String>> entries = map.entrySet();
		for (Entry<String, String> entry : entries)
		{
			builder.append(entry.getKey());
			builder.append(":");
			builder.append(entry.getValue());
			builder.append("\n");
		}
		builder.append("\n");
		builder.append("\n");
		builder.append(body);
		builder.append("\u0000");
		builder.append("\n");
		return builder.toString();
	}

}
