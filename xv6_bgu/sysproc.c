#include "types.h"
#include "x86.h"
#include "defs.h"
#include "date.h"
#include "param.h"
#include "memlayout.h"
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
  return fork();
}

int
sys_exit(void)
{
	int status;
	if(argint(0, &status) < 0)
	    return -1;

	exit(status);
	return 0;  // not reached
}

int
sys_wait(void)
{
	int* status;
	//take argument from environment
	if(argptr(0,(char**)&status, sizeof(int)) <0){ //error check
		return -1;
	}
	return wait(status);
}

int
sys_waitpid(void)
{
	int pid;
	int *status;
	int options;

	if (	(argint(0, &pid) < 0) ||
			(argptr(1,(char**)&status, sizeof(int)) < 0) ||
			(argint(2, &options) < 0) ){

		return -1;
	}

	return waitpid(pid, status, options);
}

int
sys_wait_stat(void)
{
	int *wtime, *rtime, *iotime, *status;

	if (	(argptr(0,(char**)&wtime, sizeof(int)) < 0) ||
			(argptr(1,(char**)&rtime, sizeof(int)) < 0) ||
			(argptr(2,(char**)&iotime, sizeof(int)) < 0) ||
			(argptr(3,(char**)&status, sizeof(int)) < 0) ){

		return -1;
	}

	return wait_stat(wtime, rtime, iotime, status);
}

int
sys_list_pgroup(void)
{
	int gid;
	process_info_entry* arr;
	int* size;

	if (	(argint(0, &gid) < 0) ||
			(argptr(1,(char**)&arr, sizeof(process_info_entry)) < 0) ||
			(argptr(2,(char**)&size, sizeof(int)) < 0)){

		return -1;
	}

	return list_pgroup(gid, arr, size);
}

int
sys_foreground(void)
{
	int gid;

	if (argint(0, &gid) < 0){
		return -1;
	}

	return foreground(gid);
}

int
sys_set_priority(void)
{
	int priority;

	if(argint(0, &priority) < 0)
	return -1;
	return set_priority(priority);
}


int
sys_kill(void)
{
  int pid;

  if(argint(0, &pid) < 0)
    return -1;
  return kill(pid);
}

int
sys_getpid(void)
{
  return proc->pid;
}

int
sys_sbrk(void)
{
  int addr;
  int n;

  if(argint(0, &n) < 0)
    return -1;
  addr = proc->sz;
  if(growproc(n) < 0)
    return -1;
  return addr;
}

int
sys_sleep(void)
{
  int n;
  uint ticks0;
  
  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
    if(proc->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
  return 0;
}

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
  uint xticks;
  
  acquire(&tickslock);
  xticks = ticks;
  release(&tickslock);
  return xticks;
}
