package spl.assc.model;

import java.util.concurrent.Semaphore;

/**
 * This class represents a kitchen tool
 */
public class KitchenTool extends WarehouseItem
{
	private Semaphore _lock; //for simulating restrictions on available amount
	
	public KitchenTool(String name, int quantity) {
		super(name, quantity);
		_lock = new Semaphore(quantity);
	}
	
	/**
	 * If there is not enough kitchen tools as requested, will be blocked until available 
	 * @param kitchenTool needed kitchen tools
	 */
	public void take(KitchenTool kitchenTool){
		try {
			_lock.acquire(kitchenTool._initialQuantity);
		} catch (InterruptedException e) {
			e.printStackTrace();
		}

	}
	
	/**
	 * returning used kitchen tools to warehouse
	 * @param kitchenTool
	 */
	public void putBack(KitchenTool kitchenTool){
		_lock.release(kitchenTool._initialQuantity);
	}

	
}
