/*
 * StompFrame.cpp
 *
 *  Created on: Jan 7, 2014
 *      Author: amio
 */

#include "StompFrame.h"
#include <sstream>
StompFrame::StompFrame() {
	// TODO Auto-generated constructor stub

}

StompFrame::~StompFrame() {
	// TODO Auto-generated destructor stub
}

string StompFrame::makeFrame(const string& header,vector<pair<string, string> > pairs, const string& body) {
	ostringstream output;
	output << header;
	output << '\n';
	for (unsigned int i = 0; i < pairs.size(); ++i) {
		output << pairs[i].first << ':' << pairs[i].second;
		output << '\n';
	}
	output << body;
	output << '\n';
	output << '\0';

	return output.str();
}


