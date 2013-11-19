/*
 * ImgTools.cpp
 *
 *  Created on: Nov 17, 2013
 *      Author: amio
 */

#include "../include/ImgTools.h"

ImgTools::ImgTools(const std::string& imageFileName):_loader(imageFileName){
	// TODO Auto-generated constructor stub
	ImageOperations oper;
	oper.rgb_to_greyscale(_loader.getImage(), _greyScaleImage);
}

ImgTools::~ImgTools() {
	// TODO Auto-generated destructor stub

}

void ImgTools::show() {
	//_loader.displayImage();
	//_greyScaleImage
    cv::imshow("My image", _greyScaleImage);
    cv::waitKey(5000);
}

cv::Mat& ImgTools::getImage(bool isColor)
{
	if (isColor)	return _loader.getImage();
	return _greyScaleImage;
}
