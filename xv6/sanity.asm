
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

00000070 <main>:
}

int
main(int argc, char *argv[])
{
  70:	55                   	push   %ebp
  71:	89 e5                	mov    %esp,%ebp
  73:	83 e4 f0             	and    $0xfffffff0,%esp
  76:	83 ec 50             	sub    $0x50,%esp
	int i, pid;
	int wtime, rtime, iotime;
	int presence[NUM_OF_CHLIDREN];

	set_priority(PRIORITY_HIGH);
  79:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80:	e8 4b 05 00 00       	call   5d0 <set_priority>
	memset(presence,0,NUM_OF_CHLIDREN);
  85:	c7 44 24 08 05 00 00 	movl   $0x5,0x8(%esp)
  8c:	00 
  8d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  94:	00 
  95:	8d 44 24 28          	lea    0x28(%esp),%eax
  99:	89 04 24             	mov    %eax,(%esp)
  9c:	e8 ca 02 00 00       	call   36b <memset>

	printf(1, "NUM_OF_CHLIDREN=%d CALC_SIZE=%d\n",NUM_OF_CHLIDREN, CALC_SIZE);
  a1:	c7 44 24 0c d0 07 00 	movl   $0x7d0,0xc(%esp)
  a8:	00 
  a9:	c7 44 24 08 05 00 00 	movl   $0x5,0x8(%esp)
  b0:	00 
  b1:	c7 44 24 04 74 0a 00 	movl   $0xa74,0x4(%esp)
  b8:	00 
  b9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  c0:	e8 ea 05 00 00       	call   6af <printf>


	for (i = 0; i < NUM_OF_CHLIDREN; ++i) {
  c5:	c7 44 24 4c 00 00 00 	movl   $0x0,0x4c(%esp)
  cc:	00 
  cd:	e9 a8 00 00 00       	jmp    17a <main+0x10a>
		if ((pid = fork()) > 0){	//parent
  d2:	e8 31 04 00 00       	call   508 <fork>
  d7:	89 44 24 48          	mov    %eax,0x48(%esp)
  db:	83 7c 24 48 00       	cmpl   $0x0,0x48(%esp)
  e0:	7e 23                	jle    105 <main+0x95>
			printf(1, "(fork:%d)",pid);
  e2:	8b 44 24 48          	mov    0x48(%esp),%eax
  e6:	89 44 24 08          	mov    %eax,0x8(%esp)
  ea:	c7 44 24 04 95 0a 00 	movl   $0xa95,0x4(%esp)
  f1:	00 
  f2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  f9:	e8 b1 05 00 00       	call   6af <printf>
	memset(presence,0,NUM_OF_CHLIDREN);

	printf(1, "NUM_OF_CHLIDREN=%d CALC_SIZE=%d\n",NUM_OF_CHLIDREN, CALC_SIZE);


	for (i = 0; i < NUM_OF_CHLIDREN; ++i) {
  fe:	83 44 24 4c 01       	addl   $0x1,0x4c(%esp)
 103:	eb 75                	jmp    17a <main+0x10a>
		if ((pid = fork()) > 0){	//parent
			printf(1, "(fork:%d)",pid);
		}
		else if (pid == 0){	//child
 105:	83 7c 24 48 00       	cmpl   $0x0,0x48(%esp)
 10a:	75 4e                	jne    15a <main+0xea>
			set_priority((i%3)+1);
 10c:	8b 4c 24 4c          	mov    0x4c(%esp),%ecx
 110:	ba 56 55 55 55       	mov    $0x55555556,%edx
 115:	89 c8                	mov    %ecx,%eax
 117:	f7 ea                	imul   %edx
 119:	89 c8                	mov    %ecx,%eax
 11b:	c1 f8 1f             	sar    $0x1f,%eax
 11e:	29 c2                	sub    %eax,%edx
 120:	89 d0                	mov    %edx,%eax
 122:	01 c0                	add    %eax,%eax
 124:	01 d0                	add    %edx,%eax
 126:	89 ca                	mov    %ecx,%edx
 128:	29 c2                	sub    %eax,%edx
 12a:	8d 42 01             	lea    0x1(%edx),%eax
 12d:	89 04 24             	mov    %eax,(%esp)
 130:	e8 9b 04 00 00       	call   5d0 <set_priority>
			sleep(100);
 135:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
 13c:	e8 5f 04 00 00       	call   5a0 <sleep>
			getTheNPrimeNumber(CALC_SIZE);
 141:	c7 04 24 d0 07 00 00 	movl   $0x7d0,(%esp)
 148:	e8 b3 fe ff ff       	call   0 <getTheNPrimeNumber>
			exit(getpid());
 14d:	e8 3e 04 00 00       	call   590 <getpid>
 152:	89 04 24             	mov    %eax,(%esp)
 155:	e8 b6 03 00 00       	call   510 <exit>
		}
		else{
			printf(1, "\nERROR: Fork failed\n");
 15a:	c7 44 24 04 9f 0a 00 	movl   $0xa9f,0x4(%esp)
 161:	00 
 162:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 169:	e8 41 05 00 00       	call   6af <printf>
			exit(EXIT_STATUS_FAILURE);
 16e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 175:	e8 96 03 00 00       	call   510 <exit>
	memset(presence,0,NUM_OF_CHLIDREN);

	printf(1, "NUM_OF_CHLIDREN=%d CALC_SIZE=%d\n",NUM_OF_CHLIDREN, CALC_SIZE);


	for (i = 0; i < NUM_OF_CHLIDREN; ++i) {
 17a:	83 7c 24 4c 04       	cmpl   $0x4,0x4c(%esp)
 17f:	0f 8e 4d ff ff ff    	jle    d2 <main+0x62>
		else{
			printf(1, "\nERROR: Fork failed\n");
			exit(EXIT_STATUS_FAILURE);
		}
	}
	printf(1,"\n");
 185:	c7 44 24 04 b4 0a 00 	movl   $0xab4,0x4(%esp)
 18c:	00 
 18d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 194:	e8 16 05 00 00       	call   6af <printf>

	for (i = 0; i < NUM_OF_CHLIDREN; ++i){
 199:	c7 44 24 4c 00 00 00 	movl   $0x0,0x4c(%esp)
 1a0:	00 
 1a1:	e9 99 00 00 00       	jmp    23f <main+0x1cf>

		pid = wait_stat(&wtime,&rtime,&iotime);
 1a6:	8d 44 24 3c          	lea    0x3c(%esp),%eax
 1aa:	89 44 24 08          	mov    %eax,0x8(%esp)
 1ae:	8d 44 24 40          	lea    0x40(%esp),%eax
 1b2:	89 44 24 04          	mov    %eax,0x4(%esp)
 1b6:	8d 44 24 44          	lea    0x44(%esp),%eax
 1ba:	89 04 24             	mov    %eax,(%esp)
 1bd:	e8 f6 03 00 00       	call   5b8 <wait_stat>
 1c2:	89 44 24 48          	mov    %eax,0x48(%esp)
		if (pid<0){
 1c6:	83 7c 24 48 00       	cmpl   $0x0,0x48(%esp)
 1cb:	79 20                	jns    1ed <main+0x17d>
			printf(1, "\nERROR: Not enought waits.\n");
 1cd:	c7 44 24 04 b6 0a 00 	movl   $0xab6,0x4(%esp)
 1d4:	00 
 1d5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 1dc:	e8 ce 04 00 00       	call   6af <printf>
			exit(EXIT_STATUS_FAILURE);
 1e1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 1e8:	e8 23 03 00 00       	call   510 <exit>
		}
		//printf(1, "Done(%d) ; ", pid);
		printf(1,"Done(%d): waiting (RUNNABLE): %d | running: %d | turnaround : %d\n",
				pid, wtime, rtime, wtime+rtime+iotime);
 1ed:	8b 54 24 44          	mov    0x44(%esp),%edx
 1f1:	8b 44 24 40          	mov    0x40(%esp),%eax
 1f5:	01 c2                	add    %eax,%edx
		if (pid<0){
			printf(1, "\nERROR: Not enought waits.\n");
			exit(EXIT_STATUS_FAILURE);
		}
		//printf(1, "Done(%d) ; ", pid);
		printf(1,"Done(%d): waiting (RUNNABLE): %d | running: %d | turnaround : %d\n",
 1f7:	8b 44 24 3c          	mov    0x3c(%esp),%eax
 1fb:	8d 0c 02             	lea    (%edx,%eax,1),%ecx
 1fe:	8b 54 24 40          	mov    0x40(%esp),%edx
 202:	8b 44 24 44          	mov    0x44(%esp),%eax
 206:	89 4c 24 14          	mov    %ecx,0x14(%esp)
 20a:	89 54 24 10          	mov    %edx,0x10(%esp)
 20e:	89 44 24 0c          	mov    %eax,0xc(%esp)
 212:	8b 44 24 48          	mov    0x48(%esp),%eax
 216:	89 44 24 08          	mov    %eax,0x8(%esp)
 21a:	c7 44 24 04 d4 0a 00 	movl   $0xad4,0x4(%esp)
 221:	00 
 222:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 229:	e8 81 04 00 00       	call   6af <printf>
				pid, wtime, rtime, wtime+rtime+iotime);
		presence[i] = pid;
 22e:	8b 44 24 4c          	mov    0x4c(%esp),%eax
 232:	8b 54 24 48          	mov    0x48(%esp),%edx
 236:	89 54 84 28          	mov    %edx,0x28(%esp,%eax,4)
			exit(EXIT_STATUS_FAILURE);
		}
	}
	printf(1,"\n");

	for (i = 0; i < NUM_OF_CHLIDREN; ++i){
 23a:	83 44 24 4c 01       	addl   $0x1,0x4c(%esp)
 23f:	83 7c 24 4c 04       	cmpl   $0x4,0x4c(%esp)
 244:	0f 8e 5c ff ff ff    	jle    1a6 <main+0x136>
		printf(1,"Done(%d): waiting (RUNNABLE): %d | running: %d | turnaround : %d\n",
				pid, wtime, rtime, wtime+rtime+iotime);
		presence[i] = pid;
	}

	for (i = 0; i < NUM_OF_CHLIDREN; ++i){
 24a:	c7 44 24 4c 00 00 00 	movl   $0x0,0x4c(%esp)
 251:	00 
 252:	eb 31                	jmp    285 <main+0x215>
		if(!presence[i]){
 254:	8b 44 24 4c          	mov    0x4c(%esp),%eax
 258:	8b 44 84 28          	mov    0x28(%esp,%eax,4),%eax
 25c:	85 c0                	test   %eax,%eax
 25e:	75 20                	jne    280 <main+0x210>
			printf(1, "\nERROR: Not enough waits.\n");
 260:	c7 44 24 04 16 0b 00 	movl   $0xb16,0x4(%esp)
 267:	00 
 268:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 26f:	e8 3b 04 00 00       	call   6af <printf>
			exit(EXIT_STATUS_FAILURE);
 274:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 27b:	e8 90 02 00 00       	call   510 <exit>
		printf(1,"Done(%d): waiting (RUNNABLE): %d | running: %d | turnaround : %d\n",
				pid, wtime, rtime, wtime+rtime+iotime);
		presence[i] = pid;
	}

	for (i = 0; i < NUM_OF_CHLIDREN; ++i){
 280:	83 44 24 4c 01       	addl   $0x1,0x4c(%esp)
 285:	83 7c 24 4c 04       	cmpl   $0x4,0x4c(%esp)
 28a:	7e c8                	jle    254 <main+0x1e4>
		if(!presence[i]){
			printf(1, "\nERROR: Not enough waits.\n");
			exit(EXIT_STATUS_FAILURE);
		}
	}
	printf(1, "Success: Great Success!.\n");
 28c:	c7 44 24 04 31 0b 00 	movl   $0xb31,0x4(%esp)
 293:	00 
 294:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 29b:	e8 0f 04 00 00       	call   6af <printf>
	exit(EXIT_STATUS_SUCCESS);
 2a0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 2a7:	e8 64 02 00 00       	call   510 <exit>

000002ac <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 2ac:	55                   	push   %ebp
 2ad:	89 e5                	mov    %esp,%ebp
 2af:	57                   	push   %edi
 2b0:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 2b1:	8b 4d 08             	mov    0x8(%ebp),%ecx
 2b4:	8b 55 10             	mov    0x10(%ebp),%edx
 2b7:	8b 45 0c             	mov    0xc(%ebp),%eax
 2ba:	89 cb                	mov    %ecx,%ebx
 2bc:	89 df                	mov    %ebx,%edi
 2be:	89 d1                	mov    %edx,%ecx
 2c0:	fc                   	cld    
 2c1:	f3 aa                	rep stos %al,%es:(%edi)
 2c3:	89 ca                	mov    %ecx,%edx
 2c5:	89 fb                	mov    %edi,%ebx
 2c7:	89 5d 08             	mov    %ebx,0x8(%ebp)
 2ca:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 2cd:	5b                   	pop    %ebx
 2ce:	5f                   	pop    %edi
 2cf:	5d                   	pop    %ebp
 2d0:	c3                   	ret    

000002d1 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 2d1:	55                   	push   %ebp
 2d2:	89 e5                	mov    %esp,%ebp
 2d4:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 2d7:	8b 45 08             	mov    0x8(%ebp),%eax
 2da:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 2dd:	90                   	nop
 2de:	8b 45 0c             	mov    0xc(%ebp),%eax
 2e1:	0f b6 10             	movzbl (%eax),%edx
 2e4:	8b 45 08             	mov    0x8(%ebp),%eax
 2e7:	88 10                	mov    %dl,(%eax)
 2e9:	8b 45 08             	mov    0x8(%ebp),%eax
 2ec:	0f b6 00             	movzbl (%eax),%eax
 2ef:	84 c0                	test   %al,%al
 2f1:	0f 95 c0             	setne  %al
 2f4:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 2f8:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 2fc:	84 c0                	test   %al,%al
 2fe:	75 de                	jne    2de <strcpy+0xd>
    ;
  return os;
 300:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 303:	c9                   	leave  
 304:	c3                   	ret    

00000305 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 305:	55                   	push   %ebp
 306:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 308:	eb 08                	jmp    312 <strcmp+0xd>
    p++, q++;
 30a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 30e:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 312:	8b 45 08             	mov    0x8(%ebp),%eax
 315:	0f b6 00             	movzbl (%eax),%eax
 318:	84 c0                	test   %al,%al
 31a:	74 10                	je     32c <strcmp+0x27>
 31c:	8b 45 08             	mov    0x8(%ebp),%eax
 31f:	0f b6 10             	movzbl (%eax),%edx
 322:	8b 45 0c             	mov    0xc(%ebp),%eax
 325:	0f b6 00             	movzbl (%eax),%eax
 328:	38 c2                	cmp    %al,%dl
 32a:	74 de                	je     30a <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 32c:	8b 45 08             	mov    0x8(%ebp),%eax
 32f:	0f b6 00             	movzbl (%eax),%eax
 332:	0f b6 d0             	movzbl %al,%edx
 335:	8b 45 0c             	mov    0xc(%ebp),%eax
 338:	0f b6 00             	movzbl (%eax),%eax
 33b:	0f b6 c0             	movzbl %al,%eax
 33e:	89 d1                	mov    %edx,%ecx
 340:	29 c1                	sub    %eax,%ecx
 342:	89 c8                	mov    %ecx,%eax
}
 344:	5d                   	pop    %ebp
 345:	c3                   	ret    

00000346 <strlen>:

uint
strlen(char *s)
{
 346:	55                   	push   %ebp
 347:	89 e5                	mov    %esp,%ebp
 349:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 34c:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 353:	eb 04                	jmp    359 <strlen+0x13>
 355:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 359:	8b 45 fc             	mov    -0x4(%ebp),%eax
 35c:	03 45 08             	add    0x8(%ebp),%eax
 35f:	0f b6 00             	movzbl (%eax),%eax
 362:	84 c0                	test   %al,%al
 364:	75 ef                	jne    355 <strlen+0xf>
    ;
  return n;
 366:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 369:	c9                   	leave  
 36a:	c3                   	ret    

0000036b <memset>:

void*
memset(void *dst, int c, uint n)
{
 36b:	55                   	push   %ebp
 36c:	89 e5                	mov    %esp,%ebp
 36e:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 371:	8b 45 10             	mov    0x10(%ebp),%eax
 374:	89 44 24 08          	mov    %eax,0x8(%esp)
 378:	8b 45 0c             	mov    0xc(%ebp),%eax
 37b:	89 44 24 04          	mov    %eax,0x4(%esp)
 37f:	8b 45 08             	mov    0x8(%ebp),%eax
 382:	89 04 24             	mov    %eax,(%esp)
 385:	e8 22 ff ff ff       	call   2ac <stosb>
  return dst;
 38a:	8b 45 08             	mov    0x8(%ebp),%eax
}
 38d:	c9                   	leave  
 38e:	c3                   	ret    

0000038f <strchr>:

char*
strchr(const char *s, char c)
{
 38f:	55                   	push   %ebp
 390:	89 e5                	mov    %esp,%ebp
 392:	83 ec 04             	sub    $0x4,%esp
 395:	8b 45 0c             	mov    0xc(%ebp),%eax
 398:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 39b:	eb 14                	jmp    3b1 <strchr+0x22>
    if(*s == c)
 39d:	8b 45 08             	mov    0x8(%ebp),%eax
 3a0:	0f b6 00             	movzbl (%eax),%eax
 3a3:	3a 45 fc             	cmp    -0x4(%ebp),%al
 3a6:	75 05                	jne    3ad <strchr+0x1e>
      return (char*)s;
 3a8:	8b 45 08             	mov    0x8(%ebp),%eax
 3ab:	eb 13                	jmp    3c0 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 3ad:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 3b1:	8b 45 08             	mov    0x8(%ebp),%eax
 3b4:	0f b6 00             	movzbl (%eax),%eax
 3b7:	84 c0                	test   %al,%al
 3b9:	75 e2                	jne    39d <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 3bb:	b8 00 00 00 00       	mov    $0x0,%eax
}
 3c0:	c9                   	leave  
 3c1:	c3                   	ret    

000003c2 <gets>:

char*
gets(char *buf, int max)
{
 3c2:	55                   	push   %ebp
 3c3:	89 e5                	mov    %esp,%ebp
 3c5:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 3c8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 3cf:	eb 44                	jmp    415 <gets+0x53>
    cc = read(0, &c, 1);
 3d1:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 3d8:	00 
 3d9:	8d 45 ef             	lea    -0x11(%ebp),%eax
 3dc:	89 44 24 04          	mov    %eax,0x4(%esp)
 3e0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 3e7:	e8 3c 01 00 00       	call   528 <read>
 3ec:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 3ef:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 3f3:	7e 2d                	jle    422 <gets+0x60>
      break;
    buf[i++] = c;
 3f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3f8:	03 45 08             	add    0x8(%ebp),%eax
 3fb:	0f b6 55 ef          	movzbl -0x11(%ebp),%edx
 3ff:	88 10                	mov    %dl,(%eax)
 401:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(c == '\n' || c == '\r')
 405:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 409:	3c 0a                	cmp    $0xa,%al
 40b:	74 16                	je     423 <gets+0x61>
 40d:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 411:	3c 0d                	cmp    $0xd,%al
 413:	74 0e                	je     423 <gets+0x61>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 415:	8b 45 f4             	mov    -0xc(%ebp),%eax
 418:	83 c0 01             	add    $0x1,%eax
 41b:	3b 45 0c             	cmp    0xc(%ebp),%eax
 41e:	7c b1                	jl     3d1 <gets+0xf>
 420:	eb 01                	jmp    423 <gets+0x61>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 422:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 423:	8b 45 f4             	mov    -0xc(%ebp),%eax
 426:	03 45 08             	add    0x8(%ebp),%eax
 429:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 42c:	8b 45 08             	mov    0x8(%ebp),%eax
}
 42f:	c9                   	leave  
 430:	c3                   	ret    

00000431 <stat>:

int
stat(char *n, struct stat *st)
{
 431:	55                   	push   %ebp
 432:	89 e5                	mov    %esp,%ebp
 434:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 437:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 43e:	00 
 43f:	8b 45 08             	mov    0x8(%ebp),%eax
 442:	89 04 24             	mov    %eax,(%esp)
 445:	e8 06 01 00 00       	call   550 <open>
 44a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 44d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 451:	79 07                	jns    45a <stat+0x29>
    return -1;
 453:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 458:	eb 23                	jmp    47d <stat+0x4c>
  r = fstat(fd, st);
 45a:	8b 45 0c             	mov    0xc(%ebp),%eax
 45d:	89 44 24 04          	mov    %eax,0x4(%esp)
 461:	8b 45 f4             	mov    -0xc(%ebp),%eax
 464:	89 04 24             	mov    %eax,(%esp)
 467:	e8 fc 00 00 00       	call   568 <fstat>
 46c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 46f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 472:	89 04 24             	mov    %eax,(%esp)
 475:	e8 be 00 00 00       	call   538 <close>
  return r;
 47a:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 47d:	c9                   	leave  
 47e:	c3                   	ret    

0000047f <atoi>:

int
atoi(const char *s)
{
 47f:	55                   	push   %ebp
 480:	89 e5                	mov    %esp,%ebp
 482:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 485:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 48c:	eb 23                	jmp    4b1 <atoi+0x32>
    n = n*10 + *s++ - '0';
 48e:	8b 55 fc             	mov    -0x4(%ebp),%edx
 491:	89 d0                	mov    %edx,%eax
 493:	c1 e0 02             	shl    $0x2,%eax
 496:	01 d0                	add    %edx,%eax
 498:	01 c0                	add    %eax,%eax
 49a:	89 c2                	mov    %eax,%edx
 49c:	8b 45 08             	mov    0x8(%ebp),%eax
 49f:	0f b6 00             	movzbl (%eax),%eax
 4a2:	0f be c0             	movsbl %al,%eax
 4a5:	01 d0                	add    %edx,%eax
 4a7:	83 e8 30             	sub    $0x30,%eax
 4aa:	89 45 fc             	mov    %eax,-0x4(%ebp)
 4ad:	83 45 08 01          	addl   $0x1,0x8(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 4b1:	8b 45 08             	mov    0x8(%ebp),%eax
 4b4:	0f b6 00             	movzbl (%eax),%eax
 4b7:	3c 2f                	cmp    $0x2f,%al
 4b9:	7e 0a                	jle    4c5 <atoi+0x46>
 4bb:	8b 45 08             	mov    0x8(%ebp),%eax
 4be:	0f b6 00             	movzbl (%eax),%eax
 4c1:	3c 39                	cmp    $0x39,%al
 4c3:	7e c9                	jle    48e <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 4c5:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 4c8:	c9                   	leave  
 4c9:	c3                   	ret    

000004ca <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 4ca:	55                   	push   %ebp
 4cb:	89 e5                	mov    %esp,%ebp
 4cd:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 4d0:	8b 45 08             	mov    0x8(%ebp),%eax
 4d3:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 4d6:	8b 45 0c             	mov    0xc(%ebp),%eax
 4d9:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 4dc:	eb 13                	jmp    4f1 <memmove+0x27>
    *dst++ = *src++;
 4de:	8b 45 f8             	mov    -0x8(%ebp),%eax
 4e1:	0f b6 10             	movzbl (%eax),%edx
 4e4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 4e7:	88 10                	mov    %dl,(%eax)
 4e9:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 4ed:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 4f1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 4f5:	0f 9f c0             	setg   %al
 4f8:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 4fc:	84 c0                	test   %al,%al
 4fe:	75 de                	jne    4de <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 500:	8b 45 08             	mov    0x8(%ebp),%eax
}
 503:	c9                   	leave  
 504:	c3                   	ret    
 505:	90                   	nop
 506:	90                   	nop
 507:	90                   	nop

00000508 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 508:	b8 01 00 00 00       	mov    $0x1,%eax
 50d:	cd 40                	int    $0x40
 50f:	c3                   	ret    

00000510 <exit>:
SYSCALL(exit)
 510:	b8 02 00 00 00       	mov    $0x2,%eax
 515:	cd 40                	int    $0x40
 517:	c3                   	ret    

00000518 <wait>:
SYSCALL(wait)
 518:	b8 03 00 00 00       	mov    $0x3,%eax
 51d:	cd 40                	int    $0x40
 51f:	c3                   	ret    

00000520 <pipe>:
SYSCALL(pipe)
 520:	b8 04 00 00 00       	mov    $0x4,%eax
 525:	cd 40                	int    $0x40
 527:	c3                   	ret    

00000528 <read>:
SYSCALL(read)
 528:	b8 05 00 00 00       	mov    $0x5,%eax
 52d:	cd 40                	int    $0x40
 52f:	c3                   	ret    

00000530 <write>:
SYSCALL(write)
 530:	b8 10 00 00 00       	mov    $0x10,%eax
 535:	cd 40                	int    $0x40
 537:	c3                   	ret    

00000538 <close>:
SYSCALL(close)
 538:	b8 15 00 00 00       	mov    $0x15,%eax
 53d:	cd 40                	int    $0x40
 53f:	c3                   	ret    

00000540 <kill>:
SYSCALL(kill)
 540:	b8 06 00 00 00       	mov    $0x6,%eax
 545:	cd 40                	int    $0x40
 547:	c3                   	ret    

00000548 <exec>:
SYSCALL(exec)
 548:	b8 07 00 00 00       	mov    $0x7,%eax
 54d:	cd 40                	int    $0x40
 54f:	c3                   	ret    

00000550 <open>:
SYSCALL(open)
 550:	b8 0f 00 00 00       	mov    $0xf,%eax
 555:	cd 40                	int    $0x40
 557:	c3                   	ret    

00000558 <mknod>:
SYSCALL(mknod)
 558:	b8 11 00 00 00       	mov    $0x11,%eax
 55d:	cd 40                	int    $0x40
 55f:	c3                   	ret    

00000560 <unlink>:
SYSCALL(unlink)
 560:	b8 12 00 00 00       	mov    $0x12,%eax
 565:	cd 40                	int    $0x40
 567:	c3                   	ret    

00000568 <fstat>:
SYSCALL(fstat)
 568:	b8 08 00 00 00       	mov    $0x8,%eax
 56d:	cd 40                	int    $0x40
 56f:	c3                   	ret    

00000570 <link>:
SYSCALL(link)
 570:	b8 13 00 00 00       	mov    $0x13,%eax
 575:	cd 40                	int    $0x40
 577:	c3                   	ret    

00000578 <mkdir>:
SYSCALL(mkdir)
 578:	b8 14 00 00 00       	mov    $0x14,%eax
 57d:	cd 40                	int    $0x40
 57f:	c3                   	ret    

00000580 <chdir>:
SYSCALL(chdir)
 580:	b8 09 00 00 00       	mov    $0x9,%eax
 585:	cd 40                	int    $0x40
 587:	c3                   	ret    

00000588 <dup>:
SYSCALL(dup)
 588:	b8 0a 00 00 00       	mov    $0xa,%eax
 58d:	cd 40                	int    $0x40
 58f:	c3                   	ret    

00000590 <getpid>:
SYSCALL(getpid)
 590:	b8 0b 00 00 00       	mov    $0xb,%eax
 595:	cd 40                	int    $0x40
 597:	c3                   	ret    

00000598 <sbrk>:
SYSCALL(sbrk)
 598:	b8 0c 00 00 00       	mov    $0xc,%eax
 59d:	cd 40                	int    $0x40
 59f:	c3                   	ret    

000005a0 <sleep>:
SYSCALL(sleep)
 5a0:	b8 0d 00 00 00       	mov    $0xd,%eax
 5a5:	cd 40                	int    $0x40
 5a7:	c3                   	ret    

000005a8 <uptime>:
SYSCALL(uptime)
 5a8:	b8 0e 00 00 00       	mov    $0xe,%eax
 5ad:	cd 40                	int    $0x40
 5af:	c3                   	ret    

000005b0 <waitpid>:
SYSCALL(waitpid)
 5b0:	b8 16 00 00 00       	mov    $0x16,%eax
 5b5:	cd 40                	int    $0x40
 5b7:	c3                   	ret    

000005b8 <wait_stat>:
SYSCALL(wait_stat)
 5b8:	b8 17 00 00 00       	mov    $0x17,%eax
 5bd:	cd 40                	int    $0x40
 5bf:	c3                   	ret    

000005c0 <list_pgroup>:
SYSCALL(list_pgroup)
 5c0:	b8 18 00 00 00       	mov    $0x18,%eax
 5c5:	cd 40                	int    $0x40
 5c7:	c3                   	ret    

000005c8 <foreground>:
SYSCALL(foreground)
 5c8:	b8 19 00 00 00       	mov    $0x19,%eax
 5cd:	cd 40                	int    $0x40
 5cf:	c3                   	ret    

000005d0 <set_priority>:
SYSCALL(set_priority)
 5d0:	b8 1a 00 00 00       	mov    $0x1a,%eax
 5d5:	cd 40                	int    $0x40
 5d7:	c3                   	ret    

000005d8 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 5d8:	55                   	push   %ebp
 5d9:	89 e5                	mov    %esp,%ebp
 5db:	83 ec 28             	sub    $0x28,%esp
 5de:	8b 45 0c             	mov    0xc(%ebp),%eax
 5e1:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 5e4:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 5eb:	00 
 5ec:	8d 45 f4             	lea    -0xc(%ebp),%eax
 5ef:	89 44 24 04          	mov    %eax,0x4(%esp)
 5f3:	8b 45 08             	mov    0x8(%ebp),%eax
 5f6:	89 04 24             	mov    %eax,(%esp)
 5f9:	e8 32 ff ff ff       	call   530 <write>
}
 5fe:	c9                   	leave  
 5ff:	c3                   	ret    

00000600 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 600:	55                   	push   %ebp
 601:	89 e5                	mov    %esp,%ebp
 603:	83 ec 48             	sub    $0x48,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 606:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 60d:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 611:	74 17                	je     62a <printint+0x2a>
 613:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 617:	79 11                	jns    62a <printint+0x2a>
    neg = 1;
 619:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 620:	8b 45 0c             	mov    0xc(%ebp),%eax
 623:	f7 d8                	neg    %eax
 625:	89 45 ec             	mov    %eax,-0x14(%ebp)
 628:	eb 06                	jmp    630 <printint+0x30>
  } else {
    x = xx;
 62a:	8b 45 0c             	mov    0xc(%ebp),%eax
 62d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 630:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 637:	8b 4d 10             	mov    0x10(%ebp),%ecx
 63a:	8b 45 ec             	mov    -0x14(%ebp),%eax
 63d:	ba 00 00 00 00       	mov    $0x0,%edx
 642:	f7 f1                	div    %ecx
 644:	89 d0                	mov    %edx,%eax
 646:	0f b6 90 b4 0d 00 00 	movzbl 0xdb4(%eax),%edx
 64d:	8d 45 dc             	lea    -0x24(%ebp),%eax
 650:	03 45 f4             	add    -0xc(%ebp),%eax
 653:	88 10                	mov    %dl,(%eax)
 655:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  }while((x /= base) != 0);
 659:	8b 55 10             	mov    0x10(%ebp),%edx
 65c:	89 55 d4             	mov    %edx,-0x2c(%ebp)
 65f:	8b 45 ec             	mov    -0x14(%ebp),%eax
 662:	ba 00 00 00 00       	mov    $0x0,%edx
 667:	f7 75 d4             	divl   -0x2c(%ebp)
 66a:	89 45 ec             	mov    %eax,-0x14(%ebp)
 66d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 671:	75 c4                	jne    637 <printint+0x37>
  if(neg)
 673:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 677:	74 2a                	je     6a3 <printint+0xa3>
    buf[i++] = '-';
 679:	8d 45 dc             	lea    -0x24(%ebp),%eax
 67c:	03 45 f4             	add    -0xc(%ebp),%eax
 67f:	c6 00 2d             	movb   $0x2d,(%eax)
 682:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

  while(--i >= 0)
 686:	eb 1b                	jmp    6a3 <printint+0xa3>
    putc(fd, buf[i]);
 688:	8d 45 dc             	lea    -0x24(%ebp),%eax
 68b:	03 45 f4             	add    -0xc(%ebp),%eax
 68e:	0f b6 00             	movzbl (%eax),%eax
 691:	0f be c0             	movsbl %al,%eax
 694:	89 44 24 04          	mov    %eax,0x4(%esp)
 698:	8b 45 08             	mov    0x8(%ebp),%eax
 69b:	89 04 24             	mov    %eax,(%esp)
 69e:	e8 35 ff ff ff       	call   5d8 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 6a3:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 6a7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 6ab:	79 db                	jns    688 <printint+0x88>
    putc(fd, buf[i]);
}
 6ad:	c9                   	leave  
 6ae:	c3                   	ret    

000006af <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 6af:	55                   	push   %ebp
 6b0:	89 e5                	mov    %esp,%ebp
 6b2:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 6b5:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 6bc:	8d 45 0c             	lea    0xc(%ebp),%eax
 6bf:	83 c0 04             	add    $0x4,%eax
 6c2:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 6c5:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 6cc:	e9 7d 01 00 00       	jmp    84e <printf+0x19f>
    c = fmt[i] & 0xff;
 6d1:	8b 55 0c             	mov    0xc(%ebp),%edx
 6d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6d7:	01 d0                	add    %edx,%eax
 6d9:	0f b6 00             	movzbl (%eax),%eax
 6dc:	0f be c0             	movsbl %al,%eax
 6df:	25 ff 00 00 00       	and    $0xff,%eax
 6e4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 6e7:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 6eb:	75 2c                	jne    719 <printf+0x6a>
      if(c == '%'){
 6ed:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 6f1:	75 0c                	jne    6ff <printf+0x50>
        state = '%';
 6f3:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 6fa:	e9 4b 01 00 00       	jmp    84a <printf+0x19b>
      } else {
        putc(fd, c);
 6ff:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 702:	0f be c0             	movsbl %al,%eax
 705:	89 44 24 04          	mov    %eax,0x4(%esp)
 709:	8b 45 08             	mov    0x8(%ebp),%eax
 70c:	89 04 24             	mov    %eax,(%esp)
 70f:	e8 c4 fe ff ff       	call   5d8 <putc>
 714:	e9 31 01 00 00       	jmp    84a <printf+0x19b>
      }
    } else if(state == '%'){
 719:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 71d:	0f 85 27 01 00 00    	jne    84a <printf+0x19b>
      if(c == 'd'){
 723:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 727:	75 2d                	jne    756 <printf+0xa7>
        printint(fd, *ap, 10, 1);
 729:	8b 45 e8             	mov    -0x18(%ebp),%eax
 72c:	8b 00                	mov    (%eax),%eax
 72e:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 735:	00 
 736:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 73d:	00 
 73e:	89 44 24 04          	mov    %eax,0x4(%esp)
 742:	8b 45 08             	mov    0x8(%ebp),%eax
 745:	89 04 24             	mov    %eax,(%esp)
 748:	e8 b3 fe ff ff       	call   600 <printint>
        ap++;
 74d:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 751:	e9 ed 00 00 00       	jmp    843 <printf+0x194>
      } else if(c == 'x' || c == 'p'){
 756:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 75a:	74 06                	je     762 <printf+0xb3>
 75c:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 760:	75 2d                	jne    78f <printf+0xe0>
        printint(fd, *ap, 16, 0);
 762:	8b 45 e8             	mov    -0x18(%ebp),%eax
 765:	8b 00                	mov    (%eax),%eax
 767:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 76e:	00 
 76f:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 776:	00 
 777:	89 44 24 04          	mov    %eax,0x4(%esp)
 77b:	8b 45 08             	mov    0x8(%ebp),%eax
 77e:	89 04 24             	mov    %eax,(%esp)
 781:	e8 7a fe ff ff       	call   600 <printint>
        ap++;
 786:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 78a:	e9 b4 00 00 00       	jmp    843 <printf+0x194>
      } else if(c == 's'){
 78f:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 793:	75 46                	jne    7db <printf+0x12c>
        s = (char*)*ap;
 795:	8b 45 e8             	mov    -0x18(%ebp),%eax
 798:	8b 00                	mov    (%eax),%eax
 79a:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 79d:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 7a1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 7a5:	75 27                	jne    7ce <printf+0x11f>
          s = "(null)";
 7a7:	c7 45 f4 4b 0b 00 00 	movl   $0xb4b,-0xc(%ebp)
        while(*s != 0){
 7ae:	eb 1e                	jmp    7ce <printf+0x11f>
          putc(fd, *s);
 7b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7b3:	0f b6 00             	movzbl (%eax),%eax
 7b6:	0f be c0             	movsbl %al,%eax
 7b9:	89 44 24 04          	mov    %eax,0x4(%esp)
 7bd:	8b 45 08             	mov    0x8(%ebp),%eax
 7c0:	89 04 24             	mov    %eax,(%esp)
 7c3:	e8 10 fe ff ff       	call   5d8 <putc>
          s++;
 7c8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 7cc:	eb 01                	jmp    7cf <printf+0x120>
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 7ce:	90                   	nop
 7cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7d2:	0f b6 00             	movzbl (%eax),%eax
 7d5:	84 c0                	test   %al,%al
 7d7:	75 d7                	jne    7b0 <printf+0x101>
 7d9:	eb 68                	jmp    843 <printf+0x194>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 7db:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 7df:	75 1d                	jne    7fe <printf+0x14f>
        putc(fd, *ap);
 7e1:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7e4:	8b 00                	mov    (%eax),%eax
 7e6:	0f be c0             	movsbl %al,%eax
 7e9:	89 44 24 04          	mov    %eax,0x4(%esp)
 7ed:	8b 45 08             	mov    0x8(%ebp),%eax
 7f0:	89 04 24             	mov    %eax,(%esp)
 7f3:	e8 e0 fd ff ff       	call   5d8 <putc>
        ap++;
 7f8:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 7fc:	eb 45                	jmp    843 <printf+0x194>
      } else if(c == '%'){
 7fe:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 802:	75 17                	jne    81b <printf+0x16c>
        putc(fd, c);
 804:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 807:	0f be c0             	movsbl %al,%eax
 80a:	89 44 24 04          	mov    %eax,0x4(%esp)
 80e:	8b 45 08             	mov    0x8(%ebp),%eax
 811:	89 04 24             	mov    %eax,(%esp)
 814:	e8 bf fd ff ff       	call   5d8 <putc>
 819:	eb 28                	jmp    843 <printf+0x194>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 81b:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 822:	00 
 823:	8b 45 08             	mov    0x8(%ebp),%eax
 826:	89 04 24             	mov    %eax,(%esp)
 829:	e8 aa fd ff ff       	call   5d8 <putc>
        putc(fd, c);
 82e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 831:	0f be c0             	movsbl %al,%eax
 834:	89 44 24 04          	mov    %eax,0x4(%esp)
 838:	8b 45 08             	mov    0x8(%ebp),%eax
 83b:	89 04 24             	mov    %eax,(%esp)
 83e:	e8 95 fd ff ff       	call   5d8 <putc>
      }
      state = 0;
 843:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 84a:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 84e:	8b 55 0c             	mov    0xc(%ebp),%edx
 851:	8b 45 f0             	mov    -0x10(%ebp),%eax
 854:	01 d0                	add    %edx,%eax
 856:	0f b6 00             	movzbl (%eax),%eax
 859:	84 c0                	test   %al,%al
 85b:	0f 85 70 fe ff ff    	jne    6d1 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 861:	c9                   	leave  
 862:	c3                   	ret    
 863:	90                   	nop

00000864 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 864:	55                   	push   %ebp
 865:	89 e5                	mov    %esp,%ebp
 867:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 86a:	8b 45 08             	mov    0x8(%ebp),%eax
 86d:	83 e8 08             	sub    $0x8,%eax
 870:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 873:	a1 d0 0d 00 00       	mov    0xdd0,%eax
 878:	89 45 fc             	mov    %eax,-0x4(%ebp)
 87b:	eb 24                	jmp    8a1 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 87d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 880:	8b 00                	mov    (%eax),%eax
 882:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 885:	77 12                	ja     899 <free+0x35>
 887:	8b 45 f8             	mov    -0x8(%ebp),%eax
 88a:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 88d:	77 24                	ja     8b3 <free+0x4f>
 88f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 892:	8b 00                	mov    (%eax),%eax
 894:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 897:	77 1a                	ja     8b3 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 899:	8b 45 fc             	mov    -0x4(%ebp),%eax
 89c:	8b 00                	mov    (%eax),%eax
 89e:	89 45 fc             	mov    %eax,-0x4(%ebp)
 8a1:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8a4:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 8a7:	76 d4                	jbe    87d <free+0x19>
 8a9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8ac:	8b 00                	mov    (%eax),%eax
 8ae:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 8b1:	76 ca                	jbe    87d <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 8b3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8b6:	8b 40 04             	mov    0x4(%eax),%eax
 8b9:	c1 e0 03             	shl    $0x3,%eax
 8bc:	89 c2                	mov    %eax,%edx
 8be:	03 55 f8             	add    -0x8(%ebp),%edx
 8c1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8c4:	8b 00                	mov    (%eax),%eax
 8c6:	39 c2                	cmp    %eax,%edx
 8c8:	75 24                	jne    8ee <free+0x8a>
    bp->s.size += p->s.ptr->s.size;
 8ca:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8cd:	8b 50 04             	mov    0x4(%eax),%edx
 8d0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8d3:	8b 00                	mov    (%eax),%eax
 8d5:	8b 40 04             	mov    0x4(%eax),%eax
 8d8:	01 c2                	add    %eax,%edx
 8da:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8dd:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 8e0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8e3:	8b 00                	mov    (%eax),%eax
 8e5:	8b 10                	mov    (%eax),%edx
 8e7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8ea:	89 10                	mov    %edx,(%eax)
 8ec:	eb 0a                	jmp    8f8 <free+0x94>
  } else
    bp->s.ptr = p->s.ptr;
 8ee:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8f1:	8b 10                	mov    (%eax),%edx
 8f3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8f6:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 8f8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8fb:	8b 40 04             	mov    0x4(%eax),%eax
 8fe:	c1 e0 03             	shl    $0x3,%eax
 901:	03 45 fc             	add    -0x4(%ebp),%eax
 904:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 907:	75 20                	jne    929 <free+0xc5>
    p->s.size += bp->s.size;
 909:	8b 45 fc             	mov    -0x4(%ebp),%eax
 90c:	8b 50 04             	mov    0x4(%eax),%edx
 90f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 912:	8b 40 04             	mov    0x4(%eax),%eax
 915:	01 c2                	add    %eax,%edx
 917:	8b 45 fc             	mov    -0x4(%ebp),%eax
 91a:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 91d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 920:	8b 10                	mov    (%eax),%edx
 922:	8b 45 fc             	mov    -0x4(%ebp),%eax
 925:	89 10                	mov    %edx,(%eax)
 927:	eb 08                	jmp    931 <free+0xcd>
  } else
    p->s.ptr = bp;
 929:	8b 45 fc             	mov    -0x4(%ebp),%eax
 92c:	8b 55 f8             	mov    -0x8(%ebp),%edx
 92f:	89 10                	mov    %edx,(%eax)
  freep = p;
 931:	8b 45 fc             	mov    -0x4(%ebp),%eax
 934:	a3 d0 0d 00 00       	mov    %eax,0xdd0
}
 939:	c9                   	leave  
 93a:	c3                   	ret    

0000093b <morecore>:

static Header*
morecore(uint nu)
{
 93b:	55                   	push   %ebp
 93c:	89 e5                	mov    %esp,%ebp
 93e:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 941:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 948:	77 07                	ja     951 <morecore+0x16>
    nu = 4096;
 94a:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 951:	8b 45 08             	mov    0x8(%ebp),%eax
 954:	c1 e0 03             	shl    $0x3,%eax
 957:	89 04 24             	mov    %eax,(%esp)
 95a:	e8 39 fc ff ff       	call   598 <sbrk>
 95f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 962:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 966:	75 07                	jne    96f <morecore+0x34>
    return 0;
 968:	b8 00 00 00 00       	mov    $0x0,%eax
 96d:	eb 22                	jmp    991 <morecore+0x56>
  hp = (Header*)p;
 96f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 972:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 975:	8b 45 f0             	mov    -0x10(%ebp),%eax
 978:	8b 55 08             	mov    0x8(%ebp),%edx
 97b:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 97e:	8b 45 f0             	mov    -0x10(%ebp),%eax
 981:	83 c0 08             	add    $0x8,%eax
 984:	89 04 24             	mov    %eax,(%esp)
 987:	e8 d8 fe ff ff       	call   864 <free>
  return freep;
 98c:	a1 d0 0d 00 00       	mov    0xdd0,%eax
}
 991:	c9                   	leave  
 992:	c3                   	ret    

00000993 <malloc>:

void*
malloc(uint nbytes)
{
 993:	55                   	push   %ebp
 994:	89 e5                	mov    %esp,%ebp
 996:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 999:	8b 45 08             	mov    0x8(%ebp),%eax
 99c:	83 c0 07             	add    $0x7,%eax
 99f:	c1 e8 03             	shr    $0x3,%eax
 9a2:	83 c0 01             	add    $0x1,%eax
 9a5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 9a8:	a1 d0 0d 00 00       	mov    0xdd0,%eax
 9ad:	89 45 f0             	mov    %eax,-0x10(%ebp)
 9b0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 9b4:	75 23                	jne    9d9 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 9b6:	c7 45 f0 c8 0d 00 00 	movl   $0xdc8,-0x10(%ebp)
 9bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9c0:	a3 d0 0d 00 00       	mov    %eax,0xdd0
 9c5:	a1 d0 0d 00 00       	mov    0xdd0,%eax
 9ca:	a3 c8 0d 00 00       	mov    %eax,0xdc8
    base.s.size = 0;
 9cf:	c7 05 cc 0d 00 00 00 	movl   $0x0,0xdcc
 9d6:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9dc:	8b 00                	mov    (%eax),%eax
 9de:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 9e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9e4:	8b 40 04             	mov    0x4(%eax),%eax
 9e7:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 9ea:	72 4d                	jb     a39 <malloc+0xa6>
      if(p->s.size == nunits)
 9ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9ef:	8b 40 04             	mov    0x4(%eax),%eax
 9f2:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 9f5:	75 0c                	jne    a03 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 9f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9fa:	8b 10                	mov    (%eax),%edx
 9fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9ff:	89 10                	mov    %edx,(%eax)
 a01:	eb 26                	jmp    a29 <malloc+0x96>
      else {
        p->s.size -= nunits;
 a03:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a06:	8b 40 04             	mov    0x4(%eax),%eax
 a09:	89 c2                	mov    %eax,%edx
 a0b:	2b 55 ec             	sub    -0x14(%ebp),%edx
 a0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a11:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 a14:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a17:	8b 40 04             	mov    0x4(%eax),%eax
 a1a:	c1 e0 03             	shl    $0x3,%eax
 a1d:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 a20:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a23:	8b 55 ec             	mov    -0x14(%ebp),%edx
 a26:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 a29:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a2c:	a3 d0 0d 00 00       	mov    %eax,0xdd0
      return (void*)(p + 1);
 a31:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a34:	83 c0 08             	add    $0x8,%eax
 a37:	eb 38                	jmp    a71 <malloc+0xde>
    }
    if(p == freep)
 a39:	a1 d0 0d 00 00       	mov    0xdd0,%eax
 a3e:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 a41:	75 1b                	jne    a5e <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 a43:	8b 45 ec             	mov    -0x14(%ebp),%eax
 a46:	89 04 24             	mov    %eax,(%esp)
 a49:	e8 ed fe ff ff       	call   93b <morecore>
 a4e:	89 45 f4             	mov    %eax,-0xc(%ebp)
 a51:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 a55:	75 07                	jne    a5e <malloc+0xcb>
        return 0;
 a57:	b8 00 00 00 00       	mov    $0x0,%eax
 a5c:	eb 13                	jmp    a71 <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a61:	89 45 f0             	mov    %eax,-0x10(%ebp)
 a64:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a67:	8b 00                	mov    (%eax),%eax
 a69:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 a6c:	e9 70 ff ff ff       	jmp    9e1 <malloc+0x4e>
}
 a71:	c9                   	leave  
 a72:	c3                   	ret    
