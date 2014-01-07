/*
 * StompProtocol.h
 *
 *  Created on: Jan 7, 2014
 *      Author: amio
 */

#ifndef STOMPPROTOCOL_H_
#define STOMPPROTOCOL_H_

#include "../../../include/Protocol.h"
#include "frames/ConnectFrame.h"
//#include "frames/DisconnectFrame.h"
//#include "frames/SendFrame.h"
//#include "frames/SubscribeFrame.h"
//TODO: add more

class StompProtocol: public Protocol {
public:
	StompProtocol();
	virtual ~StompProtocol();
	virtual string processUserInput(const string& msg);
	virtual void processMsg(const string& msg);
};

#endif /* STOMPPROTOCOL_H_ */
