/*
 * Protocol.h
 *
 *  Created on: Jan 7, 2014
 *      Author: amio
 */

#ifndef PROTOCOL_H_
#define PROTOCOL_H_

#include <string>
using namespace std;

class Protocol {
public:
	Protocol();
	virtual ~Protocol();
	virtual void processMsg(const string& msg) = 0;
	virtual string processUserInput(const string& msg) = 0;
};

#endif /* PROTOCOL_H_ */
