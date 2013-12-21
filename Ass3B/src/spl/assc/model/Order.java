package spl.assc.model;
import java.util.List;


public class Order
{
	public Order(int id, DeliveryAddress address, List<OrderOfDish> ordersOfDish) {
		_id = id;
		_address = address;
		_ordersOfDish = ordersOfDish;
		_difficulty = 0;

		_status = OrderStatus.INCOMPLETE;
	}
	
	private int _id;
	private DeliveryAddress _address;
	private int _difficulty;
	List<OrderOfDish> _ordersOfDish;
	private Order.OrderStatus _status;
	
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
	
	
	@Override
	public String toString()
	{
		StringBuilder builder = new StringBuilder();
		builder.append(String.format("\tOrder:\t{\tId: %d,\tDeliveryAddress: %s\t}\n", _id, _address));
		builder.append("\t\tRequested Dishes:\t");
		builder.append(_ordersOfDish);
		builder.append("\n\t====================================================================================================================\n");

		return builder.toString();
	}


	public void setDifficulty(int tmpDifficulty) {
		// TODO Auto-generated method stub
		_difficulty = tmpDifficulty;
	}


	public String getName() {
		// TODO Auto-generated method stub
		return _ordersOfDish.toString();
	}
}
