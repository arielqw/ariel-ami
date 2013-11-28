/*
 * VipCustomer.h
 *
 *  Created on: Nov 17, 2013
 *      Author: amio
 */

#ifndef VIPCUSTOMER_H_
#define VIPCUSTOMER_H_

#include "Customer.h"

class VipCustomer: public Customer {
public:
	VipCustomer(const string& customer_name,const string& favorite_product);
	virtual ~VipCustomer();
	double computeProductPrice(double originalPrice);
};

#endif /* VIPCUSTOMER_H_ */
