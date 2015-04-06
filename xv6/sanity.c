#include "types.h"
#include "stat.h"
#include "user.h"

#define NUM_OF_CHLIDREN 5
#define CALC_SIZE		2000	//8000 is 1min for 1 proc in Ami's laptop


long getTheNPrimeNumber(int n)
{
	long i=2;
	long j;
	int isPrime = 1;

	for (;;) {
		for (j = 2; j < i && isPrime; ++j) {
			if (i%j == 0){
				isPrime = 0;
				break;
			}
		}
		if (isPrime && ((n--)==1))	return i;
		i++;
		isPrime=1;
	}
}

int
main(int argc, char *argv[])
{
	int i, pid;
	int wtime, rtime, iotime;
	int presence[NUM_OF_CHLIDREN];

	set_priority(PRIORITY_HIGH);
	memset(presence,0,NUM_OF_CHLIDREN);

	printf(1, "NUM_OF_CHLIDREN=%d CALC_SIZE=%d\n",NUM_OF_CHLIDREN, CALC_SIZE);


	for (i = 0; i < NUM_OF_CHLIDREN; ++i) {
		if ((pid = fork()) > 0){	//parent
			printf(1, "(fork:%d)",pid);
		}
		else if (pid == 0){	//child
			set_priority((i%3)+1);
			sleep(100);
			getTheNPrimeNumber(CALC_SIZE);
			exit(getpid());
		}
		else{
			printf(1, "\nERROR: Fork failed\n");
			exit(EXIT_STATUS_FAILURE);
		}
	}
	printf(1,"\n");

	for (i = 0; i < NUM_OF_CHLIDREN; ++i){

		pid = wait_stat(&wtime,&rtime,&iotime);
		if (pid<0){
			printf(1, "\nERROR: Not enought waits.\n");
			exit(EXIT_STATUS_FAILURE);
		}
		//printf(1, "Done(%d) ; ", pid);
		printf(1,"Done(%d): waiting (RUNNABLE): %d | running: %d | turnaround : %d\n",
				pid, wtime, rtime, wtime+rtime+iotime);
		presence[i] = pid;
	}

	for (i = 0; i < NUM_OF_CHLIDREN; ++i){
		if(!presence[i]){
			printf(1, "\nERROR: Not enough waits.\n");
			exit(EXIT_STATUS_FAILURE);
		}
	}
	printf(1, "Success: Great Success!.\n");
	exit(EXIT_STATUS_SUCCESS);
}
