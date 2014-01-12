/*
 * Client.cpp
 *
 *  Created on: Jan 7, 2014
 *      Author: amio
 */

#include "../include/Client.h"


Client::Client(Protocol& protocol):_protocol(&protocol),_isConnected(false),_shouldShutdown(false){
	protocol.setClient(this);
}
Client::~Client() {
	// TODO Auto-generated destructor stub
}

void Client::start() {

    while (!_shouldShutdown) {
        const short bufsize = 1024;
        char buf[bufsize];
        std::cin.getline(buf, bufsize);
        string userInputMsg(buf);

        string msgToSend;
        bool shouldDisconnect = _protocol->processUserInput(userInputMsg, msgToSend);

		if(_isConnected && msgToSend != "INVALID"){
			if (!_pConnectionHanlder->sendString(msgToSend)) {
				std::cout << "Disconnected. Exiting...\n" << std::endl;
				break;
			}
		}

		if( shouldDisconnect ){
			CAppLogger::Instance().Log("got to should ",Poco::Message::PRIO_DEBUG);

			_pServerResponseHandlerThread->join(); //... waiting for disconnecting gracefully..
		}

    }
}

bool Client::connect(const string& host, unsigned short port) {
    _pConnectionHanlder = new ConnectionHandler(host, port);
    if (!_pConnectionHanlder->connect()) {
        std::cerr << "Could not connect to server. Check your Internet connection, IP and port." << std::endl;
        return false;
    }
    _isConnected = true;
    _pServerResponseHandlerThread = new boost::thread(&Client::startListenning, this);
    //todo: delete it after dc
    return true;
}

bool Client::isConnected() {
	return _isConnected;
}

void Client::disconnect() {
	CAppLogger::Instance().Log("Disconnecting... ",Poco::Message::PRIO_DEBUG);
    _isConnected = false;
    _pConnectionHanlder->close();
    delete _pConnectionHanlder;
}

void Client::shutdown() {
	_shouldShutdown = true;
}

void Client::startListenning() {
	while(_isConnected){
		string incomingMessage;
		if (_pConnectionHanlder->getFrameAscii(incomingMessage,_protocol->getDelimiter())) //BLOCKING
		{
			_protocol->fixMsg(incomingMessage);
			_protocol->processMsg(incomingMessage);
		}
		else
		{
			//if there is a problem with receiving
			break;
		}
	}
	CAppLogger::Instance().Log("Ending tcp listener thread",Poco::Message::PRIO_DEBUG);

}




