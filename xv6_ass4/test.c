#include "types.h"
#include "stat.h"
#include "user.h"

int
main(int argc, char *argv[])
{
  printf(1, " Hello World \n");
  open("/cat", 0);
  sleep(100000);
  exit();
}
