package spl.assc;

import java.util.ArrayList;
import java.util.List;
import java.util.Queue;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.locks.Lock;
import java.util.logging.Logger;

import spl.assc.model.Menu;
import spl.assc.model.Order;
import spl.assc.model.OrderOfDish;
import spl.assc.model.OrderQueue;
import spl.assc.model.ResturantInitData;
import spl.assc.model.Warehouse;
import spl.assc.runnables.RunnableChef;
import spl.assc.runnables.RunnableDeliveryPerson;


public class Management
{
	private final static Logger LOGGER = Logger.getGlobal();
	
	public Management(ResturantInitData resturant, Menu menu,
			OrderQueue orderQueue) {
		_chefs = resturant.get_chefs();
		_deliveryGuys = resturant.get_deliveryGuys();
		_warehouse = resturant.get_warehouse();
		_orders = orderQueue.get_orders();
	
		/** 
		 * TODO: clean up from constructor.
		 */
		for (Order order : _orders) {
			int tmpDifficulty = 0;
			for (OrderOfDish orderOfDish : order.get_ordersOfDish()) {
				orderOfDish.setDish(menu.getDish( orderOfDish.getName() ));
				tmpDifficulty += orderOfDish.get_dish().get_difficultyRating();
				
			}
			order.setDifficulty(tmpDifficulty);
		}
		
		for (RunnableChef chef : _chefs) {
			chef.setManagment(this);
		}
		
		ExecutorService threadPool = Executors.newFixedThreadPool(_chefs.size());
		for (RunnableChef chef : _chefs) {
			threadPool.execute(chef);
		}
		
		
	}
	
	
	private Queue<Order> _orders;
	private List<RunnableChef> _chefs;
	private List<RunnableDeliveryPerson> _deliveryGuys;
	private Warehouse _warehouse;
	
	private Order pendingOrder;

	
	public Order getPendingOrder() {
		return pendingOrder;
	}
	
	private void switchToNextPendingOrder(){
		pendingOrder = _orders.poll();
	}
	
	public void start()
	{
		while(!_orders.isEmpty()){
			
			synchronized (_orders.peek()) {
				LOGGER.info(String.format("pending order is now: '%s'", _orders.peek().getName() ));
				switchToNextPendingOrder();
				ringTheBell();
				try{
					pendingOrder.wait();
					
				} catch (InterruptedException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
			}
		}
		//statistics

	}

	private void ringTheBell() {
		// TODO Auto-generated method stub
		for (RunnableChef chef : _chefs) {
			synchronized (chef) {
				chef.notifyAll();
			}
		}
	}

	
	
}
