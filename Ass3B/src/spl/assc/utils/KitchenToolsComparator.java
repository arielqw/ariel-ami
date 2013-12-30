package spl.assc.utils;

import java.util.Comparator;

import spl.assc.model.KitchenTool;

/**
 * comparing kitchen tools by name
 */
public class KitchenToolsComparator implements Comparator<KitchenTool> {

	@Override
	public int compare(KitchenTool o1, KitchenTool o2) {
		return o1.getName().compareTo(o2.getName());
	}

}
