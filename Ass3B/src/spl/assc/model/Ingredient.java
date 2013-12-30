package spl.assc.model;

/**
 * This object represent an ingredient
 */
public class Ingredient extends WarehouseItem
{
	private int _currentQuantity;
	
	public Ingredient(String name, int quantity) {
		super(name, quantity);
		_currentQuantity = quantity;
	}
	
	/**
	 * Simulates taking some units from this ingredient
	 * @param ingredient a needed ingredient item
	 */
	public synchronized void take(Ingredient ingredient){
		_currentQuantity -= ingredient._initialQuantity;
	}
	
	/**
	 * @return how many units were used
	 */
	public int getConsumedAmount(){
		return _initialQuantity-_currentQuantity;
	}
}
