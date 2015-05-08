
#include "spinlock.h"

#define MAX_STACK_SIZE 4000
#define MAX_MUTEXES 64


enum threadstate { UNUSED, EMBRYO, SLEEPING, RUNNABLE, RUNNING, ZOMBIE };	//TODO: check what is here

struct thread {
//  uint sz;                     // Size of thread memory (bytes)
//  pde_t* pgdir;                // Page table
  char *kstack;                // Bottom of kernel stack for this process
  enum threadstate state;        // Process state
  int tid;                     // Thread ID
  struct proc *process;         // Parent process
  struct trapframe *tf;        // Trap frame for current syscall
  struct context *context;     // swtch() here to run process
  void *chan;                  // If non-zero, sleeping on chan
//  int killed;                  // If non-zero, have been killed
//  struct file *ofile[NOFILE];  // Open files
//  struct inode *cwd;           // Current directory
//  char name[16];               // Process name (debugging)
};

#define NTHREAD 16

//struct spinlock lock;

struct ttable{
  struct spinlock lock;
  struct thread thread[NTHREAD];	//threads
};

/********************************
        The API of the KLT package
 ********************************/

int kthread_create(void*(*start_func)(), void* stack, uint stack_size);
int kthread_id();
void kthread_exit();
int kthread_join(int thread_id);

int kthread_mutex_alloc();
int kthread_mutex_dealloc(int mutex_id);
int kthread_mutex_lock(int mutex_id);
int kthread_mutex_unlock(int mutex_id);
int kthread_mutex_yieldlock(int mutex_id1, int mutex_id2);

