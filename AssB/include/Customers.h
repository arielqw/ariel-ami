/*
 * Customers.h
 *
 *  Created on: Nov 17, 2013
 *      Author: amio
 */

#ifndef CUSTOMERS_H_
#define CUSTOMERS_H_
#include <vector>

#include "RegularCustomer.h"
#include "VipCustomer.h"
#include "ImgTools.h"
#include "AppLogger.h"

class Customers {
private:
	std::vector<Customer *> m_customers;
public:
	Customers();
	virtual ~Customers();
	std::vector<Customer* > detectCustomers(ImgTools& image);
	Customer& registerCustomer(const std::string& customer_name, const std::string& favorite_product,const std::string& isVIP);

	void saveCostumersCollage();
};

#endif /* CUSTOMERS_H_ */
