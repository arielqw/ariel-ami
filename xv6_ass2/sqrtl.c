
#include "types.h"
#include "user.h"



void* ariel(){
	while(1){
		kthread_mutex_lock(1);
		printf(1,"ariel\n");
		kthread_mutex_unlock(1);
	}
	return 0;
}

void* ami(){
	while(1){
		kthread_mutex_lock(1);
		printf(1,"ami\n");
		kthread_mutex_unlock(1);
	}
	return 0;
}


int
main(void)
{
  printf(1,"testing create thread");
  //void* stk1 = malloc(MAX_STACK_SIZE);
  //void* stk2 = malloc(MAX_STACK_SIZE);

  kthread_mutex_alloc();

  //int id1 = kthread_create(ariel, stk1, MAX_STACK_SIZE);
  //int id2 = kthread_create(ami, stk2, MAX_STACK_SIZE);
//
  //kthread_join(id1);
  //kthread_join(id2);

  //printf(1,"done joining %d \n");

  kthread_exit();
  return 0;
}
