/*
 * UnsubscribeFrame.cpp
 *
 *  Created on: Jan 8, 2014
 *      Author: arielbar
 */

#include "UnsubscribeFrame.h"

UnsubscribeFrame::UnsubscribeFrame(int id) :_id(id){
}

UnsubscribeFrame::~UnsubscribeFrame() {
	// TODO Auto-generated destructor stub
}

string UnsubscribeFrame::toString() {
	vector<pair<string,string> > vec;
	ostringstream id;
	id << _id;
	vec.push_back(make_pair("id",id.str()));
	return makeFrame("UNSUBSCRIBE",vec,"");
}


