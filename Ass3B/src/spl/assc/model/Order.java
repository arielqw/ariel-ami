package spl.assc.model;
import java.util.GregorianCalendar;
import java.util.List;

/**
 * This class represents an order
 */
public class Order
{
	public Order(int id, Address address, List<OrderOfDish> ordersOfDish, int difficulty) {
		_id = id;
		_address = address;
		_ordersOfDish = ordersOfDish;
		_difficulty = difficulty;
		_deliveredBy = "N/A";
		_status = OrderStatus.INCOMPLETE;
		_rewarded = "N/A";
	}
	
	public Order(String string) {
		_id = -1;
	}

	private int _id;
	private Address _address;
	private int _difficulty;
	private List<OrderOfDish> _ordersOfDish;
	private Order.OrderStatus _status;
	private long _cookStartTime;
	private long _cookEndTime;
	private long _deliveryStartTime;
	private long _deliveryEndTime;
	private String _deliveredBy;
	private String _rewarded;
	
	public List<OrderOfDish> get_ordersOfDish() {
		return _ordersOfDish;
	}

	public void setDeliveryStartTime() {
		this._deliveryStartTime = new GregorianCalendar().getTimeInMillis();
	}

	public void setDeliveryEndTime() {
		this._deliveryEndTime = new GregorianCalendar().getTimeInMillis();
	}

	//not used anywhere.
	public Order.OrderStatus get_status() {
		return _status;
	}

	public void set_status(Order.OrderStatus _status) {
		this._status = _status;
	}


	public enum OrderStatus {
		INCOMPLETE,
		INPROGRESS,
		COMPLETE,
		DELIVERED
	}
	
	public String info(){
		return ""+_id;
	}
	

	public void setCookStartTime() {
		_cookStartTime = new GregorianCalendar().getTimeInMillis();
	}


	public void setCookEndTime() {
		_cookEndTime = new GregorianCalendar().getTimeInMillis();
	}

	/**
	 * @return total time (cook + deliver)
	 */
	public long getTotalTime() {
		return ( (_cookEndTime-_cookStartTime) + (_deliveryEndTime-_deliveryStartTime) );
	}
	

	public int getReward(){
		int reward = 0;
		for (OrderOfDish orderOfDish : _ordersOfDish) {
			reward+= orderOfDish.get_dish().getReward()*orderOfDish.getQuantity();
		}
		return reward;
	}

	public long getExpectedCookTime() {
		long maxCookTime = 0;
		for (OrderOfDish orderOfDish : _ordersOfDish) {
			long tmpExpectedTime = orderOfDish.get_dish().getExpectedCookTime();
			if( tmpExpectedTime > maxCookTime){
				maxCookTime = tmpExpectedTime;
			}
		}
		return (maxCookTime);
	}


	public void setDeliveredBy(String _name) {
		_deliveredBy = _name;
		
	}


	public long computeDistanceFrom(Address _resturantAddress) {
		return _resturantAddress.computeDistanceTo(_address);
	}

	/**
	 * @return true if order is poisoned
	 */
	public boolean isPoisoned() {
		return (_id == -1);
	}

	/**
	 * @param _enduranceRating chef's endurance
	 * @param _currentPressure chef's pressure
	 * @return true if chef can take this order
	 */
	public boolean canItakeThisOrder(int _enduranceRating, int _currentPressure) {
		return ( _difficulty <= (_enduranceRating - _currentPressure) );
	}

	public int decreasedPressure(int currentPressure) {
		return currentPressure - _difficulty;
	}
	public int increasedPressure(int currentPressure) {
		return currentPressure + _difficulty;
	}

	/**
	 * returns: 
	 * 100% if order was delivered in reasonable time
	 * 50% otherwise
	 * @param wasFined
	 */
	public void wasFined(boolean wasFined) {
		if(wasFined){
			_rewarded = "100%";
		}
		else{
			_rewarded = "50%";
		}
	}

	@Override
	public String toString()
	{
		StringBuilder builder = new StringBuilder();
		builder.append(String.format("\t\t[Order=%d] [Reward=%s] [DeliveryAddress=%s] [Delivery Guys=%s] ", _id,_rewarded, _address,_deliveredBy));
		builder.append("[Requested Dishes=");
		builder.append(_ordersOfDish);
		builder.append("]\n");

		return builder.toString();
	}
}
