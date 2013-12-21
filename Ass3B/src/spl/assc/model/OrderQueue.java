package spl.assc.model;

import java.util.List;
import java.util.Queue;

public class OrderQueue
{
	public OrderQueue(Queue<Order> orders) {
		_orders = orders;
	}
	
	
	private Queue<Order> _orders;
	
	public Queue<Order> get_orders() {
		return _orders;
	}

	@Override
	public String toString()
	{
		StringBuilder builder = new StringBuilder();
		builder.append("***************************\n***\tOrderQueue:\t***\n***************************\n");
		
		for (int i = 0; i < _orders.size(); i++)
		{
			builder.append(i+1);
			builder.append(":");
			builder.append(_orders.toArray()[i].toString());
		}
		
		return builder.toString();
	}
}
