/*
 * StompProtocol.cpp
 *
 *  Created on: Jan 7, 2014
 *      Author: amio
 */

#include "StompProtocol.h"
#include <stdlib.h>
#include <sstream>
StompProtocol::StompProtocol() {
	// TODO Auto-generated constructor stub

}

StompProtocol::~StompProtocol() {
	// TODO Auto-generated destructor stub
}

void StompProtocol::processMsg(const string& msg) {

}

string StompProtocol::processUserInput(const string& msg) {
	StompFrame* frame = NULL;

    string buf; // Have a buffer string
    stringstream ss(msg); // Insert the string into a stream
    vector<string> tokens; // Create vector to hold our words
    while (ss >> buf){
    	tokens.push_back(buf);		//splits with ' ' as delimiter
    }

    if(tokens[0] == "login"){
    	if( _client->connect(tokens[1],atoi(tokens[2].c_str())) ){
        	frame = new ConnectFrame(tokens[1], atoi(tokens[2].c_str()), tokens[3], tokens[4]);
    	}
    }
//    else if	(tokens[0] == "follow")    	frame = new SubscribeFrame(tokens[1]);
//    else if	(tokens[0] == "unfollow")	frame = new UnsubscribeFrame(tokens[1]);
//    else if	(tokens[0] == "tweet")		frame = new d(tokens[1]);
//    else if	(tokens[0] == "logout")		frame = new SendFrame(tokens[1]);
//    else if	(tokens[0] == "stop")		frame = new SendFrame(tokens[1]);
//    else if	(tokens[0] == "clients")	frame = new SendFrame(tokens[1]);
//    else if	(tokens[0] == "stats")		frame = new SendFrame(tokens[1]);
    if(frame == NULL) return "INVALID";
    return frame->toString();
}
