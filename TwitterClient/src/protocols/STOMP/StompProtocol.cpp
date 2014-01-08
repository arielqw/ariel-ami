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
StompProtocol::StompProtocol():_receipt(0),_subscriptionCounter(0) {
	// TODO Auto-generated constructor stub

}

StompProtocol::~StompProtocol() {
	// TODO Auto-generated destructor stub
}

void StompProtocol::chunkUpMsg(const string& str) {
	_msgChunks << str; //add chunk to msg
	if(str.length() > 1 && str.at(str.length()-2) == '\0'){ //when a full frame is saved process it
		processMsg();
		_msgChunks.str("");
	}
}

void StompProtocol::processMsg() {
	CAppLogger::Instance().Log("Full Chunk recived: "+_msgChunks.str(),Poco::Message::PRIO_DEBUG);
	vector<string> vec;
	Utility::splitString(_msgChunks.str(),'\n',vec);
	string command = vec[0];
	if		(command == "ERROR"){ 		CAppLogger::Instance().Log(vec[1].substr(9,vec[1].length()-2),Poco::Message::PRIO_INFORMATION); }
	else if	(command == "CONNECTED"){ 	CAppLogger::Instance().Log("Login Successfully",Poco::Message::PRIO_INFORMATION); }
	else if	(command == "RECEIPT"){		CAppLogger::Instance().Log(" RECIEVED RECEIPT. DISCONNECTING..",Poco::Message::PRIO_DEBUG); _client->disconnect();}

}

bool StompProtocol::processUserInput(const string& inputMsg, string& outputMsg) {
	bool shouldDisconnect = false;
	StompFrame* frame = NULL;

    string buf; // Have a buffer string
    stringstream ss(inputMsg); // Insert the string into a stream
    vector<string> tokens; // Create vector to hold our words
    while (ss >> buf){
    	tokens.push_back(buf);		//splits with ' ' as delimiter
    }

    if(tokens[0] == "login"){ //"login ip port username password"
    	if( _client->connect(tokens[1],atoi(tokens[2].c_str())) ){
        	frame = new ConnectFrame(tokens[1], atoi(tokens[2].c_str()), tokens[3], tokens[4]);
        	_receipt ++;
    	}
    }
    else if	(tokens[0] == "logout"){ //"logout"
    	//logout
    	frame = new DisconnectFrame(_receipt);
    	shouldDisconnect = true;
    }
    else if	(tokens[0] == "exit_client"){ //"exit_client"
    	//logout
    	if(_client->isConnected()){
        	frame = new DisconnectFrame(_receipt);
        	shouldDisconnect = true;
    	}
    	_client->shutdown();
    }
    else if	(tokens[0] == "send"){ //"send destination body"
    	frame = new SendFrame(tokens[1], tokens[2]);
    }
    else if	(tokens[0] == "subscribe"){ //"subscribe destination"
    	_subscriptions[tokens[1]]=_subscriptionCounter;
    	frame = new SubscribeFrame(tokens[1], _subscriptionCounter);
    	_subscriptionCounter++;
    }
    else if	(tokens[0] == "unsubscribe"){ //"subscribe destination"
    	map<string,int>::iterator it =_subscriptions.find(tokens[1]);

    	if( it == _subscriptions.end() ){ //not found
    		//todo: print not found msg
    	}
    	else{
        	frame = new UnsubscribeFrame(it->second);
        	_subscriptions.erase(it);
    	}
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
    return shouldDisconnect;
}
