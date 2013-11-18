/*
 * VipCustomer.h
 *
 *  Created on: Nov 17, 2013
 *      Author: amio
 */

#ifndef VIPCUSTOMER_H_
#define VIPCUSTOMER_H_

#include "../include/Customer.h"

class VipCustomer: public Customer {
public:
	VipCustomer();
	virtual ~VipCustomer();
	double computeProductPrice(double originalPrice);
};

#endif /* VIPCUSTOMER_H_ */
