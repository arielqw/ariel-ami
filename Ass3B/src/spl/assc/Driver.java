package spl.assc;
import java.util.logging.Logger;

import spl.assc.model.OrderQueue;
import spl.assc.model.ResturantInitData;
import spl.assc.utils.MyLogger;
import spl.assc.utils.XMLParser;


public class Driver
{

	/**
	 * @param args
	 */
	
	public static void main(String[] args)
	{
		new MyLogger().setup();
		
		String INITIALDATA_FILENAME = "InitialData2.xml";
		String MENU_FILENAME = "Menu2.xml";
		String ORDERS_FILENAME = "OrdersList2.xml";
		
		Management manager = new Management(
								XMLParser.getSizeOf(INITIALDATA_FILENAME,"InitialData.xsd", "Chef"), 
								XMLParser.getSizeOf(INITIALDATA_FILENAME,"InitialData.xsd", "DeliveryPerson"),
								XMLParser.parseAddress(INITIALDATA_FILENAME,"InitialData.xsd") 
							);
		
		try {
			XMLParser.parseResturant(INITIALDATA_FILENAME,"InitialData.xsd",manager);
			XMLParser.parseMenu(MENU_FILENAME,"Menu.xsd",manager);
			XMLParser.parseOrderList(ORDERS_FILENAME,"OrdersList.xsd",manager);
		} catch (Exception e) {
			e.printStackTrace();
		}

		try {
			manager.openRestaurant();
			manager.start();
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
	

}
