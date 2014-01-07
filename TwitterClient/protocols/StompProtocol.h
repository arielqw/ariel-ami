/*
 * StompProtocol.h
 *
 *  Created on: Jan 7, 2014
 *      Author: amio
 */

#ifndef STOMPPROTOCOL_H_
#define STOMPPROTOCOL_H_

#include "../include/Protocol.h"

class StompProtocol:Protocol {
public:
	StompProtocol();
	virtual ~StompProtocol();
	virtual void processMsg(const string& msg);
	virtual string processUserInput(const string& msg) = 0;
};

#endif /* STOMPPROTOCOL_H_ */
