/*
 * MenuItem.h
 *
 *  Created on: Nov 22, 2013
 *      Author: arielbar
 */

#ifndef MenuItem_H_
#define MenuItem_H_
#include "Ingredient.h"
#include <vector>
#include "AppLogger.h"

using namespace std;

/*
 * a potential item that can be inside the menu that is provided for the coffee shop's customers
 */
class MenuItem {
private:
	string _name;
	vector < Ingredient* > _itemIngredients;
	double _brutoPrice;
	double _netoPrice;
	bool _onMenu;
public:
	MenuItem(const string& name);
	virtual ~MenuItem();
	double getBrutoPrice() const;
	double getNetoPrice() const;
	bool isOnMenu() const;
	int calculatePrice();
	void addIngridient(Ingredient* ingridient);

	//log of any menuitem that was added/removed from the menu
	//and return the number of menuitems on the menu that changed their price but stayed on the menu
	int logChange(double brutoPrice) const;

	void print() const;
	string getName() const;
};


#endif /* MenuItem_H_ */
