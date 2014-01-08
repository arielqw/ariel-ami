/*
 * SubscribeFrame.cpp
 *
 *  Created on: Jan 7, 2014
 *      Author: amio
 */

#include "SubscribeFrame.h"

SubscribeFrame::SubscribeFrame(const string& destination, int id):_destination(destination),_id(id) {
}

SubscribeFrame::~SubscribeFrame() {
	// TODO Auto-generated destructor stub
}

string SubscribeFrame::toString() {
	vector<pair<string,string> > vec;
	vec.push_back(make_pair("destination",_destination));
	ostringstream id;
	id << _id;
	vec.push_back(make_pair("id",id.str()));
	return makeFrame("SUBSCRIBE",vec,"");
}


