/*
 * Ingredient.cpp
 *
 *  Created on: Nov 22, 2013
 *      Author: arielbar
 */

#include "../include/Ingredient.h"
#include <iostream>
Ingredient::Ingredient(const string& ingname):_name(ingname) {

}

Ingredient::~Ingredient() {
	// TODO Auto-generated destructor stub
}

Supplier* Ingredient::pickBestSupplier() {
	Supplier* bestSupplier;
	if(_availableSuppliers.size() ==0){
		//TODO: throw error if no supplier
		return bestSupplier;
	}
	bestSupplier = _availableSuppliers[0];

	for (unsigned int i = 1; i < _availableSuppliers.size(); ++i) {
		if(_availableSuppliers[i]->getIngridientPrice(this->_name) < bestSupplier->getIngridientPrice(this->_name)){
			bestSupplier = _availableSuppliers[i];
		}
	}
	this->_chosenSupplier = bestSupplier;
	bestSupplier->incSellingCounter();
	return bestSupplier;
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

string Ingredient::getName() {
	return _name;
}

void Ingredient::print() const {
	std::cout << this->_name <<std::endl;
	for (unsigned int i = 0; i < this->_usedInTheseMenuItems.size(); ++i) {
		std::cout << "\t";
		this->_usedInTheseMenuItems[i]->print();
	}
}

int Ingredient::updateMyMenuItems() {
	int itemchanges= 0;
	for (unsigned int i = 0; i < _usedInTheseMenuItems.size(); ++i) {
		itemchanges+=_usedInTheseMenuItems[i]->calculatePrice();
	}
	return itemchanges;
	//std::cout << "items changed: " << itemchanges << std::endl;
}






