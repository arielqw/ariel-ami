/*
 * DisconnectFrame.h
 *
 *  Created on: Jan 7, 2014
 *      Author: amio
 */

#ifndef DISCONNECTFRAME_H_
#define DISCONNECTFRAME_H_

#include "StompFrame.h"
#include <sstream>

class DisconnectFrame: public StompFrame {
public:
	DisconnectFrame(int receipt);
	virtual ~DisconnectFrame();
	virtual string toString();
private:
	int _currentReceipt;
};

#endif /* DISCONNECTFRAME_H_ */
