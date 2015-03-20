/*
 * Supplier.h
 *
 *  Created on: Nov 22, 2013
 *      Author: arielbar
 */

#ifndef SUPPLIER_H_
#define SUPPLIER_H_
class Ingredient;
class SellingIngredient;

#include "SellingIngredient.h"
#include "Ingredient.h"
#include "AppLogger.h"

#include <string>
#include <vector>


using namespace std;

/*
 * represents a suuplier that proivedes ingredients to the coffeeshop
 */
class Supplier {
private:

	string _name;

	vector< SellingIngredient* > _supplierIngredients;

public:
	Supplier(const string& supname);
	virtual ~Supplier();
	bool operator == (const Supplier& other) const;

	//creates a "selling ingredient" from the ingredeint and pushes it to list
	//return true if succeeds
	bool addIngredient(Ingredient* ingredient,double price);

	//updates the matching "selling ingredient" and updates it price
	void updateIngredient(const string& ingredient_name,double price);

	void print() const;
	string getName() const;
	double getIngridientPrice(const string& ingridient_name) const;
};

#endif /* SUPPLIER_H_ */
