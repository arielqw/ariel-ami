#ifndef IMAGE_OPERATIONS_H
#define IMAGE_OPERATIONS_H

#include <opencv2/highgui/highgui.hpp>
#include <opencv2/core/core.hpp>
#include <opencv2/imgproc/imgproc.hpp>

class ImageOperations
{
public:
    /** Convert src from a color rgb picture to a greyscales picture. The result is stored inside dst */
    void rgb_to_greyscale(const cv::Mat& src, cv::Mat& dst);
    /** Copy image src and paste it inside image dst at location (xLocation,0) */
    void copy_paste_image(const cv::Mat& src, cv::Mat& dst, int xLocation);
    /** Resize original picture into the dimension of image destination */
    void resize(const cv::Mat& src, cv::Mat& dst);
};

#endif
