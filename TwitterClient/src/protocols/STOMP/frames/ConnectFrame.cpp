/*
 * ConnectFrame.cpp
 *
 *  Created on: Jan 7, 2014
 *      Author: amio
 */

#include "ConnectFrame.h"


//ConnectFrame::ConnectFrame()
//{
//}

ConnectFrame::ConnectFrame(const string& hostIP, unsigned short port,
		const string& username, const string& password):_hostIP(hostIP),_port(port),_username(username),_password(password) {

}

ConnectFrame::~ConnectFrame() {
}

string ConnectFrame::toString() {
	vector<pair<string,string> > vec;
	vec.push_back(make_pair("accept-version","1.2"));
	vec.push_back(make_pair("host",_hostIP));
	return makeFrame("CONNECT",vec,"");
}


