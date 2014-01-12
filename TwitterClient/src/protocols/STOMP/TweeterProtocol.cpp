/*
 * TweeterProtocol.cpp
 *
 *  Created on: Jan 8, 2014
 *      Author: arielbar
 */

#include "TweeterProtocol.h"

TweeterProtocol::TweeterProtocol() {
	// TODO Auto-generated constructor stub

}

TweeterProtocol::~TweeterProtocol() {
	// TODO Auto-generated destructor stub
}

bool TweeterProtocol::processUserInput(const string& inputMsg,string& outputMsg) {
    string buf; // Have a buffer string
    stringstream ss(inputMsg); // Insert the string into a stream
    vector<string> tokens; // Create vector to hold our words
    while (ss >> buf){
    	tokens.push_back(buf);		//splits with ' ' as delimiter
    }

    ostringstream stompInputMsg;

	if	(tokens[0] == "follow"){ 			//follow username
		stompInputMsg << "subscribe " << tokens[1];
	}
	else if	(tokens[0] == "unfollow"){ 		//unfollow username
		stompInputMsg << "unsubscribe " << tokens[1];
	}
	else if	(tokens[0] == "tweet" && inputMsg.size()>6){ 		//tweet msg
		stompInputMsg << "send " << _username << " " << inputMsg.substr(6);
	}
	else if	(tokens[0] == "stop"){
		stompInputMsg << "send server stop";
	}
	else if	(tokens[0] == "clients"){
		stompInputMsg << "send server clients";
	}
	else if	(tokens[0] == "stats"){
		stompInputMsg << "send server stats";
	}
	else
	{
		//login \ logout \ exit_client
		stompInputMsg << inputMsg;
	}

    return StompProtocol::processUserInput(stompInputMsg.str(), outputMsg);
}


