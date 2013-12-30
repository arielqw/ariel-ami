package spl.assc;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Queue;
import java.util.SortedSet;
import java.util.concurrent.BlockingQueue;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.LinkedBlockingQueue;
import java.util.concurrent.atomic.AtomicBoolean;
import java.util.logging.Logger;

import spl.assc.model.Address;
import spl.assc.model.Dish;
import spl.assc.model.Ingredient;
import spl.assc.model.KitchenTool;
import spl.assc.model.Order;
import spl.assc.model.OrderOfDish;
import spl.assc.model.Warehouse;
import spl.assc.runnables.RunnableChef;
import spl.assc.runnables.RunnableDeliveryPerson;

/**
 * This class has two jobs:
 * 1. Setting up the restaurant 
 * 2. Handles orders: sending to appropriate Chefs , sending to delivery
 */
public class Management
{
	private final static Logger LOGGER = Logger.getGlobal();
	
	private Statistics _stats;
	private final Address _address;
	private Queue<Order> _orders;
	private Map<String,Dish> _menu;

	private List<RunnableChef> _chefs;
	private List<RunnableDeliveryPerson> _deliveryGuys;
	private Warehouse _warehouse;
	
	private AtomicBoolean bell; //shared with Chefs - used for wait & notify purposes 
	private BlockingQueue<Order> _awaitingOrdersToDeliver;

	private CountDownLatch _chefsCountDownLatch;
	private CountDownLatch _deliveryGuysCountDownLatch;

	/**
	 * 
	 * @param chefsSize pre-knowledge of chefs amount
	 * @param deliveryGuysSize pre-knowledge of delivery guys amount
	 * @param address restaurant's address
	 */
	public Management(int chefsSize,int deliveryGuysSize, Address address) {
		LOGGER.info(String.format("[-Management initialization started-] [Chefs=%d] [Delivery Persons=%d]\n", chefsSize,deliveryGuysSize));
		
		_address = address;
		_chefs = new ArrayList<>();
		_deliveryGuys = new ArrayList<>();
		_menu = new HashMap<String, Dish>();
		_warehouse = new Warehouse();
		_orders = new LinkedList<>();
		_stats = new Statistics(_warehouse);

		_chefsCountDownLatch = new CountDownLatch(chefsSize);
		_deliveryGuysCountDownLatch = new CountDownLatch(deliveryGuysSize);
		_awaitingOrdersToDeliver = new LinkedBlockingQueue<>();

		bell = new AtomicBoolean();
	}
	
	/**
	 * Initialization of staff members
	 */
	public void openRestaurant(){
		for (RunnableChef chef : _chefs) {
			new Thread(chef).start();
		}
		
		for (RunnableDeliveryPerson deliveryGuy : _deliveryGuys) {
			new Thread(deliveryGuy).start();
		}		
	}

	/**
	 * This method simulates the restaurant's activity
	 */
	public void start() 
	{
		LOGGER.info("[-Management started-]");
		
		//As long as there is pending orders: send to appropriate chef
		while(!_orders.isEmpty()){
				boolean isOrderTaken = false;
				bell.compareAndSet(true, false);
				
				//Go through chefs and try to find a chef that will take the order
				for (RunnableChef chef : _chefs) {
					if( chef.canYouTakeThisOrder( _orders.peek()) ){
						LOGGER.info(String.format("\t[Event=Order Sent To Chef] [Order=%s] [Chef=%s]", _orders.peek().info(),chef.info() ));
						isOrderTaken = true;
						_orders.poll();
						break;
					}
				}
				//if no chef could take the order -> go sleep and wait that a chef becomes available 
				//*note: checking bell's status for knowing no one notified while awake
				if(!isOrderTaken && !bell.get()){
					synchronized (bell) {
						try {
							bell.wait();
						} catch (InterruptedException e) {
							e.printStackTrace();
						}
					}
				}
		}
		
		//Shutdown chefs
		for (RunnableChef chef : _chefs) {
			chef.stopTakingNewOrders();
			synchronized (chef) {
				chef.notifyAll();
			}
		}
		
		//wait for chefs to stop working
		try {
			_chefsCountDownLatch.await();
		} catch (InterruptedException e1) {
			e1.printStackTrace();
		}

		//Poison delivery guys
		for (int i=0; i < _deliveryGuys.size(); i++) {
			_awaitingOrdersToDeliver.add(new Order("Poisioned"));
		}
		
		//wait for delivery guys to stop
		try {
			_deliveryGuysCountDownLatch.await();
		} catch (InterruptedException e) {
			e.printStackTrace();
		}
		LOGGER.info("[-Management ended-]\n");

		LOGGER.info(String.format("[Statistics]\n%s", _stats.toString()));
	}

	
	/**
	 * push order to delivery queue
	 * @param order order to add to delivery queue
	 */
	public void sendToDelivery(Order order) {
		_awaitingOrdersToDeliver.add(order);
	}

	/**
	 * Retrives an order from orders waiting for delivered queue
	 * This method is Blocking
	 * Could return a 'Poisoned' order
	 * @return order to handle OR 'Poisoned' order
	 * @throws InterruptedException
	 */
	public Order takeNextOrder() throws InterruptedException {
		return _awaitingOrdersToDeliver.take();		
	}

	/**
	 * This method calculates the distance from an order's address to restaurant's address
	 * @param order
	 * @return distance
	 */
	public long computeDistance(Order order) {
		return order.computeDistanceFrom(_address);
	}

	/*
	 * Methods used for setting up the restaurant
	 */
	
	/**
	 * adds reward to restaurant's revenue
	 * @param reward
	 */
	public void addToStatistics(double reward) {
		_stats.add(reward);
	}

	/**
	 * adds order to restaurant's statistics 
	 */
	public void addToStatistics(Order order) {
		_stats.add(order);		
	}

	/**
	 * Adds a kitchen tool to the warehouse
	 * @param name kitchen tool name
	 * @param quantity kitchen tool quantity
	 */
	public void addKitchenTool(String name, int quantity) {
		LOGGER.info(String.format("\t(+) KitchenTool added: [%s=%d]",name,quantity));
		_warehouse.addKitchenTool(name,new KitchenTool(name, quantity));
		
	}

	/**
	 * Adds an ingredient to the warehouse
	 * @param name ingredient  name
	 * @param quantity ingredient quantity
	 */
	public void addIngredient(String name, int quantity) {
		LOGGER.info(String.format("\t(+) Ingredient added: [%s=%d]",name,quantity));
		_warehouse.addIngredient(name, new Ingredient(name, quantity));
	}	
	
	/**
	 * Adds a dish to the restaurant's menu
	 * @param name
	 * @param difficultyRating 
	 * @param expectedCookTime 
	 * @param reward dish cost to client
	 * @param kitchenTools a list of needed kitchen tools in order to cook this this
	 * @param ingredients a list of needed ingredients in order to cook this this
	 */
	public void addMenuDish(String name, int difficultyRating, long expectedCookTime, int reward, SortedSet<KitchenTool> kitchenTools, List<Ingredient> ingredients){
		LOGGER.info(String.format("\t(+) Dish added: [%s]",name));
		_menu.put(name, new Dish(name, difficultyRating, expectedCookTime, reward, kitchenTools, ingredients));
	}
	
	/**
	 * Adding a chef to restaurant's staff
	 * @param name
	 * @param rating chef's efficiency rating
	 * @param endurance chef's endurance rating
	 */
	public void addChef(String name, double rating, int endurance){
		_chefs.add(new RunnableChef(name, rating, endurance, bell,this, _chefsCountDownLatch, _warehouse) );
		LOGGER.info(String.format("\t(+) Chef added: [name=%s] [rating=%s] [endurance=%s]", name,rating,endurance));
	}
	
	/**
	 * Adding a delivery person to restaurant's staff
	 * @param name
	 * @param speed
	 */
	public void addDeliveryGuy(String name, int speed) {
		_deliveryGuys.add(new RunnableDeliveryPerson(name, speed, this, _deliveryGuysCountDownLatch) );
		LOGGER.info(String.format("\t(+) Delivery Person added: [name=%s][speed=%d]", name,speed));		
	}

	/**
	 * Adding a new order
	 * @param id
	 * @param address
	 * @param ordersOfDish a list of containing dishes 
	 */
	public void addOrder(int id, Address address, List<OrderOfDish> ordersOfDish) {
		int tmpDifficulty = 0;
		for (OrderOfDish orderOfDish : ordersOfDish) {
			orderOfDish.setDish(_menu.get( orderOfDish.getName() ));
			tmpDifficulty += orderOfDish.get_dish().getDifficultyRating();
		}
		_orders.add(new Order(id, address, ordersOfDish,tmpDifficulty));
		LOGGER.info(String.format("\t(+) Order added: [id=%s] %s", id,ordersOfDish));		
	}

	/**
	 * Utility for printing restuarant's menu
	 */
	public void printMenu()
	{
		StringBuilder builder = new StringBuilder();
		builder.append("*******************\n***\tMenu:\t***\n*******************\n");
		
		
		for (int i = 0; i < _menu.size(); i++)
		{
			builder.append(i+1);
			builder.append(":");
			builder.append(_menu.values().toArray()[i].toString());
		}
		
		LOGGER.info(builder.toString());
	}

	
}
