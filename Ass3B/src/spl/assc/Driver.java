package spl.assc;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

import spl.assc.model.Menu;
import spl.assc.model.Order;
import spl.assc.model.OrderQueue;
import spl.assc.model.ResturantInitData;
import spl.assc.utils.MyLogger;
import spl.assc.utils.XMLParser;


public class Driver
{

	/**
	 * @param args
	 */
	
	private final static Logger LOGGER = Logger.getGlobal();

	public static void main(String[] args)
	{
		new MyLogger().setup();
		
		LOGGER.info("Program started...");
		
		
		Menu menu = XMLParser.parseMenu("Menu.xml");
		LOGGER.info(menu.toString());	

		OrderQueue orderQueue = new OrderQueue(XMLParser.parseOrderList("OrdersList.xml"));
		LOGGER.info(orderQueue.toString());
			
		ResturantInitData resturant = XMLParser.parseResturant("InitialData.xml");
		LOGGER.info(resturant.toString());
		
		new Management(resturant, menu, orderQueue);

	}
	

	
	
	


}
