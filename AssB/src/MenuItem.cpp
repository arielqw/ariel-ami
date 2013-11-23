/*
 * MenuItem.cpp
 *
 *  Created on: Nov 22, 2013
 *      Author: arielbar
 */

#include "../include/MenuItem.h"
#include <iostream>

MenuItem::MenuItem(const string& name):_name(name),_itemIngredients(),_brutoPrice(-1),_netoPrice(-1),_onMenu(false) {
	// TODO Auto-generated constructor stub
}

MenuItem::~MenuItem() {
	// TODO Auto-generated destructor stub
}

double MenuItem::getBrutoPrice() const {
	return _brutoPrice;
}

double MenuItem::getNetoPrice() const {
	return _netoPrice;
}

bool MenuItem::isOnMenu() const {
	return this->_onMenu;
}


int MenuItem::calculatePrice() {
	int changed = 0;
	double cost = 0;
	for (unsigned int i = 0; i < _itemIngredients.size(); ++i) {
		cost += _itemIngredients[i]->getPrice();
	}
	if((this->_netoPrice != -1) && this->_brutoPrice != ((cost + 0.25)*1.5)){
		changed += logChange((cost + 0.25)*1.5);
	}
	this->_netoPrice = cost;
	this->_brutoPrice = (cost + 0.25)*1.5;
	if(_brutoPrice <= 5){
		this->_onMenu = true;
	}
	else{
		this->_onMenu = false;
	}
	return changed;
}

void MenuItem::addIngridient(Ingredient* ingridient) {
	_itemIngredients.push_back(ingridient);
}

int MenuItem::logChange(double brutoPrice) const {
	if( isOnMenu() ){
		if(brutoPrice <= 5){
			//std::cout << this->_name << "\t price changed, stil on menu" << std::endl;
			//inc number of items changed (and stayed on the menu)
			return 1;
		}
		else{
			CAppLogger::Instance().Log("Product addition/removal from the menu due to price change (previous item)","Product "+this->_name+" was removed from the menu.",Poco::Message::PRIO_WARNING);		}
	}
	else{
		if(brutoPrice <= 5){
			CAppLogger::Instance().Log("Product addition/removal from the menu due to price change (previous item)","Product "+this->_name+" was added from the menu.",Poco::Message::PRIO_WARNING);		}
	}
	return 0;
}

void MenuItem::print() const {
	if(this->isOnMenu()){
		std::cout << "[x] ";
	}
	else{
		std::cout << "[ ] ";
	}
	std::cout << this->_name  << "\t" << this->_brutoPrice << " (" << this->_netoPrice << ") { ";
	for (unsigned int i = 0; i < this->_itemIngredients.size(); ++i) {
		std::cout << this->_itemIngredients[i]->getName() ;
		if(i != _itemIngredients.size()-1){
			std::cout << ", ";
		}
	}
	std::cout << "}" << std::endl<< std::endl ;
}

string MenuItem::getName() const {
	return _name;
}





