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
			if (!_pConnectionHanlder->sendLine(msgToSend)) {
				std::cout << "Disconnected. Exiting...\n" << std::endl;
				break;
			}
		}

		if( shouldDisconnect ){
			CAppLogger::Instance().Log("got to should ",Poco::Message::PRIO_DEBUG);

			_pServerResponseHandlerThread->join(); //... waiting for disconnecting gracefully..
		}
//        if (!connectionHandler.sendLine(line)) {
//            std::cout << "Disconnected. Exiting...\n" << std::endl;
//            break;
//        }
//		// connectionHandler.sendLine(line) appends '\n' to the message. Therefor we send len+1 bytes.
//        std::cout << "Sent " << len+1 << " bytes to server" << std::endl;


        // We can use one of three options to read data from the server:
        // 1. Read a fixed number of characters
        // 2. Read a line (up to the newline character using the getline() buffered reader
        // 3. Read up to the null character
//        std::string answer;
//        // Get back an answer: by using the expected number of bytes (len bytes + newline delimiter)
//        // We could also use: connectionHandler.getline(answer) and then get the answer without the newline char at the end
//        if (!connectionHandler.getLine(answer)) {
//            std::cout << "Disconnected. Exiting...\n" << std::endl;
//            break;
//        }

//		len=answer.length();
//		// A C string must end with a 0 char delimiter.  When we filled the answer buffer from the socket
//		// we filled up to the \n char - we must make sure now that a 0 char is also present. So we truncate last character.
//        answer.resize(len-1);
//        std::cout << "Reply: " << answer << " " << len << " bytes " << std::endl << std::endl;
//        if (answer == "bye") {
//            std::cout << "Exiting...\n" << std::endl;
//            break;
//        }
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
    _isConnected = false;
    _pConnectionHanlder->close();
}

void Client::shutdown() {
	_shouldShutdown = true;
}

void Client::startListenning() {
	while(_isConnected){
		string incomingMessage;
		if (_pConnectionHanlder->getLine(incomingMessage)) //BLOCKING
		{
			_protocol->chunkUpMsg(incomingMessage);
		}
		else
		{
			break;
		}
	}
}




