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

	string dest("destination");
	string time("time");

	//get destination from msg
	unsigned int i = 1;
	for ( ; i<vec.size() && vec[i].size()>0; i++)
	{
		if (vec[i].size()>dest.size() && vec[i].substr(0,dest.size()) == dest)
		{
			_destination = vec[i].substr(dest.size()+1);
		}
		else if (vec[i].size()>time.size() && vec[i].substr(0,time.size()) == time)
		{
			_time = vec[i].substr(time.size()+1);
		}

	}

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

string& MessageFrame::getTime() {
	return _time;
}



