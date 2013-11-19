/*
 * Customers.cpp
 *
 *  Created on: Nov 17, 2013
 *      Author: amio
 */
#include "../include/Customers.h"

using Poco::Logger;


Customers::Customers() {
	// TODO Auto-generated constructor stub

}

Customers::~Customers() {
	// TODO Auto-generated destructor stub
}

void Customers::detectCustomers(ImgTools& image,std::vector<Customer*>& foundCustomers) {

	cv::CascadeClassifier face_cascade("haarcascade_frontalface_alt.xml");
	std::vector<cv::Rect> faces;
	face_cascade.detectMultiScale( image.getImage(false), faces, 1.1, 2, 0|CV_HAAR_SCALE_IMAGE );


	for (int i = 0; i < faces.size(); ++i) {
		bool customerFound = false;

		for (int j = 0; !customerFound && j < m_customers.size(); ++j) {
			if( image.compareAFace(faces[i] , m_customers[j]->getPhoto()) ){
				foundCustomers.push_back(m_customers[j]);
				customerFound = true;
			}
		}
	}
	//TODO: check if the rects contain faces of customers

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
}

void Customers::saveCostumersCollage() {
	for (int i = 0; i < m_customers.size(); ++i) {

		//m_customers[i]->getPhoto().show();
	}
}



