/*
 * UnsubscribeFrame.h
 *
 *  Created on: Jan 8, 2014
 *      Author: arielbar
 */

#ifndef UNSUBSCRIBEFRAME_H_
#define UNSUBSCRIBEFRAME_H_

#include "StompFrame.h"
#include <sstream>

class UnsubscribeFrame: public StompFrame {
public:
	UnsubscribeFrame(int id);
	virtual ~UnsubscribeFrame();
	virtual string toString();
private:
	int _id;
};

#endif /* UNSUBSCRIBEFRAME_H_ */
