
#include "types.h"
#include "user.h"

int mutexA;
int mutexB;

void* waitingThread(){

	kthread_mutex_lock(mutexA);

	kthread_mutex_unlock(mutexB);

	kthread_mutex_unlock(mutexA);

	kthread_exit();
	return 0;
}

void* signalingThread(){
	kthread_mutex_lock(mutexB);
//	kthread_mutex_unlock(mutexB);

	kthread_mutex_yieldlock(mutexB,mutexA);
	kthread_exit();
	return 0;
}

int
main(void)
{
  printf(1,"testing mutex yield\n");

  mutexA = kthread_mutex_alloc();
  mutexB = kthread_mutex_alloc();

  kthread_mutex_lock(mutexA);

  void* stk1 = malloc(MAX_STACK_SIZE);
  void* stk2 = malloc(MAX_STACK_SIZE);
  int id1 = kthread_create(waitingThread, stk1, MAX_STACK_SIZE);
  int id2 = kthread_create(signalingThread, stk2, MAX_STACK_SIZE);

  kthread_join(id2);
  kthread_mutex_unlock(mutexA);
  kthread_join(id1);


  printf(1,"done\n");

  kthread_exit();
  return 0;
}
