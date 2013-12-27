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

import javax.tools.ForwardingFileObject;

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
	
	//private ExecutorService chefThreadPool;
	//private ExecutorService deliveryGuysThreadPool;
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
		bell = new Object();
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
			chef.setBell(bell);
			chef.setCountDownLatch(_chefsCountDownLatch);
		}
		
		/*
		chefThreadPool = Executors.newFixedThreadPool(_chefs.size());
		for (RunnableChef chef : _chefs) {
			chefThreadPool.execute(chef);
		}
		*/
		for (RunnableChef chef : _chefs) {
			new Thread(chef).start();
		}
		
		/*
		deliveryGuysThreadPool = Executors.newFixedThreadPool(_deliveryGuys.size());
		for (RunnableDeliveryPerson deliveryGuy : _deliveryGuys) {
			deliveryGuy.setCountDownLatch(_deliveryGuysCountDownLatch);
			deliveryGuysThreadPool.execute(deliveryGuy);
		}
		*/
		for (RunnableDeliveryPerson deliveryGuy : _deliveryGuys) {
			deliveryGuy.setCountDownLatch(_deliveryGuysCountDownLatch);
			new Thread(deliveryGuy).start();

		}		
	}
	
	private CountDownLatch _chefsCountDownLatch;
	private CountDownLatch _deliveryGuysCountDownLatch;

	
	private Queue<Order> _orders;
	private List<RunnableChef> _chefs;
	private List<RunnableDeliveryPerson> _deliveryGuys;
	private Warehouse _warehouse;
	private Object bell;
	private Order pendingOrder;
	private BlockingQueue<Order> _awaitingOrdersToDeliver;
	
	public BlockingQueue<Order> get_awaitingOrdersToDeliver() {
		return _awaitingOrdersToDeliver;
	}

	public Order getPendingOrder() {
		return pendingOrder;
	}
	
	
	public void start() throws Exception
	{
		while(!_orders.isEmpty()){
			synchronized (bell) {
				boolean wasOrderTaken = false;
				for (RunnableChef chef : _chefs) {
					if( chef.canYouTakeThisOrder( _orders.peek()) ){
						LOGGER.info(String.format("[Managment] Order: [#%d] was sent to Chef '%s'", _orders.peek().getOrderId(),chef.getName() ));
						wasOrderTaken = true;
						_orders.poll();
						break;
					}
				}
	
				if(!wasOrderTaken){
//					synchronized (bell) {
						bell.wait();
//					}
				}
			}
		}
		
		//Shutdown chefs
		for (RunnableChef chef : _chefs) {
			chef.stopTakingNewOrders();
			synchronized (chef) {
				chef.notifyAll();

			}
		}
		//chefThreadPool.shutdownNow();

		try {
			_chefsCountDownLatch.await();
		} catch (InterruptedException e1) {
			// TODO Auto-generated catch block
			e1.printStackTrace();
		}

		//Poison delivery guys
		//Poison Orders
		for (RunnableDeliveryPerson deliveryGuy : _deliveryGuys) {
			_awaitingOrdersToDeliver.add(new Order(-1, null, null));
		}

		//deliveryGuysThreadPool.shutdownNow();
		
		try {
			_deliveryGuysCountDownLatch.await();
		} catch (InterruptedException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		LOGGER.info(String.format("[Statistics]\n%s", _stats.toString()));
	}


	public Warehouse getWarehouse() {
		return _warehouse;
	}

	public Address getAddress() {
		return resturant.getAddress();
	}

	
}
