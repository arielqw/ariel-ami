#include <stdlib.h>
#include "../include/Client.h"

#include "protocols/STOMP/StompProtocol.h"
#include "protocols/STOMP/TweeterProtocol.h"
#include "../include/AppLogger.h"
/**
* This code assumes that the server replies the exact text the client sent it (as opposed to the practical session example)
*/
int main (int argc, char *argv[]) {
	//init logger
	CAppLogger::Instance( "app.log",Poco::Message::PRIO_INFORMATION,Poco::Message::PRIO_INFORMATION );

	CAppLogger::Instance().Log("Tweeter Client Started!",Poco::Message::PRIO_INFORMATION);

	TweeterProtocol protocol;

	Client client(protocol);
	client.start();

    return 1;
}
