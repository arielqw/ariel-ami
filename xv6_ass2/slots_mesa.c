#include "types.h"
#include "user.h"
#include "kthread.h"
#include "mesa_slots_monitor.h"

int
main(void)
{
  int i;
  printf(1,"main | testing mesa monitor \n");

  mesa_slots_monitor_t* monitor = mesa_slots_monitor_alloc();

  mesa_slots_monitor_addslots(monitor, 5);
  for(i = 0; i< 5; i++){
//	  mesa_slots_monitor_takeslot(monitor);
  }
  mesa_slots_monitor_dealloc(monitor);

  printf(1,"main | done\n");

  kthread_exit();
  return 0;
}

