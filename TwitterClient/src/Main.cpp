#include <stdlib.h>
#include "../include/Client.h"
#include "../include/Protocol.h"

#include "protocols/STOMP/StompProtocol.h"

/**
* This code assumes that the server replies the exact text the client sent it (as opposed to the practical session example)
*/
int main (int argc, char *argv[]) {

	StompProtocol protocol;

	Client client(protocol);
	client.start();

    return 1;
}
