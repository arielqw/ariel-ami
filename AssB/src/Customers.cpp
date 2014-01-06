/*
 * Customers.cpp
 *
 *  Created on: Nov 17, 2013
 *      Author: amio
 */
#include "Customers.h"

using Poco::Logger;


Customers::Customers():m_customers() {
}

Customers::~Customers() {
	for (std::vector<Customer*>::iterator it = m_customers.begin(); it != m_customers.end(); ++it){
		delete * it;
	}
	m_customers.clear();
}

void Customers::detectCustomers(ImgTools& image,std::vector<Customer*>& foundCustomers) {

	//load face detection preferences from a file

	//cv::CascadeClassifier face_cascade("/usr/local/share/OpenCV/haarcascades/haarcascade_frontalface_alt.xml");
	//cv::CascadeClassifier face_cascade("/usr/share/OpenCV/haarcascades/haarcascade_frontalface_alt.xml");
	cv::CascadeClassifier face_cascade("haarcascade_frontalface_alt.xml");
	std::vector<cv::Rect> faces;
	face_cascade.detectMultiScale( image.getImage(false), faces, 1.1, 2, 0|CV_HAAR_SCALE_IMAGE );

	//cross detected faces with the customers' faces and push the matching faces to the vector
	for (unsigned int i = 0; i < faces.size(); ++i) {
		bool customerFound = false;

		for (unsigned int j = 0; !customerFound && j < m_customers.size(); ++j) {
			if( image.compareAFace(faces[i] , m_customers[j]->getPhoto()) ){
				foundCustomers.push_back(m_customers[j]);
				customerFound = true;
			}
		}
	}

}




void Customers::registerCustomer(const std::string& customer_name, const std::string& favorite_product,const std::string& isVIP) {
	Customer* customer;
	if(isVIP == "1"){
		customer = new VipCustomer(customer_name,favorite_product);
	}
	else{
		customer = new RegularCustomer(customer_name,favorite_product);
	}

	m_customers.push_back(customer);
}

void Customers::saveCustomersCollage() {
	ImageOperations photoshop;

	int lowestHeight 	=-1;
	int photo_height 	= 0;

	//getting lowest height for collage dimentions
	for (unsigned int i = 0; i < m_customers.size(); ++i) {
		photo_height = m_customers[i]->getPhoto().getImage(true).rows;
		if( (lowestHeight == -1) || photo_height < lowestHeight){
			lowestHeight = photo_height;
		}
	}

	//get desired canvas width
	int canvas_width =0;
	for (unsigned int i = 0; i < m_customers.size(); ++i) {
		cv::Mat img = m_customers[i]->getPhoto().getImage(false);
		canvas_width += ((int)( ( (double)lowestHeight) * ( ( (double)img.cols)/( (double)img.rows) ) ));
	}

	//1.create a blank image
	cv::Mat collage(lowestHeight,canvas_width,CV_8UC3,cv::Scalar(255,255,255));

	int xPosition =0;

	//2. paste each customer image to it
	for (unsigned int i = 0; i < m_customers.size(); ++i) {
		cv::Mat photo = m_customers[i]->getPhoto().getImage(true);
		int proportionalWidth = lowestHeight*(photo.cols/photo.rows);

		cv::Mat resizedImg(lowestHeight,proportionalWidth,CV_8UC3,cv::Scalar(255,255,255));

		photoshop.resize( m_customers[i]->getPhoto().getImage(true),resizedImg );
		photoshop.copy_paste_image(resizedImg,collage,xPosition);
		xPosition += proportionalWidth;
	}

	//3. write to file 'collage.tiff'
    imwrite("collage.tiff", collage);

}



