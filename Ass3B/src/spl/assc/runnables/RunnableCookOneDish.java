package spl.assc.runnables;

import java.util.concurrent.CountDownLatch;
import java.util.logging.Logger;

import spl.assc.model.Dish;
import spl.assc.model.Warehouse;

public class RunnableCookOneDish implements Runnable
{
	private final static Logger LOGGER = Logger.getGlobal();

	private Dish _dish;
	private Warehouse _warehouse;
	private RunnableChef _chef;
	private CountDownLatch _countDownLatch;
	
	public RunnableCookOneDish(Dish dish, Warehouse warehouse, RunnableChef chef,CountDownLatch countDownLatch) {
		// TODO Auto-generated constructor stub
		_dish = dish;
		_warehouse = warehouse;
		_chef = chef;
		_countDownLatch = countDownLatch;
	}
	

	
	@Override
	public void run()
	{
		//1. go to warehouse take things.
		_warehouse.take(_dish.get_ingredients(), _dish.get_kitchenTools());
		//2. sleep needed time
		try {
			//LOGGER.info("going to wait for: "+Math.round(_dish.get_expectedCookTime()*_chef.get_efficiencyRating())+" milisecs");
			Thread.sleep(Math.round(_dish.get_expectedCookTime()*_chef.get_efficiencyRating()));
		} catch (InterruptedException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
		_warehouse.putBack(_dish.get_kitchenTools());
		_countDownLatch.countDown();
	}
	


}
