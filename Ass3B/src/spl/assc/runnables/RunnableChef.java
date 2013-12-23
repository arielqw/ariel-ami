package spl.assc.runnables;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.Random;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;
import java.util.logging.Logger;

import javax.swing.text.html.HTMLDocument.HTMLReader.IsindexAction;

import spl.assc.Management;
import spl.assc.model.Order;
import spl.assc.model.Order.OrderStatus;

public class RunnableChef implements Runnable
{
	private final static Logger LOGGER = Logger.getGlobal();

	private String _name;
	private double _efficiencyRating;
	public double get_efficiencyRating() {
		return _efficiencyRating;
	}

	private int _enduranceRating;
	private List<Future<Order>> _futures;
	private Management _managment;
	private int _currentPressure; 
	private ExecutorService _cookWholeOrderPool;
	private boolean _stopTakingNewOrders;
	private CountDownLatch _latch;
	public RunnableChef(String name, double efficiencyRating, int enduranceRating) {
		_name = name;
		_efficiencyRating = efficiencyRating;
		_enduranceRating = enduranceRating;	
		_currentPressure = 0;
		_stopTakingNewOrders = false;
		_futures = new ArrayList<>();
		_cookWholeOrderPool = Executors.newCachedThreadPool();
		
	}

	@Override
	public void run()
	{
		try {
			work();
		} catch (Exception e) {
			// TODO: handle exception
			e.printStackTrace();
		}
	}
	
	private void work()
	{
		//LOGGER.info(String.format("Chef '%s' started...", _name));

		try {
			synchronized (this) {
				this.wait();
			//	LOGGER.info(String.format("Chef '%s' woke up", _name));

			}
		} catch (InterruptedException e) {
			_stopTakingNewOrders = true;
		}
		
		_managment = Management.getInstance();

		while(!(_stopTakingNewOrders && _futures.isEmpty())){

			//2. check if I can cook the pending order
			synchronized (_managment.getPendingOrder()) {
				//LOGGER.info(String.format("Chef '%s' got in", _name));
				Order pendingOrder = _managment.getPendingOrder();
				if( pendingOrder.get_status() == OrderStatus.INCOMPLETE){
					//LOGGER.info(String.format("%d < %d - %d - ['%s']",pendingOrder.get_difficulty(), _enduranceRating, _currentPressure, _name));
					if(pendingOrder.get_difficulty() <= (_enduranceRating - _currentPressure)){
						//take order
						pendingOrder.set_status(OrderStatus.INPROGRESS);
						pendingOrder.notify();
						long start = System.currentTimeMillis();
						//LOGGER.info("before deliver");
					
						handleNewOrder(pendingOrder);
						//LOGGER.info("deliver took:" + (System.currentTimeMillis() - start));
					}
					else
					{
						//LOGGER.info(String.format("[Chef Action] Chef %s can't take order: [#%d]", _name,pendingOrder.getOrderId()));
					}
				}
				
				
			}

			//1. send finished orders to delivery
			synchronized (this) {
				boolean wasPreasureReduced = sendFinishedOrdersToDelivery();
				if(!wasPreasureReduced){
					try {
						this.wait();
					} catch (InterruptedException e) {
						//LOGGER.info(String.format("[ShutDown] Chef %s got interrupted. shutting down", _name));
						_stopTakingNewOrders = true;
					}
				}
				
			}
			if (Thread.interrupted()){
				_stopTakingNewOrders = true;
			}
		}
		_cookWholeOrderPool.shutdown();
		_latch.countDown();
		LOGGER.info(String.format("[ShutDown] Chef %s ended.", _name));

	}
		
	
	private boolean sendFinishedOrdersToDelivery(){
		int currentOrdersSize = _futures.size();
		for (Iterator<Future<Order>> it = _futures.iterator() ; it.hasNext() ;  ) {
			Future<Order> future = it.next();
			if (future.isDone()){
				it.remove();
				try {
					Order tmp = future.get();
					_currentPressure -= tmp.get_difficulty();
					deliverOrder(tmp);
				} catch (InterruptedException e)
				{
					_stopTakingNewOrders = true;
				} catch (ExecutionException e) {
					e.printStackTrace();
				}
			}
		}
		return ( currentOrdersSize > _futures.size() );
	}
	private void handleNewOrder(Order order) {
		LOGGER.info(String.format("[Chef Action] Chef %s took order: [%d]", _name,order.getOrderId()));
		_enduranceRating -= order.get_difficulty();
		

		_futures.add( _cookWholeOrderPool.submit(new CallableCookWholeOrder(this,order)) );
		
	}
	
	private void deliverOrder(Order order)
	{
		LOGGER.info(String.format("[Delivery] Chef %s Sending Order [#%d] to Delivery Queue", _name,order.getOrderId()));
		Management.getInstance().get_awaitingOrdersToDeliver().add(order);
		
	}
	

	@Override
	public String toString()
	{
		return String.format("%s:|efficiency:%.2f|endurance:%d", _name,_efficiencyRating,_enduranceRating);
	}

	public void setManagment(Management management) {
		_managment = management;
	}

	public void setCountDownLatch(CountDownLatch countDownLatch) {
		_latch = countDownLatch;
	}

}
