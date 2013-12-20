package spl.assc.model;

public abstract class WarehouseItem
{
	public WarehouseItem(String name, int quantity) {
		_name = name;
		_quantity = quantity;
	}
	
	private String _name;
	private int _quantity;
	
	
	@Override
	public String toString()
	{
		return String.format("%s:%d", _name, _quantity);
	}
}
