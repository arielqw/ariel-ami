package spl.assc;

import java.util.ArrayList;
import java.util.List;
import java.util.Queue;
import java.util.concurrent.BlockingQueue;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.LinkedBlockingQueue;
import java.util.concurrent.locks.Lock;
import java.util.logging.Logger;

import spl.assc.model.Address;
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
	
	//lazy loader for singelton
	private static class LazyHolder {
		private static final Management INSTANCE = new Management();
	}
 

	public static Management getInstance() {
		return LazyHolder.INSTANCE;
	}
	
	public static ResturantInitData resturant;
	public static Menu menu;
	public static OrderQueue orderQueue;
	
	private ExecutorService chefThreadPool;
	private ExecutorService deliveryGuysThreadPool;
	private Statistics _stats;
	
	private Address _address;
	
	public Statistics get_stats() {
		return _stats;
	}

	//private Management(ResturantInitData resturant, Menu menu,
	//		OrderQueue orderQueue) {	
	private Management() {
		_chefs = Management.resturant.get_chefs();
		_deliveryGuys = Management.resturant.get_deliveryGuys();
		_warehouse = Management.resturant.get_warehouse();
		_address = Management.resturant.getAddress();
		
		_orders = orderQueue.get_orders();
		_awaitingOrdersToDeliver = new LinkedBlockingQueue<>();
		_stats = new Statistics();
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
		
		_chefsCountDownLatch = new CountDownLatch(_chefs.size());
		_deliveryGuysCountDownLatch = new CountDownLatch(_deliveryGuys.size());

		
		for (RunnableChef chef : _chefs) {
			chef.setManagment(this);
			chef.setCountDownLatch(_chefsCountDownLatch);
		}
		
		chefThreadPool = Executors.newFixedThreadPool(_chefs.size());
		for (RunnableChef chef : _chefs) {
			chefThreadPool.execute(chef);
		}
		
		deliveryGuysThreadPool = Executors.newFixedThreadPool(_deliveryGuys.size());
		for (RunnableDeliveryPerson deliveryGuy : _deliveryGuys) {
			deliveryGuy.setCountDownLatch(_deliveryGuysCountDownLatch);
			deliveryGuysThreadPool.execute(deliveryGuy);
		}
		
	}
	
	private CountDownLatch _chefsCountDownLatch;
	private CountDownLatch _deliveryGuysCountDownLatch;

	
	private Queue<Order> _orders;
	private List<RunnableChef> _chefs;
	private List<RunnableDeliveryPerson> _deliveryGuys;
	private Warehouse _warehouse;
	
	private Order pendingOrder;
	private BlockingQueue<Order> _awaitingOrdersToDeliver;
	
	public BlockingQueue<Order> get_awaitingOrdersToDeliver() {
		return _awaitingOrdersToDeliver;
	}

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
				LOGGER.info(String.format("[Pending Order Switch] Pending Order is now: [#%d]", _orders.peek().getOrderId() ));
				switchToNextPendingOrder();
				ringTheBell();
				try{
					pendingOrder.wait();
					
				} catch (InterruptedException e) {
					e.printStackTrace();
				}
			}
		}
		
		chefThreadPool.shutdownNow();
		try {
			_chefsCountDownLatch.await();
		} catch (InterruptedException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		deliveryGuysThreadPool.shutdownNow();
		
		try {
			_deliveryGuysCountDownLatch.await();
		} catch (InterruptedException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		LOGGER.info(String.format("[Statistics]\n%s", _stats.toString()));
	}

	private void ringTheBell() {
		// TODO Auto-generated method stub
		for (RunnableChef chef : _chefs) {
			synchronized (chef) {
				chef.notify();
			}
		}
	}

	public Warehouse getWarehouse() {
		return _warehouse;
	}

	public Address getAddress() {
		return resturant.getAddress();
	}

	
	
}
