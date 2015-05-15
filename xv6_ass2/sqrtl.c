
#include "types.h"
#include "user.h"

void* printHelloWorld(){
	printf(1,"hello scumbag world, tid: %d \n", kthread_id());
	exit();
}

int
main(void)
{
  printf(1,"testing create thread");
  void* stk = malloc(MAX_STACK_SIZE);
  kthread_create(printHelloWorld, stk, MAX_STACK_SIZE);
  //while(1);
  exit();
}
