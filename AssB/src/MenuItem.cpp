/*
 * MenuItem.cpp
 *
 *  Created on: Nov 22, 2013
 *      Author: arielbar
 */

#include "MenuItem.h"
#include <iostream>

MenuItem::MenuItem(const string& name):_name(name),_itemIngredients(),_brutoPrice(-1),_netoPrice(-1),_onMenu(false) {
	
}

MenuItem::~MenuItem() {
	
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
	int changed = 0;	//num
	double cost = 0;
	//iterate over all of this menu item's ingredients and sum up the cumulative cost
	for (unsigned int i = 0; i < _itemIngredients.size(); ++i) {
		cost += _itemIngredients[i]->getPrice();
	}
	//if a change in the menu item's price has occurred check if it was just added to the menu
	//or just removed from the menu and log accordingly
	if((this->_netoPrice != -1) && this->_brutoPrice != ((cost + 0.25)*1.5)){
		// add 1 for each menu item that was just added to the menu
		changed += logChange((cost + 0.25)*1.5);
	}
	this->_netoPrice = cost+0.25;
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
			//inc number of menu items which their price changed and but still they stayed on the menu
			return 1;
		}
		else{
			CAppLogger::Instance().Log("Product "+this->_name+" was removed from the menu.",Poco::Message::PRIO_WARNING);		}
	}
	else{
		if(brutoPrice <= 5){
			CAppLogger::Instance().Log("Product "+this->_name+" was added from the menu.",Poco::Message::PRIO_WARNING);		}
	}
	return 0;
}

void MenuItem::print() const {
	std::ostringstream debugStr;
	if(this->isOnMenu()){
		debugStr << "[x] ";
	}
	else{
		debugStr << "[ ] ";
	}
	debugStr << this->_name  << "\t" << this->_brutoPrice << " (" << this->_netoPrice << ") { ";
	for (unsigned int i = 0; i < this->_itemIngredients.size(); ++i) {
		debugStr << this->_itemIngredients[i]->getName() ;
		if(i != _itemIngredients.size()-1){
			debugStr << ", ";
		}
	}
	debugStr << " }" << std::endl;

	CAppLogger::Instance().Log(debugStr,Poco::Message::PRIO_TRACE);
}

string MenuItem::getName() const {
	return _name;
}





