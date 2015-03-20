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

	//returns the matching supplier. creates it if it doesnt exist
	Supplier* getSupplier(const string& name);

	void print() const;
};

#endif /* SUPPLIERS_H_ */
