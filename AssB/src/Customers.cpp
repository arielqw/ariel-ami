/*
 * Customers.cpp
 *
 *  Created on: Nov 17, 2013
 *      Author: amio
 */
#include "Poco/Logger.h"
#include "../include/Customers.h"

using Poco::Logger;


Customers::Customers() {
	// TODO Auto-generated constructor stub

}

Customers::~Customers() {
	// TODO Auto-generated destructor stub
}

std::vector<Customer*> Customers::detectCustomers(const ImgTools& image) const {

}

Customer& Customers::registerCustomer(const std::string& customer_name, const std::string& favorite_product,const std::string& isVIP) {
	Customer* customer;
	if(isVIP == "1"){
		customer = new VipCustomer(customer_name,favorite_product);
	}
	else{
		customer = new RegularCustomer(customer_name,favorite_product);
	}

	m_customers.push_back(customer);

	for (int i = 0; i < m_customers.size(); ++i) {

		Logger::get("log").debug(m_customers[i]->getFavoriteProduct());
	}

}

void Customers::saveCostumersCollage() {
	for (int i = 0; i < m_customers.size(); ++i) {

		m_customers[i]->getPhoto().show();
	}
}



