#include "types.h"
#include "user.h"
#include "kthread.h"
#include "mesa_slots_monitor.h"

mesa_slots_monitor_t* monitor;

void* student(){
	printf(1,"student | started..");
	int i;
	for(i = 0; i< 6; i++){
		mesa_slots_monitor_takeslot(monitor);
	}

	kthread_exit();
	return 0;
}


int
main(void)
{
  printf(1,"main | testing mesa monitor \n");
  monitor = mesa_slots_monitor_alloc();

  void* stk1 = malloc(MAX_STACK_SIZE);
  kthread_create(student, stk1, MAX_STACK_SIZE);

  mesa_slots_monitor_addslots(monitor, 5);
  mesa_slots_monitor_addslots(monitor, 2);

  mesa_slots_monitor_dealloc(monitor);

  printf(1,"main | done\n");

  kthread_exit();
  return 0;
}

