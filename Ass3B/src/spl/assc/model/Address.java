package spl.assc.model;

/**
 * This object represents an address (in x,y coords) 
 * This object is Immutable
 */
public final class Address
{
	private final int _x;
	private final int _y;

	public Address(int x, int y) {
		_x = x;
		_y = y;
	}
	
	@Override
	public String toString()
	{
		return String.format("(%d,%d)",_x,_y );
	}

	/**
	 * calculating a euclidean distance between this address and other address
	 * @param other
	 * @return distance
	 */
	public final long computeDistanceTo(Address other){
		return (long)Math.sqrt( Math.abs( Math.pow(this._y - other._y, 2) + Math.pow(this._x - other._x, 2) ));
	}
	
}
