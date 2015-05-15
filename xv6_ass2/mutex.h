
#include "linkedList.h"
//#define MAX_MUTEXES 16


struct mutex
{
	int id;
	int isUsed;
	int isLocked;
	linkedList waitingThreadsQueue;
};
