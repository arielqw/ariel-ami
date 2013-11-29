/*
 * Suppliers.cpp
 *
 *  Created on: Nov 22, 2013
 *      Author: arielbar
 */

#include "Suppliers.h"


Suppliers::Suppliers():m_suppliers() {
	

}

Suppliers::~Suppliers() {
	
	for (std::vector<Supplier*>::iterator it = m_suppliers.begin(); it != m_suppliers.end(); ++it){
		delete * it;
	}
	m_suppliers.clear();
}

bool Suppliers::add(const string& supplier_name, const string& ingredient_name,
		double price) {
	return true;
}


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
	std::ostringstream debugStr;
	debugStr <<  "***************** Suppliers ******************" << endl;
	for (unsigned int i = 0; i < m_suppliers.size(); ++i) {
		debugStr << m_suppliers[i]->getName() << std::endl;
		m_suppliers[i]->print();
	}
	debugStr << "**********************************************" << endl;
	CAppLogger::Instance().Log(debugStr, Poco::Message::PRIO_TRACE);
}



