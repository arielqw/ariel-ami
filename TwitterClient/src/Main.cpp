#include <stdlib.h>
#include "../include/Client.h"
#include "../include/Protocol.h"

#include "protocols/STOMP/StompProtocol.h"
#include "../include/AppLogger.h"
/**
* This code assumes that the server replies the exact text the client sent it (as opposed to the practical session example)
*/
int main (int argc, char *argv[]) {
	//init logger
	CAppLogger::Instance( "app.log",Poco::Message::PRIO_INFORMATION,Poco::Message::PRIO_INFORMATION );
	//CAppLogger::Instance( "app.log",Poco::Message::PRIO_DEBUG,Poco::Message::PRIO_DEBUG );

	CAppLogger::Instance().Log("Starting logging sessions\n login 10.0.0.5 61613 username password",Poco::Message::PRIO_INFORMATION);

	StompProtocol protocol;

	Client client(protocol);
	client.start();

    return 1;
}
