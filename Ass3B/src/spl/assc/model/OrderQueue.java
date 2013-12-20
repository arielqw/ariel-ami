package spl.assc.model;

import java.util.List;

public class OrderQueue
{
	public OrderQueue(List<Order> orders) {
		_orders = orders;
	}
	
	
	private List<Order> _orders;
	
	@Override
	public String toString()
	{
		StringBuilder builder = new StringBuilder();
		builder.append("***************************\n***\tOrderQueue:\t***\n***************************\n");
		
		for (int i = 0; i < _orders.size(); i++)
		{
			builder.append(i+1);
			builder.append(":");
			builder.append(_orders.get(i).toString());
		}
		
		return builder.toString();
	}
}
