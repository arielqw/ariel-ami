package spl.assc.runnables;

import java.util.concurrent.CountDownLatch;

import spl.assc.model.Dish;
import spl.assc.model.Warehouse;

/**
 * This class handles cooking a single dish
 */
public class RunnableCookOneDish implements Runnable
{
	private Dish _dish;
	private Warehouse _warehouse;
	private RunnableChef _chef;
	private CountDownLatch _countDownLatch;
	
	public RunnableCookOneDish(Dish dish, Warehouse warehouse, RunnableChef chef,CountDownLatch countDownLatch) {
		_dish = dish;
		_warehouse = warehouse;
		_chef = chef;
		_countDownLatch = countDownLatch;
	}
	

	/**
	 * start coocking
	 */
	@Override
	public void run(){
		try {
			cookOneDish();
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	/**
	 * simulates cooking one dish:
	 * taking needed kitchen tools and ingredients from warehouse
	 */
	private void cookOneDish()
	{
		//1. go to warehouse take things.
		_warehouse.take(_dish.getIngredients(), _dish.getKitchenTools());

		//2. sleep needed time
		try {
			Thread.sleep(Math.round(_dish.getExpectedCookTime()*_chef.get_efficiencyRating()));
		} catch (InterruptedException e) {
			e.printStackTrace();
		}
		
		//3. return used kitchen tools
		_warehouse.putBack(_dish.getKitchenTools());

		_countDownLatch.countDown();
	}
	


}
