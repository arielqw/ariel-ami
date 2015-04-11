
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
  84:	e8 8f 05 00 00       	call   618 <set_priority>
	memset(presence,0,NUM_OF_CHLIDREN);
  89:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
  90:	00 
  91:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  98:	00 
  99:	8d 44 24 28          	lea    0x28(%esp),%eax
  9d:	89 04 24             	mov    %eax,(%esp)
  a0:	e8 0e 03 00 00       	call   3b3 <memset>

	printf(1, "NUM_OF_CHLIDREN=%d CALC_SIZE=%d\n",NUM_OF_CHLIDREN, CALC_SIZE);
  a5:	c7 44 24 0c b8 0b 00 	movl   $0xbb8,0xc(%esp)
  ac:	00 
  ad:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
  b4:	00 
  b5:	c7 44 24 04 bc 0a 00 	movl   $0xabc,0x4(%esp)
  bc:	00 
  bd:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  c4:	e8 2e 06 00 00       	call   6f7 <printf>


	for (i = 0; i < NUM_OF_CHLIDREN; ++i) {
  c9:	c7 84 24 8c 00 00 00 	movl   $0x0,0x8c(%esp)
  d0:	00 00 00 00 
  d4:	e9 ae 00 00 00       	jmp    187 <main+0x117>
		if ((pid = fork()) > 0){	//parent
  d9:	e8 72 04 00 00       	call   550 <fork>
  de:	89 84 24 88 00 00 00 	mov    %eax,0x88(%esp)
  e5:	83 bc 24 88 00 00 00 	cmpl   $0x0,0x88(%esp)
  ec:	00 
  ed:	7e 29                	jle    118 <main+0xa8>
			printf(1, "(fork:%d)",pid);
  ef:	8b 84 24 88 00 00 00 	mov    0x88(%esp),%eax
  f6:	89 44 24 08          	mov    %eax,0x8(%esp)
  fa:	c7 44 24 04 dd 0a 00 	movl   $0xadd,0x4(%esp)
 101:	00 
 102:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 109:	e8 e9 05 00 00       	call   6f7 <printf>
	memset(presence,0,NUM_OF_CHLIDREN);

	printf(1, "NUM_OF_CHLIDREN=%d CALC_SIZE=%d\n",NUM_OF_CHLIDREN, CALC_SIZE);


	for (i = 0; i < NUM_OF_CHLIDREN; ++i) {
 10e:	83 84 24 8c 00 00 00 	addl   $0x1,0x8c(%esp)
 115:	01 
 116:	eb 6f                	jmp    187 <main+0x117>
		if ((pid = fork()) > 0){	//parent
			printf(1, "(fork:%d)",pid);
		}
		else if (pid == 0){	//child
 118:	83 bc 24 88 00 00 00 	cmpl   $0x0,0x88(%esp)
 11f:	00 
 120:	75 45                	jne    167 <main+0xf7>
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
 149:	e8 ca 04 00 00       	call   618 <set_priority>
			getTheNPrimeNumber(CALC_SIZE);
 14e:	c7 04 24 b8 0b 00 00 	movl   $0xbb8,(%esp)
 155:	e8 a6 fe ff ff       	call   0 <getTheNPrimeNumber>
			exit(getpid());
 15a:	e8 79 04 00 00       	call   5d8 <getpid>
 15f:	89 04 24             	mov    %eax,(%esp)
 162:	e8 f1 03 00 00       	call   558 <exit>
		}
		else{
			printf(1, "\nERROR: Fork failed\n");
 167:	c7 44 24 04 e7 0a 00 	movl   $0xae7,0x4(%esp)
 16e:	00 
 16f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 176:	e8 7c 05 00 00       	call   6f7 <printf>
			exit(EXIT_STATUS_FAILURE);
 17b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 182:	e8 d1 03 00 00       	call   558 <exit>
	memset(presence,0,NUM_OF_CHLIDREN);

	printf(1, "NUM_OF_CHLIDREN=%d CALC_SIZE=%d\n",NUM_OF_CHLIDREN, CALC_SIZE);


	for (i = 0; i < NUM_OF_CHLIDREN; ++i) {
 187:	83 bc 24 8c 00 00 00 	cmpl   $0x13,0x8c(%esp)
 18e:	13 
 18f:	0f 8e 44 ff ff ff    	jle    d9 <main+0x69>
		else{
			printf(1, "\nERROR: Fork failed\n");
			exit(EXIT_STATUS_FAILURE);
		}
	}
	printf(1,"\n");
 195:	c7 44 24 04 fc 0a 00 	movl   $0xafc,0x4(%esp)
 19c:	00 
 19d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 1a4:	e8 4e 05 00 00       	call   6f7 <printf>

	for (i = 0; i < NUM_OF_CHLIDREN; ++i){
 1a9:	c7 84 24 8c 00 00 00 	movl   $0x0,0x8c(%esp)
 1b0:	00 00 00 00 
 1b4:	e9 bf 00 00 00       	jmp    278 <main+0x208>
		//status returned should be pid
		pid = wait_stat(&wtime,&rtime,&iotime,&status);
 1b9:	8d 84 24 84 00 00 00 	lea    0x84(%esp),%eax
 1c0:	89 44 24 0c          	mov    %eax,0xc(%esp)
 1c4:	8d 44 24 78          	lea    0x78(%esp),%eax
 1c8:	89 44 24 08          	mov    %eax,0x8(%esp)
 1cc:	8d 44 24 7c          	lea    0x7c(%esp),%eax
 1d0:	89 44 24 04          	mov    %eax,0x4(%esp)
 1d4:	8d 84 24 80 00 00 00 	lea    0x80(%esp),%eax
 1db:	89 04 24             	mov    %eax,(%esp)
 1de:	e8 1d 04 00 00       	call   600 <wait_stat>
 1e3:	89 84 24 88 00 00 00 	mov    %eax,0x88(%esp)
		if (pid<0){
 1ea:	83 bc 24 88 00 00 00 	cmpl   $0x0,0x88(%esp)
 1f1:	00 
 1f2:	79 20                	jns    214 <main+0x1a4>
			printf(1, "\nERROR: Not enought waits.\n");
 1f4:	c7 44 24 04 fe 0a 00 	movl   $0xafe,0x4(%esp)
 1fb:	00 
 1fc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 203:	e8 ef 04 00 00       	call   6f7 <printf>
			exit(EXIT_STATUS_FAILURE);
 208:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 20f:	e8 44 03 00 00       	call   558 <exit>
		}
		printf(1,"Done(%d): waiting (RUNNABLE): %d | running: %d | turnaround : %d\n",
				status, wtime, rtime, wtime+rtime+iotime);
 214:	8b 94 24 80 00 00 00 	mov    0x80(%esp),%edx
 21b:	8b 44 24 7c          	mov    0x7c(%esp),%eax
 21f:	01 c2                	add    %eax,%edx
		pid = wait_stat(&wtime,&rtime,&iotime,&status);
		if (pid<0){
			printf(1, "\nERROR: Not enought waits.\n");
			exit(EXIT_STATUS_FAILURE);
		}
		printf(1,"Done(%d): waiting (RUNNABLE): %d | running: %d | turnaround : %d\n",
 221:	8b 44 24 78          	mov    0x78(%esp),%eax
 225:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
 228:	8b 4c 24 7c          	mov    0x7c(%esp),%ecx
 22c:	8b 94 24 80 00 00 00 	mov    0x80(%esp),%edx
 233:	8b 84 24 84 00 00 00 	mov    0x84(%esp),%eax
 23a:	89 5c 24 14          	mov    %ebx,0x14(%esp)
 23e:	89 4c 24 10          	mov    %ecx,0x10(%esp)
 242:	89 54 24 0c          	mov    %edx,0xc(%esp)
 246:	89 44 24 08          	mov    %eax,0x8(%esp)
 24a:	c7 44 24 04 1c 0b 00 	movl   $0xb1c,0x4(%esp)
 251:	00 
 252:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 259:	e8 99 04 00 00       	call   6f7 <printf>
				status, wtime, rtime, wtime+rtime+iotime);
		presence[i] = status;
 25e:	8b 94 24 84 00 00 00 	mov    0x84(%esp),%edx
 265:	8b 84 24 8c 00 00 00 	mov    0x8c(%esp),%eax
 26c:	89 54 84 28          	mov    %edx,0x28(%esp,%eax,4)
			exit(EXIT_STATUS_FAILURE);
		}
	}
	printf(1,"\n");

	for (i = 0; i < NUM_OF_CHLIDREN; ++i){
 270:	83 84 24 8c 00 00 00 	addl   $0x1,0x8c(%esp)
 277:	01 
 278:	83 bc 24 8c 00 00 00 	cmpl   $0x13,0x8c(%esp)
 27f:	13 
 280:	0f 8e 33 ff ff ff    	jle    1b9 <main+0x149>
		printf(1,"Done(%d): waiting (RUNNABLE): %d | running: %d | turnaround : %d\n",
				status, wtime, rtime, wtime+rtime+iotime);
		presence[i] = status;
	}

	for (i = 0; i < NUM_OF_CHLIDREN; ++i){
 286:	c7 84 24 8c 00 00 00 	movl   $0x0,0x8c(%esp)
 28d:	00 00 00 00 
 291:	eb 37                	jmp    2ca <main+0x25a>
		if(!presence[i]){
 293:	8b 84 24 8c 00 00 00 	mov    0x8c(%esp),%eax
 29a:	8b 44 84 28          	mov    0x28(%esp,%eax,4),%eax
 29e:	85 c0                	test   %eax,%eax
 2a0:	75 20                	jne    2c2 <main+0x252>
			printf(1, "\nERROR: Not enough waits.\n");
 2a2:	c7 44 24 04 5e 0b 00 	movl   $0xb5e,0x4(%esp)
 2a9:	00 
 2aa:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 2b1:	e8 41 04 00 00       	call   6f7 <printf>
			exit(EXIT_STATUS_FAILURE);
 2b6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 2bd:	e8 96 02 00 00       	call   558 <exit>
		printf(1,"Done(%d): waiting (RUNNABLE): %d | running: %d | turnaround : %d\n",
				status, wtime, rtime, wtime+rtime+iotime);
		presence[i] = status;
	}

	for (i = 0; i < NUM_OF_CHLIDREN; ++i){
 2c2:	83 84 24 8c 00 00 00 	addl   $0x1,0x8c(%esp)
 2c9:	01 
 2ca:	83 bc 24 8c 00 00 00 	cmpl   $0x13,0x8c(%esp)
 2d1:	13 
 2d2:	7e bf                	jle    293 <main+0x223>
		if(!presence[i]){
			printf(1, "\nERROR: Not enough waits.\n");
			exit(EXIT_STATUS_FAILURE);
		}
	}
	printf(1, "Success: Great Success!.\n");
 2d4:	c7 44 24 04 79 0b 00 	movl   $0xb79,0x4(%esp)
 2db:	00 
 2dc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 2e3:	e8 0f 04 00 00       	call   6f7 <printf>
	exit(EXIT_STATUS_SUCCESS);
 2e8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 2ef:	e8 64 02 00 00       	call   558 <exit>

000002f4 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 2f4:	55                   	push   %ebp
 2f5:	89 e5                	mov    %esp,%ebp
 2f7:	57                   	push   %edi
 2f8:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 2f9:	8b 4d 08             	mov    0x8(%ebp),%ecx
 2fc:	8b 55 10             	mov    0x10(%ebp),%edx
 2ff:	8b 45 0c             	mov    0xc(%ebp),%eax
 302:	89 cb                	mov    %ecx,%ebx
 304:	89 df                	mov    %ebx,%edi
 306:	89 d1                	mov    %edx,%ecx
 308:	fc                   	cld    
 309:	f3 aa                	rep stos %al,%es:(%edi)
 30b:	89 ca                	mov    %ecx,%edx
 30d:	89 fb                	mov    %edi,%ebx
 30f:	89 5d 08             	mov    %ebx,0x8(%ebp)
 312:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 315:	5b                   	pop    %ebx
 316:	5f                   	pop    %edi
 317:	5d                   	pop    %ebp
 318:	c3                   	ret    

00000319 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 319:	55                   	push   %ebp
 31a:	89 e5                	mov    %esp,%ebp
 31c:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 31f:	8b 45 08             	mov    0x8(%ebp),%eax
 322:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 325:	90                   	nop
 326:	8b 45 0c             	mov    0xc(%ebp),%eax
 329:	0f b6 10             	movzbl (%eax),%edx
 32c:	8b 45 08             	mov    0x8(%ebp),%eax
 32f:	88 10                	mov    %dl,(%eax)
 331:	8b 45 08             	mov    0x8(%ebp),%eax
 334:	0f b6 00             	movzbl (%eax),%eax
 337:	84 c0                	test   %al,%al
 339:	0f 95 c0             	setne  %al
 33c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 340:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 344:	84 c0                	test   %al,%al
 346:	75 de                	jne    326 <strcpy+0xd>
    ;
  return os;
 348:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 34b:	c9                   	leave  
 34c:	c3                   	ret    

0000034d <strcmp>:

int
strcmp(const char *p, const char *q)
{
 34d:	55                   	push   %ebp
 34e:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 350:	eb 08                	jmp    35a <strcmp+0xd>
    p++, q++;
 352:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 356:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 35a:	8b 45 08             	mov    0x8(%ebp),%eax
 35d:	0f b6 00             	movzbl (%eax),%eax
 360:	84 c0                	test   %al,%al
 362:	74 10                	je     374 <strcmp+0x27>
 364:	8b 45 08             	mov    0x8(%ebp),%eax
 367:	0f b6 10             	movzbl (%eax),%edx
 36a:	8b 45 0c             	mov    0xc(%ebp),%eax
 36d:	0f b6 00             	movzbl (%eax),%eax
 370:	38 c2                	cmp    %al,%dl
 372:	74 de                	je     352 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 374:	8b 45 08             	mov    0x8(%ebp),%eax
 377:	0f b6 00             	movzbl (%eax),%eax
 37a:	0f b6 d0             	movzbl %al,%edx
 37d:	8b 45 0c             	mov    0xc(%ebp),%eax
 380:	0f b6 00             	movzbl (%eax),%eax
 383:	0f b6 c0             	movzbl %al,%eax
 386:	89 d1                	mov    %edx,%ecx
 388:	29 c1                	sub    %eax,%ecx
 38a:	89 c8                	mov    %ecx,%eax
}
 38c:	5d                   	pop    %ebp
 38d:	c3                   	ret    

0000038e <strlen>:

uint
strlen(char *s)
{
 38e:	55                   	push   %ebp
 38f:	89 e5                	mov    %esp,%ebp
 391:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 394:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 39b:	eb 04                	jmp    3a1 <strlen+0x13>
 39d:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 3a1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 3a4:	03 45 08             	add    0x8(%ebp),%eax
 3a7:	0f b6 00             	movzbl (%eax),%eax
 3aa:	84 c0                	test   %al,%al
 3ac:	75 ef                	jne    39d <strlen+0xf>
    ;
  return n;
 3ae:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 3b1:	c9                   	leave  
 3b2:	c3                   	ret    

000003b3 <memset>:

void*
memset(void *dst, int c, uint n)
{
 3b3:	55                   	push   %ebp
 3b4:	89 e5                	mov    %esp,%ebp
 3b6:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 3b9:	8b 45 10             	mov    0x10(%ebp),%eax
 3bc:	89 44 24 08          	mov    %eax,0x8(%esp)
 3c0:	8b 45 0c             	mov    0xc(%ebp),%eax
 3c3:	89 44 24 04          	mov    %eax,0x4(%esp)
 3c7:	8b 45 08             	mov    0x8(%ebp),%eax
 3ca:	89 04 24             	mov    %eax,(%esp)
 3cd:	e8 22 ff ff ff       	call   2f4 <stosb>
  return dst;
 3d2:	8b 45 08             	mov    0x8(%ebp),%eax
}
 3d5:	c9                   	leave  
 3d6:	c3                   	ret    

000003d7 <strchr>:

char*
strchr(const char *s, char c)
{
 3d7:	55                   	push   %ebp
 3d8:	89 e5                	mov    %esp,%ebp
 3da:	83 ec 04             	sub    $0x4,%esp
 3dd:	8b 45 0c             	mov    0xc(%ebp),%eax
 3e0:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 3e3:	eb 14                	jmp    3f9 <strchr+0x22>
    if(*s == c)
 3e5:	8b 45 08             	mov    0x8(%ebp),%eax
 3e8:	0f b6 00             	movzbl (%eax),%eax
 3eb:	3a 45 fc             	cmp    -0x4(%ebp),%al
 3ee:	75 05                	jne    3f5 <strchr+0x1e>
      return (char*)s;
 3f0:	8b 45 08             	mov    0x8(%ebp),%eax
 3f3:	eb 13                	jmp    408 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 3f5:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 3f9:	8b 45 08             	mov    0x8(%ebp),%eax
 3fc:	0f b6 00             	movzbl (%eax),%eax
 3ff:	84 c0                	test   %al,%al
 401:	75 e2                	jne    3e5 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 403:	b8 00 00 00 00       	mov    $0x0,%eax
}
 408:	c9                   	leave  
 409:	c3                   	ret    

0000040a <gets>:

char*
gets(char *buf, int max)
{
 40a:	55                   	push   %ebp
 40b:	89 e5                	mov    %esp,%ebp
 40d:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 410:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 417:	eb 44                	jmp    45d <gets+0x53>
    cc = read(0, &c, 1);
 419:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 420:	00 
 421:	8d 45 ef             	lea    -0x11(%ebp),%eax
 424:	89 44 24 04          	mov    %eax,0x4(%esp)
 428:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 42f:	e8 3c 01 00 00       	call   570 <read>
 434:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 437:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 43b:	7e 2d                	jle    46a <gets+0x60>
      break;
    buf[i++] = c;
 43d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 440:	03 45 08             	add    0x8(%ebp),%eax
 443:	0f b6 55 ef          	movzbl -0x11(%ebp),%edx
 447:	88 10                	mov    %dl,(%eax)
 449:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(c == '\n' || c == '\r')
 44d:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 451:	3c 0a                	cmp    $0xa,%al
 453:	74 16                	je     46b <gets+0x61>
 455:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 459:	3c 0d                	cmp    $0xd,%al
 45b:	74 0e                	je     46b <gets+0x61>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 45d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 460:	83 c0 01             	add    $0x1,%eax
 463:	3b 45 0c             	cmp    0xc(%ebp),%eax
 466:	7c b1                	jl     419 <gets+0xf>
 468:	eb 01                	jmp    46b <gets+0x61>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 46a:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 46b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 46e:	03 45 08             	add    0x8(%ebp),%eax
 471:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 474:	8b 45 08             	mov    0x8(%ebp),%eax
}
 477:	c9                   	leave  
 478:	c3                   	ret    

00000479 <stat>:

int
stat(char *n, struct stat *st)
{
 479:	55                   	push   %ebp
 47a:	89 e5                	mov    %esp,%ebp
 47c:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 47f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 486:	00 
 487:	8b 45 08             	mov    0x8(%ebp),%eax
 48a:	89 04 24             	mov    %eax,(%esp)
 48d:	e8 06 01 00 00       	call   598 <open>
 492:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 495:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 499:	79 07                	jns    4a2 <stat+0x29>
    return -1;
 49b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 4a0:	eb 23                	jmp    4c5 <stat+0x4c>
  r = fstat(fd, st);
 4a2:	8b 45 0c             	mov    0xc(%ebp),%eax
 4a5:	89 44 24 04          	mov    %eax,0x4(%esp)
 4a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4ac:	89 04 24             	mov    %eax,(%esp)
 4af:	e8 fc 00 00 00       	call   5b0 <fstat>
 4b4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 4b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4ba:	89 04 24             	mov    %eax,(%esp)
 4bd:	e8 be 00 00 00       	call   580 <close>
  return r;
 4c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 4c5:	c9                   	leave  
 4c6:	c3                   	ret    

000004c7 <atoi>:

int
atoi(const char *s)
{
 4c7:	55                   	push   %ebp
 4c8:	89 e5                	mov    %esp,%ebp
 4ca:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 4cd:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 4d4:	eb 23                	jmp    4f9 <atoi+0x32>
    n = n*10 + *s++ - '0';
 4d6:	8b 55 fc             	mov    -0x4(%ebp),%edx
 4d9:	89 d0                	mov    %edx,%eax
 4db:	c1 e0 02             	shl    $0x2,%eax
 4de:	01 d0                	add    %edx,%eax
 4e0:	01 c0                	add    %eax,%eax
 4e2:	89 c2                	mov    %eax,%edx
 4e4:	8b 45 08             	mov    0x8(%ebp),%eax
 4e7:	0f b6 00             	movzbl (%eax),%eax
 4ea:	0f be c0             	movsbl %al,%eax
 4ed:	01 d0                	add    %edx,%eax
 4ef:	83 e8 30             	sub    $0x30,%eax
 4f2:	89 45 fc             	mov    %eax,-0x4(%ebp)
 4f5:	83 45 08 01          	addl   $0x1,0x8(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 4f9:	8b 45 08             	mov    0x8(%ebp),%eax
 4fc:	0f b6 00             	movzbl (%eax),%eax
 4ff:	3c 2f                	cmp    $0x2f,%al
 501:	7e 0a                	jle    50d <atoi+0x46>
 503:	8b 45 08             	mov    0x8(%ebp),%eax
 506:	0f b6 00             	movzbl (%eax),%eax
 509:	3c 39                	cmp    $0x39,%al
 50b:	7e c9                	jle    4d6 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 50d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 510:	c9                   	leave  
 511:	c3                   	ret    

00000512 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 512:	55                   	push   %ebp
 513:	89 e5                	mov    %esp,%ebp
 515:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 518:	8b 45 08             	mov    0x8(%ebp),%eax
 51b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 51e:	8b 45 0c             	mov    0xc(%ebp),%eax
 521:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 524:	eb 13                	jmp    539 <memmove+0x27>
    *dst++ = *src++;
 526:	8b 45 f8             	mov    -0x8(%ebp),%eax
 529:	0f b6 10             	movzbl (%eax),%edx
 52c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 52f:	88 10                	mov    %dl,(%eax)
 531:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 535:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 539:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 53d:	0f 9f c0             	setg   %al
 540:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 544:	84 c0                	test   %al,%al
 546:	75 de                	jne    526 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 548:	8b 45 08             	mov    0x8(%ebp),%eax
}
 54b:	c9                   	leave  
 54c:	c3                   	ret    
 54d:	90                   	nop
 54e:	90                   	nop
 54f:	90                   	nop

00000550 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 550:	b8 01 00 00 00       	mov    $0x1,%eax
 555:	cd 40                	int    $0x40
 557:	c3                   	ret    

00000558 <exit>:
SYSCALL(exit)
 558:	b8 02 00 00 00       	mov    $0x2,%eax
 55d:	cd 40                	int    $0x40
 55f:	c3                   	ret    

00000560 <wait>:
SYSCALL(wait)
 560:	b8 03 00 00 00       	mov    $0x3,%eax
 565:	cd 40                	int    $0x40
 567:	c3                   	ret    

00000568 <pipe>:
SYSCALL(pipe)
 568:	b8 04 00 00 00       	mov    $0x4,%eax
 56d:	cd 40                	int    $0x40
 56f:	c3                   	ret    

00000570 <read>:
SYSCALL(read)
 570:	b8 05 00 00 00       	mov    $0x5,%eax
 575:	cd 40                	int    $0x40
 577:	c3                   	ret    

00000578 <write>:
SYSCALL(write)
 578:	b8 10 00 00 00       	mov    $0x10,%eax
 57d:	cd 40                	int    $0x40
 57f:	c3                   	ret    

00000580 <close>:
SYSCALL(close)
 580:	b8 15 00 00 00       	mov    $0x15,%eax
 585:	cd 40                	int    $0x40
 587:	c3                   	ret    

00000588 <kill>:
SYSCALL(kill)
 588:	b8 06 00 00 00       	mov    $0x6,%eax
 58d:	cd 40                	int    $0x40
 58f:	c3                   	ret    

00000590 <exec>:
SYSCALL(exec)
 590:	b8 07 00 00 00       	mov    $0x7,%eax
 595:	cd 40                	int    $0x40
 597:	c3                   	ret    

00000598 <open>:
SYSCALL(open)
 598:	b8 0f 00 00 00       	mov    $0xf,%eax
 59d:	cd 40                	int    $0x40
 59f:	c3                   	ret    

000005a0 <mknod>:
SYSCALL(mknod)
 5a0:	b8 11 00 00 00       	mov    $0x11,%eax
 5a5:	cd 40                	int    $0x40
 5a7:	c3                   	ret    

000005a8 <unlink>:
SYSCALL(unlink)
 5a8:	b8 12 00 00 00       	mov    $0x12,%eax
 5ad:	cd 40                	int    $0x40
 5af:	c3                   	ret    

000005b0 <fstat>:
SYSCALL(fstat)
 5b0:	b8 08 00 00 00       	mov    $0x8,%eax
 5b5:	cd 40                	int    $0x40
 5b7:	c3                   	ret    

000005b8 <link>:
SYSCALL(link)
 5b8:	b8 13 00 00 00       	mov    $0x13,%eax
 5bd:	cd 40                	int    $0x40
 5bf:	c3                   	ret    

000005c0 <mkdir>:
SYSCALL(mkdir)
 5c0:	b8 14 00 00 00       	mov    $0x14,%eax
 5c5:	cd 40                	int    $0x40
 5c7:	c3                   	ret    

000005c8 <chdir>:
SYSCALL(chdir)
 5c8:	b8 09 00 00 00       	mov    $0x9,%eax
 5cd:	cd 40                	int    $0x40
 5cf:	c3                   	ret    

000005d0 <dup>:
SYSCALL(dup)
 5d0:	b8 0a 00 00 00       	mov    $0xa,%eax
 5d5:	cd 40                	int    $0x40
 5d7:	c3                   	ret    

000005d8 <getpid>:
SYSCALL(getpid)
 5d8:	b8 0b 00 00 00       	mov    $0xb,%eax
 5dd:	cd 40                	int    $0x40
 5df:	c3                   	ret    

000005e0 <sbrk>:
SYSCALL(sbrk)
 5e0:	b8 0c 00 00 00       	mov    $0xc,%eax
 5e5:	cd 40                	int    $0x40
 5e7:	c3                   	ret    

000005e8 <sleep>:
SYSCALL(sleep)
 5e8:	b8 0d 00 00 00       	mov    $0xd,%eax
 5ed:	cd 40                	int    $0x40
 5ef:	c3                   	ret    

000005f0 <uptime>:
SYSCALL(uptime)
 5f0:	b8 0e 00 00 00       	mov    $0xe,%eax
 5f5:	cd 40                	int    $0x40
 5f7:	c3                   	ret    

000005f8 <waitpid>:
SYSCALL(waitpid)
 5f8:	b8 16 00 00 00       	mov    $0x16,%eax
 5fd:	cd 40                	int    $0x40
 5ff:	c3                   	ret    

00000600 <wait_stat>:
SYSCALL(wait_stat)
 600:	b8 17 00 00 00       	mov    $0x17,%eax
 605:	cd 40                	int    $0x40
 607:	c3                   	ret    

00000608 <list_pgroup>:
SYSCALL(list_pgroup)
 608:	b8 18 00 00 00       	mov    $0x18,%eax
 60d:	cd 40                	int    $0x40
 60f:	c3                   	ret    

00000610 <foreground>:
SYSCALL(foreground)
 610:	b8 19 00 00 00       	mov    $0x19,%eax
 615:	cd 40                	int    $0x40
 617:	c3                   	ret    

00000618 <set_priority>:
SYSCALL(set_priority)
 618:	b8 1a 00 00 00       	mov    $0x1a,%eax
 61d:	cd 40                	int    $0x40
 61f:	c3                   	ret    

00000620 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 620:	55                   	push   %ebp
 621:	89 e5                	mov    %esp,%ebp
 623:	83 ec 28             	sub    $0x28,%esp
 626:	8b 45 0c             	mov    0xc(%ebp),%eax
 629:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 62c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 633:	00 
 634:	8d 45 f4             	lea    -0xc(%ebp),%eax
 637:	89 44 24 04          	mov    %eax,0x4(%esp)
 63b:	8b 45 08             	mov    0x8(%ebp),%eax
 63e:	89 04 24             	mov    %eax,(%esp)
 641:	e8 32 ff ff ff       	call   578 <write>
}
 646:	c9                   	leave  
 647:	c3                   	ret    

00000648 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 648:	55                   	push   %ebp
 649:	89 e5                	mov    %esp,%ebp
 64b:	83 ec 48             	sub    $0x48,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 64e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 655:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 659:	74 17                	je     672 <printint+0x2a>
 65b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 65f:	79 11                	jns    672 <printint+0x2a>
    neg = 1;
 661:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 668:	8b 45 0c             	mov    0xc(%ebp),%eax
 66b:	f7 d8                	neg    %eax
 66d:	89 45 ec             	mov    %eax,-0x14(%ebp)
 670:	eb 06                	jmp    678 <printint+0x30>
  } else {
    x = xx;
 672:	8b 45 0c             	mov    0xc(%ebp),%eax
 675:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 678:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 67f:	8b 4d 10             	mov    0x10(%ebp),%ecx
 682:	8b 45 ec             	mov    -0x14(%ebp),%eax
 685:	ba 00 00 00 00       	mov    $0x0,%edx
 68a:	f7 f1                	div    %ecx
 68c:	89 d0                	mov    %edx,%eax
 68e:	0f b6 90 fc 0d 00 00 	movzbl 0xdfc(%eax),%edx
 695:	8d 45 dc             	lea    -0x24(%ebp),%eax
 698:	03 45 f4             	add    -0xc(%ebp),%eax
 69b:	88 10                	mov    %dl,(%eax)
 69d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  }while((x /= base) != 0);
 6a1:	8b 55 10             	mov    0x10(%ebp),%edx
 6a4:	89 55 d4             	mov    %edx,-0x2c(%ebp)
 6a7:	8b 45 ec             	mov    -0x14(%ebp),%eax
 6aa:	ba 00 00 00 00       	mov    $0x0,%edx
 6af:	f7 75 d4             	divl   -0x2c(%ebp)
 6b2:	89 45 ec             	mov    %eax,-0x14(%ebp)
 6b5:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 6b9:	75 c4                	jne    67f <printint+0x37>
  if(neg)
 6bb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 6bf:	74 2a                	je     6eb <printint+0xa3>
    buf[i++] = '-';
 6c1:	8d 45 dc             	lea    -0x24(%ebp),%eax
 6c4:	03 45 f4             	add    -0xc(%ebp),%eax
 6c7:	c6 00 2d             	movb   $0x2d,(%eax)
 6ca:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

  while(--i >= 0)
 6ce:	eb 1b                	jmp    6eb <printint+0xa3>
    putc(fd, buf[i]);
 6d0:	8d 45 dc             	lea    -0x24(%ebp),%eax
 6d3:	03 45 f4             	add    -0xc(%ebp),%eax
 6d6:	0f b6 00             	movzbl (%eax),%eax
 6d9:	0f be c0             	movsbl %al,%eax
 6dc:	89 44 24 04          	mov    %eax,0x4(%esp)
 6e0:	8b 45 08             	mov    0x8(%ebp),%eax
 6e3:	89 04 24             	mov    %eax,(%esp)
 6e6:	e8 35 ff ff ff       	call   620 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 6eb:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 6ef:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 6f3:	79 db                	jns    6d0 <printint+0x88>
    putc(fd, buf[i]);
}
 6f5:	c9                   	leave  
 6f6:	c3                   	ret    

000006f7 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 6f7:	55                   	push   %ebp
 6f8:	89 e5                	mov    %esp,%ebp
 6fa:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 6fd:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 704:	8d 45 0c             	lea    0xc(%ebp),%eax
 707:	83 c0 04             	add    $0x4,%eax
 70a:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 70d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 714:	e9 7d 01 00 00       	jmp    896 <printf+0x19f>
    c = fmt[i] & 0xff;
 719:	8b 55 0c             	mov    0xc(%ebp),%edx
 71c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 71f:	01 d0                	add    %edx,%eax
 721:	0f b6 00             	movzbl (%eax),%eax
 724:	0f be c0             	movsbl %al,%eax
 727:	25 ff 00 00 00       	and    $0xff,%eax
 72c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 72f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 733:	75 2c                	jne    761 <printf+0x6a>
      if(c == '%'){
 735:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 739:	75 0c                	jne    747 <printf+0x50>
        state = '%';
 73b:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 742:	e9 4b 01 00 00       	jmp    892 <printf+0x19b>
      } else {
        putc(fd, c);
 747:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 74a:	0f be c0             	movsbl %al,%eax
 74d:	89 44 24 04          	mov    %eax,0x4(%esp)
 751:	8b 45 08             	mov    0x8(%ebp),%eax
 754:	89 04 24             	mov    %eax,(%esp)
 757:	e8 c4 fe ff ff       	call   620 <putc>
 75c:	e9 31 01 00 00       	jmp    892 <printf+0x19b>
      }
    } else if(state == '%'){
 761:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 765:	0f 85 27 01 00 00    	jne    892 <printf+0x19b>
      if(c == 'd'){
 76b:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 76f:	75 2d                	jne    79e <printf+0xa7>
        printint(fd, *ap, 10, 1);
 771:	8b 45 e8             	mov    -0x18(%ebp),%eax
 774:	8b 00                	mov    (%eax),%eax
 776:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 77d:	00 
 77e:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 785:	00 
 786:	89 44 24 04          	mov    %eax,0x4(%esp)
 78a:	8b 45 08             	mov    0x8(%ebp),%eax
 78d:	89 04 24             	mov    %eax,(%esp)
 790:	e8 b3 fe ff ff       	call   648 <printint>
        ap++;
 795:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 799:	e9 ed 00 00 00       	jmp    88b <printf+0x194>
      } else if(c == 'x' || c == 'p'){
 79e:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 7a2:	74 06                	je     7aa <printf+0xb3>
 7a4:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 7a8:	75 2d                	jne    7d7 <printf+0xe0>
        printint(fd, *ap, 16, 0);
 7aa:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7ad:	8b 00                	mov    (%eax),%eax
 7af:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 7b6:	00 
 7b7:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 7be:	00 
 7bf:	89 44 24 04          	mov    %eax,0x4(%esp)
 7c3:	8b 45 08             	mov    0x8(%ebp),%eax
 7c6:	89 04 24             	mov    %eax,(%esp)
 7c9:	e8 7a fe ff ff       	call   648 <printint>
        ap++;
 7ce:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 7d2:	e9 b4 00 00 00       	jmp    88b <printf+0x194>
      } else if(c == 's'){
 7d7:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 7db:	75 46                	jne    823 <printf+0x12c>
        s = (char*)*ap;
 7dd:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7e0:	8b 00                	mov    (%eax),%eax
 7e2:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 7e5:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 7e9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 7ed:	75 27                	jne    816 <printf+0x11f>
          s = "(null)";
 7ef:	c7 45 f4 93 0b 00 00 	movl   $0xb93,-0xc(%ebp)
        while(*s != 0){
 7f6:	eb 1e                	jmp    816 <printf+0x11f>
          putc(fd, *s);
 7f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7fb:	0f b6 00             	movzbl (%eax),%eax
 7fe:	0f be c0             	movsbl %al,%eax
 801:	89 44 24 04          	mov    %eax,0x4(%esp)
 805:	8b 45 08             	mov    0x8(%ebp),%eax
 808:	89 04 24             	mov    %eax,(%esp)
 80b:	e8 10 fe ff ff       	call   620 <putc>
          s++;
 810:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 814:	eb 01                	jmp    817 <printf+0x120>
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 816:	90                   	nop
 817:	8b 45 f4             	mov    -0xc(%ebp),%eax
 81a:	0f b6 00             	movzbl (%eax),%eax
 81d:	84 c0                	test   %al,%al
 81f:	75 d7                	jne    7f8 <printf+0x101>
 821:	eb 68                	jmp    88b <printf+0x194>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 823:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 827:	75 1d                	jne    846 <printf+0x14f>
        putc(fd, *ap);
 829:	8b 45 e8             	mov    -0x18(%ebp),%eax
 82c:	8b 00                	mov    (%eax),%eax
 82e:	0f be c0             	movsbl %al,%eax
 831:	89 44 24 04          	mov    %eax,0x4(%esp)
 835:	8b 45 08             	mov    0x8(%ebp),%eax
 838:	89 04 24             	mov    %eax,(%esp)
 83b:	e8 e0 fd ff ff       	call   620 <putc>
        ap++;
 840:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 844:	eb 45                	jmp    88b <printf+0x194>
      } else if(c == '%'){
 846:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 84a:	75 17                	jne    863 <printf+0x16c>
        putc(fd, c);
 84c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 84f:	0f be c0             	movsbl %al,%eax
 852:	89 44 24 04          	mov    %eax,0x4(%esp)
 856:	8b 45 08             	mov    0x8(%ebp),%eax
 859:	89 04 24             	mov    %eax,(%esp)
 85c:	e8 bf fd ff ff       	call   620 <putc>
 861:	eb 28                	jmp    88b <printf+0x194>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 863:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 86a:	00 
 86b:	8b 45 08             	mov    0x8(%ebp),%eax
 86e:	89 04 24             	mov    %eax,(%esp)
 871:	e8 aa fd ff ff       	call   620 <putc>
        putc(fd, c);
 876:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 879:	0f be c0             	movsbl %al,%eax
 87c:	89 44 24 04          	mov    %eax,0x4(%esp)
 880:	8b 45 08             	mov    0x8(%ebp),%eax
 883:	89 04 24             	mov    %eax,(%esp)
 886:	e8 95 fd ff ff       	call   620 <putc>
      }
      state = 0;
 88b:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 892:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 896:	8b 55 0c             	mov    0xc(%ebp),%edx
 899:	8b 45 f0             	mov    -0x10(%ebp),%eax
 89c:	01 d0                	add    %edx,%eax
 89e:	0f b6 00             	movzbl (%eax),%eax
 8a1:	84 c0                	test   %al,%al
 8a3:	0f 85 70 fe ff ff    	jne    719 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 8a9:	c9                   	leave  
 8aa:	c3                   	ret    
 8ab:	90                   	nop

000008ac <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 8ac:	55                   	push   %ebp
 8ad:	89 e5                	mov    %esp,%ebp
 8af:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 8b2:	8b 45 08             	mov    0x8(%ebp),%eax
 8b5:	83 e8 08             	sub    $0x8,%eax
 8b8:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8bb:	a1 18 0e 00 00       	mov    0xe18,%eax
 8c0:	89 45 fc             	mov    %eax,-0x4(%ebp)
 8c3:	eb 24                	jmp    8e9 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8c5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8c8:	8b 00                	mov    (%eax),%eax
 8ca:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 8cd:	77 12                	ja     8e1 <free+0x35>
 8cf:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8d2:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 8d5:	77 24                	ja     8fb <free+0x4f>
 8d7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8da:	8b 00                	mov    (%eax),%eax
 8dc:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 8df:	77 1a                	ja     8fb <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8e1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8e4:	8b 00                	mov    (%eax),%eax
 8e6:	89 45 fc             	mov    %eax,-0x4(%ebp)
 8e9:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8ec:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 8ef:	76 d4                	jbe    8c5 <free+0x19>
 8f1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8f4:	8b 00                	mov    (%eax),%eax
 8f6:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 8f9:	76 ca                	jbe    8c5 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 8fb:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8fe:	8b 40 04             	mov    0x4(%eax),%eax
 901:	c1 e0 03             	shl    $0x3,%eax
 904:	89 c2                	mov    %eax,%edx
 906:	03 55 f8             	add    -0x8(%ebp),%edx
 909:	8b 45 fc             	mov    -0x4(%ebp),%eax
 90c:	8b 00                	mov    (%eax),%eax
 90e:	39 c2                	cmp    %eax,%edx
 910:	75 24                	jne    936 <free+0x8a>
    bp->s.size += p->s.ptr->s.size;
 912:	8b 45 f8             	mov    -0x8(%ebp),%eax
 915:	8b 50 04             	mov    0x4(%eax),%edx
 918:	8b 45 fc             	mov    -0x4(%ebp),%eax
 91b:	8b 00                	mov    (%eax),%eax
 91d:	8b 40 04             	mov    0x4(%eax),%eax
 920:	01 c2                	add    %eax,%edx
 922:	8b 45 f8             	mov    -0x8(%ebp),%eax
 925:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 928:	8b 45 fc             	mov    -0x4(%ebp),%eax
 92b:	8b 00                	mov    (%eax),%eax
 92d:	8b 10                	mov    (%eax),%edx
 92f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 932:	89 10                	mov    %edx,(%eax)
 934:	eb 0a                	jmp    940 <free+0x94>
  } else
    bp->s.ptr = p->s.ptr;
 936:	8b 45 fc             	mov    -0x4(%ebp),%eax
 939:	8b 10                	mov    (%eax),%edx
 93b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 93e:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 940:	8b 45 fc             	mov    -0x4(%ebp),%eax
 943:	8b 40 04             	mov    0x4(%eax),%eax
 946:	c1 e0 03             	shl    $0x3,%eax
 949:	03 45 fc             	add    -0x4(%ebp),%eax
 94c:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 94f:	75 20                	jne    971 <free+0xc5>
    p->s.size += bp->s.size;
 951:	8b 45 fc             	mov    -0x4(%ebp),%eax
 954:	8b 50 04             	mov    0x4(%eax),%edx
 957:	8b 45 f8             	mov    -0x8(%ebp),%eax
 95a:	8b 40 04             	mov    0x4(%eax),%eax
 95d:	01 c2                	add    %eax,%edx
 95f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 962:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 965:	8b 45 f8             	mov    -0x8(%ebp),%eax
 968:	8b 10                	mov    (%eax),%edx
 96a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 96d:	89 10                	mov    %edx,(%eax)
 96f:	eb 08                	jmp    979 <free+0xcd>
  } else
    p->s.ptr = bp;
 971:	8b 45 fc             	mov    -0x4(%ebp),%eax
 974:	8b 55 f8             	mov    -0x8(%ebp),%edx
 977:	89 10                	mov    %edx,(%eax)
  freep = p;
 979:	8b 45 fc             	mov    -0x4(%ebp),%eax
 97c:	a3 18 0e 00 00       	mov    %eax,0xe18
}
 981:	c9                   	leave  
 982:	c3                   	ret    

00000983 <morecore>:

static Header*
morecore(uint nu)
{
 983:	55                   	push   %ebp
 984:	89 e5                	mov    %esp,%ebp
 986:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 989:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 990:	77 07                	ja     999 <morecore+0x16>
    nu = 4096;
 992:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 999:	8b 45 08             	mov    0x8(%ebp),%eax
 99c:	c1 e0 03             	shl    $0x3,%eax
 99f:	89 04 24             	mov    %eax,(%esp)
 9a2:	e8 39 fc ff ff       	call   5e0 <sbrk>
 9a7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 9aa:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 9ae:	75 07                	jne    9b7 <morecore+0x34>
    return 0;
 9b0:	b8 00 00 00 00       	mov    $0x0,%eax
 9b5:	eb 22                	jmp    9d9 <morecore+0x56>
  hp = (Header*)p;
 9b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9ba:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 9bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9c0:	8b 55 08             	mov    0x8(%ebp),%edx
 9c3:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 9c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9c9:	83 c0 08             	add    $0x8,%eax
 9cc:	89 04 24             	mov    %eax,(%esp)
 9cf:	e8 d8 fe ff ff       	call   8ac <free>
  return freep;
 9d4:	a1 18 0e 00 00       	mov    0xe18,%eax
}
 9d9:	c9                   	leave  
 9da:	c3                   	ret    

000009db <malloc>:

void*
malloc(uint nbytes)
{
 9db:	55                   	push   %ebp
 9dc:	89 e5                	mov    %esp,%ebp
 9de:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 9e1:	8b 45 08             	mov    0x8(%ebp),%eax
 9e4:	83 c0 07             	add    $0x7,%eax
 9e7:	c1 e8 03             	shr    $0x3,%eax
 9ea:	83 c0 01             	add    $0x1,%eax
 9ed:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 9f0:	a1 18 0e 00 00       	mov    0xe18,%eax
 9f5:	89 45 f0             	mov    %eax,-0x10(%ebp)
 9f8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 9fc:	75 23                	jne    a21 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 9fe:	c7 45 f0 10 0e 00 00 	movl   $0xe10,-0x10(%ebp)
 a05:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a08:	a3 18 0e 00 00       	mov    %eax,0xe18
 a0d:	a1 18 0e 00 00       	mov    0xe18,%eax
 a12:	a3 10 0e 00 00       	mov    %eax,0xe10
    base.s.size = 0;
 a17:	c7 05 14 0e 00 00 00 	movl   $0x0,0xe14
 a1e:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a21:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a24:	8b 00                	mov    (%eax),%eax
 a26:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 a29:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a2c:	8b 40 04             	mov    0x4(%eax),%eax
 a2f:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 a32:	72 4d                	jb     a81 <malloc+0xa6>
      if(p->s.size == nunits)
 a34:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a37:	8b 40 04             	mov    0x4(%eax),%eax
 a3a:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 a3d:	75 0c                	jne    a4b <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 a3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a42:	8b 10                	mov    (%eax),%edx
 a44:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a47:	89 10                	mov    %edx,(%eax)
 a49:	eb 26                	jmp    a71 <malloc+0x96>
      else {
        p->s.size -= nunits;
 a4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a4e:	8b 40 04             	mov    0x4(%eax),%eax
 a51:	89 c2                	mov    %eax,%edx
 a53:	2b 55 ec             	sub    -0x14(%ebp),%edx
 a56:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a59:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 a5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a5f:	8b 40 04             	mov    0x4(%eax),%eax
 a62:	c1 e0 03             	shl    $0x3,%eax
 a65:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 a68:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a6b:	8b 55 ec             	mov    -0x14(%ebp),%edx
 a6e:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 a71:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a74:	a3 18 0e 00 00       	mov    %eax,0xe18
      return (void*)(p + 1);
 a79:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a7c:	83 c0 08             	add    $0x8,%eax
 a7f:	eb 38                	jmp    ab9 <malloc+0xde>
    }
    if(p == freep)
 a81:	a1 18 0e 00 00       	mov    0xe18,%eax
 a86:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 a89:	75 1b                	jne    aa6 <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 a8b:	8b 45 ec             	mov    -0x14(%ebp),%eax
 a8e:	89 04 24             	mov    %eax,(%esp)
 a91:	e8 ed fe ff ff       	call   983 <morecore>
 a96:	89 45 f4             	mov    %eax,-0xc(%ebp)
 a99:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 a9d:	75 07                	jne    aa6 <malloc+0xcb>
        return 0;
 a9f:	b8 00 00 00 00       	mov    $0x0,%eax
 aa4:	eb 13                	jmp    ab9 <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 aa6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 aa9:	89 45 f0             	mov    %eax,-0x10(%ebp)
 aac:	8b 45 f4             	mov    -0xc(%ebp),%eax
 aaf:	8b 00                	mov    (%eax),%eax
 ab1:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 ab4:	e9 70 ff ff ff       	jmp    a29 <malloc+0x4e>
}
 ab9:	c9                   	leave  
 aba:	c3                   	ret    
