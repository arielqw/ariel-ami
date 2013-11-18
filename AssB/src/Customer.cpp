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
	//TODO: read images and load it to photo.
	//ImageLoader loader("faces/"+customer_name+"/"+customer_name+".tiff");
	//loader.getImage();
	//_photo.



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



