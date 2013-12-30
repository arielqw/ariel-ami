package spl.assc.runnables;

import java.util.concurrent.CountDownLatch;
import java.util.logging.Logger;

import spl.assc.Management;
import spl.assc.model.Order;
import spl.assc.model.Order.OrderStatus;

/**
 * This class represents a restaurant's delivery person
 * In order to shutdown needs to receive a poisoned order.
 */
public class RunnableDeliveryPerson implements Runnable
{
	private final static Logger LOGGER = Logger.getGlobal();

	private String _name;
	private int _speed;
	private CountDownLatch _latch;
	private Management _management;
	
	public RunnableDeliveryPerson(String name, int speed, Management management, CountDownLatch latch) {
		_name = name;
		_speed = speed;
		_latch = latch;
		_management = management;
	}

	
	@Override
	public void run(){
		try {
			work();
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
	
	/**
	 * Constinley checking for new orders needed delivered and deliver them 
	 */
	private void work()
	{
		while(true){
			
			//trying to take an order (blocked untill succeed)
			Order orderToDeliver = null;
			try {
				orderToDeliver = _management.takeNextOrder();
				if(orderToDeliver.isPoisoned()){
					break;
				}

			} catch (InterruptedException e) {
				e.printStackTrace();
			}
			
			if(orderToDeliver == null) continue;
			
			LOGGER.info(String.format("\t[Event=Order Taken] [DeliveryPerson=%s] [Order=%s]", _name, orderToDeliver.info()));

			
			long distance = _management.computeDistance(orderToDeliver);
			long expectedDeliveryTime = (long)(distance/_speed);
		
			//1. set delivery start time
			orderToDeliver.setDeliveryStartTime();
			//2. deliver order (Sleep)
			drive(expectedDeliveryTime);
			//3. set deliver end time
			orderToDeliver.setDeliveryEndTime();

			//4. recive money
			_management.addToStatistics( calculateReward(orderToDeliver,expectedDeliveryTime) );
			_management.addToStatistics( orderToDeliver );
			
			//5. mark as delivered
			orderToDeliver.set_status(OrderStatus.DELIVERED);
			orderToDeliver.setDeliveredBy(_name);
			//6. go home (Sleep)
			drive(expectedDeliveryTime);
			//if (Thread.interrupted())	wasInterruptSent = true;
		}
		_latch.countDown();
		LOGGER.info(String.format("\t[Event=Shutdown] [DeliveryPerson=%s]", _name));

	}

	/**
	 * calculating order's reward money
	 * @param order
	 * @param expectedDeliveryTime
	 * @return money
	 */
	private double calculateReward(Order order, long expectedDeliveryTime) {
		long actualTotalTime = order.getTotalTime();
		long expectedTotalTime = order.getExpectedCookTime() + expectedDeliveryTime;

		//checking if order was fined
		boolean isFined = (actualTotalTime > 1.15 * expectedTotalTime);
		double dishReward = order.getReward();
		
		LOGGER.info(String.format("\t[Stats] [Order=%s] [Fined=%b] [Actual time=%d] [Expected time=%d]", order.info(),isFined,actualTotalTime,expectedTotalTime));

		if(isFined){
			order.wasFined(false);
			return dishReward*0.5;
		}
		else{
			order.wasFined(true);
			return dishReward;
		}
	}

	/**
	 * simulates driving between locations
	 * @param deliveryTime
	 */
	private void drive(long deliveryTime){
		
		try {
			Thread.sleep( deliveryTime );
		} catch (InterruptedException e) {
			Thread.currentThread().interrupt();
		}
	}

	@Override
	public String toString()
	{
		return String.format("%s:|speed:%d", _name,_speed);
	}
}
