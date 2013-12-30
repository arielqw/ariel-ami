package spl.assc;

import java.util.List;
import java.util.Queue;
import java.util.concurrent.BlockingQueue;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.LinkedBlockingQueue;
import java.util.concurrent.atomic.AtomicBoolean;
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
	
	private Statistics _stats;
	private Address _address;


	private Management() {
		_chefs = Management.resturant.get_chefs();
		_deliveryGuys = Management.resturant.get_deliveryGuys();
		_warehouse = Management.resturant.get_warehouse();
		_address = Management.resturant.getAddress();
		
		_orders = orderQueue.get_orders();

		_awaitingOrdersToDeliver = new LinkedBlockingQueue<>();
		_stats = new Statistics();
		bell = new AtomicBoolean();
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
		

		for (RunnableChef chef : _chefs) {
			new Thread(chef).start();
		}
		
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
	private AtomicBoolean bell;
	private BlockingQueue<Order> _awaitingOrdersToDeliver;
		
	
	public void start() throws Exception
	{
		while(!_orders.isEmpty()){
			
				boolean isOrderTaken = false;
				bell.compareAndSet(true, false);
				for (RunnableChef chef : _chefs) {
					if( chef.canYouTakeThisOrder( _orders.peek()) ){
						LOGGER.info(String.format("[Managment] Order: [#%s] was sent to %s", _orders.peek().info(),chef.info() ));
						isOrderTaken = true;
						_orders.poll();
						break;
					}
				}
					if(!isOrderTaken && !bell.get()){
						synchronized (bell) {
							bell.wait();
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

		try {
			_chefsCountDownLatch.await();
		} catch (InterruptedException e1) {
			e1.printStackTrace();
		}

		//Poison delivery guys
		for (int i=0; i < _deliveryGuys.size(); i++) {
			_awaitingOrdersToDeliver.add(new Order(-1, null, null));
		}
		
		try {
			_deliveryGuysCountDownLatch.await();
		} catch (InterruptedException e) {
			e.printStackTrace();
		}
		LOGGER.info(String.format("[Statistics]\n%s", _stats.toString()));
	}


	public Warehouse linkToWareHouse() {
		return _warehouse;
	}

	public void sendToDelivery(Order order) {
		_awaitingOrdersToDeliver.add(order);
	}

	public Order takeNextOrder() throws InterruptedException {
		return _awaitingOrdersToDeliver.take();		
	}

	public long computeDistance(Order order) {
		return order.computeDistanceFrom(_address);
	}

	public void addToStatistics(double reward) {
		_stats.add(reward);
	}

	public void addToStatistics(Order order) {
		_stats.add(order);		
	}

	
}
