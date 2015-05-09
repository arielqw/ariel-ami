
#include "kthread.h"
//#include "proc.h"

int nexttid = 1;


int kthread_create(void*(*start_func)(), void* stack, uint stack_size)
{
	return 0;
}

void kthread_exit()
{
	thread->state = ZOMBIE;

//	struct ttable a;
//	a.thread[0].state = UNUSED;
//	a.lock
	//thread->process->killed = 1;

	//acquire(&(thread->process->ttable.lock));
	/*
	thread->state = ZOMBIE;
	wakeup1(thread->chan);
	release(thread->process->ttable.lock);
*/
}

int kthread_join(int thread_id)
{
	/*
	acquire(thread->process->ttable.lock);
	struct proc* p = thread->process;
	struct thread* t;
	for(t = p->ttable.thread; t < &p->ttable.thread[NTHREAD]; t++){

	}
	thread->state = ZOMBIE;
	wakeup1(thread->chan);
	release(thread->process->ttable.lock);
*/
	return 0;
}

int kthread_mutex_alloc()
{
	return 0;

}

int kthread_mutex_dealloc(int mutex_id)
{
	return 0;

}

int kthread_mutex_lock(int mutex_id)
{
	return 0;

}

int kthread_mutex_unlock(int mutex_id)
{
	return 0;

}

int kthread_mutex_yieldlock(int mutex_id1, int mutex_id2)
{
	return 0;

}













