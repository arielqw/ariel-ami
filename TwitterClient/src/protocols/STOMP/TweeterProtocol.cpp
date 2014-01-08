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


	if	(tokens[0] == "follow"){ //follow username
		return StompProtocol::processUserInput("subscribe "+tokens[1],outputMsg);
	}
	else if	(tokens[0] == "unfollow"){ //unfollow username
		return StompProtocol::processUserInput("unsubscribe "+tokens[1],outputMsg);
	}
	else if	(tokens[0] == "tweet"){ //tweet msg
		return StompProtocol::processUserInput("send "+_username+" "+tokens[1],outputMsg);
	}
	else if	(tokens[0] == "stop"){
		return StompProtocol::processUserInput("send server stop",outputMsg);
	}
	else if	(tokens[0] == "clients"){
		return StompProtocol::processUserInput("send server clients",outputMsg);
	}
	else if	(tokens[0] == "stats"){
		return StompProtocol::processUserInput("send server stats",outputMsg);
	}

	//else -> login \ logout \ exit_client
    return StompProtocol::processUserInput(inputMsg,outputMsg);
}


