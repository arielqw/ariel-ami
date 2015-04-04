
_balbazar:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:


/*
 * testing working wait(status)
 */
int main(int argc, char *argv[]){
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 e4 f0             	and    $0xfffffff0,%esp
   6:	83 ec 10             	sub    $0x10,%esp

	test_wait();
   9:	e8 7b 01 00 00       	call   189 <test_wait>
	test_waitpid(BLOCKING);
   e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  15:	e8 18 00 00 00       	call   32 <test_waitpid>
	test_waitpid(NONBLOCKING);
  1a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  21:	e8 0c 00 00 00       	call   32 <test_waitpid>

	exit(1);
  26:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  2d:	e8 4e 04 00 00       	call   480 <exit>

00000032 <test_waitpid>:
	return 0;
}

/* testing working wait(status)*/
int test_waitpid(int option){
  32:	55                   	push   %ebp
  33:	89 e5                	mov    %esp,%ebp
  35:	83 ec 28             	sub    $0x28,%esp
	printf(1, "*** Testing waitpid *** \n");
  38:	c7 44 24 04 d4 09 00 	movl   $0x9d4,0x4(%esp)
  3f:	00 
  40:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  47:	e8 c3 05 00 00       	call   60f <printf>

	printf(1, "check invalid son: %d \n", waitpid(666,0,0));
  4c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  53:	00 
  54:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  5b:	00 
  5c:	c7 04 24 9a 02 00 00 	movl   $0x29a,(%esp)
  63:	e8 b8 04 00 00       	call   520 <waitpid>
  68:	89 44 24 08          	mov    %eax,0x8(%esp)
  6c:	c7 44 24 04 ee 09 00 	movl   $0x9ee,0x4(%esp)
  73:	00 
  74:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  7b:	e8 8f 05 00 00       	call   60f <printf>
	int stat;
	int childStatus = 9;
  80:	c7 45 f4 09 00 00 00 	movl   $0x9,-0xc(%ebp)
	int pid;

	if( !( pid = fork() )  ){
  87:	e8 ec 03 00 00       	call   478 <fork>
  8c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  93:	75 32                	jne    c7 <test_waitpid+0x95>
		sleep(1000);
  95:	c7 04 24 e8 03 00 00 	movl   $0x3e8,(%esp)
  9c:	e8 6f 04 00 00       	call   510 <sleep>
	  printf(1, "Exiting with status: %d \n", childStatus);
  a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  a4:	89 44 24 08          	mov    %eax,0x8(%esp)
  a8:	c7 44 24 04 06 0a 00 	movl   $0xa06,0x4(%esp)
  af:	00 
  b0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  b7:	e8 53 05 00 00       	call   60f <printf>
	  exit(childStatus);
  bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  bf:	89 04 24             	mov    %eax,(%esp)
  c2:	e8 b9 03 00 00       	call   480 <exit>
	}
	//parent
	switch (option) {
  c7:	8b 45 08             	mov    0x8(%ebp),%eax
  ca:	85 c0                	test   %eax,%eax
  cc:	74 0a                	je     d8 <test_waitpid+0xa6>
  ce:	83 f8 01             	cmp    $0x1,%eax
  d1:	74 4c                	je     11f <test_waitpid+0xed>
  d3:	e9 8e 00 00 00       	jmp    166 <test_waitpid+0x134>
		case BLOCKING:
			printf(1, "testing BLOCKING \n");
  d8:	c7 44 24 04 20 0a 00 	movl   $0xa20,0x4(%esp)
  df:	00 
  e0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  e7:	e8 23 05 00 00       	call   60f <printf>
			printf(1, "waitpid returns: %d \n", waitpid(pid,&stat,option));
  ec:	8b 45 08             	mov    0x8(%ebp),%eax
  ef:	89 44 24 08          	mov    %eax,0x8(%esp)
  f3:	8d 45 ec             	lea    -0x14(%ebp),%eax
  f6:	89 44 24 04          	mov    %eax,0x4(%esp)
  fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  fd:	89 04 24             	mov    %eax,(%esp)
 100:	e8 1b 04 00 00       	call   520 <waitpid>
 105:	89 44 24 08          	mov    %eax,0x8(%esp)
 109:	c7 44 24 04 33 0a 00 	movl   $0xa33,0x4(%esp)
 110:	00 
 111:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 118:	e8 f2 04 00 00       	call   60f <printf>
			break;
 11d:	eb 48                	jmp    167 <test_waitpid+0x135>
		case NONBLOCKING:
			printf(1, "testing NONBLOCKING \n");
 11f:	c7 44 24 04 49 0a 00 	movl   $0xa49,0x4(%esp)
 126:	00 
 127:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 12e:	e8 dc 04 00 00       	call   60f <printf>
			printf(1, "waitpid returns: %d \n", waitpid(pid,&stat,option));
 133:	8b 45 08             	mov    0x8(%ebp),%eax
 136:	89 44 24 08          	mov    %eax,0x8(%esp)
 13a:	8d 45 ec             	lea    -0x14(%ebp),%eax
 13d:	89 44 24 04          	mov    %eax,0x4(%esp)
 141:	8b 45 f0             	mov    -0x10(%ebp),%eax
 144:	89 04 24             	mov    %eax,(%esp)
 147:	e8 d4 03 00 00       	call   520 <waitpid>
 14c:	89 44 24 08          	mov    %eax,0x8(%esp)
 150:	c7 44 24 04 33 0a 00 	movl   $0xa33,0x4(%esp)
 157:	00 
 158:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 15f:	e8 ab 04 00 00       	call   60f <printf>
			break;
 164:	eb 01                	jmp    167 <test_waitpid+0x135>
		default:
			break;
 166:	90                   	nop
	}


	printf(1, "child exited with status: %d \n", stat);
 167:	8b 45 ec             	mov    -0x14(%ebp),%eax
 16a:	89 44 24 08          	mov    %eax,0x8(%esp)
 16e:	c7 44 24 04 60 0a 00 	movl   $0xa60,0x4(%esp)
 175:	00 
 176:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 17d:	e8 8d 04 00 00       	call   60f <printf>
	;
	return 0;
 182:	b8 00 00 00 00       	mov    $0x0,%eax
}
 187:	c9                   	leave  
 188:	c3                   	ret    

00000189 <test_wait>:


/* testing working wait(status)*/
int test_wait(){
 189:	55                   	push   %ebp
 18a:	89 e5                	mov    %esp,%ebp
 18c:	83 ec 28             	sub    $0x28,%esp
	printf(1, "*** Testing wait(status) *** \n");
 18f:	c7 44 24 04 80 0a 00 	movl   $0xa80,0x4(%esp)
 196:	00 
 197:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 19e:	e8 6c 04 00 00       	call   60f <printf>
	int stat;
	int childStatus = 7;
 1a3:	c7 45 f4 07 00 00 00 	movl   $0x7,-0xc(%ebp)
	  printf(1,"Ruby Sapphire attack! \n");
 1aa:	c7 44 24 04 9f 0a 00 	movl   $0xa9f,0x4(%esp)
 1b1:	00 
 1b2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 1b9:	e8 51 04 00 00       	call   60f <printf>

	  if( !fork() ){
 1be:	e8 b5 02 00 00       	call   478 <fork>
 1c3:	85 c0                	test   %eax,%eax
 1c5:	75 26                	jne    1ed <test_wait+0x64>
		  printf(1, "Exiting with status: %d \n", childStatus);
 1c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1ca:	89 44 24 08          	mov    %eax,0x8(%esp)
 1ce:	c7 44 24 04 06 0a 00 	movl   $0xa06,0x4(%esp)
 1d5:	00 
 1d6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 1dd:	e8 2d 04 00 00       	call   60f <printf>
		  exit(childStatus);
 1e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1e5:	89 04 24             	mov    %eax,(%esp)
 1e8:	e8 93 02 00 00       	call   480 <exit>
	  }
	  //parent
	  wait(&stat);
 1ed:	8d 45 f0             	lea    -0x10(%ebp),%eax
 1f0:	89 04 24             	mov    %eax,(%esp)
 1f3:	e8 90 02 00 00       	call   488 <wait>
	  printf(1, "child exited with status: %d \n", stat);
 1f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
 1fb:	89 44 24 08          	mov    %eax,0x8(%esp)
 1ff:	c7 44 24 04 60 0a 00 	movl   $0xa60,0x4(%esp)
 206:	00 
 207:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 20e:	e8 fc 03 00 00       	call   60f <printf>

	  return 0;
 213:	b8 00 00 00 00       	mov    $0x0,%eax
}
 218:	c9                   	leave  
 219:	c3                   	ret    
 21a:	90                   	nop
 21b:	90                   	nop

0000021c <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 21c:	55                   	push   %ebp
 21d:	89 e5                	mov    %esp,%ebp
 21f:	57                   	push   %edi
 220:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 221:	8b 4d 08             	mov    0x8(%ebp),%ecx
 224:	8b 55 10             	mov    0x10(%ebp),%edx
 227:	8b 45 0c             	mov    0xc(%ebp),%eax
 22a:	89 cb                	mov    %ecx,%ebx
 22c:	89 df                	mov    %ebx,%edi
 22e:	89 d1                	mov    %edx,%ecx
 230:	fc                   	cld    
 231:	f3 aa                	rep stos %al,%es:(%edi)
 233:	89 ca                	mov    %ecx,%edx
 235:	89 fb                	mov    %edi,%ebx
 237:	89 5d 08             	mov    %ebx,0x8(%ebp)
 23a:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 23d:	5b                   	pop    %ebx
 23e:	5f                   	pop    %edi
 23f:	5d                   	pop    %ebp
 240:	c3                   	ret    

00000241 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 241:	55                   	push   %ebp
 242:	89 e5                	mov    %esp,%ebp
 244:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 247:	8b 45 08             	mov    0x8(%ebp),%eax
 24a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 24d:	90                   	nop
 24e:	8b 45 0c             	mov    0xc(%ebp),%eax
 251:	0f b6 10             	movzbl (%eax),%edx
 254:	8b 45 08             	mov    0x8(%ebp),%eax
 257:	88 10                	mov    %dl,(%eax)
 259:	8b 45 08             	mov    0x8(%ebp),%eax
 25c:	0f b6 00             	movzbl (%eax),%eax
 25f:	84 c0                	test   %al,%al
 261:	0f 95 c0             	setne  %al
 264:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 268:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 26c:	84 c0                	test   %al,%al
 26e:	75 de                	jne    24e <strcpy+0xd>
    ;
  return os;
 270:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 273:	c9                   	leave  
 274:	c3                   	ret    

00000275 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 275:	55                   	push   %ebp
 276:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 278:	eb 08                	jmp    282 <strcmp+0xd>
    p++, q++;
 27a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 27e:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 282:	8b 45 08             	mov    0x8(%ebp),%eax
 285:	0f b6 00             	movzbl (%eax),%eax
 288:	84 c0                	test   %al,%al
 28a:	74 10                	je     29c <strcmp+0x27>
 28c:	8b 45 08             	mov    0x8(%ebp),%eax
 28f:	0f b6 10             	movzbl (%eax),%edx
 292:	8b 45 0c             	mov    0xc(%ebp),%eax
 295:	0f b6 00             	movzbl (%eax),%eax
 298:	38 c2                	cmp    %al,%dl
 29a:	74 de                	je     27a <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 29c:	8b 45 08             	mov    0x8(%ebp),%eax
 29f:	0f b6 00             	movzbl (%eax),%eax
 2a2:	0f b6 d0             	movzbl %al,%edx
 2a5:	8b 45 0c             	mov    0xc(%ebp),%eax
 2a8:	0f b6 00             	movzbl (%eax),%eax
 2ab:	0f b6 c0             	movzbl %al,%eax
 2ae:	89 d1                	mov    %edx,%ecx
 2b0:	29 c1                	sub    %eax,%ecx
 2b2:	89 c8                	mov    %ecx,%eax
}
 2b4:	5d                   	pop    %ebp
 2b5:	c3                   	ret    

000002b6 <strlen>:

uint
strlen(char *s)
{
 2b6:	55                   	push   %ebp
 2b7:	89 e5                	mov    %esp,%ebp
 2b9:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 2bc:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 2c3:	eb 04                	jmp    2c9 <strlen+0x13>
 2c5:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 2c9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 2cc:	03 45 08             	add    0x8(%ebp),%eax
 2cf:	0f b6 00             	movzbl (%eax),%eax
 2d2:	84 c0                	test   %al,%al
 2d4:	75 ef                	jne    2c5 <strlen+0xf>
    ;
  return n;
 2d6:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 2d9:	c9                   	leave  
 2da:	c3                   	ret    

000002db <memset>:

void*
memset(void *dst, int c, uint n)
{
 2db:	55                   	push   %ebp
 2dc:	89 e5                	mov    %esp,%ebp
 2de:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 2e1:	8b 45 10             	mov    0x10(%ebp),%eax
 2e4:	89 44 24 08          	mov    %eax,0x8(%esp)
 2e8:	8b 45 0c             	mov    0xc(%ebp),%eax
 2eb:	89 44 24 04          	mov    %eax,0x4(%esp)
 2ef:	8b 45 08             	mov    0x8(%ebp),%eax
 2f2:	89 04 24             	mov    %eax,(%esp)
 2f5:	e8 22 ff ff ff       	call   21c <stosb>
  return dst;
 2fa:	8b 45 08             	mov    0x8(%ebp),%eax
}
 2fd:	c9                   	leave  
 2fe:	c3                   	ret    

000002ff <strchr>:

char*
strchr(const char *s, char c)
{
 2ff:	55                   	push   %ebp
 300:	89 e5                	mov    %esp,%ebp
 302:	83 ec 04             	sub    $0x4,%esp
 305:	8b 45 0c             	mov    0xc(%ebp),%eax
 308:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 30b:	eb 14                	jmp    321 <strchr+0x22>
    if(*s == c)
 30d:	8b 45 08             	mov    0x8(%ebp),%eax
 310:	0f b6 00             	movzbl (%eax),%eax
 313:	3a 45 fc             	cmp    -0x4(%ebp),%al
 316:	75 05                	jne    31d <strchr+0x1e>
      return (char*)s;
 318:	8b 45 08             	mov    0x8(%ebp),%eax
 31b:	eb 13                	jmp    330 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 31d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 321:	8b 45 08             	mov    0x8(%ebp),%eax
 324:	0f b6 00             	movzbl (%eax),%eax
 327:	84 c0                	test   %al,%al
 329:	75 e2                	jne    30d <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 32b:	b8 00 00 00 00       	mov    $0x0,%eax
}
 330:	c9                   	leave  
 331:	c3                   	ret    

00000332 <gets>:

char*
gets(char *buf, int max)
{
 332:	55                   	push   %ebp
 333:	89 e5                	mov    %esp,%ebp
 335:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 338:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 33f:	eb 44                	jmp    385 <gets+0x53>
    cc = read(0, &c, 1);
 341:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 348:	00 
 349:	8d 45 ef             	lea    -0x11(%ebp),%eax
 34c:	89 44 24 04          	mov    %eax,0x4(%esp)
 350:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 357:	e8 3c 01 00 00       	call   498 <read>
 35c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 35f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 363:	7e 2d                	jle    392 <gets+0x60>
      break;
    buf[i++] = c;
 365:	8b 45 f4             	mov    -0xc(%ebp),%eax
 368:	03 45 08             	add    0x8(%ebp),%eax
 36b:	0f b6 55 ef          	movzbl -0x11(%ebp),%edx
 36f:	88 10                	mov    %dl,(%eax)
 371:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(c == '\n' || c == '\r')
 375:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 379:	3c 0a                	cmp    $0xa,%al
 37b:	74 16                	je     393 <gets+0x61>
 37d:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 381:	3c 0d                	cmp    $0xd,%al
 383:	74 0e                	je     393 <gets+0x61>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 385:	8b 45 f4             	mov    -0xc(%ebp),%eax
 388:	83 c0 01             	add    $0x1,%eax
 38b:	3b 45 0c             	cmp    0xc(%ebp),%eax
 38e:	7c b1                	jl     341 <gets+0xf>
 390:	eb 01                	jmp    393 <gets+0x61>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 392:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 393:	8b 45 f4             	mov    -0xc(%ebp),%eax
 396:	03 45 08             	add    0x8(%ebp),%eax
 399:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 39c:	8b 45 08             	mov    0x8(%ebp),%eax
}
 39f:	c9                   	leave  
 3a0:	c3                   	ret    

000003a1 <stat>:

int
stat(char *n, struct stat *st)
{
 3a1:	55                   	push   %ebp
 3a2:	89 e5                	mov    %esp,%ebp
 3a4:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 3a7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 3ae:	00 
 3af:	8b 45 08             	mov    0x8(%ebp),%eax
 3b2:	89 04 24             	mov    %eax,(%esp)
 3b5:	e8 06 01 00 00       	call   4c0 <open>
 3ba:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 3bd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 3c1:	79 07                	jns    3ca <stat+0x29>
    return -1;
 3c3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 3c8:	eb 23                	jmp    3ed <stat+0x4c>
  r = fstat(fd, st);
 3ca:	8b 45 0c             	mov    0xc(%ebp),%eax
 3cd:	89 44 24 04          	mov    %eax,0x4(%esp)
 3d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3d4:	89 04 24             	mov    %eax,(%esp)
 3d7:	e8 fc 00 00 00       	call   4d8 <fstat>
 3dc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 3df:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3e2:	89 04 24             	mov    %eax,(%esp)
 3e5:	e8 be 00 00 00       	call   4a8 <close>
  return r;
 3ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 3ed:	c9                   	leave  
 3ee:	c3                   	ret    

000003ef <atoi>:

int
atoi(const char *s)
{
 3ef:	55                   	push   %ebp
 3f0:	89 e5                	mov    %esp,%ebp
 3f2:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 3f5:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 3fc:	eb 23                	jmp    421 <atoi+0x32>
    n = n*10 + *s++ - '0';
 3fe:	8b 55 fc             	mov    -0x4(%ebp),%edx
 401:	89 d0                	mov    %edx,%eax
 403:	c1 e0 02             	shl    $0x2,%eax
 406:	01 d0                	add    %edx,%eax
 408:	01 c0                	add    %eax,%eax
 40a:	89 c2                	mov    %eax,%edx
 40c:	8b 45 08             	mov    0x8(%ebp),%eax
 40f:	0f b6 00             	movzbl (%eax),%eax
 412:	0f be c0             	movsbl %al,%eax
 415:	01 d0                	add    %edx,%eax
 417:	83 e8 30             	sub    $0x30,%eax
 41a:	89 45 fc             	mov    %eax,-0x4(%ebp)
 41d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 421:	8b 45 08             	mov    0x8(%ebp),%eax
 424:	0f b6 00             	movzbl (%eax),%eax
 427:	3c 2f                	cmp    $0x2f,%al
 429:	7e 0a                	jle    435 <atoi+0x46>
 42b:	8b 45 08             	mov    0x8(%ebp),%eax
 42e:	0f b6 00             	movzbl (%eax),%eax
 431:	3c 39                	cmp    $0x39,%al
 433:	7e c9                	jle    3fe <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 435:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 438:	c9                   	leave  
 439:	c3                   	ret    

0000043a <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 43a:	55                   	push   %ebp
 43b:	89 e5                	mov    %esp,%ebp
 43d:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 440:	8b 45 08             	mov    0x8(%ebp),%eax
 443:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 446:	8b 45 0c             	mov    0xc(%ebp),%eax
 449:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 44c:	eb 13                	jmp    461 <memmove+0x27>
    *dst++ = *src++;
 44e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 451:	0f b6 10             	movzbl (%eax),%edx
 454:	8b 45 fc             	mov    -0x4(%ebp),%eax
 457:	88 10                	mov    %dl,(%eax)
 459:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 45d:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 461:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 465:	0f 9f c0             	setg   %al
 468:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 46c:	84 c0                	test   %al,%al
 46e:	75 de                	jne    44e <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 470:	8b 45 08             	mov    0x8(%ebp),%eax
}
 473:	c9                   	leave  
 474:	c3                   	ret    
 475:	90                   	nop
 476:	90                   	nop
 477:	90                   	nop

00000478 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 478:	b8 01 00 00 00       	mov    $0x1,%eax
 47d:	cd 40                	int    $0x40
 47f:	c3                   	ret    

00000480 <exit>:
SYSCALL(exit)
 480:	b8 02 00 00 00       	mov    $0x2,%eax
 485:	cd 40                	int    $0x40
 487:	c3                   	ret    

00000488 <wait>:
SYSCALL(wait)
 488:	b8 03 00 00 00       	mov    $0x3,%eax
 48d:	cd 40                	int    $0x40
 48f:	c3                   	ret    

00000490 <pipe>:
SYSCALL(pipe)
 490:	b8 04 00 00 00       	mov    $0x4,%eax
 495:	cd 40                	int    $0x40
 497:	c3                   	ret    

00000498 <read>:
SYSCALL(read)
 498:	b8 05 00 00 00       	mov    $0x5,%eax
 49d:	cd 40                	int    $0x40
 49f:	c3                   	ret    

000004a0 <write>:
SYSCALL(write)
 4a0:	b8 10 00 00 00       	mov    $0x10,%eax
 4a5:	cd 40                	int    $0x40
 4a7:	c3                   	ret    

000004a8 <close>:
SYSCALL(close)
 4a8:	b8 15 00 00 00       	mov    $0x15,%eax
 4ad:	cd 40                	int    $0x40
 4af:	c3                   	ret    

000004b0 <kill>:
SYSCALL(kill)
 4b0:	b8 06 00 00 00       	mov    $0x6,%eax
 4b5:	cd 40                	int    $0x40
 4b7:	c3                   	ret    

000004b8 <exec>:
SYSCALL(exec)
 4b8:	b8 07 00 00 00       	mov    $0x7,%eax
 4bd:	cd 40                	int    $0x40
 4bf:	c3                   	ret    

000004c0 <open>:
SYSCALL(open)
 4c0:	b8 0f 00 00 00       	mov    $0xf,%eax
 4c5:	cd 40                	int    $0x40
 4c7:	c3                   	ret    

000004c8 <mknod>:
SYSCALL(mknod)
 4c8:	b8 11 00 00 00       	mov    $0x11,%eax
 4cd:	cd 40                	int    $0x40
 4cf:	c3                   	ret    

000004d0 <unlink>:
SYSCALL(unlink)
 4d0:	b8 12 00 00 00       	mov    $0x12,%eax
 4d5:	cd 40                	int    $0x40
 4d7:	c3                   	ret    

000004d8 <fstat>:
SYSCALL(fstat)
 4d8:	b8 08 00 00 00       	mov    $0x8,%eax
 4dd:	cd 40                	int    $0x40
 4df:	c3                   	ret    

000004e0 <link>:
SYSCALL(link)
 4e0:	b8 13 00 00 00       	mov    $0x13,%eax
 4e5:	cd 40                	int    $0x40
 4e7:	c3                   	ret    

000004e8 <mkdir>:
SYSCALL(mkdir)
 4e8:	b8 14 00 00 00       	mov    $0x14,%eax
 4ed:	cd 40                	int    $0x40
 4ef:	c3                   	ret    

000004f0 <chdir>:
SYSCALL(chdir)
 4f0:	b8 09 00 00 00       	mov    $0x9,%eax
 4f5:	cd 40                	int    $0x40
 4f7:	c3                   	ret    

000004f8 <dup>:
SYSCALL(dup)
 4f8:	b8 0a 00 00 00       	mov    $0xa,%eax
 4fd:	cd 40                	int    $0x40
 4ff:	c3                   	ret    

00000500 <getpid>:
SYSCALL(getpid)
 500:	b8 0b 00 00 00       	mov    $0xb,%eax
 505:	cd 40                	int    $0x40
 507:	c3                   	ret    

00000508 <sbrk>:
SYSCALL(sbrk)
 508:	b8 0c 00 00 00       	mov    $0xc,%eax
 50d:	cd 40                	int    $0x40
 50f:	c3                   	ret    

00000510 <sleep>:
SYSCALL(sleep)
 510:	b8 0d 00 00 00       	mov    $0xd,%eax
 515:	cd 40                	int    $0x40
 517:	c3                   	ret    

00000518 <uptime>:
SYSCALL(uptime)
 518:	b8 0e 00 00 00       	mov    $0xe,%eax
 51d:	cd 40                	int    $0x40
 51f:	c3                   	ret    

00000520 <waitpid>:
SYSCALL(waitpid)
 520:	b8 16 00 00 00       	mov    $0x16,%eax
 525:	cd 40                	int    $0x40
 527:	c3                   	ret    

00000528 <wait_stat>:
SYSCALL(wait_stat)
 528:	b8 17 00 00 00       	mov    $0x17,%eax
 52d:	cd 40                	int    $0x40
 52f:	c3                   	ret    

00000530 <list_pgroup>:
SYSCALL(list_pgroup)
 530:	b8 18 00 00 00       	mov    $0x18,%eax
 535:	cd 40                	int    $0x40
 537:	c3                   	ret    

00000538 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 538:	55                   	push   %ebp
 539:	89 e5                	mov    %esp,%ebp
 53b:	83 ec 28             	sub    $0x28,%esp
 53e:	8b 45 0c             	mov    0xc(%ebp),%eax
 541:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 544:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 54b:	00 
 54c:	8d 45 f4             	lea    -0xc(%ebp),%eax
 54f:	89 44 24 04          	mov    %eax,0x4(%esp)
 553:	8b 45 08             	mov    0x8(%ebp),%eax
 556:	89 04 24             	mov    %eax,(%esp)
 559:	e8 42 ff ff ff       	call   4a0 <write>
}
 55e:	c9                   	leave  
 55f:	c3                   	ret    

00000560 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 560:	55                   	push   %ebp
 561:	89 e5                	mov    %esp,%ebp
 563:	83 ec 48             	sub    $0x48,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 566:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 56d:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 571:	74 17                	je     58a <printint+0x2a>
 573:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 577:	79 11                	jns    58a <printint+0x2a>
    neg = 1;
 579:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 580:	8b 45 0c             	mov    0xc(%ebp),%eax
 583:	f7 d8                	neg    %eax
 585:	89 45 ec             	mov    %eax,-0x14(%ebp)
 588:	eb 06                	jmp    590 <printint+0x30>
  } else {
    x = xx;
 58a:	8b 45 0c             	mov    0xc(%ebp),%eax
 58d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 590:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 597:	8b 4d 10             	mov    0x10(%ebp),%ecx
 59a:	8b 45 ec             	mov    -0x14(%ebp),%eax
 59d:	ba 00 00 00 00       	mov    $0x0,%edx
 5a2:	f7 f1                	div    %ecx
 5a4:	89 d0                	mov    %edx,%eax
 5a6:	0f b6 90 3c 0d 00 00 	movzbl 0xd3c(%eax),%edx
 5ad:	8d 45 dc             	lea    -0x24(%ebp),%eax
 5b0:	03 45 f4             	add    -0xc(%ebp),%eax
 5b3:	88 10                	mov    %dl,(%eax)
 5b5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  }while((x /= base) != 0);
 5b9:	8b 55 10             	mov    0x10(%ebp),%edx
 5bc:	89 55 d4             	mov    %edx,-0x2c(%ebp)
 5bf:	8b 45 ec             	mov    -0x14(%ebp),%eax
 5c2:	ba 00 00 00 00       	mov    $0x0,%edx
 5c7:	f7 75 d4             	divl   -0x2c(%ebp)
 5ca:	89 45 ec             	mov    %eax,-0x14(%ebp)
 5cd:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 5d1:	75 c4                	jne    597 <printint+0x37>
  if(neg)
 5d3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 5d7:	74 2a                	je     603 <printint+0xa3>
    buf[i++] = '-';
 5d9:	8d 45 dc             	lea    -0x24(%ebp),%eax
 5dc:	03 45 f4             	add    -0xc(%ebp),%eax
 5df:	c6 00 2d             	movb   $0x2d,(%eax)
 5e2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

  while(--i >= 0)
 5e6:	eb 1b                	jmp    603 <printint+0xa3>
    putc(fd, buf[i]);
 5e8:	8d 45 dc             	lea    -0x24(%ebp),%eax
 5eb:	03 45 f4             	add    -0xc(%ebp),%eax
 5ee:	0f b6 00             	movzbl (%eax),%eax
 5f1:	0f be c0             	movsbl %al,%eax
 5f4:	89 44 24 04          	mov    %eax,0x4(%esp)
 5f8:	8b 45 08             	mov    0x8(%ebp),%eax
 5fb:	89 04 24             	mov    %eax,(%esp)
 5fe:	e8 35 ff ff ff       	call   538 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 603:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 607:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 60b:	79 db                	jns    5e8 <printint+0x88>
    putc(fd, buf[i]);
}
 60d:	c9                   	leave  
 60e:	c3                   	ret    

0000060f <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 60f:	55                   	push   %ebp
 610:	89 e5                	mov    %esp,%ebp
 612:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 615:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 61c:	8d 45 0c             	lea    0xc(%ebp),%eax
 61f:	83 c0 04             	add    $0x4,%eax
 622:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 625:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 62c:	e9 7d 01 00 00       	jmp    7ae <printf+0x19f>
    c = fmt[i] & 0xff;
 631:	8b 55 0c             	mov    0xc(%ebp),%edx
 634:	8b 45 f0             	mov    -0x10(%ebp),%eax
 637:	01 d0                	add    %edx,%eax
 639:	0f b6 00             	movzbl (%eax),%eax
 63c:	0f be c0             	movsbl %al,%eax
 63f:	25 ff 00 00 00       	and    $0xff,%eax
 644:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 647:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 64b:	75 2c                	jne    679 <printf+0x6a>
      if(c == '%'){
 64d:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 651:	75 0c                	jne    65f <printf+0x50>
        state = '%';
 653:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 65a:	e9 4b 01 00 00       	jmp    7aa <printf+0x19b>
      } else {
        putc(fd, c);
 65f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 662:	0f be c0             	movsbl %al,%eax
 665:	89 44 24 04          	mov    %eax,0x4(%esp)
 669:	8b 45 08             	mov    0x8(%ebp),%eax
 66c:	89 04 24             	mov    %eax,(%esp)
 66f:	e8 c4 fe ff ff       	call   538 <putc>
 674:	e9 31 01 00 00       	jmp    7aa <printf+0x19b>
      }
    } else if(state == '%'){
 679:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 67d:	0f 85 27 01 00 00    	jne    7aa <printf+0x19b>
      if(c == 'd'){
 683:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 687:	75 2d                	jne    6b6 <printf+0xa7>
        printint(fd, *ap, 10, 1);
 689:	8b 45 e8             	mov    -0x18(%ebp),%eax
 68c:	8b 00                	mov    (%eax),%eax
 68e:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 695:	00 
 696:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 69d:	00 
 69e:	89 44 24 04          	mov    %eax,0x4(%esp)
 6a2:	8b 45 08             	mov    0x8(%ebp),%eax
 6a5:	89 04 24             	mov    %eax,(%esp)
 6a8:	e8 b3 fe ff ff       	call   560 <printint>
        ap++;
 6ad:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 6b1:	e9 ed 00 00 00       	jmp    7a3 <printf+0x194>
      } else if(c == 'x' || c == 'p'){
 6b6:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 6ba:	74 06                	je     6c2 <printf+0xb3>
 6bc:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 6c0:	75 2d                	jne    6ef <printf+0xe0>
        printint(fd, *ap, 16, 0);
 6c2:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6c5:	8b 00                	mov    (%eax),%eax
 6c7:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 6ce:	00 
 6cf:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 6d6:	00 
 6d7:	89 44 24 04          	mov    %eax,0x4(%esp)
 6db:	8b 45 08             	mov    0x8(%ebp),%eax
 6de:	89 04 24             	mov    %eax,(%esp)
 6e1:	e8 7a fe ff ff       	call   560 <printint>
        ap++;
 6e6:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 6ea:	e9 b4 00 00 00       	jmp    7a3 <printf+0x194>
      } else if(c == 's'){
 6ef:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 6f3:	75 46                	jne    73b <printf+0x12c>
        s = (char*)*ap;
 6f5:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6f8:	8b 00                	mov    (%eax),%eax
 6fa:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 6fd:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 701:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 705:	75 27                	jne    72e <printf+0x11f>
          s = "(null)";
 707:	c7 45 f4 b7 0a 00 00 	movl   $0xab7,-0xc(%ebp)
        while(*s != 0){
 70e:	eb 1e                	jmp    72e <printf+0x11f>
          putc(fd, *s);
 710:	8b 45 f4             	mov    -0xc(%ebp),%eax
 713:	0f b6 00             	movzbl (%eax),%eax
 716:	0f be c0             	movsbl %al,%eax
 719:	89 44 24 04          	mov    %eax,0x4(%esp)
 71d:	8b 45 08             	mov    0x8(%ebp),%eax
 720:	89 04 24             	mov    %eax,(%esp)
 723:	e8 10 fe ff ff       	call   538 <putc>
          s++;
 728:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 72c:	eb 01                	jmp    72f <printf+0x120>
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 72e:	90                   	nop
 72f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 732:	0f b6 00             	movzbl (%eax),%eax
 735:	84 c0                	test   %al,%al
 737:	75 d7                	jne    710 <printf+0x101>
 739:	eb 68                	jmp    7a3 <printf+0x194>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 73b:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 73f:	75 1d                	jne    75e <printf+0x14f>
        putc(fd, *ap);
 741:	8b 45 e8             	mov    -0x18(%ebp),%eax
 744:	8b 00                	mov    (%eax),%eax
 746:	0f be c0             	movsbl %al,%eax
 749:	89 44 24 04          	mov    %eax,0x4(%esp)
 74d:	8b 45 08             	mov    0x8(%ebp),%eax
 750:	89 04 24             	mov    %eax,(%esp)
 753:	e8 e0 fd ff ff       	call   538 <putc>
        ap++;
 758:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 75c:	eb 45                	jmp    7a3 <printf+0x194>
      } else if(c == '%'){
 75e:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 762:	75 17                	jne    77b <printf+0x16c>
        putc(fd, c);
 764:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 767:	0f be c0             	movsbl %al,%eax
 76a:	89 44 24 04          	mov    %eax,0x4(%esp)
 76e:	8b 45 08             	mov    0x8(%ebp),%eax
 771:	89 04 24             	mov    %eax,(%esp)
 774:	e8 bf fd ff ff       	call   538 <putc>
 779:	eb 28                	jmp    7a3 <printf+0x194>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 77b:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 782:	00 
 783:	8b 45 08             	mov    0x8(%ebp),%eax
 786:	89 04 24             	mov    %eax,(%esp)
 789:	e8 aa fd ff ff       	call   538 <putc>
        putc(fd, c);
 78e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 791:	0f be c0             	movsbl %al,%eax
 794:	89 44 24 04          	mov    %eax,0x4(%esp)
 798:	8b 45 08             	mov    0x8(%ebp),%eax
 79b:	89 04 24             	mov    %eax,(%esp)
 79e:	e8 95 fd ff ff       	call   538 <putc>
      }
      state = 0;
 7a3:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 7aa:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 7ae:	8b 55 0c             	mov    0xc(%ebp),%edx
 7b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7b4:	01 d0                	add    %edx,%eax
 7b6:	0f b6 00             	movzbl (%eax),%eax
 7b9:	84 c0                	test   %al,%al
 7bb:	0f 85 70 fe ff ff    	jne    631 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 7c1:	c9                   	leave  
 7c2:	c3                   	ret    
 7c3:	90                   	nop

000007c4 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7c4:	55                   	push   %ebp
 7c5:	89 e5                	mov    %esp,%ebp
 7c7:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7ca:	8b 45 08             	mov    0x8(%ebp),%eax
 7cd:	83 e8 08             	sub    $0x8,%eax
 7d0:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7d3:	a1 58 0d 00 00       	mov    0xd58,%eax
 7d8:	89 45 fc             	mov    %eax,-0x4(%ebp)
 7db:	eb 24                	jmp    801 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7dd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7e0:	8b 00                	mov    (%eax),%eax
 7e2:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 7e5:	77 12                	ja     7f9 <free+0x35>
 7e7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7ea:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 7ed:	77 24                	ja     813 <free+0x4f>
 7ef:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7f2:	8b 00                	mov    (%eax),%eax
 7f4:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 7f7:	77 1a                	ja     813 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7f9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7fc:	8b 00                	mov    (%eax),%eax
 7fe:	89 45 fc             	mov    %eax,-0x4(%ebp)
 801:	8b 45 f8             	mov    -0x8(%ebp),%eax
 804:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 807:	76 d4                	jbe    7dd <free+0x19>
 809:	8b 45 fc             	mov    -0x4(%ebp),%eax
 80c:	8b 00                	mov    (%eax),%eax
 80e:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 811:	76 ca                	jbe    7dd <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 813:	8b 45 f8             	mov    -0x8(%ebp),%eax
 816:	8b 40 04             	mov    0x4(%eax),%eax
 819:	c1 e0 03             	shl    $0x3,%eax
 81c:	89 c2                	mov    %eax,%edx
 81e:	03 55 f8             	add    -0x8(%ebp),%edx
 821:	8b 45 fc             	mov    -0x4(%ebp),%eax
 824:	8b 00                	mov    (%eax),%eax
 826:	39 c2                	cmp    %eax,%edx
 828:	75 24                	jne    84e <free+0x8a>
    bp->s.size += p->s.ptr->s.size;
 82a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 82d:	8b 50 04             	mov    0x4(%eax),%edx
 830:	8b 45 fc             	mov    -0x4(%ebp),%eax
 833:	8b 00                	mov    (%eax),%eax
 835:	8b 40 04             	mov    0x4(%eax),%eax
 838:	01 c2                	add    %eax,%edx
 83a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 83d:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 840:	8b 45 fc             	mov    -0x4(%ebp),%eax
 843:	8b 00                	mov    (%eax),%eax
 845:	8b 10                	mov    (%eax),%edx
 847:	8b 45 f8             	mov    -0x8(%ebp),%eax
 84a:	89 10                	mov    %edx,(%eax)
 84c:	eb 0a                	jmp    858 <free+0x94>
  } else
    bp->s.ptr = p->s.ptr;
 84e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 851:	8b 10                	mov    (%eax),%edx
 853:	8b 45 f8             	mov    -0x8(%ebp),%eax
 856:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 858:	8b 45 fc             	mov    -0x4(%ebp),%eax
 85b:	8b 40 04             	mov    0x4(%eax),%eax
 85e:	c1 e0 03             	shl    $0x3,%eax
 861:	03 45 fc             	add    -0x4(%ebp),%eax
 864:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 867:	75 20                	jne    889 <free+0xc5>
    p->s.size += bp->s.size;
 869:	8b 45 fc             	mov    -0x4(%ebp),%eax
 86c:	8b 50 04             	mov    0x4(%eax),%edx
 86f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 872:	8b 40 04             	mov    0x4(%eax),%eax
 875:	01 c2                	add    %eax,%edx
 877:	8b 45 fc             	mov    -0x4(%ebp),%eax
 87a:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 87d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 880:	8b 10                	mov    (%eax),%edx
 882:	8b 45 fc             	mov    -0x4(%ebp),%eax
 885:	89 10                	mov    %edx,(%eax)
 887:	eb 08                	jmp    891 <free+0xcd>
  } else
    p->s.ptr = bp;
 889:	8b 45 fc             	mov    -0x4(%ebp),%eax
 88c:	8b 55 f8             	mov    -0x8(%ebp),%edx
 88f:	89 10                	mov    %edx,(%eax)
  freep = p;
 891:	8b 45 fc             	mov    -0x4(%ebp),%eax
 894:	a3 58 0d 00 00       	mov    %eax,0xd58
}
 899:	c9                   	leave  
 89a:	c3                   	ret    

0000089b <morecore>:

static Header*
morecore(uint nu)
{
 89b:	55                   	push   %ebp
 89c:	89 e5                	mov    %esp,%ebp
 89e:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 8a1:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 8a8:	77 07                	ja     8b1 <morecore+0x16>
    nu = 4096;
 8aa:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 8b1:	8b 45 08             	mov    0x8(%ebp),%eax
 8b4:	c1 e0 03             	shl    $0x3,%eax
 8b7:	89 04 24             	mov    %eax,(%esp)
 8ba:	e8 49 fc ff ff       	call   508 <sbrk>
 8bf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 8c2:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 8c6:	75 07                	jne    8cf <morecore+0x34>
    return 0;
 8c8:	b8 00 00 00 00       	mov    $0x0,%eax
 8cd:	eb 22                	jmp    8f1 <morecore+0x56>
  hp = (Header*)p;
 8cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8d2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 8d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8d8:	8b 55 08             	mov    0x8(%ebp),%edx
 8db:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 8de:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8e1:	83 c0 08             	add    $0x8,%eax
 8e4:	89 04 24             	mov    %eax,(%esp)
 8e7:	e8 d8 fe ff ff       	call   7c4 <free>
  return freep;
 8ec:	a1 58 0d 00 00       	mov    0xd58,%eax
}
 8f1:	c9                   	leave  
 8f2:	c3                   	ret    

000008f3 <malloc>:

void*
malloc(uint nbytes)
{
 8f3:	55                   	push   %ebp
 8f4:	89 e5                	mov    %esp,%ebp
 8f6:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8f9:	8b 45 08             	mov    0x8(%ebp),%eax
 8fc:	83 c0 07             	add    $0x7,%eax
 8ff:	c1 e8 03             	shr    $0x3,%eax
 902:	83 c0 01             	add    $0x1,%eax
 905:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 908:	a1 58 0d 00 00       	mov    0xd58,%eax
 90d:	89 45 f0             	mov    %eax,-0x10(%ebp)
 910:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 914:	75 23                	jne    939 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 916:	c7 45 f0 50 0d 00 00 	movl   $0xd50,-0x10(%ebp)
 91d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 920:	a3 58 0d 00 00       	mov    %eax,0xd58
 925:	a1 58 0d 00 00       	mov    0xd58,%eax
 92a:	a3 50 0d 00 00       	mov    %eax,0xd50
    base.s.size = 0;
 92f:	c7 05 54 0d 00 00 00 	movl   $0x0,0xd54
 936:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 939:	8b 45 f0             	mov    -0x10(%ebp),%eax
 93c:	8b 00                	mov    (%eax),%eax
 93e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 941:	8b 45 f4             	mov    -0xc(%ebp),%eax
 944:	8b 40 04             	mov    0x4(%eax),%eax
 947:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 94a:	72 4d                	jb     999 <malloc+0xa6>
      if(p->s.size == nunits)
 94c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 94f:	8b 40 04             	mov    0x4(%eax),%eax
 952:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 955:	75 0c                	jne    963 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 957:	8b 45 f4             	mov    -0xc(%ebp),%eax
 95a:	8b 10                	mov    (%eax),%edx
 95c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 95f:	89 10                	mov    %edx,(%eax)
 961:	eb 26                	jmp    989 <malloc+0x96>
      else {
        p->s.size -= nunits;
 963:	8b 45 f4             	mov    -0xc(%ebp),%eax
 966:	8b 40 04             	mov    0x4(%eax),%eax
 969:	89 c2                	mov    %eax,%edx
 96b:	2b 55 ec             	sub    -0x14(%ebp),%edx
 96e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 971:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 974:	8b 45 f4             	mov    -0xc(%ebp),%eax
 977:	8b 40 04             	mov    0x4(%eax),%eax
 97a:	c1 e0 03             	shl    $0x3,%eax
 97d:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 980:	8b 45 f4             	mov    -0xc(%ebp),%eax
 983:	8b 55 ec             	mov    -0x14(%ebp),%edx
 986:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 989:	8b 45 f0             	mov    -0x10(%ebp),%eax
 98c:	a3 58 0d 00 00       	mov    %eax,0xd58
      return (void*)(p + 1);
 991:	8b 45 f4             	mov    -0xc(%ebp),%eax
 994:	83 c0 08             	add    $0x8,%eax
 997:	eb 38                	jmp    9d1 <malloc+0xde>
    }
    if(p == freep)
 999:	a1 58 0d 00 00       	mov    0xd58,%eax
 99e:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 9a1:	75 1b                	jne    9be <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 9a3:	8b 45 ec             	mov    -0x14(%ebp),%eax
 9a6:	89 04 24             	mov    %eax,(%esp)
 9a9:	e8 ed fe ff ff       	call   89b <morecore>
 9ae:	89 45 f4             	mov    %eax,-0xc(%ebp)
 9b1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 9b5:	75 07                	jne    9be <malloc+0xcb>
        return 0;
 9b7:	b8 00 00 00 00       	mov    $0x0,%eax
 9bc:	eb 13                	jmp    9d1 <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9be:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9c1:	89 45 f0             	mov    %eax,-0x10(%ebp)
 9c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9c7:	8b 00                	mov    (%eax),%eax
 9c9:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 9cc:	e9 70 ff ff ff       	jmp    941 <malloc+0x4e>
}
 9d1:	c9                   	leave  
 9d2:	c3                   	ret    
