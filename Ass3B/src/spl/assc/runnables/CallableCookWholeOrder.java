package spl.assc.runnables;
import java.util.concurrent.Callable;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.logging.Logger;

import spl.assc.Management;
import spl.assc.model.Order;
import spl.assc.model.Order.OrderStatus;
import spl.assc.model.OrderOfDish;


public class CallableCookWholeOrder implements Callable<Order>
{
	private final static Logger LOGGER = Logger.getGlobal();
	private RunnableChef _myChef;
	private Order _myOrder;
	private int _numOfThreads;
	
	public CallableCookWholeOrder(RunnableChef runnableChef, Order order) {
		_myOrder = order;
		_myChef = runnableChef;
		_numOfThreads =0;
		
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
		//starting time
		_myOrder.setCookStartTime();
		CountDownLatch _countDownLatch = createCountDownLatch();
		ExecutorService _runnableCookOneDishPool = Executors.newFixedThreadPool(_numOfThreads);
		
		for (OrderOfDish orderOfDish : _myOrder.get_ordersOfDish()) {
			for (int i = 0; i < orderOfDish.getQuantity(); i++) {
				_runnableCookOneDishPool.execute(new RunnableCookOneDish(orderOfDish.get_dish(), Management.getInstance().getWarehouse(), _myChef,_countDownLatch));
			}
		}
		_countDownLatch.await();
		_runnableCookOneDishPool.shutdown();
		_myOrder.set_status(OrderStatus.COMPLETE);
		_myOrder.setCookEndTime();

		synchronized (_myChef) {
			_myChef.notify();
			return _myOrder;
		}
	}

	

}
