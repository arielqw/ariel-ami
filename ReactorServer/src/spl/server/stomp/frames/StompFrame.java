package spl.server.stomp.frames;

import java.io.Serializable;
import java.util.Map;
import java.util.Map.Entry;
import java.util.Set;

import tokenizer.Message;



public abstract class StompFrame implements Message<StompFrame>
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

	public abstract String getEncodedString();
	
	@Override
	public byte[] getBytes()
	{
		return getEncodedString().getBytes();
	}
	

}
