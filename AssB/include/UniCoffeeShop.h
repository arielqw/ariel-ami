/*
 * UniCoffeeShop.h
 *
 *  Created on: Nov 12, 2013
 *      Author: Ami Oren && Ariel Baruch
 */

#ifndef UNICOFFEESHOP_H_
#define UNICOFFEESHOP_H_
#include <vector>
#include <string>
#include <fstream>
#include <iostream>
#include <stdlib.h>

#include "Suppliers.h"
#include "MenuItems.h"
#include "Ingredients.h"

const double LABOR_COST = 0.25;

using namespace std;

class UniCoffeeShop {
private:
	MenuItems _menuItems;
	Suppliers _suppliers;
	Ingredients _ingredients;
	void processProducts(const vector< vector<string> >& productsInput);
	void processSuppliers(const vector< vector<string> >& suppliersInput);
//	Suppliers _suppliers;

public:
	UniCoffeeShop();
	virtual ~UniCoffeeShop();
	void start(vector< vector<string> >& productsInput,vector< vector<string> >& suppliersInput);
	int updateSupplierIngredient(const string& supplier_name,const string& ingredient_name,const string& price);
	MenuItem* getProductPrice(const string& product_name);
};

#endif /* UNICOFFEESHOP_H_ */
