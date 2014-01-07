/*
 * Client.h
 *
 *  Created on: Jan 7, 2014
 *      Author: amio
 */

#ifndef CLIENT_H_
#define CLIENT_H_

#include "Protocol.h"
#include "connectionHandler.h"
class Protocol;

#include <string>
using namespace std;
class Client {
public:
	Client(Protocol& protocol);
	virtual ~Client();
	void start();
	bool connect(const string& host, unsigned short port);
	bool isConnected();
private:
	Protocol* _protocol;
	bool _isConnected;
	ConnectionHandler* _pConnectionHanlder;
};

#endif /* CLIENT_H_ */
