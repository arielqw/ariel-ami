package spl.assc.runnables;

public class RunnableDeliveryPerson implements Runnable
{

	public RunnableDeliveryPerson(String name, int speed) {
		_name = name;
		_speed = speed;
	}

	
	private String _name;
	private int _speed;
	
	@Override
	public void run()
	{
		// TODO Auto-generated method stub

	}

	
	@Override
	public String toString()
	{
		return String.format("%s:|speed:%d", _name,_speed);
	}
}
