/*
 * SendFrame.h
 *
 *  Created on: Jan 7, 2014
 *      Author: amio
 */

#ifndef SENDFRAME_H_
#define SENDFRAME_H_

#include "StompFrame.h"

class SendFrame: public StompFrame {
public:
	SendFrame();
	virtual ~SendFrame();
};

#endif /* SENDFRAME_H_ */
