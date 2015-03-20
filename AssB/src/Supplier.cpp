/*
 * Supplier.cpp
 *
 *  Created on: Nov 22, 2013
 *      Author: arielbar
 */

#include "Supplier.h"
#include <iostream>
Supplier::Supplier(const string& supname):_name(supname),_supplierIngredients() {

}

Supplier::~Supplier() {
	
	for (std::vector<SellingIngredient*>::iterator it = _supplierIngredients.begin(); it != _supplierIngredients.end(); ++it){
		delete * it;
	}
	_supplierIngredients.clear();


}

bool Supplier::addIngredient(Ingredient* ingredient,double price) {
	SellingIngredient* sellingIngredient = new SellingIngredient(ingredient);
	sellingIngredient->setPrice(price);
  	_supplierIngredients.push_back(sellingIngredient);

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

	std::ostringstream debugStr;
	for (unsigned int j = 0; j < _supplierIngredients.size(); ++j) {
		debugStr << "\t"<< _supplierIngredients[j]->getName() << "("<< _supplierIngredients[j]->getPrice() << ")"<<std::endl;
	}
	CAppLogger::Instance().Log(debugStr, Poco::Message::PRIO_TRACE);
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
	//matandro said on the forum it cannot happen
	CAppLogger::Instance().Log("getIngridientPrice: ingredient not found", Poco::Message::PRIO_DEBUG );
	return -1;
}






