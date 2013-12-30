package spl.assc.model;
import java.util.GregorianCalendar;
import java.util.List;


public class Order
{
	public void set_deliveryStartTime() {
//		this._deliveryStartTime = System.currentTimeMillis();
		this._deliveryStartTime = new GregorianCalendar().getTimeInMillis();
		
	}


	public void set_deliveryEndTime() {
		//this._deliveryEndTime = System.currentTimeMillis();
		this._deliveryEndTime = new GregorianCalendar().getTimeInMillis();
	}


	public Order(int id, Address address, List<OrderOfDish> ordersOfDish) {
		_id = id;
		_address = address;
		_ordersOfDish = ordersOfDish;
		_difficulty = 0;
		_deliveredBy = "N/A";
		_status = OrderStatus.INCOMPLETE;
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
	
	public List<OrderOfDish> get_ordersOfDish() {
		return _ordersOfDish;
	}


	public int get_difficulty() {
		return _difficulty;
	}


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
	
	public int getOrderId(){
		return _id;
	}
	
	@Override
	public String toString()
	{
		StringBuilder builder = new StringBuilder();
		builder.append(String.format("\tOrder:\t{\tId: %d,\tDeliveryAddress: %s\t Delivered By: '%s'\t} ", _id, _address,_deliveredBy));
		builder.append("\t\tRequested Dishes:\t");
		builder.append(_ordersOfDish);
		builder.append("\n\t===================================================================================================================================================================\n");

		return builder.toString();
	}


	public void setDifficulty(int tmpDifficulty) {
		// TODO Auto-generated method stub
		_difficulty = tmpDifficulty;
	}


	public void setCookStartTime() {
		//_cookStartTime = System.currentTimeMillis();
		_cookStartTime = new GregorianCalendar().getTimeInMillis();
	}


	public void setCookEndTime() {
		//_cookEndTime = System.currentTimeMillis();
		_cookEndTime = new GregorianCalendar().getTimeInMillis();
		
	}


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
			long tmpExpectedTime = orderOfDish.get_dish().get_expectedCookTime();
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


	public boolean isPoisoned() {
		return (_id == -1);
	}


	public boolean canItakeThisOrder(int _enduranceRating, int _currentPressure) {
		return ( _difficulty <= (_enduranceRating - _currentPressure) );
	}

	public int decreasedPressure(int currentPressure) {
		return currentPressure - _difficulty;
	}
	public int increasedPressure(int currentPressure) {
		return currentPressure + _difficulty;
	}
}
