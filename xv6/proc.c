#include "types.h"
#include "defs.h"
#include "param.h"
#include "memlayout.h"
#include "mmu.h"
#include "x86.h"
#include "proc.h"
#include "spinlock.h"

#include "linkedList.h"

#define SHELL_PID 2

struct {
  struct spinlock lock;
  struct proc proc[NPROC];
} ptable;

static struct proc *initproc;
static linkedList plist; //TODO ifdef

int nextpid = 1;
extern void forkret(void);
extern void trapret(void);

static void wakeup1(void *chan);

void
pinit(void)
{
  initlock(&ptable.lock, "ptable");
  init_linkedList(&plist,NPROC);
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
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    if(p->state == UNUSED)
      goto found;
  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
  p->pid = nextpid++;
  p->ctime = ticks;
  release(&ptable.lock);

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
    p->state = UNUSED;
    return 0;
  }
  sp = p->kstack + KSTACKSIZE;
  
  // Leave room for trap frame.
  sp -= sizeof *p->tf;
  p->tf = (struct trapframe*)sp;
  
  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
  *(uint*)sp = (uint)trapret;

  sp -= sizeof *p->context;
  p->context = (struct context*)sp;
  memset(p->context, 0, sizeof *p->context);
  p->context->eip = (uint)forkret;

  return p;
}

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];
  
  p = allocproc();
  initproc = p;
  if((p->pgdir = setupkvm()) == 0)
    panic("userinit: out of memory?");
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
  p->sz = PGSIZE;
  memset(p->tf, 0, sizeof(*p->tf));
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
  p->tf->es = p->tf->ds;
  p->tf->ss = p->tf->ds;
  p->tf->eflags = FL_IF;
  p->tf->esp = PGSIZE;
  p->tf->eip = 0;  // beginning of initcode.S

  safestrcpy(p->name, "initcode", sizeof(p->name));
  p->cwd = namei("/");

  p->state = RUNNABLE;

  //TODO ifdef
  acquire(&ptable.lock);	//wasnt here
  plist.add(&plist, p->pid, p);
  release(&ptable.lock);

}

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
  uint sz;
  
  sz = proc->sz;
  if(n > 0){
    if((sz = allocuvm(proc->pgdir, sz, sz + n)) == 0)
      return -1;
  } else if(n < 0){
    if((sz = deallocuvm(proc->pgdir, sz, sz + n)) == 0)
      return -1;
  }
  proc->sz = sz;
  switchuvm(proc);
  return 0;
}

// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
//  char* TAG = "fork";
  int i, pid, gid;
  struct proc *np;

  // Allocate process.
  if((np = allocproc()) == 0)
    return -1;

  // Copy process state from p.
  if((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
    kfree(np->kstack);
    np->kstack = 0;
    np->state = UNUSED;
    return -1;
  }
  np->sz = proc->sz;
  np->parent = proc;
  *np->tf = *proc->tf;

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
    if(proc->ofile[i])
      np->ofile[i] = filedup(proc->ofile[i]);
  np->cwd = idup(proc->cwd);

  safestrcpy(np->name, proc->name, sizeof(proc->name));
 
  pid = np->pid;

  //Set group id
  //if father is shell -> gid = this new process pid
  if( proc->pid == SHELL_PID){
	  gid = pid;
  }
  //else, take father gid
  else{
	  gid = proc->gid;
  }

  np->gid = gid;

  //cprintf("\n[debug] [fork] Created a new process son of '%s' with pid %d, and guid: %d\n", np->name, pid, gid);
  // lock to force the compiler to emit the np->state write last.
  acquire(&ptable.lock);
  np->state = RUNNABLE;
  
  plist.add(&plist, pid, np); //todo ifdef
  //plist.print(&plist);
  release(&ptable.lock);



  return pid;
}

// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(int status)
{
//  char* TAG = "exit";
  struct proc *p;
  int fd;

  //cprintf("\n[debug] [exit] Process '%s' (%d) Exited with status code %d\n", proc->name, proc->pid, status);

  if(proc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
    if(proc->ofile[fd]){
      fileclose(proc->ofile[fd]);
      proc->ofile[fd] = 0;
    }
  }

  begin_op();
  iput(proc->cwd);
  end_op();
  proc->cwd = 0;


  acquire(&ptable.lock);

  proc->status = status;
  proc->ttime = ticks;
  // Parent might be sleeping in wait().
  wakeup1(proc->parent);
//  cprintf("\n This is your captin speaking, here is : %s \n", ptable.proc[SHELL_PID].name);


  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->parent == proc){
      p->parent = initproc;
      if(p->state == ZOMBIE)
        wakeup1(initproc);
    }
  }

  // Jump into the scheduler, never to return.
  proc->state = ZOMBIE;
  sched();
  panic("zombie exit");


}
int clean_proc_entry(struct proc* p){
	int pid;
    // Found one.
    pid = p->pid;
    kfree(p->kstack);
    p->kstack = 0;
    freevm(p->pgdir);
    p->state = UNUSED;
    p->pid = 0;
    p->parent = 0;
    p->name[0] = 0;
    p->killed = 0;
    p->retime = 0;
    p->rutime = 0;
    p->stime = 0;
    p->ttime = 0;
    p->ctime = 0;
//    plist.remove_link(&plist,pid); //todo ifdef
    return pid;
}

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(int* status)
{
  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->parent != proc)
        continue;
      havekids = 1;
      if(p->state == ZOMBIE){
        // Found one.
        pid = clean_proc_entry(p);

        if(status){ // if user did not send status=0 (do not care)
            *status = p->status; //return status to caller
        }

        release(&ptable.lock);

        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
      release(&ptable.lock);
      return -1;
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
  }
}

int
shellWait(int childPid)
{
  struct proc *p;
 // int havekids, pid, isMyChild;
  int pid;

  for(;;){
    // Scan through table looking for zombie children.
   // havekids = 0;
   // isMyChild = 0;

    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->parent != proc)
        continue;
    //  havekids = 1;
      if( p->pid == childPid ){
    	 //isMyChild = 1;
		 if(p->state == ZOMBIE ){
			pid = clean_proc_entry(p);
			release(&ptable.lock);

			return pid;
		  }
      }

    }
	sleep(proc, &ptable.lock);
  }
}

// Wait for a child process *with a specific pid* to exit and return its pid.
// Return -1 if this process has no children.
int
waitpid(int childPid, int* status, int options)
{
  struct proc *p;
  int havekids, pid, isMyChild;

  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    isMyChild = 0;

    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->parent != proc)
        continue;
      havekids = 1;
      if( p->pid == childPid ){
    	 isMyChild = 1;
		 if(p->state == ZOMBIE ){
			pid = clean_proc_entry(p);

			if(status){ // if user did not send status=0 (do not care)
				*status = p->status; //return status to caller
			}

			release(&ptable.lock);

			return pid;
		  }
      }

    }

    // No point waiting if we don't have any children.
    if(!havekids || !isMyChild || proc->killed){
      release(&ptable.lock);
      return -1;
    }

    switch (options) {
		case BLOCKING:
			sleep(proc, &ptable.lock);
			break;
		case NONBLOCKING:
			release(&ptable.lock);
			return -1;
			break;
		default:
			release(&ptable.lock);
			return -1;
			break;
	}

  }
}

int
wait_stat(int* wtime, int* rtime, int* iotime)
{
	*wtime = proc->retime;
	*rtime = proc->rutime;
	*iotime = proc->stime;

	return wait(0);
}

int
foreground(int gid)
{
	struct proc* p;
	int pids[64];
	int counter = 0;
//	int i, status;
	int i;
	int retVal = -1;

	//cprintf("called fg with gid: %d \n", gid);
	acquire(&ptable.lock);
	for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
			if( ( p->state == RUNNING ||  p->state == RUNNABLE ||  p->state == SLEEPING) &&
				(p->parent == initproc) &&
				(p->gid == gid) )
			{
				p->parent = &ptable.proc[1]; //parent = shell
				pids[counter] = p->pid;
				counter++;
			}
	}
	for(i=0; i < counter; i++){
		//cprintf("**waiting for: %d \n ",pids[i]);
		if (shellWait(pids[i]) != -1)	retVal = 1;
	}
	release(&ptable.lock);
/*
	for(i=0; i < counter; i++){
		cprintf("**waiting for: %d \n ",pids[i]);
		waitpid(pids[i], &status, BLOCKING);
	}
	*/

	return retVal;
}

int
set_priority(int priority)
{
#ifndef CFS
	return -1;
#endif
	acquire(&ptable.lock);
	proc->priority = priority;
	//todo: change queueus
	release(&ptable.lock);
	return 1;
}

// Filling process_info_entry array with <pid,name> that is not zombie and has required <gid>
// should be called with a 64(=MAX NUM OF PROCESSES), will set <size> accordingly
int
list_pgroup(int gid, process_info_entry* arr, int* size)
{
	struct proc* p;
	int i = 0;
//	struct node* head;
//
//	linkedList plist;
//	  init_linkedList(&plist, 64);
//	  head = create_link(&plist);
//	  head->id = 18;
//	  head->data = 0;
//
//	  add_last(&plist,head);
//	plist.print(&plist);
	acquire(&ptable.lock);

//	cprintf("10 entire from process table:\n");
//
//	cprintf("pid   name   gid   father   father_name   \n");
//
//	for(p = ptable.proc; p < &ptable.proc[10]; p++){
//		cprintf("%d %d   %s   %d   %d   %s  \n", j, p->pid, p->name, p->gid,p->parent->pid,p->parent->name);
//		j++;
//	}

//	cprintf("requested listing of processes with group id %d \n", gid);

	for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
		if( ( p->state == RUNNING ||  p->state == RUNNABLE ||  p->state == SLEEPING) &&
			p->gid == gid ){

			arr[i].pid = p->pid;
			safestrcpy(arr[i].name, p->name, sizeof(arr[i].name));
			i++;
		}
	}

//	cprintf("found %d for group id %d  \n", i, gid);

	*size = i;
	release(&ptable.lock);

	return 0;
}


#ifdef DEFAULT

//PAGEBREAK: 42
// Per-CPU process scheduler.
// Each CPU calls scheduler() after setting itself up.
// Scheduler never returns.  It loops, doing:
//  - choose a process to run
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler_default(void)
{
  struct proc *p;

  for(;;){
    // Enable interrupts on this processor.
    sti();

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->state != RUNNABLE)
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      proc = p;
      switchuvm(p);
      p->state = RUNNING;
      swtch(&cpu->scheduler, proc->context);
      switchkvm();

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
    }
    release(&ptable.lock);

  }
}
#endif

#ifdef FRR
void
scheduler_frr(void)
{
	  struct proc *p;

	  for(;;){
	    // Enable interrupts on this processor.
	    sti();

	    acquire(&ptable.lock);
	    if (plist.size)
	    {
			  p = plist.remove_first(&plist);
			  if(p->state != RUNNABLE){
				  cprintf("ERROR: linkedlist contains a proc which is not RUNNABLE");
			  }

			  // Switch to chosen process.  It is the process's job
			  // to release ptable.lock and then reacquire it
			  // before jumping back to us.
			  proc = p;
			  switchuvm(p);
			  p->state = RUNNING;
			  swtch(&cpu->scheduler, proc->context);
			  switchkvm();

			  // Process is done running for now.
			  // It should have changed its p->state before coming back.
			  proc = 0;
	    }
	    release(&ptable.lock);

	  }
	}
#endif


void
scheduler(void)
{
	#if FRR
		cprintf("SCHEDULAR = FRR\n");
		scheduler_frr();
	#elif FCFS
		cprintf("SCHEDULAR = FCFS\n");
//		scheduler_fcfs();
	#elif CFS
		cprintf("SCHEDULAR = CFS\n");
//		scheduler_cfs();
	#else
		cprintf("SCHEDULAR = DEFAULT\n");
		//DEFAULT
		scheduler_default();
	#endif

	for(;;){}	//must be no-return
}

// Enter scheduler.  Must hold only ptable.lock
// and have changed proc->state.
void
sched(void)
{
  int intena;

  if(!holding(&ptable.lock))
    panic("sched ptable.lock");
  if(cpu->ncli != 1)
    panic("sched locks");
  if(proc->state == RUNNING)
    panic("sched running");
  if(readeflags()&FL_IF)
    panic("sched interruptible");
  intena = cpu->intena;
  swtch(&proc->context, cpu->scheduler);
  cpu->intena = intena;
}

// Give up the CPU for one scheduling round.
void
yield(void)
{
  acquire(&ptable.lock);  //DOC: yieldlock
  if(proc->state != RUNNABLE) plist.add(&plist, proc->pid, proc); //todo ifdef
  proc->state = RUNNABLE;

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
  if(proc == 0)
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
  proc->chan = chan;
  proc->state = SLEEPING;
  sched();

  // Tidy up.
  proc->chan = 0;

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

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    if(p->state == SLEEPING && p->chan == chan){
        p->state = RUNNABLE;
        plist.add(&plist,p->pid, p); //todo ifdef
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
      if(p->state == SLEEPING){
        p->state = RUNNABLE;
        plist.add(&plist,p->pid,p); //todo ifdef
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
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
      state = states[p->state];
    else
      state = "???";
    cprintf("%d %s %s", p->pid, state, p->name);
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}
