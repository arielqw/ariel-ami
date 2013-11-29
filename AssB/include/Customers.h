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

/*
 * a class that represents all the customers of the coffeeshop
 */
class Customers {
private:
	std::vector<Customer *> m_customers;
public:
	Customers();
	virtual ~Customers();

	//fills the vector with the customers found on the photo
	void detectCustomers(ImgTools& image,std::vector<Customer*>& foundCustomers);

	// register a new customer to the system
	void registerCustomer(const std::string& customer_name, const std::string& favorite_product,const std::string& isVIP);

	//produce a collage of from all the customers' images and save it to a file
	void saveCostumersCollage();
};

#endif /* CUSTOMERS_H_ */
