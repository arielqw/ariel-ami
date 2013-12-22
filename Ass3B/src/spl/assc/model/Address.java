package spl.assc.model;

public class Address
{
	public Address(int x, int y) {
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

	public int getX() {
		return _x;
	}
	public int getY() {
		return _y;
	}
}
