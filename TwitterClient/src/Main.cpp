#include <stdlib.h>
#include "../include/Client.h"
#include "../include/Protocol.h"
#include "../include/UserInputHandler.h"

#include "../userInputHandlers/TweeterUserInputHandler.h"
#include "../protocols/StompProtocol.h"

/**
* This code assumes that the server replies the exact text the client sent it (as opposed to the practical session example)
*/
int main (int argc, char *argv[]) {

	StompProtocol protocol;
	TweeterUserInputHandler userInputHandler;

	Client client(protocol, userInputHandler);
	client.start();

    return 1;
}
