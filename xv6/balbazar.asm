
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
  38:	c7 44 24 04 cc 09 00 	movl   $0x9cc,0x4(%esp)
  3f:	00 
  40:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  47:	e8 bb 05 00 00       	call   607 <printf>

	printf(1, "check invalid son: %d \n", waitpid(666,0,0));
  4c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  53:	00 
  54:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  5b:	00 
  5c:	c7 04 24 9a 02 00 00 	movl   $0x29a,(%esp)
  63:	e8 b8 04 00 00       	call   520 <waitpid>
  68:	89 44 24 08          	mov    %eax,0x8(%esp)
  6c:	c7 44 24 04 e6 09 00 	movl   $0x9e6,0x4(%esp)
  73:	00 
  74:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  7b:	e8 87 05 00 00       	call   607 <printf>
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
  a8:	c7 44 24 04 fe 09 00 	movl   $0x9fe,0x4(%esp)
  af:	00 
  b0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  b7:	e8 4b 05 00 00       	call   607 <printf>
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
  d8:	c7 44 24 04 18 0a 00 	movl   $0xa18,0x4(%esp)
  df:	00 
  e0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  e7:	e8 1b 05 00 00       	call   607 <printf>
			printf(1, "waitpid returns: %d \n", waitpid(pid,&stat,option));
  ec:	8b 45 08             	mov    0x8(%ebp),%eax
  ef:	89 44 24 08          	mov    %eax,0x8(%esp)
  f3:	8d 45 ec             	lea    -0x14(%ebp),%eax
  f6:	89 44 24 04          	mov    %eax,0x4(%esp)
  fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  fd:	89 04 24             	mov    %eax,(%esp)
 100:	e8 1b 04 00 00       	call   520 <waitpid>
 105:	89 44 24 08          	mov    %eax,0x8(%esp)
 109:	c7 44 24 04 2b 0a 00 	movl   $0xa2b,0x4(%esp)
 110:	00 
 111:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 118:	e8 ea 04 00 00       	call   607 <printf>
			break;
 11d:	eb 48                	jmp    167 <test_waitpid+0x135>
		case NONBLOCKING:
			printf(1, "testing NONBLOCKING \n");
 11f:	c7 44 24 04 41 0a 00 	movl   $0xa41,0x4(%esp)
 126:	00 
 127:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 12e:	e8 d4 04 00 00       	call   607 <printf>
			printf(1, "waitpid returns: %d \n", waitpid(pid,&stat,option));
 133:	8b 45 08             	mov    0x8(%ebp),%eax
 136:	89 44 24 08          	mov    %eax,0x8(%esp)
 13a:	8d 45 ec             	lea    -0x14(%ebp),%eax
 13d:	89 44 24 04          	mov    %eax,0x4(%esp)
 141:	8b 45 f0             	mov    -0x10(%ebp),%eax
 144:	89 04 24             	mov    %eax,(%esp)
 147:	e8 d4 03 00 00       	call   520 <waitpid>
 14c:	89 44 24 08          	mov    %eax,0x8(%esp)
 150:	c7 44 24 04 2b 0a 00 	movl   $0xa2b,0x4(%esp)
 157:	00 
 158:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 15f:	e8 a3 04 00 00       	call   607 <printf>
			break;
 164:	eb 01                	jmp    167 <test_waitpid+0x135>
		default:
			break;
 166:	90                   	nop
	}


	printf(1, "child exited with status: %d \n", stat);
 167:	8b 45 ec             	mov    -0x14(%ebp),%eax
 16a:	89 44 24 08          	mov    %eax,0x8(%esp)
 16e:	c7 44 24 04 58 0a 00 	movl   $0xa58,0x4(%esp)
 175:	00 
 176:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 17d:	e8 85 04 00 00       	call   607 <printf>
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
 18f:	c7 44 24 04 78 0a 00 	movl   $0xa78,0x4(%esp)
 196:	00 
 197:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 19e:	e8 64 04 00 00       	call   607 <printf>
	int stat;
	int childStatus = 7;
 1a3:	c7 45 f4 07 00 00 00 	movl   $0x7,-0xc(%ebp)
	  printf(1,"Ruby Sapphire attack! \n");
 1aa:	c7 44 24 04 97 0a 00 	movl   $0xa97,0x4(%esp)
 1b1:	00 
 1b2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 1b9:	e8 49 04 00 00       	call   607 <printf>

	  if( !fork() ){
 1be:	e8 b5 02 00 00       	call   478 <fork>
 1c3:	85 c0                	test   %eax,%eax
 1c5:	75 26                	jne    1ed <test_wait+0x64>
		  printf(1, "Exiting with status: %d \n", childStatus);
 1c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1ca:	89 44 24 08          	mov    %eax,0x8(%esp)
 1ce:	c7 44 24 04 fe 09 00 	movl   $0x9fe,0x4(%esp)
 1d5:	00 
 1d6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 1dd:	e8 25 04 00 00       	call   607 <printf>
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
 1ff:	c7 44 24 04 58 0a 00 	movl   $0xa58,0x4(%esp)
 206:	00 
 207:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 20e:	e8 f4 03 00 00       	call   607 <printf>

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

00000530 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 530:	55                   	push   %ebp
 531:	89 e5                	mov    %esp,%ebp
 533:	83 ec 28             	sub    $0x28,%esp
 536:	8b 45 0c             	mov    0xc(%ebp),%eax
 539:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 53c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 543:	00 
 544:	8d 45 f4             	lea    -0xc(%ebp),%eax
 547:	89 44 24 04          	mov    %eax,0x4(%esp)
 54b:	8b 45 08             	mov    0x8(%ebp),%eax
 54e:	89 04 24             	mov    %eax,(%esp)
 551:	e8 4a ff ff ff       	call   4a0 <write>
}
 556:	c9                   	leave  
 557:	c3                   	ret    

00000558 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 558:	55                   	push   %ebp
 559:	89 e5                	mov    %esp,%ebp
 55b:	83 ec 48             	sub    $0x48,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 55e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 565:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 569:	74 17                	je     582 <printint+0x2a>
 56b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 56f:	79 11                	jns    582 <printint+0x2a>
    neg = 1;
 571:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 578:	8b 45 0c             	mov    0xc(%ebp),%eax
 57b:	f7 d8                	neg    %eax
 57d:	89 45 ec             	mov    %eax,-0x14(%ebp)
 580:	eb 06                	jmp    588 <printint+0x30>
  } else {
    x = xx;
 582:	8b 45 0c             	mov    0xc(%ebp),%eax
 585:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 588:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 58f:	8b 4d 10             	mov    0x10(%ebp),%ecx
 592:	8b 45 ec             	mov    -0x14(%ebp),%eax
 595:	ba 00 00 00 00       	mov    $0x0,%edx
 59a:	f7 f1                	div    %ecx
 59c:	89 d0                	mov    %edx,%eax
 59e:	0f b6 90 34 0d 00 00 	movzbl 0xd34(%eax),%edx
 5a5:	8d 45 dc             	lea    -0x24(%ebp),%eax
 5a8:	03 45 f4             	add    -0xc(%ebp),%eax
 5ab:	88 10                	mov    %dl,(%eax)
 5ad:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  }while((x /= base) != 0);
 5b1:	8b 55 10             	mov    0x10(%ebp),%edx
 5b4:	89 55 d4             	mov    %edx,-0x2c(%ebp)
 5b7:	8b 45 ec             	mov    -0x14(%ebp),%eax
 5ba:	ba 00 00 00 00       	mov    $0x0,%edx
 5bf:	f7 75 d4             	divl   -0x2c(%ebp)
 5c2:	89 45 ec             	mov    %eax,-0x14(%ebp)
 5c5:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 5c9:	75 c4                	jne    58f <printint+0x37>
  if(neg)
 5cb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 5cf:	74 2a                	je     5fb <printint+0xa3>
    buf[i++] = '-';
 5d1:	8d 45 dc             	lea    -0x24(%ebp),%eax
 5d4:	03 45 f4             	add    -0xc(%ebp),%eax
 5d7:	c6 00 2d             	movb   $0x2d,(%eax)
 5da:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

  while(--i >= 0)
 5de:	eb 1b                	jmp    5fb <printint+0xa3>
    putc(fd, buf[i]);
 5e0:	8d 45 dc             	lea    -0x24(%ebp),%eax
 5e3:	03 45 f4             	add    -0xc(%ebp),%eax
 5e6:	0f b6 00             	movzbl (%eax),%eax
 5e9:	0f be c0             	movsbl %al,%eax
 5ec:	89 44 24 04          	mov    %eax,0x4(%esp)
 5f0:	8b 45 08             	mov    0x8(%ebp),%eax
 5f3:	89 04 24             	mov    %eax,(%esp)
 5f6:	e8 35 ff ff ff       	call   530 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 5fb:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 5ff:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 603:	79 db                	jns    5e0 <printint+0x88>
    putc(fd, buf[i]);
}
 605:	c9                   	leave  
 606:	c3                   	ret    

00000607 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 607:	55                   	push   %ebp
 608:	89 e5                	mov    %esp,%ebp
 60a:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 60d:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 614:	8d 45 0c             	lea    0xc(%ebp),%eax
 617:	83 c0 04             	add    $0x4,%eax
 61a:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 61d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 624:	e9 7d 01 00 00       	jmp    7a6 <printf+0x19f>
    c = fmt[i] & 0xff;
 629:	8b 55 0c             	mov    0xc(%ebp),%edx
 62c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 62f:	01 d0                	add    %edx,%eax
 631:	0f b6 00             	movzbl (%eax),%eax
 634:	0f be c0             	movsbl %al,%eax
 637:	25 ff 00 00 00       	and    $0xff,%eax
 63c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 63f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 643:	75 2c                	jne    671 <printf+0x6a>
      if(c == '%'){
 645:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 649:	75 0c                	jne    657 <printf+0x50>
        state = '%';
 64b:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 652:	e9 4b 01 00 00       	jmp    7a2 <printf+0x19b>
      } else {
        putc(fd, c);
 657:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 65a:	0f be c0             	movsbl %al,%eax
 65d:	89 44 24 04          	mov    %eax,0x4(%esp)
 661:	8b 45 08             	mov    0x8(%ebp),%eax
 664:	89 04 24             	mov    %eax,(%esp)
 667:	e8 c4 fe ff ff       	call   530 <putc>
 66c:	e9 31 01 00 00       	jmp    7a2 <printf+0x19b>
      }
    } else if(state == '%'){
 671:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 675:	0f 85 27 01 00 00    	jne    7a2 <printf+0x19b>
      if(c == 'd'){
 67b:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 67f:	75 2d                	jne    6ae <printf+0xa7>
        printint(fd, *ap, 10, 1);
 681:	8b 45 e8             	mov    -0x18(%ebp),%eax
 684:	8b 00                	mov    (%eax),%eax
 686:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 68d:	00 
 68e:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 695:	00 
 696:	89 44 24 04          	mov    %eax,0x4(%esp)
 69a:	8b 45 08             	mov    0x8(%ebp),%eax
 69d:	89 04 24             	mov    %eax,(%esp)
 6a0:	e8 b3 fe ff ff       	call   558 <printint>
        ap++;
 6a5:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 6a9:	e9 ed 00 00 00       	jmp    79b <printf+0x194>
      } else if(c == 'x' || c == 'p'){
 6ae:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 6b2:	74 06                	je     6ba <printf+0xb3>
 6b4:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 6b8:	75 2d                	jne    6e7 <printf+0xe0>
        printint(fd, *ap, 16, 0);
 6ba:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6bd:	8b 00                	mov    (%eax),%eax
 6bf:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 6c6:	00 
 6c7:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 6ce:	00 
 6cf:	89 44 24 04          	mov    %eax,0x4(%esp)
 6d3:	8b 45 08             	mov    0x8(%ebp),%eax
 6d6:	89 04 24             	mov    %eax,(%esp)
 6d9:	e8 7a fe ff ff       	call   558 <printint>
        ap++;
 6de:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 6e2:	e9 b4 00 00 00       	jmp    79b <printf+0x194>
      } else if(c == 's'){
 6e7:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 6eb:	75 46                	jne    733 <printf+0x12c>
        s = (char*)*ap;
 6ed:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6f0:	8b 00                	mov    (%eax),%eax
 6f2:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 6f5:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 6f9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 6fd:	75 27                	jne    726 <printf+0x11f>
          s = "(null)";
 6ff:	c7 45 f4 af 0a 00 00 	movl   $0xaaf,-0xc(%ebp)
        while(*s != 0){
 706:	eb 1e                	jmp    726 <printf+0x11f>
          putc(fd, *s);
 708:	8b 45 f4             	mov    -0xc(%ebp),%eax
 70b:	0f b6 00             	movzbl (%eax),%eax
 70e:	0f be c0             	movsbl %al,%eax
 711:	89 44 24 04          	mov    %eax,0x4(%esp)
 715:	8b 45 08             	mov    0x8(%ebp),%eax
 718:	89 04 24             	mov    %eax,(%esp)
 71b:	e8 10 fe ff ff       	call   530 <putc>
          s++;
 720:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 724:	eb 01                	jmp    727 <printf+0x120>
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 726:	90                   	nop
 727:	8b 45 f4             	mov    -0xc(%ebp),%eax
 72a:	0f b6 00             	movzbl (%eax),%eax
 72d:	84 c0                	test   %al,%al
 72f:	75 d7                	jne    708 <printf+0x101>
 731:	eb 68                	jmp    79b <printf+0x194>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 733:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 737:	75 1d                	jne    756 <printf+0x14f>
        putc(fd, *ap);
 739:	8b 45 e8             	mov    -0x18(%ebp),%eax
 73c:	8b 00                	mov    (%eax),%eax
 73e:	0f be c0             	movsbl %al,%eax
 741:	89 44 24 04          	mov    %eax,0x4(%esp)
 745:	8b 45 08             	mov    0x8(%ebp),%eax
 748:	89 04 24             	mov    %eax,(%esp)
 74b:	e8 e0 fd ff ff       	call   530 <putc>
        ap++;
 750:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 754:	eb 45                	jmp    79b <printf+0x194>
      } else if(c == '%'){
 756:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 75a:	75 17                	jne    773 <printf+0x16c>
        putc(fd, c);
 75c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 75f:	0f be c0             	movsbl %al,%eax
 762:	89 44 24 04          	mov    %eax,0x4(%esp)
 766:	8b 45 08             	mov    0x8(%ebp),%eax
 769:	89 04 24             	mov    %eax,(%esp)
 76c:	e8 bf fd ff ff       	call   530 <putc>
 771:	eb 28                	jmp    79b <printf+0x194>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 773:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 77a:	00 
 77b:	8b 45 08             	mov    0x8(%ebp),%eax
 77e:	89 04 24             	mov    %eax,(%esp)
 781:	e8 aa fd ff ff       	call   530 <putc>
        putc(fd, c);
 786:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 789:	0f be c0             	movsbl %al,%eax
 78c:	89 44 24 04          	mov    %eax,0x4(%esp)
 790:	8b 45 08             	mov    0x8(%ebp),%eax
 793:	89 04 24             	mov    %eax,(%esp)
 796:	e8 95 fd ff ff       	call   530 <putc>
      }
      state = 0;
 79b:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 7a2:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 7a6:	8b 55 0c             	mov    0xc(%ebp),%edx
 7a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7ac:	01 d0                	add    %edx,%eax
 7ae:	0f b6 00             	movzbl (%eax),%eax
 7b1:	84 c0                	test   %al,%al
 7b3:	0f 85 70 fe ff ff    	jne    629 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 7b9:	c9                   	leave  
 7ba:	c3                   	ret    
 7bb:	90                   	nop

000007bc <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7bc:	55                   	push   %ebp
 7bd:	89 e5                	mov    %esp,%ebp
 7bf:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7c2:	8b 45 08             	mov    0x8(%ebp),%eax
 7c5:	83 e8 08             	sub    $0x8,%eax
 7c8:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7cb:	a1 50 0d 00 00       	mov    0xd50,%eax
 7d0:	89 45 fc             	mov    %eax,-0x4(%ebp)
 7d3:	eb 24                	jmp    7f9 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7d5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7d8:	8b 00                	mov    (%eax),%eax
 7da:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 7dd:	77 12                	ja     7f1 <free+0x35>
 7df:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7e2:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 7e5:	77 24                	ja     80b <free+0x4f>
 7e7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7ea:	8b 00                	mov    (%eax),%eax
 7ec:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 7ef:	77 1a                	ja     80b <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7f1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7f4:	8b 00                	mov    (%eax),%eax
 7f6:	89 45 fc             	mov    %eax,-0x4(%ebp)
 7f9:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7fc:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 7ff:	76 d4                	jbe    7d5 <free+0x19>
 801:	8b 45 fc             	mov    -0x4(%ebp),%eax
 804:	8b 00                	mov    (%eax),%eax
 806:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 809:	76 ca                	jbe    7d5 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 80b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 80e:	8b 40 04             	mov    0x4(%eax),%eax
 811:	c1 e0 03             	shl    $0x3,%eax
 814:	89 c2                	mov    %eax,%edx
 816:	03 55 f8             	add    -0x8(%ebp),%edx
 819:	8b 45 fc             	mov    -0x4(%ebp),%eax
 81c:	8b 00                	mov    (%eax),%eax
 81e:	39 c2                	cmp    %eax,%edx
 820:	75 24                	jne    846 <free+0x8a>
    bp->s.size += p->s.ptr->s.size;
 822:	8b 45 f8             	mov    -0x8(%ebp),%eax
 825:	8b 50 04             	mov    0x4(%eax),%edx
 828:	8b 45 fc             	mov    -0x4(%ebp),%eax
 82b:	8b 00                	mov    (%eax),%eax
 82d:	8b 40 04             	mov    0x4(%eax),%eax
 830:	01 c2                	add    %eax,%edx
 832:	8b 45 f8             	mov    -0x8(%ebp),%eax
 835:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 838:	8b 45 fc             	mov    -0x4(%ebp),%eax
 83b:	8b 00                	mov    (%eax),%eax
 83d:	8b 10                	mov    (%eax),%edx
 83f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 842:	89 10                	mov    %edx,(%eax)
 844:	eb 0a                	jmp    850 <free+0x94>
  } else
    bp->s.ptr = p->s.ptr;
 846:	8b 45 fc             	mov    -0x4(%ebp),%eax
 849:	8b 10                	mov    (%eax),%edx
 84b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 84e:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 850:	8b 45 fc             	mov    -0x4(%ebp),%eax
 853:	8b 40 04             	mov    0x4(%eax),%eax
 856:	c1 e0 03             	shl    $0x3,%eax
 859:	03 45 fc             	add    -0x4(%ebp),%eax
 85c:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 85f:	75 20                	jne    881 <free+0xc5>
    p->s.size += bp->s.size;
 861:	8b 45 fc             	mov    -0x4(%ebp),%eax
 864:	8b 50 04             	mov    0x4(%eax),%edx
 867:	8b 45 f8             	mov    -0x8(%ebp),%eax
 86a:	8b 40 04             	mov    0x4(%eax),%eax
 86d:	01 c2                	add    %eax,%edx
 86f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 872:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 875:	8b 45 f8             	mov    -0x8(%ebp),%eax
 878:	8b 10                	mov    (%eax),%edx
 87a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 87d:	89 10                	mov    %edx,(%eax)
 87f:	eb 08                	jmp    889 <free+0xcd>
  } else
    p->s.ptr = bp;
 881:	8b 45 fc             	mov    -0x4(%ebp),%eax
 884:	8b 55 f8             	mov    -0x8(%ebp),%edx
 887:	89 10                	mov    %edx,(%eax)
  freep = p;
 889:	8b 45 fc             	mov    -0x4(%ebp),%eax
 88c:	a3 50 0d 00 00       	mov    %eax,0xd50
}
 891:	c9                   	leave  
 892:	c3                   	ret    

00000893 <morecore>:

static Header*
morecore(uint nu)
{
 893:	55                   	push   %ebp
 894:	89 e5                	mov    %esp,%ebp
 896:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 899:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 8a0:	77 07                	ja     8a9 <morecore+0x16>
    nu = 4096;
 8a2:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 8a9:	8b 45 08             	mov    0x8(%ebp),%eax
 8ac:	c1 e0 03             	shl    $0x3,%eax
 8af:	89 04 24             	mov    %eax,(%esp)
 8b2:	e8 51 fc ff ff       	call   508 <sbrk>
 8b7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 8ba:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 8be:	75 07                	jne    8c7 <morecore+0x34>
    return 0;
 8c0:	b8 00 00 00 00       	mov    $0x0,%eax
 8c5:	eb 22                	jmp    8e9 <morecore+0x56>
  hp = (Header*)p;
 8c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8ca:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 8cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8d0:	8b 55 08             	mov    0x8(%ebp),%edx
 8d3:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 8d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8d9:	83 c0 08             	add    $0x8,%eax
 8dc:	89 04 24             	mov    %eax,(%esp)
 8df:	e8 d8 fe ff ff       	call   7bc <free>
  return freep;
 8e4:	a1 50 0d 00 00       	mov    0xd50,%eax
}
 8e9:	c9                   	leave  
 8ea:	c3                   	ret    

000008eb <malloc>:

void*
malloc(uint nbytes)
{
 8eb:	55                   	push   %ebp
 8ec:	89 e5                	mov    %esp,%ebp
 8ee:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8f1:	8b 45 08             	mov    0x8(%ebp),%eax
 8f4:	83 c0 07             	add    $0x7,%eax
 8f7:	c1 e8 03             	shr    $0x3,%eax
 8fa:	83 c0 01             	add    $0x1,%eax
 8fd:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 900:	a1 50 0d 00 00       	mov    0xd50,%eax
 905:	89 45 f0             	mov    %eax,-0x10(%ebp)
 908:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 90c:	75 23                	jne    931 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 90e:	c7 45 f0 48 0d 00 00 	movl   $0xd48,-0x10(%ebp)
 915:	8b 45 f0             	mov    -0x10(%ebp),%eax
 918:	a3 50 0d 00 00       	mov    %eax,0xd50
 91d:	a1 50 0d 00 00       	mov    0xd50,%eax
 922:	a3 48 0d 00 00       	mov    %eax,0xd48
    base.s.size = 0;
 927:	c7 05 4c 0d 00 00 00 	movl   $0x0,0xd4c
 92e:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 931:	8b 45 f0             	mov    -0x10(%ebp),%eax
 934:	8b 00                	mov    (%eax),%eax
 936:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 939:	8b 45 f4             	mov    -0xc(%ebp),%eax
 93c:	8b 40 04             	mov    0x4(%eax),%eax
 93f:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 942:	72 4d                	jb     991 <malloc+0xa6>
      if(p->s.size == nunits)
 944:	8b 45 f4             	mov    -0xc(%ebp),%eax
 947:	8b 40 04             	mov    0x4(%eax),%eax
 94a:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 94d:	75 0c                	jne    95b <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 94f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 952:	8b 10                	mov    (%eax),%edx
 954:	8b 45 f0             	mov    -0x10(%ebp),%eax
 957:	89 10                	mov    %edx,(%eax)
 959:	eb 26                	jmp    981 <malloc+0x96>
      else {
        p->s.size -= nunits;
 95b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 95e:	8b 40 04             	mov    0x4(%eax),%eax
 961:	89 c2                	mov    %eax,%edx
 963:	2b 55 ec             	sub    -0x14(%ebp),%edx
 966:	8b 45 f4             	mov    -0xc(%ebp),%eax
 969:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 96c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 96f:	8b 40 04             	mov    0x4(%eax),%eax
 972:	c1 e0 03             	shl    $0x3,%eax
 975:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 978:	8b 45 f4             	mov    -0xc(%ebp),%eax
 97b:	8b 55 ec             	mov    -0x14(%ebp),%edx
 97e:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 981:	8b 45 f0             	mov    -0x10(%ebp),%eax
 984:	a3 50 0d 00 00       	mov    %eax,0xd50
      return (void*)(p + 1);
 989:	8b 45 f4             	mov    -0xc(%ebp),%eax
 98c:	83 c0 08             	add    $0x8,%eax
 98f:	eb 38                	jmp    9c9 <malloc+0xde>
    }
    if(p == freep)
 991:	a1 50 0d 00 00       	mov    0xd50,%eax
 996:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 999:	75 1b                	jne    9b6 <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 99b:	8b 45 ec             	mov    -0x14(%ebp),%eax
 99e:	89 04 24             	mov    %eax,(%esp)
 9a1:	e8 ed fe ff ff       	call   893 <morecore>
 9a6:	89 45 f4             	mov    %eax,-0xc(%ebp)
 9a9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 9ad:	75 07                	jne    9b6 <malloc+0xcb>
        return 0;
 9af:	b8 00 00 00 00       	mov    $0x0,%eax
 9b4:	eb 13                	jmp    9c9 <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9b9:	89 45 f0             	mov    %eax,-0x10(%ebp)
 9bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9bf:	8b 00                	mov    (%eax),%eax
 9c1:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 9c4:	e9 70 ff ff ff       	jmp    939 <malloc+0x4e>
}
 9c9:	c9                   	leave  
 9ca:	c3                   	ret    
