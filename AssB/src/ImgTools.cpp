/*
 * ImgTools.cpp
 *
 *  Created on: Nov 17, 2013
 *      Author: amio
 */

#include "ImgTools.h"
#include <iostream>
ImgTools::ImgTools(const std::string& imageFileName):_loader(imageFileName),_greyScaleImage(){
	
	ImageOperations oper;
	//make & save a greyscale version of the image
	oper.rgb_to_greyscale(_loader.getImage(), _greyScaleImage);
}

ImgTools::~ImgTools() {
	

}

void ImgTools::show() const{
    cv::imshow("My image", _greyScaleImage);
    cv::waitKey(5000);
}

cv::Mat& ImgTools::getImage(bool isColor)
{
	if (isColor)	return _loader.getImage();
	return _greyScaleImage;
}

bool ImgTools::compareAFace(const cv::Rect& rect, const ImgTools& face) const {

	//if the sizes dont match then we can return false immediatly
	if( (rect.height != face._greyScaleImage.rows) || (rect.width != face._greyScaleImage.cols)){
		return false;
	}

	//iterate pixel by pixel - if all match return true
	for (int i = 0; i < rect.width; ++i) {
		for (int j = 0; j < rect.height; ++j) {
			if( face._greyScaleImage.ptr<cv::Point_<uchar> >(j,i)->x != _greyScaleImage.ptr<cv::Point_<uchar> >(j+rect.y,i+rect.x)->x ){
				return false;	//one pixel doesnt match - no match
			}
		}
	}
    return true;
}

