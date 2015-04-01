#include "types.h"
#include "stat.h"
#include "user.h"

int test_wait();
int test_waitpid();


/*
 * testing working wait(status)
 */
int main(int argc, char *argv[]){

	test_wait();
	test_waitpid(BLOCKING);
	test_waitpid(NONBLOCKING);

	exit(1);
	return 0;
}

/* testing working wait(status)*/
int test_waitpid(int option){
	printf(1, "*** Testing waitpid *** \n");

	printf(1, "check invalid son: %d \n", waitpid(666,0,0));
	int stat;
	int childStatus = 9;
	int pid;

	if( !( pid = fork() )  ){
		sleep(1000);
	  printf(1, "Exiting with status: %d \n", childStatus);
	  exit(childStatus);
	}
	//parent
	switch (option) {
		case BLOCKING:
			printf(1, "testing BLOCKING \n");
			printf(1, "waitpid returns: %d \n", waitpid(pid,&stat,option));
			break;
		case NONBLOCKING:
			printf(1, "testing NONBLOCKING \n");
			printf(1, "waitpid returns: %d \n", waitpid(pid,&stat,option));
			break;
		default:
			break;
	}


	printf(1, "child exited with status: %d \n", stat);
	;
	return 0;
}


/* testing working wait(status)*/
int test_wait(){
	printf(1, "*** Testing wait(status) *** \n");
	int stat;
	int childStatus = 7;
	  printf(1,"Ruby Sapphire attack! \n");

	  if( !fork() ){
		  printf(1, "Exiting with status: %d \n", childStatus);
		  exit(childStatus);
	  }
	  //parent
	  wait(&stat);
	  printf(1, "child exited with status: %d \n", stat);

	  return 0;
}