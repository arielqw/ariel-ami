/*
 * Ingredient.h
 *
 *  Created on: Nov 22, 2013
 *      Author: arielbar
 */

#ifndef INGREDIENT_H_
#define INGREDIENT_H_

#include "Supplier.h"
#include "MenuItem.h"
#include <string>
#include <vector>

//for looping
class Supplier;
class MenuItem;

using namespace std;

class Ingredient {
private:
	string _name;
	Supplier* _chosenSupplier;
	vector< Supplier* > _availableSuppliers;
	vector< MenuItem* > _usedInTheseMenuItems;
public:
	Ingredient(const string& ingname);
	virtual ~Ingredient();
	bool operator==(const Ingredient& other) const;

	void addSupplier(Supplier* supplier);
	void addMenuItem(MenuItem* menuItem);
	Supplier* pickBestSupplier();
	double getPrice() const;
	string getName();

	void print() const;
	int updateMyMenuItems();
};

#endif /* INGREDIENT_H_ */
