package spl.assc;

import java.util.Vector;

import spl.assc.model.Order;
import spl.assc.model.Warehouse;

/**
 * This class handles statistics for the restaurant
 */
public class Statistics
{
	private double _moneyGained;
	private Vector<Order> _deliveredOrders;
	private Warehouse _warehouse;
	
	public Statistics(Warehouse warehouse) {
		_moneyGained = 0;
		_deliveredOrders = new Vector<>();
		_warehouse = warehouse;
	}
	
	//inserting data methods
	public synchronized void add(double reward){
		_moneyGained += reward;
	}
	public void add(Order order){
		_deliveredOrders.add(order);
	}

	
	@Override
	public String toString() {
		StringBuilder builder = new StringBuilder();
		builder.append(String.format("\t\t[Money Gained=%.2f]\n\t\t[Delivered Orderes=]\n",_moneyGained));
		for (Order order : _deliveredOrders) {
			builder.append(String.format("\t%s", order.toString()));
		}
		builder.append("\t\t[Ingredients Consumed]\n");
		builder.append(String.format("\t\t\t%s",_warehouse.consumedIngredientsReport()));

		return builder.toString();

	}
}
