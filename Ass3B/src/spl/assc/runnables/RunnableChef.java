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
	private AtomicBoolean _bell;
	private Queue<Order> _myPendingOrders;

	public RunnableChef(String name, double efficiencyRating, int enduranceRating, AtomicBoolean bell, Management managment, CountDownLatch latch) {
		_name = name;
		_efficiencyRating = efficiencyRating;
		_enduranceRating = enduranceRating;	
		_currentPressure = 0;
		_stopTakingNewOrders = false;
		_futures = new ArrayList<>();
		_cookWholeOrderPool = Executors.newCachedThreadPool();
		_myPendingOrders = new LinkedList<>();
		_bell = bell;
		_managment = managment;
		_latch = latch;
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

		//_managment = Management.getInstance();

		while(!(_stopTakingNewOrders && _futures.isEmpty() && _myPendingOrders.isEmpty() )){
			//start working on available orders
			if(!_myPendingOrders.isEmpty()){
				handleNewOrder(_myPendingOrders.poll());
			}
			//send completed orders to delivery
			boolean wasPressureReduced = sendFinishedOrdersToDelivery();
			if(wasPressureReduced){
				_bell.compareAndSet(false, true);
				synchronized (_bell) {
					_bell.notifyAll(); // notify management that my pressure was reduced and i can take new orders now
				}
			}
			else{ //try later
				synchronized (this) {
					try {
						this.wait();
					} catch (InterruptedException e) {
						e.printStackTrace();
					}
				}
			}
			
		}
		_latch.countDown();
		_cookWholeOrderPool.shutdown();
		LOGGER.info(String.format("\t[Event=Shutdown] [Chef=%s]", _name));
	}
	
	public void stopTakingNewOrders(){
		_stopTakingNewOrders = true;
	}
	
	private boolean sendFinishedOrdersToDelivery(){
		int currentOrdersSize = _futures.size();
		for (Iterator<Future<Order>> it = _futures.iterator() ; it.hasNext() ;  ) {
			Future<Order> future = it.next();
			if (future.isDone()){
				it.remove();
					Order tmp;
					try {
						tmp = future.get();
						_currentPressure = tmp.decreasedPressure(_currentPressure);
						deliverOrder(tmp);
					} catch (InterruptedException | ExecutionException e) {
						e.printStackTrace();
					}
			}
		}
		return ( currentOrdersSize > _futures.size() );
	}
	
	private void handleNewOrder(Order order) {
		LOGGER.info(String.format("\t[Event=Took Order] [Chef=%s] [Order=%s]", _name,order.info()));
		_futures.add( _cookWholeOrderPool.submit(new CallableCookWholeOrder(this,order,_managment.linkToWareHouse())) );
	}
	
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


	public boolean canYouTakeThisOrder(Order order) {
		if( order.canItakeThisOrder(_enduranceRating,_currentPressure) ){
			//take order
			order.set_status(OrderStatus.INPROGRESS);
			//_enduranceRating -= order.get_difficulty();
			_currentPressure = order.increasedPressure(_currentPressure);
			_myPendingOrders.add(order);
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

}
