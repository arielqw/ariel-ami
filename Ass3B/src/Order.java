import java.util.List;


public class Order
{
	public Order(int id, DeliveryAddress address, List<OrderOfDish> ordersOfDish) {
		_id = id;
		_address = address;
		_ordersOfDish = ordersOfDish;
	}
	
	private int _id;
	private DeliveryAddress _address;
	List<OrderOfDish> _ordersOfDish;
	
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
}
