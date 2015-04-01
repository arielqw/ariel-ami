
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
  38:	c7 44 24 04 c4 09 00 	movl   $0x9c4,0x4(%esp)
  3f:	00 
  40:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  47:	e8 b3 05 00 00       	call   5ff <printf>

	printf(1, "check invalid son: %d \n", waitpid(666,0,0));
  4c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  53:	00 
  54:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  5b:	00 
  5c:	c7 04 24 9a 02 00 00 	movl   $0x29a,(%esp)
  63:	e8 b8 04 00 00       	call   520 <waitpid>
  68:	89 44 24 08          	mov    %eax,0x8(%esp)
  6c:	c7 44 24 04 de 09 00 	movl   $0x9de,0x4(%esp)
  73:	00 
  74:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  7b:	e8 7f 05 00 00       	call   5ff <printf>
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
  a8:	c7 44 24 04 f6 09 00 	movl   $0x9f6,0x4(%esp)
  af:	00 
  b0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  b7:	e8 43 05 00 00       	call   5ff <printf>
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
  d8:	c7 44 24 04 10 0a 00 	movl   $0xa10,0x4(%esp)
  df:	00 
  e0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  e7:	e8 13 05 00 00       	call   5ff <printf>
			printf(1, "waitpid returns: %d \n", waitpid(pid,&stat,option));
  ec:	8b 45 08             	mov    0x8(%ebp),%eax
  ef:	89 44 24 08          	mov    %eax,0x8(%esp)
  f3:	8d 45 ec             	lea    -0x14(%ebp),%eax
  f6:	89 44 24 04          	mov    %eax,0x4(%esp)
  fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  fd:	89 04 24             	mov    %eax,(%esp)
 100:	e8 1b 04 00 00       	call   520 <waitpid>
 105:	89 44 24 08          	mov    %eax,0x8(%esp)
 109:	c7 44 24 04 23 0a 00 	movl   $0xa23,0x4(%esp)
 110:	00 
 111:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 118:	e8 e2 04 00 00       	call   5ff <printf>
			break;
 11d:	eb 48                	jmp    167 <test_waitpid+0x135>
		case NONBLOCKING:
			printf(1, "testing NONBLOCKING \n");
 11f:	c7 44 24 04 39 0a 00 	movl   $0xa39,0x4(%esp)
 126:	00 
 127:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 12e:	e8 cc 04 00 00       	call   5ff <printf>
			printf(1, "waitpid returns: %d \n", waitpid(pid,&stat,option));
 133:	8b 45 08             	mov    0x8(%ebp),%eax
 136:	89 44 24 08          	mov    %eax,0x8(%esp)
 13a:	8d 45 ec             	lea    -0x14(%ebp),%eax
 13d:	89 44 24 04          	mov    %eax,0x4(%esp)
 141:	8b 45 f0             	mov    -0x10(%ebp),%eax
 144:	89 04 24             	mov    %eax,(%esp)
 147:	e8 d4 03 00 00       	call   520 <waitpid>
 14c:	89 44 24 08          	mov    %eax,0x8(%esp)
 150:	c7 44 24 04 23 0a 00 	movl   $0xa23,0x4(%esp)
 157:	00 
 158:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 15f:	e8 9b 04 00 00       	call   5ff <printf>
			break;
 164:	eb 01                	jmp    167 <test_waitpid+0x135>
		default:
			break;
 166:	90                   	nop
	}


	printf(1, "child exited with status: %d \n", stat);
 167:	8b 45 ec             	mov    -0x14(%ebp),%eax
 16a:	89 44 24 08          	mov    %eax,0x8(%esp)
 16e:	c7 44 24 04 50 0a 00 	movl   $0xa50,0x4(%esp)
 175:	00 
 176:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 17d:	e8 7d 04 00 00       	call   5ff <printf>
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
 18f:	c7 44 24 04 70 0a 00 	movl   $0xa70,0x4(%esp)
 196:	00 
 197:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 19e:	e8 5c 04 00 00       	call   5ff <printf>
	int stat;
	int childStatus = 7;
 1a3:	c7 45 f4 07 00 00 00 	movl   $0x7,-0xc(%ebp)
	  printf(1,"Ruby Sapphire attack! \n");
 1aa:	c7 44 24 04 8f 0a 00 	movl   $0xa8f,0x4(%esp)
 1b1:	00 
 1b2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 1b9:	e8 41 04 00 00       	call   5ff <printf>

	  if( !fork() ){
 1be:	e8 b5 02 00 00       	call   478 <fork>
 1c3:	85 c0                	test   %eax,%eax
 1c5:	75 26                	jne    1ed <test_wait+0x64>
		  printf(1, "Exiting with status: %d \n", childStatus);
 1c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1ca:	89 44 24 08          	mov    %eax,0x8(%esp)
 1ce:	c7 44 24 04 f6 09 00 	movl   $0x9f6,0x4(%esp)
 1d5:	00 
 1d6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 1dd:	e8 1d 04 00 00       	call   5ff <printf>
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
 1ff:	c7 44 24 04 50 0a 00 	movl   $0xa50,0x4(%esp)
 206:	00 
 207:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 20e:	e8 ec 03 00 00       	call   5ff <printf>

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

00000528 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 528:	55                   	push   %ebp
 529:	89 e5                	mov    %esp,%ebp
 52b:	83 ec 28             	sub    $0x28,%esp
 52e:	8b 45 0c             	mov    0xc(%ebp),%eax
 531:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 534:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 53b:	00 
 53c:	8d 45 f4             	lea    -0xc(%ebp),%eax
 53f:	89 44 24 04          	mov    %eax,0x4(%esp)
 543:	8b 45 08             	mov    0x8(%ebp),%eax
 546:	89 04 24             	mov    %eax,(%esp)
 549:	e8 52 ff ff ff       	call   4a0 <write>
}
 54e:	c9                   	leave  
 54f:	c3                   	ret    

00000550 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 550:	55                   	push   %ebp
 551:	89 e5                	mov    %esp,%ebp
 553:	83 ec 48             	sub    $0x48,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 556:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 55d:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 561:	74 17                	je     57a <printint+0x2a>
 563:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 567:	79 11                	jns    57a <printint+0x2a>
    neg = 1;
 569:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 570:	8b 45 0c             	mov    0xc(%ebp),%eax
 573:	f7 d8                	neg    %eax
 575:	89 45 ec             	mov    %eax,-0x14(%ebp)
 578:	eb 06                	jmp    580 <printint+0x30>
  } else {
    x = xx;
 57a:	8b 45 0c             	mov    0xc(%ebp),%eax
 57d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 580:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 587:	8b 4d 10             	mov    0x10(%ebp),%ecx
 58a:	8b 45 ec             	mov    -0x14(%ebp),%eax
 58d:	ba 00 00 00 00       	mov    $0x0,%edx
 592:	f7 f1                	div    %ecx
 594:	89 d0                	mov    %edx,%eax
 596:	0f b6 90 2c 0d 00 00 	movzbl 0xd2c(%eax),%edx
 59d:	8d 45 dc             	lea    -0x24(%ebp),%eax
 5a0:	03 45 f4             	add    -0xc(%ebp),%eax
 5a3:	88 10                	mov    %dl,(%eax)
 5a5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  }while((x /= base) != 0);
 5a9:	8b 55 10             	mov    0x10(%ebp),%edx
 5ac:	89 55 d4             	mov    %edx,-0x2c(%ebp)
 5af:	8b 45 ec             	mov    -0x14(%ebp),%eax
 5b2:	ba 00 00 00 00       	mov    $0x0,%edx
 5b7:	f7 75 d4             	divl   -0x2c(%ebp)
 5ba:	89 45 ec             	mov    %eax,-0x14(%ebp)
 5bd:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 5c1:	75 c4                	jne    587 <printint+0x37>
  if(neg)
 5c3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 5c7:	74 2a                	je     5f3 <printint+0xa3>
    buf[i++] = '-';
 5c9:	8d 45 dc             	lea    -0x24(%ebp),%eax
 5cc:	03 45 f4             	add    -0xc(%ebp),%eax
 5cf:	c6 00 2d             	movb   $0x2d,(%eax)
 5d2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

  while(--i >= 0)
 5d6:	eb 1b                	jmp    5f3 <printint+0xa3>
    putc(fd, buf[i]);
 5d8:	8d 45 dc             	lea    -0x24(%ebp),%eax
 5db:	03 45 f4             	add    -0xc(%ebp),%eax
 5de:	0f b6 00             	movzbl (%eax),%eax
 5e1:	0f be c0             	movsbl %al,%eax
 5e4:	89 44 24 04          	mov    %eax,0x4(%esp)
 5e8:	8b 45 08             	mov    0x8(%ebp),%eax
 5eb:	89 04 24             	mov    %eax,(%esp)
 5ee:	e8 35 ff ff ff       	call   528 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 5f3:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 5f7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 5fb:	79 db                	jns    5d8 <printint+0x88>
    putc(fd, buf[i]);
}
 5fd:	c9                   	leave  
 5fe:	c3                   	ret    

000005ff <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 5ff:	55                   	push   %ebp
 600:	89 e5                	mov    %esp,%ebp
 602:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 605:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 60c:	8d 45 0c             	lea    0xc(%ebp),%eax
 60f:	83 c0 04             	add    $0x4,%eax
 612:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 615:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 61c:	e9 7d 01 00 00       	jmp    79e <printf+0x19f>
    c = fmt[i] & 0xff;
 621:	8b 55 0c             	mov    0xc(%ebp),%edx
 624:	8b 45 f0             	mov    -0x10(%ebp),%eax
 627:	01 d0                	add    %edx,%eax
 629:	0f b6 00             	movzbl (%eax),%eax
 62c:	0f be c0             	movsbl %al,%eax
 62f:	25 ff 00 00 00       	and    $0xff,%eax
 634:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 637:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 63b:	75 2c                	jne    669 <printf+0x6a>
      if(c == '%'){
 63d:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 641:	75 0c                	jne    64f <printf+0x50>
        state = '%';
 643:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 64a:	e9 4b 01 00 00       	jmp    79a <printf+0x19b>
      } else {
        putc(fd, c);
 64f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 652:	0f be c0             	movsbl %al,%eax
 655:	89 44 24 04          	mov    %eax,0x4(%esp)
 659:	8b 45 08             	mov    0x8(%ebp),%eax
 65c:	89 04 24             	mov    %eax,(%esp)
 65f:	e8 c4 fe ff ff       	call   528 <putc>
 664:	e9 31 01 00 00       	jmp    79a <printf+0x19b>
      }
    } else if(state == '%'){
 669:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 66d:	0f 85 27 01 00 00    	jne    79a <printf+0x19b>
      if(c == 'd'){
 673:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 677:	75 2d                	jne    6a6 <printf+0xa7>
        printint(fd, *ap, 10, 1);
 679:	8b 45 e8             	mov    -0x18(%ebp),%eax
 67c:	8b 00                	mov    (%eax),%eax
 67e:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 685:	00 
 686:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 68d:	00 
 68e:	89 44 24 04          	mov    %eax,0x4(%esp)
 692:	8b 45 08             	mov    0x8(%ebp),%eax
 695:	89 04 24             	mov    %eax,(%esp)
 698:	e8 b3 fe ff ff       	call   550 <printint>
        ap++;
 69d:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 6a1:	e9 ed 00 00 00       	jmp    793 <printf+0x194>
      } else if(c == 'x' || c == 'p'){
 6a6:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 6aa:	74 06                	je     6b2 <printf+0xb3>
 6ac:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 6b0:	75 2d                	jne    6df <printf+0xe0>
        printint(fd, *ap, 16, 0);
 6b2:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6b5:	8b 00                	mov    (%eax),%eax
 6b7:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 6be:	00 
 6bf:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 6c6:	00 
 6c7:	89 44 24 04          	mov    %eax,0x4(%esp)
 6cb:	8b 45 08             	mov    0x8(%ebp),%eax
 6ce:	89 04 24             	mov    %eax,(%esp)
 6d1:	e8 7a fe ff ff       	call   550 <printint>
        ap++;
 6d6:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 6da:	e9 b4 00 00 00       	jmp    793 <printf+0x194>
      } else if(c == 's'){
 6df:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 6e3:	75 46                	jne    72b <printf+0x12c>
        s = (char*)*ap;
 6e5:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6e8:	8b 00                	mov    (%eax),%eax
 6ea:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 6ed:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 6f1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 6f5:	75 27                	jne    71e <printf+0x11f>
          s = "(null)";
 6f7:	c7 45 f4 a7 0a 00 00 	movl   $0xaa7,-0xc(%ebp)
        while(*s != 0){
 6fe:	eb 1e                	jmp    71e <printf+0x11f>
          putc(fd, *s);
 700:	8b 45 f4             	mov    -0xc(%ebp),%eax
 703:	0f b6 00             	movzbl (%eax),%eax
 706:	0f be c0             	movsbl %al,%eax
 709:	89 44 24 04          	mov    %eax,0x4(%esp)
 70d:	8b 45 08             	mov    0x8(%ebp),%eax
 710:	89 04 24             	mov    %eax,(%esp)
 713:	e8 10 fe ff ff       	call   528 <putc>
          s++;
 718:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 71c:	eb 01                	jmp    71f <printf+0x120>
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 71e:	90                   	nop
 71f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 722:	0f b6 00             	movzbl (%eax),%eax
 725:	84 c0                	test   %al,%al
 727:	75 d7                	jne    700 <printf+0x101>
 729:	eb 68                	jmp    793 <printf+0x194>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 72b:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 72f:	75 1d                	jne    74e <printf+0x14f>
        putc(fd, *ap);
 731:	8b 45 e8             	mov    -0x18(%ebp),%eax
 734:	8b 00                	mov    (%eax),%eax
 736:	0f be c0             	movsbl %al,%eax
 739:	89 44 24 04          	mov    %eax,0x4(%esp)
 73d:	8b 45 08             	mov    0x8(%ebp),%eax
 740:	89 04 24             	mov    %eax,(%esp)
 743:	e8 e0 fd ff ff       	call   528 <putc>
        ap++;
 748:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 74c:	eb 45                	jmp    793 <printf+0x194>
      } else if(c == '%'){
 74e:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 752:	75 17                	jne    76b <printf+0x16c>
        putc(fd, c);
 754:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 757:	0f be c0             	movsbl %al,%eax
 75a:	89 44 24 04          	mov    %eax,0x4(%esp)
 75e:	8b 45 08             	mov    0x8(%ebp),%eax
 761:	89 04 24             	mov    %eax,(%esp)
 764:	e8 bf fd ff ff       	call   528 <putc>
 769:	eb 28                	jmp    793 <printf+0x194>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 76b:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 772:	00 
 773:	8b 45 08             	mov    0x8(%ebp),%eax
 776:	89 04 24             	mov    %eax,(%esp)
 779:	e8 aa fd ff ff       	call   528 <putc>
        putc(fd, c);
 77e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 781:	0f be c0             	movsbl %al,%eax
 784:	89 44 24 04          	mov    %eax,0x4(%esp)
 788:	8b 45 08             	mov    0x8(%ebp),%eax
 78b:	89 04 24             	mov    %eax,(%esp)
 78e:	e8 95 fd ff ff       	call   528 <putc>
      }
      state = 0;
 793:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 79a:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 79e:	8b 55 0c             	mov    0xc(%ebp),%edx
 7a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7a4:	01 d0                	add    %edx,%eax
 7a6:	0f b6 00             	movzbl (%eax),%eax
 7a9:	84 c0                	test   %al,%al
 7ab:	0f 85 70 fe ff ff    	jne    621 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 7b1:	c9                   	leave  
 7b2:	c3                   	ret    
 7b3:	90                   	nop

000007b4 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7b4:	55                   	push   %ebp
 7b5:	89 e5                	mov    %esp,%ebp
 7b7:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7ba:	8b 45 08             	mov    0x8(%ebp),%eax
 7bd:	83 e8 08             	sub    $0x8,%eax
 7c0:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7c3:	a1 48 0d 00 00       	mov    0xd48,%eax
 7c8:	89 45 fc             	mov    %eax,-0x4(%ebp)
 7cb:	eb 24                	jmp    7f1 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7cd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7d0:	8b 00                	mov    (%eax),%eax
 7d2:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 7d5:	77 12                	ja     7e9 <free+0x35>
 7d7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7da:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 7dd:	77 24                	ja     803 <free+0x4f>
 7df:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7e2:	8b 00                	mov    (%eax),%eax
 7e4:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 7e7:	77 1a                	ja     803 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7e9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7ec:	8b 00                	mov    (%eax),%eax
 7ee:	89 45 fc             	mov    %eax,-0x4(%ebp)
 7f1:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7f4:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 7f7:	76 d4                	jbe    7cd <free+0x19>
 7f9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7fc:	8b 00                	mov    (%eax),%eax
 7fe:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 801:	76 ca                	jbe    7cd <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 803:	8b 45 f8             	mov    -0x8(%ebp),%eax
 806:	8b 40 04             	mov    0x4(%eax),%eax
 809:	c1 e0 03             	shl    $0x3,%eax
 80c:	89 c2                	mov    %eax,%edx
 80e:	03 55 f8             	add    -0x8(%ebp),%edx
 811:	8b 45 fc             	mov    -0x4(%ebp),%eax
 814:	8b 00                	mov    (%eax),%eax
 816:	39 c2                	cmp    %eax,%edx
 818:	75 24                	jne    83e <free+0x8a>
    bp->s.size += p->s.ptr->s.size;
 81a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 81d:	8b 50 04             	mov    0x4(%eax),%edx
 820:	8b 45 fc             	mov    -0x4(%ebp),%eax
 823:	8b 00                	mov    (%eax),%eax
 825:	8b 40 04             	mov    0x4(%eax),%eax
 828:	01 c2                	add    %eax,%edx
 82a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 82d:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 830:	8b 45 fc             	mov    -0x4(%ebp),%eax
 833:	8b 00                	mov    (%eax),%eax
 835:	8b 10                	mov    (%eax),%edx
 837:	8b 45 f8             	mov    -0x8(%ebp),%eax
 83a:	89 10                	mov    %edx,(%eax)
 83c:	eb 0a                	jmp    848 <free+0x94>
  } else
    bp->s.ptr = p->s.ptr;
 83e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 841:	8b 10                	mov    (%eax),%edx
 843:	8b 45 f8             	mov    -0x8(%ebp),%eax
 846:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 848:	8b 45 fc             	mov    -0x4(%ebp),%eax
 84b:	8b 40 04             	mov    0x4(%eax),%eax
 84e:	c1 e0 03             	shl    $0x3,%eax
 851:	03 45 fc             	add    -0x4(%ebp),%eax
 854:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 857:	75 20                	jne    879 <free+0xc5>
    p->s.size += bp->s.size;
 859:	8b 45 fc             	mov    -0x4(%ebp),%eax
 85c:	8b 50 04             	mov    0x4(%eax),%edx
 85f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 862:	8b 40 04             	mov    0x4(%eax),%eax
 865:	01 c2                	add    %eax,%edx
 867:	8b 45 fc             	mov    -0x4(%ebp),%eax
 86a:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 86d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 870:	8b 10                	mov    (%eax),%edx
 872:	8b 45 fc             	mov    -0x4(%ebp),%eax
 875:	89 10                	mov    %edx,(%eax)
 877:	eb 08                	jmp    881 <free+0xcd>
  } else
    p->s.ptr = bp;
 879:	8b 45 fc             	mov    -0x4(%ebp),%eax
 87c:	8b 55 f8             	mov    -0x8(%ebp),%edx
 87f:	89 10                	mov    %edx,(%eax)
  freep = p;
 881:	8b 45 fc             	mov    -0x4(%ebp),%eax
 884:	a3 48 0d 00 00       	mov    %eax,0xd48
}
 889:	c9                   	leave  
 88a:	c3                   	ret    

0000088b <morecore>:

static Header*
morecore(uint nu)
{
 88b:	55                   	push   %ebp
 88c:	89 e5                	mov    %esp,%ebp
 88e:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 891:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 898:	77 07                	ja     8a1 <morecore+0x16>
    nu = 4096;
 89a:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 8a1:	8b 45 08             	mov    0x8(%ebp),%eax
 8a4:	c1 e0 03             	shl    $0x3,%eax
 8a7:	89 04 24             	mov    %eax,(%esp)
 8aa:	e8 59 fc ff ff       	call   508 <sbrk>
 8af:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 8b2:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 8b6:	75 07                	jne    8bf <morecore+0x34>
    return 0;
 8b8:	b8 00 00 00 00       	mov    $0x0,%eax
 8bd:	eb 22                	jmp    8e1 <morecore+0x56>
  hp = (Header*)p;
 8bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8c2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 8c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8c8:	8b 55 08             	mov    0x8(%ebp),%edx
 8cb:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 8ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8d1:	83 c0 08             	add    $0x8,%eax
 8d4:	89 04 24             	mov    %eax,(%esp)
 8d7:	e8 d8 fe ff ff       	call   7b4 <free>
  return freep;
 8dc:	a1 48 0d 00 00       	mov    0xd48,%eax
}
 8e1:	c9                   	leave  
 8e2:	c3                   	ret    

000008e3 <malloc>:

void*
malloc(uint nbytes)
{
 8e3:	55                   	push   %ebp
 8e4:	89 e5                	mov    %esp,%ebp
 8e6:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8e9:	8b 45 08             	mov    0x8(%ebp),%eax
 8ec:	83 c0 07             	add    $0x7,%eax
 8ef:	c1 e8 03             	shr    $0x3,%eax
 8f2:	83 c0 01             	add    $0x1,%eax
 8f5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 8f8:	a1 48 0d 00 00       	mov    0xd48,%eax
 8fd:	89 45 f0             	mov    %eax,-0x10(%ebp)
 900:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 904:	75 23                	jne    929 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 906:	c7 45 f0 40 0d 00 00 	movl   $0xd40,-0x10(%ebp)
 90d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 910:	a3 48 0d 00 00       	mov    %eax,0xd48
 915:	a1 48 0d 00 00       	mov    0xd48,%eax
 91a:	a3 40 0d 00 00       	mov    %eax,0xd40
    base.s.size = 0;
 91f:	c7 05 44 0d 00 00 00 	movl   $0x0,0xd44
 926:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 929:	8b 45 f0             	mov    -0x10(%ebp),%eax
 92c:	8b 00                	mov    (%eax),%eax
 92e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 931:	8b 45 f4             	mov    -0xc(%ebp),%eax
 934:	8b 40 04             	mov    0x4(%eax),%eax
 937:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 93a:	72 4d                	jb     989 <malloc+0xa6>
      if(p->s.size == nunits)
 93c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 93f:	8b 40 04             	mov    0x4(%eax),%eax
 942:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 945:	75 0c                	jne    953 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 947:	8b 45 f4             	mov    -0xc(%ebp),%eax
 94a:	8b 10                	mov    (%eax),%edx
 94c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 94f:	89 10                	mov    %edx,(%eax)
 951:	eb 26                	jmp    979 <malloc+0x96>
      else {
        p->s.size -= nunits;
 953:	8b 45 f4             	mov    -0xc(%ebp),%eax
 956:	8b 40 04             	mov    0x4(%eax),%eax
 959:	89 c2                	mov    %eax,%edx
 95b:	2b 55 ec             	sub    -0x14(%ebp),%edx
 95e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 961:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 964:	8b 45 f4             	mov    -0xc(%ebp),%eax
 967:	8b 40 04             	mov    0x4(%eax),%eax
 96a:	c1 e0 03             	shl    $0x3,%eax
 96d:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 970:	8b 45 f4             	mov    -0xc(%ebp),%eax
 973:	8b 55 ec             	mov    -0x14(%ebp),%edx
 976:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 979:	8b 45 f0             	mov    -0x10(%ebp),%eax
 97c:	a3 48 0d 00 00       	mov    %eax,0xd48
      return (void*)(p + 1);
 981:	8b 45 f4             	mov    -0xc(%ebp),%eax
 984:	83 c0 08             	add    $0x8,%eax
 987:	eb 38                	jmp    9c1 <malloc+0xde>
    }
    if(p == freep)
 989:	a1 48 0d 00 00       	mov    0xd48,%eax
 98e:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 991:	75 1b                	jne    9ae <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 993:	8b 45 ec             	mov    -0x14(%ebp),%eax
 996:	89 04 24             	mov    %eax,(%esp)
 999:	e8 ed fe ff ff       	call   88b <morecore>
 99e:	89 45 f4             	mov    %eax,-0xc(%ebp)
 9a1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 9a5:	75 07                	jne    9ae <malloc+0xcb>
        return 0;
 9a7:	b8 00 00 00 00       	mov    $0x0,%eax
 9ac:	eb 13                	jmp    9c1 <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9b1:	89 45 f0             	mov    %eax,-0x10(%ebp)
 9b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9b7:	8b 00                	mov    (%eax),%eax
 9b9:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 9bc:	e9 70 ff ff ff       	jmp    931 <malloc+0x4e>
}
 9c1:	c9                   	leave  
 9c2:	c3                   	ret    
