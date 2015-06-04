#include "types.h"
#include "user.h"


#define PAGE_SIZE 4096


void testPageAccess()
{
 //int i;
 int* arr = (int*)sbrk(PAGE_SIZE*101); //size of array is 103424
 //printf(1, "%d\n", arr);

 //sbrk(-PAGE_SIZE*101); //size of array is 103424

 //arr++;
// for (i = 0; i < 103424; ++i) {
//  arr[i]=1;
// }

 //touch page 0
 arr[PAGE_SIZE/4*0 + 15]  = 1;
 arr[PAGE_SIZE/4*0 + 900]  = 1;



 //touch page 14
 arr[PAGE_SIZE/4*14 + 152] = 1;
 arr[PAGE_SIZE/4*14 + 533] = 1;
 arr[PAGE_SIZE/4*14 + 700] = 1;

 //touch page 37
 arr[PAGE_SIZE/4*37 + 566] = 1;

}

void testFork()
{


 int* arr = (int*)malloc(PAGE_SIZE*101); //size of array is 103424

 if (fork() == 0)
 {
  arr[PAGE_SIZE/4*11 + 500] = 123;
  exit();
 }
 arr[PAGE_SIZE/4*14 + 700] = 456;
 wait();
 printf(1, "%d,%d", arr[PAGE_SIZE/4*11 + 500], arr[PAGE_SIZE/4*14 + 700]);

}


int
main(int argc, char *argv[])
{
 //testPageAccess();
 testFork();
 exit();

}
