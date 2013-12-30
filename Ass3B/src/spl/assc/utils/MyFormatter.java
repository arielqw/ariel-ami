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
		SimpleDateFormat sdf = new SimpleDateFormat("HH:mm:ss.SSS");
		return String.format("%s %s\n", 
					sdf.format(new Date(record.getMillis())), 
					record.getMessage()
					);

	}

}
