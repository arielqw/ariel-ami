/*
 * RegularCustomer.cpp
 *
 *  Created on: Nov 17, 2013
 *      Author: amio
 */

#include "RegularCustomer.h"

//RegularCustomer::RegularCustomer()
//{
//}

RegularCustomer::RegularCustomer(const string& customer_name,const string& favorite_product):Customer(customer_name,favorite_product) {
	
}
RegularCustomer::~RegularCustomer() {
	
}

double RegularCustomer::computeProductPrice(double originalPrice) {
	return originalPrice;
}


