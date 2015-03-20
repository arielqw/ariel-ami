package spl.assc.runnables;
import java.util.concurrent.Callable;
import java.util.concurrent.CountDownLatch;
import java.util.logging.Logger;

import spl.assc.model.Order;
import spl.assc.model.Order.OrderStatus;
import spl.assc.model.OrderOfDish;
import spl.assc.model.Warehouse;

/**
 * This class handles cooking all the dishes of an order in parallel 
 */
public class CallableCookWholeOrder implements Callable<Order>
{
	private final static Logger LOGGER = Logger.getGlobal();
	private final RunnableChef _myChef;
	private final Order _myOrder;
	private int _numOfThreads;
	private final Warehouse _wareHouse;
	
	public CallableCookWholeOrder(RunnableChef runnableChef, Order order,Warehouse warhouse) {
		_myOrder = order;
		_myChef = runnableChef;
		_numOfThreads =0;
		_wareHouse = warhouse;
	}

	/**
	 * calculating how much cookOneDish should run
	 * @return a latch with ^ size
	 */
	private CountDownLatch createCountDownLatch(){
		for (OrderOfDish orderOfDish : _myOrder.get_ordersOfDish()) {
			_numOfThreads += orderOfDish.getQuantity();
		}
		return new CountDownLatch(_numOfThreads);
	}

	
	@Override
	/**
	 * cooking all the order's dishes in parallel 
	 */
	public Order call() throws Exception
	{
		LOGGER.info(String.format("\t[Event=Cooking Started] [Order=%s]", _myOrder.info()));

		CountDownLatch _countDownLatch = createCountDownLatch();

		_myOrder.setCookStartTime();
		
		//for each dish : for each unit of the dish:
		//creating a cookOneDish runnable and starting it
		for (OrderOfDish orderOfDish : _myOrder.get_ordersOfDish()) {
			for (int i = 0; i < orderOfDish.getQuantity(); i++) {
				new Thread(new RunnableCookOneDish(orderOfDish.get_dish(), _wareHouse, _myChef,_countDownLatch)).start();
			}
		}
		//waiting for all runnable cookOneDish will finish
		_countDownLatch.await();
		
		_myOrder.setCookEndTime();

		_myOrder.set_status(OrderStatus.COMPLETE);
		
		//Notifying the chef that the cook process of the order was completed
		synchronized (_myChef) {
			LOGGER.info(String.format("\t[Event=Cooking Ended] [Order=%s]", _myOrder.info()));
			_myChef.notifyAll();
			return _myOrder;
		}
	}

	

}
