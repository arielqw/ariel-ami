/*
 * SubscribeFrame.h
 *
 *  Created on: Jan 7, 2014
 *      Author: amio
 */

#ifndef SUBSCRIBEFRAME_H_
#define SUBSCRIBEFRAME_H_

#include "StompFrame.h"

class SubscribeFrame: public StompFrame {
public:
	SubscribeFrame(const string& username);
	virtual ~SubscribeFrame();
};

#endif /* SUBSCRIBEFRAME_H_ */
