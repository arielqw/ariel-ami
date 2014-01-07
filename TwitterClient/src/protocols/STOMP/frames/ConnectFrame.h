/*
 * ConnectFrame.h
 *
 *  Created on: Jan 7, 2014
 *      Author: amio
 */

#ifndef CONNECTFRAME_H_
#define CONNECTFRAME_H_

#include "StompFrame.h"
#include <string>
using namespace std;

class ConnectFrame:public StompFrame {
public:

	ConnectFrame(const string& hostIP, unsigned short port, const string& username, const string& password);
	virtual ~ConnectFrame();
	virtual string toString();

private:
	string _hostIP;
	unsigned short _port;
	string _username;
	string _password;
};

#endif /* CONNECTFRAME_H_ */
