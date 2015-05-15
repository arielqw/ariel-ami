#include "types.h"
#include "defs.h"
#include "param.h"
#include "memlayout.h"
#include "mmu.h"
#include "x86.h"
#include "spinlock.h"

#include "proc.h"

struct {
  struct spinlock lock;
  struct proc proc[NPROC];
} ptable;

static struct proc *initproc;

int nextpid = 1;
int nexttid;
extern void forkret(void);
extern void trapret(void);

static void wakeup1(void *chan);

void
pinit(void)
{
  initlock(&ptable.lock, "ptable");
//  int i = 0;
//  struct proc* p;
//  char* names[] = {"ttable0","ttable1", "ttable2", "ttable3", "ttable4", "ttable5", "ttable6", "ttable7",
//		  	  	  "ttable8","ttable9", "ttable10", "ttable11", "ttable12","ttable13", "ttable14", "ttable15"};
//
//  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
//	  initlock(&p->ttable.lock, names[i++]);
//  }
}

// retrieves the first thread of the process with matching state
// returns 0 if not found
struct thread* getThreadInStateOf(struct proc* p, enum threadstate state){
	struct thread* t;
	for(t = p-> ttable.thread; t < &p->ttable.thread[NTHREAD]; t++){
		if (t->state == state) return t;
	}
	return 0;
}


int isZombie(struct proc* p){
	struct thread* t;

	for(t = p->ttable.thread; t < &p->ttable.thread[NTHREAD]; t++){
		if (t->state != ZOMBIE && t->state != UNUSED) return 0;
	}
	return 1;
}

int isUnused(struct proc* p){
	struct thread* t;

	for(t = p->ttable.thread; t < &p->ttable.thread[NTHREAD]; t++){
		if (t->state != UNUSED) return 0;
	}
	return 1;
}

//PAGEBREAK: 32
// Look in the process table for an UNUSED proc.
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
  struct thread *t;
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(isUnused(p))
    {
    	t = &(p->ttable.thread[0]);
        goto found;
    }
  }
  release(&ptable.lock);
  return 0;


found:
  t->state = EMBRYO;
  t->tid = nexttid++;	//TODO: synchronize this?
  p->pid = nextpid++;
  p->isDying = 0;
  t->process = p;
  p->isPendingExec = 0;
  p->threadThatCalledExec = 0;

  release(&ptable.lock);

  // Allocate kernel stack.	//THREAD
  if((t->kstack = kalloc()) == 0){
    t->state = UNUSED;
    return 0;
  }
  sp = t->kstack + KSTACKSIZE;
  
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

  return p;
}

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{

  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];
  
  cprintf("before allocproc\n");
  p = allocproc();
  struct thread* t = &(p->ttable.thread[0]);
  cprintf("after allocproc\n");
  initproc = p;
  if((p->pgdir = setupkvm()) == 0)
    panic("userinit: out of memory?");
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
  p->sz = PGSIZE;
  memset(t->tf, 0, sizeof(*t->tf));
  t->tf->cs = (SEG_UCODE << 3) | DPL_USER;
  t->tf->ds = (SEG_UDATA << 3) | DPL_USER;
  t->tf->es = t->tf->ds;
  t->tf->ss = t->tf->ds;
  t->tf->eflags = FL_IF;
  t->tf->esp = PGSIZE;
  t->tf->eip = 0;  // beginning of initcode.S

  safestrcpy(p->name, "initcode", sizeof(p->name));
  p->cwd = namei("/");

  //cprintf("got here");
  //p->parent = p;
  p->ttable.thread[0].state = RUNNABLE;

}

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
  uint sz;
  
  sz = thread->process->sz;
  if(n > 0){
    if((sz = allocuvm(thread->process->pgdir, sz, sz + n)) == 0)
      return -1;
  } else if(n < 0){
    if((sz = deallocuvm(thread->process->pgdir, sz, sz + n)) == 0)
      return -1;
  }
  thread->process->sz = sz;
  switchuvm(thread->process);
  return 0;
}

// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
  int i, pid;
  struct proc *np;

  // Allocate process.
  if((np = allocproc()) == 0)
    return -1;

  struct thread* nt = &(np->ttable.thread[0]);
  // Copy process state from p.
  if((np->pgdir = copyuvm(thread->process->pgdir, thread->process->sz)) == 0){
    kfree(nt->kstack);
    nt->kstack = 0;
    nt->state = UNUSED;
    return -1;
  }

  nt->killed = 0;
  np->sz = thread->process->sz;
  np->parent = thread->process;
  *nt->tf = *thread->tf;

  // Clear %eax so that fork returns 0 in the child.
  nt->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
    if(thread->process->ofile[i])
      np->ofile[i] = filedup(thread->process->ofile[i]);
  np->cwd = idup(thread->process->cwd);

  safestrcpy(np->name, thread->process->name, sizeof(thread->process->name));
 
  pid = np->pid;

  // lock to force the compiler to emit the np->state write last.
  acquire(&ptable.lock);

  //int
  //*nt = *thread;	//copy all fields
  //*(nt->context) = *thread->context;

  nt->state = RUNNABLE;	//TODO: synchronize this
  release(&ptable.lock);
  
  return pid;
}
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void){ //todo: fix 2 paralel exits bug

	//todo : check if we need to lock this
	acquire(&ptable.lock);
	if(thread->process->isDying){
		//release(&ptable.lock);
		sched();
		cprintf("sched not working! buuz \n");
	}
	cprintf("exiting pid:%d...\n", thread->process->pid);

	thread->process->isDying = 1;

    //kill all threads
	struct thread* t;
	for(t = thread->process->ttable.thread; t < &thread->process->ttable.thread[NTHREAD]; t++){
		t->killed = 1;
	}
	//thread->state = RUNNABLE;

	//release(&ptable.lock);

	//sched();
	//panic("exit didnt go to sched");
	release(&ptable.lock);	//should release after killThread
	killThread();
}


void
killThread(void)
{
  //todo: add lock
  cprintf("killing thread\n");
  thread->state = ZOMBIE;

  //in case we are in exec mode
  if (thread->process->isPendingExec){
	  //saving and switching the state of the thread who called exec
	  enum threadstate previousState = thread->process->threadThatCalledExec->state;
	  thread->process->threadThatCalledExec->state = ZOMBIE;

	  if( !isZombie(thread->process) ){
		  thread->process->threadThatCalledExec->state = previousState;
		  return;
	  }
	  else{
		  thread->process->threadThatCalledExec->state = previousState;
		  wakeup(thread->process->threadThatCalledExec->chan);
		  return;
	  }
  }

  //if all threads are killed we can proceed with exit, otherwise not
  if( !isZombie(thread->process) ){
	  acquire(&ptable.lock);
	  goto done;
	  cprintf("sched failed 1");
	  //return;
  }

	cprintf("last thread dead. killing process\n");

  struct proc *p;
  int fd;

  if(thread->process == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
    if(thread->process->ofile[fd]){
      fileclose(thread->process->ofile[fd]);
      thread->process->ofile[fd] = 0;
    }
  }


  begin_op();
  iput(thread->process->cwd);
  end_op();
  thread->process->cwd = 0;

  acquire(&ptable.lock);

  // Parent might be sleeping in wait().
  wakeup1(thread->process->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->parent == thread->process){
      p->parent = initproc;
      if(isZombie(p))
        wakeup1(initproc);
    }
  }

  // Jump into the scheduler, never to return.
done:
	cprintf("trying to wake-up");
	wakeup1(thread->chan);
	cprintf("done trying to wake-up");

  sched();
  panic("zombie exit");
}

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->parent != thread->process)
        continue;
      havekids = 1;
      if( isZombie(p) ){
        // Found one.
        pid = p->pid;

        struct thread* t;
        // cleaning threads and freeing used stacks
        for(t = p->ttable.thread; t < &p->ttable.thread[NTHREAD]; t++){
            if (t->state != UNUSED)	//zombie
            {
            	cprintf("wait cleaning thread\n");

            	kfree(t->kstack);	//TODO: should make sure we are not deleting a running thread!
                t->kstack = 0;
                t->killed = 0;
                t->state = UNUSED;
                memset(t,0,sizeof(struct thread));
            }
        }

        freevm(p->pgdir);
        p->pid = 0;
        p->parent = 0;
        p->name[0] = 0;
        p->killed = 0;
        release(&ptable.lock);
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || thread->process->killed){
      release(&ptable.lock);
      return -1;
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(thread->process, &ptable.lock);  //DOC: wait-sleep
  }
}

//PAGEBREAK: 42
// Per-CPU process scheduler.
// Each CPU calls scheduler() after setting itself up.
// Scheduler never returns.  It loops, doing:
//  - choose a process to run
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
  struct proc *p;

  for(;;){
    // Enable interrupts on this processor.
    sti();

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){

    	struct thread* t;
    	for(t = p->ttable.thread; t < &p->ttable.thread[NTHREAD]; t++){

		  if(t->state != RUNNABLE) continue; // if there is no RUNNABLE thread in process
		  //acquire(&p->ttable.lock);
		  // Switch to chosen process.  It is the process's job
		  // to release ptable.lock and then reacquire it
		  // before jumping back to us.
		  //thread->process = p;
		  thread = t;

		  switchuvm(p);
		  t->state = RUNNING;
		  swtch(&cpu->scheduler, thread->context);
		  switchkvm();

		  // Process is done running for now.
		  // It should have changed its p->state before coming back.
		  thread = 0;
		  //release(&p->ttable.lock);

    	}

    }
    release(&ptable.lock);

  }
}

// Enter scheduler.  Must hold only ptable.lock
// and have changed thread->process->state.
void
sched(void)
{
  int intena;

  if(!holding(&ptable.lock))
    panic("sched ptable.lock");
  if(cpu->ncli != 1)	//TODO: might not work well
    panic("sched locks");
  if(thread->state == RUNNING)
    panic("sched running");
  if(readeflags()&FL_IF)
    panic("sched interruptible");
  intena = cpu->intena;
  swtch(&thread->context, cpu->scheduler);
  cpu->intena = intena;
}

// Give up the CPU for one scheduling round.
void
yield(void)
{
  acquire(&ptable.lock);  //DOC: yieldlock
  thread->state = RUNNABLE;
  sched();
  release(&ptable.lock);
}

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);

  if (first) {
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot 
    // be run from main().
    first = 0;
    initlog();
  }
  
  // Return to "caller", actually trapret (see allocproc).
}

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
  if(thread->process == 0)
    panic("sleep");

  if(lk == 0)
    panic("sleep without lk");

  // Must acquire ptable.lock in order to
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
    acquire(&ptable.lock);  //DOC: sleeplock1
    release(lk);
  }

  // Go to sleep.
  thread->process->chan = chan;
  thread->state = SLEEPING;
  sched();

  // Tidy up.
  thread->process->chan = 0;

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
    release(&ptable.lock);
    acquire(lk);
  }
}

//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{

  struct proc *p;
  /*
   *
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    if(p->state == SLEEPING && p->chan == chan)
      p->state = RUNNABLE;
      */
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    	struct thread* t;
    	for(t = p->ttable.thread; t < &p->ttable.thread[NTHREAD]; t++){
    		if(t->state == SLEEPING && (t->chan == chan || p->chan == chan))
    		      t->state = RUNNABLE;
    	}
	}
}

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
  acquire(&ptable.lock);
  wakeup1(chan);
  release(&ptable.lock);
}

// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->pid == pid){
      p->killed = 1;
      // Wake process from sleep if necessary.
      struct thread* t;
      for(t = p->ttable.thread; t < &p->ttable.thread[NTHREAD]; t++){
          if(t->state == SLEEPING)
            t->state = RUNNABLE;
      }
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
  return -1;
}

//PAGEBREAK: 36
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
  static char *states[] = {
  [UNUSED]    "unused",
  [EMBRYO]    "embryo",
  [SLEEPING]  "sleep ",
  [RUNNABLE]  "runble",
  [RUNNING]   "run   ",
  [ZOMBIE]    "zombie"
  };
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
	  struct thread* t;
      for(t = p->ttable.thread; t < &p->ttable.thread[NTHREAD]; t++){
    	    if(t->state == UNUSED)
    	      continue;
    	    if(t->state >= 0 && t->state < NELEM(states) && states[t->state])
    	      state = states[t->state];
    	    else
    	      state = "???";
    	    cprintf("pid: %d thread_state: %s proc_name: %s", p->pid, state, p->name);
    	    if(t->state == SLEEPING){
    	      getcallerpcs((uint*)t->context->ebp+2, pc);	//TODO: check if it is good enough
    	      for(i=0; i<10 && pc[i] != 0; i++)
    	        cprintf(" %p", pc[i]);
    	    }
    	    cprintf("\n");
      }

  }
}

#include "kthread.c"
