int nextmutexid = 1;

struct {
  struct spinlock lock;
  struct mutex mutexes[MAX_MUTEXES];
} mtable;


void setMutexToUnusedAndClear(struct mutex* m)
{
	m->isLocked = 0;
	m->isUsed = 0;
	m->reservedMutex = 0;
	m->lockingThread = 0;
	clean_list(&m->waitingThreadsQueue);
}

void initMutexes()
{
	//this code runs at the very begining, no prints or logic here.
	struct mutex* m;
	for(m = mtable.mutexes; m < &mtable.mutexes[MAX_MUTEXES]; m++){
		init_linkedList(&m->waitingThreadsQueue, NTHREAD);
		setMutexToUnusedAndClear(m);
	}
	initlock(&mtable.lock, "mtable");

}


struct mutex* getUnusedMutex()
{
	struct mutex* m;
	for(m = mtable.mutexes; m < &mtable.mutexes[MAX_MUTEXES]; m++){
		if (m->isUsed == 0)	return m;
	}
	cprintf("no free mutex. cant alloc");
	return 0;
}

struct mutex* getMutexById(int id)
{
	struct mutex* m;
	for(m = mtable.mutexes; m < &mtable.mutexes[MAX_MUTEXES]; m++){
		if (m->id == id)	return m;
	}
	cprintf("cant find mutex by id");
	return 0;
}

int kthread_mutex_alloc()
{

	int mid = -1;
	acquire(&mtable.lock);
	debug_print("%d | [%s] start \n", thread->tid, __FUNCTION__);

	struct mutex* m = getUnusedMutex();
	if (m)
	{
		//clean_list(&m->waitingThreadsQueue);	already cleaned
		m->isUsed = 1;
		m->id = nextmutexid++;
		mid = m->id;
		debug_print("%d | [%s] alloced new mutex id %d \n", thread->tid, __FUNCTION__, mid);
	}
	else{
		cprintf("%d | %s error alloced new mutex  \n", thread->tid, __FUNCTION__);
	}
	release(&mtable.lock);
	return mid;
}

int kthread_mutex_dealloc(int mutex_id)
{

	int retVal = -1;
	acquire(&mtable.lock);
	debug_print("%d | [%s] start received mutex_id: %d \n", thread->tid, __FUNCTION__, mutex_id);

	struct mutex* m = getMutexById(mutex_id);
	if (m && m->isUsed && !m->isLocked)
	{
		setMutexToUnusedAndClear(m);
		retVal = 0;
		debug_print("%d | [%s] dealloc mutex  \n", thread->tid, __FUNCTION__, mutex_id);
	}
	else{
		cprintf("%d | [%s] error dealloc mutex  \n", thread->tid, __FUNCTION__, mutex_id);
	}
	release(&mtable.lock);
	return retVal;
}

int kthread_mutex_lock(int mutex_id)
{

	int retVal = -1;
	acquire(&mtable.lock);
	debug_print("%d | [%s] start received mutex id: %d \n", thread->tid, __FUNCTION__, mutex_id);

	struct mutex* m = getMutexById(mutex_id);
	if (m && m->isUsed)
	{
		if (m->isLocked)
		{
			m->waitingThreadsQueue.add(&m->waitingThreadsQueue, thread->tid, thread);
			while (m->lockingThread != 0 || m->waitingThreadsQueue.head->data != thread)
			{
				debug_print("%d | [%s] mutex %d is locked, going to sleep on thread %d \n", thread->tid, __FUNCTION__, m->id, thread->tid);
				sleep(thread, &mtable.lock);
			}
			m->waitingThreadsQueue.remove_first(&m->waitingThreadsQueue);
		}
		else	//not locked
		{
			m->isLocked = 1;
			m->reservedMutex = 0;	//u can only enjoy reserve once
		}

		retVal = 0;
		m->lockingThread = thread;
	}
	debug_print("%d | [%s] got mutex %d (%d|%d|%d) \n", thread->tid, __FUNCTION__, m->id, m->isUsed, m->isLocked, m->lockingThread->tid);

	release(&mtable.lock);
	return retVal;
}


int kthread_mutex_unlock1(int mutex_id)
{

	int retVal = -1;
	debug_print("%d | [%s] start , mutex id: %d \n", thread->tid, __FUNCTION__, mutex_id);

	struct mutex* m = getMutexById(mutex_id);
//	cprintf("%d | %s current owner of mutex: %d is: %d \n", thread->tid, __FUNCTION__, m->id, m->lockingThread->tid);

	if (m && m->isUsed && m->isLocked)
	{
		if (m->waitingThreadsQueue.size > 0)
		{
			struct thread* nextThreadToLock = m->waitingThreadsQueue.head->data;
			debug_print("%d | [%s] unlocking mutex %d, waking up thread: %d \n", thread->tid, __FUNCTION__, mutex_id, nextThreadToLock->tid);
			wakeup1(nextThreadToLock);

		}
		else	//no thread is waiting for lock
		{
			debug_print("%d | [%s] no one waiting for mutex %d, no need to wakeup threads \n", thread->tid, __FUNCTION__, mutex_id);
			m->isLocked = 0;
		}

		m->lockingThread = 0;
		retVal = 0;
	}
	else{
		cprintf("%d | [%s] error unlocking mutex %d (%d|%d)\n", thread->tid, __FUNCTION__, mutex_id , m->isUsed , m->isLocked);
	}
	return retVal;

}

int kthread_mutex_unlock(int mutex_id){
    int retVal;
	acquire(&mtable.lock);
	retVal = kthread_mutex_unlock1(mutex_id);
    release(&mtable.lock);
    return retVal;
}

int kthread_mutex_yieldlock(int mutex_id1, int mutex_id2)
{
	debug_print("%d | [%s] start m1:%d m2:%d \n", thread->tid, __FUNCTION__, mutex_id1, mutex_id2);
	int retVal = -1;
	acquire(&mtable.lock);
	struct mutex* m1 = getMutexById(mutex_id1);
	struct mutex* m2 = getMutexById(mutex_id2);
//
	if (m1  && m2
			&& m1->isUsed
			&& m1->isLocked
			&& m1->lockingThread == thread)
	{
		if(m2->waitingThreadsQueue.size > 0){
			debug_print("%d | [%s] moving mutex %d from %d to %d \n", thread->tid, __FUNCTION__, m1->id, thread->tid, m2->waitingThreadsQueue.head->data->tid);

			m1->lockingThread = m2->waitingThreadsQueue.head->data;
			retVal = 0;
		}
		else{
			//locks going to be lost forever
			debug_print("%d | [%s] no one is waiting on %d, locks are lost \n", thread->tid, __FUNCTION__, m2->id);

		}

	}
	else{
		cprintf("%d | %s error ..  \n", thread->tid, __FUNCTION__);

	}
	if(retVal == -1){
		kthread_mutex_unlock1(mutex_id1);
	}
	release(&mtable.lock);
	return retVal;

}
