package spl.assc.model;
import java.util.HashMap;
import java.util.List;
import java.util.Map;


public class Menu
{
	public Menu(Map<String,Dish> dishes) {
		this._dishes = dishes;
	}
	
	
	private Map<String,Dish> _dishes;
	
	
	@Override
	public String toString()
	{
		StringBuilder builder = new StringBuilder();
		builder.append("*******************\n***\tMenu:\t***\n*******************\n");
		
		
		for (int i = 0; i < _dishes.size(); i++)
		{
			builder.append(i+1);
			builder.append(":");
			builder.append(_dishes.values().toArray()[i].toString());
		}
		
		return builder.toString();
	}


	public Dish getDish(String name) {
		// TODO Auto-generated method stub
		return _dishes.get(name);
	}
	
}
