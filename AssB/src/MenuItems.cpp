/*
 * MenuItems.cpp
 *
 *  Created on: Nov 22, 2013
 *      Author: arielbar
 */

#include "MenuItems.h"
#include <iostream>
MenuItems::MenuItems():m_menuItems() {
	// TODO Auto-generated constructor stub

}

MenuItems::~MenuItems() {
	// TODO Auto-generated destructor stub
	for (std::vector<MenuItem*>::iterator it = m_menuItems.begin(); it != m_menuItems.end(); ++it){
		delete * it;
	}
	m_menuItems.clear();
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
	std::ostringstream debugStr;
	debugStr << "*****************Menu Items ******************" << std::endl;
	for (unsigned int i = 0; i < m_menuItems.size(); ++i) {
		m_menuItems[i]->print();
	}
	debugStr << "**********************************************" << std::endl;
	CAppLogger::Instance().Log(debugStr, Poco::Message::PRIO_TRACE);
}

void MenuItems::update() {
	for (unsigned int i = 0; i < m_menuItems.size(); ++i) {
		m_menuItems[i]->calculatePrice();
	}
}

void MenuItems::printMenu() const {
}


