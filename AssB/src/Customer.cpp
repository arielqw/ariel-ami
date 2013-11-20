/*
 * Customer.cpp
 *
 *  Created on: Nov 17, 2013
 *      Author: amio
 */

#include "../include/Customer.h"

//Customer::Customer() {
//}

Customer::Customer(const string& customer_name,const string& favoriteProduct):
		_customer_name(customer_name),_favoriteProduct(favoriteProduct), _photo("faces/"+customer_name+"/"+customer_name+".tiff") {
}

Customer::~Customer() {
	// TODO Auto-generated destructor stub
}

std::string Customer::getFavoriteProduct() const {
	return _favoriteProduct;
}

ImgTools& Customer::getPhoto() {
	return _photo;
}




