/*
 * Customers.h
 *
 *  Created on: Nov 17, 2013
 *      Author: amio
 */

#ifndef CUSTOMERS_H_
#define CUSTOMERS_H_
#include <vector>
#include "Customer.h"
#include "ImgTools.h"

class Customers {
private:
	std::vector<Customer *> m_customers;
public:
	Customers();
	virtual ~Customers();
	std::vector<Customer* > detectCustomers(const ImgTools& image) const;
	Customer& registerCustomer(const std::string& customer_name, const std::string& favorite_product,bool isVIP);
};

#endif /* CUSTOMERS_H_ */
