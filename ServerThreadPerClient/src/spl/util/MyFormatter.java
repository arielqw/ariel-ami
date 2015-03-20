package spl.util;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.logging.Formatter;
import java.util.logging.LogRecord;


/**
 * Custom format for logger
 *
 */
public class MyFormatter extends Formatter
{
	@Override
	public String format(LogRecord record)
	{
		SimpleDateFormat sdf = new SimpleDateFormat("HH:mm:ss");
		return String.format("%s %s\n", 
					sdf.format(new Date(record.getMillis())), 
					record.getMessage()
					);

	}

}
