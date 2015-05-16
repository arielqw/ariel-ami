
#include "types.h"
#include "user.h"



void* ariel(){
	int var;
	for (var = 0; var < 1; ++var) {
		kthread_mutex_lock(1);
		printf(1,"ariel\n");
		kthread_mutex_unlock(1);
	}
	kthread_exit();
	return 0;
}

void* ami(){
	int var;
	for (var = 0; var < 1; ++var) {
		kthread_mutex_lock(1);
		printf(1,"ami\n");
		kthread_mutex_unlock(1);
	}
	kthread_exit();
	return 0;
}


int
main(void)
{
  printf(1,"testing create thread");
  void* stk1 = malloc(MAX_STACK_SIZE);
  void* stk2 = malloc(MAX_STACK_SIZE);

  int mutexid = kthread_mutex_alloc();
  printf(1,"allocated mutex id %d\n", mutexid);

  int id1 = kthread_create(ariel, stk1, MAX_STACK_SIZE);
  int id2 = kthread_create(ami, stk2, MAX_STACK_SIZE);

  kthread_join(id1);
  kthread_join(id2);

  printf(1,"done joining\n");

  kthread_exit();
  return 0;
}
