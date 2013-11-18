/*
 * Customers.cpp
 *
 *  Created on: Nov 17, 2013
 *      Author: amio
 */

#include "../include/Customers.h"

Customers::Customers() {
	// TODO Auto-generated constructor stub

}

Customers::~Customers() {
	// TODO Auto-generated destructor stub
}

std::vector<Customer*> Customers::detectCustomers(const ImgTools& image) const {

}

Customer& Customers::registerCustomer(const std::string& customer_name, const std::string& favorite_product, bool isVIP) {
	Customer* customer;
	if(isVIP){
		customer = new VipCustomer(customer_name,favorite_product);
	}
	else{
		customer = new RegularCustomer(customer_name,favorite_product);
	}

	m_customers.push_back(customer);
}


