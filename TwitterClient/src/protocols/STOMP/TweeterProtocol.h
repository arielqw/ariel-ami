/*
 * TweeterProtocol.h
 *
 *  Created on: Jan 8, 2014
 *      Author: arielbar
 */

#ifndef TWEETERPROTOCOL_H_
#define TWEETERPROTOCOL_H_

#include "StompProtocol.h"

class TweeterProtocol: public StompProtocol {
public:
	TweeterProtocol();
	virtual ~TweeterProtocol();

	virtual bool processUserInput(const string& inputMsg, string& outputMsg);

protected:
	virtual void processMsg();
};

#endif /* TWEETERPROTOCOL_H_ */
