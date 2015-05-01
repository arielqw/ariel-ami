#include "types.h"
#include "stat.h"
#include "user.h"

int
main(int argc, char *argv[])
{
	char c[2] = {0,0};
	int pos = 0;

	while(1){
		read(0,&c[pos],1);
		write(1,&c[pos],1);

		if(c[pos] == '\n' && c[!pos] == 'q'){
			exit(0);
		}

		pos = !pos;

	}
	return 0;
}
