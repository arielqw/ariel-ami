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
#include <boost/thread.hpp>
#include <sstream>
#include "AppLogger.h"

class Protocol;

#include <string>
using namespace std;
class Client {
public:
	Client(Protocol& protocol);
	virtual ~Client();
	void start();
	bool connect(const string& host, unsigned short port);
	void disconnect();
	bool isConnected();
	void shutdown();
private:
	Protocol* _protocol;
	bool _isConnected;
	bool _shouldShutdown;
	ConnectionHandler* _pConnectionHanlder;
	void startListenning();
	boost::thread* _pServerResponseHandlerThread;
};

#endif /* CLIENT_H_ */
