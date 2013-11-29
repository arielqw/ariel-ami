/*
 * RegularCustomer.h
 *
 *  Created on: Nov 17, 2013
 *      Author: amio
 */

#ifndef REGULARCUSTOMER_H_
#define REGULARCUSTOMER_H_

#include "Customer.h"

/*
 * a type of customer
 */
class RegularCustomer: public Customer {
public:
	//RegularCustomer();
	RegularCustomer(const string& customer_name,const string& favorite_product);
	virtual ~RegularCustomer();
	double computeProductPrice(double originalPrice);
};

#endif /* REGULARCUSTOMER_H_ */
