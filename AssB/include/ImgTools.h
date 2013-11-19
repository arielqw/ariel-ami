/*
 * ImgTools.h
 *
 *  Created on: Nov 17, 2013
 *      Author: amio
 */

#ifndef IMGTOOLS_H_
#define IMGTOOLS_H_

#include "imageloader.h"
#include "imageoperations.h"

class ImgTools {
public:
	ImgTools(const std::string& imageFileName);
	virtual ~ImgTools();

	void show();

	cv::Mat& getImage(bool isColor);

private:
	ImageLoader _loader;
	cv::Mat _greyScaleImage;
};

#endif /* IMGTOOLS_H_ */
