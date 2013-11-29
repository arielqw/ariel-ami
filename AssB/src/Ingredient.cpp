/*
 * Ingredient.cpp
 *
 *  Created on: Nov 22, 2013
 *      Author: arielbar
 */

#include "Ingredient.h"

#include <iostream>

Ingredient::Ingredient(const string& ingname):
		_name(ingname), _chosenSupplier(NULL), _availableSuppliers(), _usedInTheseMenuItems() {
}

Ingredient::Ingredient(const Ingredient& other):
		_name(other._name), _chosenSupplier(NULL), _availableSuppliers(), _usedInTheseMenuItems(){
	//unreachable
	Ingredient(other._name);
}

Ingredient& Ingredient::operator =(const Ingredient& other) {
	//unreachable
	return *this;
}

Ingredient::~Ingredient() {
	// TODO Auto-generated destructor stub
}

void Ingredient::pickBestSupplier() {
	Supplier* bestSupplier = NULL;
	if(_availableSuppliers.size() ==0){
		//TODO: throw error if no supplier
		return;
	}
	bestSupplier = _availableSuppliers[0];

	for (unsigned int i = 1; i < _availableSuppliers.size(); ++i) {
		if(_availableSuppliers[i]->getIngridientPrice(this->_name) < bestSupplier->getIngridientPrice(this->_name)){
			bestSupplier = _availableSuppliers[i];
		}
	}
	this->_chosenSupplier = bestSupplier;
	bestSupplier->incSellingCounter();

}

bool Ingredient::operator ==(const Ingredient& other) const {
	return (this->_name == other._name);
}

double Ingredient::getPrice() const {
	return _chosenSupplier->getIngridientPrice(this->_name);
}

void Ingredient::addSupplier(Supplier* supplier) {
	_availableSuppliers.push_back(supplier);
}

void Ingredient::addMenuItem(MenuItem* menuItem) {
	_usedInTheseMenuItems.push_back(menuItem);
}

string Ingredient::getName() const{
	return _name;
}



void Ingredient::print() const {

	std::ostringstream debugStr;
	debugStr << this->_name <<std::endl;
	for (unsigned int i = 0; i < this->_usedInTheseMenuItems.size(); ++i) {
		debugStr << "\t";
		this->_usedInTheseMenuItems[i]->print();
	}
	CAppLogger::Instance().Log(debugStr, Poco::Message::PRIO_TRACE);
}

int Ingredient::updateMyMenuItems() {
	int itemchanges= 0;
	for (unsigned int i = 0; i < _usedInTheseMenuItems.size(); ++i) {
		itemchanges+=_usedInTheseMenuItems[i]->calculatePrice();
	}
	return itemchanges;
}






