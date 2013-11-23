/*
 * SellingIngredient.cpp
 *
 *  Created on: Nov 22, 2013
 *      Author: arielbar
 */

#include "../include/SellingIngredient.h"

SellingIngredient::SellingIngredient(Ingredient* ingridient):_ingredient(ingridient),_price(0) {

}

SellingIngredient::~SellingIngredient() {
	// TODO Auto-generated destructor stub
}

string SellingIngredient::getName() {
	return _ingredient->getName();
}

double SellingIngredient::getPrice() const {
	return _price;
}

void SellingIngredient::setPrice(double price) {
	_price = price;
}




