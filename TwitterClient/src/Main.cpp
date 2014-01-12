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
	//CAppLogger::Instance( "app.log",Poco::Message::PRIO_DEBUG,Poco::Message::PRIO_DEBUG );

	CAppLogger::Instance().Log("Starting logging sessions\n login 127.0.0.1 61613 user password",Poco::Message::PRIO_INFORMATION);
	//CAppLogger::Instance().Log("Starting logging sessions\n login 79.177.215.3 33342 ami password",Poco::Message::PRIO_INFORMATION);

	//StompProtocol protocol;
	TweeterProtocol protocol;

	Client client(protocol);
	client.start();

    return 1;
}
