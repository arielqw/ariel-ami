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

/*
 * this class represents a photo and gives utils for face recognition
 */
class ImgTools {
public:
	//gets an image
	ImgTools(const std::string& imageFileName);
	virtual ~ImgTools();

	//show the image on screen
	void show() const;

	//get image in greyscale or in color
	cv::Mat& getImage(bool isColor);

	//gets a face and a rectangle and checks if the face is in the rectangle in this image
	bool compareAFace(const cv::Rect& rect, const ImgTools& face) const;
private:
	ImageLoader _loader;	//the original color image
	cv::Mat _greyScaleImage;	//a greyscale version for faster detection
};

#endif /* IMGTOOLS_H_ */
