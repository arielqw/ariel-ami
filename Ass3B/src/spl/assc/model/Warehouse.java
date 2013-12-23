package spl.assc.model;

import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.SortedSet;
import java.util.logging.Logger;

import spl.assc.Management;

public class Warehouse
{
	private final static Logger LOGGER = Logger.getGlobal();

	private Map<String,KitchenTool> 	_kitchenTools; 
	private Map<String,Ingredient> 	_ingredients;

	public Warehouse(SortedSet<KitchenTool> kitchenTools, List<Ingredient> ingredients) {
		_kitchenTools = new HashMap<String,KitchenTool>();
		_ingredients = new HashMap<String,Ingredient>();

		
		//transfer set to hash map
		for (KitchenTool kitchenTool : kitchenTools) {
			_kitchenTools.put(kitchenTool.getName(), kitchenTool);
		}

		for (Ingredient ingredient : ingredients) {
			_ingredients.put(ingredient.getName(), ingredient);
		}
	}
	
	/*TODO: try to do this:
	private void take(Iterable<WarehouseItem> iterable, Map<String,WarehouseItem> map){
		for (WarehouseItem item : iterable) {
			map.get( item.getName() ).take( item.getQuantity() );
		}
	}
	*/
	/**
	 * This function is Blocking (semaphore kitchen tools take()
	 * @param ingredients
	 * @param kitchenTools
	 */
	public void take(List<Ingredient> ingredients,SortedSet<KitchenTool> kitchenTools){
		//take ingredients
		for (Ingredient ingredient : ingredients) {
			_ingredients.get( ingredient.getName() ).take( ingredient.getQuantity() );
		}
		
		//take kitchen tools
		for (KitchenTool kitchenTool : kitchenTools) {
			_kitchenTools.get( kitchenTool.getName() ).take( kitchenTool.getQuantity() );
		}
		
	}
	
	public void putBack(SortedSet<KitchenTool> kitchenTools){
		for (KitchenTool kitchenTool : kitchenTools) {
			_kitchenTools.get( kitchenTool.getName() ).putBack( kitchenTool.getQuantity() );
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
