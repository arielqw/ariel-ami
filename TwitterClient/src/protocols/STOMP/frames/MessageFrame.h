/*
 * MessageFrame.h
 *
 *  Created on: Jan 10, 2014
 *      Author: amio
 */

#ifndef MESSAGEFRAME_H_
#define MESSAGEFRAME_H_

#include <sstream>
#include "../../../../include/AppLogger.h"
#include "../../../../include/Utility.h"
#include "StompFrame.h"
using namespace std;

class MessageFrame: public StompFrame {
public:
	MessageFrame(const string& unencodedchars);
	virtual ~MessageFrame();

	virtual string toString();

	string& getMsg();
	string& getDestination();

private:
	string _msg;
	string _destination;
	string _originalFrameMsg;

};

#endif /* MESSAGEFRAME_H_ */
