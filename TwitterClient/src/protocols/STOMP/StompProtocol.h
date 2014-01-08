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

//#include "frames/SendFrame.h"
//#include "frames/SubscribeFrame.h"
//TODO: add more

class StompProtocol: public Protocol {
public:
	StompProtocol();
	virtual ~StompProtocol();
	virtual bool processUserInput(const string& inputMsg, string& outputMsg);
	void chunkUpMsg(const string& str);
protected:
	virtual void processMsg();
private:
	int _receipt;
};

#endif /* STOMPPROTOCOL_H_ */
