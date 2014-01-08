/*
 * SubscribeFrame.h
 *
 *  Created on: Jan 7, 2014
 *      Author: amio
 */

#ifndef SUBSCRIBEFRAME_H_
#define SUBSCRIBEFRAME_H_

#include "StompFrame.h"
#include <sstream>
class SubscribeFrame: public StompFrame {
public:
	SubscribeFrame(const string& destination, int id);
	virtual ~SubscribeFrame();
	virtual string toString();
private:
	string _destination;
	int _id;
};

#endif /* SUBSCRIBEFRAME_H_ */
