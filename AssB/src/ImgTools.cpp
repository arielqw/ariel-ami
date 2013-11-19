/*
 * ImgTools.cpp
 *
 *  Created on: Nov 17, 2013
 *      Author: amio
 */

#include "../include/ImgTools.h"
#include <iostream>
ImgTools::ImgTools(const std::string& imageFileName):_loader(imageFileName){
	// TODO Auto-generated constructor stub
	ImageOperations oper;
	oper.rgb_to_greyscale(_loader.getImage(), _greyScaleImage);
}

ImgTools::~ImgTools() {
	// TODO Auto-generated destructor stub

}

void ImgTools::show() const{
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

bool ImgTools::compareAFace(const cv::Rect& rect, const ImgTools& face) const {

	if( (rect.height != face._greyScaleImage.rows) || (rect.width != face._greyScaleImage.cols)){
		return false;
	}

	for (int i = 0; i < rect.width; ++i) {
		for (int j = 0; j < rect.height; ++j) {
			if( face._greyScaleImage.ptr<cv::Point_<uchar> >(j,i)->x != _greyScaleImage.ptr<cv::Point_<uchar> >(j+rect.y,i+rect.x)->x ){
				return false;
			}
		}
	}
    //cv::Point_<uchar>* q = _greyScaleImage.ptr<cv::Point_<uchar> >(0,0);


    return true;
}

