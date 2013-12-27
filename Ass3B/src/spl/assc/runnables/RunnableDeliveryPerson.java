package spl.assc.runnables;

import java.util.concurrent.BlockingQueue;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.LinkedBlockingQueue;
import java.util.logging.Logger;

import spl.assc.Management;
import spl.assc.Statistics;
import spl.assc.model.Address;
import spl.assc.model.Order;
import spl.assc.model.Order.OrderStatus;

public class RunnableDeliveryPerson implements Runnable
{
	private final static Logger LOGGER = Logger.getGlobal();

	public RunnableDeliveryPerson(String name, int speed) {
		_name = name;
		_speed = speed;
	}

	
	private String _name;
	private int _speed;
	private Address _resturantAddress;
	private Statistics _statistics;
	private CountDownLatch _latch;
	
	public void setCountDownLatch(CountDownLatch countDownLatch) {
		_latch = countDownLatch;
	}
	
	@Override
	public void run()
	{
		Management management = Management.getInstance();
		_statistics = management.get_stats();
		
		BlockingQueue<Order> awaitingOrders = management.get_awaitingOrdersToDeliver();
		_resturantAddress = management.getAddress();
		
		//boolean wasInterruptSent = false;
		
		while(true){
			Order orderToDeliver=null;

			try {
				orderToDeliver = awaitingOrders.take();
				if(orderToDeliver.getOrderId() == -1){
					break;
					
				}

			} catch (InterruptedException e) {
				//wasInterruptSent = true;
			}

			if(orderToDeliver == null){
				//if (Thread.interrupted())	wasInterruptSent = true;
				continue;
			}
			
			LOGGER.info(String.format("[Delivery] DeliveryPerson %s took order: [#%d]", _name, orderToDeliver.getOrderId()));

			
			long distance = calculateDistance(orderToDeliver.getAddress());
			long expectedDeliveryTime = (long)(distance/_speed);
			//1. set delivery start time
			
			orderToDeliver.set_deliveryStartTime();
			//2. deliver order (Sleep)
			drive(expectedDeliveryTime);
			//3. set deliver end time
			orderToDeliver.set_deliveryEndTime();

			//4. recive money
			_statistics.add( calculateReward(orderToDeliver,expectedDeliveryTime) );
			_statistics.add( orderToDeliver );
			
			//5. mark as delivered
			orderToDeliver.set_status(OrderStatus.DELIVERED);
			orderToDeliver.setDeliveredBy(_name);
			//6. go home (Sleep)
			drive(expectedDeliveryTime);
			//if (Thread.interrupted())	wasInterruptSent = true;
		}
		_latch.countDown();
		LOGGER.info(String.format("[-Terminated-] DeliveryPerson %s ended.", _name));

	}

	private double calculateReward(Order order, long expectedDeliveryTime) {
		long actualTotalTime = order.getTotalTime();
		long expectedTotalTime = order.getExpectedCookTime() + expectedDeliveryTime;

		boolean isFined = (actualTotalTime >= 1.15 * expectedTotalTime);
		double dishReward = order.getReward();
		
		LOGGER.info(String.format("[Stats] Order: %d is Fined: %b.\nActual time:%d\nExpected time:%d", order.getOrderId(),isFined,actualTotalTime,expectedTotalTime));
		//LOGGER.info(String.format("[More] expected delivery time:%d,actualy delivery time:%d", expectedDeliveryTime));
		if(isFined){
			return dishReward*0.5;
		}
		else{
			return dishReward;
		}
	}

	private void drive(long deliveryTime){
		
		try {
			Thread.sleep( deliveryTime );
		} catch (InterruptedException e) {
			Thread.currentThread().interrupt();
		}
	}
	private long calculateDistance(Address address) {
		return (long)Math.sqrt( 
			Math.abs( 
						Math.pow(address.getY() - _resturantAddress.getY(), 2)	+ 
						Math.pow(address.getX() - _resturantAddress.getX(), 2)  
			) 
		);
	}
//TODO: wrap for throws

	@Override
	public String toString()
	{
		return String.format("%s:|speed:%d", _name,_speed);
	}
}
