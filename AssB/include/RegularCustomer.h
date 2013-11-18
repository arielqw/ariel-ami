/*
 * RegularCustomer.h
 *
 *  Created on: Nov 17, 2013
 *      Author: amio
 */

#ifndef REGULARCUSTOMER_H_
#define REGULARCUSTOMER_H_

#include "Customer.h"

class RegularCustomer: public Customer {
public:
	RegularCustomer();
	virtual ~RegularCustomer();
	double computeProductPrice(double originalPrice);
};

#endif /* REGULARCUSTOMER_H_ */
