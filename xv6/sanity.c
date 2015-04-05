#include "types.h"
#include "stat.h"
#include "user.h"

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
  printf(1, "%d\n", getTheNPrimeNumber(8000));	//8000 is about a minute
  exit(EXIT_STATUS_SUCCESS);
}
