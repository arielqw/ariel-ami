import java.util.List;


public class Driver
{

	/**
	 * @param args
	 */
	public static void main(String[] args)
	{
		// TODO Auto-generated method stub
		
		/*
		Menu menu = XMLParser.parseMenu("menu.xml");
		System.out.println(menu);
		*/
		
		List<Order> orderList = XMLParser.parseOrderList("orderList.xml");
		System.out.println(orderList);

	}
	
	
	


}
