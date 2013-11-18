/*
 * CoffeeManager.h
 *
 *  Created on: Nov 17, 2013
 *      Author: amio
 */

#ifndef COFFEEMANAGER_H_
#define COFFEEMANAGER_H_




#include "Customers.h"
#include "UniCoffeeShop.h"

class CoffeeManager {
private:
	double _revenue;
	double _profit;
	UniCoffeeShop* _shop;
	Customers _customers;

	void splitString(const string& str,char delimiter, vector<string>& output);
	void readFromFile(const string&  filename,vector< vector<string> >& table);

	void eventHandler(const string& eventFileName);
	void registerEvent(const string& name, const string& product_name, const string& is_VIP);
	void purchaseEvent(const string& customer_image);
	void updateSupplierIngredientEvent(const string& supplier_name, const string& ingredient_name, const string& price);
	void singleBuy();


public:
	CoffeeManager();
	virtual ~CoffeeManager();
	void start(const string& productsFileName,const string& suppliersFileName,const string& eventFileName);

};

#endif /* COFFEEMANAGER_H_ */
