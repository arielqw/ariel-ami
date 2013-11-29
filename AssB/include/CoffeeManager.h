/*
 * CoffeeManager.h
 *
 *  Created on: Nov 17, 2013
 *      Author: amio
 */

#ifndef COFFEEMANAGER_H_
#define COFFEEMANAGER_H_



//#include "Log.h"
#include "AppLogger.h"
#include "Customers.h"
#include "UniCoffeeShop.h"

/*
 * a class that manages the coffeeshop events and provides it with the data it needs
 *
 */
class CoffeeManager {
private:
	CoffeeManager(const CoffeeManager& other);
	CoffeeManager& operator=(const CoffeeManager& other);

	double _revenue;	//total income
	double _profit;		//total income minus expenses
	UniCoffeeShop* _shop;
	Customers _customers;	//registered customers

	//splits a string to a string vector according to delimiter
	void splitString(const string& str,char delimiter, vector<string>& output);

	//reads a file into a string matrix
	void readFromFile(const string&  filename,vector< vector<string> >& table, char delimiter);

	//reads events and handles them
	void eventHandler(const string& eventFileName);

	//handles register event
	void registerEvent(const string& name, const string& product_name, const string& is_VIP);

	//handles purchase event
	void purchaseEvent(const string& customer_image);

	//handles event of a supplier updating a price of an ingredient
	void updateSupplierIngredientEvent(const string& supplier_name, const string& ingredient_name, const string& price);

	//tries to make a purchase for a single customer
	void singleBuy(Customer& buyer);

	//logs current revenue and profit
	void logRevenueAndProfit() const;


public:
	CoffeeManager();
	virtual ~CoffeeManager();

	//start the CoffeeManager's operation
	void start(const string& confFileName, const string& productsFileName,const string& suppliersFileName,const string& eventFileName);

};

#endif /* COFFEEMANAGER_H_ */
