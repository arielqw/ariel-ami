package spl.assc.runnables;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;
import java.util.logging.Logger;

import spl.assc.Management;
import spl.assc.model.Order;
import spl.assc.model.Order.OrderStatus;

public class RunnableChef implements Runnable
{
	private final static Logger LOGGER = Logger.getGlobal();

	private String _name;
	private double _efficiencyRating;
	private int _enduranceRating;
	private List<Future<Order>> _futures;
	private Management _managment;
	private int _currentPressure; 
	private ExecutorService _cookWholeOrderPool;

	public RunnableChef(String name, double efficiencyRating, int enduranceRating) {
		_name = name;
		_efficiencyRating = efficiencyRating;
		_enduranceRating = enduranceRating;	
		_currentPressure = 0;
		_futures = new ArrayList<>();
		_cookWholeOrderPool = Executors.newCachedThreadPool();
		
	}

	@Override
	public void run()
	{
		//LOGGER.info(String.format("Chef '%s' started...", _name));
		
		try {
			synchronized (this) {
				this.wait();
			//	LOGGER.info(String.format("Chef '%s' woke up", _name));

			}
		} catch (InterruptedException e) {
			LOGGER.info("Chef "+_name+" got interrupted. shutting down");
			Thread.currentThread().interrupt();
		}
		
		_managment = Management.getInstance();

		// TODO Auto-generated method stub
		while(!(Thread.interrupted() && _futures.isEmpty())){
			//1. send finished orders to delivery
			for (Iterator<Future<Order>> it = _futures.iterator() ; it.hasNext() ;  ) {
				Future<Order> future = it.next();
				if (future.isDone())	it.remove();
				try {
					deliverOrder(future.get());
				} catch (InterruptedException | ExecutionException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
			}
		
		
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
						handleNewOrder(pendingOrder);
					}
					else
					{
						LOGGER.info("chef cant take order");
					}
				}
				
				
			}
			try {
				synchronized (this) {
					this.wait();
				}
			} catch (InterruptedException e) {
				LOGGER.info("Chef "+_name+" got interrupted. shutting down");
				Thread.currentThread().interrupt();
			}

		}
		
	}
	
	private void handleNewOrder(Order order) {
		LOGGER.info("took order");
		_enduranceRating -= order.get_difficulty();
		//_futures.add( _cookWholeOrderPool.submit(new CallableCookWholeOrder(this,)) );
		
	}
	
	private void deliverOrder(Order order)
	{
	}
	

	@Override
	public String toString()
	{
		return String.format("%s:|efficiency:%.2f|endurance:%d", _name,_efficiencyRating,_enduranceRating);
	}

	public void setManagment(Management management) {
		_managment = management;
	}

}
