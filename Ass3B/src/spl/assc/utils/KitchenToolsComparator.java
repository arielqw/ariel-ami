package spl.assc.utils;

import java.util.Comparator;

import spl.assc.model.KitchenTool;

public class KitchenToolsComparator implements Comparator<KitchenTool> {

	@Override
	public int compare(KitchenTool o1, KitchenTool o2) {
		//return o1.hashCode() - o2.hashCode();
		return o1.getName().compareTo(o2.getName());
	}

}
