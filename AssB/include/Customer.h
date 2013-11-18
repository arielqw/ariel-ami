/*
 * Customer.h
 *
 *  Created on: Nov 17, 2013
 *      Author: amio
 */

#ifndef CUSTOMER_H_
#define CUSTOMER_H_
#include "ImgTools.h"
#include "UniCoffeeShop.h"

#include <string>

class Customer {
protected:
	const std::string _customer_name;
	const std::string _favoriteProduct;
	ImgTools* _photo;

public:
	//Customer();
	Customer(const string& customer_name,const string& favoriteProduct);
	virtual ~Customer();
	virtual double computeProductPrice(double originalPrice)=0;
	std::string getFavoriteProduct() const;

};

#endif /* CUSTOMER_H_ */
