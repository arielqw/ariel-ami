/*
 * MenuItems.cpp
 *
 *  Created on: Nov 22, 2013
 *      Author: arielbar
 */

#include "../include/MenuItems.h"
#include <iostream>
MenuItems::MenuItems() {
	// TODO Auto-generated constructor stub

}

MenuItems::~MenuItems() {
	// TODO Auto-generated destructor stub
	for (unsigned int i = 0; i < m_menuItems.size(); ++i) {
		if(m_menuItems[i] != 0){
			delete m_menuItems[i];
		}
		m_menuItems[i]=0;
	}
}

MenuItem* MenuItems::getMenuItem(const string& name) {
	//if MenuItem exists -> return it
	for (unsigned int i = 0; i < m_menuItems.size(); ++i) {
		if(name == m_menuItems[i]->getName()){
			return m_menuItems[i];
		}
	}
	//else -> create it, push, and return it
	MenuItem* menuItem = new MenuItem(name);
	m_menuItems.push_back(menuItem);
	return menuItem;

}


void MenuItems::print() const {
	std::cout << "*****************Menu Items ******************" << std::endl;
	for (unsigned int i = 0; i < m_menuItems.size(); ++i) {
		m_menuItems[i]->print();
	}
	std::cout << "**********************************************" << std::endl;
}

void MenuItems::update() {
	for (unsigned int i = 0; i < m_menuItems.size(); ++i) {
		m_menuItems[i]->calculatePrice();
	}
}

void MenuItems::printMenu() const {
}


