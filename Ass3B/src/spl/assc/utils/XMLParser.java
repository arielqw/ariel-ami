package spl.assc.utils;
import java.io.File;
import java.io.ObjectInputStream.GetField;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Queue;
import java.util.logging.Logger;

import javax.xml.XMLConstants;
import javax.xml.crypto.NodeSetData;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.validation.Schema;
import javax.xml.validation.SchemaFactory;

import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.NamedNodeMap;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.xml.sax.SAXException;
import org.xml.sax.SAXParseException;

import spl.assc.model.Address;
import spl.assc.model.Dish;
import spl.assc.model.Ingredient;
import spl.assc.model.KitchenTool;
import spl.assc.model.Menu;
import spl.assc.model.Order;
import spl.assc.model.OrderOfDish;
import spl.assc.model.ResturantInitData;
import spl.assc.model.Warehouse;
import spl.assc.runnables.RunnableChef;
import spl.assc.runnables.RunnableDeliveryPerson;


public class XMLParser
{
	
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
	
	private static Document getDocumentFromXML(String filename)
	{
		DocumentBuilderFactory documentBuilder = DocumentBuilderFactory.newInstance();
		documentBuilder.setIgnoringElementContentWhitespace(true);
		Schema schema;
		Document document = null;
		try
		{
			schema = SchemaFactory.newInstance(XMLConstants.W3C_XML_SCHEMA_NS_URI).newSchema(new File(filename.substring(0, filename.length()-3)+"xsd"));
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
	
	public static Menu parseMenu(String filename)
	{
		Document doc = getDocumentFromXML(filename);
		Map<String,Dish> dishes = new HashMap<String, Dish>();

		NodeList dishNodes = doc.getElementsByTagName("Dish");

		for (int i = 0; i < dishNodes.getLength(); i++)
		{
			NodeList kitchenToolNodes 		= ((Element)dishNodes.item(i)).getElementsByTagName("KitchenTool");
			List<KitchenTool> kitchenTools 	= parseKitchenTools(kitchenToolNodes);
			
			NodeList ingredientNodes 		= ((Element)dishNodes.item(i)).getElementsByTagName("Ingredient");			
			List<Ingredient> ingredients 	= parseIngredients(ingredientNodes);
			
			String name = 			getNodeStringValue(dishNodes.item(i), "name");
			int difficultyRating = 	getNodeIntValue(dishNodes.item(i), "difficultyRating");
			long expectedCookTime = getNodeLongValue(dishNodes.item(i), "expectedCookTime");
			int reward = 			getNodeIntValue(dishNodes.item(i), "reward");
			dishes.put(name,new Dish(name, difficultyRating, expectedCookTime, reward, kitchenTools, ingredients));
		}
		
		return new Menu(dishes);
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
	
	private static List<KitchenTool> parseKitchenTools(NodeList kitchenToolNodes)
	{
		List<KitchenTool> kitchenTools = new ArrayList<>();
		for (int i = 0; i < kitchenToolNodes.getLength(); i++)
		{
			String name = 	getNodeStringValue(kitchenToolNodes.item(i), "name");  			
			int quantity = 	getNodeIntValue(kitchenToolNodes.item(i), "quantity");
			kitchenTools.add(new KitchenTool(name, quantity));
		}
		return kitchenTools;
	}
	
	
	///////////////////////////////////////////////////////////////////
	
	//////////// OrderList ////////////////////////////////////////////	

	public static Queue<Order> parseOrderList(String filename)
	{
		Queue<Order> orders = new LinkedList<>();
		
		Document doc = getDocumentFromXML(filename);

		NodeList orderNodes = doc.getElementsByTagName("Order");

		for (int i = 0; i < orderNodes.getLength(); i++)
		{
			int id = Integer.parseInt(((Element)orderNodes.item(i)).getAttribute("id"));
			int x = getNodeIntValue(orderNodes.item(i), "x");
			int y = getNodeIntValue(orderNodes.item(i), "y");
			Address address = new Address(x, y);
			
			
			NodeList orderOfDishNodes 		= ((Element)orderNodes.item(i)).getElementsByTagName("Dish");
			List<OrderOfDish> ordersOfDish 	= parseOrderOfDish(orderOfDishNodes);
			
			orders.add(new Order(id, address, ordersOfDish));
		}
		
		return orders;
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
	
	public static ResturantInitData parseResturant(String filename)
	{
		Document document = getDocumentFromXML(filename);
		Warehouse warehouse = new Warehouse(parseKitchenTools(document.getElementsByTagName("KitchenTool")), parseIngredients(document.getElementsByTagName("Ingredient")));
		List<RunnableChef> chefs = 						parseChefs(document.getElementsByTagName("Chef"));
		List<RunnableDeliveryPerson> deliveryGuys = 	parseDeliveryGuys(document.getElementsByTagName("DeliveryPerson"));
		return new ResturantInitData(chefs, deliveryGuys, warehouse);
	}
	
	private static List<RunnableChef> parseChefs(NodeList chefNodes)
	{
		List<RunnableChef> chefs = new ArrayList<>();
		for (int i = 0; i < chefNodes.getLength(); i++)
		{
			String name = 	getNodeStringValue(chefNodes.item(i), "name");  			
			double efficiencyRating = 	getNodeDoubleValue(chefNodes.item(i), "efficiencyRating");
			int enduranceRating = 	getNodeIntValue(chefNodes.item(i), "enduranceRating");
			chefs.add(new RunnableChef(name, efficiencyRating, enduranceRating));
		}
		return chefs;
	}
	
	private static List<RunnableDeliveryPerson> parseDeliveryGuys(NodeList deliveryGuysNodes)
	{
		List<RunnableDeliveryPerson> deliveryGuys = new ArrayList<>();
		for (int i = 0; i < deliveryGuysNodes.getLength(); i++)
		{
			String name = 	getNodeStringValue(deliveryGuysNodes.item(i), "name");  			
			int speed = 	getNodeIntValue(deliveryGuysNodes.item(i), "speed");
			deliveryGuys.add(new RunnableDeliveryPerson(name, speed));
		}
		return deliveryGuys;
	}
	
	
	
	///////////////////////////////////////////////////////////////////
}
