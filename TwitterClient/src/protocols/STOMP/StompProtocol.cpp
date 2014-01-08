/*
 * StompProtocol.cpp
 *
 *  Created on: Jan 7, 2014
 *      Author: amio
 */

#include "StompProtocol.h"
#include <stdlib.h>
#include <sstream>
#include "../../../include/AppLogger.h"
StompProtocol::StompProtocol():_receipt(0) {
	// TODO Auto-generated constructor stub

}

StompProtocol::~StompProtocol() {
	// TODO Auto-generated destructor stub
}

void StompProtocol::chunkUpMsg(const string& str) {
	_msgChunks << str; //add chunk to msg
	if(str.length() > 1 && str.at(str.length()-2) == '\0'){ //when a full frame is saved process it
		processMsg();
	}
}

void StompProtocol::processMsg() {
	CAppLogger::Instance().Log("Full Chunk recived: "+_msgChunks.str(),Poco::Message::PRIO_DEBUG);
	vector<string> vec;
	Utility::splitString(_msgChunks.str(),'\n',vec);
	string command = vec[0];
	if		(command == "ERROR"){ 		CAppLogger::Instance().Log(vec[1].substr(9,vec[1].length()-2),Poco::Message::PRIO_INFORMATION); }
	else if	(command == "CONNECTED"){ 	CAppLogger::Instance().Log("Login Successfully",Poco::Message::PRIO_INFORMATION); }

}

bool StompProtocol::processUserInput(const string& inputMsg, string& outputMsg) {
	StompFrame* frame = NULL;

    string buf; // Have a buffer string
    stringstream ss(inputMsg); // Insert the string into a stream
    vector<string> tokens; // Create vector to hold our words
    while (ss >> buf){
    	tokens.push_back(buf);		//splits with ' ' as delimiter
    }

    if(tokens[0] == "login"){
    	if( _client->connect(tokens[1],atoi(tokens[2].c_str())) ){
        	frame = new ConnectFrame(tokens[1], atoi(tokens[2].c_str()), tokens[3], tokens[4]);
        	_receipt ++;
    	}
    }
    else if	(tokens[0] == "logout"){
    	frame = new DisconnectFrame(_receipt);
        return false;
    }

//    else if	(tokens[0] == "follow")    	frame = new SubscribeFrame(tokens[1]);
//    else if	(tokens[0] == "unfollow")	frame = new UnsubscribeFrame(tokens[1]);
//    else if	(tokens[0] == "tweet")		frame = new d(tokens[1]);
//    else if	(tokens[0] == "logout")		frame = new SendFrame(tokens[1]);
//    else if	(tokens[0] == "stop")		frame = new SendFrame(tokens[1]);
//    else if	(tokens[0] == "clients")	frame = new SendFrame(tokens[1]);
//    else if	(tokens[0] == "stats")		frame = new SendFrame(tokens[1]);
    if(frame == NULL) outputMsg = "INVALID";

    outputMsg = frame->toString();
    return false;
}
