import java.util.Map;
import java.util.Map.Entry;
import java.util.Set;





public class StompFrame extends MessageFrame
{

	@Override
	public String getString()
	{
		// TODO Auto-generated method stub
		return null;
	}
	
	protected String getInTemplate(String header, Map<String, String> map, String body)
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
		builder.append("\u0000");
		builder.append("\n");
		return builder.toString();
	}

}
