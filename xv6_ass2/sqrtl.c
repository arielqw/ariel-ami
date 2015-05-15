
#include "types.h"
#include "user.h"

void* printHelloWorld(){
	int i;
	for(i = 0; i < 3; i++){
		printf(1," aa %d\n",i);
	}
	printf(1,"hello scumbag world, tid: %d \n", kthread_id());
	kthread_exit();
	return 0;
}

int
main(void)
{
  printf(1,"testing create thread");
  void* stk = malloc(MAX_STACK_SIZE);
  int id = kthread_create(printHelloWorld, stk, MAX_STACK_SIZE);

  printf(1,"joining %d \n",id);
  kthread_join(id);

  printf(1,"done joining %d \n");

  kthread_exit();
  return 0;
}
