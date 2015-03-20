import java.util.List;

/**
 * @inv getIngredientsCount() >= 0
 * @inv getKitchenToolCount() >= 0
 * 
 */
public interface Warehouse
{

	/**
	 * @pre foreach ingredient in @ingredients: getRemainingIngredient(ingredient) >= ingredient.quantity
	 * @pre foreach kitchenTool in @kitchenTools: getRemainingKitchenTools(kitchenTool) >= kitchenTool.quantity
	 * @post foreach ingredient in @this._ingredients: getRemainingIngredient(ingredient) == @before(getRemainingIngredient(ingredient)-ingredient.quantity)
	 * @post foreach kitchenTool in @this._kitchenTools: getRemainingKitchenTools(kitchenTool) == @before(getRemainingKitchenTools(kitchenTool)-kitchenTool.quantity)
	 */
	public void takeResources(List<Ingredient> ingredients, List<KitchenTool> kitchenTools);
	
	/**
	 * @pre foreach kitchenTool in @kitchenTools: getRemainingKitchenTools(kitchenTool) >= 0
	 * @post foreach kitchenTool in @this._kitchenTools: getRemainingKitchenTools(kitchenTool) == @before(getRemainingKitchenTools(kitchenTool)+kitchenTool.quantity)
	 */
	public void returnKitchenTools(List<KitchenTool> kitchenTools);
	
	//
	public String ingredientsConsumedReport();
	
	
	public int getIngredientsCount();
	public int getKitchenToolCount();
	
	public int getRemainingIngredient(String ingredient);
	public int getRemainingKitchenTools(String kitchenTools);
	
	
}

