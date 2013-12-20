package spl.assc.model;
import java.util.List;


public class Menu
{
	public Menu(List<Dish> dishes) {
		this._dishes = dishes;
		
	}
	
	
	private List<Dish> _dishes;
	
	
	@Override
	public String toString()
	{
		StringBuilder builder = new StringBuilder();
		builder.append("*******************\n***\tMenu:\t***\n*******************\n");
		
		for (int i = 0; i < _dishes.size(); i++)
		{
			builder.append(i+1);
			builder.append(":");
			builder.append(_dishes.get(i).toString());
		}
		
		return builder.toString();
	}
	
}
