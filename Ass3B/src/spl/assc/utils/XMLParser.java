package spl.assc.utils;
import java.io.File;
import java.util.ArrayList;
import java.util.List;
import java.util.SortedSet;
import java.util.TreeSet;
import java.util.logging.Logger;

import javax.xml.XMLConstants;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.validation.Schema;
import javax.xml.validation.SchemaFactory;

import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

import spl.assc.Management;
import spl.assc.model.Address;
import spl.assc.model.Ingredient;
import spl.assc.model.KitchenTool;
import spl.assc.model.OrderOfDish;


public class XMLParser
{
	private final static Logger LOGGER = Logger.getGlobal();

	//////////// General //////////////////////////////////////////////
	
	private static String getNodeStringValue(Node node, String tagName)
	{
		Element element = (Element)node;
		return element.getElementsByTagName(tagName).item(0).getTextContent();
	}
	
	private static int getNodeIntValue(Node node, String tagName)
	{
		return Integer.parseInt(getNodeStringValue(node, tagName));
	}
	
	private static long getNodeLongValue(Node node, String tagName)
	{
		return Integer.parseInt(getNodeStringValue(node, tagName));
	}
	
	private static double getNodeDoubleValue(Node node, String tagName)
	{
		return Double.parseDouble(getNodeStringValue(node, tagName));
	}
	
	private static Document getDocumentFromXML(String filename, String schemaFilename)
	{
		DocumentBuilderFactory documentBuilder = DocumentBuilderFactory.newInstance();
		documentBuilder.setIgnoringElementContentWhitespace(true);
		Schema schema;
		Document document = null;
		try
		{
			schema = SchemaFactory.newInstance(XMLConstants.W3C_XML_SCHEMA_NS_URI).newSchema(new File(schemaFilename));
			documentBuilder.setSchema(schema);
			document = documentBuilder.newDocumentBuilder().parse(filename);
		} catch (Exception e)
		{
			Logger.getGlobal().severe("xml/xsd error");
		}
		
		return document;
	    	
	    	
	}

	
	///////////////////////////////////////////////////////////////////
	
	
	//////////// Menu /////////////////////////////////////////////////
	
	public static void parseMenu(String filename,String schemaFilename, Management management)
	{
		Document doc = getDocumentFromXML(filename,schemaFilename);

		NodeList dishNodes = doc.getElementsByTagName("Dish");
		LOGGER.info("[DISH]");

		for (int i = 0; i < dishNodes.getLength(); i++)
		{
			NodeList kitchenToolNodes 		= ((Element)dishNodes.item(i)).getElementsByTagName("KitchenTool");
			SortedSet<KitchenTool> kitchenTools 	= parseKitchenTools(kitchenToolNodes);
			
			NodeList ingredientNodes 		= ((Element)dishNodes.item(i)).getElementsByTagName("Ingredient");			
			List<Ingredient> ingredients 	= parseIngredients(ingredientNodes);
			
			String name = 			getNodeStringValue(dishNodes.item(i), "name");
			int difficultyRating = 	getNodeIntValue(dishNodes.item(i), "difficultyRating");
			long expectedCookTime = getNodeLongValue(dishNodes.item(i), "expectedCookTime");
			int reward = 			getNodeIntValue(dishNodes.item(i), "reward");
			management.addMenuDish(name, difficultyRating, expectedCookTime, reward, kitchenTools, ingredients);
			
		}
		LOGGER.info("[/DISH]\n");
	
	}
	
	private static List<Ingredient> parseIngredients(NodeList ingredientNodes)
	{
		List<Ingredient> ingredients = new ArrayList<>();
		for (int i = 0; i < ingredientNodes.getLength(); i++)
		{
			String name = 	getNodeStringValue(ingredientNodes.item(i), "name");  			
			int quantity = 	getNodeIntValue(ingredientNodes.item(i), "quantity");
			ingredients.add(new Ingredient(name, quantity));
		}
		return ingredients;
	}
	
	private static SortedSet<KitchenTool> parseKitchenTools(NodeList kitchenToolNodes)
	{
		
		SortedSet<KitchenTool> kitchenTools = new TreeSet<KitchenTool>(new KitchenToolsComparator());
		for (int i = 0; i < kitchenToolNodes.getLength(); i++)
		{
			String name = 	getNodeStringValue(kitchenToolNodes.item(i), "name");  			
			int quantity = 	getNodeIntValue(kitchenToolNodes.item(i), "quantity");
			kitchenTools.add(new KitchenTool(name, quantity));
		}
		return kitchenTools;
	}
	private static void parseIngredients(NodeList ingredientNodes,Management management)
	{
		LOGGER.info("[INGREDIENTS]");
		for (int i = 0; i < ingredientNodes.getLength(); i++)
		{
			String name = 	getNodeStringValue(ingredientNodes.item(i), "name");  			
			int quantity = 	getNodeIntValue(ingredientNodes.item(i), "quantity");
			management.addIngredient(name, quantity);

		}
		LOGGER.info("[/INGREDIENTS]\n");
	}
	
	private static void parseKitchenTools(NodeList kitchenToolNodes, Management management)
	{
		LOGGER.info("[TOOLS]");
		for (int i = 0; i < kitchenToolNodes.getLength(); i++)
		{
			String name = 	getNodeStringValue(kitchenToolNodes.item(i), "name");  			
			int quantity = 	getNodeIntValue(kitchenToolNodes.item(i), "quantity");
			management.addKitchenTool(name, quantity);
		}
		LOGGER.info("[/TOOLS]\n");
	}
	
	///////////////////////////////////////////////////////////////////
	
	//////////// OrderList ////////////////////////////////////////////	

	public static void parseOrderList(String filename, String schemaFilename,Management management)
	{
		LOGGER.info("[ORDERS]");
		
		Document doc = getDocumentFromXML(filename,schemaFilename);

		NodeList orderNodes = doc.getElementsByTagName("Order");

		for (int i = 0; i < orderNodes.getLength(); i++)
		{
			int id = Integer.parseInt(((Element)orderNodes.item(i)).getAttribute("id"));
			int x = getNodeIntValue(orderNodes.item(i), "x");
			int y = getNodeIntValue(orderNodes.item(i), "y");
			Address address = new Address(x, y);
			
			NodeList orderOfDishNodes 		= ((Element)orderNodes.item(i)).getElementsByTagName("Dish");
			List<OrderOfDish> ordersOfDish 	= parseOrderOfDish(orderOfDishNodes);
			management.addOrder(id, address, ordersOfDish);
		
		}
		LOGGER.info("[/ORDERS]\n");
	}
	
	
	private static List<OrderOfDish> parseOrderOfDish(NodeList orderOfDishNodes)
	{
		List<OrderOfDish> ordersOfDish = new ArrayList<>();
		for (int i = 0; i < orderOfDishNodes.getLength(); i++)
		{
			String name = 	getNodeStringValue(orderOfDishNodes.item(i), "name");  			
			int quantity = 	getNodeIntValue(orderOfDishNodes.item(i), "quantity");
			ordersOfDish.add(new OrderOfDish(name, quantity));
		}
		return ordersOfDish;
	}
	
	///////////////////////////////////////////////////////////////////	
	
	
	//////////// Resturant ////////////////////////////////////////////
	
	public static void parseResturant(String filename,String schemaFilename, Management manager)
	{
		Document document = getDocumentFromXML(filename,schemaFilename);
		
		parseChefs(document.getElementsByTagName("Chef"),manager);
		parseDeliveryGuys(document.getElementsByTagName("DeliveryPerson"),manager);
		parseKitchenTools(document.getElementsByTagName("KitchenTool"),manager);
		parseIngredients(document.getElementsByTagName("Ingredient"),manager);
		
	}
	
	public static Address parseAddress(String filename,String schemaFilename){
		Document document = getDocumentFromXML(filename,schemaFilename);
		Node addressNode = document.getElementsByTagName("Address").item(0);
		Address address = new Address(getNodeIntValue(addressNode, "x"), getNodeIntValue(addressNode, "y"));
		return address;
	}
	
	private static void parseChefs(NodeList chefNodes, Management management)
	{
		LOGGER.info("[CHEFS]");
		for (int i = 0; i < chefNodes.getLength(); i++)
		{
			String name = 	getNodeStringValue(chefNodes.item(i), "name");  			
			double efficiencyRating = 	getNodeDoubleValue(chefNodes.item(i), "efficiencyRating");
			int enduranceRating = 	getNodeIntValue(chefNodes.item(i), "enduranceRating");
			management.addChef(name, efficiencyRating, enduranceRating);
		}
		LOGGER.info("[/CHEFS]\n");
	}
	
	private static void parseDeliveryGuys(NodeList deliveryGuysNodes, Management management)
	{
		LOGGER.info("[DELIVERY]");
		for (int i = 0; i < deliveryGuysNodes.getLength(); i++)
		{
			String name = 	getNodeStringValue(deliveryGuysNodes.item(i), "name");  			
			int speed = 	getNodeIntValue(deliveryGuysNodes.item(i), "speed");
			
			management.addDeliveryGuy(name,speed);
		}
		LOGGER.info("[/DELIVERY]\n");
	}

	public static int getSizeOf(String filename,String schemaFilename,String tag) {
		Document document = getDocumentFromXML(filename,schemaFilename);
		return document.getElementsByTagName(tag).getLength();
	}
	
	
	
	///////////////////////////////////////////////////////////////////
}
