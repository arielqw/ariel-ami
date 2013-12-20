package spl.assc.model;

public class DeliveryAddress
{
	public DeliveryAddress(int x, int y) {
		_x = x;
		_y = y;
	}
	
	private int _x;
	private int _y;
	
	@Override
	public String toString()
	{
		return String.format("(%d,%d)",_x,_y );
	}
}
