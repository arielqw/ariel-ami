
_sanity:     file format elf32-i386


Disassembly of section .text:

00000000 <getTheNPrimeNumber>:
#define NUM_OF_CHLIDREN 5
#define CALC_SIZE		2000	//8000 is 1min for 1 proc in Ami's laptop


long getTheNPrimeNumber(int n)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 ec 10             	sub    $0x10,%esp
	long i=2;
   6:	c7 45 fc 02 00 00 00 	movl   $0x2,-0x4(%ebp)
	long j;
	int isPrime = 1;
   d:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)

	for (;;) {
		for (j = 2; j < i && isPrime; ++j) {
  14:	c7 45 f8 02 00 00 00 	movl   $0x2,-0x8(%ebp)
  1b:	eb 1e                	jmp    3b <getTheNPrimeNumber+0x3b>
			if (i%j == 0){
  1d:	8b 45 fc             	mov    -0x4(%ebp),%eax
  20:	89 c2                	mov    %eax,%edx
  22:	c1 fa 1f             	sar    $0x1f,%edx
  25:	f7 7d f8             	idivl  -0x8(%ebp)
  28:	89 d0                	mov    %edx,%eax
  2a:	85 c0                	test   %eax,%eax
  2c:	75 09                	jne    37 <getTheNPrimeNumber+0x37>
				isPrime = 0;
  2e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
				break;
  35:	eb 12                	jmp    49 <getTheNPrimeNumber+0x49>
	long i=2;
	long j;
	int isPrime = 1;

	for (;;) {
		for (j = 2; j < i && isPrime; ++j) {
  37:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
  3b:	8b 45 f8             	mov    -0x8(%ebp),%eax
  3e:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  41:	7d 06                	jge    49 <getTheNPrimeNumber+0x49>
  43:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  47:	75 d4                	jne    1d <getTheNPrimeNumber+0x1d>
			if (i%j == 0){
				isPrime = 0;
				break;
			}
		}
		if (isPrime && ((n--)==1))	return i;
  49:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  4d:	74 14                	je     63 <getTheNPrimeNumber+0x63>
  4f:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
  53:	0f 94 c0             	sete   %al
  56:	83 6d 08 01          	subl   $0x1,0x8(%ebp)
  5a:	84 c0                	test   %al,%al
  5c:	74 05                	je     63 <getTheNPrimeNumber+0x63>
  5e:	8b 45 fc             	mov    -0x4(%ebp),%eax
		i++;
		isPrime=1;
	}
}
  61:	c9                   	leave  
  62:	c3                   	ret    
				isPrime = 0;
				break;
			}
		}
		if (isPrime && ((n--)==1))	return i;
		i++;
  63:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
		isPrime=1;
  67:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
	}
  6e:	eb a4                	jmp    14 <getTheNPrimeNumber+0x14>

00000070 <set_priority>:
}

int set_priority(int priority){return 0;}
  70:	55                   	push   %ebp
  71:	89 e5                	mov    %esp,%ebp
  73:	b8 00 00 00 00       	mov    $0x0,%eax
  78:	5d                   	pop    %ebp
  79:	c3                   	ret    

0000007a <main>:
			pid, wtime, rtime, wtime+rtime+iotime);
}
*/
int
main(int argc, char *argv[])
{
  7a:	55                   	push   %ebp
  7b:	89 e5                	mov    %esp,%ebp
  7d:	83 e4 f0             	and    $0xfffffff0,%esp
  80:	83 ec 50             	sub    $0x50,%esp
	int i, pid;
	int wtime, rtime, iotime;
	int presence[NUM_OF_CHLIDREN];

	set_priority(PRIORITY_HIGH);
  83:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8a:	e8 e1 ff ff ff       	call   70 <set_priority>
	memset(presence,0,NUM_OF_CHLIDREN);
  8f:	c7 44 24 08 05 00 00 	movl   $0x5,0x8(%esp)
  96:	00 
  97:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  9e:	00 
  9f:	8d 44 24 28          	lea    0x28(%esp),%eax
  a3:	89 04 24             	mov    %eax,(%esp)
  a6:	e8 cc 02 00 00       	call   377 <memset>

	printf(1, "NUM_OF_CHLIDREN=%d CALC_SIZE=%d\n",NUM_OF_CHLIDREN, CALC_SIZE);
  ab:	c7 44 24 0c d0 07 00 	movl   $0x7d0,0xc(%esp)
  b2:	00 
  b3:	c7 44 24 08 05 00 00 	movl   $0x5,0x8(%esp)
  ba:	00 
  bb:	c7 44 24 04 78 0a 00 	movl   $0xa78,0x4(%esp)
  c2:	00 
  c3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  ca:	e8 e4 05 00 00       	call   6b3 <printf>


	for (i = 0; i < NUM_OF_CHLIDREN; ++i) {
  cf:	c7 44 24 4c 00 00 00 	movl   $0x0,0x4c(%esp)
  d6:	00 
  d7:	e9 a8 00 00 00       	jmp    184 <main+0x10a>
		if ((pid = fork()) > 0){	//parent
  dc:	e8 33 04 00 00       	call   514 <fork>
  e1:	89 44 24 48          	mov    %eax,0x48(%esp)
  e5:	83 7c 24 48 00       	cmpl   $0x0,0x48(%esp)
  ea:	7e 23                	jle    10f <main+0x95>
			printf(1, "(fork:%d)",pid);
  ec:	8b 44 24 48          	mov    0x48(%esp),%eax
  f0:	89 44 24 08          	mov    %eax,0x8(%esp)
  f4:	c7 44 24 04 99 0a 00 	movl   $0xa99,0x4(%esp)
  fb:	00 
  fc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 103:	e8 ab 05 00 00       	call   6b3 <printf>
	memset(presence,0,NUM_OF_CHLIDREN);

	printf(1, "NUM_OF_CHLIDREN=%d CALC_SIZE=%d\n",NUM_OF_CHLIDREN, CALC_SIZE);


	for (i = 0; i < NUM_OF_CHLIDREN; ++i) {
 108:	83 44 24 4c 01       	addl   $0x1,0x4c(%esp)
 10d:	eb 75                	jmp    184 <main+0x10a>
		if ((pid = fork()) > 0){	//parent
			printf(1, "(fork:%d)",pid);
		}
		else if (pid == 0){	//child
 10f:	83 7c 24 48 00       	cmpl   $0x0,0x48(%esp)
 114:	75 4e                	jne    164 <main+0xea>
			set_priority((i%3)+1);
 116:	8b 4c 24 4c          	mov    0x4c(%esp),%ecx
 11a:	ba 56 55 55 55       	mov    $0x55555556,%edx
 11f:	89 c8                	mov    %ecx,%eax
 121:	f7 ea                	imul   %edx
 123:	89 c8                	mov    %ecx,%eax
 125:	c1 f8 1f             	sar    $0x1f,%eax
 128:	29 c2                	sub    %eax,%edx
 12a:	89 d0                	mov    %edx,%eax
 12c:	01 c0                	add    %eax,%eax
 12e:	01 d0                	add    %edx,%eax
 130:	89 ca                	mov    %ecx,%edx
 132:	29 c2                	sub    %eax,%edx
 134:	8d 42 01             	lea    0x1(%edx),%eax
 137:	89 04 24             	mov    %eax,(%esp)
 13a:	e8 31 ff ff ff       	call   70 <set_priority>
			sleep(100);
 13f:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
 146:	e8 61 04 00 00       	call   5ac <sleep>
			getTheNPrimeNumber(CALC_SIZE);
 14b:	c7 04 24 d0 07 00 00 	movl   $0x7d0,(%esp)
 152:	e8 a9 fe ff ff       	call   0 <getTheNPrimeNumber>
			exit(getpid());
 157:	e8 40 04 00 00       	call   59c <getpid>
 15c:	89 04 24             	mov    %eax,(%esp)
 15f:	e8 b8 03 00 00       	call   51c <exit>
		}
		else{
			printf(1, "\nERROR: Fork failed\n");
 164:	c7 44 24 04 a3 0a 00 	movl   $0xaa3,0x4(%esp)
 16b:	00 
 16c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 173:	e8 3b 05 00 00       	call   6b3 <printf>
			exit(EXIT_STATUS_FAILURE);
 178:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 17f:	e8 98 03 00 00       	call   51c <exit>
	memset(presence,0,NUM_OF_CHLIDREN);

	printf(1, "NUM_OF_CHLIDREN=%d CALC_SIZE=%d\n",NUM_OF_CHLIDREN, CALC_SIZE);


	for (i = 0; i < NUM_OF_CHLIDREN; ++i) {
 184:	83 7c 24 4c 04       	cmpl   $0x4,0x4c(%esp)
 189:	0f 8e 4d ff ff ff    	jle    dc <main+0x62>
		else{
			printf(1, "\nERROR: Fork failed\n");
			exit(EXIT_STATUS_FAILURE);
		}
	}
	printf(1,"\n");
 18f:	c7 44 24 04 b8 0a 00 	movl   $0xab8,0x4(%esp)
 196:	00 
 197:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 19e:	e8 10 05 00 00       	call   6b3 <printf>

	for (i = 0; i < NUM_OF_CHLIDREN; ++i){
 1a3:	c7 44 24 4c 00 00 00 	movl   $0x0,0x4c(%esp)
 1aa:	00 
 1ab:	e9 99 00 00 00       	jmp    249 <main+0x1cf>

		pid = wait_stat(&wtime,&rtime,&iotime);
 1b0:	8d 44 24 3c          	lea    0x3c(%esp),%eax
 1b4:	89 44 24 08          	mov    %eax,0x8(%esp)
 1b8:	8d 44 24 40          	lea    0x40(%esp),%eax
 1bc:	89 44 24 04          	mov    %eax,0x4(%esp)
 1c0:	8d 44 24 44          	lea    0x44(%esp),%eax
 1c4:	89 04 24             	mov    %eax,(%esp)
 1c7:	e8 f8 03 00 00       	call   5c4 <wait_stat>
 1cc:	89 44 24 48          	mov    %eax,0x48(%esp)
		if (pid<0){
 1d0:	83 7c 24 48 00       	cmpl   $0x0,0x48(%esp)
 1d5:	79 20                	jns    1f7 <main+0x17d>
			printf(1, "\nERROR: Not enought waits.\n");
 1d7:	c7 44 24 04 ba 0a 00 	movl   $0xaba,0x4(%esp)
 1de:	00 
 1df:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 1e6:	e8 c8 04 00 00       	call   6b3 <printf>
			exit(EXIT_STATUS_FAILURE);
 1eb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 1f2:	e8 25 03 00 00       	call   51c <exit>
		}
		//printf(1, "Done(%d) ; ", pid);
		printf(1,"Done(%d): waiting (RUNNABLE): %d | running: %d | turnaround : %d\n",
				pid, wtime, rtime, wtime+rtime+iotime);
 1f7:	8b 54 24 44          	mov    0x44(%esp),%edx
 1fb:	8b 44 24 40          	mov    0x40(%esp),%eax
 1ff:	01 c2                	add    %eax,%edx
		if (pid<0){
			printf(1, "\nERROR: Not enought waits.\n");
			exit(EXIT_STATUS_FAILURE);
		}
		//printf(1, "Done(%d) ; ", pid);
		printf(1,"Done(%d): waiting (RUNNABLE): %d | running: %d | turnaround : %d\n",
 201:	8b 44 24 3c          	mov    0x3c(%esp),%eax
 205:	8d 0c 02             	lea    (%edx,%eax,1),%ecx
 208:	8b 54 24 40          	mov    0x40(%esp),%edx
 20c:	8b 44 24 44          	mov    0x44(%esp),%eax
 210:	89 4c 24 14          	mov    %ecx,0x14(%esp)
 214:	89 54 24 10          	mov    %edx,0x10(%esp)
 218:	89 44 24 0c          	mov    %eax,0xc(%esp)
 21c:	8b 44 24 48          	mov    0x48(%esp),%eax
 220:	89 44 24 08          	mov    %eax,0x8(%esp)
 224:	c7 44 24 04 d8 0a 00 	movl   $0xad8,0x4(%esp)
 22b:	00 
 22c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 233:	e8 7b 04 00 00       	call   6b3 <printf>
				pid, wtime, rtime, wtime+rtime+iotime);
		presence[i] = pid;
 238:	8b 44 24 4c          	mov    0x4c(%esp),%eax
 23c:	8b 54 24 48          	mov    0x48(%esp),%edx
 240:	89 54 84 28          	mov    %edx,0x28(%esp,%eax,4)
			exit(EXIT_STATUS_FAILURE);
		}
	}
	printf(1,"\n");

	for (i = 0; i < NUM_OF_CHLIDREN; ++i){
 244:	83 44 24 4c 01       	addl   $0x1,0x4c(%esp)
 249:	83 7c 24 4c 04       	cmpl   $0x4,0x4c(%esp)
 24e:	0f 8e 5c ff ff ff    	jle    1b0 <main+0x136>
		printf(1,"Done(%d): waiting (RUNNABLE): %d | running: %d | turnaround : %d\n",
				pid, wtime, rtime, wtime+rtime+iotime);
		presence[i] = pid;
	}

	for (i = 0; i < NUM_OF_CHLIDREN; ++i){
 254:	c7 44 24 4c 00 00 00 	movl   $0x0,0x4c(%esp)
 25b:	00 
 25c:	eb 31                	jmp    28f <main+0x215>
		if(!presence[i]){
 25e:	8b 44 24 4c          	mov    0x4c(%esp),%eax
 262:	8b 44 84 28          	mov    0x28(%esp,%eax,4),%eax
 266:	85 c0                	test   %eax,%eax
 268:	75 20                	jne    28a <main+0x210>
			printf(1, "\nERROR: Not enough waits.\n");
 26a:	c7 44 24 04 1a 0b 00 	movl   $0xb1a,0x4(%esp)
 271:	00 
 272:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 279:	e8 35 04 00 00       	call   6b3 <printf>
			exit(EXIT_STATUS_FAILURE);
 27e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 285:	e8 92 02 00 00       	call   51c <exit>
		printf(1,"Done(%d): waiting (RUNNABLE): %d | running: %d | turnaround : %d\n",
				pid, wtime, rtime, wtime+rtime+iotime);
		presence[i] = pid;
	}

	for (i = 0; i < NUM_OF_CHLIDREN; ++i){
 28a:	83 44 24 4c 01       	addl   $0x1,0x4c(%esp)
 28f:	83 7c 24 4c 04       	cmpl   $0x4,0x4c(%esp)
 294:	7e c8                	jle    25e <main+0x1e4>
		if(!presence[i]){
			printf(1, "\nERROR: Not enough waits.\n");
			exit(EXIT_STATUS_FAILURE);
		}
	}
	printf(1, "Success: Great Success!.\n");
 296:	c7 44 24 04 35 0b 00 	movl   $0xb35,0x4(%esp)
 29d:	00 
 29e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 2a5:	e8 09 04 00 00       	call   6b3 <printf>
	exit(EXIT_STATUS_SUCCESS);
 2aa:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 2b1:	e8 66 02 00 00       	call   51c <exit>
 2b6:	90                   	nop
 2b7:	90                   	nop

000002b8 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 2b8:	55                   	push   %ebp
 2b9:	89 e5                	mov    %esp,%ebp
 2bb:	57                   	push   %edi
 2bc:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 2bd:	8b 4d 08             	mov    0x8(%ebp),%ecx
 2c0:	8b 55 10             	mov    0x10(%ebp),%edx
 2c3:	8b 45 0c             	mov    0xc(%ebp),%eax
 2c6:	89 cb                	mov    %ecx,%ebx
 2c8:	89 df                	mov    %ebx,%edi
 2ca:	89 d1                	mov    %edx,%ecx
 2cc:	fc                   	cld    
 2cd:	f3 aa                	rep stos %al,%es:(%edi)
 2cf:	89 ca                	mov    %ecx,%edx
 2d1:	89 fb                	mov    %edi,%ebx
 2d3:	89 5d 08             	mov    %ebx,0x8(%ebp)
 2d6:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 2d9:	5b                   	pop    %ebx
 2da:	5f                   	pop    %edi
 2db:	5d                   	pop    %ebp
 2dc:	c3                   	ret    

000002dd <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 2dd:	55                   	push   %ebp
 2de:	89 e5                	mov    %esp,%ebp
 2e0:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 2e3:	8b 45 08             	mov    0x8(%ebp),%eax
 2e6:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 2e9:	90                   	nop
 2ea:	8b 45 0c             	mov    0xc(%ebp),%eax
 2ed:	0f b6 10             	movzbl (%eax),%edx
 2f0:	8b 45 08             	mov    0x8(%ebp),%eax
 2f3:	88 10                	mov    %dl,(%eax)
 2f5:	8b 45 08             	mov    0x8(%ebp),%eax
 2f8:	0f b6 00             	movzbl (%eax),%eax
 2fb:	84 c0                	test   %al,%al
 2fd:	0f 95 c0             	setne  %al
 300:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 304:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 308:	84 c0                	test   %al,%al
 30a:	75 de                	jne    2ea <strcpy+0xd>
    ;
  return os;
 30c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 30f:	c9                   	leave  
 310:	c3                   	ret    

00000311 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 311:	55                   	push   %ebp
 312:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 314:	eb 08                	jmp    31e <strcmp+0xd>
    p++, q++;
 316:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 31a:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 31e:	8b 45 08             	mov    0x8(%ebp),%eax
 321:	0f b6 00             	movzbl (%eax),%eax
 324:	84 c0                	test   %al,%al
 326:	74 10                	je     338 <strcmp+0x27>
 328:	8b 45 08             	mov    0x8(%ebp),%eax
 32b:	0f b6 10             	movzbl (%eax),%edx
 32e:	8b 45 0c             	mov    0xc(%ebp),%eax
 331:	0f b6 00             	movzbl (%eax),%eax
 334:	38 c2                	cmp    %al,%dl
 336:	74 de                	je     316 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 338:	8b 45 08             	mov    0x8(%ebp),%eax
 33b:	0f b6 00             	movzbl (%eax),%eax
 33e:	0f b6 d0             	movzbl %al,%edx
 341:	8b 45 0c             	mov    0xc(%ebp),%eax
 344:	0f b6 00             	movzbl (%eax),%eax
 347:	0f b6 c0             	movzbl %al,%eax
 34a:	89 d1                	mov    %edx,%ecx
 34c:	29 c1                	sub    %eax,%ecx
 34e:	89 c8                	mov    %ecx,%eax
}
 350:	5d                   	pop    %ebp
 351:	c3                   	ret    

00000352 <strlen>:

uint
strlen(char *s)
{
 352:	55                   	push   %ebp
 353:	89 e5                	mov    %esp,%ebp
 355:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 358:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 35f:	eb 04                	jmp    365 <strlen+0x13>
 361:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 365:	8b 45 fc             	mov    -0x4(%ebp),%eax
 368:	03 45 08             	add    0x8(%ebp),%eax
 36b:	0f b6 00             	movzbl (%eax),%eax
 36e:	84 c0                	test   %al,%al
 370:	75 ef                	jne    361 <strlen+0xf>
    ;
  return n;
 372:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 375:	c9                   	leave  
 376:	c3                   	ret    

00000377 <memset>:

void*
memset(void *dst, int c, uint n)
{
 377:	55                   	push   %ebp
 378:	89 e5                	mov    %esp,%ebp
 37a:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 37d:	8b 45 10             	mov    0x10(%ebp),%eax
 380:	89 44 24 08          	mov    %eax,0x8(%esp)
 384:	8b 45 0c             	mov    0xc(%ebp),%eax
 387:	89 44 24 04          	mov    %eax,0x4(%esp)
 38b:	8b 45 08             	mov    0x8(%ebp),%eax
 38e:	89 04 24             	mov    %eax,(%esp)
 391:	e8 22 ff ff ff       	call   2b8 <stosb>
  return dst;
 396:	8b 45 08             	mov    0x8(%ebp),%eax
}
 399:	c9                   	leave  
 39a:	c3                   	ret    

0000039b <strchr>:

char*
strchr(const char *s, char c)
{
 39b:	55                   	push   %ebp
 39c:	89 e5                	mov    %esp,%ebp
 39e:	83 ec 04             	sub    $0x4,%esp
 3a1:	8b 45 0c             	mov    0xc(%ebp),%eax
 3a4:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 3a7:	eb 14                	jmp    3bd <strchr+0x22>
    if(*s == c)
 3a9:	8b 45 08             	mov    0x8(%ebp),%eax
 3ac:	0f b6 00             	movzbl (%eax),%eax
 3af:	3a 45 fc             	cmp    -0x4(%ebp),%al
 3b2:	75 05                	jne    3b9 <strchr+0x1e>
      return (char*)s;
 3b4:	8b 45 08             	mov    0x8(%ebp),%eax
 3b7:	eb 13                	jmp    3cc <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 3b9:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 3bd:	8b 45 08             	mov    0x8(%ebp),%eax
 3c0:	0f b6 00             	movzbl (%eax),%eax
 3c3:	84 c0                	test   %al,%al
 3c5:	75 e2                	jne    3a9 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 3c7:	b8 00 00 00 00       	mov    $0x0,%eax
}
 3cc:	c9                   	leave  
 3cd:	c3                   	ret    

000003ce <gets>:

char*
gets(char *buf, int max)
{
 3ce:	55                   	push   %ebp
 3cf:	89 e5                	mov    %esp,%ebp
 3d1:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 3d4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 3db:	eb 44                	jmp    421 <gets+0x53>
    cc = read(0, &c, 1);
 3dd:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 3e4:	00 
 3e5:	8d 45 ef             	lea    -0x11(%ebp),%eax
 3e8:	89 44 24 04          	mov    %eax,0x4(%esp)
 3ec:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 3f3:	e8 3c 01 00 00       	call   534 <read>
 3f8:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 3fb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 3ff:	7e 2d                	jle    42e <gets+0x60>
      break;
    buf[i++] = c;
 401:	8b 45 f4             	mov    -0xc(%ebp),%eax
 404:	03 45 08             	add    0x8(%ebp),%eax
 407:	0f b6 55 ef          	movzbl -0x11(%ebp),%edx
 40b:	88 10                	mov    %dl,(%eax)
 40d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(c == '\n' || c == '\r')
 411:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 415:	3c 0a                	cmp    $0xa,%al
 417:	74 16                	je     42f <gets+0x61>
 419:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 41d:	3c 0d                	cmp    $0xd,%al
 41f:	74 0e                	je     42f <gets+0x61>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 421:	8b 45 f4             	mov    -0xc(%ebp),%eax
 424:	83 c0 01             	add    $0x1,%eax
 427:	3b 45 0c             	cmp    0xc(%ebp),%eax
 42a:	7c b1                	jl     3dd <gets+0xf>
 42c:	eb 01                	jmp    42f <gets+0x61>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 42e:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 42f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 432:	03 45 08             	add    0x8(%ebp),%eax
 435:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 438:	8b 45 08             	mov    0x8(%ebp),%eax
}
 43b:	c9                   	leave  
 43c:	c3                   	ret    

0000043d <stat>:

int
stat(char *n, struct stat *st)
{
 43d:	55                   	push   %ebp
 43e:	89 e5                	mov    %esp,%ebp
 440:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 443:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 44a:	00 
 44b:	8b 45 08             	mov    0x8(%ebp),%eax
 44e:	89 04 24             	mov    %eax,(%esp)
 451:	e8 06 01 00 00       	call   55c <open>
 456:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 459:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 45d:	79 07                	jns    466 <stat+0x29>
    return -1;
 45f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 464:	eb 23                	jmp    489 <stat+0x4c>
  r = fstat(fd, st);
 466:	8b 45 0c             	mov    0xc(%ebp),%eax
 469:	89 44 24 04          	mov    %eax,0x4(%esp)
 46d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 470:	89 04 24             	mov    %eax,(%esp)
 473:	e8 fc 00 00 00       	call   574 <fstat>
 478:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 47b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 47e:	89 04 24             	mov    %eax,(%esp)
 481:	e8 be 00 00 00       	call   544 <close>
  return r;
 486:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 489:	c9                   	leave  
 48a:	c3                   	ret    

0000048b <atoi>:

int
atoi(const char *s)
{
 48b:	55                   	push   %ebp
 48c:	89 e5                	mov    %esp,%ebp
 48e:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 491:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 498:	eb 23                	jmp    4bd <atoi+0x32>
    n = n*10 + *s++ - '0';
 49a:	8b 55 fc             	mov    -0x4(%ebp),%edx
 49d:	89 d0                	mov    %edx,%eax
 49f:	c1 e0 02             	shl    $0x2,%eax
 4a2:	01 d0                	add    %edx,%eax
 4a4:	01 c0                	add    %eax,%eax
 4a6:	89 c2                	mov    %eax,%edx
 4a8:	8b 45 08             	mov    0x8(%ebp),%eax
 4ab:	0f b6 00             	movzbl (%eax),%eax
 4ae:	0f be c0             	movsbl %al,%eax
 4b1:	01 d0                	add    %edx,%eax
 4b3:	83 e8 30             	sub    $0x30,%eax
 4b6:	89 45 fc             	mov    %eax,-0x4(%ebp)
 4b9:	83 45 08 01          	addl   $0x1,0x8(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 4bd:	8b 45 08             	mov    0x8(%ebp),%eax
 4c0:	0f b6 00             	movzbl (%eax),%eax
 4c3:	3c 2f                	cmp    $0x2f,%al
 4c5:	7e 0a                	jle    4d1 <atoi+0x46>
 4c7:	8b 45 08             	mov    0x8(%ebp),%eax
 4ca:	0f b6 00             	movzbl (%eax),%eax
 4cd:	3c 39                	cmp    $0x39,%al
 4cf:	7e c9                	jle    49a <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 4d1:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 4d4:	c9                   	leave  
 4d5:	c3                   	ret    

000004d6 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 4d6:	55                   	push   %ebp
 4d7:	89 e5                	mov    %esp,%ebp
 4d9:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 4dc:	8b 45 08             	mov    0x8(%ebp),%eax
 4df:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 4e2:	8b 45 0c             	mov    0xc(%ebp),%eax
 4e5:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 4e8:	eb 13                	jmp    4fd <memmove+0x27>
    *dst++ = *src++;
 4ea:	8b 45 f8             	mov    -0x8(%ebp),%eax
 4ed:	0f b6 10             	movzbl (%eax),%edx
 4f0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 4f3:	88 10                	mov    %dl,(%eax)
 4f5:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 4f9:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 4fd:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 501:	0f 9f c0             	setg   %al
 504:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 508:	84 c0                	test   %al,%al
 50a:	75 de                	jne    4ea <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 50c:	8b 45 08             	mov    0x8(%ebp),%eax
}
 50f:	c9                   	leave  
 510:	c3                   	ret    
 511:	90                   	nop
 512:	90                   	nop
 513:	90                   	nop

00000514 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 514:	b8 01 00 00 00       	mov    $0x1,%eax
 519:	cd 40                	int    $0x40
 51b:	c3                   	ret    

0000051c <exit>:
SYSCALL(exit)
 51c:	b8 02 00 00 00       	mov    $0x2,%eax
 521:	cd 40                	int    $0x40
 523:	c3                   	ret    

00000524 <wait>:
SYSCALL(wait)
 524:	b8 03 00 00 00       	mov    $0x3,%eax
 529:	cd 40                	int    $0x40
 52b:	c3                   	ret    

0000052c <pipe>:
SYSCALL(pipe)
 52c:	b8 04 00 00 00       	mov    $0x4,%eax
 531:	cd 40                	int    $0x40
 533:	c3                   	ret    

00000534 <read>:
SYSCALL(read)
 534:	b8 05 00 00 00       	mov    $0x5,%eax
 539:	cd 40                	int    $0x40
 53b:	c3                   	ret    

0000053c <write>:
SYSCALL(write)
 53c:	b8 10 00 00 00       	mov    $0x10,%eax
 541:	cd 40                	int    $0x40
 543:	c3                   	ret    

00000544 <close>:
SYSCALL(close)
 544:	b8 15 00 00 00       	mov    $0x15,%eax
 549:	cd 40                	int    $0x40
 54b:	c3                   	ret    

0000054c <kill>:
SYSCALL(kill)
 54c:	b8 06 00 00 00       	mov    $0x6,%eax
 551:	cd 40                	int    $0x40
 553:	c3                   	ret    

00000554 <exec>:
SYSCALL(exec)
 554:	b8 07 00 00 00       	mov    $0x7,%eax
 559:	cd 40                	int    $0x40
 55b:	c3                   	ret    

0000055c <open>:
SYSCALL(open)
 55c:	b8 0f 00 00 00       	mov    $0xf,%eax
 561:	cd 40                	int    $0x40
 563:	c3                   	ret    

00000564 <mknod>:
SYSCALL(mknod)
 564:	b8 11 00 00 00       	mov    $0x11,%eax
 569:	cd 40                	int    $0x40
 56b:	c3                   	ret    

0000056c <unlink>:
SYSCALL(unlink)
 56c:	b8 12 00 00 00       	mov    $0x12,%eax
 571:	cd 40                	int    $0x40
 573:	c3                   	ret    

00000574 <fstat>:
SYSCALL(fstat)
 574:	b8 08 00 00 00       	mov    $0x8,%eax
 579:	cd 40                	int    $0x40
 57b:	c3                   	ret    

0000057c <link>:
SYSCALL(link)
 57c:	b8 13 00 00 00       	mov    $0x13,%eax
 581:	cd 40                	int    $0x40
 583:	c3                   	ret    

00000584 <mkdir>:
SYSCALL(mkdir)
 584:	b8 14 00 00 00       	mov    $0x14,%eax
 589:	cd 40                	int    $0x40
 58b:	c3                   	ret    

0000058c <chdir>:
SYSCALL(chdir)
 58c:	b8 09 00 00 00       	mov    $0x9,%eax
 591:	cd 40                	int    $0x40
 593:	c3                   	ret    

00000594 <dup>:
SYSCALL(dup)
 594:	b8 0a 00 00 00       	mov    $0xa,%eax
 599:	cd 40                	int    $0x40
 59b:	c3                   	ret    

0000059c <getpid>:
SYSCALL(getpid)
 59c:	b8 0b 00 00 00       	mov    $0xb,%eax
 5a1:	cd 40                	int    $0x40
 5a3:	c3                   	ret    

000005a4 <sbrk>:
SYSCALL(sbrk)
 5a4:	b8 0c 00 00 00       	mov    $0xc,%eax
 5a9:	cd 40                	int    $0x40
 5ab:	c3                   	ret    

000005ac <sleep>:
SYSCALL(sleep)
 5ac:	b8 0d 00 00 00       	mov    $0xd,%eax
 5b1:	cd 40                	int    $0x40
 5b3:	c3                   	ret    

000005b4 <uptime>:
SYSCALL(uptime)
 5b4:	b8 0e 00 00 00       	mov    $0xe,%eax
 5b9:	cd 40                	int    $0x40
 5bb:	c3                   	ret    

000005bc <waitpid>:
SYSCALL(waitpid)
 5bc:	b8 16 00 00 00       	mov    $0x16,%eax
 5c1:	cd 40                	int    $0x40
 5c3:	c3                   	ret    

000005c4 <wait_stat>:
SYSCALL(wait_stat)
 5c4:	b8 17 00 00 00       	mov    $0x17,%eax
 5c9:	cd 40                	int    $0x40
 5cb:	c3                   	ret    

000005cc <list_pgroup>:
SYSCALL(list_pgroup)
 5cc:	b8 18 00 00 00       	mov    $0x18,%eax
 5d1:	cd 40                	int    $0x40
 5d3:	c3                   	ret    

000005d4 <foreground>:
SYSCALL(foreground)
 5d4:	b8 19 00 00 00       	mov    $0x19,%eax
 5d9:	cd 40                	int    $0x40
 5db:	c3                   	ret    

000005dc <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 5dc:	55                   	push   %ebp
 5dd:	89 e5                	mov    %esp,%ebp
 5df:	83 ec 28             	sub    $0x28,%esp
 5e2:	8b 45 0c             	mov    0xc(%ebp),%eax
 5e5:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 5e8:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 5ef:	00 
 5f0:	8d 45 f4             	lea    -0xc(%ebp),%eax
 5f3:	89 44 24 04          	mov    %eax,0x4(%esp)
 5f7:	8b 45 08             	mov    0x8(%ebp),%eax
 5fa:	89 04 24             	mov    %eax,(%esp)
 5fd:	e8 3a ff ff ff       	call   53c <write>
}
 602:	c9                   	leave  
 603:	c3                   	ret    

00000604 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 604:	55                   	push   %ebp
 605:	89 e5                	mov    %esp,%ebp
 607:	83 ec 48             	sub    $0x48,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 60a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 611:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 615:	74 17                	je     62e <printint+0x2a>
 617:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 61b:	79 11                	jns    62e <printint+0x2a>
    neg = 1;
 61d:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 624:	8b 45 0c             	mov    0xc(%ebp),%eax
 627:	f7 d8                	neg    %eax
 629:	89 45 ec             	mov    %eax,-0x14(%ebp)
 62c:	eb 06                	jmp    634 <printint+0x30>
  } else {
    x = xx;
 62e:	8b 45 0c             	mov    0xc(%ebp),%eax
 631:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 634:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 63b:	8b 4d 10             	mov    0x10(%ebp),%ecx
 63e:	8b 45 ec             	mov    -0x14(%ebp),%eax
 641:	ba 00 00 00 00       	mov    $0x0,%edx
 646:	f7 f1                	div    %ecx
 648:	89 d0                	mov    %edx,%eax
 64a:	0f b6 90 d8 0d 00 00 	movzbl 0xdd8(%eax),%edx
 651:	8d 45 dc             	lea    -0x24(%ebp),%eax
 654:	03 45 f4             	add    -0xc(%ebp),%eax
 657:	88 10                	mov    %dl,(%eax)
 659:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  }while((x /= base) != 0);
 65d:	8b 55 10             	mov    0x10(%ebp),%edx
 660:	89 55 d4             	mov    %edx,-0x2c(%ebp)
 663:	8b 45 ec             	mov    -0x14(%ebp),%eax
 666:	ba 00 00 00 00       	mov    $0x0,%edx
 66b:	f7 75 d4             	divl   -0x2c(%ebp)
 66e:	89 45 ec             	mov    %eax,-0x14(%ebp)
 671:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 675:	75 c4                	jne    63b <printint+0x37>
  if(neg)
 677:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 67b:	74 2a                	je     6a7 <printint+0xa3>
    buf[i++] = '-';
 67d:	8d 45 dc             	lea    -0x24(%ebp),%eax
 680:	03 45 f4             	add    -0xc(%ebp),%eax
 683:	c6 00 2d             	movb   $0x2d,(%eax)
 686:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

  while(--i >= 0)
 68a:	eb 1b                	jmp    6a7 <printint+0xa3>
    putc(fd, buf[i]);
 68c:	8d 45 dc             	lea    -0x24(%ebp),%eax
 68f:	03 45 f4             	add    -0xc(%ebp),%eax
 692:	0f b6 00             	movzbl (%eax),%eax
 695:	0f be c0             	movsbl %al,%eax
 698:	89 44 24 04          	mov    %eax,0x4(%esp)
 69c:	8b 45 08             	mov    0x8(%ebp),%eax
 69f:	89 04 24             	mov    %eax,(%esp)
 6a2:	e8 35 ff ff ff       	call   5dc <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 6a7:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 6ab:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 6af:	79 db                	jns    68c <printint+0x88>
    putc(fd, buf[i]);
}
 6b1:	c9                   	leave  
 6b2:	c3                   	ret    

000006b3 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 6b3:	55                   	push   %ebp
 6b4:	89 e5                	mov    %esp,%ebp
 6b6:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 6b9:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 6c0:	8d 45 0c             	lea    0xc(%ebp),%eax
 6c3:	83 c0 04             	add    $0x4,%eax
 6c6:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 6c9:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 6d0:	e9 7d 01 00 00       	jmp    852 <printf+0x19f>
    c = fmt[i] & 0xff;
 6d5:	8b 55 0c             	mov    0xc(%ebp),%edx
 6d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6db:	01 d0                	add    %edx,%eax
 6dd:	0f b6 00             	movzbl (%eax),%eax
 6e0:	0f be c0             	movsbl %al,%eax
 6e3:	25 ff 00 00 00       	and    $0xff,%eax
 6e8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 6eb:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 6ef:	75 2c                	jne    71d <printf+0x6a>
      if(c == '%'){
 6f1:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 6f5:	75 0c                	jne    703 <printf+0x50>
        state = '%';
 6f7:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 6fe:	e9 4b 01 00 00       	jmp    84e <printf+0x19b>
      } else {
        putc(fd, c);
 703:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 706:	0f be c0             	movsbl %al,%eax
 709:	89 44 24 04          	mov    %eax,0x4(%esp)
 70d:	8b 45 08             	mov    0x8(%ebp),%eax
 710:	89 04 24             	mov    %eax,(%esp)
 713:	e8 c4 fe ff ff       	call   5dc <putc>
 718:	e9 31 01 00 00       	jmp    84e <printf+0x19b>
      }
    } else if(state == '%'){
 71d:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 721:	0f 85 27 01 00 00    	jne    84e <printf+0x19b>
      if(c == 'd'){
 727:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 72b:	75 2d                	jne    75a <printf+0xa7>
        printint(fd, *ap, 10, 1);
 72d:	8b 45 e8             	mov    -0x18(%ebp),%eax
 730:	8b 00                	mov    (%eax),%eax
 732:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 739:	00 
 73a:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 741:	00 
 742:	89 44 24 04          	mov    %eax,0x4(%esp)
 746:	8b 45 08             	mov    0x8(%ebp),%eax
 749:	89 04 24             	mov    %eax,(%esp)
 74c:	e8 b3 fe ff ff       	call   604 <printint>
        ap++;
 751:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 755:	e9 ed 00 00 00       	jmp    847 <printf+0x194>
      } else if(c == 'x' || c == 'p'){
 75a:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 75e:	74 06                	je     766 <printf+0xb3>
 760:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 764:	75 2d                	jne    793 <printf+0xe0>
        printint(fd, *ap, 16, 0);
 766:	8b 45 e8             	mov    -0x18(%ebp),%eax
 769:	8b 00                	mov    (%eax),%eax
 76b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 772:	00 
 773:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 77a:	00 
 77b:	89 44 24 04          	mov    %eax,0x4(%esp)
 77f:	8b 45 08             	mov    0x8(%ebp),%eax
 782:	89 04 24             	mov    %eax,(%esp)
 785:	e8 7a fe ff ff       	call   604 <printint>
        ap++;
 78a:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 78e:	e9 b4 00 00 00       	jmp    847 <printf+0x194>
      } else if(c == 's'){
 793:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 797:	75 46                	jne    7df <printf+0x12c>
        s = (char*)*ap;
 799:	8b 45 e8             	mov    -0x18(%ebp),%eax
 79c:	8b 00                	mov    (%eax),%eax
 79e:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 7a1:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 7a5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 7a9:	75 27                	jne    7d2 <printf+0x11f>
          s = "(null)";
 7ab:	c7 45 f4 4f 0b 00 00 	movl   $0xb4f,-0xc(%ebp)
        while(*s != 0){
 7b2:	eb 1e                	jmp    7d2 <printf+0x11f>
          putc(fd, *s);
 7b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7b7:	0f b6 00             	movzbl (%eax),%eax
 7ba:	0f be c0             	movsbl %al,%eax
 7bd:	89 44 24 04          	mov    %eax,0x4(%esp)
 7c1:	8b 45 08             	mov    0x8(%ebp),%eax
 7c4:	89 04 24             	mov    %eax,(%esp)
 7c7:	e8 10 fe ff ff       	call   5dc <putc>
          s++;
 7cc:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 7d0:	eb 01                	jmp    7d3 <printf+0x120>
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 7d2:	90                   	nop
 7d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7d6:	0f b6 00             	movzbl (%eax),%eax
 7d9:	84 c0                	test   %al,%al
 7db:	75 d7                	jne    7b4 <printf+0x101>
 7dd:	eb 68                	jmp    847 <printf+0x194>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 7df:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 7e3:	75 1d                	jne    802 <printf+0x14f>
        putc(fd, *ap);
 7e5:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7e8:	8b 00                	mov    (%eax),%eax
 7ea:	0f be c0             	movsbl %al,%eax
 7ed:	89 44 24 04          	mov    %eax,0x4(%esp)
 7f1:	8b 45 08             	mov    0x8(%ebp),%eax
 7f4:	89 04 24             	mov    %eax,(%esp)
 7f7:	e8 e0 fd ff ff       	call   5dc <putc>
        ap++;
 7fc:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 800:	eb 45                	jmp    847 <printf+0x194>
      } else if(c == '%'){
 802:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 806:	75 17                	jne    81f <printf+0x16c>
        putc(fd, c);
 808:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 80b:	0f be c0             	movsbl %al,%eax
 80e:	89 44 24 04          	mov    %eax,0x4(%esp)
 812:	8b 45 08             	mov    0x8(%ebp),%eax
 815:	89 04 24             	mov    %eax,(%esp)
 818:	e8 bf fd ff ff       	call   5dc <putc>
 81d:	eb 28                	jmp    847 <printf+0x194>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 81f:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 826:	00 
 827:	8b 45 08             	mov    0x8(%ebp),%eax
 82a:	89 04 24             	mov    %eax,(%esp)
 82d:	e8 aa fd ff ff       	call   5dc <putc>
        putc(fd, c);
 832:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 835:	0f be c0             	movsbl %al,%eax
 838:	89 44 24 04          	mov    %eax,0x4(%esp)
 83c:	8b 45 08             	mov    0x8(%ebp),%eax
 83f:	89 04 24             	mov    %eax,(%esp)
 842:	e8 95 fd ff ff       	call   5dc <putc>
      }
      state = 0;
 847:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 84e:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 852:	8b 55 0c             	mov    0xc(%ebp),%edx
 855:	8b 45 f0             	mov    -0x10(%ebp),%eax
 858:	01 d0                	add    %edx,%eax
 85a:	0f b6 00             	movzbl (%eax),%eax
 85d:	84 c0                	test   %al,%al
 85f:	0f 85 70 fe ff ff    	jne    6d5 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 865:	c9                   	leave  
 866:	c3                   	ret    
 867:	90                   	nop

00000868 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 868:	55                   	push   %ebp
 869:	89 e5                	mov    %esp,%ebp
 86b:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 86e:	8b 45 08             	mov    0x8(%ebp),%eax
 871:	83 e8 08             	sub    $0x8,%eax
 874:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 877:	a1 f4 0d 00 00       	mov    0xdf4,%eax
 87c:	89 45 fc             	mov    %eax,-0x4(%ebp)
 87f:	eb 24                	jmp    8a5 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 881:	8b 45 fc             	mov    -0x4(%ebp),%eax
 884:	8b 00                	mov    (%eax),%eax
 886:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 889:	77 12                	ja     89d <free+0x35>
 88b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 88e:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 891:	77 24                	ja     8b7 <free+0x4f>
 893:	8b 45 fc             	mov    -0x4(%ebp),%eax
 896:	8b 00                	mov    (%eax),%eax
 898:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 89b:	77 1a                	ja     8b7 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 89d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8a0:	8b 00                	mov    (%eax),%eax
 8a2:	89 45 fc             	mov    %eax,-0x4(%ebp)
 8a5:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8a8:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 8ab:	76 d4                	jbe    881 <free+0x19>
 8ad:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8b0:	8b 00                	mov    (%eax),%eax
 8b2:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 8b5:	76 ca                	jbe    881 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 8b7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8ba:	8b 40 04             	mov    0x4(%eax),%eax
 8bd:	c1 e0 03             	shl    $0x3,%eax
 8c0:	89 c2                	mov    %eax,%edx
 8c2:	03 55 f8             	add    -0x8(%ebp),%edx
 8c5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8c8:	8b 00                	mov    (%eax),%eax
 8ca:	39 c2                	cmp    %eax,%edx
 8cc:	75 24                	jne    8f2 <free+0x8a>
    bp->s.size += p->s.ptr->s.size;
 8ce:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8d1:	8b 50 04             	mov    0x4(%eax),%edx
 8d4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8d7:	8b 00                	mov    (%eax),%eax
 8d9:	8b 40 04             	mov    0x4(%eax),%eax
 8dc:	01 c2                	add    %eax,%edx
 8de:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8e1:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 8e4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8e7:	8b 00                	mov    (%eax),%eax
 8e9:	8b 10                	mov    (%eax),%edx
 8eb:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8ee:	89 10                	mov    %edx,(%eax)
 8f0:	eb 0a                	jmp    8fc <free+0x94>
  } else
    bp->s.ptr = p->s.ptr;
 8f2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8f5:	8b 10                	mov    (%eax),%edx
 8f7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8fa:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 8fc:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8ff:	8b 40 04             	mov    0x4(%eax),%eax
 902:	c1 e0 03             	shl    $0x3,%eax
 905:	03 45 fc             	add    -0x4(%ebp),%eax
 908:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 90b:	75 20                	jne    92d <free+0xc5>
    p->s.size += bp->s.size;
 90d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 910:	8b 50 04             	mov    0x4(%eax),%edx
 913:	8b 45 f8             	mov    -0x8(%ebp),%eax
 916:	8b 40 04             	mov    0x4(%eax),%eax
 919:	01 c2                	add    %eax,%edx
 91b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 91e:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 921:	8b 45 f8             	mov    -0x8(%ebp),%eax
 924:	8b 10                	mov    (%eax),%edx
 926:	8b 45 fc             	mov    -0x4(%ebp),%eax
 929:	89 10                	mov    %edx,(%eax)
 92b:	eb 08                	jmp    935 <free+0xcd>
  } else
    p->s.ptr = bp;
 92d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 930:	8b 55 f8             	mov    -0x8(%ebp),%edx
 933:	89 10                	mov    %edx,(%eax)
  freep = p;
 935:	8b 45 fc             	mov    -0x4(%ebp),%eax
 938:	a3 f4 0d 00 00       	mov    %eax,0xdf4
}
 93d:	c9                   	leave  
 93e:	c3                   	ret    

0000093f <morecore>:

static Header*
morecore(uint nu)
{
 93f:	55                   	push   %ebp
 940:	89 e5                	mov    %esp,%ebp
 942:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 945:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 94c:	77 07                	ja     955 <morecore+0x16>
    nu = 4096;
 94e:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 955:	8b 45 08             	mov    0x8(%ebp),%eax
 958:	c1 e0 03             	shl    $0x3,%eax
 95b:	89 04 24             	mov    %eax,(%esp)
 95e:	e8 41 fc ff ff       	call   5a4 <sbrk>
 963:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 966:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 96a:	75 07                	jne    973 <morecore+0x34>
    return 0;
 96c:	b8 00 00 00 00       	mov    $0x0,%eax
 971:	eb 22                	jmp    995 <morecore+0x56>
  hp = (Header*)p;
 973:	8b 45 f4             	mov    -0xc(%ebp),%eax
 976:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 979:	8b 45 f0             	mov    -0x10(%ebp),%eax
 97c:	8b 55 08             	mov    0x8(%ebp),%edx
 97f:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 982:	8b 45 f0             	mov    -0x10(%ebp),%eax
 985:	83 c0 08             	add    $0x8,%eax
 988:	89 04 24             	mov    %eax,(%esp)
 98b:	e8 d8 fe ff ff       	call   868 <free>
  return freep;
 990:	a1 f4 0d 00 00       	mov    0xdf4,%eax
}
 995:	c9                   	leave  
 996:	c3                   	ret    

00000997 <malloc>:

void*
malloc(uint nbytes)
{
 997:	55                   	push   %ebp
 998:	89 e5                	mov    %esp,%ebp
 99a:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 99d:	8b 45 08             	mov    0x8(%ebp),%eax
 9a0:	83 c0 07             	add    $0x7,%eax
 9a3:	c1 e8 03             	shr    $0x3,%eax
 9a6:	83 c0 01             	add    $0x1,%eax
 9a9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 9ac:	a1 f4 0d 00 00       	mov    0xdf4,%eax
 9b1:	89 45 f0             	mov    %eax,-0x10(%ebp)
 9b4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 9b8:	75 23                	jne    9dd <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 9ba:	c7 45 f0 ec 0d 00 00 	movl   $0xdec,-0x10(%ebp)
 9c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9c4:	a3 f4 0d 00 00       	mov    %eax,0xdf4
 9c9:	a1 f4 0d 00 00       	mov    0xdf4,%eax
 9ce:	a3 ec 0d 00 00       	mov    %eax,0xdec
    base.s.size = 0;
 9d3:	c7 05 f0 0d 00 00 00 	movl   $0x0,0xdf0
 9da:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9e0:	8b 00                	mov    (%eax),%eax
 9e2:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 9e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9e8:	8b 40 04             	mov    0x4(%eax),%eax
 9eb:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 9ee:	72 4d                	jb     a3d <malloc+0xa6>
      if(p->s.size == nunits)
 9f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9f3:	8b 40 04             	mov    0x4(%eax),%eax
 9f6:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 9f9:	75 0c                	jne    a07 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 9fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9fe:	8b 10                	mov    (%eax),%edx
 a00:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a03:	89 10                	mov    %edx,(%eax)
 a05:	eb 26                	jmp    a2d <malloc+0x96>
      else {
        p->s.size -= nunits;
 a07:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a0a:	8b 40 04             	mov    0x4(%eax),%eax
 a0d:	89 c2                	mov    %eax,%edx
 a0f:	2b 55 ec             	sub    -0x14(%ebp),%edx
 a12:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a15:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 a18:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a1b:	8b 40 04             	mov    0x4(%eax),%eax
 a1e:	c1 e0 03             	shl    $0x3,%eax
 a21:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 a24:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a27:	8b 55 ec             	mov    -0x14(%ebp),%edx
 a2a:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 a2d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a30:	a3 f4 0d 00 00       	mov    %eax,0xdf4
      return (void*)(p + 1);
 a35:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a38:	83 c0 08             	add    $0x8,%eax
 a3b:	eb 38                	jmp    a75 <malloc+0xde>
    }
    if(p == freep)
 a3d:	a1 f4 0d 00 00       	mov    0xdf4,%eax
 a42:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 a45:	75 1b                	jne    a62 <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 a47:	8b 45 ec             	mov    -0x14(%ebp),%eax
 a4a:	89 04 24             	mov    %eax,(%esp)
 a4d:	e8 ed fe ff ff       	call   93f <morecore>
 a52:	89 45 f4             	mov    %eax,-0xc(%ebp)
 a55:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 a59:	75 07                	jne    a62 <malloc+0xcb>
        return 0;
 a5b:	b8 00 00 00 00       	mov    $0x0,%eax
 a60:	eb 13                	jmp    a75 <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a62:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a65:	89 45 f0             	mov    %eax,-0x10(%ebp)
 a68:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a6b:	8b 00                	mov    (%eax),%eax
 a6d:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 a70:	e9 70 ff ff ff       	jmp    9e5 <malloc+0x4e>
}
 a75:	c9                   	leave  
 a76:	c3                   	ret    
