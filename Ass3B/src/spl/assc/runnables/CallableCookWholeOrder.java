package spl.assc.runnables;
import java.util.Random;
import java.util.concurrent.Callable;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.logging.Logger;

import spl.assc.Management;
import spl.assc.model.Order;
import spl.assc.model.Order.OrderStatus;
import spl.assc.model.OrderOfDish;
import spl.assc.model.Warehouse;


public class CallableCookWholeOrder implements Callable<Order>
{
	private final static Logger LOGGER = Logger.getGlobal();
	private RunnableChef _myChef;
	private Order _myOrder;
	private int _numOfThreads;
	private Warehouse _wareHouse;
	
	public CallableCookWholeOrder(RunnableChef runnableChef, Order order,Warehouse warhouse) {
		_myOrder = order;
		_myChef = runnableChef;
		_numOfThreads =0;
		_wareHouse = warhouse;
		
	}

	private CountDownLatch createCountDownLatch(){
		for (OrderOfDish orderOfDish : _myOrder.get_ordersOfDish()) {
			_numOfThreads += orderOfDish.getQuantity();
		}
		return new CountDownLatch(_numOfThreads);
	}

	
	@Override
	public Order call() throws Exception
	{
		LOGGER.info(String.format("\t[Event=Cooking Started] [Order=%s]", _myOrder.info()));

		CountDownLatch _countDownLatch = createCountDownLatch();

		_myOrder.setCookStartTime();

		for (OrderOfDish orderOfDish : _myOrder.get_ordersOfDish()) {
			for (int i = 0; i < orderOfDish.getQuantity(); i++) {
				new Thread(new RunnableCookOneDish(orderOfDish.get_dish(), _wareHouse, _myChef,_countDownLatch)).start();
			}
		}
		_countDownLatch.await();
		_myOrder.setCookEndTime();

		_myOrder.set_status(OrderStatus.COMPLETE);
		
		synchronized (_myChef) {
			LOGGER.info(String.format("\t[Event=Cooking Ended] [Order=%s]", _myOrder.info()));
			_myChef.notifyAll();
			return _myOrder;
		}
	}

	

}
