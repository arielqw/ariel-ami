package spl.assc.runnables;

import spl.assc.model.Dish;
import spl.assc.model.Warehouse;

public class RunnableCookOneDish implements Runnable
{
	public RunnableCookOneDish(Dish dish, Warehouse warehouse, RunnableChef chef) {
		// TODO Auto-generated constructor stub
		_dish = dish;
		_warehouse = warehouse;
		_chef = chef;
	}
	
	private Dish _dish;
	private Warehouse _warehouse;
	private RunnableChef _chef;
	
	
	@Override
	public void run()
	{
		// TODO Auto-generated method stub

	}
	


}
