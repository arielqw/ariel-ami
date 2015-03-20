package spl.assc.model;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.SortedSet;

/**
 * This object represents a warehouse
 */
public class Warehouse
{

	private Map<String,KitchenTool> _kitchenTools; 
	private Map<String,Ingredient> 	_ingredients;

	public Warehouse() {
		_kitchenTools = new HashMap<String,KitchenTool>();
		_ingredients = new HashMap<String,Ingredient>();

	}
	
	public void addKitchenTool(String name, KitchenTool kitchenTool){
		_kitchenTools.put(name, kitchenTool);
	}
	
	public void addIngredient(String name, Ingredient ingredient){
		_ingredients.put(name, ingredient);
	}	
	
	/**
	 * used to retrive desired kitchen tools and ingredients
	 * This method is Blocking (semaphore kitchen tools take() )
	 * @param ingredients
	 * @param kitchenTools
	 */
	public void take(List<Ingredient> ingredients,SortedSet<KitchenTool> kitchenTools){
		//take ingredients
		for (Ingredient ingredient : ingredients) {
			_ingredients.get( ingredient.getName() ).take(ingredient);
		}
		
		//take kitchen tools
		for (KitchenTool kitchenTool : kitchenTools) {
			KitchenTool warehouseKitchenTool = _kitchenTools.get( kitchenTool.getName() );
			warehouseKitchenTool.take( kitchenTool );
		}
	}

	/**
	 * return used kitchen tools to the warehouse
	 * @param kitchenTools
	 */
	public void putBack(SortedSet<KitchenTool> kitchenTools){
		for (KitchenTool kitchenTool : kitchenTools) {
			_kitchenTools.get( kitchenTool.getName() ).putBack( kitchenTool );
		}
	}

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
	
	
	/**
	 * Utility, printing how many ingredients were used
	 * @return
	 */
	public String consumedIngredientsReport()
	{
		StringBuilder builder = new StringBuilder();
		
		for (Ingredient ingredient : _ingredients.values()) {
			if( ingredient.getConsumedAmount() > 0 ){
				builder.append(String.format("[%s:%d], ", ingredient.getName(),ingredient.getConsumedAmount()));
			}
		}
		//delete last ','
		if(builder.length() >0){
			return builder.substring(0,builder.length()-2);
		}
		else{
			return builder.toString();
		}
	}

}
