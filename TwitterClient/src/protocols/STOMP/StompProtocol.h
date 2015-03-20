/*
 * StompProtocol.h
 *
 *  Created on: Jan 7, 2014
 *      Author: amio
 */

#ifndef STOMPPROTOCOL_H_
#define STOMPPROTOCOL_H_

#include "../../../include/Protocol.h"
#include <vector>
#include "frames/ConnectFrame.h"
#include "frames/DisconnectFrame.h"
#include "frames/SendFrame.h"
#include <map>
#include "frames/SubscribeFrame.h"
#include "frames/UnsubscribeFrame.h"
#include "frames/MessageFrame.h"

//TODO: add more

class StompProtocol: public Protocol {
public:
	StompProtocol();
	virtual ~StompProtocol();
	virtual bool processUserInput(const string& inputMsg, string& outputMsg);
	virtual char getDelimiter();
	virtual void processMsg(const string& msg);
	//void chunkUpMsg(const string& str);
	virtual void fixMsg(string& msg);	//corrects diversions from protocol

protected:
	string _username;
private:
	int _receipt;
	int _subscriptionCounter;
	map<string,int> _subscriptions;
};

#endif /* STOMPPROTOCOL_H_ */
