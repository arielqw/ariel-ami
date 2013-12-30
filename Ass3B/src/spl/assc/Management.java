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
import spl.assc.model.OrderQueue;
import spl.assc.model.ResturantInitData;
import spl.assc.model.Warehouse;
import spl.assc.runnables.RunnableChef;
import spl.assc.runnables.RunnableDeliveryPerson;


public class Management
{
	private final static Logger LOGGER = Logger.getGlobal();
	
	private Statistics _stats;
	private final Address _address;
	private CountDownLatch _chefsCountDownLatch;
	private CountDownLatch _deliveryGuysCountDownLatch;

	private Queue<Order> _orders;
	private List<RunnableChef> _chefs;
	private List<RunnableDeliveryPerson> _deliveryGuys;
	private Warehouse _warehouse;
	private AtomicBoolean bell;
	private BlockingQueue<Order> _awaitingOrdersToDeliver;
	private Map<String,Dish> _menu;

	public Management(int chefsSize,int deliveryGuysSize, Address address) {
		LOGGER.info(String.format("[-Management initialization started-] [Chefs=%d] [Delivery Persons=%d]\n", chefsSize,deliveryGuysSize));
		
		_address = address;
		_chefs = new ArrayList<>();
		_deliveryGuys = new ArrayList<>();

		_chefsCountDownLatch = new CountDownLatch(chefsSize);
		_deliveryGuysCountDownLatch = new CountDownLatch(deliveryGuysSize);
		_awaitingOrdersToDeliver = new LinkedBlockingQueue<>();

		_menu = new HashMap<String, Dish>();
		bell = new AtomicBoolean();

		_orders = new LinkedList<>();
		
		_warehouse = new Warehouse();
		_stats = new Statistics(_warehouse);

	}
	
	public void openRestaurant(){
		for (RunnableChef chef : _chefs) {
			new Thread(chef).start();
		}
		
		for (RunnableDeliveryPerson deliveryGuy : _deliveryGuys) {
			new Thread(deliveryGuy).start();
		}		
	}

	
	public void start() throws Exception
	{
		LOGGER.info("[-Management started-]");

		while(!_orders.isEmpty()){
			
				boolean isOrderTaken = false;
				bell.compareAndSet(true, false);
				for (RunnableChef chef : _chefs) {
					if( chef.canYouTakeThisOrder( _orders.peek()) ){
						LOGGER.info(String.format("\t[Event=Order Sent To Chef] [Order=%s] [Chef=%s]", _orders.peek().info(),chef.info() ));
						isOrderTaken = true;
						_orders.poll();
						break;
					}
				}
					if(!isOrderTaken && !bell.get()){
						synchronized (bell) {
							bell.wait();
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

		try {
			_chefsCountDownLatch.await();
		} catch (InterruptedException e1) {
			e1.printStackTrace();
		}

		//Poison delivery guys
		for (int i=0; i < _deliveryGuys.size(); i++) {
			_awaitingOrdersToDeliver.add(new Order("Poisioned"));
		}
		
		try {
			_deliveryGuysCountDownLatch.await();
		} catch (InterruptedException e) {
			e.printStackTrace();
		}
		LOGGER.info("[-Management ended-]\n");

		LOGGER.info(String.format("[Statistics]\n%s", _stats.toString()));
	}


	public Warehouse linkToWareHouse() {
		return _warehouse;
	}

	public void sendToDelivery(Order order) {
		_awaitingOrdersToDeliver.add(order);
	}

	public Order takeNextOrder() throws InterruptedException {
		return _awaitingOrdersToDeliver.take();		
	}

	public long computeDistance(Order order) {
		return order.computeDistanceFrom(_address);
	}

	//init adders
	
	public void addToStatistics(double reward) {
		_stats.add(reward);
	}

	public void addToStatistics(Order order) {
		_stats.add(order);		
	}

	public void addKitchenTool(String name, int quantity) {
		LOGGER.info(String.format("\t(+) KitchenTool added: [%s=%d]",name,quantity));
		_warehouse.addKitchenTool(name,new KitchenTool(name, quantity));
		
	}

	public void addIngredient(String name, int quantity) {
		LOGGER.info(String.format("\t(+) Ingredient added: [%s=%d]",name,quantity));
		_warehouse.addIngredient(name, new Ingredient(name, quantity));
	}	
	public void addMenuDish(String name, int difficultyRating, long expectedCookTime, int reward, SortedSet<KitchenTool> kitchenTools, List<Ingredient> ingredients){
		LOGGER.info(String.format("\t(+) Dish added: [%s]",name));
		_menu.put(name, new Dish(name, difficultyRating, expectedCookTime, reward, kitchenTools, ingredients));
	}
	
	public void addChef(String name, double rating, int endurance){
		_chefs.add(new RunnableChef(name, rating, endurance, bell,this, _chefsCountDownLatch) );
		LOGGER.info(String.format("\t(+) Chef added: [name=%s] [rating=%s] [endurance=%s]", name,rating,endurance));
	}
	public void addDeliveryGuy(String name, int speed) {
		_deliveryGuys.add(new RunnableDeliveryPerson(name, speed, this, _deliveryGuysCountDownLatch) );
		LOGGER.info(String.format("\t(+) Delivery Person added: [name=%s][speed=%d]", name,speed));		
	}

	public void addOrder(int id, Address address, List<OrderOfDish> ordersOfDish) {
		int tmpDifficulty = 0;
		for (OrderOfDish orderOfDish : ordersOfDish) {
			orderOfDish.setDish(_menu.get( orderOfDish.getName() ));
			tmpDifficulty += orderOfDish.get_dish().get_difficultyRating();
		}
		_orders.add(new Order(id, address, ordersOfDish,tmpDifficulty));
		LOGGER.info(String.format("\t(+) Order added: [id=%s] %s", id,ordersOfDish));		
	}


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
