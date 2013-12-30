package spl.assc.model;

/**
 * Represents a dish order (dish + it's amount)
 */
public class OrderOfDish
{
	public OrderOfDish(String name, int quantity) {
		_name = name;
		_quantity = quantity;
	}
	
	private String _name;
	private int _quantity;
	private Dish _dish;
	

	public Dish get_dish() {
		return _dish;
	}
	
	public void setDish(Dish dish){
		_dish = dish;
	}


	@Override
	public String toString()
	{
		return String.format("%s=%d", _name, _quantity);
	}

	public String getName() {
		return _name;
	}

	public int getQuantity() {
		return _quantity;
	}
}
