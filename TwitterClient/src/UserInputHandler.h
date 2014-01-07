/*
 * UserInputHandler.h
 *
 *  Created on: Jan 7, 2014
 *      Author: amio
 */

#ifndef USERINPUTHANDLER_H_
#define USERINPUTHANDLER_H_

#include <string>
#include "connectionHandler.h"
#include "ConnectFrame.h"
using namespace std;

class UserInputHandler {
public:
	UserInputHandler(ConnectionHandler connectionHandler);
	virtual ~UserInputHandler();

	void start();
	StompFrame* decodeMsg(const string& msgStr);
	void processMsg(StompFrame* frame);
};

#endif /* USERINPUTHANDLER_H_ */
