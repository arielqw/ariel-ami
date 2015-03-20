package spl.assc.model;

public abstract class WarehouseItem
{
	public WarehouseItem(String name, int quantity) {
		_name = name;
		_initialQuantity = quantity;
	}
	
	protected final String _name;
	protected final int _initialQuantity;
	
	public String getName() {
		return _name;
	}	
		
	@Override
	public String toString()
	{
		return String.format("%s:%d", _name, _initialQuantity);
	}
}
