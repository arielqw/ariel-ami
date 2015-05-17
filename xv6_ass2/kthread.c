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
//			kthread_mutex_unlock1(m->id); //todo: dont unlock cond_ mutex
		}
	}

    release(&mtable.lock);
    memset(t,0,sizeof(struct thread));
}

int kthread_create(void*(*start_func)(), void* stack, uint stack_size)
{
	debug_print("%d | [%s] start \n", thread->tid, __FUNCTION__);
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

	  debug_print("%d | [%s] done. new thread id is %d \n", thread->tid, __FUNCTION__, t->tid);

	  return t->tid;
}

void kthread_exit()
{
	debug_print("%d | [%s] start \n", thread->tid, __FUNCTION__);

	killThread();

}

int kthread_join(int thread_id)
{
	debug_print("%d | [%s] start \n", thread->tid, __FUNCTION__);

	acquire(&ptable.lock);
	struct proc* p = thread->process;
	struct thread* t;
	for(t = p->ttable.thread; t < &p->ttable.thread[NTHREAD]; t++){
		if(t->tid == thread_id){
			goto found;
		}
	}
	debug_print("%d | [%s] error invalid tid (%d) to join \n", thread->tid, __FUNCTION__, thread_id);

	release(&ptable.lock);

	return -1;
found:
	debug_print("%d | [%s] trying to sleep on tid %d (%s) \n", thread->tid, __FUNCTION__, t->tid, getStatusString(t->state));

	while (t->state != UNUSED && t->state != ZOMBIE)
	{
		debug_print("%d | %s going to sleep on tid %d (%s) \n", thread->tid, __FUNCTION__, t->tid, getStatusString(t->state));
		sleep(t,&ptable.lock);
	}
	debug_print("%d | [%s] woke up from sleep on tid %d (%s) \n", thread->tid, __FUNCTION__, t->tid, getStatusString(t->state));

	if(t->state == ZOMBIE){
		//cleanup
		clean_thread(t);
	}
	release(&ptable.lock);

	return 0;
}














