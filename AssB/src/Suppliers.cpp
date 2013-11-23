/*
 * Suppliers.cpp
 *
 *  Created on: Nov 22, 2013
 *      Author: arielbar
 */

#include "../include/Suppliers.h"
#include <iostream>
Suppliers::Suppliers() {
	// TODO Auto-generated constructor stub

}

Suppliers::~Suppliers() {
	// TODO Auto-generated destructor stub
	for (unsigned int i = 0; i < m_suppliers.size(); ++i) {
			if(m_suppliers[i] != 0){
				delete m_suppliers[i];
			}
			m_suppliers[i] =0;
	}
}

bool Suppliers::add(const string& supplier_name, const string& ingredient_name,
		double price) {
	return true;
}

//TODO: check if can use impletments to avoid copy code..
Supplier* Suppliers::getSupplier(const string& name) {
	//if ingredient exists -> return it
	for (unsigned int i = 0; i < m_suppliers.size(); ++i) {
		if(name == m_suppliers[i]->getName()){
			return m_suppliers[i];
		}
	}
	//else -> create it, push, and return it
	Supplier* supplier = new Supplier(name);
	m_suppliers.push_back(supplier);
	return supplier;
}

bool Suppliers::updateSupplierIngredient(const string& supplier_name,
		string& ingredient_name, double price) {
	return true;
}

void Suppliers::print() const {
	std::cout << "***************** Suppliers ******************" << std::endl;
	for (unsigned int i = 0; i < m_suppliers.size(); ++i) {
		std::cout<< m_suppliers[i]->getName() << ": "<<std::endl;
		m_suppliers[i]->print();
		std::cout  << std::endl;
	}
	std::cout << "**********************************************" << std::endl;
}



