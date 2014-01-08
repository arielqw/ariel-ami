/*
 * DisconnectFrame.cpp
 *
 *  Created on: Jan 7, 2014
 *      Author: amio
 */

#include "DisconnectFrame.h"

DisconnectFrame::DisconnectFrame(int receipt):_currentReceipt(receipt) {
	// TODO Auto-generated constructor stub

}

DisconnectFrame::~DisconnectFrame() {
	// TODO Auto-generated destructor stub
}

string DisconnectFrame::toString() {
	vector<pair<string,string> > vec;
	ostringstream recipt;
	recipt << _currentReceipt;
	vec.push_back(make_pair("receipt",recipt.str()));
	return makeFrame("DISCONNECT",vec,"");

}


