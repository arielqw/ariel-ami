import static org.junit.Assert.*;

import java.util.ArrayList;
import java.util.List;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;


public class WarehouseTest
{

	WarehouseImpl warehouse;
	
	
	@Before
	public void setUp() throws Exception
	{
		warehouse = new WarehouseImpl();
	}

	@After
	public void tearDown() throws Exception
	{
	}

	@Test
	public void testTakeResources()
	{
		String ingredientsStr[] = { "cucumber", "tommato", "letus", "potato" };
		List<Ingredient> ingredients = new ArrayList<Ingredient>();
		
		for (int i = 0; i < ingredientsStr.length; i++)
		{
			ingredients.add(new Ingredient(ingredientsStr[i],i+1));
		}
		
		String kitchenToolsStr[] = { "fork", "pot", "spoon", "knife" };
		List<KitchenTool> kitchenTools = new ArrayList<KitchenTool>();
		
		for (int i = 0; i < kitchenToolsStr.length; i++)
		{
			kitchenTools.add(new KitchenTool(kitchenToolsStr[i],i+1));
		}
		
		warehouse.takeResources(ingredients, kitchenTools);
		
		
		for (KitchenTool kitchenTool : kitchenTools)
		{
			//warehouse.getKitchenToolCount() == 
		}
		
		
		fail("Not yet implemented");
	}

	@Test
	public void testReturnKitchenTools()
	{
		fail("Not yet implemented");
	}

	@Test
	public void testIngredientsConsumedReport()
	{
		fail("Not yet implemented");
	}

}
