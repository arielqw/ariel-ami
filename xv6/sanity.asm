
_sanity:     file format elf32-i386


Disassembly of section .text:

00000000 <getTheNPrimeNumber>:
#define NUM_OF_CHLIDREN 20
#define CALC_SIZE		3000	//8000 is 1min for 1 proc in Ami's laptop


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
  76:	81 ec 90 00 00 00    	sub    $0x90,%esp
	int i, pid;
	int wtime, rtime, iotime;
	int presence[NUM_OF_CHLIDREN];

	set_priority(PRIORITY_HIGH);
  7c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  83:	e8 98 05 00 00       	call   620 <set_priority>
	memset(presence,0,NUM_OF_CHLIDREN);
  88:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
  8f:	00 
  90:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  97:	00 
  98:	8d 44 24 2c          	lea    0x2c(%esp),%eax
  9c:	89 04 24             	mov    %eax,(%esp)
  9f:	e8 17 03 00 00       	call   3bb <memset>

	printf(1, "NUM_OF_CHLIDREN=%d CALC_SIZE=%d\n",NUM_OF_CHLIDREN, CALC_SIZE);
  a4:	c7 44 24 0c b8 0b 00 	movl   $0xbb8,0xc(%esp)
  ab:	00 
  ac:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
  b3:	00 
  b4:	c7 44 24 04 c4 0a 00 	movl   $0xac4,0x4(%esp)
  bb:	00 
  bc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  c3:	e8 37 06 00 00       	call   6ff <printf>


	for (i = 0; i < NUM_OF_CHLIDREN; ++i) {
  c8:	c7 84 24 8c 00 00 00 	movl   $0x0,0x8c(%esp)
  cf:	00 00 00 00 
  d3:	e9 b7 00 00 00       	jmp    18f <main+0x11f>
		if ((pid = fork()) > 0){	//parent
  d8:	e8 7b 04 00 00       	call   558 <fork>
  dd:	89 84 24 88 00 00 00 	mov    %eax,0x88(%esp)
  e4:	83 bc 24 88 00 00 00 	cmpl   $0x0,0x88(%esp)
  eb:	00 
  ec:	7e 29                	jle    117 <main+0xa7>
			printf(1, "(fork:%d)",pid);
  ee:	8b 84 24 88 00 00 00 	mov    0x88(%esp),%eax
  f5:	89 44 24 08          	mov    %eax,0x8(%esp)
  f9:	c7 44 24 04 e5 0a 00 	movl   $0xae5,0x4(%esp)
 100:	00 
 101:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 108:	e8 f2 05 00 00       	call   6ff <printf>
	memset(presence,0,NUM_OF_CHLIDREN);

	printf(1, "NUM_OF_CHLIDREN=%d CALC_SIZE=%d\n",NUM_OF_CHLIDREN, CALC_SIZE);


	for (i = 0; i < NUM_OF_CHLIDREN; ++i) {
 10d:	83 84 24 8c 00 00 00 	addl   $0x1,0x8c(%esp)
 114:	01 
 115:	eb 78                	jmp    18f <main+0x11f>
		if ((pid = fork()) > 0){	//parent
			printf(1, "(fork:%d)",pid);
		}
		else if (pid == 0){	//child
 117:	83 bc 24 88 00 00 00 	cmpl   $0x0,0x88(%esp)
 11e:	00 
 11f:	75 4e                	jne    16f <main+0xff>
			set_priority((i%3));
 121:	8b 8c 24 8c 00 00 00 	mov    0x8c(%esp),%ecx
 128:	ba 56 55 55 55       	mov    $0x55555556,%edx
 12d:	89 c8                	mov    %ecx,%eax
 12f:	f7 ea                	imul   %edx
 131:	89 c8                	mov    %ecx,%eax
 133:	c1 f8 1f             	sar    $0x1f,%eax
 136:	29 c2                	sub    %eax,%edx
 138:	89 d0                	mov    %edx,%eax
 13a:	01 c0                	add    %eax,%eax
 13c:	01 d0                	add    %edx,%eax
 13e:	89 ca                	mov    %ecx,%edx
 140:	29 c2                	sub    %eax,%edx
 142:	89 14 24             	mov    %edx,(%esp)
 145:	e8 d6 04 00 00       	call   620 <set_priority>
			sleep(100);
 14a:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
 151:	e8 9a 04 00 00       	call   5f0 <sleep>
			getTheNPrimeNumber(CALC_SIZE);
 156:	c7 04 24 b8 0b 00 00 	movl   $0xbb8,(%esp)
 15d:	e8 9e fe ff ff       	call   0 <getTheNPrimeNumber>
			exit(getpid());
 162:	e8 79 04 00 00       	call   5e0 <getpid>
 167:	89 04 24             	mov    %eax,(%esp)
 16a:	e8 f1 03 00 00       	call   560 <exit>
		}
		else{
			printf(1, "\nERROR: Fork failed\n");
 16f:	c7 44 24 04 ef 0a 00 	movl   $0xaef,0x4(%esp)
 176:	00 
 177:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 17e:	e8 7c 05 00 00       	call   6ff <printf>
			exit(EXIT_STATUS_FAILURE);
 183:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 18a:	e8 d1 03 00 00       	call   560 <exit>
	memset(presence,0,NUM_OF_CHLIDREN);

	printf(1, "NUM_OF_CHLIDREN=%d CALC_SIZE=%d\n",NUM_OF_CHLIDREN, CALC_SIZE);


	for (i = 0; i < NUM_OF_CHLIDREN; ++i) {
 18f:	83 bc 24 8c 00 00 00 	cmpl   $0x13,0x8c(%esp)
 196:	13 
 197:	0f 8e 3b ff ff ff    	jle    d8 <main+0x68>
		else{
			printf(1, "\nERROR: Fork failed\n");
			exit(EXIT_STATUS_FAILURE);
		}
	}
	printf(1,"\n");
 19d:	c7 44 24 04 04 0b 00 	movl   $0xb04,0x4(%esp)
 1a4:	00 
 1a5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 1ac:	e8 4e 05 00 00       	call   6ff <printf>

	for (i = 0; i < NUM_OF_CHLIDREN; ++i){
 1b1:	c7 84 24 8c 00 00 00 	movl   $0x0,0x8c(%esp)
 1b8:	00 00 00 00 
 1bc:	e9 bd 00 00 00       	jmp    27e <main+0x20e>

		pid = wait_stat(&wtime,&rtime,&iotime);
 1c1:	8d 44 24 7c          	lea    0x7c(%esp),%eax
 1c5:	89 44 24 08          	mov    %eax,0x8(%esp)
 1c9:	8d 84 24 80 00 00 00 	lea    0x80(%esp),%eax
 1d0:	89 44 24 04          	mov    %eax,0x4(%esp)
 1d4:	8d 84 24 84 00 00 00 	lea    0x84(%esp),%eax
 1db:	89 04 24             	mov    %eax,(%esp)
 1de:	e8 25 04 00 00       	call   608 <wait_stat>
 1e3:	89 84 24 88 00 00 00 	mov    %eax,0x88(%esp)
		if (pid<0){
 1ea:	83 bc 24 88 00 00 00 	cmpl   $0x0,0x88(%esp)
 1f1:	00 
 1f2:	79 20                	jns    214 <main+0x1a4>
			printf(1, "\nERROR: Not enought waits.\n");
 1f4:	c7 44 24 04 06 0b 00 	movl   $0xb06,0x4(%esp)
 1fb:	00 
 1fc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 203:	e8 f7 04 00 00       	call   6ff <printf>
			exit(EXIT_STATUS_FAILURE);
 208:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 20f:	e8 4c 03 00 00       	call   560 <exit>
		}
		//printf(1, "Done(%d) ; ", pid);
		printf(1,"Done(%d): waiting (RUNNABLE): %d | running: %d | turnaround : %d\n",
				pid, wtime, rtime, wtime+rtime+iotime);
 214:	8b 94 24 84 00 00 00 	mov    0x84(%esp),%edx
 21b:	8b 84 24 80 00 00 00 	mov    0x80(%esp),%eax
 222:	01 c2                	add    %eax,%edx
		if (pid<0){
			printf(1, "\nERROR: Not enought waits.\n");
			exit(EXIT_STATUS_FAILURE);
		}
		//printf(1, "Done(%d) ; ", pid);
		printf(1,"Done(%d): waiting (RUNNABLE): %d | running: %d | turnaround : %d\n",
 224:	8b 44 24 7c          	mov    0x7c(%esp),%eax
 228:	8d 0c 02             	lea    (%edx,%eax,1),%ecx
 22b:	8b 94 24 80 00 00 00 	mov    0x80(%esp),%edx
 232:	8b 84 24 84 00 00 00 	mov    0x84(%esp),%eax
 239:	89 4c 24 14          	mov    %ecx,0x14(%esp)
 23d:	89 54 24 10          	mov    %edx,0x10(%esp)
 241:	89 44 24 0c          	mov    %eax,0xc(%esp)
 245:	8b 84 24 88 00 00 00 	mov    0x88(%esp),%eax
 24c:	89 44 24 08          	mov    %eax,0x8(%esp)
 250:	c7 44 24 04 24 0b 00 	movl   $0xb24,0x4(%esp)
 257:	00 
 258:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 25f:	e8 9b 04 00 00       	call   6ff <printf>
				pid, wtime, rtime, wtime+rtime+iotime);
		presence[i] = pid;
 264:	8b 84 24 8c 00 00 00 	mov    0x8c(%esp),%eax
 26b:	8b 94 24 88 00 00 00 	mov    0x88(%esp),%edx
 272:	89 54 84 2c          	mov    %edx,0x2c(%esp,%eax,4)
			exit(EXIT_STATUS_FAILURE);
		}
	}
	printf(1,"\n");

	for (i = 0; i < NUM_OF_CHLIDREN; ++i){
 276:	83 84 24 8c 00 00 00 	addl   $0x1,0x8c(%esp)
 27d:	01 
 27e:	83 bc 24 8c 00 00 00 	cmpl   $0x13,0x8c(%esp)
 285:	13 
 286:	0f 8e 35 ff ff ff    	jle    1c1 <main+0x151>
		printf(1,"Done(%d): waiting (RUNNABLE): %d | running: %d | turnaround : %d\n",
				pid, wtime, rtime, wtime+rtime+iotime);
		presence[i] = pid;
	}

	for (i = 0; i < NUM_OF_CHLIDREN; ++i){
 28c:	c7 84 24 8c 00 00 00 	movl   $0x0,0x8c(%esp)
 293:	00 00 00 00 
 297:	eb 37                	jmp    2d0 <main+0x260>
		if(!presence[i]){
 299:	8b 84 24 8c 00 00 00 	mov    0x8c(%esp),%eax
 2a0:	8b 44 84 2c          	mov    0x2c(%esp,%eax,4),%eax
 2a4:	85 c0                	test   %eax,%eax
 2a6:	75 20                	jne    2c8 <main+0x258>
			printf(1, "\nERROR: Not enough waits.\n");
 2a8:	c7 44 24 04 66 0b 00 	movl   $0xb66,0x4(%esp)
 2af:	00 
 2b0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 2b7:	e8 43 04 00 00       	call   6ff <printf>
			exit(EXIT_STATUS_FAILURE);
 2bc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 2c3:	e8 98 02 00 00       	call   560 <exit>
		printf(1,"Done(%d): waiting (RUNNABLE): %d | running: %d | turnaround : %d\n",
				pid, wtime, rtime, wtime+rtime+iotime);
		presence[i] = pid;
	}

	for (i = 0; i < NUM_OF_CHLIDREN; ++i){
 2c8:	83 84 24 8c 00 00 00 	addl   $0x1,0x8c(%esp)
 2cf:	01 
 2d0:	83 bc 24 8c 00 00 00 	cmpl   $0x13,0x8c(%esp)
 2d7:	13 
 2d8:	7e bf                	jle    299 <main+0x229>
		if(!presence[i]){
			printf(1, "\nERROR: Not enough waits.\n");
			exit(EXIT_STATUS_FAILURE);
		}
	}
	printf(1, "Success: Great Success!.\n");
 2da:	c7 44 24 04 81 0b 00 	movl   $0xb81,0x4(%esp)
 2e1:	00 
 2e2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 2e9:	e8 11 04 00 00       	call   6ff <printf>
	exit(EXIT_STATUS_SUCCESS);
 2ee:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 2f5:	e8 66 02 00 00       	call   560 <exit>
 2fa:	90                   	nop
 2fb:	90                   	nop

000002fc <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 2fc:	55                   	push   %ebp
 2fd:	89 e5                	mov    %esp,%ebp
 2ff:	57                   	push   %edi
 300:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 301:	8b 4d 08             	mov    0x8(%ebp),%ecx
 304:	8b 55 10             	mov    0x10(%ebp),%edx
 307:	8b 45 0c             	mov    0xc(%ebp),%eax
 30a:	89 cb                	mov    %ecx,%ebx
 30c:	89 df                	mov    %ebx,%edi
 30e:	89 d1                	mov    %edx,%ecx
 310:	fc                   	cld    
 311:	f3 aa                	rep stos %al,%es:(%edi)
 313:	89 ca                	mov    %ecx,%edx
 315:	89 fb                	mov    %edi,%ebx
 317:	89 5d 08             	mov    %ebx,0x8(%ebp)
 31a:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 31d:	5b                   	pop    %ebx
 31e:	5f                   	pop    %edi
 31f:	5d                   	pop    %ebp
 320:	c3                   	ret    

00000321 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 321:	55                   	push   %ebp
 322:	89 e5                	mov    %esp,%ebp
 324:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 327:	8b 45 08             	mov    0x8(%ebp),%eax
 32a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 32d:	90                   	nop
 32e:	8b 45 0c             	mov    0xc(%ebp),%eax
 331:	0f b6 10             	movzbl (%eax),%edx
 334:	8b 45 08             	mov    0x8(%ebp),%eax
 337:	88 10                	mov    %dl,(%eax)
 339:	8b 45 08             	mov    0x8(%ebp),%eax
 33c:	0f b6 00             	movzbl (%eax),%eax
 33f:	84 c0                	test   %al,%al
 341:	0f 95 c0             	setne  %al
 344:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 348:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 34c:	84 c0                	test   %al,%al
 34e:	75 de                	jne    32e <strcpy+0xd>
    ;
  return os;
 350:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 353:	c9                   	leave  
 354:	c3                   	ret    

00000355 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 355:	55                   	push   %ebp
 356:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 358:	eb 08                	jmp    362 <strcmp+0xd>
    p++, q++;
 35a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 35e:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 362:	8b 45 08             	mov    0x8(%ebp),%eax
 365:	0f b6 00             	movzbl (%eax),%eax
 368:	84 c0                	test   %al,%al
 36a:	74 10                	je     37c <strcmp+0x27>
 36c:	8b 45 08             	mov    0x8(%ebp),%eax
 36f:	0f b6 10             	movzbl (%eax),%edx
 372:	8b 45 0c             	mov    0xc(%ebp),%eax
 375:	0f b6 00             	movzbl (%eax),%eax
 378:	38 c2                	cmp    %al,%dl
 37a:	74 de                	je     35a <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 37c:	8b 45 08             	mov    0x8(%ebp),%eax
 37f:	0f b6 00             	movzbl (%eax),%eax
 382:	0f b6 d0             	movzbl %al,%edx
 385:	8b 45 0c             	mov    0xc(%ebp),%eax
 388:	0f b6 00             	movzbl (%eax),%eax
 38b:	0f b6 c0             	movzbl %al,%eax
 38e:	89 d1                	mov    %edx,%ecx
 390:	29 c1                	sub    %eax,%ecx
 392:	89 c8                	mov    %ecx,%eax
}
 394:	5d                   	pop    %ebp
 395:	c3                   	ret    

00000396 <strlen>:

uint
strlen(char *s)
{
 396:	55                   	push   %ebp
 397:	89 e5                	mov    %esp,%ebp
 399:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 39c:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 3a3:	eb 04                	jmp    3a9 <strlen+0x13>
 3a5:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 3a9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 3ac:	03 45 08             	add    0x8(%ebp),%eax
 3af:	0f b6 00             	movzbl (%eax),%eax
 3b2:	84 c0                	test   %al,%al
 3b4:	75 ef                	jne    3a5 <strlen+0xf>
    ;
  return n;
 3b6:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 3b9:	c9                   	leave  
 3ba:	c3                   	ret    

000003bb <memset>:

void*
memset(void *dst, int c, uint n)
{
 3bb:	55                   	push   %ebp
 3bc:	89 e5                	mov    %esp,%ebp
 3be:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 3c1:	8b 45 10             	mov    0x10(%ebp),%eax
 3c4:	89 44 24 08          	mov    %eax,0x8(%esp)
 3c8:	8b 45 0c             	mov    0xc(%ebp),%eax
 3cb:	89 44 24 04          	mov    %eax,0x4(%esp)
 3cf:	8b 45 08             	mov    0x8(%ebp),%eax
 3d2:	89 04 24             	mov    %eax,(%esp)
 3d5:	e8 22 ff ff ff       	call   2fc <stosb>
  return dst;
 3da:	8b 45 08             	mov    0x8(%ebp),%eax
}
 3dd:	c9                   	leave  
 3de:	c3                   	ret    

000003df <strchr>:

char*
strchr(const char *s, char c)
{
 3df:	55                   	push   %ebp
 3e0:	89 e5                	mov    %esp,%ebp
 3e2:	83 ec 04             	sub    $0x4,%esp
 3e5:	8b 45 0c             	mov    0xc(%ebp),%eax
 3e8:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 3eb:	eb 14                	jmp    401 <strchr+0x22>
    if(*s == c)
 3ed:	8b 45 08             	mov    0x8(%ebp),%eax
 3f0:	0f b6 00             	movzbl (%eax),%eax
 3f3:	3a 45 fc             	cmp    -0x4(%ebp),%al
 3f6:	75 05                	jne    3fd <strchr+0x1e>
      return (char*)s;
 3f8:	8b 45 08             	mov    0x8(%ebp),%eax
 3fb:	eb 13                	jmp    410 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 3fd:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 401:	8b 45 08             	mov    0x8(%ebp),%eax
 404:	0f b6 00             	movzbl (%eax),%eax
 407:	84 c0                	test   %al,%al
 409:	75 e2                	jne    3ed <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 40b:	b8 00 00 00 00       	mov    $0x0,%eax
}
 410:	c9                   	leave  
 411:	c3                   	ret    

00000412 <gets>:

char*
gets(char *buf, int max)
{
 412:	55                   	push   %ebp
 413:	89 e5                	mov    %esp,%ebp
 415:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 418:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 41f:	eb 44                	jmp    465 <gets+0x53>
    cc = read(0, &c, 1);
 421:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 428:	00 
 429:	8d 45 ef             	lea    -0x11(%ebp),%eax
 42c:	89 44 24 04          	mov    %eax,0x4(%esp)
 430:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 437:	e8 3c 01 00 00       	call   578 <read>
 43c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 43f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 443:	7e 2d                	jle    472 <gets+0x60>
      break;
    buf[i++] = c;
 445:	8b 45 f4             	mov    -0xc(%ebp),%eax
 448:	03 45 08             	add    0x8(%ebp),%eax
 44b:	0f b6 55 ef          	movzbl -0x11(%ebp),%edx
 44f:	88 10                	mov    %dl,(%eax)
 451:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(c == '\n' || c == '\r')
 455:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 459:	3c 0a                	cmp    $0xa,%al
 45b:	74 16                	je     473 <gets+0x61>
 45d:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 461:	3c 0d                	cmp    $0xd,%al
 463:	74 0e                	je     473 <gets+0x61>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 465:	8b 45 f4             	mov    -0xc(%ebp),%eax
 468:	83 c0 01             	add    $0x1,%eax
 46b:	3b 45 0c             	cmp    0xc(%ebp),%eax
 46e:	7c b1                	jl     421 <gets+0xf>
 470:	eb 01                	jmp    473 <gets+0x61>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 472:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 473:	8b 45 f4             	mov    -0xc(%ebp),%eax
 476:	03 45 08             	add    0x8(%ebp),%eax
 479:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 47c:	8b 45 08             	mov    0x8(%ebp),%eax
}
 47f:	c9                   	leave  
 480:	c3                   	ret    

00000481 <stat>:

int
stat(char *n, struct stat *st)
{
 481:	55                   	push   %ebp
 482:	89 e5                	mov    %esp,%ebp
 484:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 487:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 48e:	00 
 48f:	8b 45 08             	mov    0x8(%ebp),%eax
 492:	89 04 24             	mov    %eax,(%esp)
 495:	e8 06 01 00 00       	call   5a0 <open>
 49a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 49d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 4a1:	79 07                	jns    4aa <stat+0x29>
    return -1;
 4a3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 4a8:	eb 23                	jmp    4cd <stat+0x4c>
  r = fstat(fd, st);
 4aa:	8b 45 0c             	mov    0xc(%ebp),%eax
 4ad:	89 44 24 04          	mov    %eax,0x4(%esp)
 4b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4b4:	89 04 24             	mov    %eax,(%esp)
 4b7:	e8 fc 00 00 00       	call   5b8 <fstat>
 4bc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 4bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4c2:	89 04 24             	mov    %eax,(%esp)
 4c5:	e8 be 00 00 00       	call   588 <close>
  return r;
 4ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 4cd:	c9                   	leave  
 4ce:	c3                   	ret    

000004cf <atoi>:

int
atoi(const char *s)
{
 4cf:	55                   	push   %ebp
 4d0:	89 e5                	mov    %esp,%ebp
 4d2:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 4d5:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 4dc:	eb 23                	jmp    501 <atoi+0x32>
    n = n*10 + *s++ - '0';
 4de:	8b 55 fc             	mov    -0x4(%ebp),%edx
 4e1:	89 d0                	mov    %edx,%eax
 4e3:	c1 e0 02             	shl    $0x2,%eax
 4e6:	01 d0                	add    %edx,%eax
 4e8:	01 c0                	add    %eax,%eax
 4ea:	89 c2                	mov    %eax,%edx
 4ec:	8b 45 08             	mov    0x8(%ebp),%eax
 4ef:	0f b6 00             	movzbl (%eax),%eax
 4f2:	0f be c0             	movsbl %al,%eax
 4f5:	01 d0                	add    %edx,%eax
 4f7:	83 e8 30             	sub    $0x30,%eax
 4fa:	89 45 fc             	mov    %eax,-0x4(%ebp)
 4fd:	83 45 08 01          	addl   $0x1,0x8(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 501:	8b 45 08             	mov    0x8(%ebp),%eax
 504:	0f b6 00             	movzbl (%eax),%eax
 507:	3c 2f                	cmp    $0x2f,%al
 509:	7e 0a                	jle    515 <atoi+0x46>
 50b:	8b 45 08             	mov    0x8(%ebp),%eax
 50e:	0f b6 00             	movzbl (%eax),%eax
 511:	3c 39                	cmp    $0x39,%al
 513:	7e c9                	jle    4de <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 515:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 518:	c9                   	leave  
 519:	c3                   	ret    

0000051a <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 51a:	55                   	push   %ebp
 51b:	89 e5                	mov    %esp,%ebp
 51d:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 520:	8b 45 08             	mov    0x8(%ebp),%eax
 523:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 526:	8b 45 0c             	mov    0xc(%ebp),%eax
 529:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 52c:	eb 13                	jmp    541 <memmove+0x27>
    *dst++ = *src++;
 52e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 531:	0f b6 10             	movzbl (%eax),%edx
 534:	8b 45 fc             	mov    -0x4(%ebp),%eax
 537:	88 10                	mov    %dl,(%eax)
 539:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 53d:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 541:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 545:	0f 9f c0             	setg   %al
 548:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 54c:	84 c0                	test   %al,%al
 54e:	75 de                	jne    52e <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 550:	8b 45 08             	mov    0x8(%ebp),%eax
}
 553:	c9                   	leave  
 554:	c3                   	ret    
 555:	90                   	nop
 556:	90                   	nop
 557:	90                   	nop

00000558 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 558:	b8 01 00 00 00       	mov    $0x1,%eax
 55d:	cd 40                	int    $0x40
 55f:	c3                   	ret    

00000560 <exit>:
SYSCALL(exit)
 560:	b8 02 00 00 00       	mov    $0x2,%eax
 565:	cd 40                	int    $0x40
 567:	c3                   	ret    

00000568 <wait>:
SYSCALL(wait)
 568:	b8 03 00 00 00       	mov    $0x3,%eax
 56d:	cd 40                	int    $0x40
 56f:	c3                   	ret    

00000570 <pipe>:
SYSCALL(pipe)
 570:	b8 04 00 00 00       	mov    $0x4,%eax
 575:	cd 40                	int    $0x40
 577:	c3                   	ret    

00000578 <read>:
SYSCALL(read)
 578:	b8 05 00 00 00       	mov    $0x5,%eax
 57d:	cd 40                	int    $0x40
 57f:	c3                   	ret    

00000580 <write>:
SYSCALL(write)
 580:	b8 10 00 00 00       	mov    $0x10,%eax
 585:	cd 40                	int    $0x40
 587:	c3                   	ret    

00000588 <close>:
SYSCALL(close)
 588:	b8 15 00 00 00       	mov    $0x15,%eax
 58d:	cd 40                	int    $0x40
 58f:	c3                   	ret    

00000590 <kill>:
SYSCALL(kill)
 590:	b8 06 00 00 00       	mov    $0x6,%eax
 595:	cd 40                	int    $0x40
 597:	c3                   	ret    

00000598 <exec>:
SYSCALL(exec)
 598:	b8 07 00 00 00       	mov    $0x7,%eax
 59d:	cd 40                	int    $0x40
 59f:	c3                   	ret    

000005a0 <open>:
SYSCALL(open)
 5a0:	b8 0f 00 00 00       	mov    $0xf,%eax
 5a5:	cd 40                	int    $0x40
 5a7:	c3                   	ret    

000005a8 <mknod>:
SYSCALL(mknod)
 5a8:	b8 11 00 00 00       	mov    $0x11,%eax
 5ad:	cd 40                	int    $0x40
 5af:	c3                   	ret    

000005b0 <unlink>:
SYSCALL(unlink)
 5b0:	b8 12 00 00 00       	mov    $0x12,%eax
 5b5:	cd 40                	int    $0x40
 5b7:	c3                   	ret    

000005b8 <fstat>:
SYSCALL(fstat)
 5b8:	b8 08 00 00 00       	mov    $0x8,%eax
 5bd:	cd 40                	int    $0x40
 5bf:	c3                   	ret    

000005c0 <link>:
SYSCALL(link)
 5c0:	b8 13 00 00 00       	mov    $0x13,%eax
 5c5:	cd 40                	int    $0x40
 5c7:	c3                   	ret    

000005c8 <mkdir>:
SYSCALL(mkdir)
 5c8:	b8 14 00 00 00       	mov    $0x14,%eax
 5cd:	cd 40                	int    $0x40
 5cf:	c3                   	ret    

000005d0 <chdir>:
SYSCALL(chdir)
 5d0:	b8 09 00 00 00       	mov    $0x9,%eax
 5d5:	cd 40                	int    $0x40
 5d7:	c3                   	ret    

000005d8 <dup>:
SYSCALL(dup)
 5d8:	b8 0a 00 00 00       	mov    $0xa,%eax
 5dd:	cd 40                	int    $0x40
 5df:	c3                   	ret    

000005e0 <getpid>:
SYSCALL(getpid)
 5e0:	b8 0b 00 00 00       	mov    $0xb,%eax
 5e5:	cd 40                	int    $0x40
 5e7:	c3                   	ret    

000005e8 <sbrk>:
SYSCALL(sbrk)
 5e8:	b8 0c 00 00 00       	mov    $0xc,%eax
 5ed:	cd 40                	int    $0x40
 5ef:	c3                   	ret    

000005f0 <sleep>:
SYSCALL(sleep)
 5f0:	b8 0d 00 00 00       	mov    $0xd,%eax
 5f5:	cd 40                	int    $0x40
 5f7:	c3                   	ret    

000005f8 <uptime>:
SYSCALL(uptime)
 5f8:	b8 0e 00 00 00       	mov    $0xe,%eax
 5fd:	cd 40                	int    $0x40
 5ff:	c3                   	ret    

00000600 <waitpid>:
SYSCALL(waitpid)
 600:	b8 16 00 00 00       	mov    $0x16,%eax
 605:	cd 40                	int    $0x40
 607:	c3                   	ret    

00000608 <wait_stat>:
SYSCALL(wait_stat)
 608:	b8 17 00 00 00       	mov    $0x17,%eax
 60d:	cd 40                	int    $0x40
 60f:	c3                   	ret    

00000610 <list_pgroup>:
SYSCALL(list_pgroup)
 610:	b8 18 00 00 00       	mov    $0x18,%eax
 615:	cd 40                	int    $0x40
 617:	c3                   	ret    

00000618 <foreground>:
SYSCALL(foreground)
 618:	b8 19 00 00 00       	mov    $0x19,%eax
 61d:	cd 40                	int    $0x40
 61f:	c3                   	ret    

00000620 <set_priority>:
SYSCALL(set_priority)
 620:	b8 1a 00 00 00       	mov    $0x1a,%eax
 625:	cd 40                	int    $0x40
 627:	c3                   	ret    

00000628 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 628:	55                   	push   %ebp
 629:	89 e5                	mov    %esp,%ebp
 62b:	83 ec 28             	sub    $0x28,%esp
 62e:	8b 45 0c             	mov    0xc(%ebp),%eax
 631:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 634:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 63b:	00 
 63c:	8d 45 f4             	lea    -0xc(%ebp),%eax
 63f:	89 44 24 04          	mov    %eax,0x4(%esp)
 643:	8b 45 08             	mov    0x8(%ebp),%eax
 646:	89 04 24             	mov    %eax,(%esp)
 649:	e8 32 ff ff ff       	call   580 <write>
}
 64e:	c9                   	leave  
 64f:	c3                   	ret    

00000650 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 650:	55                   	push   %ebp
 651:	89 e5                	mov    %esp,%ebp
 653:	83 ec 48             	sub    $0x48,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 656:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 65d:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 661:	74 17                	je     67a <printint+0x2a>
 663:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 667:	79 11                	jns    67a <printint+0x2a>
    neg = 1;
 669:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 670:	8b 45 0c             	mov    0xc(%ebp),%eax
 673:	f7 d8                	neg    %eax
 675:	89 45 ec             	mov    %eax,-0x14(%ebp)
 678:	eb 06                	jmp    680 <printint+0x30>
  } else {
    x = xx;
 67a:	8b 45 0c             	mov    0xc(%ebp),%eax
 67d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 680:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 687:	8b 4d 10             	mov    0x10(%ebp),%ecx
 68a:	8b 45 ec             	mov    -0x14(%ebp),%eax
 68d:	ba 00 00 00 00       	mov    $0x0,%edx
 692:	f7 f1                	div    %ecx
 694:	89 d0                	mov    %edx,%eax
 696:	0f b6 90 04 0e 00 00 	movzbl 0xe04(%eax),%edx
 69d:	8d 45 dc             	lea    -0x24(%ebp),%eax
 6a0:	03 45 f4             	add    -0xc(%ebp),%eax
 6a3:	88 10                	mov    %dl,(%eax)
 6a5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  }while((x /= base) != 0);
 6a9:	8b 55 10             	mov    0x10(%ebp),%edx
 6ac:	89 55 d4             	mov    %edx,-0x2c(%ebp)
 6af:	8b 45 ec             	mov    -0x14(%ebp),%eax
 6b2:	ba 00 00 00 00       	mov    $0x0,%edx
 6b7:	f7 75 d4             	divl   -0x2c(%ebp)
 6ba:	89 45 ec             	mov    %eax,-0x14(%ebp)
 6bd:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 6c1:	75 c4                	jne    687 <printint+0x37>
  if(neg)
 6c3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 6c7:	74 2a                	je     6f3 <printint+0xa3>
    buf[i++] = '-';
 6c9:	8d 45 dc             	lea    -0x24(%ebp),%eax
 6cc:	03 45 f4             	add    -0xc(%ebp),%eax
 6cf:	c6 00 2d             	movb   $0x2d,(%eax)
 6d2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

  while(--i >= 0)
 6d6:	eb 1b                	jmp    6f3 <printint+0xa3>
    putc(fd, buf[i]);
 6d8:	8d 45 dc             	lea    -0x24(%ebp),%eax
 6db:	03 45 f4             	add    -0xc(%ebp),%eax
 6de:	0f b6 00             	movzbl (%eax),%eax
 6e1:	0f be c0             	movsbl %al,%eax
 6e4:	89 44 24 04          	mov    %eax,0x4(%esp)
 6e8:	8b 45 08             	mov    0x8(%ebp),%eax
 6eb:	89 04 24             	mov    %eax,(%esp)
 6ee:	e8 35 ff ff ff       	call   628 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 6f3:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 6f7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 6fb:	79 db                	jns    6d8 <printint+0x88>
    putc(fd, buf[i]);
}
 6fd:	c9                   	leave  
 6fe:	c3                   	ret    

000006ff <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 6ff:	55                   	push   %ebp
 700:	89 e5                	mov    %esp,%ebp
 702:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 705:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 70c:	8d 45 0c             	lea    0xc(%ebp),%eax
 70f:	83 c0 04             	add    $0x4,%eax
 712:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 715:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 71c:	e9 7d 01 00 00       	jmp    89e <printf+0x19f>
    c = fmt[i] & 0xff;
 721:	8b 55 0c             	mov    0xc(%ebp),%edx
 724:	8b 45 f0             	mov    -0x10(%ebp),%eax
 727:	01 d0                	add    %edx,%eax
 729:	0f b6 00             	movzbl (%eax),%eax
 72c:	0f be c0             	movsbl %al,%eax
 72f:	25 ff 00 00 00       	and    $0xff,%eax
 734:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 737:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 73b:	75 2c                	jne    769 <printf+0x6a>
      if(c == '%'){
 73d:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 741:	75 0c                	jne    74f <printf+0x50>
        state = '%';
 743:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 74a:	e9 4b 01 00 00       	jmp    89a <printf+0x19b>
      } else {
        putc(fd, c);
 74f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 752:	0f be c0             	movsbl %al,%eax
 755:	89 44 24 04          	mov    %eax,0x4(%esp)
 759:	8b 45 08             	mov    0x8(%ebp),%eax
 75c:	89 04 24             	mov    %eax,(%esp)
 75f:	e8 c4 fe ff ff       	call   628 <putc>
 764:	e9 31 01 00 00       	jmp    89a <printf+0x19b>
      }
    } else if(state == '%'){
 769:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 76d:	0f 85 27 01 00 00    	jne    89a <printf+0x19b>
      if(c == 'd'){
 773:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 777:	75 2d                	jne    7a6 <printf+0xa7>
        printint(fd, *ap, 10, 1);
 779:	8b 45 e8             	mov    -0x18(%ebp),%eax
 77c:	8b 00                	mov    (%eax),%eax
 77e:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 785:	00 
 786:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 78d:	00 
 78e:	89 44 24 04          	mov    %eax,0x4(%esp)
 792:	8b 45 08             	mov    0x8(%ebp),%eax
 795:	89 04 24             	mov    %eax,(%esp)
 798:	e8 b3 fe ff ff       	call   650 <printint>
        ap++;
 79d:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 7a1:	e9 ed 00 00 00       	jmp    893 <printf+0x194>
      } else if(c == 'x' || c == 'p'){
 7a6:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 7aa:	74 06                	je     7b2 <printf+0xb3>
 7ac:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 7b0:	75 2d                	jne    7df <printf+0xe0>
        printint(fd, *ap, 16, 0);
 7b2:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7b5:	8b 00                	mov    (%eax),%eax
 7b7:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 7be:	00 
 7bf:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 7c6:	00 
 7c7:	89 44 24 04          	mov    %eax,0x4(%esp)
 7cb:	8b 45 08             	mov    0x8(%ebp),%eax
 7ce:	89 04 24             	mov    %eax,(%esp)
 7d1:	e8 7a fe ff ff       	call   650 <printint>
        ap++;
 7d6:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 7da:	e9 b4 00 00 00       	jmp    893 <printf+0x194>
      } else if(c == 's'){
 7df:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 7e3:	75 46                	jne    82b <printf+0x12c>
        s = (char*)*ap;
 7e5:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7e8:	8b 00                	mov    (%eax),%eax
 7ea:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 7ed:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 7f1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 7f5:	75 27                	jne    81e <printf+0x11f>
          s = "(null)";
 7f7:	c7 45 f4 9b 0b 00 00 	movl   $0xb9b,-0xc(%ebp)
        while(*s != 0){
 7fe:	eb 1e                	jmp    81e <printf+0x11f>
          putc(fd, *s);
 800:	8b 45 f4             	mov    -0xc(%ebp),%eax
 803:	0f b6 00             	movzbl (%eax),%eax
 806:	0f be c0             	movsbl %al,%eax
 809:	89 44 24 04          	mov    %eax,0x4(%esp)
 80d:	8b 45 08             	mov    0x8(%ebp),%eax
 810:	89 04 24             	mov    %eax,(%esp)
 813:	e8 10 fe ff ff       	call   628 <putc>
          s++;
 818:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 81c:	eb 01                	jmp    81f <printf+0x120>
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 81e:	90                   	nop
 81f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 822:	0f b6 00             	movzbl (%eax),%eax
 825:	84 c0                	test   %al,%al
 827:	75 d7                	jne    800 <printf+0x101>
 829:	eb 68                	jmp    893 <printf+0x194>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 82b:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 82f:	75 1d                	jne    84e <printf+0x14f>
        putc(fd, *ap);
 831:	8b 45 e8             	mov    -0x18(%ebp),%eax
 834:	8b 00                	mov    (%eax),%eax
 836:	0f be c0             	movsbl %al,%eax
 839:	89 44 24 04          	mov    %eax,0x4(%esp)
 83d:	8b 45 08             	mov    0x8(%ebp),%eax
 840:	89 04 24             	mov    %eax,(%esp)
 843:	e8 e0 fd ff ff       	call   628 <putc>
        ap++;
 848:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 84c:	eb 45                	jmp    893 <printf+0x194>
      } else if(c == '%'){
 84e:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 852:	75 17                	jne    86b <printf+0x16c>
        putc(fd, c);
 854:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 857:	0f be c0             	movsbl %al,%eax
 85a:	89 44 24 04          	mov    %eax,0x4(%esp)
 85e:	8b 45 08             	mov    0x8(%ebp),%eax
 861:	89 04 24             	mov    %eax,(%esp)
 864:	e8 bf fd ff ff       	call   628 <putc>
 869:	eb 28                	jmp    893 <printf+0x194>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 86b:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 872:	00 
 873:	8b 45 08             	mov    0x8(%ebp),%eax
 876:	89 04 24             	mov    %eax,(%esp)
 879:	e8 aa fd ff ff       	call   628 <putc>
        putc(fd, c);
 87e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 881:	0f be c0             	movsbl %al,%eax
 884:	89 44 24 04          	mov    %eax,0x4(%esp)
 888:	8b 45 08             	mov    0x8(%ebp),%eax
 88b:	89 04 24             	mov    %eax,(%esp)
 88e:	e8 95 fd ff ff       	call   628 <putc>
      }
      state = 0;
 893:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 89a:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 89e:	8b 55 0c             	mov    0xc(%ebp),%edx
 8a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8a4:	01 d0                	add    %edx,%eax
 8a6:	0f b6 00             	movzbl (%eax),%eax
 8a9:	84 c0                	test   %al,%al
 8ab:	0f 85 70 fe ff ff    	jne    721 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 8b1:	c9                   	leave  
 8b2:	c3                   	ret    
 8b3:	90                   	nop

000008b4 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 8b4:	55                   	push   %ebp
 8b5:	89 e5                	mov    %esp,%ebp
 8b7:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 8ba:	8b 45 08             	mov    0x8(%ebp),%eax
 8bd:	83 e8 08             	sub    $0x8,%eax
 8c0:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8c3:	a1 20 0e 00 00       	mov    0xe20,%eax
 8c8:	89 45 fc             	mov    %eax,-0x4(%ebp)
 8cb:	eb 24                	jmp    8f1 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8cd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8d0:	8b 00                	mov    (%eax),%eax
 8d2:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 8d5:	77 12                	ja     8e9 <free+0x35>
 8d7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8da:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 8dd:	77 24                	ja     903 <free+0x4f>
 8df:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8e2:	8b 00                	mov    (%eax),%eax
 8e4:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 8e7:	77 1a                	ja     903 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8e9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8ec:	8b 00                	mov    (%eax),%eax
 8ee:	89 45 fc             	mov    %eax,-0x4(%ebp)
 8f1:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8f4:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 8f7:	76 d4                	jbe    8cd <free+0x19>
 8f9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8fc:	8b 00                	mov    (%eax),%eax
 8fe:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 901:	76 ca                	jbe    8cd <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 903:	8b 45 f8             	mov    -0x8(%ebp),%eax
 906:	8b 40 04             	mov    0x4(%eax),%eax
 909:	c1 e0 03             	shl    $0x3,%eax
 90c:	89 c2                	mov    %eax,%edx
 90e:	03 55 f8             	add    -0x8(%ebp),%edx
 911:	8b 45 fc             	mov    -0x4(%ebp),%eax
 914:	8b 00                	mov    (%eax),%eax
 916:	39 c2                	cmp    %eax,%edx
 918:	75 24                	jne    93e <free+0x8a>
    bp->s.size += p->s.ptr->s.size;
 91a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 91d:	8b 50 04             	mov    0x4(%eax),%edx
 920:	8b 45 fc             	mov    -0x4(%ebp),%eax
 923:	8b 00                	mov    (%eax),%eax
 925:	8b 40 04             	mov    0x4(%eax),%eax
 928:	01 c2                	add    %eax,%edx
 92a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 92d:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 930:	8b 45 fc             	mov    -0x4(%ebp),%eax
 933:	8b 00                	mov    (%eax),%eax
 935:	8b 10                	mov    (%eax),%edx
 937:	8b 45 f8             	mov    -0x8(%ebp),%eax
 93a:	89 10                	mov    %edx,(%eax)
 93c:	eb 0a                	jmp    948 <free+0x94>
  } else
    bp->s.ptr = p->s.ptr;
 93e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 941:	8b 10                	mov    (%eax),%edx
 943:	8b 45 f8             	mov    -0x8(%ebp),%eax
 946:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 948:	8b 45 fc             	mov    -0x4(%ebp),%eax
 94b:	8b 40 04             	mov    0x4(%eax),%eax
 94e:	c1 e0 03             	shl    $0x3,%eax
 951:	03 45 fc             	add    -0x4(%ebp),%eax
 954:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 957:	75 20                	jne    979 <free+0xc5>
    p->s.size += bp->s.size;
 959:	8b 45 fc             	mov    -0x4(%ebp),%eax
 95c:	8b 50 04             	mov    0x4(%eax),%edx
 95f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 962:	8b 40 04             	mov    0x4(%eax),%eax
 965:	01 c2                	add    %eax,%edx
 967:	8b 45 fc             	mov    -0x4(%ebp),%eax
 96a:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 96d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 970:	8b 10                	mov    (%eax),%edx
 972:	8b 45 fc             	mov    -0x4(%ebp),%eax
 975:	89 10                	mov    %edx,(%eax)
 977:	eb 08                	jmp    981 <free+0xcd>
  } else
    p->s.ptr = bp;
 979:	8b 45 fc             	mov    -0x4(%ebp),%eax
 97c:	8b 55 f8             	mov    -0x8(%ebp),%edx
 97f:	89 10                	mov    %edx,(%eax)
  freep = p;
 981:	8b 45 fc             	mov    -0x4(%ebp),%eax
 984:	a3 20 0e 00 00       	mov    %eax,0xe20
}
 989:	c9                   	leave  
 98a:	c3                   	ret    

0000098b <morecore>:

static Header*
morecore(uint nu)
{
 98b:	55                   	push   %ebp
 98c:	89 e5                	mov    %esp,%ebp
 98e:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 991:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 998:	77 07                	ja     9a1 <morecore+0x16>
    nu = 4096;
 99a:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 9a1:	8b 45 08             	mov    0x8(%ebp),%eax
 9a4:	c1 e0 03             	shl    $0x3,%eax
 9a7:	89 04 24             	mov    %eax,(%esp)
 9aa:	e8 39 fc ff ff       	call   5e8 <sbrk>
 9af:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 9b2:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 9b6:	75 07                	jne    9bf <morecore+0x34>
    return 0;
 9b8:	b8 00 00 00 00       	mov    $0x0,%eax
 9bd:	eb 22                	jmp    9e1 <morecore+0x56>
  hp = (Header*)p;
 9bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9c2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 9c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9c8:	8b 55 08             	mov    0x8(%ebp),%edx
 9cb:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 9ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9d1:	83 c0 08             	add    $0x8,%eax
 9d4:	89 04 24             	mov    %eax,(%esp)
 9d7:	e8 d8 fe ff ff       	call   8b4 <free>
  return freep;
 9dc:	a1 20 0e 00 00       	mov    0xe20,%eax
}
 9e1:	c9                   	leave  
 9e2:	c3                   	ret    

000009e3 <malloc>:

void*
malloc(uint nbytes)
{
 9e3:	55                   	push   %ebp
 9e4:	89 e5                	mov    %esp,%ebp
 9e6:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 9e9:	8b 45 08             	mov    0x8(%ebp),%eax
 9ec:	83 c0 07             	add    $0x7,%eax
 9ef:	c1 e8 03             	shr    $0x3,%eax
 9f2:	83 c0 01             	add    $0x1,%eax
 9f5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 9f8:	a1 20 0e 00 00       	mov    0xe20,%eax
 9fd:	89 45 f0             	mov    %eax,-0x10(%ebp)
 a00:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 a04:	75 23                	jne    a29 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 a06:	c7 45 f0 18 0e 00 00 	movl   $0xe18,-0x10(%ebp)
 a0d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a10:	a3 20 0e 00 00       	mov    %eax,0xe20
 a15:	a1 20 0e 00 00       	mov    0xe20,%eax
 a1a:	a3 18 0e 00 00       	mov    %eax,0xe18
    base.s.size = 0;
 a1f:	c7 05 1c 0e 00 00 00 	movl   $0x0,0xe1c
 a26:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a29:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a2c:	8b 00                	mov    (%eax),%eax
 a2e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 a31:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a34:	8b 40 04             	mov    0x4(%eax),%eax
 a37:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 a3a:	72 4d                	jb     a89 <malloc+0xa6>
      if(p->s.size == nunits)
 a3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a3f:	8b 40 04             	mov    0x4(%eax),%eax
 a42:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 a45:	75 0c                	jne    a53 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 a47:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a4a:	8b 10                	mov    (%eax),%edx
 a4c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a4f:	89 10                	mov    %edx,(%eax)
 a51:	eb 26                	jmp    a79 <malloc+0x96>
      else {
        p->s.size -= nunits;
 a53:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a56:	8b 40 04             	mov    0x4(%eax),%eax
 a59:	89 c2                	mov    %eax,%edx
 a5b:	2b 55 ec             	sub    -0x14(%ebp),%edx
 a5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a61:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 a64:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a67:	8b 40 04             	mov    0x4(%eax),%eax
 a6a:	c1 e0 03             	shl    $0x3,%eax
 a6d:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 a70:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a73:	8b 55 ec             	mov    -0x14(%ebp),%edx
 a76:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 a79:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a7c:	a3 20 0e 00 00       	mov    %eax,0xe20
      return (void*)(p + 1);
 a81:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a84:	83 c0 08             	add    $0x8,%eax
 a87:	eb 38                	jmp    ac1 <malloc+0xde>
    }
    if(p == freep)
 a89:	a1 20 0e 00 00       	mov    0xe20,%eax
 a8e:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 a91:	75 1b                	jne    aae <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 a93:	8b 45 ec             	mov    -0x14(%ebp),%eax
 a96:	89 04 24             	mov    %eax,(%esp)
 a99:	e8 ed fe ff ff       	call   98b <morecore>
 a9e:	89 45 f4             	mov    %eax,-0xc(%ebp)
 aa1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 aa5:	75 07                	jne    aae <malloc+0xcb>
        return 0;
 aa7:	b8 00 00 00 00       	mov    $0x0,%eax
 aac:	eb 13                	jmp    ac1 <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 aae:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ab1:	89 45 f0             	mov    %eax,-0x10(%ebp)
 ab4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ab7:	8b 00                	mov    (%eax),%eax
 ab9:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 abc:	e9 70 ff ff ff       	jmp    a31 <malloc+0x4e>
}
 ac1:	c9                   	leave  
 ac2:	c3                   	ret    
