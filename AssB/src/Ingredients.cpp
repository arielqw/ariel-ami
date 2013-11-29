/*
 * Ingredients.cpp
 *
 *  Created on: Nov 22, 2013
 *      Author: arielbar
 */

#include "Ingredients.h"
#include <iostream>
Ingredients::Ingredients():m_ingredients() {
	// TODO Auto-generated constructor stub

}

Ingredients::~Ingredients() {
	// TODO Auto-generated destructor stub
	for (std::vector<Ingredient*>::iterator it = m_ingredients.begin(); it != m_ingredients.end(); ++it){
		delete * it;
	}
	m_ingredients.clear();
}

Ingredient* Ingredients::getIngredient(const string& ingredient_name) {
	//if ingredient exists -> return it
	for (unsigned int i = 0; i < m_ingredients.size(); ++i) {
		if(ingredient_name == m_ingredients[i]->getName()){
			return m_ingredients[i];
		}
	}
	//else -> create it, push, and return it
	Ingredient* ingridient = new Ingredient(ingredient_name);
	m_ingredients.push_back(ingridient);
	return ingridient;
}

void Ingredients::update() {
	for (unsigned int i = 0; i < m_ingredients.size(); ++i) {
		m_ingredients[i]->pickBestSupplier();
	}
}

void Ingredients::print() const {
	std::ostringstream debugStr;
	debugStr << "***************** Ingredients ******************" << std::endl;
	for (unsigned int i = 0; i < m_ingredients.size(); ++i) {
		m_ingredients[i]->print();
	}
	debugStr << "**********************************************" << std::endl;
	CAppLogger::Instance().Log(debugStr, Poco::Message::PRIO_TRACE);
}






