
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
   9:	e8 0a 01 00 00       	call   118 <test_wait>
	test_waitpid(BLOCKING);
   e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  15:	e8 18 00 00 00       	call   32 <test_waitpid>
	test_waitpid(NONBLOCKING);
  1a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  21:	e8 0c 00 00 00       	call   32 <test_waitpid>

	exit(1);
  26:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  2d:	e8 de 03 00 00       	call   410 <exit>

00000032 <test_waitpid>:
	return 0;
}

/* testing working wait(status)*/
int test_waitpid(int option){
  32:	55                   	push   %ebp
  33:	89 e5                	mov    %esp,%ebp
  35:	83 ec 28             	sub    $0x28,%esp
	printf(1, "*** Testing waitpid *** \n");
  38:	c7 44 24 04 54 09 00 	movl   $0x954,0x4(%esp)
  3f:	00 
  40:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  47:	e8 43 05 00 00       	call   58f <printf>

	int stat;
	int childStatus = 9;
  4c:	c7 45 f4 09 00 00 00 	movl   $0x9,-0xc(%ebp)
	int pid;

	if( !( pid = fork() )  ){
  53:	e8 b0 03 00 00       	call   408 <fork>
  58:	89 45 f0             	mov    %eax,-0x10(%ebp)
  5b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  5f:	75 26                	jne    87 <test_waitpid+0x55>
	  printf(1, "Exiting with status: %d \n", childStatus);
  61:	8b 45 f4             	mov    -0xc(%ebp),%eax
  64:	89 44 24 08          	mov    %eax,0x8(%esp)
  68:	c7 44 24 04 6e 09 00 	movl   $0x96e,0x4(%esp)
  6f:	00 
  70:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  77:	e8 13 05 00 00       	call   58f <printf>
	  exit(childStatus);
  7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  7f:	89 04 24             	mov    %eax,(%esp)
  82:	e8 89 03 00 00       	call   410 <exit>
	}
	//parent
	switch (option) {
  87:	8b 45 08             	mov    0x8(%ebp),%eax
  8a:	85 c0                	test   %eax,%eax
  8c:	74 07                	je     95 <test_waitpid+0x63>
  8e:	83 f8 01             	cmp    $0x1,%eax
  91:	74 32                	je     c5 <test_waitpid+0x93>
  93:	eb 60                	jmp    f5 <test_waitpid+0xc3>
		case BLOCKING:
			printf(1, "testing BLOCKING \n");
  95:	c7 44 24 04 88 09 00 	movl   $0x988,0x4(%esp)
  9c:	00 
  9d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  a4:	e8 e6 04 00 00       	call   58f <printf>
			waitpid(pid,&stat,BLOCKING);
  a9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  b0:	00 
  b1:	8d 45 ec             	lea    -0x14(%ebp),%eax
  b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  bb:	89 04 24             	mov    %eax,(%esp)
  be:	e8 ed 03 00 00       	call   4b0 <waitpid>
			break;
  c3:	eb 31                	jmp    f6 <test_waitpid+0xc4>
		case NONBLOCKING:
			printf(1, "testing NONBLOCKING \n");
  c5:	c7 44 24 04 9b 09 00 	movl   $0x99b,0x4(%esp)
  cc:	00 
  cd:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  d4:	e8 b6 04 00 00       	call   58f <printf>
			waitpid(pid,&stat,NONBLOCKING);
  d9:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  e0:	00 
  e1:	8d 45 ec             	lea    -0x14(%ebp),%eax
  e4:	89 44 24 04          	mov    %eax,0x4(%esp)
  e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  eb:	89 04 24             	mov    %eax,(%esp)
  ee:	e8 bd 03 00 00       	call   4b0 <waitpid>
			break;
  f3:	eb 01                	jmp    f6 <test_waitpid+0xc4>
		default:
			break;
  f5:	90                   	nop
	}


	printf(1, "child exited with status: %d \n", stat);
  f6:	8b 45 ec             	mov    -0x14(%ebp),%eax
  f9:	89 44 24 08          	mov    %eax,0x8(%esp)
  fd:	c7 44 24 04 b4 09 00 	movl   $0x9b4,0x4(%esp)
 104:	00 
 105:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 10c:	e8 7e 04 00 00       	call   58f <printf>
	;
	return 0;
 111:	b8 00 00 00 00       	mov    $0x0,%eax
}
 116:	c9                   	leave  
 117:	c3                   	ret    

00000118 <test_wait>:


/* testing working wait(status)*/
int test_wait(){
 118:	55                   	push   %ebp
 119:	89 e5                	mov    %esp,%ebp
 11b:	83 ec 28             	sub    $0x28,%esp
	printf(1, "*** Testing wait(status) *** \n");
 11e:	c7 44 24 04 d4 09 00 	movl   $0x9d4,0x4(%esp)
 125:	00 
 126:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 12d:	e8 5d 04 00 00       	call   58f <printf>
	int stat;
	int childStatus = 7;
 132:	c7 45 f4 07 00 00 00 	movl   $0x7,-0xc(%ebp)
	  printf(1,"Ruby Sapphire attack! \n");
 139:	c7 44 24 04 f3 09 00 	movl   $0x9f3,0x4(%esp)
 140:	00 
 141:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 148:	e8 42 04 00 00       	call   58f <printf>

	  if( !fork() ){
 14d:	e8 b6 02 00 00       	call   408 <fork>
 152:	85 c0                	test   %eax,%eax
 154:	75 26                	jne    17c <test_wait+0x64>
		  printf(1, "Exiting with status: %d \n", childStatus);
 156:	8b 45 f4             	mov    -0xc(%ebp),%eax
 159:	89 44 24 08          	mov    %eax,0x8(%esp)
 15d:	c7 44 24 04 6e 09 00 	movl   $0x96e,0x4(%esp)
 164:	00 
 165:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 16c:	e8 1e 04 00 00       	call   58f <printf>
		  exit(childStatus);
 171:	8b 45 f4             	mov    -0xc(%ebp),%eax
 174:	89 04 24             	mov    %eax,(%esp)
 177:	e8 94 02 00 00       	call   410 <exit>
	  }
	  //parent
	  wait(&stat);
 17c:	8d 45 f0             	lea    -0x10(%ebp),%eax
 17f:	89 04 24             	mov    %eax,(%esp)
 182:	e8 91 02 00 00       	call   418 <wait>
	  printf(1, "child exited with status: %d \n", stat);
 187:	8b 45 f0             	mov    -0x10(%ebp),%eax
 18a:	89 44 24 08          	mov    %eax,0x8(%esp)
 18e:	c7 44 24 04 b4 09 00 	movl   $0x9b4,0x4(%esp)
 195:	00 
 196:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 19d:	e8 ed 03 00 00       	call   58f <printf>

	  return 0;
 1a2:	b8 00 00 00 00       	mov    $0x0,%eax
}
 1a7:	c9                   	leave  
 1a8:	c3                   	ret    
 1a9:	90                   	nop
 1aa:	90                   	nop
 1ab:	90                   	nop

000001ac <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 1ac:	55                   	push   %ebp
 1ad:	89 e5                	mov    %esp,%ebp
 1af:	57                   	push   %edi
 1b0:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 1b1:	8b 4d 08             	mov    0x8(%ebp),%ecx
 1b4:	8b 55 10             	mov    0x10(%ebp),%edx
 1b7:	8b 45 0c             	mov    0xc(%ebp),%eax
 1ba:	89 cb                	mov    %ecx,%ebx
 1bc:	89 df                	mov    %ebx,%edi
 1be:	89 d1                	mov    %edx,%ecx
 1c0:	fc                   	cld    
 1c1:	f3 aa                	rep stos %al,%es:(%edi)
 1c3:	89 ca                	mov    %ecx,%edx
 1c5:	89 fb                	mov    %edi,%ebx
 1c7:	89 5d 08             	mov    %ebx,0x8(%ebp)
 1ca:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 1cd:	5b                   	pop    %ebx
 1ce:	5f                   	pop    %edi
 1cf:	5d                   	pop    %ebp
 1d0:	c3                   	ret    

000001d1 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 1d1:	55                   	push   %ebp
 1d2:	89 e5                	mov    %esp,%ebp
 1d4:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 1d7:	8b 45 08             	mov    0x8(%ebp),%eax
 1da:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 1dd:	90                   	nop
 1de:	8b 45 0c             	mov    0xc(%ebp),%eax
 1e1:	0f b6 10             	movzbl (%eax),%edx
 1e4:	8b 45 08             	mov    0x8(%ebp),%eax
 1e7:	88 10                	mov    %dl,(%eax)
 1e9:	8b 45 08             	mov    0x8(%ebp),%eax
 1ec:	0f b6 00             	movzbl (%eax),%eax
 1ef:	84 c0                	test   %al,%al
 1f1:	0f 95 c0             	setne  %al
 1f4:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 1f8:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 1fc:	84 c0                	test   %al,%al
 1fe:	75 de                	jne    1de <strcpy+0xd>
    ;
  return os;
 200:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 203:	c9                   	leave  
 204:	c3                   	ret    

00000205 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 205:	55                   	push   %ebp
 206:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 208:	eb 08                	jmp    212 <strcmp+0xd>
    p++, q++;
 20a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 20e:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 212:	8b 45 08             	mov    0x8(%ebp),%eax
 215:	0f b6 00             	movzbl (%eax),%eax
 218:	84 c0                	test   %al,%al
 21a:	74 10                	je     22c <strcmp+0x27>
 21c:	8b 45 08             	mov    0x8(%ebp),%eax
 21f:	0f b6 10             	movzbl (%eax),%edx
 222:	8b 45 0c             	mov    0xc(%ebp),%eax
 225:	0f b6 00             	movzbl (%eax),%eax
 228:	38 c2                	cmp    %al,%dl
 22a:	74 de                	je     20a <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 22c:	8b 45 08             	mov    0x8(%ebp),%eax
 22f:	0f b6 00             	movzbl (%eax),%eax
 232:	0f b6 d0             	movzbl %al,%edx
 235:	8b 45 0c             	mov    0xc(%ebp),%eax
 238:	0f b6 00             	movzbl (%eax),%eax
 23b:	0f b6 c0             	movzbl %al,%eax
 23e:	89 d1                	mov    %edx,%ecx
 240:	29 c1                	sub    %eax,%ecx
 242:	89 c8                	mov    %ecx,%eax
}
 244:	5d                   	pop    %ebp
 245:	c3                   	ret    

00000246 <strlen>:

uint
strlen(char *s)
{
 246:	55                   	push   %ebp
 247:	89 e5                	mov    %esp,%ebp
 249:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 24c:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 253:	eb 04                	jmp    259 <strlen+0x13>
 255:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 259:	8b 45 fc             	mov    -0x4(%ebp),%eax
 25c:	03 45 08             	add    0x8(%ebp),%eax
 25f:	0f b6 00             	movzbl (%eax),%eax
 262:	84 c0                	test   %al,%al
 264:	75 ef                	jne    255 <strlen+0xf>
    ;
  return n;
 266:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 269:	c9                   	leave  
 26a:	c3                   	ret    

0000026b <memset>:

void*
memset(void *dst, int c, uint n)
{
 26b:	55                   	push   %ebp
 26c:	89 e5                	mov    %esp,%ebp
 26e:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 271:	8b 45 10             	mov    0x10(%ebp),%eax
 274:	89 44 24 08          	mov    %eax,0x8(%esp)
 278:	8b 45 0c             	mov    0xc(%ebp),%eax
 27b:	89 44 24 04          	mov    %eax,0x4(%esp)
 27f:	8b 45 08             	mov    0x8(%ebp),%eax
 282:	89 04 24             	mov    %eax,(%esp)
 285:	e8 22 ff ff ff       	call   1ac <stosb>
  return dst;
 28a:	8b 45 08             	mov    0x8(%ebp),%eax
}
 28d:	c9                   	leave  
 28e:	c3                   	ret    

0000028f <strchr>:

char*
strchr(const char *s, char c)
{
 28f:	55                   	push   %ebp
 290:	89 e5                	mov    %esp,%ebp
 292:	83 ec 04             	sub    $0x4,%esp
 295:	8b 45 0c             	mov    0xc(%ebp),%eax
 298:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 29b:	eb 14                	jmp    2b1 <strchr+0x22>
    if(*s == c)
 29d:	8b 45 08             	mov    0x8(%ebp),%eax
 2a0:	0f b6 00             	movzbl (%eax),%eax
 2a3:	3a 45 fc             	cmp    -0x4(%ebp),%al
 2a6:	75 05                	jne    2ad <strchr+0x1e>
      return (char*)s;
 2a8:	8b 45 08             	mov    0x8(%ebp),%eax
 2ab:	eb 13                	jmp    2c0 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 2ad:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 2b1:	8b 45 08             	mov    0x8(%ebp),%eax
 2b4:	0f b6 00             	movzbl (%eax),%eax
 2b7:	84 c0                	test   %al,%al
 2b9:	75 e2                	jne    29d <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 2bb:	b8 00 00 00 00       	mov    $0x0,%eax
}
 2c0:	c9                   	leave  
 2c1:	c3                   	ret    

000002c2 <gets>:

char*
gets(char *buf, int max)
{
 2c2:	55                   	push   %ebp
 2c3:	89 e5                	mov    %esp,%ebp
 2c5:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 2c8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 2cf:	eb 44                	jmp    315 <gets+0x53>
    cc = read(0, &c, 1);
 2d1:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 2d8:	00 
 2d9:	8d 45 ef             	lea    -0x11(%ebp),%eax
 2dc:	89 44 24 04          	mov    %eax,0x4(%esp)
 2e0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 2e7:	e8 3c 01 00 00       	call   428 <read>
 2ec:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 2ef:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 2f3:	7e 2d                	jle    322 <gets+0x60>
      break;
    buf[i++] = c;
 2f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2f8:	03 45 08             	add    0x8(%ebp),%eax
 2fb:	0f b6 55 ef          	movzbl -0x11(%ebp),%edx
 2ff:	88 10                	mov    %dl,(%eax)
 301:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(c == '\n' || c == '\r')
 305:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 309:	3c 0a                	cmp    $0xa,%al
 30b:	74 16                	je     323 <gets+0x61>
 30d:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 311:	3c 0d                	cmp    $0xd,%al
 313:	74 0e                	je     323 <gets+0x61>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 315:	8b 45 f4             	mov    -0xc(%ebp),%eax
 318:	83 c0 01             	add    $0x1,%eax
 31b:	3b 45 0c             	cmp    0xc(%ebp),%eax
 31e:	7c b1                	jl     2d1 <gets+0xf>
 320:	eb 01                	jmp    323 <gets+0x61>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 322:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 323:	8b 45 f4             	mov    -0xc(%ebp),%eax
 326:	03 45 08             	add    0x8(%ebp),%eax
 329:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 32c:	8b 45 08             	mov    0x8(%ebp),%eax
}
 32f:	c9                   	leave  
 330:	c3                   	ret    

00000331 <stat>:

int
stat(char *n, struct stat *st)
{
 331:	55                   	push   %ebp
 332:	89 e5                	mov    %esp,%ebp
 334:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 337:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 33e:	00 
 33f:	8b 45 08             	mov    0x8(%ebp),%eax
 342:	89 04 24             	mov    %eax,(%esp)
 345:	e8 06 01 00 00       	call   450 <open>
 34a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 34d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 351:	79 07                	jns    35a <stat+0x29>
    return -1;
 353:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 358:	eb 23                	jmp    37d <stat+0x4c>
  r = fstat(fd, st);
 35a:	8b 45 0c             	mov    0xc(%ebp),%eax
 35d:	89 44 24 04          	mov    %eax,0x4(%esp)
 361:	8b 45 f4             	mov    -0xc(%ebp),%eax
 364:	89 04 24             	mov    %eax,(%esp)
 367:	e8 fc 00 00 00       	call   468 <fstat>
 36c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 36f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 372:	89 04 24             	mov    %eax,(%esp)
 375:	e8 be 00 00 00       	call   438 <close>
  return r;
 37a:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 37d:	c9                   	leave  
 37e:	c3                   	ret    

0000037f <atoi>:

int
atoi(const char *s)
{
 37f:	55                   	push   %ebp
 380:	89 e5                	mov    %esp,%ebp
 382:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 385:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 38c:	eb 23                	jmp    3b1 <atoi+0x32>
    n = n*10 + *s++ - '0';
 38e:	8b 55 fc             	mov    -0x4(%ebp),%edx
 391:	89 d0                	mov    %edx,%eax
 393:	c1 e0 02             	shl    $0x2,%eax
 396:	01 d0                	add    %edx,%eax
 398:	01 c0                	add    %eax,%eax
 39a:	89 c2                	mov    %eax,%edx
 39c:	8b 45 08             	mov    0x8(%ebp),%eax
 39f:	0f b6 00             	movzbl (%eax),%eax
 3a2:	0f be c0             	movsbl %al,%eax
 3a5:	01 d0                	add    %edx,%eax
 3a7:	83 e8 30             	sub    $0x30,%eax
 3aa:	89 45 fc             	mov    %eax,-0x4(%ebp)
 3ad:	83 45 08 01          	addl   $0x1,0x8(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 3b1:	8b 45 08             	mov    0x8(%ebp),%eax
 3b4:	0f b6 00             	movzbl (%eax),%eax
 3b7:	3c 2f                	cmp    $0x2f,%al
 3b9:	7e 0a                	jle    3c5 <atoi+0x46>
 3bb:	8b 45 08             	mov    0x8(%ebp),%eax
 3be:	0f b6 00             	movzbl (%eax),%eax
 3c1:	3c 39                	cmp    $0x39,%al
 3c3:	7e c9                	jle    38e <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 3c5:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 3c8:	c9                   	leave  
 3c9:	c3                   	ret    

000003ca <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 3ca:	55                   	push   %ebp
 3cb:	89 e5                	mov    %esp,%ebp
 3cd:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 3d0:	8b 45 08             	mov    0x8(%ebp),%eax
 3d3:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 3d6:	8b 45 0c             	mov    0xc(%ebp),%eax
 3d9:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 3dc:	eb 13                	jmp    3f1 <memmove+0x27>
    *dst++ = *src++;
 3de:	8b 45 f8             	mov    -0x8(%ebp),%eax
 3e1:	0f b6 10             	movzbl (%eax),%edx
 3e4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 3e7:	88 10                	mov    %dl,(%eax)
 3e9:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 3ed:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 3f1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 3f5:	0f 9f c0             	setg   %al
 3f8:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 3fc:	84 c0                	test   %al,%al
 3fe:	75 de                	jne    3de <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 400:	8b 45 08             	mov    0x8(%ebp),%eax
}
 403:	c9                   	leave  
 404:	c3                   	ret    
 405:	90                   	nop
 406:	90                   	nop
 407:	90                   	nop

00000408 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 408:	b8 01 00 00 00       	mov    $0x1,%eax
 40d:	cd 40                	int    $0x40
 40f:	c3                   	ret    

00000410 <exit>:
SYSCALL(exit)
 410:	b8 02 00 00 00       	mov    $0x2,%eax
 415:	cd 40                	int    $0x40
 417:	c3                   	ret    

00000418 <wait>:
SYSCALL(wait)
 418:	b8 03 00 00 00       	mov    $0x3,%eax
 41d:	cd 40                	int    $0x40
 41f:	c3                   	ret    

00000420 <pipe>:
SYSCALL(pipe)
 420:	b8 04 00 00 00       	mov    $0x4,%eax
 425:	cd 40                	int    $0x40
 427:	c3                   	ret    

00000428 <read>:
SYSCALL(read)
 428:	b8 05 00 00 00       	mov    $0x5,%eax
 42d:	cd 40                	int    $0x40
 42f:	c3                   	ret    

00000430 <write>:
SYSCALL(write)
 430:	b8 10 00 00 00       	mov    $0x10,%eax
 435:	cd 40                	int    $0x40
 437:	c3                   	ret    

00000438 <close>:
SYSCALL(close)
 438:	b8 15 00 00 00       	mov    $0x15,%eax
 43d:	cd 40                	int    $0x40
 43f:	c3                   	ret    

00000440 <kill>:
SYSCALL(kill)
 440:	b8 06 00 00 00       	mov    $0x6,%eax
 445:	cd 40                	int    $0x40
 447:	c3                   	ret    

00000448 <exec>:
SYSCALL(exec)
 448:	b8 07 00 00 00       	mov    $0x7,%eax
 44d:	cd 40                	int    $0x40
 44f:	c3                   	ret    

00000450 <open>:
SYSCALL(open)
 450:	b8 0f 00 00 00       	mov    $0xf,%eax
 455:	cd 40                	int    $0x40
 457:	c3                   	ret    

00000458 <mknod>:
SYSCALL(mknod)
 458:	b8 11 00 00 00       	mov    $0x11,%eax
 45d:	cd 40                	int    $0x40
 45f:	c3                   	ret    

00000460 <unlink>:
SYSCALL(unlink)
 460:	b8 12 00 00 00       	mov    $0x12,%eax
 465:	cd 40                	int    $0x40
 467:	c3                   	ret    

00000468 <fstat>:
SYSCALL(fstat)
 468:	b8 08 00 00 00       	mov    $0x8,%eax
 46d:	cd 40                	int    $0x40
 46f:	c3                   	ret    

00000470 <link>:
SYSCALL(link)
 470:	b8 13 00 00 00       	mov    $0x13,%eax
 475:	cd 40                	int    $0x40
 477:	c3                   	ret    

00000478 <mkdir>:
SYSCALL(mkdir)
 478:	b8 14 00 00 00       	mov    $0x14,%eax
 47d:	cd 40                	int    $0x40
 47f:	c3                   	ret    

00000480 <chdir>:
SYSCALL(chdir)
 480:	b8 09 00 00 00       	mov    $0x9,%eax
 485:	cd 40                	int    $0x40
 487:	c3                   	ret    

00000488 <dup>:
SYSCALL(dup)
 488:	b8 0a 00 00 00       	mov    $0xa,%eax
 48d:	cd 40                	int    $0x40
 48f:	c3                   	ret    

00000490 <getpid>:
SYSCALL(getpid)
 490:	b8 0b 00 00 00       	mov    $0xb,%eax
 495:	cd 40                	int    $0x40
 497:	c3                   	ret    

00000498 <sbrk>:
SYSCALL(sbrk)
 498:	b8 0c 00 00 00       	mov    $0xc,%eax
 49d:	cd 40                	int    $0x40
 49f:	c3                   	ret    

000004a0 <sleep>:
SYSCALL(sleep)
 4a0:	b8 0d 00 00 00       	mov    $0xd,%eax
 4a5:	cd 40                	int    $0x40
 4a7:	c3                   	ret    

000004a8 <uptime>:
SYSCALL(uptime)
 4a8:	b8 0e 00 00 00       	mov    $0xe,%eax
 4ad:	cd 40                	int    $0x40
 4af:	c3                   	ret    

000004b0 <waitpid>:
SYSCALL(waitpid)
 4b0:	b8 16 00 00 00       	mov    $0x16,%eax
 4b5:	cd 40                	int    $0x40
 4b7:	c3                   	ret    

000004b8 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 4b8:	55                   	push   %ebp
 4b9:	89 e5                	mov    %esp,%ebp
 4bb:	83 ec 28             	sub    $0x28,%esp
 4be:	8b 45 0c             	mov    0xc(%ebp),%eax
 4c1:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 4c4:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 4cb:	00 
 4cc:	8d 45 f4             	lea    -0xc(%ebp),%eax
 4cf:	89 44 24 04          	mov    %eax,0x4(%esp)
 4d3:	8b 45 08             	mov    0x8(%ebp),%eax
 4d6:	89 04 24             	mov    %eax,(%esp)
 4d9:	e8 52 ff ff ff       	call   430 <write>
}
 4de:	c9                   	leave  
 4df:	c3                   	ret    

000004e0 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 4e0:	55                   	push   %ebp
 4e1:	89 e5                	mov    %esp,%ebp
 4e3:	83 ec 48             	sub    $0x48,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 4e6:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 4ed:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 4f1:	74 17                	je     50a <printint+0x2a>
 4f3:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 4f7:	79 11                	jns    50a <printint+0x2a>
    neg = 1;
 4f9:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 500:	8b 45 0c             	mov    0xc(%ebp),%eax
 503:	f7 d8                	neg    %eax
 505:	89 45 ec             	mov    %eax,-0x14(%ebp)
 508:	eb 06                	jmp    510 <printint+0x30>
  } else {
    x = xx;
 50a:	8b 45 0c             	mov    0xc(%ebp),%eax
 50d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 510:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 517:	8b 4d 10             	mov    0x10(%ebp),%ecx
 51a:	8b 45 ec             	mov    -0x14(%ebp),%eax
 51d:	ba 00 00 00 00       	mov    $0x0,%edx
 522:	f7 f1                	div    %ecx
 524:	89 d0                	mov    %edx,%eax
 526:	0f b6 90 90 0c 00 00 	movzbl 0xc90(%eax),%edx
 52d:	8d 45 dc             	lea    -0x24(%ebp),%eax
 530:	03 45 f4             	add    -0xc(%ebp),%eax
 533:	88 10                	mov    %dl,(%eax)
 535:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  }while((x /= base) != 0);
 539:	8b 55 10             	mov    0x10(%ebp),%edx
 53c:	89 55 d4             	mov    %edx,-0x2c(%ebp)
 53f:	8b 45 ec             	mov    -0x14(%ebp),%eax
 542:	ba 00 00 00 00       	mov    $0x0,%edx
 547:	f7 75 d4             	divl   -0x2c(%ebp)
 54a:	89 45 ec             	mov    %eax,-0x14(%ebp)
 54d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 551:	75 c4                	jne    517 <printint+0x37>
  if(neg)
 553:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 557:	74 2a                	je     583 <printint+0xa3>
    buf[i++] = '-';
 559:	8d 45 dc             	lea    -0x24(%ebp),%eax
 55c:	03 45 f4             	add    -0xc(%ebp),%eax
 55f:	c6 00 2d             	movb   $0x2d,(%eax)
 562:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

  while(--i >= 0)
 566:	eb 1b                	jmp    583 <printint+0xa3>
    putc(fd, buf[i]);
 568:	8d 45 dc             	lea    -0x24(%ebp),%eax
 56b:	03 45 f4             	add    -0xc(%ebp),%eax
 56e:	0f b6 00             	movzbl (%eax),%eax
 571:	0f be c0             	movsbl %al,%eax
 574:	89 44 24 04          	mov    %eax,0x4(%esp)
 578:	8b 45 08             	mov    0x8(%ebp),%eax
 57b:	89 04 24             	mov    %eax,(%esp)
 57e:	e8 35 ff ff ff       	call   4b8 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 583:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 587:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 58b:	79 db                	jns    568 <printint+0x88>
    putc(fd, buf[i]);
}
 58d:	c9                   	leave  
 58e:	c3                   	ret    

0000058f <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 58f:	55                   	push   %ebp
 590:	89 e5                	mov    %esp,%ebp
 592:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 595:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 59c:	8d 45 0c             	lea    0xc(%ebp),%eax
 59f:	83 c0 04             	add    $0x4,%eax
 5a2:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 5a5:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 5ac:	e9 7d 01 00 00       	jmp    72e <printf+0x19f>
    c = fmt[i] & 0xff;
 5b1:	8b 55 0c             	mov    0xc(%ebp),%edx
 5b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
 5b7:	01 d0                	add    %edx,%eax
 5b9:	0f b6 00             	movzbl (%eax),%eax
 5bc:	0f be c0             	movsbl %al,%eax
 5bf:	25 ff 00 00 00       	and    $0xff,%eax
 5c4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 5c7:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 5cb:	75 2c                	jne    5f9 <printf+0x6a>
      if(c == '%'){
 5cd:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 5d1:	75 0c                	jne    5df <printf+0x50>
        state = '%';
 5d3:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 5da:	e9 4b 01 00 00       	jmp    72a <printf+0x19b>
      } else {
        putc(fd, c);
 5df:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 5e2:	0f be c0             	movsbl %al,%eax
 5e5:	89 44 24 04          	mov    %eax,0x4(%esp)
 5e9:	8b 45 08             	mov    0x8(%ebp),%eax
 5ec:	89 04 24             	mov    %eax,(%esp)
 5ef:	e8 c4 fe ff ff       	call   4b8 <putc>
 5f4:	e9 31 01 00 00       	jmp    72a <printf+0x19b>
      }
    } else if(state == '%'){
 5f9:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 5fd:	0f 85 27 01 00 00    	jne    72a <printf+0x19b>
      if(c == 'd'){
 603:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 607:	75 2d                	jne    636 <printf+0xa7>
        printint(fd, *ap, 10, 1);
 609:	8b 45 e8             	mov    -0x18(%ebp),%eax
 60c:	8b 00                	mov    (%eax),%eax
 60e:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 615:	00 
 616:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 61d:	00 
 61e:	89 44 24 04          	mov    %eax,0x4(%esp)
 622:	8b 45 08             	mov    0x8(%ebp),%eax
 625:	89 04 24             	mov    %eax,(%esp)
 628:	e8 b3 fe ff ff       	call   4e0 <printint>
        ap++;
 62d:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 631:	e9 ed 00 00 00       	jmp    723 <printf+0x194>
      } else if(c == 'x' || c == 'p'){
 636:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 63a:	74 06                	je     642 <printf+0xb3>
 63c:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 640:	75 2d                	jne    66f <printf+0xe0>
        printint(fd, *ap, 16, 0);
 642:	8b 45 e8             	mov    -0x18(%ebp),%eax
 645:	8b 00                	mov    (%eax),%eax
 647:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 64e:	00 
 64f:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 656:	00 
 657:	89 44 24 04          	mov    %eax,0x4(%esp)
 65b:	8b 45 08             	mov    0x8(%ebp),%eax
 65e:	89 04 24             	mov    %eax,(%esp)
 661:	e8 7a fe ff ff       	call   4e0 <printint>
        ap++;
 666:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 66a:	e9 b4 00 00 00       	jmp    723 <printf+0x194>
      } else if(c == 's'){
 66f:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 673:	75 46                	jne    6bb <printf+0x12c>
        s = (char*)*ap;
 675:	8b 45 e8             	mov    -0x18(%ebp),%eax
 678:	8b 00                	mov    (%eax),%eax
 67a:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 67d:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 681:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 685:	75 27                	jne    6ae <printf+0x11f>
          s = "(null)";
 687:	c7 45 f4 0b 0a 00 00 	movl   $0xa0b,-0xc(%ebp)
        while(*s != 0){
 68e:	eb 1e                	jmp    6ae <printf+0x11f>
          putc(fd, *s);
 690:	8b 45 f4             	mov    -0xc(%ebp),%eax
 693:	0f b6 00             	movzbl (%eax),%eax
 696:	0f be c0             	movsbl %al,%eax
 699:	89 44 24 04          	mov    %eax,0x4(%esp)
 69d:	8b 45 08             	mov    0x8(%ebp),%eax
 6a0:	89 04 24             	mov    %eax,(%esp)
 6a3:	e8 10 fe ff ff       	call   4b8 <putc>
          s++;
 6a8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 6ac:	eb 01                	jmp    6af <printf+0x120>
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 6ae:	90                   	nop
 6af:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6b2:	0f b6 00             	movzbl (%eax),%eax
 6b5:	84 c0                	test   %al,%al
 6b7:	75 d7                	jne    690 <printf+0x101>
 6b9:	eb 68                	jmp    723 <printf+0x194>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 6bb:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 6bf:	75 1d                	jne    6de <printf+0x14f>
        putc(fd, *ap);
 6c1:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6c4:	8b 00                	mov    (%eax),%eax
 6c6:	0f be c0             	movsbl %al,%eax
 6c9:	89 44 24 04          	mov    %eax,0x4(%esp)
 6cd:	8b 45 08             	mov    0x8(%ebp),%eax
 6d0:	89 04 24             	mov    %eax,(%esp)
 6d3:	e8 e0 fd ff ff       	call   4b8 <putc>
        ap++;
 6d8:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 6dc:	eb 45                	jmp    723 <printf+0x194>
      } else if(c == '%'){
 6de:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 6e2:	75 17                	jne    6fb <printf+0x16c>
        putc(fd, c);
 6e4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 6e7:	0f be c0             	movsbl %al,%eax
 6ea:	89 44 24 04          	mov    %eax,0x4(%esp)
 6ee:	8b 45 08             	mov    0x8(%ebp),%eax
 6f1:	89 04 24             	mov    %eax,(%esp)
 6f4:	e8 bf fd ff ff       	call   4b8 <putc>
 6f9:	eb 28                	jmp    723 <printf+0x194>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 6fb:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 702:	00 
 703:	8b 45 08             	mov    0x8(%ebp),%eax
 706:	89 04 24             	mov    %eax,(%esp)
 709:	e8 aa fd ff ff       	call   4b8 <putc>
        putc(fd, c);
 70e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 711:	0f be c0             	movsbl %al,%eax
 714:	89 44 24 04          	mov    %eax,0x4(%esp)
 718:	8b 45 08             	mov    0x8(%ebp),%eax
 71b:	89 04 24             	mov    %eax,(%esp)
 71e:	e8 95 fd ff ff       	call   4b8 <putc>
      }
      state = 0;
 723:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 72a:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 72e:	8b 55 0c             	mov    0xc(%ebp),%edx
 731:	8b 45 f0             	mov    -0x10(%ebp),%eax
 734:	01 d0                	add    %edx,%eax
 736:	0f b6 00             	movzbl (%eax),%eax
 739:	84 c0                	test   %al,%al
 73b:	0f 85 70 fe ff ff    	jne    5b1 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 741:	c9                   	leave  
 742:	c3                   	ret    
 743:	90                   	nop

00000744 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 744:	55                   	push   %ebp
 745:	89 e5                	mov    %esp,%ebp
 747:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 74a:	8b 45 08             	mov    0x8(%ebp),%eax
 74d:	83 e8 08             	sub    $0x8,%eax
 750:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 753:	a1 ac 0c 00 00       	mov    0xcac,%eax
 758:	89 45 fc             	mov    %eax,-0x4(%ebp)
 75b:	eb 24                	jmp    781 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 75d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 760:	8b 00                	mov    (%eax),%eax
 762:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 765:	77 12                	ja     779 <free+0x35>
 767:	8b 45 f8             	mov    -0x8(%ebp),%eax
 76a:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 76d:	77 24                	ja     793 <free+0x4f>
 76f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 772:	8b 00                	mov    (%eax),%eax
 774:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 777:	77 1a                	ja     793 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 779:	8b 45 fc             	mov    -0x4(%ebp),%eax
 77c:	8b 00                	mov    (%eax),%eax
 77e:	89 45 fc             	mov    %eax,-0x4(%ebp)
 781:	8b 45 f8             	mov    -0x8(%ebp),%eax
 784:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 787:	76 d4                	jbe    75d <free+0x19>
 789:	8b 45 fc             	mov    -0x4(%ebp),%eax
 78c:	8b 00                	mov    (%eax),%eax
 78e:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 791:	76 ca                	jbe    75d <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 793:	8b 45 f8             	mov    -0x8(%ebp),%eax
 796:	8b 40 04             	mov    0x4(%eax),%eax
 799:	c1 e0 03             	shl    $0x3,%eax
 79c:	89 c2                	mov    %eax,%edx
 79e:	03 55 f8             	add    -0x8(%ebp),%edx
 7a1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7a4:	8b 00                	mov    (%eax),%eax
 7a6:	39 c2                	cmp    %eax,%edx
 7a8:	75 24                	jne    7ce <free+0x8a>
    bp->s.size += p->s.ptr->s.size;
 7aa:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7ad:	8b 50 04             	mov    0x4(%eax),%edx
 7b0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7b3:	8b 00                	mov    (%eax),%eax
 7b5:	8b 40 04             	mov    0x4(%eax),%eax
 7b8:	01 c2                	add    %eax,%edx
 7ba:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7bd:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 7c0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7c3:	8b 00                	mov    (%eax),%eax
 7c5:	8b 10                	mov    (%eax),%edx
 7c7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7ca:	89 10                	mov    %edx,(%eax)
 7cc:	eb 0a                	jmp    7d8 <free+0x94>
  } else
    bp->s.ptr = p->s.ptr;
 7ce:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7d1:	8b 10                	mov    (%eax),%edx
 7d3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7d6:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 7d8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7db:	8b 40 04             	mov    0x4(%eax),%eax
 7de:	c1 e0 03             	shl    $0x3,%eax
 7e1:	03 45 fc             	add    -0x4(%ebp),%eax
 7e4:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 7e7:	75 20                	jne    809 <free+0xc5>
    p->s.size += bp->s.size;
 7e9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7ec:	8b 50 04             	mov    0x4(%eax),%edx
 7ef:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7f2:	8b 40 04             	mov    0x4(%eax),%eax
 7f5:	01 c2                	add    %eax,%edx
 7f7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7fa:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 7fd:	8b 45 f8             	mov    -0x8(%ebp),%eax
 800:	8b 10                	mov    (%eax),%edx
 802:	8b 45 fc             	mov    -0x4(%ebp),%eax
 805:	89 10                	mov    %edx,(%eax)
 807:	eb 08                	jmp    811 <free+0xcd>
  } else
    p->s.ptr = bp;
 809:	8b 45 fc             	mov    -0x4(%ebp),%eax
 80c:	8b 55 f8             	mov    -0x8(%ebp),%edx
 80f:	89 10                	mov    %edx,(%eax)
  freep = p;
 811:	8b 45 fc             	mov    -0x4(%ebp),%eax
 814:	a3 ac 0c 00 00       	mov    %eax,0xcac
}
 819:	c9                   	leave  
 81a:	c3                   	ret    

0000081b <morecore>:

static Header*
morecore(uint nu)
{
 81b:	55                   	push   %ebp
 81c:	89 e5                	mov    %esp,%ebp
 81e:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 821:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 828:	77 07                	ja     831 <morecore+0x16>
    nu = 4096;
 82a:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 831:	8b 45 08             	mov    0x8(%ebp),%eax
 834:	c1 e0 03             	shl    $0x3,%eax
 837:	89 04 24             	mov    %eax,(%esp)
 83a:	e8 59 fc ff ff       	call   498 <sbrk>
 83f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 842:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 846:	75 07                	jne    84f <morecore+0x34>
    return 0;
 848:	b8 00 00 00 00       	mov    $0x0,%eax
 84d:	eb 22                	jmp    871 <morecore+0x56>
  hp = (Header*)p;
 84f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 852:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 855:	8b 45 f0             	mov    -0x10(%ebp),%eax
 858:	8b 55 08             	mov    0x8(%ebp),%edx
 85b:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 85e:	8b 45 f0             	mov    -0x10(%ebp),%eax
 861:	83 c0 08             	add    $0x8,%eax
 864:	89 04 24             	mov    %eax,(%esp)
 867:	e8 d8 fe ff ff       	call   744 <free>
  return freep;
 86c:	a1 ac 0c 00 00       	mov    0xcac,%eax
}
 871:	c9                   	leave  
 872:	c3                   	ret    

00000873 <malloc>:

void*
malloc(uint nbytes)
{
 873:	55                   	push   %ebp
 874:	89 e5                	mov    %esp,%ebp
 876:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 879:	8b 45 08             	mov    0x8(%ebp),%eax
 87c:	83 c0 07             	add    $0x7,%eax
 87f:	c1 e8 03             	shr    $0x3,%eax
 882:	83 c0 01             	add    $0x1,%eax
 885:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 888:	a1 ac 0c 00 00       	mov    0xcac,%eax
 88d:	89 45 f0             	mov    %eax,-0x10(%ebp)
 890:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 894:	75 23                	jne    8b9 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 896:	c7 45 f0 a4 0c 00 00 	movl   $0xca4,-0x10(%ebp)
 89d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8a0:	a3 ac 0c 00 00       	mov    %eax,0xcac
 8a5:	a1 ac 0c 00 00       	mov    0xcac,%eax
 8aa:	a3 a4 0c 00 00       	mov    %eax,0xca4
    base.s.size = 0;
 8af:	c7 05 a8 0c 00 00 00 	movl   $0x0,0xca8
 8b6:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8bc:	8b 00                	mov    (%eax),%eax
 8be:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 8c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8c4:	8b 40 04             	mov    0x4(%eax),%eax
 8c7:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 8ca:	72 4d                	jb     919 <malloc+0xa6>
      if(p->s.size == nunits)
 8cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8cf:	8b 40 04             	mov    0x4(%eax),%eax
 8d2:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 8d5:	75 0c                	jne    8e3 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 8d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8da:	8b 10                	mov    (%eax),%edx
 8dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8df:	89 10                	mov    %edx,(%eax)
 8e1:	eb 26                	jmp    909 <malloc+0x96>
      else {
        p->s.size -= nunits;
 8e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8e6:	8b 40 04             	mov    0x4(%eax),%eax
 8e9:	89 c2                	mov    %eax,%edx
 8eb:	2b 55 ec             	sub    -0x14(%ebp),%edx
 8ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8f1:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 8f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8f7:	8b 40 04             	mov    0x4(%eax),%eax
 8fa:	c1 e0 03             	shl    $0x3,%eax
 8fd:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 900:	8b 45 f4             	mov    -0xc(%ebp),%eax
 903:	8b 55 ec             	mov    -0x14(%ebp),%edx
 906:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 909:	8b 45 f0             	mov    -0x10(%ebp),%eax
 90c:	a3 ac 0c 00 00       	mov    %eax,0xcac
      return (void*)(p + 1);
 911:	8b 45 f4             	mov    -0xc(%ebp),%eax
 914:	83 c0 08             	add    $0x8,%eax
 917:	eb 38                	jmp    951 <malloc+0xde>
    }
    if(p == freep)
 919:	a1 ac 0c 00 00       	mov    0xcac,%eax
 91e:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 921:	75 1b                	jne    93e <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 923:	8b 45 ec             	mov    -0x14(%ebp),%eax
 926:	89 04 24             	mov    %eax,(%esp)
 929:	e8 ed fe ff ff       	call   81b <morecore>
 92e:	89 45 f4             	mov    %eax,-0xc(%ebp)
 931:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 935:	75 07                	jne    93e <malloc+0xcb>
        return 0;
 937:	b8 00 00 00 00       	mov    $0x0,%eax
 93c:	eb 13                	jmp    951 <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 93e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 941:	89 45 f0             	mov    %eax,-0x10(%ebp)
 944:	8b 45 f4             	mov    -0xc(%ebp),%eax
 947:	8b 00                	mov    (%eax),%eax
 949:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 94c:	e9 70 ff ff ff       	jmp    8c1 <malloc+0x4e>
}
 951:	c9                   	leave  
 952:	c3                   	ret    
