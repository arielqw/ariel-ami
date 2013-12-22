package spl.assc.model;

import java.util.List;

import spl.assc.runnables.RunnableChef;
import spl.assc.runnables.RunnableDeliveryPerson;

public class ResturantInitData
{
	public ResturantInitData(List<RunnableChef> chefs, List<RunnableDeliveryPerson> deliveryGuys, Warehouse warehouse) {
		_chefs = chefs;
		_deliveryGuys = deliveryGuys;
		_warehouse = warehouse;
	}
	
	public List<RunnableChef> get_chefs() {
		return _chefs;
	}


	public List<RunnableDeliveryPerson> get_deliveryGuys() {
		return _deliveryGuys;
	}


	public Warehouse get_warehouse() {
		return _warehouse;
	}

	private List<RunnableChef> _chefs;
	private List<RunnableDeliveryPerson> _deliveryGuys;
	private Warehouse _warehouse;
	
	
	@Override
	public String toString()
	{
		StringBuilder builder = new StringBuilder();
		builder.append("***********************************\n***\tResturantInitData:\t***\n***********************************\n");
		builder.append(_warehouse);
		builder.append("\t\tChefs:\t\t");
		builder.append(_chefs);
		builder.append("\n\t\tDelivery Guys:\t");
		builder.append(_deliveryGuys);
		builder.append("\n\t====================================================================================================================\n");

		return builder.toString();
	}

	public Address getAddress() {
		// TODO get Address from parser - AMI!
		return new Address(10, 10);
	}
}
