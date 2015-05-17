#include "types.h"
#include "user.h"
#include "kthread.h"
#include "mesa_slots_monitor.h"

mesa_slots_monitor_t* monitor;
//int isGraderRunning = 1;

#define M 10		//num of students
#define N 3		//num of slots added each time

int isGraderRunning = 1;

void* student(){
	printf(1,"student | started..\n");
	mesa_slots_monitor_takeslot(monitor);
	printf(1,"student | done.\n");
	kthread_exit();
	return 0;
}

void* grader(){
	printf(1,"grader | started..\n");
	while (isGraderRunning)
	{
		mesa_slots_monitor_addslots(monitor, N);
	}
	printf(1,"grader | done.\n");
	kthread_exit();
	return 0;
}

int
main(void)
{
  printf(1,"main | slots_mesa | start\n");
  monitor = mesa_slots_monitor_alloc();

  void* studentsStacks[M];
  int studentsThreadIds[M];
  int i;
  for (i = 0; i < M; ++i) {
	  studentsStacks[i] = malloc(MAX_STACK_SIZE);
	  studentsThreadIds[i] = kthread_create(student, studentsStacks[i], MAX_STACK_SIZE);
  }

  void* graderStack = malloc(MAX_STACK_SIZE);
  int graderThreadId = kthread_create(grader, graderStack, MAX_STACK_SIZE);

  for (i = 0; i < M; ++i) {
	  kthread_join(studentsThreadIds[i]);
	  free(studentsStacks[i]);
  }
  isGraderRunning = 0;
  mesa_slots_monitor_stopadding(monitor);
  kthread_join(graderThreadId);

  mesa_slots_monitor_dealloc(monitor);

  printf(1,"main | slots_mesa | done\n");

  kthread_exit();
  return 0;
}
