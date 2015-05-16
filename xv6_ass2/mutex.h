
#include "linkedList.h"


struct mutex
{
	int id;
	int isUsed;
	int isLocked;
	linkedList waitingThreadsQueue;
	struct mutex* reservedMutex;
	struct thread* lockingThread;
};
