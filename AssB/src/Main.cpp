
//for opencv
#include "../include/imageloader.h"
#include "../include/imageoperations.h"


#include <iostream>

#include "../include/CoffeeManager.h"

using namespace cv;


int main(int argc, char **argv)
{
	if (argc < 5)
	{
		//TODO: throw error if args <5 (first = home path)
		cout << "not enough arguments. exiting..." << endl;
		return 0;
	}

	CoffeeManager manager;

	manager.start( std::string(argv[1]), std::string(argv[2]) , std::string(argv[3]) , std::string(argv[4]) );

	return 1;
}
