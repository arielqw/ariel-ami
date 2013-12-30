package spl.assc;

import spl.assc.utils.MyLogger;
import spl.assc.utils.XMLParser;

/**
 * Our program main class which:
 * 1. Calling for Parsing inputs
 * 2. starting up management
 */
public class Driver
{
	public static void main(String[] args)
	{
		new MyLogger().setup();
		
		//Input files
		String INITIALDATA_FILENAME = "InitialData.xml";
		String MENU_FILENAME = "Menu.xml";
		String ORDERS_FILENAME = "OrdersList.xml";
		
		//Creating a new management 
		Management manager = new Management(
								XMLParser.getSizeOf(INITIALDATA_FILENAME,"InitialData.xsd", "Chef"), 
								XMLParser.getSizeOf(INITIALDATA_FILENAME,"InitialData.xsd", "DeliveryPerson"),
								XMLParser.parseAddress(INITIALDATA_FILENAME,"InitialData.xsd") 
							);
		//Parsing data and setting up in management
		try {
			XMLParser.parseResturant(INITIALDATA_FILENAME,"InitialData.xsd",manager);
			XMLParser.parseMenu(MENU_FILENAME,"Menu.xsd",manager);
			XMLParser.parseOrderList(ORDERS_FILENAME,"OrdersList.xsd",manager);
		} catch (Exception e) {
			e.printStackTrace();
		}

		//Starting the program
		try {
			manager.openRestaurant();
			manager.start();
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
	

}
