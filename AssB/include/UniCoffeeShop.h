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



struct ProductPrice{
	double netoPrice;
	double brutoPrice;
	ProductPrice():netoPrice(0), brutoPrice(0){}
};


using namespace std;

//Keeps best price for an ingredient
struct AuctionWinner{
	string ingridientName;
	string supplierName;
	double winningPrice;
	AuctionWinner():ingridientName(""), supplierName(""),winningPrice(0){}
};

//Keeps a final menu item
struct MenuItem{
	string itemName;
	double itemPrice;
	MenuItem():itemName(""), itemPrice(0){}
};

//Keeps a final Shopping List item
struct ShoppingListItem{
	string supplierName;
	vector<string> ingredients;
	ShoppingListItem():supplierName(""), ingredients(){}
};



/*
 * 1st generation BGU coffee shop
 */
class UniCoffeeShop {
private:

	vector< vector<string> > _productsInput;  // keeping input files to class
	vector< vector<string> > _suppliersInput; //..

	vector<MenuItem> 			_menuOutput;
	vector<ShoppingListItem> 	_shoppingListOutput;

	void readFromFile(const string&  filename,vector< vector<string> >& table);
	void writeToFile(const string& filename , const string& str ) const;

	void splitString(const string& str,char delimiter, vector<string>& output);

	//Processing input and saving to suitable output vectores
	void processData();

	//for debug'ing purposes
	void printMatrix(const vector< vector<string> >& matrix) const;
	double calculatePrice(double priceBeforeFee);

	//Finding best price for an ingredient
	AuctionWinner getAuctionWinner(const string& ingredient) const;

	//Updates ShopingListOutput with a suitable supplier
	void addIngredientToShoppingList(const AuctionWinner& winner);

	//two uses:
	//1. prints to files
	//2. prints to console (debug'ing purposes)
	void printOutput(bool debug) const;

public:
	UniCoffeeShop();
	void start(); //doing what needs to be done
	ProductPrice getProductPrice(const string& product_name) const;
	bool updateSupplierIngredient(const string& supplier_name,const string& ingredient_name,double price_to_update );
};

#endif /* UNICOFFEESHOP_H_ */
