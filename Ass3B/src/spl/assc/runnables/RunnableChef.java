package spl.assc.runnables;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Queue;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;
import java.util.concurrent.atomic.AtomicBoolean;
import java.util.logging.Logger;

import spl.assc.Management;
import spl.assc.model.Order;
import spl.assc.model.Order.OrderStatus;
import spl.assc.model.Warehouse;

/**
 * Runnable class which represents a restaurant's chef.
 * Handling cooking given orders
 */
public class RunnableChef implements Runnable
{
	private final static Logger LOGGER = Logger.getGlobal();

	private final String _name;
	private final double _efficiencyRating;
	private final int _enduranceRating;
	private int _currentPressure; 

	private boolean _stopTakingNewOrders;

	private final Management _managment;
	private final Warehouse _warehouse;

	private final AtomicBoolean _bell;

	private Queue<Order> _myPendingOrders;
	private List<Future<Order>> _futures;
	private ExecutorService _cookWholeOrderPool;
	private CountDownLatch _latch;
	
	public RunnableChef(String name, double efficiencyRating, int enduranceRating, AtomicBoolean bell, Management managment, CountDownLatch latch, Warehouse warehouse) {
		_name = name;
		_efficiencyRating = efficiencyRating;
		_enduranceRating = enduranceRating;	
		_currentPressure = 0;
		_stopTakingNewOrders = false;
		_warehouse = warehouse;
		_futures = new ArrayList<>();
		_cookWholeOrderPool = Executors.newCachedThreadPool();
		_myPendingOrders = new LinkedList<>();
		_bell = bell;
		_managment = managment;
		_latch = latch;
	}

	@Override
	/**
	 * starting to work
	 */
	public void run()
	{
		try {
			work();
		} catch (Exception e) {
			// TODO: handle exception
			e.printStackTrace();
		}
	}
	
	/**
	 * 
	 */
	private void work()
	{
		/**
		 * As long as:
		 * 1. management didn't shut chef down
		 * 2. got new orders to process
		 * 3. got orders to deliver
		 * continue working and handeling the above
		 */
		while(!(_stopTakingNewOrders && _futures.isEmpty() && _myPendingOrders.isEmpty() )){
			
			//start working on available orders
			if(!_myPendingOrders.isEmpty()){
				handleNewOrder(_myPendingOrders.poll());
			}
			
			//send completed orders to delivery
			boolean wasPressureReduced = sendFinishedOrdersToDelivery();
			
			//if Pressure was reduced notify management 
			if(wasPressureReduced){
				_bell.compareAndSet(false, true);
				synchronized (_bell) {
					_bell.notifyAll(); // notify management that my pressure was reduced and i can take new orders now
				}
			}
			else{ //else - let's try later
				synchronized (this) {
					try {
						this.wait();
					} catch (InterruptedException e) {
						e.printStackTrace();
					}
				}
			}
			
		}// end while
		
		_latch.countDown(); 
		_cookWholeOrderPool.shutdown();
		
		LOGGER.info(String.format("\t[Event=Shutdown] [Chef=%s]", _name));
	}
	
	public void stopTakingNewOrders(){
		_stopTakingNewOrders = true;
	}
	
	/**
	 * Going through completed orders and sending them to delivery
	 * not blocking.
	 * @return true if pressure was reduced
	 */
	private boolean sendFinishedOrdersToDelivery(){
		int currentOrdersSize = _futures.size();
		for (Iterator<Future<Order>> it = _futures.iterator() ; it.hasNext() ;  ) {
			Future<Order> future = it.next();
			
			if (future.isDone()){ //ask so won't be blocked
				it.remove();
					Order tmp;
					try {
						tmp = future.get(); //will succeed because asked if isDone
						_currentPressure = tmp.decreasedPressure(_currentPressure);
						deliverOrder(tmp);
					} catch (InterruptedException | ExecutionException e) {
						e.printStackTrace();
					}
			}
		}
		return ( currentOrdersSize > _futures.size() ); 
	}
	
	/**
	 * start cooking the whole order
	 * @param order
	 */
	private void handleNewOrder(Order order) {
		LOGGER.info(String.format("\t[Event=Took Order] [Chef=%s] [Order=%s]", _name,order.info()));
		_futures.add( _cookWholeOrderPool.submit(new CallableCookWholeOrder(this,order,_warehouse)) );
	}
	
	/**
	 * Sending order to delivery
	 * @param order
	 */
	private void deliverOrder(Order order)
	{
		LOGGER.info(String.format("\t[Event=Sent to Delivery] [Chef=%s] [Order=%s]", _name,order.info()));
		_managment.sendToDelivery(order);
		
	}
	

	@Override
	public String toString()
	{
		return String.format("%s:|efficiency:%.2f|endurance:%d", _name,_efficiencyRating,_enduranceRating);
	}


	/**
	 * if chef can handle this order - will start working on immediately it and returns true
	 * @param order
	 * @return true if chef can take order
	 */
	public boolean canYouTakeThisOrder(Order order) {
		if( order.canItakeThisOrder(_enduranceRating,_currentPressure) ){
			//take order
			order.set_status(OrderStatus.INPROGRESS);
			
			//reduce pressure and add to queue
			_currentPressure = order.increasedPressure(_currentPressure);
			_myPendingOrders.add(order);
			//wake up chef if sleeping
			synchronized (this) {
				this.notifyAll();
			}
			return true;
		}
		else{
			return false;
		}
	}

	public String info() {
		return _name;
	}
	public double get_efficiencyRating() {
		return _efficiencyRating;
	}
}
