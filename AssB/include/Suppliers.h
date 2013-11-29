/*
 * Suppliers.h
 *
 *  Created on: Nov 22, 2013
 *      Author: arielbar
 */

#ifndef SUPPLIERS_H_
#define SUPPLIERS_H_
#include "Supplier.h"
#include "AppLogger.h"
#include <vector>

/*
 * represents all the suppliers known to the coffeeshop
 */
class Suppliers {
private:
	vector< Supplier* > m_suppliers;
public:
	Suppliers();
	virtual ~Suppliers();

	bool add(const string& supplier_name,const string& ingredient_name,double price);
	Supplier* getSupplier(const string& name);
	bool updateSupplierIngredient(const string& supplier_name, string& ingredient_name, double price);

	void print() const;
};

#endif /* SUPPLIERS_H_ */
