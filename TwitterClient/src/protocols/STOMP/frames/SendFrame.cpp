/*
 * SendFrame.cpp
 *
 *  Created on: Jan 7, 2014
 *      Author: amio
 */

#include "SendFrame.h"


SendFrame::SendFrame(const string& destination, const string& body):_destination(destination),_body(body) {
}

SendFrame::~SendFrame() {
	// TODO Auto-generated destructor stub
}

string SendFrame::toString() {
	vector<pair<string,string> > vec;
	vec.push_back(make_pair("destination",_destination));
	return makeFrame("SEND",vec,_body);
}


