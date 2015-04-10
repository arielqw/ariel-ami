
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
  73:	53                   	push   %ebx
  74:	83 e4 f0             	and    $0xfffffff0,%esp
  77:	81 ec 90 00 00 00    	sub    $0x90,%esp
	int i, pid, status;
	int wtime, rtime, iotime;
	int presence[NUM_OF_CHLIDREN];

	set_priority(PRIORITY_HIGH);
  7d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  84:	e8 9b 05 00 00       	call   624 <set_priority>
	memset(presence,0,NUM_OF_CHLIDREN);
  89:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
  90:	00 
  91:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  98:	00 
  99:	8d 44 24 28          	lea    0x28(%esp),%eax
  9d:	89 04 24             	mov    %eax,(%esp)
  a0:	e8 1a 03 00 00       	call   3bf <memset>

	printf(1, "NUM_OF_CHLIDREN=%d CALC_SIZE=%d\n",NUM_OF_CHLIDREN, CALC_SIZE);
  a5:	c7 44 24 0c b8 0b 00 	movl   $0xbb8,0xc(%esp)
  ac:	00 
  ad:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
  b4:	00 
  b5:	c7 44 24 04 c8 0a 00 	movl   $0xac8,0x4(%esp)
  bc:	00 
  bd:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  c4:	e8 3a 06 00 00       	call   703 <printf>


	for (i = 0; i < NUM_OF_CHLIDREN; ++i) {
  c9:	c7 84 24 8c 00 00 00 	movl   $0x0,0x8c(%esp)
  d0:	00 00 00 00 
  d4:	e9 ba 00 00 00       	jmp    193 <main+0x123>
		if ((pid = fork()) > 0){	//parent
  d9:	e8 7e 04 00 00       	call   55c <fork>
  de:	89 84 24 88 00 00 00 	mov    %eax,0x88(%esp)
  e5:	83 bc 24 88 00 00 00 	cmpl   $0x0,0x88(%esp)
  ec:	00 
  ed:	7e 29                	jle    118 <main+0xa8>
			printf(1, "(fork:%d)",pid);
  ef:	8b 84 24 88 00 00 00 	mov    0x88(%esp),%eax
  f6:	89 44 24 08          	mov    %eax,0x8(%esp)
  fa:	c7 44 24 04 e9 0a 00 	movl   $0xae9,0x4(%esp)
 101:	00 
 102:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 109:	e8 f5 05 00 00       	call   703 <printf>
	memset(presence,0,NUM_OF_CHLIDREN);

	printf(1, "NUM_OF_CHLIDREN=%d CALC_SIZE=%d\n",NUM_OF_CHLIDREN, CALC_SIZE);


	for (i = 0; i < NUM_OF_CHLIDREN; ++i) {
 10e:	83 84 24 8c 00 00 00 	addl   $0x1,0x8c(%esp)
 115:	01 
 116:	eb 7b                	jmp    193 <main+0x123>
		if ((pid = fork()) > 0){	//parent
			printf(1, "(fork:%d)",pid);
		}
		else if (pid == 0){	//child
 118:	83 bc 24 88 00 00 00 	cmpl   $0x0,0x88(%esp)
 11f:	00 
 120:	75 51                	jne    173 <main+0x103>
			set_priority((i%3)+1);
 122:	8b 8c 24 8c 00 00 00 	mov    0x8c(%esp),%ecx
 129:	ba 56 55 55 55       	mov    $0x55555556,%edx
 12e:	89 c8                	mov    %ecx,%eax
 130:	f7 ea                	imul   %edx
 132:	89 c8                	mov    %ecx,%eax
 134:	c1 f8 1f             	sar    $0x1f,%eax
 137:	29 c2                	sub    %eax,%edx
 139:	89 d0                	mov    %edx,%eax
 13b:	01 c0                	add    %eax,%eax
 13d:	01 d0                	add    %edx,%eax
 13f:	89 ca                	mov    %ecx,%edx
 141:	29 c2                	sub    %eax,%edx
 143:	8d 42 01             	lea    0x1(%edx),%eax
 146:	89 04 24             	mov    %eax,(%esp)
 149:	e8 d6 04 00 00       	call   624 <set_priority>
			sleep(100);
 14e:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
 155:	e8 9a 04 00 00       	call   5f4 <sleep>
			getTheNPrimeNumber(CALC_SIZE);
 15a:	c7 04 24 b8 0b 00 00 	movl   $0xbb8,(%esp)
 161:	e8 9a fe ff ff       	call   0 <getTheNPrimeNumber>
			exit(getpid());
 166:	e8 79 04 00 00       	call   5e4 <getpid>
 16b:	89 04 24             	mov    %eax,(%esp)
 16e:	e8 f1 03 00 00       	call   564 <exit>
		}
		else{
			printf(1, "\nERROR: Fork failed\n");
 173:	c7 44 24 04 f3 0a 00 	movl   $0xaf3,0x4(%esp)
 17a:	00 
 17b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 182:	e8 7c 05 00 00       	call   703 <printf>
			exit(EXIT_STATUS_FAILURE);
 187:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 18e:	e8 d1 03 00 00       	call   564 <exit>
	memset(presence,0,NUM_OF_CHLIDREN);

	printf(1, "NUM_OF_CHLIDREN=%d CALC_SIZE=%d\n",NUM_OF_CHLIDREN, CALC_SIZE);


	for (i = 0; i < NUM_OF_CHLIDREN; ++i) {
 193:	83 bc 24 8c 00 00 00 	cmpl   $0x13,0x8c(%esp)
 19a:	13 
 19b:	0f 8e 38 ff ff ff    	jle    d9 <main+0x69>
		else{
			printf(1, "\nERROR: Fork failed\n");
			exit(EXIT_STATUS_FAILURE);
		}
	}
	printf(1,"\n");
 1a1:	c7 44 24 04 08 0b 00 	movl   $0xb08,0x4(%esp)
 1a8:	00 
 1a9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 1b0:	e8 4e 05 00 00       	call   703 <printf>

	for (i = 0; i < NUM_OF_CHLIDREN; ++i){
 1b5:	c7 84 24 8c 00 00 00 	movl   $0x0,0x8c(%esp)
 1bc:	00 00 00 00 
 1c0:	e9 bf 00 00 00       	jmp    284 <main+0x214>
		//status returned should be pid
		pid = wait_stat(&wtime,&rtime,&iotime,&status);
 1c5:	8d 84 24 84 00 00 00 	lea    0x84(%esp),%eax
 1cc:	89 44 24 0c          	mov    %eax,0xc(%esp)
 1d0:	8d 44 24 78          	lea    0x78(%esp),%eax
 1d4:	89 44 24 08          	mov    %eax,0x8(%esp)
 1d8:	8d 44 24 7c          	lea    0x7c(%esp),%eax
 1dc:	89 44 24 04          	mov    %eax,0x4(%esp)
 1e0:	8d 84 24 80 00 00 00 	lea    0x80(%esp),%eax
 1e7:	89 04 24             	mov    %eax,(%esp)
 1ea:	e8 1d 04 00 00       	call   60c <wait_stat>
 1ef:	89 84 24 88 00 00 00 	mov    %eax,0x88(%esp)
		if (pid<0){
 1f6:	83 bc 24 88 00 00 00 	cmpl   $0x0,0x88(%esp)
 1fd:	00 
 1fe:	79 20                	jns    220 <main+0x1b0>
			printf(1, "\nERROR: Not enought waits.\n");
 200:	c7 44 24 04 0a 0b 00 	movl   $0xb0a,0x4(%esp)
 207:	00 
 208:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 20f:	e8 ef 04 00 00       	call   703 <printf>
			exit(EXIT_STATUS_FAILURE);
 214:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 21b:	e8 44 03 00 00       	call   564 <exit>
		}
		printf(1,"Done(%d): waiting (RUNNABLE): %d | running: %d | turnaround : %d\n",
				status, wtime, rtime, wtime+rtime+iotime);
 220:	8b 94 24 80 00 00 00 	mov    0x80(%esp),%edx
 227:	8b 44 24 7c          	mov    0x7c(%esp),%eax
 22b:	01 c2                	add    %eax,%edx
		pid = wait_stat(&wtime,&rtime,&iotime,&status);
		if (pid<0){
			printf(1, "\nERROR: Not enought waits.\n");
			exit(EXIT_STATUS_FAILURE);
		}
		printf(1,"Done(%d): waiting (RUNNABLE): %d | running: %d | turnaround : %d\n",
 22d:	8b 44 24 78          	mov    0x78(%esp),%eax
 231:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
 234:	8b 4c 24 7c          	mov    0x7c(%esp),%ecx
 238:	8b 94 24 80 00 00 00 	mov    0x80(%esp),%edx
 23f:	8b 84 24 84 00 00 00 	mov    0x84(%esp),%eax
 246:	89 5c 24 14          	mov    %ebx,0x14(%esp)
 24a:	89 4c 24 10          	mov    %ecx,0x10(%esp)
 24e:	89 54 24 0c          	mov    %edx,0xc(%esp)
 252:	89 44 24 08          	mov    %eax,0x8(%esp)
 256:	c7 44 24 04 28 0b 00 	movl   $0xb28,0x4(%esp)
 25d:	00 
 25e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 265:	e8 99 04 00 00       	call   703 <printf>
				status, wtime, rtime, wtime+rtime+iotime);
		presence[i] = status;
 26a:	8b 94 24 84 00 00 00 	mov    0x84(%esp),%edx
 271:	8b 84 24 8c 00 00 00 	mov    0x8c(%esp),%eax
 278:	89 54 84 28          	mov    %edx,0x28(%esp,%eax,4)
			exit(EXIT_STATUS_FAILURE);
		}
	}
	printf(1,"\n");

	for (i = 0; i < NUM_OF_CHLIDREN; ++i){
 27c:	83 84 24 8c 00 00 00 	addl   $0x1,0x8c(%esp)
 283:	01 
 284:	83 bc 24 8c 00 00 00 	cmpl   $0x13,0x8c(%esp)
 28b:	13 
 28c:	0f 8e 33 ff ff ff    	jle    1c5 <main+0x155>
		printf(1,"Done(%d): waiting (RUNNABLE): %d | running: %d | turnaround : %d\n",
				status, wtime, rtime, wtime+rtime+iotime);
		presence[i] = status;
	}

	for (i = 0; i < NUM_OF_CHLIDREN; ++i){
 292:	c7 84 24 8c 00 00 00 	movl   $0x0,0x8c(%esp)
 299:	00 00 00 00 
 29d:	eb 37                	jmp    2d6 <main+0x266>
		if(!presence[i]){
 29f:	8b 84 24 8c 00 00 00 	mov    0x8c(%esp),%eax
 2a6:	8b 44 84 28          	mov    0x28(%esp,%eax,4),%eax
 2aa:	85 c0                	test   %eax,%eax
 2ac:	75 20                	jne    2ce <main+0x25e>
			printf(1, "\nERROR: Not enough waits.\n");
 2ae:	c7 44 24 04 6a 0b 00 	movl   $0xb6a,0x4(%esp)
 2b5:	00 
 2b6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 2bd:	e8 41 04 00 00       	call   703 <printf>
			exit(EXIT_STATUS_FAILURE);
 2c2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 2c9:	e8 96 02 00 00       	call   564 <exit>
		printf(1,"Done(%d): waiting (RUNNABLE): %d | running: %d | turnaround : %d\n",
				status, wtime, rtime, wtime+rtime+iotime);
		presence[i] = status;
	}

	for (i = 0; i < NUM_OF_CHLIDREN; ++i){
 2ce:	83 84 24 8c 00 00 00 	addl   $0x1,0x8c(%esp)
 2d5:	01 
 2d6:	83 bc 24 8c 00 00 00 	cmpl   $0x13,0x8c(%esp)
 2dd:	13 
 2de:	7e bf                	jle    29f <main+0x22f>
		if(!presence[i]){
			printf(1, "\nERROR: Not enough waits.\n");
			exit(EXIT_STATUS_FAILURE);
		}
	}
	printf(1, "Success: Great Success!.\n");
 2e0:	c7 44 24 04 85 0b 00 	movl   $0xb85,0x4(%esp)
 2e7:	00 
 2e8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 2ef:	e8 0f 04 00 00       	call   703 <printf>
	exit(EXIT_STATUS_SUCCESS);
 2f4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 2fb:	e8 64 02 00 00       	call   564 <exit>

00000300 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 300:	55                   	push   %ebp
 301:	89 e5                	mov    %esp,%ebp
 303:	57                   	push   %edi
 304:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 305:	8b 4d 08             	mov    0x8(%ebp),%ecx
 308:	8b 55 10             	mov    0x10(%ebp),%edx
 30b:	8b 45 0c             	mov    0xc(%ebp),%eax
 30e:	89 cb                	mov    %ecx,%ebx
 310:	89 df                	mov    %ebx,%edi
 312:	89 d1                	mov    %edx,%ecx
 314:	fc                   	cld    
 315:	f3 aa                	rep stos %al,%es:(%edi)
 317:	89 ca                	mov    %ecx,%edx
 319:	89 fb                	mov    %edi,%ebx
 31b:	89 5d 08             	mov    %ebx,0x8(%ebp)
 31e:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 321:	5b                   	pop    %ebx
 322:	5f                   	pop    %edi
 323:	5d                   	pop    %ebp
 324:	c3                   	ret    

00000325 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 325:	55                   	push   %ebp
 326:	89 e5                	mov    %esp,%ebp
 328:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 32b:	8b 45 08             	mov    0x8(%ebp),%eax
 32e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 331:	90                   	nop
 332:	8b 45 0c             	mov    0xc(%ebp),%eax
 335:	0f b6 10             	movzbl (%eax),%edx
 338:	8b 45 08             	mov    0x8(%ebp),%eax
 33b:	88 10                	mov    %dl,(%eax)
 33d:	8b 45 08             	mov    0x8(%ebp),%eax
 340:	0f b6 00             	movzbl (%eax),%eax
 343:	84 c0                	test   %al,%al
 345:	0f 95 c0             	setne  %al
 348:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 34c:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 350:	84 c0                	test   %al,%al
 352:	75 de                	jne    332 <strcpy+0xd>
    ;
  return os;
 354:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 357:	c9                   	leave  
 358:	c3                   	ret    

00000359 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 359:	55                   	push   %ebp
 35a:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 35c:	eb 08                	jmp    366 <strcmp+0xd>
    p++, q++;
 35e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 362:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 366:	8b 45 08             	mov    0x8(%ebp),%eax
 369:	0f b6 00             	movzbl (%eax),%eax
 36c:	84 c0                	test   %al,%al
 36e:	74 10                	je     380 <strcmp+0x27>
 370:	8b 45 08             	mov    0x8(%ebp),%eax
 373:	0f b6 10             	movzbl (%eax),%edx
 376:	8b 45 0c             	mov    0xc(%ebp),%eax
 379:	0f b6 00             	movzbl (%eax),%eax
 37c:	38 c2                	cmp    %al,%dl
 37e:	74 de                	je     35e <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 380:	8b 45 08             	mov    0x8(%ebp),%eax
 383:	0f b6 00             	movzbl (%eax),%eax
 386:	0f b6 d0             	movzbl %al,%edx
 389:	8b 45 0c             	mov    0xc(%ebp),%eax
 38c:	0f b6 00             	movzbl (%eax),%eax
 38f:	0f b6 c0             	movzbl %al,%eax
 392:	89 d1                	mov    %edx,%ecx
 394:	29 c1                	sub    %eax,%ecx
 396:	89 c8                	mov    %ecx,%eax
}
 398:	5d                   	pop    %ebp
 399:	c3                   	ret    

0000039a <strlen>:

uint
strlen(char *s)
{
 39a:	55                   	push   %ebp
 39b:	89 e5                	mov    %esp,%ebp
 39d:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 3a0:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 3a7:	eb 04                	jmp    3ad <strlen+0x13>
 3a9:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 3ad:	8b 45 fc             	mov    -0x4(%ebp),%eax
 3b0:	03 45 08             	add    0x8(%ebp),%eax
 3b3:	0f b6 00             	movzbl (%eax),%eax
 3b6:	84 c0                	test   %al,%al
 3b8:	75 ef                	jne    3a9 <strlen+0xf>
    ;
  return n;
 3ba:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 3bd:	c9                   	leave  
 3be:	c3                   	ret    

000003bf <memset>:

void*
memset(void *dst, int c, uint n)
{
 3bf:	55                   	push   %ebp
 3c0:	89 e5                	mov    %esp,%ebp
 3c2:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 3c5:	8b 45 10             	mov    0x10(%ebp),%eax
 3c8:	89 44 24 08          	mov    %eax,0x8(%esp)
 3cc:	8b 45 0c             	mov    0xc(%ebp),%eax
 3cf:	89 44 24 04          	mov    %eax,0x4(%esp)
 3d3:	8b 45 08             	mov    0x8(%ebp),%eax
 3d6:	89 04 24             	mov    %eax,(%esp)
 3d9:	e8 22 ff ff ff       	call   300 <stosb>
  return dst;
 3de:	8b 45 08             	mov    0x8(%ebp),%eax
}
 3e1:	c9                   	leave  
 3e2:	c3                   	ret    

000003e3 <strchr>:

char*
strchr(const char *s, char c)
{
 3e3:	55                   	push   %ebp
 3e4:	89 e5                	mov    %esp,%ebp
 3e6:	83 ec 04             	sub    $0x4,%esp
 3e9:	8b 45 0c             	mov    0xc(%ebp),%eax
 3ec:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 3ef:	eb 14                	jmp    405 <strchr+0x22>
    if(*s == c)
 3f1:	8b 45 08             	mov    0x8(%ebp),%eax
 3f4:	0f b6 00             	movzbl (%eax),%eax
 3f7:	3a 45 fc             	cmp    -0x4(%ebp),%al
 3fa:	75 05                	jne    401 <strchr+0x1e>
      return (char*)s;
 3fc:	8b 45 08             	mov    0x8(%ebp),%eax
 3ff:	eb 13                	jmp    414 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 401:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 405:	8b 45 08             	mov    0x8(%ebp),%eax
 408:	0f b6 00             	movzbl (%eax),%eax
 40b:	84 c0                	test   %al,%al
 40d:	75 e2                	jne    3f1 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 40f:	b8 00 00 00 00       	mov    $0x0,%eax
}
 414:	c9                   	leave  
 415:	c3                   	ret    

00000416 <gets>:

char*
gets(char *buf, int max)
{
 416:	55                   	push   %ebp
 417:	89 e5                	mov    %esp,%ebp
 419:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 41c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 423:	eb 44                	jmp    469 <gets+0x53>
    cc = read(0, &c, 1);
 425:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 42c:	00 
 42d:	8d 45 ef             	lea    -0x11(%ebp),%eax
 430:	89 44 24 04          	mov    %eax,0x4(%esp)
 434:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 43b:	e8 3c 01 00 00       	call   57c <read>
 440:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 443:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 447:	7e 2d                	jle    476 <gets+0x60>
      break;
    buf[i++] = c;
 449:	8b 45 f4             	mov    -0xc(%ebp),%eax
 44c:	03 45 08             	add    0x8(%ebp),%eax
 44f:	0f b6 55 ef          	movzbl -0x11(%ebp),%edx
 453:	88 10                	mov    %dl,(%eax)
 455:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(c == '\n' || c == '\r')
 459:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 45d:	3c 0a                	cmp    $0xa,%al
 45f:	74 16                	je     477 <gets+0x61>
 461:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 465:	3c 0d                	cmp    $0xd,%al
 467:	74 0e                	je     477 <gets+0x61>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 469:	8b 45 f4             	mov    -0xc(%ebp),%eax
 46c:	83 c0 01             	add    $0x1,%eax
 46f:	3b 45 0c             	cmp    0xc(%ebp),%eax
 472:	7c b1                	jl     425 <gets+0xf>
 474:	eb 01                	jmp    477 <gets+0x61>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 476:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 477:	8b 45 f4             	mov    -0xc(%ebp),%eax
 47a:	03 45 08             	add    0x8(%ebp),%eax
 47d:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 480:	8b 45 08             	mov    0x8(%ebp),%eax
}
 483:	c9                   	leave  
 484:	c3                   	ret    

00000485 <stat>:

int
stat(char *n, struct stat *st)
{
 485:	55                   	push   %ebp
 486:	89 e5                	mov    %esp,%ebp
 488:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 48b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 492:	00 
 493:	8b 45 08             	mov    0x8(%ebp),%eax
 496:	89 04 24             	mov    %eax,(%esp)
 499:	e8 06 01 00 00       	call   5a4 <open>
 49e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 4a1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 4a5:	79 07                	jns    4ae <stat+0x29>
    return -1;
 4a7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 4ac:	eb 23                	jmp    4d1 <stat+0x4c>
  r = fstat(fd, st);
 4ae:	8b 45 0c             	mov    0xc(%ebp),%eax
 4b1:	89 44 24 04          	mov    %eax,0x4(%esp)
 4b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4b8:	89 04 24             	mov    %eax,(%esp)
 4bb:	e8 fc 00 00 00       	call   5bc <fstat>
 4c0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 4c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4c6:	89 04 24             	mov    %eax,(%esp)
 4c9:	e8 be 00 00 00       	call   58c <close>
  return r;
 4ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 4d1:	c9                   	leave  
 4d2:	c3                   	ret    

000004d3 <atoi>:

int
atoi(const char *s)
{
 4d3:	55                   	push   %ebp
 4d4:	89 e5                	mov    %esp,%ebp
 4d6:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 4d9:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 4e0:	eb 23                	jmp    505 <atoi+0x32>
    n = n*10 + *s++ - '0';
 4e2:	8b 55 fc             	mov    -0x4(%ebp),%edx
 4e5:	89 d0                	mov    %edx,%eax
 4e7:	c1 e0 02             	shl    $0x2,%eax
 4ea:	01 d0                	add    %edx,%eax
 4ec:	01 c0                	add    %eax,%eax
 4ee:	89 c2                	mov    %eax,%edx
 4f0:	8b 45 08             	mov    0x8(%ebp),%eax
 4f3:	0f b6 00             	movzbl (%eax),%eax
 4f6:	0f be c0             	movsbl %al,%eax
 4f9:	01 d0                	add    %edx,%eax
 4fb:	83 e8 30             	sub    $0x30,%eax
 4fe:	89 45 fc             	mov    %eax,-0x4(%ebp)
 501:	83 45 08 01          	addl   $0x1,0x8(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 505:	8b 45 08             	mov    0x8(%ebp),%eax
 508:	0f b6 00             	movzbl (%eax),%eax
 50b:	3c 2f                	cmp    $0x2f,%al
 50d:	7e 0a                	jle    519 <atoi+0x46>
 50f:	8b 45 08             	mov    0x8(%ebp),%eax
 512:	0f b6 00             	movzbl (%eax),%eax
 515:	3c 39                	cmp    $0x39,%al
 517:	7e c9                	jle    4e2 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 519:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 51c:	c9                   	leave  
 51d:	c3                   	ret    

0000051e <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 51e:	55                   	push   %ebp
 51f:	89 e5                	mov    %esp,%ebp
 521:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 524:	8b 45 08             	mov    0x8(%ebp),%eax
 527:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 52a:	8b 45 0c             	mov    0xc(%ebp),%eax
 52d:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 530:	eb 13                	jmp    545 <memmove+0x27>
    *dst++ = *src++;
 532:	8b 45 f8             	mov    -0x8(%ebp),%eax
 535:	0f b6 10             	movzbl (%eax),%edx
 538:	8b 45 fc             	mov    -0x4(%ebp),%eax
 53b:	88 10                	mov    %dl,(%eax)
 53d:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 541:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 545:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 549:	0f 9f c0             	setg   %al
 54c:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 550:	84 c0                	test   %al,%al
 552:	75 de                	jne    532 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 554:	8b 45 08             	mov    0x8(%ebp),%eax
}
 557:	c9                   	leave  
 558:	c3                   	ret    
 559:	90                   	nop
 55a:	90                   	nop
 55b:	90                   	nop

0000055c <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 55c:	b8 01 00 00 00       	mov    $0x1,%eax
 561:	cd 40                	int    $0x40
 563:	c3                   	ret    

00000564 <exit>:
SYSCALL(exit)
 564:	b8 02 00 00 00       	mov    $0x2,%eax
 569:	cd 40                	int    $0x40
 56b:	c3                   	ret    

0000056c <wait>:
SYSCALL(wait)
 56c:	b8 03 00 00 00       	mov    $0x3,%eax
 571:	cd 40                	int    $0x40
 573:	c3                   	ret    

00000574 <pipe>:
SYSCALL(pipe)
 574:	b8 04 00 00 00       	mov    $0x4,%eax
 579:	cd 40                	int    $0x40
 57b:	c3                   	ret    

0000057c <read>:
SYSCALL(read)
 57c:	b8 05 00 00 00       	mov    $0x5,%eax
 581:	cd 40                	int    $0x40
 583:	c3                   	ret    

00000584 <write>:
SYSCALL(write)
 584:	b8 10 00 00 00       	mov    $0x10,%eax
 589:	cd 40                	int    $0x40
 58b:	c3                   	ret    

0000058c <close>:
SYSCALL(close)
 58c:	b8 15 00 00 00       	mov    $0x15,%eax
 591:	cd 40                	int    $0x40
 593:	c3                   	ret    

00000594 <kill>:
SYSCALL(kill)
 594:	b8 06 00 00 00       	mov    $0x6,%eax
 599:	cd 40                	int    $0x40
 59b:	c3                   	ret    

0000059c <exec>:
SYSCALL(exec)
 59c:	b8 07 00 00 00       	mov    $0x7,%eax
 5a1:	cd 40                	int    $0x40
 5a3:	c3                   	ret    

000005a4 <open>:
SYSCALL(open)
 5a4:	b8 0f 00 00 00       	mov    $0xf,%eax
 5a9:	cd 40                	int    $0x40
 5ab:	c3                   	ret    

000005ac <mknod>:
SYSCALL(mknod)
 5ac:	b8 11 00 00 00       	mov    $0x11,%eax
 5b1:	cd 40                	int    $0x40
 5b3:	c3                   	ret    

000005b4 <unlink>:
SYSCALL(unlink)
 5b4:	b8 12 00 00 00       	mov    $0x12,%eax
 5b9:	cd 40                	int    $0x40
 5bb:	c3                   	ret    

000005bc <fstat>:
SYSCALL(fstat)
 5bc:	b8 08 00 00 00       	mov    $0x8,%eax
 5c1:	cd 40                	int    $0x40
 5c3:	c3                   	ret    

000005c4 <link>:
SYSCALL(link)
 5c4:	b8 13 00 00 00       	mov    $0x13,%eax
 5c9:	cd 40                	int    $0x40
 5cb:	c3                   	ret    

000005cc <mkdir>:
SYSCALL(mkdir)
 5cc:	b8 14 00 00 00       	mov    $0x14,%eax
 5d1:	cd 40                	int    $0x40
 5d3:	c3                   	ret    

000005d4 <chdir>:
SYSCALL(chdir)
 5d4:	b8 09 00 00 00       	mov    $0x9,%eax
 5d9:	cd 40                	int    $0x40
 5db:	c3                   	ret    

000005dc <dup>:
SYSCALL(dup)
 5dc:	b8 0a 00 00 00       	mov    $0xa,%eax
 5e1:	cd 40                	int    $0x40
 5e3:	c3                   	ret    

000005e4 <getpid>:
SYSCALL(getpid)
 5e4:	b8 0b 00 00 00       	mov    $0xb,%eax
 5e9:	cd 40                	int    $0x40
 5eb:	c3                   	ret    

000005ec <sbrk>:
SYSCALL(sbrk)
 5ec:	b8 0c 00 00 00       	mov    $0xc,%eax
 5f1:	cd 40                	int    $0x40
 5f3:	c3                   	ret    

000005f4 <sleep>:
SYSCALL(sleep)
 5f4:	b8 0d 00 00 00       	mov    $0xd,%eax
 5f9:	cd 40                	int    $0x40
 5fb:	c3                   	ret    

000005fc <uptime>:
SYSCALL(uptime)
 5fc:	b8 0e 00 00 00       	mov    $0xe,%eax
 601:	cd 40                	int    $0x40
 603:	c3                   	ret    

00000604 <waitpid>:
SYSCALL(waitpid)
 604:	b8 16 00 00 00       	mov    $0x16,%eax
 609:	cd 40                	int    $0x40
 60b:	c3                   	ret    

0000060c <wait_stat>:
SYSCALL(wait_stat)
 60c:	b8 17 00 00 00       	mov    $0x17,%eax
 611:	cd 40                	int    $0x40
 613:	c3                   	ret    

00000614 <list_pgroup>:
SYSCALL(list_pgroup)
 614:	b8 18 00 00 00       	mov    $0x18,%eax
 619:	cd 40                	int    $0x40
 61b:	c3                   	ret    

0000061c <foreground>:
SYSCALL(foreground)
 61c:	b8 19 00 00 00       	mov    $0x19,%eax
 621:	cd 40                	int    $0x40
 623:	c3                   	ret    

00000624 <set_priority>:
SYSCALL(set_priority)
 624:	b8 1a 00 00 00       	mov    $0x1a,%eax
 629:	cd 40                	int    $0x40
 62b:	c3                   	ret    

0000062c <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 62c:	55                   	push   %ebp
 62d:	89 e5                	mov    %esp,%ebp
 62f:	83 ec 28             	sub    $0x28,%esp
 632:	8b 45 0c             	mov    0xc(%ebp),%eax
 635:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 638:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 63f:	00 
 640:	8d 45 f4             	lea    -0xc(%ebp),%eax
 643:	89 44 24 04          	mov    %eax,0x4(%esp)
 647:	8b 45 08             	mov    0x8(%ebp),%eax
 64a:	89 04 24             	mov    %eax,(%esp)
 64d:	e8 32 ff ff ff       	call   584 <write>
}
 652:	c9                   	leave  
 653:	c3                   	ret    

00000654 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 654:	55                   	push   %ebp
 655:	89 e5                	mov    %esp,%ebp
 657:	83 ec 48             	sub    $0x48,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 65a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 661:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 665:	74 17                	je     67e <printint+0x2a>
 667:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 66b:	79 11                	jns    67e <printint+0x2a>
    neg = 1;
 66d:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 674:	8b 45 0c             	mov    0xc(%ebp),%eax
 677:	f7 d8                	neg    %eax
 679:	89 45 ec             	mov    %eax,-0x14(%ebp)
 67c:	eb 06                	jmp    684 <printint+0x30>
  } else {
    x = xx;
 67e:	8b 45 0c             	mov    0xc(%ebp),%eax
 681:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 684:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 68b:	8b 4d 10             	mov    0x10(%ebp),%ecx
 68e:	8b 45 ec             	mov    -0x14(%ebp),%eax
 691:	ba 00 00 00 00       	mov    $0x0,%edx
 696:	f7 f1                	div    %ecx
 698:	89 d0                	mov    %edx,%eax
 69a:	0f b6 90 08 0e 00 00 	movzbl 0xe08(%eax),%edx
 6a1:	8d 45 dc             	lea    -0x24(%ebp),%eax
 6a4:	03 45 f4             	add    -0xc(%ebp),%eax
 6a7:	88 10                	mov    %dl,(%eax)
 6a9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  }while((x /= base) != 0);
 6ad:	8b 55 10             	mov    0x10(%ebp),%edx
 6b0:	89 55 d4             	mov    %edx,-0x2c(%ebp)
 6b3:	8b 45 ec             	mov    -0x14(%ebp),%eax
 6b6:	ba 00 00 00 00       	mov    $0x0,%edx
 6bb:	f7 75 d4             	divl   -0x2c(%ebp)
 6be:	89 45 ec             	mov    %eax,-0x14(%ebp)
 6c1:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 6c5:	75 c4                	jne    68b <printint+0x37>
  if(neg)
 6c7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 6cb:	74 2a                	je     6f7 <printint+0xa3>
    buf[i++] = '-';
 6cd:	8d 45 dc             	lea    -0x24(%ebp),%eax
 6d0:	03 45 f4             	add    -0xc(%ebp),%eax
 6d3:	c6 00 2d             	movb   $0x2d,(%eax)
 6d6:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

  while(--i >= 0)
 6da:	eb 1b                	jmp    6f7 <printint+0xa3>
    putc(fd, buf[i]);
 6dc:	8d 45 dc             	lea    -0x24(%ebp),%eax
 6df:	03 45 f4             	add    -0xc(%ebp),%eax
 6e2:	0f b6 00             	movzbl (%eax),%eax
 6e5:	0f be c0             	movsbl %al,%eax
 6e8:	89 44 24 04          	mov    %eax,0x4(%esp)
 6ec:	8b 45 08             	mov    0x8(%ebp),%eax
 6ef:	89 04 24             	mov    %eax,(%esp)
 6f2:	e8 35 ff ff ff       	call   62c <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 6f7:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 6fb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 6ff:	79 db                	jns    6dc <printint+0x88>
    putc(fd, buf[i]);
}
 701:	c9                   	leave  
 702:	c3                   	ret    

00000703 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 703:	55                   	push   %ebp
 704:	89 e5                	mov    %esp,%ebp
 706:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 709:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 710:	8d 45 0c             	lea    0xc(%ebp),%eax
 713:	83 c0 04             	add    $0x4,%eax
 716:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 719:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 720:	e9 7d 01 00 00       	jmp    8a2 <printf+0x19f>
    c = fmt[i] & 0xff;
 725:	8b 55 0c             	mov    0xc(%ebp),%edx
 728:	8b 45 f0             	mov    -0x10(%ebp),%eax
 72b:	01 d0                	add    %edx,%eax
 72d:	0f b6 00             	movzbl (%eax),%eax
 730:	0f be c0             	movsbl %al,%eax
 733:	25 ff 00 00 00       	and    $0xff,%eax
 738:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 73b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 73f:	75 2c                	jne    76d <printf+0x6a>
      if(c == '%'){
 741:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 745:	75 0c                	jne    753 <printf+0x50>
        state = '%';
 747:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 74e:	e9 4b 01 00 00       	jmp    89e <printf+0x19b>
      } else {
        putc(fd, c);
 753:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 756:	0f be c0             	movsbl %al,%eax
 759:	89 44 24 04          	mov    %eax,0x4(%esp)
 75d:	8b 45 08             	mov    0x8(%ebp),%eax
 760:	89 04 24             	mov    %eax,(%esp)
 763:	e8 c4 fe ff ff       	call   62c <putc>
 768:	e9 31 01 00 00       	jmp    89e <printf+0x19b>
      }
    } else if(state == '%'){
 76d:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 771:	0f 85 27 01 00 00    	jne    89e <printf+0x19b>
      if(c == 'd'){
 777:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 77b:	75 2d                	jne    7aa <printf+0xa7>
        printint(fd, *ap, 10, 1);
 77d:	8b 45 e8             	mov    -0x18(%ebp),%eax
 780:	8b 00                	mov    (%eax),%eax
 782:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 789:	00 
 78a:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 791:	00 
 792:	89 44 24 04          	mov    %eax,0x4(%esp)
 796:	8b 45 08             	mov    0x8(%ebp),%eax
 799:	89 04 24             	mov    %eax,(%esp)
 79c:	e8 b3 fe ff ff       	call   654 <printint>
        ap++;
 7a1:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 7a5:	e9 ed 00 00 00       	jmp    897 <printf+0x194>
      } else if(c == 'x' || c == 'p'){
 7aa:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 7ae:	74 06                	je     7b6 <printf+0xb3>
 7b0:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 7b4:	75 2d                	jne    7e3 <printf+0xe0>
        printint(fd, *ap, 16, 0);
 7b6:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7b9:	8b 00                	mov    (%eax),%eax
 7bb:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 7c2:	00 
 7c3:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 7ca:	00 
 7cb:	89 44 24 04          	mov    %eax,0x4(%esp)
 7cf:	8b 45 08             	mov    0x8(%ebp),%eax
 7d2:	89 04 24             	mov    %eax,(%esp)
 7d5:	e8 7a fe ff ff       	call   654 <printint>
        ap++;
 7da:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 7de:	e9 b4 00 00 00       	jmp    897 <printf+0x194>
      } else if(c == 's'){
 7e3:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 7e7:	75 46                	jne    82f <printf+0x12c>
        s = (char*)*ap;
 7e9:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7ec:	8b 00                	mov    (%eax),%eax
 7ee:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 7f1:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 7f5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 7f9:	75 27                	jne    822 <printf+0x11f>
          s = "(null)";
 7fb:	c7 45 f4 9f 0b 00 00 	movl   $0xb9f,-0xc(%ebp)
        while(*s != 0){
 802:	eb 1e                	jmp    822 <printf+0x11f>
          putc(fd, *s);
 804:	8b 45 f4             	mov    -0xc(%ebp),%eax
 807:	0f b6 00             	movzbl (%eax),%eax
 80a:	0f be c0             	movsbl %al,%eax
 80d:	89 44 24 04          	mov    %eax,0x4(%esp)
 811:	8b 45 08             	mov    0x8(%ebp),%eax
 814:	89 04 24             	mov    %eax,(%esp)
 817:	e8 10 fe ff ff       	call   62c <putc>
          s++;
 81c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 820:	eb 01                	jmp    823 <printf+0x120>
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 822:	90                   	nop
 823:	8b 45 f4             	mov    -0xc(%ebp),%eax
 826:	0f b6 00             	movzbl (%eax),%eax
 829:	84 c0                	test   %al,%al
 82b:	75 d7                	jne    804 <printf+0x101>
 82d:	eb 68                	jmp    897 <printf+0x194>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 82f:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 833:	75 1d                	jne    852 <printf+0x14f>
        putc(fd, *ap);
 835:	8b 45 e8             	mov    -0x18(%ebp),%eax
 838:	8b 00                	mov    (%eax),%eax
 83a:	0f be c0             	movsbl %al,%eax
 83d:	89 44 24 04          	mov    %eax,0x4(%esp)
 841:	8b 45 08             	mov    0x8(%ebp),%eax
 844:	89 04 24             	mov    %eax,(%esp)
 847:	e8 e0 fd ff ff       	call   62c <putc>
        ap++;
 84c:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 850:	eb 45                	jmp    897 <printf+0x194>
      } else if(c == '%'){
 852:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 856:	75 17                	jne    86f <printf+0x16c>
        putc(fd, c);
 858:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 85b:	0f be c0             	movsbl %al,%eax
 85e:	89 44 24 04          	mov    %eax,0x4(%esp)
 862:	8b 45 08             	mov    0x8(%ebp),%eax
 865:	89 04 24             	mov    %eax,(%esp)
 868:	e8 bf fd ff ff       	call   62c <putc>
 86d:	eb 28                	jmp    897 <printf+0x194>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 86f:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 876:	00 
 877:	8b 45 08             	mov    0x8(%ebp),%eax
 87a:	89 04 24             	mov    %eax,(%esp)
 87d:	e8 aa fd ff ff       	call   62c <putc>
        putc(fd, c);
 882:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 885:	0f be c0             	movsbl %al,%eax
 888:	89 44 24 04          	mov    %eax,0x4(%esp)
 88c:	8b 45 08             	mov    0x8(%ebp),%eax
 88f:	89 04 24             	mov    %eax,(%esp)
 892:	e8 95 fd ff ff       	call   62c <putc>
      }
      state = 0;
 897:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 89e:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 8a2:	8b 55 0c             	mov    0xc(%ebp),%edx
 8a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8a8:	01 d0                	add    %edx,%eax
 8aa:	0f b6 00             	movzbl (%eax),%eax
 8ad:	84 c0                	test   %al,%al
 8af:	0f 85 70 fe ff ff    	jne    725 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 8b5:	c9                   	leave  
 8b6:	c3                   	ret    
 8b7:	90                   	nop

000008b8 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 8b8:	55                   	push   %ebp
 8b9:	89 e5                	mov    %esp,%ebp
 8bb:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 8be:	8b 45 08             	mov    0x8(%ebp),%eax
 8c1:	83 e8 08             	sub    $0x8,%eax
 8c4:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8c7:	a1 24 0e 00 00       	mov    0xe24,%eax
 8cc:	89 45 fc             	mov    %eax,-0x4(%ebp)
 8cf:	eb 24                	jmp    8f5 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8d1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8d4:	8b 00                	mov    (%eax),%eax
 8d6:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 8d9:	77 12                	ja     8ed <free+0x35>
 8db:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8de:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 8e1:	77 24                	ja     907 <free+0x4f>
 8e3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8e6:	8b 00                	mov    (%eax),%eax
 8e8:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 8eb:	77 1a                	ja     907 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8ed:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8f0:	8b 00                	mov    (%eax),%eax
 8f2:	89 45 fc             	mov    %eax,-0x4(%ebp)
 8f5:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8f8:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 8fb:	76 d4                	jbe    8d1 <free+0x19>
 8fd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 900:	8b 00                	mov    (%eax),%eax
 902:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 905:	76 ca                	jbe    8d1 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 907:	8b 45 f8             	mov    -0x8(%ebp),%eax
 90a:	8b 40 04             	mov    0x4(%eax),%eax
 90d:	c1 e0 03             	shl    $0x3,%eax
 910:	89 c2                	mov    %eax,%edx
 912:	03 55 f8             	add    -0x8(%ebp),%edx
 915:	8b 45 fc             	mov    -0x4(%ebp),%eax
 918:	8b 00                	mov    (%eax),%eax
 91a:	39 c2                	cmp    %eax,%edx
 91c:	75 24                	jne    942 <free+0x8a>
    bp->s.size += p->s.ptr->s.size;
 91e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 921:	8b 50 04             	mov    0x4(%eax),%edx
 924:	8b 45 fc             	mov    -0x4(%ebp),%eax
 927:	8b 00                	mov    (%eax),%eax
 929:	8b 40 04             	mov    0x4(%eax),%eax
 92c:	01 c2                	add    %eax,%edx
 92e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 931:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 934:	8b 45 fc             	mov    -0x4(%ebp),%eax
 937:	8b 00                	mov    (%eax),%eax
 939:	8b 10                	mov    (%eax),%edx
 93b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 93e:	89 10                	mov    %edx,(%eax)
 940:	eb 0a                	jmp    94c <free+0x94>
  } else
    bp->s.ptr = p->s.ptr;
 942:	8b 45 fc             	mov    -0x4(%ebp),%eax
 945:	8b 10                	mov    (%eax),%edx
 947:	8b 45 f8             	mov    -0x8(%ebp),%eax
 94a:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 94c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 94f:	8b 40 04             	mov    0x4(%eax),%eax
 952:	c1 e0 03             	shl    $0x3,%eax
 955:	03 45 fc             	add    -0x4(%ebp),%eax
 958:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 95b:	75 20                	jne    97d <free+0xc5>
    p->s.size += bp->s.size;
 95d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 960:	8b 50 04             	mov    0x4(%eax),%edx
 963:	8b 45 f8             	mov    -0x8(%ebp),%eax
 966:	8b 40 04             	mov    0x4(%eax),%eax
 969:	01 c2                	add    %eax,%edx
 96b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 96e:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 971:	8b 45 f8             	mov    -0x8(%ebp),%eax
 974:	8b 10                	mov    (%eax),%edx
 976:	8b 45 fc             	mov    -0x4(%ebp),%eax
 979:	89 10                	mov    %edx,(%eax)
 97b:	eb 08                	jmp    985 <free+0xcd>
  } else
    p->s.ptr = bp;
 97d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 980:	8b 55 f8             	mov    -0x8(%ebp),%edx
 983:	89 10                	mov    %edx,(%eax)
  freep = p;
 985:	8b 45 fc             	mov    -0x4(%ebp),%eax
 988:	a3 24 0e 00 00       	mov    %eax,0xe24
}
 98d:	c9                   	leave  
 98e:	c3                   	ret    

0000098f <morecore>:

static Header*
morecore(uint nu)
{
 98f:	55                   	push   %ebp
 990:	89 e5                	mov    %esp,%ebp
 992:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 995:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 99c:	77 07                	ja     9a5 <morecore+0x16>
    nu = 4096;
 99e:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 9a5:	8b 45 08             	mov    0x8(%ebp),%eax
 9a8:	c1 e0 03             	shl    $0x3,%eax
 9ab:	89 04 24             	mov    %eax,(%esp)
 9ae:	e8 39 fc ff ff       	call   5ec <sbrk>
 9b3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 9b6:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 9ba:	75 07                	jne    9c3 <morecore+0x34>
    return 0;
 9bc:	b8 00 00 00 00       	mov    $0x0,%eax
 9c1:	eb 22                	jmp    9e5 <morecore+0x56>
  hp = (Header*)p;
 9c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9c6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 9c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9cc:	8b 55 08             	mov    0x8(%ebp),%edx
 9cf:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 9d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9d5:	83 c0 08             	add    $0x8,%eax
 9d8:	89 04 24             	mov    %eax,(%esp)
 9db:	e8 d8 fe ff ff       	call   8b8 <free>
  return freep;
 9e0:	a1 24 0e 00 00       	mov    0xe24,%eax
}
 9e5:	c9                   	leave  
 9e6:	c3                   	ret    

000009e7 <malloc>:

void*
malloc(uint nbytes)
{
 9e7:	55                   	push   %ebp
 9e8:	89 e5                	mov    %esp,%ebp
 9ea:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 9ed:	8b 45 08             	mov    0x8(%ebp),%eax
 9f0:	83 c0 07             	add    $0x7,%eax
 9f3:	c1 e8 03             	shr    $0x3,%eax
 9f6:	83 c0 01             	add    $0x1,%eax
 9f9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 9fc:	a1 24 0e 00 00       	mov    0xe24,%eax
 a01:	89 45 f0             	mov    %eax,-0x10(%ebp)
 a04:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 a08:	75 23                	jne    a2d <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 a0a:	c7 45 f0 1c 0e 00 00 	movl   $0xe1c,-0x10(%ebp)
 a11:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a14:	a3 24 0e 00 00       	mov    %eax,0xe24
 a19:	a1 24 0e 00 00       	mov    0xe24,%eax
 a1e:	a3 1c 0e 00 00       	mov    %eax,0xe1c
    base.s.size = 0;
 a23:	c7 05 20 0e 00 00 00 	movl   $0x0,0xe20
 a2a:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a2d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a30:	8b 00                	mov    (%eax),%eax
 a32:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 a35:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a38:	8b 40 04             	mov    0x4(%eax),%eax
 a3b:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 a3e:	72 4d                	jb     a8d <malloc+0xa6>
      if(p->s.size == nunits)
 a40:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a43:	8b 40 04             	mov    0x4(%eax),%eax
 a46:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 a49:	75 0c                	jne    a57 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 a4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a4e:	8b 10                	mov    (%eax),%edx
 a50:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a53:	89 10                	mov    %edx,(%eax)
 a55:	eb 26                	jmp    a7d <malloc+0x96>
      else {
        p->s.size -= nunits;
 a57:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a5a:	8b 40 04             	mov    0x4(%eax),%eax
 a5d:	89 c2                	mov    %eax,%edx
 a5f:	2b 55 ec             	sub    -0x14(%ebp),%edx
 a62:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a65:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 a68:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a6b:	8b 40 04             	mov    0x4(%eax),%eax
 a6e:	c1 e0 03             	shl    $0x3,%eax
 a71:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 a74:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a77:	8b 55 ec             	mov    -0x14(%ebp),%edx
 a7a:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 a7d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a80:	a3 24 0e 00 00       	mov    %eax,0xe24
      return (void*)(p + 1);
 a85:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a88:	83 c0 08             	add    $0x8,%eax
 a8b:	eb 38                	jmp    ac5 <malloc+0xde>
    }
    if(p == freep)
 a8d:	a1 24 0e 00 00       	mov    0xe24,%eax
 a92:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 a95:	75 1b                	jne    ab2 <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 a97:	8b 45 ec             	mov    -0x14(%ebp),%eax
 a9a:	89 04 24             	mov    %eax,(%esp)
 a9d:	e8 ed fe ff ff       	call   98f <morecore>
 aa2:	89 45 f4             	mov    %eax,-0xc(%ebp)
 aa5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 aa9:	75 07                	jne    ab2 <malloc+0xcb>
        return 0;
 aab:	b8 00 00 00 00       	mov    $0x0,%eax
 ab0:	eb 13                	jmp    ac5 <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 ab2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ab5:	89 45 f0             	mov    %eax,-0x10(%ebp)
 ab8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 abb:	8b 00                	mov    (%eax),%eax
 abd:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 ac0:	e9 70 ff ff ff       	jmp    a35 <malloc+0x4e>
}
 ac5:	c9                   	leave  
 ac6:	c3                   	ret    
