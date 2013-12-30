package spl.assc;


import java.util.Vector;

import spl.assc.model.Ingredient;
import spl.assc.model.Order;

public class Statistics
{
	private double _moneyGained;
	private Vector<Order> _deliveredOrders;
	//private Vector<Ingredient> _ingredientsConsumed;
	
	public Statistics() {
		_moneyGained = 0;
		_deliveredOrders = new Vector<>();
		//_ingredientsConsumed = new Vector<>();
	}
	public synchronized void add(double reward){
		_moneyGained += reward;
	}
	public void add(Order order){
		_deliveredOrders.add(order);
	}
	/*
	public void add(Ingredient ingredient){
		_ingredientsConsumed.add(ingredient);
	}
	*/
	
	@Override
	public String toString() {
		return String.format("Money Gained: %.2f\nDelivered Orderes: \n%s\nIngredients Consumed: \n%s", _moneyGained,_deliveredOrders.toString(),Management.getInstance().linkToWareHouse().consumedIngredientsReport());
	}
}
