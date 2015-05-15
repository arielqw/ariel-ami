




int nextmutexid = 1;
static struct mutex mutexes[MAX_MUTEXES];


void initMutexes()
{
	struct mutex* m;
	for(m = mutexes; m < &mutexes[MAX_MUTEXES]; m++){
		init_linkedList(&m->waitingThreadsQueue, NTHREAD);
		m->isLocked = 0;
		m->isUsed = 0;
	}
}


struct mutex* getUnusedMutex()
{
	struct mutex* m;
	for(m = mutexes; m < &mutexes[MAX_MUTEXES]; m++){
		if (m->isUsed == 0)	return m;
	}
	cprintf("no free mutex. cant alloc");
	return 0;
}

struct mutex* getMutexById(int id)
{
	struct mutex* m;
	for(m = mutexes; m < &mutexes[MAX_MUTEXES]; m++){
		if (m->id == id)	return m;
	}
	cprintf("cant find mutex by id");
	return 0;
}

int kthread_mutex_alloc()
{
	int mid = -1;
	acquire(&ptable.lock);
	struct mutex* m = getUnusedMutex();
	clean_list(&m->waitingThreadsQueue);
	m->isUsed = 1;
	m->id = nextmutexid++;
	mid = m->id;
	release(&ptable.lock);
	return mid;
}

int kthread_mutex_dealloc(int mutex_id)
{
	int retVal = -1;
	acquire(&ptable.lock);
	struct mutex* m = getMutexById(mutex_id);
	if(!m || m->isUsed || m->isLocked){
		goto dealloc_done;
	}

	m->isUsed = 0;
dealloc_done:
	release(&ptable.lock);
	return retVal;
}

int kthread_mutex_lock(int mutex_id)
{
	int retVal = -1;
	acquire(&ptable.lock);
	struct mutex* m = getMutexById(mutex_id);
	if (m && m->isUsed)
	{
		if (m->isLocked)
		{
			m->waitingThreadsQueue.add(&m->waitingThreadsQueue, thread->tid, thread);
			while (m->waitingThreadsQueue.head->data != thread)
			{
				sleep(thread, &ptable.lock);
			}
			m->waitingThreadsQueue.remove_first(&m->waitingThreadsQueue);
		}
		else	//not locked
		{
			m->isLocked = 1;
		}
		retVal = 0;
	}
	release(&ptable.lock);
	return retVal;
}

int kthread_mutex_unlock(int mutex_id)
{
	int retVal = -1;
	acquire(&ptable.lock);
	struct mutex* m = getMutexById(mutex_id);
	if (m && m->isUsed && m->isLocked)
	{
		if (m->waitingThreadsQueue.size > 0)
		{
			struct thread* nextThreadToLock = m->waitingThreadsQueue.head->data;
			wakeup1(nextThreadToLock);
		}
		else	//no thread is waiting for lock
		{
			m->isLocked = 0;
		}
		retVal = 0;
	}
	release(&ptable.lock);
	return retVal;

}

int kthread_mutex_yieldlock(int mutex_id1, int mutex_id2)
{

	return 0;

}
