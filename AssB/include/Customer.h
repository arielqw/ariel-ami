/*
 * Customer.h
 *
 *  Created on: Nov 17, 2013
 *      Author: amio
 */

#ifndef CUSTOMER_H_
#define CUSTOMER_H_
#include "ImgTools.h"
#include <string>

class Customer {
protected:
	std::string _favoriteProduct;
	ImgTools* photo;

public:
	Customer();
	virtual ~Customer();
	virtual double computeProductPrice(double originalPrice)=0;
	std::string getFavoriteProduct() const;
};

#endif /* CUSTOMER_H_ */
