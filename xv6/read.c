#include "types.h"
#include "stat.h"
#include "user.h"

int
main(int argc, char *argv[])
{
  char c = -1;
  //int wtime, rtime, iotime;
  while (c!='q')  {
	  if (c!=-1){
		  if (write(1,&c,1) != 1)	exit(EXIT_STATUS_FAILURE);
	  }

//	  if (c=='p')
//	  {
//		  wait_stat(&wtime, &rtime, &iotime);
//		  printf(1, "wtime %d, rtime %d, iotime %d", wtime, rtime, iotime);
//	  }

	  if (read(0,&c,1) != 1)	exit(EXIT_STATUS_FAILURE);
  }
  exit(EXIT_STATUS_SUCCESS);
}
