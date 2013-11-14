#ifndef IMAGE_LOADER_H
#define IMAGE_LOADER_H

#include <opencv2/highgui/highgui.hpp>
#include <opencv2/core/core.hpp>
#include <opencv2/imgproc/imgproc.hpp>
#include <string>

class ImageLoader
{
public:
    /** create a new image with the size=width*height */
    ImageLoader(int width, int height);
    /** import an image from a file location */
    ImageLoader(const std::string& fileName);
    /** display an image on screen */
    void displayImage();
    /** matrix getter */
    cv::Mat& getImage();
    /** save image to filename */
    void saveImage(const std::string& filename);

    virtual ~ImageLoader();

private:
    cv::Mat m_image;
};
#endif
