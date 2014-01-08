/*
 * Utility.h
 *
 *  Created on: Jan 8, 2014
 *      Author: arielbar
 */

#ifndef UTILITY_H_
#define UTILITY_H_
#include <string>
#include <vector>

using namespace std;

class Utility {
public:
	Utility();
	virtual ~Utility();
	static void splitString(const string& str,char delimiter, vector<string>& output);

};

#endif /* UTILITY_H_ */
