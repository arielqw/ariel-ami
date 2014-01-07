/*
 * UserInputHandler.cpp
 *
 *  Created on: Jan 7, 2014
 *      Author: amio
 */

#include "UserInputHandler.h"

using namespace std;

UserInputHandler::UserInputHandler(ConnectionHandler connectionHandler) {
	// TODO Auto-generated constructor stub

}

UserInputHandler::~UserInputHandler() {
	// TODO Auto-generated destructor stub
}

void UserInputHandler::start() {
	string str;
	cin >> str;

	StompFrame* frame = decodeMsg(str);
	processMsg(frame);
	delete frame;
}

StompFrame* UserInputHandler::decodeMsg(const string& msgStr) {

	StompFrame* frame = NULL;

    string buf; // Have a buffer string
    stringstream ss(msgStr); // Insert the string into a stream
    vector<string> tokens; // Create vector to hold our words
    while (ss >> buf)	 tokens.push_back(buf);		//splits with ' ' as delimiter

    if 		(tokens[0] == "login")   	frame = new ConnectFrame(tokens[1], atoi(tokens[2].c_str()), tokens[3], tokens[4]);
    else if	(tokens[0] == "follow")    	frame = new SubscribeFrame(tokens[1]);
    else if	(tokens[0] == "unfollow")	frame = new UnsubscribeFrame(tokens[1]);
    else if	(tokens[0] == "tweet")		frame = new SendFrame(tokens[1]);
    else if	(tokens[0] == "logout")		frame = new SendFrame(tokens[1]);
    else if	(tokens[0] == "stop")		frame = new SendFrame(tokens[1]);
    else if	(tokens[0] == "clients")	frame = new SendFrame(tokens[1]);
    else if	(tokens[0] == "stats")		frame = new SendFrame(tokens[1]);

    return frame;
}

void UserInputHandler::processMsg(StompFrame* frame) {
}

/*	TOKENIZER
#include <iostream>
#include <string>
#include <boost/foreach.hpp>
#include <boost/tokenizer.hpp>

using namespace std;
using namespace boost;

int main(int argc, char** argv)
{
    string text = "token  test\tstring";

    char_separator<char> sep(" \t");
    tokenizer<char_separator<char>> tokens(text, sep);
    BOOST_FOREACH(string t, tokens)
    {
        cout << t << "." << endl;
    }
}
*/

