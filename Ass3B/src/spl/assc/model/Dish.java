package spl.assc.model;
import java.util.List;
import java.util.SortedSet;

/**
 * This object represents a dish
 * This object is Immutable
 */
public final class Dish
{
	private final String _name; 
	private final int _difficultyRating; 
	private final long _expectedCookTime; 
	private final int _reward;
	private final SortedSet<KitchenTool> _kitchenTools; 
	private final List<Ingredient> _ingredients;
	
	public Dish(String name, int difficultyRating, long expectedCookTime, int reward, SortedSet<KitchenTool> kitchenTools, List<Ingredient> ingredients) {
		_name = name;
		_difficultyRating = difficultyRating;
		_expectedCookTime = expectedCookTime;
		_reward = reward;
		_kitchenTools = kitchenTools;
		_ingredients = ingredients;
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


	public void take(Warehouse warehouse) {
		warehouse.take(_ingredients, _kitchenTools);
	}

	public void putBack(Warehouse warehouse) {
		warehouse.putBack(_kitchenTools);		
	}
}
