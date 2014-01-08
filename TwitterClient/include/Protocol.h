/*
 * Protocol.h
 *
 *  Created on: Jan 7, 2014
 *      Author: amio
 */

#ifndef PROTOCOL_H_
#define PROTOCOL_H_

#include <string>
#include "Client.h"
#include "Utility.h"
#include <sstream>

class Client;

using namespace std;

class Protocol {
public:
	Protocol();
	virtual ~Protocol();
	virtual bool processUserInput(const string& inputMsg, string& outputMsg) = 0;
	void setClient(Client* client);
	virtual void chunkUpMsg(const string& str) = 0;
protected:
	Client* _client;
	virtual void processMsg() = 0;
	ostringstream _msgChunks;
};

#endif /* PROTOCOL_H_ */
