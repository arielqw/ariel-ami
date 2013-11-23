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

class MenuItems {
private:
	vector < MenuItem* > m_menuItems;
public:
	MenuItems();
	virtual ~MenuItems();

	MenuItem* getMenuItem(const string& name);
	void update();

	void print() const;
	void printMenu() const;
};

#endif /* MenuItemS_H_ */
