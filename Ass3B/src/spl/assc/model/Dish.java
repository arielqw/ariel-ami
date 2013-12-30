package spl.assc.model;
import java.util.List;
import java.util.SortedSet;

/**
 * This object represents a dish
 */
public class Dish
{
	private String 				_name; 
	private int 				_difficultyRating; 
	private long 				_expectedCookTime; 
	private int 				_reward;
	private SortedSet<KitchenTool> 	_kitchenTools; 
	private List<Ingredient> 	_ingredients;
	
	public Dish(String name, int difficultyRating, long expectedCookTime, int reward, SortedSet<KitchenTool> kitchenTools, List<Ingredient> ingredients) {
		_name = name;
		_difficultyRating = difficultyRating;
		_expectedCookTime = expectedCookTime;
		_reward = reward;
		_kitchenTools = kitchenTools;
		_ingredients = ingredients;
	}
	
	/**
	 * this object is immutable .
	 * @return needed kitchen tools
	 */
	public SortedSet<KitchenTool> getKitchenTools() {
		return _kitchenTools;
	}

	/**
	 * this object is immutable .
	 * @return needed ingredients 
	 */
	public List<Ingredient> getIngredients() {
		return _ingredients;
	}

	/**
	 * @return expected cook time for this dish
	 */
	public long getExpectedCookTime() {
		return _expectedCookTime;
	}
	

	public int getDifficultyRating() {
		return _difficultyRating;
	}


	@Override
	public String toString()
	{
		StringBuilder builder = new StringBuilder();
		builder.append(String.format("\tDish:\t{\tName: %s,\tDifficultyRating: %d,\tExpectedCookTime: %d,\tReward: %d\t}\n", _name, _difficultyRating, _expectedCookTime, _reward));
		builder.append("\t\tNeeded Kitchen Tools:\t");
		builder.append(_kitchenTools);
		builder.append("\n\t\tNeeded Ingredients:\t");
		builder.append(_ingredients);
		builder.append("\n\t====================================================================================================================\n");

		return builder.toString();
	}


	public int getReward() {
		return _reward;
	}
}
