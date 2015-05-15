#include "kthread.h"


int nexttid = 1;


int kthread_create(void*(*start_func)(), void* stack, uint stack_size)
{
	cprintf("creating thread...");
	  acquire(&ptable.lock);

	  //find a free thread to use
	  struct thread *t = getThreadInStateOf(thread->process,UNUSED);
	  if(t == 0){
		  cprintf("threads limit for this process exceeded. pid: %d ", thread->process->pid);
		  release(&ptable.lock);
		  return -1;
	  }

	  memset(t, 0, sizeof *t);
	  t->state = EMBRYO;
	  t->tid = nexttid++;	//TODO: synchronize this?
	  t->process = thread->process;
	  t->killed = 0;

	  if((t->kstack = kalloc()) == 0){
	    t->state = UNUSED;
	    return -1;
	  }

	  char *sp = t->kstack + KSTACKSIZE;

	  // Leave room for trap frame.
	  sp -= sizeof *t->tf;
	  t->tf = (struct trapframe*)sp;

	  // Set up new context to start executing at forkret,
	  // which returns to trapret.
	  sp -= 4;
	  *(uint*)sp = (uint)trapret;

	  sp -= sizeof *t->context;
	  t->context = (struct context*)sp;

	  memset(t->context, 0, sizeof *t->context);
	  t->context->eip = (uint)forkret;

	  //memset(t->tf, 0, sizeof *t->tf);
	  *t->tf = *thread->tf;

	  t->tf->eip = (uint)start_func;
	  t->tf->esp = (uint)(stack + stack_size);

	  t->state = RUNNABLE;
	  release(&ptable.lock);

	  return t->tid;
}

void kthread_exit()
{
	thread->state = ZOMBIE;

//	struct ttable a;
//	a.thread[0].state = UNUSED;
//	a.lock
	thread->process->killed = 1;

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













