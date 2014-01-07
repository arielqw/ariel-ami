/*
 * DisconnectFrame.h
 *
 *  Created on: Jan 7, 2014
 *      Author: amio
 */

#ifndef DISCONNECTFRAME_H_
#define DISCONNECTFRAME_H_

#include "StompFrame.h"

class DisconnectFrame: public StompFrame {
public:
	DisconnectFrame();
	virtual ~DisconnectFrame();
};

#endif /* DISCONNECTFRAME_H_ */
