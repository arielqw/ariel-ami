/*
 * StompFrame.h
 *
 *  Created on: Jan 7, 2014
 *      Author: amio
 */

#ifndef STOMPFRAME_H_
#define STOMPFRAME_H_

#include <string>
#include <vector>
//#include <stdio.h>

using namespace std;

class StompFrame {
public:
	StompFrame();
	virtual ~StompFrame();
	virtual string toString() = 0;

protected:
	string makeFrame(const string& header, vector<pair<string,string> > pairs,const string& body);


};

#endif /* STOMPFRAME_H_ */
