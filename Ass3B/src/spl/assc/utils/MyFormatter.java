package spl.assc.utils;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.logging.Formatter;
import java.util.logging.Level;
import java.util.logging.LogRecord;


public class MyFormatter extends Formatter
{

	@Override
	public String format(LogRecord record)
	{
		if (record.getLevel() == Level.FINEST)
		{
			SimpleDateFormat sdf = new SimpleDateFormat("HH:mm:ss.SSS");
			return String.format("[%d|%s|%s][%s:%s]\n%s\n", 
						record.getThreadID(), 
						sdf.format(new Date(record.getMillis())), 
						record.getLevel().getName(), 
						record.getSourceClassName(),
						record.getSourceMethodName(),
						record.getMessage()
						);
		}
		//return String.format("[%d]\t%s\n", record.getThreadID(), record.getMessage());
		SimpleDateFormat sdf = new SimpleDateFormat("HH:mm:ss.SSS");

		return String.format("[%d]%s\n",record.getThreadID(), record.getMessage());

	}

}
