package spl.assc.runnables;

import java.util.concurrent.BlockingQueue;
import java.util.concurrent.LinkedBlockingQueue;

import spl.assc.Management;
import spl.assc.model.Address;
import spl.assc.model.Order;
import spl.assc.model.Order.OrderStatus;

public class RunnableDeliveryPerson implements Runnable
{

	public RunnableDeliveryPerson(String name, int speed) {
		_name = name;
		_speed = speed;
	}

	
	private String _name;
	private int _speed;
	private Address _resturantAddress;
	@Override
	public void run()
	{
		Management management = Management.getInstance();
		BlockingQueue<Order> awaitingOrders = management.get_awaitingOrdersToDeliver();
		_resturantAddress = management.getAddress();
		
		while(!Thread.interrupted()){
			Order orderToDeliver=null;
			try {
				orderToDeliver = awaitingOrders.take();
			} catch (InterruptedException e) {
				Thread.currentThread().interrupt();
			}
			if(orderToDeliver == null) continue;
			long distance = calculateDistance(orderToDeliver.getAddress());
			
			//1. set delivery start time
			orderToDeliver.set_deliveryStartTime();
			//2. deliver order (Sleep)
			drive(distance);
			//3. set deliver end time
			orderToDeliver.set_deliveryEndTime();
			//4. recive money
			/**
			 * TODO: calc revenue -> update statistics
			 */
			//5. mark as delivered
			orderToDeliver.set_status(OrderStatus.DELIVERED);
			//6. go home (Sleep)
			drive(distance);
			
		}
	}

	private void drive(long distance){
		try {
			Thread.sleep( (long)(distance/_speed) );
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


	@Override
	public String toString()
	{
		return String.format("%s:|speed:%d", _name,_speed);
	}
}
