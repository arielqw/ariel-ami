/*
 * Client.h
 *
 *  Created on: Jan 7, 2014
 *      Author: amio
 */

#ifndef CLIENT_H_
#define CLIENT_H_
#include "Protocol.h"
#include "UserInputHandler.h"

class Client {
public:
	Client(Protocol protocol,UserInputHandler userInputHandler);
	virtual ~Client();
	void start();
private:
	Protocol* _protocol;
	UserInputHandler* _userInputHandler;
	bool _isConnected;
	void connect();
	void start();
};

#endif /* CLIENT_H_ */
