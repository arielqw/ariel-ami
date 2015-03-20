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
#include "imageloader.h"

#include <string>

/*
 * a class that represents a customer of the coffeeshop
 */
class Customer {
protected:
	const std::string _customer_name;
	const std::string _favoriteProduct;	//the customer's favorite product
	ImgTools _photo;	//the face image of the customer

public:

	Customer(const string& customer_name,const string& favoriteProduct);
	virtual ~Customer();

	//returns a product price customer - takes into account store fee and type of customer
	virtual double computeProductPrice(double originalPrice)=0;

	std::string getFavoriteProduct() const;

	ImgTools& getPhoto();

	const std::string getCustomerName() const {
		return _customer_name;
	}

};

#endif /* CUSTOMER_H_ */
