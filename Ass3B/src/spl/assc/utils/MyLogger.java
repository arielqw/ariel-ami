package spl.assc.utils;
import java.util.logging.ConsoleHandler;
import java.util.logging.FileHandler;
import java.util.logging.Formatter;
import java.util.logging.Handler;
import java.util.logging.Level;
import java.util.logging.Logger;


public class MyLogger
{

	public void setup()
	{
		Logger logger = Logger.getGlobal();
		
	
		logger.setLevel(Level.FINEST);
		
		logger.setUseParentHandlers(false);
		Formatter formatter = new MyFormatter();
		
		//change output from System.err to system.out Patch
		class myConsoleHandler extends ConsoleHandler {
			public myConsoleHandler() {
				super();
				this.setOutputStream(System.out);
			}
		}
		
		Handler consoleHandler = new myConsoleHandler();
		consoleHandler.setFormatter(formatter);
		logger.addHandler(consoleHandler);
		
		
		
		try
		{
			Handler fileHandler = new FileHandler("log.log");
			fileHandler.setFormatter(formatter);
			logger.addHandler(fileHandler);
		} 
		catch (Exception e)
		{
			logger.warning("could not create file logger");
		}

	}
}
