/*
 * SellingIngredient.cpp
 *
 *  Created on: Nov 22, 2013
 *      Author: arielbar
 */

#include "SellingIngredient.h"

SellingIngredient::SellingIngredient(Ingredient* ingridient):_ingredient(ingridient),_price(0) {

}

SellingIngredient::SellingIngredient(const SellingIngredient& other):_ingredient(NULL),_price(0) {
	//unreachable

}

SellingIngredient& SellingIngredient::operator =(
		const SellingIngredient& other) {
	//unreachable
	return *this;
}

SellingIngredient::~SellingIngredient() {
	
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




