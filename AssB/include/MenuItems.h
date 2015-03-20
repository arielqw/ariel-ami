/*
 * MenuItems.h
 *
 *  Created on: Nov 22, 2013
 *      Author: arielbar
 */

#ifndef MenuItemS_H_
#define MenuItemS_H_
#include "MenuItem.h"
#include <vector>

/*
 * all the menu items that are known to the coffeeshop
 */
class MenuItems {
private:
	vector < MenuItem* > m_menuItems;
public:
	MenuItems();
	virtual ~MenuItems();

	//searches for a menu item and returns it. creates it if it doesnt exist
	MenuItem* getMenuItem(const string& name);

	//initial update for calculating prices for menuitems for the first time
	void update();

	void print() const;
	void printMenu() const;
};

#endif /* MenuItemS_H_ */
