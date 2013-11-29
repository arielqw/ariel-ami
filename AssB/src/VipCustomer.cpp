/*
 * VipCustomer.cpp
 *
 *  Created on: Nov 17, 2013
 *      Author: amio
 */

#include "VipCustomer.h"

VipCustomer::VipCustomer(const string& customer_name,const string& favorite_product):Customer(customer_name,favorite_product) {
	

}

VipCustomer::~VipCustomer() {
	
}

double VipCustomer::computeProductPrice(double originalPrice) {
	return originalPrice*0.8;
}


