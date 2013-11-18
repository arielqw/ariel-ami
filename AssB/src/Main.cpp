//for opencv
#include "../include/imageloader.h"
#include "../include/imageoperations.h"

//for poco logger
#include "Poco/Logger.h"
#include "Poco/PatternFormatter.h"
#include "Poco/FormattingChannel.h"
#include "Poco/ConsoleChannel.h"
#include "Poco/FileChannel.h"
#include "Poco/Message.h"

#include <iostream>

#include "../include/CoffeeManager.h"

using namespace cv;

using Poco::Logger;
using Poco::PatternFormatter;
using Poco::FormattingChannel;
using Poco::ConsoleChannel;
using Poco::FileChannel;
using Poco::Message;

int main(int argc, char **argv)
{
	//TODO: throw error if args <4 (first = home path)
	CoffeeManager manager;

	manager.start( std::string(argv[1]) , std::string(argv[2]) , std::string(argv[3]) );

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

        return 1;

        img1.displayImage();

        ImageOperations opr;

        ImageLoader img2(100,100);
        opr.resize(img1.getImage(),img2.getImage());
        img2.displayImage();

        ImageLoader img3(img1.getImage().size().height, img1.getImage().size().width * 2);
        opr.copy_paste_image(img1.getImage(),img3.getImage(),0);
        opr.copy_paste_image(img1.getImage(),img3.getImage(),img1.getImage().size().width);
        img3.displayImage();
//logger test:
    	// set up two channel chains - one to the
    	// console and the other one to a log file.
    	FormattingChannel* pFCConsole = new FormattingChannel(new PatternFormatter("%s: %p: %t"));
    	pFCConsole->setChannel(new ConsoleChannel);
    	pFCConsole->open();

    	FormattingChannel* pFCFile = new FormattingChannel(new PatternFormatter("%Y-%m-%d %H:%M:%S.%c %N[%P]:%s:%q:%t"));
    	pFCFile->setChannel(new FileChannel("sample.log"));
    	pFCFile->open();

    	// create two Logger objects - one for
    	// each channel chain.
    	Logger& consoleLogger = Logger::create("ConsoleLogger", pFCConsole, Message::PRIO_INFORMATION);
    	Logger& fileLogger    = Logger::create("FileLogger", pFCFile, Message::PRIO_WARNING);

    	// log some messages
    	consoleLogger.error("An error message");
    	fileLogger.error("An error message");

    	consoleLogger.warning("A warning message");
    	fileLogger.error("A warning message");

    	consoleLogger.information("An information message");
    	fileLogger.information("An information message");

    	poco_information(consoleLogger, "Another informational message");
    	poco_warning_f2(consoleLogger, "A warning message with arguments: %d, %d", 1, 2);

    	Logger::get("ConsoleLogger").error("Another error message");
}
