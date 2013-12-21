package spl.assc.runnables;

import java.util.ArrayList;
import java.util.List;
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

	public RunnableChef(String name, double efficiencyRating, int enduranceRating) {
		_name = name;
		_efficiencyRating = efficiencyRating;
		_enduranceRating = enduranceRating;	
		_currentPressure = 0;
		_futures = new ArrayList<>();
		_cookWholeOrderPool = Executors.newCachedThreadPool();
	}

	private String _name;
	private double _efficiencyRating;
	private int _enduranceRating;
	private List<Future<Order>> _futures;
	private Management _managment;
	private int _currentPressure; 
	private ExecutorService _cookWholeOrderPool;
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
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	
		// TODO Auto-generated method stub
		while(!Thread.interrupted()){
				//1. send finished orders to delivery
				
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
					// TODO Auto-generated catch block
					e.printStackTrace();
				}

		}
		
	}
	
	private void handleNewOrder(Order order) {
		LOGGER.info("took order");
		_enduranceRating -= order.get_difficulty();
		//_futures.add( _cookWholeOrderPool.submit(new CallableCookWholeOrder(this,)) );
		
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
