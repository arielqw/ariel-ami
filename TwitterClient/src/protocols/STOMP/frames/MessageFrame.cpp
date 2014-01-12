/*
 * MessageFrame.cpp
 *
 *  Created on: Jan 10, 2014
 *      Author: amio
 */

#include "MessageFrame.h"

MessageFrame::MessageFrame(const string& unencodedchars) {

	_originalFrameMsg = unencodedchars;
	vector<string> vec;
	Utility::splitString(unencodedchars,'\n',vec);

	if (vec.size() < 3)		return;

	//get destination from msg
	unsigned int i = 1;
	for ( ; i<vec.size(); i++)
	{
		if (vec[i].size()>=11 && vec[i].substr(0,11) == "destination")
		{
			_destination = vec[i].substr(11);
			break;
		}
	}

	bool isNextStringBody = false;
	for ( ; i<vec.size(); i++)
	{
		if (vec[i].size() == 0)
		{
			isNextStringBody = true;
			break;
		}
	}

	if (!isNextStringBody)	return;

	stringstream ss;
	for ( ; i<vec.size(); i++)
	{
		ss << vec[i];
	}
	_msg = ss.str();

}

MessageFrame::~MessageFrame() {
	// TODO Auto-generated destructor stub
}

string MessageFrame::toString()
{
	return _originalFrameMsg;
}

string& MessageFrame::getMsg() {
	return _msg;
}

string& MessageFrame::getDestination() {
	return _destination;
}


