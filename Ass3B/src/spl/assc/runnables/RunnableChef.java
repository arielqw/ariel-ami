package spl.assc.runnables;

public class RunnableChef implements Runnable
{
	
	public RunnableChef(String name, double efficiencyRating, int enduranceRating) {
		_name = name;
		_efficiencyRating = efficiencyRating;
		_enduranceRating = enduranceRating;	
	}

	private String _name;
	private double _efficiencyRating;
	private int _enduranceRating;


	@Override
	public void run()
	{
		// TODO Auto-generated method stub

	}
	
	@Override
	public String toString()
	{
		return String.format("%s:|efficiency:%.2f|endurance:%d", _name,_efficiencyRating,_enduranceRating);
	}

}
