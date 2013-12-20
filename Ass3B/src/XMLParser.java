import java.io.File;
import java.io.ObjectInputStream.GetField;
import java.util.ArrayList;
import java.util.List;

import javax.xml.crypto.NodeSetData;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;

import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.NamedNodeMap;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.xml.sax.SAXException;
import org.xml.sax.SAXParseException;


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
	
	private static Document getDocumentFromXML(String filename)
	{
	    try {

	    	File file = new File(filename);
	    	DocumentBuilder dBuilder = DocumentBuilderFactory.newInstance().newDocumentBuilder();
	    	return dBuilder.parse(file);
	    }
    	catch (Exception e) {
			e.printStackTrace();
		}
		return null;
	    	
	    	
	}

	
	///////////////////////////////////////////////////////////////////
	
	
	//////////// Menu /////////////////////////////////////////////////
	
	public static Menu parseMenu(String filename)
	{
		Document doc = getDocumentFromXML(filename);
		List<Dish> dishes = new ArrayList<>();

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
			dishes.add(new Dish(name, difficultyRating, expectedCookTime, reward, kitchenTools, ingredients));
			
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

	public static List<Order> parseOrderList(String filename)
	{
		List<Order> orders = new ArrayList<>();
		
		Document doc = getDocumentFromXML(filename);

		NodeList orderNodes = doc.getElementsByTagName("Order");

		for (int i = 0; i < orderNodes.getLength(); i++)
		{
			int id = Integer.parseInt(((Element)orderNodes.item(i)).getAttribute("id"));
			int x = getNodeIntValue(orderNodes.item(i), "x");
			int y = getNodeIntValue(orderNodes.item(i), "y");
			DeliveryAddress address = new DeliveryAddress(x, y);
			
			
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
}
