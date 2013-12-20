package spl.assc.model;

import java.util.List;

public class Warehouse
{
	public Warehouse(List<KitchenTool> kitchenTools, List<Ingredient> ingredients) {
		_kitchenTools = kitchenTools;
		_ingredients = ingredients;
	}
	
	private List<KitchenTool> 	_kitchenTools; 
	private List<Ingredient> 	_ingredients;
	
	
	@Override
	public String toString()
	{
		StringBuilder builder = new StringBuilder();
		//builder.append("***************************\n***\tWarehouse:\t***\n***************************\n");
		builder.append("\t\tAvailable Kitchen Tools:\t");
		builder.append(_kitchenTools);
		builder.append("\n\t\tAvailable Ingredients:\t\t");
		builder.append(_ingredients);
		builder.append("\n\t====================================================================================================================\n");

		return builder.toString();
	}
}
