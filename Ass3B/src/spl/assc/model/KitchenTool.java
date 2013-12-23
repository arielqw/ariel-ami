package spl.assc.model;

import java.util.concurrent.Semaphore;

public class KitchenTool extends WarehouseItem
{
	private Semaphore _lock;
	
	public KitchenTool(String name, int quantity) {
		super(name, quantity);
		_lock = new Semaphore(quantity);
	}
	
	@Override
	public void take(int quantity){
		try {
			_lock.acquire(quantity);
		} catch (InterruptedException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
	
	public void putBack(int quantity){
		_lock.release(quantity);
	}


	
}
