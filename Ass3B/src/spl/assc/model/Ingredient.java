package spl.assc.model;

public class Ingredient extends WarehouseItem
{
	private int _currentQuantity;
	
	public Ingredient(String name, int quantity) {
		super(name, quantity);
		_currentQuantity = quantity;
	}
	
	
	public synchronized void take(int quantity){
		_currentQuantity -= quantity;
	}
	
	public int getConsumedAmount(){
		return _initialQuantity-_currentQuantity;
	}
}
