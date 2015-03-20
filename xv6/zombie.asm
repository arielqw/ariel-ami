
_zombie:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "stat.h"
#include "user.h"

int
main(void)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 e4 f0             	and    $0xfffffff0,%esp
   6:	83 ec 10             	sub    $0x10,%esp
  if(fork() > 0)
   9:	e8 7a 02 00 00       	call   288 <fork>
   e:	85 c0                	test   %eax,%eax
  10:	7e 0c                	jle    1e <main+0x1e>
    sleep(5);  // Let child exit before parent.
  12:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  19:	e8 02 03 00 00       	call   320 <sleep>
  exit(EXIT_STATUS_DEFAULT);
  1e:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  25:	e8 66 02 00 00       	call   290 <exit>
  2a:	90                   	nop
  2b:	90                   	nop

0000002c <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
  2c:	55                   	push   %ebp
  2d:	89 e5                	mov    %esp,%ebp
  2f:	57                   	push   %edi
  30:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
  31:	8b 4d 08             	mov    0x8(%ebp),%ecx
  34:	8b 55 10             	mov    0x10(%ebp),%edx
  37:	8b 45 0c             	mov    0xc(%ebp),%eax
  3a:	89 cb                	mov    %ecx,%ebx
  3c:	89 df                	mov    %ebx,%edi
  3e:	89 d1                	mov    %edx,%ecx
  40:	fc                   	cld    
  41:	f3 aa                	rep stos %al,%es:(%edi)
  43:	89 ca                	mov    %ecx,%edx
  45:	89 fb                	mov    %edi,%ebx
  47:	89 5d 08             	mov    %ebx,0x8(%ebp)
  4a:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
  4d:	5b                   	pop    %ebx
  4e:	5f                   	pop    %edi
  4f:	5d                   	pop    %ebp
  50:	c3                   	ret    

00000051 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
  51:	55                   	push   %ebp
  52:	89 e5                	mov    %esp,%ebp
  54:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
  57:	8b 45 08             	mov    0x8(%ebp),%eax
  5a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
  5d:	90                   	nop
  5e:	8b 45 0c             	mov    0xc(%ebp),%eax
  61:	0f b6 10             	movzbl (%eax),%edx
  64:	8b 45 08             	mov    0x8(%ebp),%eax
  67:	88 10                	mov    %dl,(%eax)
  69:	8b 45 08             	mov    0x8(%ebp),%eax
  6c:	0f b6 00             	movzbl (%eax),%eax
  6f:	84 c0                	test   %al,%al
  71:	0f 95 c0             	setne  %al
  74:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  78:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  7c:	84 c0                	test   %al,%al
  7e:	75 de                	jne    5e <strcpy+0xd>
    ;
  return os;
  80:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  83:	c9                   	leave  
  84:	c3                   	ret    

00000085 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  85:	55                   	push   %ebp
  86:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
  88:	eb 08                	jmp    92 <strcmp+0xd>
    p++, q++;
  8a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  8e:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
  92:	8b 45 08             	mov    0x8(%ebp),%eax
  95:	0f b6 00             	movzbl (%eax),%eax
  98:	84 c0                	test   %al,%al
  9a:	74 10                	je     ac <strcmp+0x27>
  9c:	8b 45 08             	mov    0x8(%ebp),%eax
  9f:	0f b6 10             	movzbl (%eax),%edx
  a2:	8b 45 0c             	mov    0xc(%ebp),%eax
  a5:	0f b6 00             	movzbl (%eax),%eax
  a8:	38 c2                	cmp    %al,%dl
  aa:	74 de                	je     8a <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
  ac:	8b 45 08             	mov    0x8(%ebp),%eax
  af:	0f b6 00             	movzbl (%eax),%eax
  b2:	0f b6 d0             	movzbl %al,%edx
  b5:	8b 45 0c             	mov    0xc(%ebp),%eax
  b8:	0f b6 00             	movzbl (%eax),%eax
  bb:	0f b6 c0             	movzbl %al,%eax
  be:	89 d1                	mov    %edx,%ecx
  c0:	29 c1                	sub    %eax,%ecx
  c2:	89 c8                	mov    %ecx,%eax
}
  c4:	5d                   	pop    %ebp
  c5:	c3                   	ret    

000000c6 <strlen>:

uint
strlen(char *s)
{
  c6:	55                   	push   %ebp
  c7:	89 e5                	mov    %esp,%ebp
  c9:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
  cc:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  d3:	eb 04                	jmp    d9 <strlen+0x13>
  d5:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  d9:	8b 45 fc             	mov    -0x4(%ebp),%eax
  dc:	03 45 08             	add    0x8(%ebp),%eax
  df:	0f b6 00             	movzbl (%eax),%eax
  e2:	84 c0                	test   %al,%al
  e4:	75 ef                	jne    d5 <strlen+0xf>
    ;
  return n;
  e6:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  e9:	c9                   	leave  
  ea:	c3                   	ret    

000000eb <memset>:

void*
memset(void *dst, int c, uint n)
{
  eb:	55                   	push   %ebp
  ec:	89 e5                	mov    %esp,%ebp
  ee:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
  f1:	8b 45 10             	mov    0x10(%ebp),%eax
  f4:	89 44 24 08          	mov    %eax,0x8(%esp)
  f8:	8b 45 0c             	mov    0xc(%ebp),%eax
  fb:	89 44 24 04          	mov    %eax,0x4(%esp)
  ff:	8b 45 08             	mov    0x8(%ebp),%eax
 102:	89 04 24             	mov    %eax,(%esp)
 105:	e8 22 ff ff ff       	call   2c <stosb>
  return dst;
 10a:	8b 45 08             	mov    0x8(%ebp),%eax
}
 10d:	c9                   	leave  
 10e:	c3                   	ret    

0000010f <strchr>:

char*
strchr(const char *s, char c)
{
 10f:	55                   	push   %ebp
 110:	89 e5                	mov    %esp,%ebp
 112:	83 ec 04             	sub    $0x4,%esp
 115:	8b 45 0c             	mov    0xc(%ebp),%eax
 118:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 11b:	eb 14                	jmp    131 <strchr+0x22>
    if(*s == c)
 11d:	8b 45 08             	mov    0x8(%ebp),%eax
 120:	0f b6 00             	movzbl (%eax),%eax
 123:	3a 45 fc             	cmp    -0x4(%ebp),%al
 126:	75 05                	jne    12d <strchr+0x1e>
      return (char*)s;
 128:	8b 45 08             	mov    0x8(%ebp),%eax
 12b:	eb 13                	jmp    140 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 12d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 131:	8b 45 08             	mov    0x8(%ebp),%eax
 134:	0f b6 00             	movzbl (%eax),%eax
 137:	84 c0                	test   %al,%al
 139:	75 e2                	jne    11d <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 13b:	b8 00 00 00 00       	mov    $0x0,%eax
}
 140:	c9                   	leave  
 141:	c3                   	ret    

00000142 <gets>:

char*
gets(char *buf, int max)
{
 142:	55                   	push   %ebp
 143:	89 e5                	mov    %esp,%ebp
 145:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 148:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 14f:	eb 44                	jmp    195 <gets+0x53>
    cc = read(0, &c, 1);
 151:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 158:	00 
 159:	8d 45 ef             	lea    -0x11(%ebp),%eax
 15c:	89 44 24 04          	mov    %eax,0x4(%esp)
 160:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 167:	e8 3c 01 00 00       	call   2a8 <read>
 16c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 16f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 173:	7e 2d                	jle    1a2 <gets+0x60>
      break;
    buf[i++] = c;
 175:	8b 45 f4             	mov    -0xc(%ebp),%eax
 178:	03 45 08             	add    0x8(%ebp),%eax
 17b:	0f b6 55 ef          	movzbl -0x11(%ebp),%edx
 17f:	88 10                	mov    %dl,(%eax)
 181:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(c == '\n' || c == '\r')
 185:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 189:	3c 0a                	cmp    $0xa,%al
 18b:	74 16                	je     1a3 <gets+0x61>
 18d:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 191:	3c 0d                	cmp    $0xd,%al
 193:	74 0e                	je     1a3 <gets+0x61>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 195:	8b 45 f4             	mov    -0xc(%ebp),%eax
 198:	83 c0 01             	add    $0x1,%eax
 19b:	3b 45 0c             	cmp    0xc(%ebp),%eax
 19e:	7c b1                	jl     151 <gets+0xf>
 1a0:	eb 01                	jmp    1a3 <gets+0x61>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 1a2:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 1a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1a6:	03 45 08             	add    0x8(%ebp),%eax
 1a9:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 1ac:	8b 45 08             	mov    0x8(%ebp),%eax
}
 1af:	c9                   	leave  
 1b0:	c3                   	ret    

000001b1 <stat>:

int
stat(char *n, struct stat *st)
{
 1b1:	55                   	push   %ebp
 1b2:	89 e5                	mov    %esp,%ebp
 1b4:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1b7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 1be:	00 
 1bf:	8b 45 08             	mov    0x8(%ebp),%eax
 1c2:	89 04 24             	mov    %eax,(%esp)
 1c5:	e8 06 01 00 00       	call   2d0 <open>
 1ca:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 1cd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 1d1:	79 07                	jns    1da <stat+0x29>
    return -1;
 1d3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 1d8:	eb 23                	jmp    1fd <stat+0x4c>
  r = fstat(fd, st);
 1da:	8b 45 0c             	mov    0xc(%ebp),%eax
 1dd:	89 44 24 04          	mov    %eax,0x4(%esp)
 1e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1e4:	89 04 24             	mov    %eax,(%esp)
 1e7:	e8 fc 00 00 00       	call   2e8 <fstat>
 1ec:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 1ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1f2:	89 04 24             	mov    %eax,(%esp)
 1f5:	e8 be 00 00 00       	call   2b8 <close>
  return r;
 1fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 1fd:	c9                   	leave  
 1fe:	c3                   	ret    

000001ff <atoi>:

int
atoi(const char *s)
{
 1ff:	55                   	push   %ebp
 200:	89 e5                	mov    %esp,%ebp
 202:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 205:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 20c:	eb 23                	jmp    231 <atoi+0x32>
    n = n*10 + *s++ - '0';
 20e:	8b 55 fc             	mov    -0x4(%ebp),%edx
 211:	89 d0                	mov    %edx,%eax
 213:	c1 e0 02             	shl    $0x2,%eax
 216:	01 d0                	add    %edx,%eax
 218:	01 c0                	add    %eax,%eax
 21a:	89 c2                	mov    %eax,%edx
 21c:	8b 45 08             	mov    0x8(%ebp),%eax
 21f:	0f b6 00             	movzbl (%eax),%eax
 222:	0f be c0             	movsbl %al,%eax
 225:	01 d0                	add    %edx,%eax
 227:	83 e8 30             	sub    $0x30,%eax
 22a:	89 45 fc             	mov    %eax,-0x4(%ebp)
 22d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 231:	8b 45 08             	mov    0x8(%ebp),%eax
 234:	0f b6 00             	movzbl (%eax),%eax
 237:	3c 2f                	cmp    $0x2f,%al
 239:	7e 0a                	jle    245 <atoi+0x46>
 23b:	8b 45 08             	mov    0x8(%ebp),%eax
 23e:	0f b6 00             	movzbl (%eax),%eax
 241:	3c 39                	cmp    $0x39,%al
 243:	7e c9                	jle    20e <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 245:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 248:	c9                   	leave  
 249:	c3                   	ret    

0000024a <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 24a:	55                   	push   %ebp
 24b:	89 e5                	mov    %esp,%ebp
 24d:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 250:	8b 45 08             	mov    0x8(%ebp),%eax
 253:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 256:	8b 45 0c             	mov    0xc(%ebp),%eax
 259:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 25c:	eb 13                	jmp    271 <memmove+0x27>
    *dst++ = *src++;
 25e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 261:	0f b6 10             	movzbl (%eax),%edx
 264:	8b 45 fc             	mov    -0x4(%ebp),%eax
 267:	88 10                	mov    %dl,(%eax)
 269:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 26d:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 271:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 275:	0f 9f c0             	setg   %al
 278:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 27c:	84 c0                	test   %al,%al
 27e:	75 de                	jne    25e <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 280:	8b 45 08             	mov    0x8(%ebp),%eax
}
 283:	c9                   	leave  
 284:	c3                   	ret    
 285:	90                   	nop
 286:	90                   	nop
 287:	90                   	nop

00000288 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 288:	b8 01 00 00 00       	mov    $0x1,%eax
 28d:	cd 40                	int    $0x40
 28f:	c3                   	ret    

00000290 <exit>:
SYSCALL(exit)
 290:	b8 02 00 00 00       	mov    $0x2,%eax
 295:	cd 40                	int    $0x40
 297:	c3                   	ret    

00000298 <wait>:
SYSCALL(wait)
 298:	b8 03 00 00 00       	mov    $0x3,%eax
 29d:	cd 40                	int    $0x40
 29f:	c3                   	ret    

000002a0 <pipe>:
SYSCALL(pipe)
 2a0:	b8 04 00 00 00       	mov    $0x4,%eax
 2a5:	cd 40                	int    $0x40
 2a7:	c3                   	ret    

000002a8 <read>:
SYSCALL(read)
 2a8:	b8 05 00 00 00       	mov    $0x5,%eax
 2ad:	cd 40                	int    $0x40
 2af:	c3                   	ret    

000002b0 <write>:
SYSCALL(write)
 2b0:	b8 10 00 00 00       	mov    $0x10,%eax
 2b5:	cd 40                	int    $0x40
 2b7:	c3                   	ret    

000002b8 <close>:
SYSCALL(close)
 2b8:	b8 15 00 00 00       	mov    $0x15,%eax
 2bd:	cd 40                	int    $0x40
 2bf:	c3                   	ret    

000002c0 <kill>:
SYSCALL(kill)
 2c0:	b8 06 00 00 00       	mov    $0x6,%eax
 2c5:	cd 40                	int    $0x40
 2c7:	c3                   	ret    

000002c8 <exec>:
SYSCALL(exec)
 2c8:	b8 07 00 00 00       	mov    $0x7,%eax
 2cd:	cd 40                	int    $0x40
 2cf:	c3                   	ret    

000002d0 <open>:
SYSCALL(open)
 2d0:	b8 0f 00 00 00       	mov    $0xf,%eax
 2d5:	cd 40                	int    $0x40
 2d7:	c3                   	ret    

000002d8 <mknod>:
SYSCALL(mknod)
 2d8:	b8 11 00 00 00       	mov    $0x11,%eax
 2dd:	cd 40                	int    $0x40
 2df:	c3                   	ret    

000002e0 <unlink>:
SYSCALL(unlink)
 2e0:	b8 12 00 00 00       	mov    $0x12,%eax
 2e5:	cd 40                	int    $0x40
 2e7:	c3                   	ret    

000002e8 <fstat>:
SYSCALL(fstat)
 2e8:	b8 08 00 00 00       	mov    $0x8,%eax
 2ed:	cd 40                	int    $0x40
 2ef:	c3                   	ret    

000002f0 <link>:
SYSCALL(link)
 2f0:	b8 13 00 00 00       	mov    $0x13,%eax
 2f5:	cd 40                	int    $0x40
 2f7:	c3                   	ret    

000002f8 <mkdir>:
SYSCALL(mkdir)
 2f8:	b8 14 00 00 00       	mov    $0x14,%eax
 2fd:	cd 40                	int    $0x40
 2ff:	c3                   	ret    

00000300 <chdir>:
SYSCALL(chdir)
 300:	b8 09 00 00 00       	mov    $0x9,%eax
 305:	cd 40                	int    $0x40
 307:	c3                   	ret    

00000308 <dup>:
SYSCALL(dup)
 308:	b8 0a 00 00 00       	mov    $0xa,%eax
 30d:	cd 40                	int    $0x40
 30f:	c3                   	ret    

00000310 <getpid>:
SYSCALL(getpid)
 310:	b8 0b 00 00 00       	mov    $0xb,%eax
 315:	cd 40                	int    $0x40
 317:	c3                   	ret    

00000318 <sbrk>:
SYSCALL(sbrk)
 318:	b8 0c 00 00 00       	mov    $0xc,%eax
 31d:	cd 40                	int    $0x40
 31f:	c3                   	ret    

00000320 <sleep>:
SYSCALL(sleep)
 320:	b8 0d 00 00 00       	mov    $0xd,%eax
 325:	cd 40                	int    $0x40
 327:	c3                   	ret    

00000328 <uptime>:
SYSCALL(uptime)
 328:	b8 0e 00 00 00       	mov    $0xe,%eax
 32d:	cd 40                	int    $0x40
 32f:	c3                   	ret    

00000330 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 330:	55                   	push   %ebp
 331:	89 e5                	mov    %esp,%ebp
 333:	83 ec 28             	sub    $0x28,%esp
 336:	8b 45 0c             	mov    0xc(%ebp),%eax
 339:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 33c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 343:	00 
 344:	8d 45 f4             	lea    -0xc(%ebp),%eax
 347:	89 44 24 04          	mov    %eax,0x4(%esp)
 34b:	8b 45 08             	mov    0x8(%ebp),%eax
 34e:	89 04 24             	mov    %eax,(%esp)
 351:	e8 5a ff ff ff       	call   2b0 <write>
}
 356:	c9                   	leave  
 357:	c3                   	ret    

00000358 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 358:	55                   	push   %ebp
 359:	89 e5                	mov    %esp,%ebp
 35b:	83 ec 48             	sub    $0x48,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 35e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 365:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 369:	74 17                	je     382 <printint+0x2a>
 36b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 36f:	79 11                	jns    382 <printint+0x2a>
    neg = 1;
 371:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 378:	8b 45 0c             	mov    0xc(%ebp),%eax
 37b:	f7 d8                	neg    %eax
 37d:	89 45 ec             	mov    %eax,-0x14(%ebp)
 380:	eb 06                	jmp    388 <printint+0x30>
  } else {
    x = xx;
 382:	8b 45 0c             	mov    0xc(%ebp),%eax
 385:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 388:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 38f:	8b 4d 10             	mov    0x10(%ebp),%ecx
 392:	8b 45 ec             	mov    -0x14(%ebp),%eax
 395:	ba 00 00 00 00       	mov    $0x0,%edx
 39a:	f7 f1                	div    %ecx
 39c:	89 d0                	mov    %edx,%eax
 39e:	0f b6 90 10 0a 00 00 	movzbl 0xa10(%eax),%edx
 3a5:	8d 45 dc             	lea    -0x24(%ebp),%eax
 3a8:	03 45 f4             	add    -0xc(%ebp),%eax
 3ab:	88 10                	mov    %dl,(%eax)
 3ad:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  }while((x /= base) != 0);
 3b1:	8b 55 10             	mov    0x10(%ebp),%edx
 3b4:	89 55 d4             	mov    %edx,-0x2c(%ebp)
 3b7:	8b 45 ec             	mov    -0x14(%ebp),%eax
 3ba:	ba 00 00 00 00       	mov    $0x0,%edx
 3bf:	f7 75 d4             	divl   -0x2c(%ebp)
 3c2:	89 45 ec             	mov    %eax,-0x14(%ebp)
 3c5:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 3c9:	75 c4                	jne    38f <printint+0x37>
  if(neg)
 3cb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 3cf:	74 2a                	je     3fb <printint+0xa3>
    buf[i++] = '-';
 3d1:	8d 45 dc             	lea    -0x24(%ebp),%eax
 3d4:	03 45 f4             	add    -0xc(%ebp),%eax
 3d7:	c6 00 2d             	movb   $0x2d,(%eax)
 3da:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

  while(--i >= 0)
 3de:	eb 1b                	jmp    3fb <printint+0xa3>
    putc(fd, buf[i]);
 3e0:	8d 45 dc             	lea    -0x24(%ebp),%eax
 3e3:	03 45 f4             	add    -0xc(%ebp),%eax
 3e6:	0f b6 00             	movzbl (%eax),%eax
 3e9:	0f be c0             	movsbl %al,%eax
 3ec:	89 44 24 04          	mov    %eax,0x4(%esp)
 3f0:	8b 45 08             	mov    0x8(%ebp),%eax
 3f3:	89 04 24             	mov    %eax,(%esp)
 3f6:	e8 35 ff ff ff       	call   330 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 3fb:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 3ff:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 403:	79 db                	jns    3e0 <printint+0x88>
    putc(fd, buf[i]);
}
 405:	c9                   	leave  
 406:	c3                   	ret    

00000407 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 407:	55                   	push   %ebp
 408:	89 e5                	mov    %esp,%ebp
 40a:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 40d:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 414:	8d 45 0c             	lea    0xc(%ebp),%eax
 417:	83 c0 04             	add    $0x4,%eax
 41a:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 41d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 424:	e9 7d 01 00 00       	jmp    5a6 <printf+0x19f>
    c = fmt[i] & 0xff;
 429:	8b 55 0c             	mov    0xc(%ebp),%edx
 42c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 42f:	01 d0                	add    %edx,%eax
 431:	0f b6 00             	movzbl (%eax),%eax
 434:	0f be c0             	movsbl %al,%eax
 437:	25 ff 00 00 00       	and    $0xff,%eax
 43c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 43f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 443:	75 2c                	jne    471 <printf+0x6a>
      if(c == '%'){
 445:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 449:	75 0c                	jne    457 <printf+0x50>
        state = '%';
 44b:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 452:	e9 4b 01 00 00       	jmp    5a2 <printf+0x19b>
      } else {
        putc(fd, c);
 457:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 45a:	0f be c0             	movsbl %al,%eax
 45d:	89 44 24 04          	mov    %eax,0x4(%esp)
 461:	8b 45 08             	mov    0x8(%ebp),%eax
 464:	89 04 24             	mov    %eax,(%esp)
 467:	e8 c4 fe ff ff       	call   330 <putc>
 46c:	e9 31 01 00 00       	jmp    5a2 <printf+0x19b>
      }
    } else if(state == '%'){
 471:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 475:	0f 85 27 01 00 00    	jne    5a2 <printf+0x19b>
      if(c == 'd'){
 47b:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 47f:	75 2d                	jne    4ae <printf+0xa7>
        printint(fd, *ap, 10, 1);
 481:	8b 45 e8             	mov    -0x18(%ebp),%eax
 484:	8b 00                	mov    (%eax),%eax
 486:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 48d:	00 
 48e:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 495:	00 
 496:	89 44 24 04          	mov    %eax,0x4(%esp)
 49a:	8b 45 08             	mov    0x8(%ebp),%eax
 49d:	89 04 24             	mov    %eax,(%esp)
 4a0:	e8 b3 fe ff ff       	call   358 <printint>
        ap++;
 4a5:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 4a9:	e9 ed 00 00 00       	jmp    59b <printf+0x194>
      } else if(c == 'x' || c == 'p'){
 4ae:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 4b2:	74 06                	je     4ba <printf+0xb3>
 4b4:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 4b8:	75 2d                	jne    4e7 <printf+0xe0>
        printint(fd, *ap, 16, 0);
 4ba:	8b 45 e8             	mov    -0x18(%ebp),%eax
 4bd:	8b 00                	mov    (%eax),%eax
 4bf:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 4c6:	00 
 4c7:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 4ce:	00 
 4cf:	89 44 24 04          	mov    %eax,0x4(%esp)
 4d3:	8b 45 08             	mov    0x8(%ebp),%eax
 4d6:	89 04 24             	mov    %eax,(%esp)
 4d9:	e8 7a fe ff ff       	call   358 <printint>
        ap++;
 4de:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 4e2:	e9 b4 00 00 00       	jmp    59b <printf+0x194>
      } else if(c == 's'){
 4e7:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 4eb:	75 46                	jne    533 <printf+0x12c>
        s = (char*)*ap;
 4ed:	8b 45 e8             	mov    -0x18(%ebp),%eax
 4f0:	8b 00                	mov    (%eax),%eax
 4f2:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 4f5:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 4f9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 4fd:	75 27                	jne    526 <printf+0x11f>
          s = "(null)";
 4ff:	c7 45 f4 cb 07 00 00 	movl   $0x7cb,-0xc(%ebp)
        while(*s != 0){
 506:	eb 1e                	jmp    526 <printf+0x11f>
          putc(fd, *s);
 508:	8b 45 f4             	mov    -0xc(%ebp),%eax
 50b:	0f b6 00             	movzbl (%eax),%eax
 50e:	0f be c0             	movsbl %al,%eax
 511:	89 44 24 04          	mov    %eax,0x4(%esp)
 515:	8b 45 08             	mov    0x8(%ebp),%eax
 518:	89 04 24             	mov    %eax,(%esp)
 51b:	e8 10 fe ff ff       	call   330 <putc>
          s++;
 520:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 524:	eb 01                	jmp    527 <printf+0x120>
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 526:	90                   	nop
 527:	8b 45 f4             	mov    -0xc(%ebp),%eax
 52a:	0f b6 00             	movzbl (%eax),%eax
 52d:	84 c0                	test   %al,%al
 52f:	75 d7                	jne    508 <printf+0x101>
 531:	eb 68                	jmp    59b <printf+0x194>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 533:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 537:	75 1d                	jne    556 <printf+0x14f>
        putc(fd, *ap);
 539:	8b 45 e8             	mov    -0x18(%ebp),%eax
 53c:	8b 00                	mov    (%eax),%eax
 53e:	0f be c0             	movsbl %al,%eax
 541:	89 44 24 04          	mov    %eax,0x4(%esp)
 545:	8b 45 08             	mov    0x8(%ebp),%eax
 548:	89 04 24             	mov    %eax,(%esp)
 54b:	e8 e0 fd ff ff       	call   330 <putc>
        ap++;
 550:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 554:	eb 45                	jmp    59b <printf+0x194>
      } else if(c == '%'){
 556:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 55a:	75 17                	jne    573 <printf+0x16c>
        putc(fd, c);
 55c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 55f:	0f be c0             	movsbl %al,%eax
 562:	89 44 24 04          	mov    %eax,0x4(%esp)
 566:	8b 45 08             	mov    0x8(%ebp),%eax
 569:	89 04 24             	mov    %eax,(%esp)
 56c:	e8 bf fd ff ff       	call   330 <putc>
 571:	eb 28                	jmp    59b <printf+0x194>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 573:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 57a:	00 
 57b:	8b 45 08             	mov    0x8(%ebp),%eax
 57e:	89 04 24             	mov    %eax,(%esp)
 581:	e8 aa fd ff ff       	call   330 <putc>
        putc(fd, c);
 586:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 589:	0f be c0             	movsbl %al,%eax
 58c:	89 44 24 04          	mov    %eax,0x4(%esp)
 590:	8b 45 08             	mov    0x8(%ebp),%eax
 593:	89 04 24             	mov    %eax,(%esp)
 596:	e8 95 fd ff ff       	call   330 <putc>
      }
      state = 0;
 59b:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 5a2:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 5a6:	8b 55 0c             	mov    0xc(%ebp),%edx
 5a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
 5ac:	01 d0                	add    %edx,%eax
 5ae:	0f b6 00             	movzbl (%eax),%eax
 5b1:	84 c0                	test   %al,%al
 5b3:	0f 85 70 fe ff ff    	jne    429 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 5b9:	c9                   	leave  
 5ba:	c3                   	ret    
 5bb:	90                   	nop

000005bc <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 5bc:	55                   	push   %ebp
 5bd:	89 e5                	mov    %esp,%ebp
 5bf:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 5c2:	8b 45 08             	mov    0x8(%ebp),%eax
 5c5:	83 e8 08             	sub    $0x8,%eax
 5c8:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 5cb:	a1 2c 0a 00 00       	mov    0xa2c,%eax
 5d0:	89 45 fc             	mov    %eax,-0x4(%ebp)
 5d3:	eb 24                	jmp    5f9 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 5d5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 5d8:	8b 00                	mov    (%eax),%eax
 5da:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 5dd:	77 12                	ja     5f1 <free+0x35>
 5df:	8b 45 f8             	mov    -0x8(%ebp),%eax
 5e2:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 5e5:	77 24                	ja     60b <free+0x4f>
 5e7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 5ea:	8b 00                	mov    (%eax),%eax
 5ec:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 5ef:	77 1a                	ja     60b <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 5f1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 5f4:	8b 00                	mov    (%eax),%eax
 5f6:	89 45 fc             	mov    %eax,-0x4(%ebp)
 5f9:	8b 45 f8             	mov    -0x8(%ebp),%eax
 5fc:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 5ff:	76 d4                	jbe    5d5 <free+0x19>
 601:	8b 45 fc             	mov    -0x4(%ebp),%eax
 604:	8b 00                	mov    (%eax),%eax
 606:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 609:	76 ca                	jbe    5d5 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 60b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 60e:	8b 40 04             	mov    0x4(%eax),%eax
 611:	c1 e0 03             	shl    $0x3,%eax
 614:	89 c2                	mov    %eax,%edx
 616:	03 55 f8             	add    -0x8(%ebp),%edx
 619:	8b 45 fc             	mov    -0x4(%ebp),%eax
 61c:	8b 00                	mov    (%eax),%eax
 61e:	39 c2                	cmp    %eax,%edx
 620:	75 24                	jne    646 <free+0x8a>
    bp->s.size += p->s.ptr->s.size;
 622:	8b 45 f8             	mov    -0x8(%ebp),%eax
 625:	8b 50 04             	mov    0x4(%eax),%edx
 628:	8b 45 fc             	mov    -0x4(%ebp),%eax
 62b:	8b 00                	mov    (%eax),%eax
 62d:	8b 40 04             	mov    0x4(%eax),%eax
 630:	01 c2                	add    %eax,%edx
 632:	8b 45 f8             	mov    -0x8(%ebp),%eax
 635:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 638:	8b 45 fc             	mov    -0x4(%ebp),%eax
 63b:	8b 00                	mov    (%eax),%eax
 63d:	8b 10                	mov    (%eax),%edx
 63f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 642:	89 10                	mov    %edx,(%eax)
 644:	eb 0a                	jmp    650 <free+0x94>
  } else
    bp->s.ptr = p->s.ptr;
 646:	8b 45 fc             	mov    -0x4(%ebp),%eax
 649:	8b 10                	mov    (%eax),%edx
 64b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 64e:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 650:	8b 45 fc             	mov    -0x4(%ebp),%eax
 653:	8b 40 04             	mov    0x4(%eax),%eax
 656:	c1 e0 03             	shl    $0x3,%eax
 659:	03 45 fc             	add    -0x4(%ebp),%eax
 65c:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 65f:	75 20                	jne    681 <free+0xc5>
    p->s.size += bp->s.size;
 661:	8b 45 fc             	mov    -0x4(%ebp),%eax
 664:	8b 50 04             	mov    0x4(%eax),%edx
 667:	8b 45 f8             	mov    -0x8(%ebp),%eax
 66a:	8b 40 04             	mov    0x4(%eax),%eax
 66d:	01 c2                	add    %eax,%edx
 66f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 672:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 675:	8b 45 f8             	mov    -0x8(%ebp),%eax
 678:	8b 10                	mov    (%eax),%edx
 67a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 67d:	89 10                	mov    %edx,(%eax)
 67f:	eb 08                	jmp    689 <free+0xcd>
  } else
    p->s.ptr = bp;
 681:	8b 45 fc             	mov    -0x4(%ebp),%eax
 684:	8b 55 f8             	mov    -0x8(%ebp),%edx
 687:	89 10                	mov    %edx,(%eax)
  freep = p;
 689:	8b 45 fc             	mov    -0x4(%ebp),%eax
 68c:	a3 2c 0a 00 00       	mov    %eax,0xa2c
}
 691:	c9                   	leave  
 692:	c3                   	ret    

00000693 <morecore>:

static Header*
morecore(uint nu)
{
 693:	55                   	push   %ebp
 694:	89 e5                	mov    %esp,%ebp
 696:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 699:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 6a0:	77 07                	ja     6a9 <morecore+0x16>
    nu = 4096;
 6a2:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 6a9:	8b 45 08             	mov    0x8(%ebp),%eax
 6ac:	c1 e0 03             	shl    $0x3,%eax
 6af:	89 04 24             	mov    %eax,(%esp)
 6b2:	e8 61 fc ff ff       	call   318 <sbrk>
 6b7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 6ba:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 6be:	75 07                	jne    6c7 <morecore+0x34>
    return 0;
 6c0:	b8 00 00 00 00       	mov    $0x0,%eax
 6c5:	eb 22                	jmp    6e9 <morecore+0x56>
  hp = (Header*)p;
 6c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6ca:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 6cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6d0:	8b 55 08             	mov    0x8(%ebp),%edx
 6d3:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 6d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6d9:	83 c0 08             	add    $0x8,%eax
 6dc:	89 04 24             	mov    %eax,(%esp)
 6df:	e8 d8 fe ff ff       	call   5bc <free>
  return freep;
 6e4:	a1 2c 0a 00 00       	mov    0xa2c,%eax
}
 6e9:	c9                   	leave  
 6ea:	c3                   	ret    

000006eb <malloc>:

void*
malloc(uint nbytes)
{
 6eb:	55                   	push   %ebp
 6ec:	89 e5                	mov    %esp,%ebp
 6ee:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 6f1:	8b 45 08             	mov    0x8(%ebp),%eax
 6f4:	83 c0 07             	add    $0x7,%eax
 6f7:	c1 e8 03             	shr    $0x3,%eax
 6fa:	83 c0 01             	add    $0x1,%eax
 6fd:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 700:	a1 2c 0a 00 00       	mov    0xa2c,%eax
 705:	89 45 f0             	mov    %eax,-0x10(%ebp)
 708:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 70c:	75 23                	jne    731 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 70e:	c7 45 f0 24 0a 00 00 	movl   $0xa24,-0x10(%ebp)
 715:	8b 45 f0             	mov    -0x10(%ebp),%eax
 718:	a3 2c 0a 00 00       	mov    %eax,0xa2c
 71d:	a1 2c 0a 00 00       	mov    0xa2c,%eax
 722:	a3 24 0a 00 00       	mov    %eax,0xa24
    base.s.size = 0;
 727:	c7 05 28 0a 00 00 00 	movl   $0x0,0xa28
 72e:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 731:	8b 45 f0             	mov    -0x10(%ebp),%eax
 734:	8b 00                	mov    (%eax),%eax
 736:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 739:	8b 45 f4             	mov    -0xc(%ebp),%eax
 73c:	8b 40 04             	mov    0x4(%eax),%eax
 73f:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 742:	72 4d                	jb     791 <malloc+0xa6>
      if(p->s.size == nunits)
 744:	8b 45 f4             	mov    -0xc(%ebp),%eax
 747:	8b 40 04             	mov    0x4(%eax),%eax
 74a:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 74d:	75 0c                	jne    75b <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 74f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 752:	8b 10                	mov    (%eax),%edx
 754:	8b 45 f0             	mov    -0x10(%ebp),%eax
 757:	89 10                	mov    %edx,(%eax)
 759:	eb 26                	jmp    781 <malloc+0x96>
      else {
        p->s.size -= nunits;
 75b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 75e:	8b 40 04             	mov    0x4(%eax),%eax
 761:	89 c2                	mov    %eax,%edx
 763:	2b 55 ec             	sub    -0x14(%ebp),%edx
 766:	8b 45 f4             	mov    -0xc(%ebp),%eax
 769:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 76c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 76f:	8b 40 04             	mov    0x4(%eax),%eax
 772:	c1 e0 03             	shl    $0x3,%eax
 775:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 778:	8b 45 f4             	mov    -0xc(%ebp),%eax
 77b:	8b 55 ec             	mov    -0x14(%ebp),%edx
 77e:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 781:	8b 45 f0             	mov    -0x10(%ebp),%eax
 784:	a3 2c 0a 00 00       	mov    %eax,0xa2c
      return (void*)(p + 1);
 789:	8b 45 f4             	mov    -0xc(%ebp),%eax
 78c:	83 c0 08             	add    $0x8,%eax
 78f:	eb 38                	jmp    7c9 <malloc+0xde>
    }
    if(p == freep)
 791:	a1 2c 0a 00 00       	mov    0xa2c,%eax
 796:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 799:	75 1b                	jne    7b6 <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 79b:	8b 45 ec             	mov    -0x14(%ebp),%eax
 79e:	89 04 24             	mov    %eax,(%esp)
 7a1:	e8 ed fe ff ff       	call   693 <morecore>
 7a6:	89 45 f4             	mov    %eax,-0xc(%ebp)
 7a9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 7ad:	75 07                	jne    7b6 <malloc+0xcb>
        return 0;
 7af:	b8 00 00 00 00       	mov    $0x0,%eax
 7b4:	eb 13                	jmp    7c9 <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7b9:	89 45 f0             	mov    %eax,-0x10(%ebp)
 7bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7bf:	8b 00                	mov    (%eax),%eax
 7c1:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 7c4:	e9 70 ff ff ff       	jmp    739 <malloc+0x4e>
}
 7c9:	c9                   	leave  
 7ca:	c3                   	ret    
