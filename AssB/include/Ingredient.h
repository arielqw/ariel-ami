/*
 * Ingredient.h
 *
 *  Created on: Nov 22, 2013
 *      Author: arielbar
 */

#ifndef INGREDIENT_H_
#define INGREDIENT_H_

#include "AppLogger.h"
#include "Supplier.h"
#include "MenuItem.h"
#include <string>
#include <vector>

//for looping - solves circular references
class Supplier;
class MenuItem;

using namespace std;

/*
 * this class represents an ingredient that is used to make menuitems and provided by a supplier
 */
class Ingredient {
private:
	Ingredient(const Ingredient& other);
	Ingredient& operator=(const Ingredient& other);

	string _name;
	Supplier* _chosenSupplier;	//the cheapest supplier for this ingredient
	vector< Supplier* > _availableSuppliers;
	vector< MenuItem* > _usedInTheseMenuItems;	//menu items that use this ingredient
public:
	Ingredient(const string& ingname);
	virtual ~Ingredient();
	bool operator==(const Ingredient& other) const;

	//adds a supplier that provides this ingredient
	void addSupplier(Supplier* supplier);

	//adds MenuItem that uses this ingredient
	void addMenuItem(MenuItem* menuItem);

	//update this instance to know who its best supplier is
	void pickBestSupplier();

	//get price from the cheapest supplier
	double getPrice() const;

	string getName() const;

	void print() const;

	//updates the prices of all the menu items that use this ingredient
	//and return the number of menuitems on the menu that changed their price but stayed on the menu
	int updateMyMenuItems();
};

#endif /* INGREDIENT_H_ */
