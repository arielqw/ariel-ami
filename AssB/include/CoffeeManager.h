/*
 * CoffeeManager.h
 *
 *  Created on: Nov 17, 2013
 *      Author: amio
 */

#ifndef COFFEEMANAGER_H_
#define COFFEEMANAGER_H_


struct ProductPrice;


#include "Customers.h"
#include "UniCoffeeShop.h"

class CoffeeManager {
private:
	double _revenue;
	double _profit;
	UniCoffeeShop _shop;
	Customers _customers;

	void eventHandler();
	void registerEvent();
	void purchaseEvent();
	void singleBuy();
	void updateSupplierIngredient();

public:
	CoffeeManager();
	virtual ~CoffeeManager();


};

#endif /* COFFEEMANAGER_H_ */
