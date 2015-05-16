
#include "types.h"
#include "user.h"
#include "mesa_cond.h"

int resource_mutex;
mesa_cond_t* cv;

void* worker(){

	kthread_mutex_lock(resource_mutex);

	printf(1,"worker | worker working..");

	mesa_cond_signal(cv);
	printf(1,"worker | signaled");

	kthread_mutex_unlock(resource_mutex);
	kthread_exit();
	return 0;
}


int
main(void)
{
  printf(1,"main | testing messa \n");
  cv = mesa_cond_alloc();

  resource_mutex = kthread_mutex_alloc();

  kthread_mutex_lock(resource_mutex);

  void* stk1 = malloc(MAX_STACK_SIZE);
  int id1 = kthread_create(worker, stk1, MAX_STACK_SIZE);

  printf(1,"main | sleeping some.. \n");

  sleep(300);
  mesa_cond_wait(cv,resource_mutex);

  printf(1,"main | back from wait.. \n");

  kthread_mutex_unlock(resource_mutex);

  kthread_join(id1);

  mesa_cond_dealloc(cv);

  printf(1,"main | done\n");

  kthread_exit();
  return 0;
}
