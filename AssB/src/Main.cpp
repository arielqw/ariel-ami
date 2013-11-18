#include "../include/LoggerWrapper.h"
//for opencv
#include "../include/imageloader.h"
#include "../include/imageoperations.h"


#include <iostream>

#include "../include/CoffeeManager.h"

using namespace cv;


int main(int argc, char **argv)
{
	LoggerWrapper log;
	log.init();

	Logger::get("ConsoleLogger").error("ami");

	//TODO: throw error if args <4 (first = home path)
	CoffeeManager manager;

	manager.start( std::string(argv[1]) , std::string(argv[2]) , std::string(argv[3]) );

	/*
//opencv test:
        ImageLoader img1("Lenna.png");


        Mat greyscaleMat;
        ImageOperations imgoper;
        imgoper.rgb_to_greyscale(img1.getImage(), greyscaleMat);

        Point3_<uchar>* p = img1.getImage().ptr<Point3_<uchar> >(0,0);

        std::cout << (int)p->x << " " << (int)p->y << " " << (int)p->z << std::endl;

        Point_<uchar>* q = greyscaleMat.ptr<Point_<uchar> >(0,0);
        std::cout << (int)q->x << " " << (int)q->y << " "<< std::endl;



        imshow(string("ami"), greyscaleMat);
        waitKey(5000);



        img1.displayImage();

        ImageOperations opr;

        ImageLoader img2(100,100);
        opr.resize(img1.getImage(),img2.getImage());
        img2.displayImage();

        ImageLoader img3(img1.getImage().size().height, img1.getImage().size().width * 2);
        opr.copy_paste_image(img1.getImage(),img3.getImage(),0);
        opr.copy_paste_image(img1.getImage(),img3.getImage(),img1.getImage().size().width);
        img3.displayImage();

	 */
    	return 1;
}
