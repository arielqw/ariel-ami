/*
 * Supplier.cpp
 *
 *  Created on: Nov 22, 2013
 *      Author: arielbar
 */

#include "../include/Supplier.h"
#include <iostream>
Supplier::Supplier(const string& supname):_name(supname),_sellingCounter(0),_supplierIngredients() {

}

Supplier::~Supplier() {
	// TODO Auto-generated destructor stub
	for (unsigned int i = 0; i < _supplierIngredients.size(); ++i) {
		if(_supplierIngredients[i] != 0){
			delete _supplierIngredients[i];
		}
		_supplierIngredients[i] = 0;
	}
}

bool Supplier::addIngredient(Ingredient* ingredient,double price) {
//	std::cout << "pushing "<<ingredient.getName() << std::endl;
	SellingIngredient* sellingIngredient = new SellingIngredient(ingredient);
	sellingIngredient->setPrice(price);
  	_supplierIngredients.push_back(sellingIngredient);
//	std::cout << _supplierIngredients.size() << std::endl;
	//_prices.push_back(price);
	return true;
}

bool Supplier::operator ==(const Supplier& other) const {
	return (this->_name == other._name);
}

void Supplier::updateIngredient(const string& ingredient_name, double price) {
	for (unsigned int i = 0; i < _supplierIngredients.size(); ++i) {
		if(_supplierIngredients[i]->getName() == ingredient_name){
			_supplierIngredients[i]->setPrice(price);
			return;
		}
	}
}

void Supplier::print() const {

	for (unsigned int j = 0; j < _supplierIngredients.size(); ++j) {
		std::cout << "\t"<< _supplierIngredients[j]->getName() << "("<< _supplierIngredients[j]->getPrice() << ")"<<std::endl;
	}
}

string Supplier::getName() const {
	return _name;
}

double Supplier::getIngridientPrice(const string& ingridient_name) const {
	for (unsigned int i = 0; i < _supplierIngredients.size(); ++i) {
		if(_supplierIngredients[i]->getName() == ingridient_name){
			return _supplierIngredients[i]->getPrice();
		}
	}
	//TODO: throw exception
	return -1;
}

void Supplier::incSellingCounter() {
	_sellingCounter++;
}




