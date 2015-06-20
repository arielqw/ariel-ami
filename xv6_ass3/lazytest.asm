
_lazytest:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:

#define PAGE_SIZE 4096

int
main(int argc, char *argv[])
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 e4 f0             	and    $0xfffffff0,%esp
   6:	83 ec 20             	sub    $0x20,%esp
	//int i;
	int* arr = (int*)sbrk(PAGE_SIZE*101);	//size of array is 103424
   9:	c7 04 24 00 50 06 00 	movl   $0x65000,(%esp)
  10:	e8 4f 03 00 00       	call   364 <sbrk>
  15:	89 44 24 1c          	mov    %eax,0x1c(%esp)
//	for (i = 0; i < 103424; ++i) {
//		arr[i]=1;
//	}

	//touch page 0
	arr[PAGE_SIZE/4*0 + 15] 	= 1;
  19:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  1d:	83 c0 3c             	add    $0x3c,%eax
  20:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
	arr[PAGE_SIZE/4*0 + 900] 	= 1;
  26:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  2a:	05 10 0e 00 00       	add    $0xe10,%eax
  2f:	c7 00 01 00 00 00    	movl   $0x1,(%eax)



	//touch page 14
	arr[PAGE_SIZE/4*14 + 152] = 1;
  35:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  39:	05 60 e2 00 00       	add    $0xe260,%eax
  3e:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
	arr[PAGE_SIZE/4*14 + 533] = 1;
  44:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  48:	05 54 e8 00 00       	add    $0xe854,%eax
  4d:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
	arr[PAGE_SIZE/4*14 + 700] = 1;
  53:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  57:	05 f0 ea 00 00       	add    $0xeaf0,%eax
  5c:	c7 00 01 00 00 00    	movl   $0x1,(%eax)

	//touch page 37
	arr[PAGE_SIZE/4*37 + 566] = 1;
  62:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  66:	05 d8 58 02 00       	add    $0x258d8,%eax
  6b:	c7 00 01 00 00 00    	movl   $0x1,(%eax)



	exit();
  71:	e8 66 02 00 00       	call   2dc <exit>
  76:	90                   	nop
  77:	90                   	nop

00000078 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
  78:	55                   	push   %ebp
  79:	89 e5                	mov    %esp,%ebp
  7b:	57                   	push   %edi
  7c:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
  7d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80:	8b 55 10             	mov    0x10(%ebp),%edx
  83:	8b 45 0c             	mov    0xc(%ebp),%eax
  86:	89 cb                	mov    %ecx,%ebx
  88:	89 df                	mov    %ebx,%edi
  8a:	89 d1                	mov    %edx,%ecx
  8c:	fc                   	cld    
  8d:	f3 aa                	rep stos %al,%es:(%edi)
  8f:	89 ca                	mov    %ecx,%edx
  91:	89 fb                	mov    %edi,%ebx
  93:	89 5d 08             	mov    %ebx,0x8(%ebp)
  96:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
  99:	5b                   	pop    %ebx
  9a:	5f                   	pop    %edi
  9b:	5d                   	pop    %ebp
  9c:	c3                   	ret    

0000009d <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
  9d:	55                   	push   %ebp
  9e:	89 e5                	mov    %esp,%ebp
  a0:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
  a3:	8b 45 08             	mov    0x8(%ebp),%eax
  a6:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
  a9:	90                   	nop
  aa:	8b 45 0c             	mov    0xc(%ebp),%eax
  ad:	0f b6 10             	movzbl (%eax),%edx
  b0:	8b 45 08             	mov    0x8(%ebp),%eax
  b3:	88 10                	mov    %dl,(%eax)
  b5:	8b 45 08             	mov    0x8(%ebp),%eax
  b8:	0f b6 00             	movzbl (%eax),%eax
  bb:	84 c0                	test   %al,%al
  bd:	0f 95 c0             	setne  %al
  c0:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  c4:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  c8:	84 c0                	test   %al,%al
  ca:	75 de                	jne    aa <strcpy+0xd>
    ;
  return os;
  cc:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  cf:	c9                   	leave  
  d0:	c3                   	ret    

000000d1 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  d1:	55                   	push   %ebp
  d2:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
  d4:	eb 08                	jmp    de <strcmp+0xd>
    p++, q++;
  d6:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  da:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
  de:	8b 45 08             	mov    0x8(%ebp),%eax
  e1:	0f b6 00             	movzbl (%eax),%eax
  e4:	84 c0                	test   %al,%al
  e6:	74 10                	je     f8 <strcmp+0x27>
  e8:	8b 45 08             	mov    0x8(%ebp),%eax
  eb:	0f b6 10             	movzbl (%eax),%edx
  ee:	8b 45 0c             	mov    0xc(%ebp),%eax
  f1:	0f b6 00             	movzbl (%eax),%eax
  f4:	38 c2                	cmp    %al,%dl
  f6:	74 de                	je     d6 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
  f8:	8b 45 08             	mov    0x8(%ebp),%eax
  fb:	0f b6 00             	movzbl (%eax),%eax
  fe:	0f b6 d0             	movzbl %al,%edx
 101:	8b 45 0c             	mov    0xc(%ebp),%eax
 104:	0f b6 00             	movzbl (%eax),%eax
 107:	0f b6 c0             	movzbl %al,%eax
 10a:	89 d1                	mov    %edx,%ecx
 10c:	29 c1                	sub    %eax,%ecx
 10e:	89 c8                	mov    %ecx,%eax
}
 110:	5d                   	pop    %ebp
 111:	c3                   	ret    

00000112 <strlen>:

uint
strlen(char *s)
{
 112:	55                   	push   %ebp
 113:	89 e5                	mov    %esp,%ebp
 115:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 118:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 11f:	eb 04                	jmp    125 <strlen+0x13>
 121:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 125:	8b 45 fc             	mov    -0x4(%ebp),%eax
 128:	03 45 08             	add    0x8(%ebp),%eax
 12b:	0f b6 00             	movzbl (%eax),%eax
 12e:	84 c0                	test   %al,%al
 130:	75 ef                	jne    121 <strlen+0xf>
    ;
  return n;
 132:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 135:	c9                   	leave  
 136:	c3                   	ret    

00000137 <memset>:

void*
memset(void *dst, int c, uint n)
{
 137:	55                   	push   %ebp
 138:	89 e5                	mov    %esp,%ebp
 13a:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 13d:	8b 45 10             	mov    0x10(%ebp),%eax
 140:	89 44 24 08          	mov    %eax,0x8(%esp)
 144:	8b 45 0c             	mov    0xc(%ebp),%eax
 147:	89 44 24 04          	mov    %eax,0x4(%esp)
 14b:	8b 45 08             	mov    0x8(%ebp),%eax
 14e:	89 04 24             	mov    %eax,(%esp)
 151:	e8 22 ff ff ff       	call   78 <stosb>
  return dst;
 156:	8b 45 08             	mov    0x8(%ebp),%eax
}
 159:	c9                   	leave  
 15a:	c3                   	ret    

0000015b <strchr>:

char*
strchr(const char *s, char c)
{
 15b:	55                   	push   %ebp
 15c:	89 e5                	mov    %esp,%ebp
 15e:	83 ec 04             	sub    $0x4,%esp
 161:	8b 45 0c             	mov    0xc(%ebp),%eax
 164:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 167:	eb 14                	jmp    17d <strchr+0x22>
    if(*s == c)
 169:	8b 45 08             	mov    0x8(%ebp),%eax
 16c:	0f b6 00             	movzbl (%eax),%eax
 16f:	3a 45 fc             	cmp    -0x4(%ebp),%al
 172:	75 05                	jne    179 <strchr+0x1e>
      return (char*)s;
 174:	8b 45 08             	mov    0x8(%ebp),%eax
 177:	eb 13                	jmp    18c <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 179:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 17d:	8b 45 08             	mov    0x8(%ebp),%eax
 180:	0f b6 00             	movzbl (%eax),%eax
 183:	84 c0                	test   %al,%al
 185:	75 e2                	jne    169 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 187:	b8 00 00 00 00       	mov    $0x0,%eax
}
 18c:	c9                   	leave  
 18d:	c3                   	ret    

0000018e <gets>:

char*
gets(char *buf, int max)
{
 18e:	55                   	push   %ebp
 18f:	89 e5                	mov    %esp,%ebp
 191:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 194:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 19b:	eb 44                	jmp    1e1 <gets+0x53>
    cc = read(0, &c, 1);
 19d:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 1a4:	00 
 1a5:	8d 45 ef             	lea    -0x11(%ebp),%eax
 1a8:	89 44 24 04          	mov    %eax,0x4(%esp)
 1ac:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 1b3:	e8 3c 01 00 00       	call   2f4 <read>
 1b8:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 1bb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 1bf:	7e 2d                	jle    1ee <gets+0x60>
      break;
    buf[i++] = c;
 1c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1c4:	03 45 08             	add    0x8(%ebp),%eax
 1c7:	0f b6 55 ef          	movzbl -0x11(%ebp),%edx
 1cb:	88 10                	mov    %dl,(%eax)
 1cd:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(c == '\n' || c == '\r')
 1d1:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1d5:	3c 0a                	cmp    $0xa,%al
 1d7:	74 16                	je     1ef <gets+0x61>
 1d9:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1dd:	3c 0d                	cmp    $0xd,%al
 1df:	74 0e                	je     1ef <gets+0x61>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1e4:	83 c0 01             	add    $0x1,%eax
 1e7:	3b 45 0c             	cmp    0xc(%ebp),%eax
 1ea:	7c b1                	jl     19d <gets+0xf>
 1ec:	eb 01                	jmp    1ef <gets+0x61>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 1ee:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 1ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1f2:	03 45 08             	add    0x8(%ebp),%eax
 1f5:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 1f8:	8b 45 08             	mov    0x8(%ebp),%eax
}
 1fb:	c9                   	leave  
 1fc:	c3                   	ret    

000001fd <stat>:

int
stat(char *n, struct stat *st)
{
 1fd:	55                   	push   %ebp
 1fe:	89 e5                	mov    %esp,%ebp
 200:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 203:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 20a:	00 
 20b:	8b 45 08             	mov    0x8(%ebp),%eax
 20e:	89 04 24             	mov    %eax,(%esp)
 211:	e8 06 01 00 00       	call   31c <open>
 216:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 219:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 21d:	79 07                	jns    226 <stat+0x29>
    return -1;
 21f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 224:	eb 23                	jmp    249 <stat+0x4c>
  r = fstat(fd, st);
 226:	8b 45 0c             	mov    0xc(%ebp),%eax
 229:	89 44 24 04          	mov    %eax,0x4(%esp)
 22d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 230:	89 04 24             	mov    %eax,(%esp)
 233:	e8 fc 00 00 00       	call   334 <fstat>
 238:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 23b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 23e:	89 04 24             	mov    %eax,(%esp)
 241:	e8 be 00 00 00       	call   304 <close>
  return r;
 246:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 249:	c9                   	leave  
 24a:	c3                   	ret    

0000024b <atoi>:

int
atoi(const char *s)
{
 24b:	55                   	push   %ebp
 24c:	89 e5                	mov    %esp,%ebp
 24e:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 251:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 258:	eb 23                	jmp    27d <atoi+0x32>
    n = n*10 + *s++ - '0';
 25a:	8b 55 fc             	mov    -0x4(%ebp),%edx
 25d:	89 d0                	mov    %edx,%eax
 25f:	c1 e0 02             	shl    $0x2,%eax
 262:	01 d0                	add    %edx,%eax
 264:	01 c0                	add    %eax,%eax
 266:	89 c2                	mov    %eax,%edx
 268:	8b 45 08             	mov    0x8(%ebp),%eax
 26b:	0f b6 00             	movzbl (%eax),%eax
 26e:	0f be c0             	movsbl %al,%eax
 271:	01 d0                	add    %edx,%eax
 273:	83 e8 30             	sub    $0x30,%eax
 276:	89 45 fc             	mov    %eax,-0x4(%ebp)
 279:	83 45 08 01          	addl   $0x1,0x8(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 27d:	8b 45 08             	mov    0x8(%ebp),%eax
 280:	0f b6 00             	movzbl (%eax),%eax
 283:	3c 2f                	cmp    $0x2f,%al
 285:	7e 0a                	jle    291 <atoi+0x46>
 287:	8b 45 08             	mov    0x8(%ebp),%eax
 28a:	0f b6 00             	movzbl (%eax),%eax
 28d:	3c 39                	cmp    $0x39,%al
 28f:	7e c9                	jle    25a <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 291:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 294:	c9                   	leave  
 295:	c3                   	ret    

00000296 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 296:	55                   	push   %ebp
 297:	89 e5                	mov    %esp,%ebp
 299:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 29c:	8b 45 08             	mov    0x8(%ebp),%eax
 29f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 2a2:	8b 45 0c             	mov    0xc(%ebp),%eax
 2a5:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 2a8:	eb 13                	jmp    2bd <memmove+0x27>
    *dst++ = *src++;
 2aa:	8b 45 f8             	mov    -0x8(%ebp),%eax
 2ad:	0f b6 10             	movzbl (%eax),%edx
 2b0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 2b3:	88 10                	mov    %dl,(%eax)
 2b5:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 2b9:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 2bd:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 2c1:	0f 9f c0             	setg   %al
 2c4:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 2c8:	84 c0                	test   %al,%al
 2ca:	75 de                	jne    2aa <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 2cc:	8b 45 08             	mov    0x8(%ebp),%eax
}
 2cf:	c9                   	leave  
 2d0:	c3                   	ret    
 2d1:	90                   	nop
 2d2:	90                   	nop
 2d3:	90                   	nop

000002d4 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 2d4:	b8 01 00 00 00       	mov    $0x1,%eax
 2d9:	cd 40                	int    $0x40
 2db:	c3                   	ret    

000002dc <exit>:
SYSCALL(exit)
 2dc:	b8 02 00 00 00       	mov    $0x2,%eax
 2e1:	cd 40                	int    $0x40
 2e3:	c3                   	ret    

000002e4 <wait>:
SYSCALL(wait)
 2e4:	b8 03 00 00 00       	mov    $0x3,%eax
 2e9:	cd 40                	int    $0x40
 2eb:	c3                   	ret    

000002ec <pipe>:
SYSCALL(pipe)
 2ec:	b8 04 00 00 00       	mov    $0x4,%eax
 2f1:	cd 40                	int    $0x40
 2f3:	c3                   	ret    

000002f4 <read>:
SYSCALL(read)
 2f4:	b8 05 00 00 00       	mov    $0x5,%eax
 2f9:	cd 40                	int    $0x40
 2fb:	c3                   	ret    

000002fc <write>:
SYSCALL(write)
 2fc:	b8 10 00 00 00       	mov    $0x10,%eax
 301:	cd 40                	int    $0x40
 303:	c3                   	ret    

00000304 <close>:
SYSCALL(close)
 304:	b8 15 00 00 00       	mov    $0x15,%eax
 309:	cd 40                	int    $0x40
 30b:	c3                   	ret    

0000030c <kill>:
SYSCALL(kill)
 30c:	b8 06 00 00 00       	mov    $0x6,%eax
 311:	cd 40                	int    $0x40
 313:	c3                   	ret    

00000314 <exec>:
SYSCALL(exec)
 314:	b8 07 00 00 00       	mov    $0x7,%eax
 319:	cd 40                	int    $0x40
 31b:	c3                   	ret    

0000031c <open>:
SYSCALL(open)
 31c:	b8 0f 00 00 00       	mov    $0xf,%eax
 321:	cd 40                	int    $0x40
 323:	c3                   	ret    

00000324 <mknod>:
SYSCALL(mknod)
 324:	b8 11 00 00 00       	mov    $0x11,%eax
 329:	cd 40                	int    $0x40
 32b:	c3                   	ret    

0000032c <unlink>:
SYSCALL(unlink)
 32c:	b8 12 00 00 00       	mov    $0x12,%eax
 331:	cd 40                	int    $0x40
 333:	c3                   	ret    

00000334 <fstat>:
SYSCALL(fstat)
 334:	b8 08 00 00 00       	mov    $0x8,%eax
 339:	cd 40                	int    $0x40
 33b:	c3                   	ret    

0000033c <link>:
SYSCALL(link)
 33c:	b8 13 00 00 00       	mov    $0x13,%eax
 341:	cd 40                	int    $0x40
 343:	c3                   	ret    

00000344 <mkdir>:
SYSCALL(mkdir)
 344:	b8 14 00 00 00       	mov    $0x14,%eax
 349:	cd 40                	int    $0x40
 34b:	c3                   	ret    

0000034c <chdir>:
SYSCALL(chdir)
 34c:	b8 09 00 00 00       	mov    $0x9,%eax
 351:	cd 40                	int    $0x40
 353:	c3                   	ret    

00000354 <dup>:
SYSCALL(dup)
 354:	b8 0a 00 00 00       	mov    $0xa,%eax
 359:	cd 40                	int    $0x40
 35b:	c3                   	ret    

0000035c <getpid>:
SYSCALL(getpid)
 35c:	b8 0b 00 00 00       	mov    $0xb,%eax
 361:	cd 40                	int    $0x40
 363:	c3                   	ret    

00000364 <sbrk>:
SYSCALL(sbrk)
 364:	b8 0c 00 00 00       	mov    $0xc,%eax
 369:	cd 40                	int    $0x40
 36b:	c3                   	ret    

0000036c <sleep>:
SYSCALL(sleep)
 36c:	b8 0d 00 00 00       	mov    $0xd,%eax
 371:	cd 40                	int    $0x40
 373:	c3                   	ret    

00000374 <uptime>:
SYSCALL(uptime)
 374:	b8 0e 00 00 00       	mov    $0xe,%eax
 379:	cd 40                	int    $0x40
 37b:	c3                   	ret    

0000037c <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 37c:	55                   	push   %ebp
 37d:	89 e5                	mov    %esp,%ebp
 37f:	83 ec 28             	sub    $0x28,%esp
 382:	8b 45 0c             	mov    0xc(%ebp),%eax
 385:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 388:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 38f:	00 
 390:	8d 45 f4             	lea    -0xc(%ebp),%eax
 393:	89 44 24 04          	mov    %eax,0x4(%esp)
 397:	8b 45 08             	mov    0x8(%ebp),%eax
 39a:	89 04 24             	mov    %eax,(%esp)
 39d:	e8 5a ff ff ff       	call   2fc <write>
}
 3a2:	c9                   	leave  
 3a3:	c3                   	ret    

000003a4 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 3a4:	55                   	push   %ebp
 3a5:	89 e5                	mov    %esp,%ebp
 3a7:	83 ec 48             	sub    $0x48,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 3aa:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 3b1:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 3b5:	74 17                	je     3ce <printint+0x2a>
 3b7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 3bb:	79 11                	jns    3ce <printint+0x2a>
    neg = 1;
 3bd:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 3c4:	8b 45 0c             	mov    0xc(%ebp),%eax
 3c7:	f7 d8                	neg    %eax
 3c9:	89 45 ec             	mov    %eax,-0x14(%ebp)
 3cc:	eb 06                	jmp    3d4 <printint+0x30>
  } else {
    x = xx;
 3ce:	8b 45 0c             	mov    0xc(%ebp),%eax
 3d1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 3d4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 3db:	8b 4d 10             	mov    0x10(%ebp),%ecx
 3de:	8b 45 ec             	mov    -0x14(%ebp),%eax
 3e1:	ba 00 00 00 00       	mov    $0x0,%edx
 3e6:	f7 f1                	div    %ecx
 3e8:	89 d0                	mov    %edx,%eax
 3ea:	0f b6 90 5c 0a 00 00 	movzbl 0xa5c(%eax),%edx
 3f1:	8d 45 dc             	lea    -0x24(%ebp),%eax
 3f4:	03 45 f4             	add    -0xc(%ebp),%eax
 3f7:	88 10                	mov    %dl,(%eax)
 3f9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  }while((x /= base) != 0);
 3fd:	8b 55 10             	mov    0x10(%ebp),%edx
 400:	89 55 d4             	mov    %edx,-0x2c(%ebp)
 403:	8b 45 ec             	mov    -0x14(%ebp),%eax
 406:	ba 00 00 00 00       	mov    $0x0,%edx
 40b:	f7 75 d4             	divl   -0x2c(%ebp)
 40e:	89 45 ec             	mov    %eax,-0x14(%ebp)
 411:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 415:	75 c4                	jne    3db <printint+0x37>
  if(neg)
 417:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 41b:	74 2a                	je     447 <printint+0xa3>
    buf[i++] = '-';
 41d:	8d 45 dc             	lea    -0x24(%ebp),%eax
 420:	03 45 f4             	add    -0xc(%ebp),%eax
 423:	c6 00 2d             	movb   $0x2d,(%eax)
 426:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

  while(--i >= 0)
 42a:	eb 1b                	jmp    447 <printint+0xa3>
    putc(fd, buf[i]);
 42c:	8d 45 dc             	lea    -0x24(%ebp),%eax
 42f:	03 45 f4             	add    -0xc(%ebp),%eax
 432:	0f b6 00             	movzbl (%eax),%eax
 435:	0f be c0             	movsbl %al,%eax
 438:	89 44 24 04          	mov    %eax,0x4(%esp)
 43c:	8b 45 08             	mov    0x8(%ebp),%eax
 43f:	89 04 24             	mov    %eax,(%esp)
 442:	e8 35 ff ff ff       	call   37c <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 447:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 44b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 44f:	79 db                	jns    42c <printint+0x88>
    putc(fd, buf[i]);
}
 451:	c9                   	leave  
 452:	c3                   	ret    

00000453 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 453:	55                   	push   %ebp
 454:	89 e5                	mov    %esp,%ebp
 456:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 459:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 460:	8d 45 0c             	lea    0xc(%ebp),%eax
 463:	83 c0 04             	add    $0x4,%eax
 466:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 469:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 470:	e9 7d 01 00 00       	jmp    5f2 <printf+0x19f>
    c = fmt[i] & 0xff;
 475:	8b 55 0c             	mov    0xc(%ebp),%edx
 478:	8b 45 f0             	mov    -0x10(%ebp),%eax
 47b:	01 d0                	add    %edx,%eax
 47d:	0f b6 00             	movzbl (%eax),%eax
 480:	0f be c0             	movsbl %al,%eax
 483:	25 ff 00 00 00       	and    $0xff,%eax
 488:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 48b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 48f:	75 2c                	jne    4bd <printf+0x6a>
      if(c == '%'){
 491:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 495:	75 0c                	jne    4a3 <printf+0x50>
        state = '%';
 497:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 49e:	e9 4b 01 00 00       	jmp    5ee <printf+0x19b>
      } else {
        putc(fd, c);
 4a3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 4a6:	0f be c0             	movsbl %al,%eax
 4a9:	89 44 24 04          	mov    %eax,0x4(%esp)
 4ad:	8b 45 08             	mov    0x8(%ebp),%eax
 4b0:	89 04 24             	mov    %eax,(%esp)
 4b3:	e8 c4 fe ff ff       	call   37c <putc>
 4b8:	e9 31 01 00 00       	jmp    5ee <printf+0x19b>
      }
    } else if(state == '%'){
 4bd:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 4c1:	0f 85 27 01 00 00    	jne    5ee <printf+0x19b>
      if(c == 'd'){
 4c7:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 4cb:	75 2d                	jne    4fa <printf+0xa7>
        printint(fd, *ap, 10, 1);
 4cd:	8b 45 e8             	mov    -0x18(%ebp),%eax
 4d0:	8b 00                	mov    (%eax),%eax
 4d2:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 4d9:	00 
 4da:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 4e1:	00 
 4e2:	89 44 24 04          	mov    %eax,0x4(%esp)
 4e6:	8b 45 08             	mov    0x8(%ebp),%eax
 4e9:	89 04 24             	mov    %eax,(%esp)
 4ec:	e8 b3 fe ff ff       	call   3a4 <printint>
        ap++;
 4f1:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 4f5:	e9 ed 00 00 00       	jmp    5e7 <printf+0x194>
      } else if(c == 'x' || c == 'p'){
 4fa:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 4fe:	74 06                	je     506 <printf+0xb3>
 500:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 504:	75 2d                	jne    533 <printf+0xe0>
        printint(fd, *ap, 16, 0);
 506:	8b 45 e8             	mov    -0x18(%ebp),%eax
 509:	8b 00                	mov    (%eax),%eax
 50b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 512:	00 
 513:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 51a:	00 
 51b:	89 44 24 04          	mov    %eax,0x4(%esp)
 51f:	8b 45 08             	mov    0x8(%ebp),%eax
 522:	89 04 24             	mov    %eax,(%esp)
 525:	e8 7a fe ff ff       	call   3a4 <printint>
        ap++;
 52a:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 52e:	e9 b4 00 00 00       	jmp    5e7 <printf+0x194>
      } else if(c == 's'){
 533:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 537:	75 46                	jne    57f <printf+0x12c>
        s = (char*)*ap;
 539:	8b 45 e8             	mov    -0x18(%ebp),%eax
 53c:	8b 00                	mov    (%eax),%eax
 53e:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 541:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 545:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 549:	75 27                	jne    572 <printf+0x11f>
          s = "(null)";
 54b:	c7 45 f4 17 08 00 00 	movl   $0x817,-0xc(%ebp)
        while(*s != 0){
 552:	eb 1e                	jmp    572 <printf+0x11f>
          putc(fd, *s);
 554:	8b 45 f4             	mov    -0xc(%ebp),%eax
 557:	0f b6 00             	movzbl (%eax),%eax
 55a:	0f be c0             	movsbl %al,%eax
 55d:	89 44 24 04          	mov    %eax,0x4(%esp)
 561:	8b 45 08             	mov    0x8(%ebp),%eax
 564:	89 04 24             	mov    %eax,(%esp)
 567:	e8 10 fe ff ff       	call   37c <putc>
          s++;
 56c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 570:	eb 01                	jmp    573 <printf+0x120>
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 572:	90                   	nop
 573:	8b 45 f4             	mov    -0xc(%ebp),%eax
 576:	0f b6 00             	movzbl (%eax),%eax
 579:	84 c0                	test   %al,%al
 57b:	75 d7                	jne    554 <printf+0x101>
 57d:	eb 68                	jmp    5e7 <printf+0x194>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 57f:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 583:	75 1d                	jne    5a2 <printf+0x14f>
        putc(fd, *ap);
 585:	8b 45 e8             	mov    -0x18(%ebp),%eax
 588:	8b 00                	mov    (%eax),%eax
 58a:	0f be c0             	movsbl %al,%eax
 58d:	89 44 24 04          	mov    %eax,0x4(%esp)
 591:	8b 45 08             	mov    0x8(%ebp),%eax
 594:	89 04 24             	mov    %eax,(%esp)
 597:	e8 e0 fd ff ff       	call   37c <putc>
        ap++;
 59c:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 5a0:	eb 45                	jmp    5e7 <printf+0x194>
      } else if(c == '%'){
 5a2:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 5a6:	75 17                	jne    5bf <printf+0x16c>
        putc(fd, c);
 5a8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 5ab:	0f be c0             	movsbl %al,%eax
 5ae:	89 44 24 04          	mov    %eax,0x4(%esp)
 5b2:	8b 45 08             	mov    0x8(%ebp),%eax
 5b5:	89 04 24             	mov    %eax,(%esp)
 5b8:	e8 bf fd ff ff       	call   37c <putc>
 5bd:	eb 28                	jmp    5e7 <printf+0x194>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 5bf:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 5c6:	00 
 5c7:	8b 45 08             	mov    0x8(%ebp),%eax
 5ca:	89 04 24             	mov    %eax,(%esp)
 5cd:	e8 aa fd ff ff       	call   37c <putc>
        putc(fd, c);
 5d2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 5d5:	0f be c0             	movsbl %al,%eax
 5d8:	89 44 24 04          	mov    %eax,0x4(%esp)
 5dc:	8b 45 08             	mov    0x8(%ebp),%eax
 5df:	89 04 24             	mov    %eax,(%esp)
 5e2:	e8 95 fd ff ff       	call   37c <putc>
      }
      state = 0;
 5e7:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 5ee:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 5f2:	8b 55 0c             	mov    0xc(%ebp),%edx
 5f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
 5f8:	01 d0                	add    %edx,%eax
 5fa:	0f b6 00             	movzbl (%eax),%eax
 5fd:	84 c0                	test   %al,%al
 5ff:	0f 85 70 fe ff ff    	jne    475 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 605:	c9                   	leave  
 606:	c3                   	ret    
 607:	90                   	nop

00000608 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 608:	55                   	push   %ebp
 609:	89 e5                	mov    %esp,%ebp
 60b:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 60e:	8b 45 08             	mov    0x8(%ebp),%eax
 611:	83 e8 08             	sub    $0x8,%eax
 614:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 617:	a1 78 0a 00 00       	mov    0xa78,%eax
 61c:	89 45 fc             	mov    %eax,-0x4(%ebp)
 61f:	eb 24                	jmp    645 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 621:	8b 45 fc             	mov    -0x4(%ebp),%eax
 624:	8b 00                	mov    (%eax),%eax
 626:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 629:	77 12                	ja     63d <free+0x35>
 62b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 62e:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 631:	77 24                	ja     657 <free+0x4f>
 633:	8b 45 fc             	mov    -0x4(%ebp),%eax
 636:	8b 00                	mov    (%eax),%eax
 638:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 63b:	77 1a                	ja     657 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 63d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 640:	8b 00                	mov    (%eax),%eax
 642:	89 45 fc             	mov    %eax,-0x4(%ebp)
 645:	8b 45 f8             	mov    -0x8(%ebp),%eax
 648:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 64b:	76 d4                	jbe    621 <free+0x19>
 64d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 650:	8b 00                	mov    (%eax),%eax
 652:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 655:	76 ca                	jbe    621 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 657:	8b 45 f8             	mov    -0x8(%ebp),%eax
 65a:	8b 40 04             	mov    0x4(%eax),%eax
 65d:	c1 e0 03             	shl    $0x3,%eax
 660:	89 c2                	mov    %eax,%edx
 662:	03 55 f8             	add    -0x8(%ebp),%edx
 665:	8b 45 fc             	mov    -0x4(%ebp),%eax
 668:	8b 00                	mov    (%eax),%eax
 66a:	39 c2                	cmp    %eax,%edx
 66c:	75 24                	jne    692 <free+0x8a>
    bp->s.size += p->s.ptr->s.size;
 66e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 671:	8b 50 04             	mov    0x4(%eax),%edx
 674:	8b 45 fc             	mov    -0x4(%ebp),%eax
 677:	8b 00                	mov    (%eax),%eax
 679:	8b 40 04             	mov    0x4(%eax),%eax
 67c:	01 c2                	add    %eax,%edx
 67e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 681:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 684:	8b 45 fc             	mov    -0x4(%ebp),%eax
 687:	8b 00                	mov    (%eax),%eax
 689:	8b 10                	mov    (%eax),%edx
 68b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 68e:	89 10                	mov    %edx,(%eax)
 690:	eb 0a                	jmp    69c <free+0x94>
  } else
    bp->s.ptr = p->s.ptr;
 692:	8b 45 fc             	mov    -0x4(%ebp),%eax
 695:	8b 10                	mov    (%eax),%edx
 697:	8b 45 f8             	mov    -0x8(%ebp),%eax
 69a:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 69c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 69f:	8b 40 04             	mov    0x4(%eax),%eax
 6a2:	c1 e0 03             	shl    $0x3,%eax
 6a5:	03 45 fc             	add    -0x4(%ebp),%eax
 6a8:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 6ab:	75 20                	jne    6cd <free+0xc5>
    p->s.size += bp->s.size;
 6ad:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6b0:	8b 50 04             	mov    0x4(%eax),%edx
 6b3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6b6:	8b 40 04             	mov    0x4(%eax),%eax
 6b9:	01 c2                	add    %eax,%edx
 6bb:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6be:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 6c1:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6c4:	8b 10                	mov    (%eax),%edx
 6c6:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6c9:	89 10                	mov    %edx,(%eax)
 6cb:	eb 08                	jmp    6d5 <free+0xcd>
  } else
    p->s.ptr = bp;
 6cd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6d0:	8b 55 f8             	mov    -0x8(%ebp),%edx
 6d3:	89 10                	mov    %edx,(%eax)
  freep = p;
 6d5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6d8:	a3 78 0a 00 00       	mov    %eax,0xa78
}
 6dd:	c9                   	leave  
 6de:	c3                   	ret    

000006df <morecore>:

static Header*
morecore(uint nu)
{
 6df:	55                   	push   %ebp
 6e0:	89 e5                	mov    %esp,%ebp
 6e2:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 6e5:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 6ec:	77 07                	ja     6f5 <morecore+0x16>
    nu = 4096;
 6ee:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 6f5:	8b 45 08             	mov    0x8(%ebp),%eax
 6f8:	c1 e0 03             	shl    $0x3,%eax
 6fb:	89 04 24             	mov    %eax,(%esp)
 6fe:	e8 61 fc ff ff       	call   364 <sbrk>
 703:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 706:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 70a:	75 07                	jne    713 <morecore+0x34>
    return 0;
 70c:	b8 00 00 00 00       	mov    $0x0,%eax
 711:	eb 22                	jmp    735 <morecore+0x56>
  hp = (Header*)p;
 713:	8b 45 f4             	mov    -0xc(%ebp),%eax
 716:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 719:	8b 45 f0             	mov    -0x10(%ebp),%eax
 71c:	8b 55 08             	mov    0x8(%ebp),%edx
 71f:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 722:	8b 45 f0             	mov    -0x10(%ebp),%eax
 725:	83 c0 08             	add    $0x8,%eax
 728:	89 04 24             	mov    %eax,(%esp)
 72b:	e8 d8 fe ff ff       	call   608 <free>
  return freep;
 730:	a1 78 0a 00 00       	mov    0xa78,%eax
}
 735:	c9                   	leave  
 736:	c3                   	ret    

00000737 <malloc>:

void*
malloc(uint nbytes)
{
 737:	55                   	push   %ebp
 738:	89 e5                	mov    %esp,%ebp
 73a:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 73d:	8b 45 08             	mov    0x8(%ebp),%eax
 740:	83 c0 07             	add    $0x7,%eax
 743:	c1 e8 03             	shr    $0x3,%eax
 746:	83 c0 01             	add    $0x1,%eax
 749:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 74c:	a1 78 0a 00 00       	mov    0xa78,%eax
 751:	89 45 f0             	mov    %eax,-0x10(%ebp)
 754:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 758:	75 23                	jne    77d <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 75a:	c7 45 f0 70 0a 00 00 	movl   $0xa70,-0x10(%ebp)
 761:	8b 45 f0             	mov    -0x10(%ebp),%eax
 764:	a3 78 0a 00 00       	mov    %eax,0xa78
 769:	a1 78 0a 00 00       	mov    0xa78,%eax
 76e:	a3 70 0a 00 00       	mov    %eax,0xa70
    base.s.size = 0;
 773:	c7 05 74 0a 00 00 00 	movl   $0x0,0xa74
 77a:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 77d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 780:	8b 00                	mov    (%eax),%eax
 782:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 785:	8b 45 f4             	mov    -0xc(%ebp),%eax
 788:	8b 40 04             	mov    0x4(%eax),%eax
 78b:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 78e:	72 4d                	jb     7dd <malloc+0xa6>
      if(p->s.size == nunits)
 790:	8b 45 f4             	mov    -0xc(%ebp),%eax
 793:	8b 40 04             	mov    0x4(%eax),%eax
 796:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 799:	75 0c                	jne    7a7 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 79b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 79e:	8b 10                	mov    (%eax),%edx
 7a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7a3:	89 10                	mov    %edx,(%eax)
 7a5:	eb 26                	jmp    7cd <malloc+0x96>
      else {
        p->s.size -= nunits;
 7a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7aa:	8b 40 04             	mov    0x4(%eax),%eax
 7ad:	89 c2                	mov    %eax,%edx
 7af:	2b 55 ec             	sub    -0x14(%ebp),%edx
 7b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7b5:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 7b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7bb:	8b 40 04             	mov    0x4(%eax),%eax
 7be:	c1 e0 03             	shl    $0x3,%eax
 7c1:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 7c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7c7:	8b 55 ec             	mov    -0x14(%ebp),%edx
 7ca:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 7cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7d0:	a3 78 0a 00 00       	mov    %eax,0xa78
      return (void*)(p + 1);
 7d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7d8:	83 c0 08             	add    $0x8,%eax
 7db:	eb 38                	jmp    815 <malloc+0xde>
    }
    if(p == freep)
 7dd:	a1 78 0a 00 00       	mov    0xa78,%eax
 7e2:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 7e5:	75 1b                	jne    802 <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 7e7:	8b 45 ec             	mov    -0x14(%ebp),%eax
 7ea:	89 04 24             	mov    %eax,(%esp)
 7ed:	e8 ed fe ff ff       	call   6df <morecore>
 7f2:	89 45 f4             	mov    %eax,-0xc(%ebp)
 7f5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 7f9:	75 07                	jne    802 <malloc+0xcb>
        return 0;
 7fb:	b8 00 00 00 00       	mov    $0x0,%eax
 800:	eb 13                	jmp    815 <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 802:	8b 45 f4             	mov    -0xc(%ebp),%eax
 805:	89 45 f0             	mov    %eax,-0x10(%ebp)
 808:	8b 45 f4             	mov    -0xc(%ebp),%eax
 80b:	8b 00                	mov    (%eax),%eax
 80d:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 810:	e9 70 ff ff ff       	jmp    785 <malloc+0x4e>
}
 815:	c9                   	leave  
 816:	c3                   	ret    