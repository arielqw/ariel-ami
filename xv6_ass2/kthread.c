#include "kthread.h"


int nexttid = 1;

void clean_thread(struct thread* t){
	kfree(t->kstack);
    t->kstack = 0;
    t->killed = 0;
    t->state = UNUSED;

    acquire(&mtable.lock);
    struct mutex* m;
	for(m = mtable.mutexes; m < &mtable.mutexes[MAX_MUTEXES]; m++){
		if(m->lockingThread == t){
			kthread_mutex_unlock1(m->id);
		}
	}

    release(&mtable.lock);
    memset(t,0,sizeof(struct thread));
}

int kthread_create(void*(*start_func)(), void* stack, uint stack_size)
{
	char* LOG_TAG = "[kthread_create] ";
	cprintf("%d | %s start \n", thread->tid, LOG_TAG);
	  acquire(&ptable.lock);

	  //find a free thread to use
	  struct thread *t = getThreadInStateOf(thread->process,UNUSED);
	  if(t == 0){
		  cprintf("threads limit for this process exceeded. pid: %d \n", thread->process->pid);
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
		cprintf("kthread_create failed kalloc thread stack for pid: %d \n", thread->process->pid);
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

	  cprintf("%d | %s done. new thread id is %d \n", thread->tid, LOG_TAG, t->tid);

	  return t->tid;
}

void kthread_exit()
{
	char* LOG_TAG = "[kthread_exit] ";
	cprintf("%d | %s start \n", thread->tid, LOG_TAG);

	killThread();

}

int kthread_join(int thread_id)
{
	char* LOG_TAG = "[kthread_join] ";
	cprintf("%d | %s start \n", thread->tid, LOG_TAG);

	acquire(&ptable.lock);
	struct proc* p = thread->process;
	struct thread* t;
	for(t = p->ttable.thread; t < &p->ttable.thread[NTHREAD]; t++){
		if(t->tid == thread_id){
			goto found;
		}
	}
	cprintf("error invalid tid to join");
	cprintf("%d | %s error invalid tid (%d) to join \n", thread->tid, LOG_TAG, thread_id);

	release(&ptable.lock);

	return -1;
found:
	cprintf("%d | %s trying to sleep on tid %d (%s) \n", thread->tid, LOG_TAG, t->tid, getStatusString(t->state));

	while (t->state != UNUSED && t->state != ZOMBIE)
	{
		cprintf("%d | %s going to sleep on tid %d (%s) \n", thread->tid, LOG_TAG, t->tid, getStatusString(t->state));
		sleep(t,&ptable.lock);
	}
	cprintf("%d | %s woke up from sleep on tid %d (%s) \n", thread->tid, LOG_TAG, t->tid, getStatusString(t->state));

	if(t->state == ZOMBIE){
		//cleanup
		clean_thread(t);
	}
	release(&ptable.lock);

	return 0;
}














