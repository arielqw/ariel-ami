package spl.assc.model;

import java.util.concurrent.Semaphore;

public class KitchenTool extends WarehouseItem
{
	private Semaphore _lock;
	
	public KitchenTool(String name, int quantity) {
		super(name, quantity);
		_lock = new Semaphore(quantity);
	}
	
	
	public void take(KitchenTool kitchenTool){

		try {
			_lock.acquire(kitchenTool._initialQuantity);
		} catch (InterruptedException e) {
			e.printStackTrace();
		}

	}
	
	public void putBack(KitchenTool kitchenTool){
		_lock.release(kitchenTool._initialQuantity);
	}
	
	public String getQuantities()
	{
		return String.format("%s:[%d/%d]", _name, _lock.availablePermits(), _initialQuantity);
	}


	
}
