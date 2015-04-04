
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

00000330 <waitpid>:
SYSCALL(waitpid)
 330:	b8 16 00 00 00       	mov    $0x16,%eax
 335:	cd 40                	int    $0x40
 337:	c3                   	ret    

00000338 <wait_stat>:
SYSCALL(wait_stat)
 338:	b8 17 00 00 00       	mov    $0x17,%eax
 33d:	cd 40                	int    $0x40
 33f:	c3                   	ret    

00000340 <list_pgroup>:
SYSCALL(list_pgroup)
 340:	b8 18 00 00 00       	mov    $0x18,%eax
 345:	cd 40                	int    $0x40
 347:	c3                   	ret    

00000348 <foreground>:
SYSCALL(foreground)
 348:	b8 19 00 00 00       	mov    $0x19,%eax
 34d:	cd 40                	int    $0x40
 34f:	c3                   	ret    

00000350 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 350:	55                   	push   %ebp
 351:	89 e5                	mov    %esp,%ebp
 353:	83 ec 28             	sub    $0x28,%esp
 356:	8b 45 0c             	mov    0xc(%ebp),%eax
 359:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 35c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 363:	00 
 364:	8d 45 f4             	lea    -0xc(%ebp),%eax
 367:	89 44 24 04          	mov    %eax,0x4(%esp)
 36b:	8b 45 08             	mov    0x8(%ebp),%eax
 36e:	89 04 24             	mov    %eax,(%esp)
 371:	e8 3a ff ff ff       	call   2b0 <write>
}
 376:	c9                   	leave  
 377:	c3                   	ret    

00000378 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 378:	55                   	push   %ebp
 379:	89 e5                	mov    %esp,%ebp
 37b:	83 ec 48             	sub    $0x48,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 37e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 385:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 389:	74 17                	je     3a2 <printint+0x2a>
 38b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 38f:	79 11                	jns    3a2 <printint+0x2a>
    neg = 1;
 391:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 398:	8b 45 0c             	mov    0xc(%ebp),%eax
 39b:	f7 d8                	neg    %eax
 39d:	89 45 ec             	mov    %eax,-0x14(%ebp)
 3a0:	eb 06                	jmp    3a8 <printint+0x30>
  } else {
    x = xx;
 3a2:	8b 45 0c             	mov    0xc(%ebp),%eax
 3a5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 3a8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 3af:	8b 4d 10             	mov    0x10(%ebp),%ecx
 3b2:	8b 45 ec             	mov    -0x14(%ebp),%eax
 3b5:	ba 00 00 00 00       	mov    $0x0,%edx
 3ba:	f7 f1                	div    %ecx
 3bc:	89 d0                	mov    %edx,%eax
 3be:	0f b6 90 30 0a 00 00 	movzbl 0xa30(%eax),%edx
 3c5:	8d 45 dc             	lea    -0x24(%ebp),%eax
 3c8:	03 45 f4             	add    -0xc(%ebp),%eax
 3cb:	88 10                	mov    %dl,(%eax)
 3cd:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  }while((x /= base) != 0);
 3d1:	8b 55 10             	mov    0x10(%ebp),%edx
 3d4:	89 55 d4             	mov    %edx,-0x2c(%ebp)
 3d7:	8b 45 ec             	mov    -0x14(%ebp),%eax
 3da:	ba 00 00 00 00       	mov    $0x0,%edx
 3df:	f7 75 d4             	divl   -0x2c(%ebp)
 3e2:	89 45 ec             	mov    %eax,-0x14(%ebp)
 3e5:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 3e9:	75 c4                	jne    3af <printint+0x37>
  if(neg)
 3eb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 3ef:	74 2a                	je     41b <printint+0xa3>
    buf[i++] = '-';
 3f1:	8d 45 dc             	lea    -0x24(%ebp),%eax
 3f4:	03 45 f4             	add    -0xc(%ebp),%eax
 3f7:	c6 00 2d             	movb   $0x2d,(%eax)
 3fa:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

  while(--i >= 0)
 3fe:	eb 1b                	jmp    41b <printint+0xa3>
    putc(fd, buf[i]);
 400:	8d 45 dc             	lea    -0x24(%ebp),%eax
 403:	03 45 f4             	add    -0xc(%ebp),%eax
 406:	0f b6 00             	movzbl (%eax),%eax
 409:	0f be c0             	movsbl %al,%eax
 40c:	89 44 24 04          	mov    %eax,0x4(%esp)
 410:	8b 45 08             	mov    0x8(%ebp),%eax
 413:	89 04 24             	mov    %eax,(%esp)
 416:	e8 35 ff ff ff       	call   350 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 41b:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 41f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 423:	79 db                	jns    400 <printint+0x88>
    putc(fd, buf[i]);
}
 425:	c9                   	leave  
 426:	c3                   	ret    

00000427 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 427:	55                   	push   %ebp
 428:	89 e5                	mov    %esp,%ebp
 42a:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 42d:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 434:	8d 45 0c             	lea    0xc(%ebp),%eax
 437:	83 c0 04             	add    $0x4,%eax
 43a:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 43d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 444:	e9 7d 01 00 00       	jmp    5c6 <printf+0x19f>
    c = fmt[i] & 0xff;
 449:	8b 55 0c             	mov    0xc(%ebp),%edx
 44c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 44f:	01 d0                	add    %edx,%eax
 451:	0f b6 00             	movzbl (%eax),%eax
 454:	0f be c0             	movsbl %al,%eax
 457:	25 ff 00 00 00       	and    $0xff,%eax
 45c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 45f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 463:	75 2c                	jne    491 <printf+0x6a>
      if(c == '%'){
 465:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 469:	75 0c                	jne    477 <printf+0x50>
        state = '%';
 46b:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 472:	e9 4b 01 00 00       	jmp    5c2 <printf+0x19b>
      } else {
        putc(fd, c);
 477:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 47a:	0f be c0             	movsbl %al,%eax
 47d:	89 44 24 04          	mov    %eax,0x4(%esp)
 481:	8b 45 08             	mov    0x8(%ebp),%eax
 484:	89 04 24             	mov    %eax,(%esp)
 487:	e8 c4 fe ff ff       	call   350 <putc>
 48c:	e9 31 01 00 00       	jmp    5c2 <printf+0x19b>
      }
    } else if(state == '%'){
 491:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 495:	0f 85 27 01 00 00    	jne    5c2 <printf+0x19b>
      if(c == 'd'){
 49b:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 49f:	75 2d                	jne    4ce <printf+0xa7>
        printint(fd, *ap, 10, 1);
 4a1:	8b 45 e8             	mov    -0x18(%ebp),%eax
 4a4:	8b 00                	mov    (%eax),%eax
 4a6:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 4ad:	00 
 4ae:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 4b5:	00 
 4b6:	89 44 24 04          	mov    %eax,0x4(%esp)
 4ba:	8b 45 08             	mov    0x8(%ebp),%eax
 4bd:	89 04 24             	mov    %eax,(%esp)
 4c0:	e8 b3 fe ff ff       	call   378 <printint>
        ap++;
 4c5:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 4c9:	e9 ed 00 00 00       	jmp    5bb <printf+0x194>
      } else if(c == 'x' || c == 'p'){
 4ce:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 4d2:	74 06                	je     4da <printf+0xb3>
 4d4:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 4d8:	75 2d                	jne    507 <printf+0xe0>
        printint(fd, *ap, 16, 0);
 4da:	8b 45 e8             	mov    -0x18(%ebp),%eax
 4dd:	8b 00                	mov    (%eax),%eax
 4df:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 4e6:	00 
 4e7:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 4ee:	00 
 4ef:	89 44 24 04          	mov    %eax,0x4(%esp)
 4f3:	8b 45 08             	mov    0x8(%ebp),%eax
 4f6:	89 04 24             	mov    %eax,(%esp)
 4f9:	e8 7a fe ff ff       	call   378 <printint>
        ap++;
 4fe:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 502:	e9 b4 00 00 00       	jmp    5bb <printf+0x194>
      } else if(c == 's'){
 507:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 50b:	75 46                	jne    553 <printf+0x12c>
        s = (char*)*ap;
 50d:	8b 45 e8             	mov    -0x18(%ebp),%eax
 510:	8b 00                	mov    (%eax),%eax
 512:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 515:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 519:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 51d:	75 27                	jne    546 <printf+0x11f>
          s = "(null)";
 51f:	c7 45 f4 eb 07 00 00 	movl   $0x7eb,-0xc(%ebp)
        while(*s != 0){
 526:	eb 1e                	jmp    546 <printf+0x11f>
          putc(fd, *s);
 528:	8b 45 f4             	mov    -0xc(%ebp),%eax
 52b:	0f b6 00             	movzbl (%eax),%eax
 52e:	0f be c0             	movsbl %al,%eax
 531:	89 44 24 04          	mov    %eax,0x4(%esp)
 535:	8b 45 08             	mov    0x8(%ebp),%eax
 538:	89 04 24             	mov    %eax,(%esp)
 53b:	e8 10 fe ff ff       	call   350 <putc>
          s++;
 540:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 544:	eb 01                	jmp    547 <printf+0x120>
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 546:	90                   	nop
 547:	8b 45 f4             	mov    -0xc(%ebp),%eax
 54a:	0f b6 00             	movzbl (%eax),%eax
 54d:	84 c0                	test   %al,%al
 54f:	75 d7                	jne    528 <printf+0x101>
 551:	eb 68                	jmp    5bb <printf+0x194>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 553:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 557:	75 1d                	jne    576 <printf+0x14f>
        putc(fd, *ap);
 559:	8b 45 e8             	mov    -0x18(%ebp),%eax
 55c:	8b 00                	mov    (%eax),%eax
 55e:	0f be c0             	movsbl %al,%eax
 561:	89 44 24 04          	mov    %eax,0x4(%esp)
 565:	8b 45 08             	mov    0x8(%ebp),%eax
 568:	89 04 24             	mov    %eax,(%esp)
 56b:	e8 e0 fd ff ff       	call   350 <putc>
        ap++;
 570:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 574:	eb 45                	jmp    5bb <printf+0x194>
      } else if(c == '%'){
 576:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 57a:	75 17                	jne    593 <printf+0x16c>
        putc(fd, c);
 57c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 57f:	0f be c0             	movsbl %al,%eax
 582:	89 44 24 04          	mov    %eax,0x4(%esp)
 586:	8b 45 08             	mov    0x8(%ebp),%eax
 589:	89 04 24             	mov    %eax,(%esp)
 58c:	e8 bf fd ff ff       	call   350 <putc>
 591:	eb 28                	jmp    5bb <printf+0x194>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 593:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 59a:	00 
 59b:	8b 45 08             	mov    0x8(%ebp),%eax
 59e:	89 04 24             	mov    %eax,(%esp)
 5a1:	e8 aa fd ff ff       	call   350 <putc>
        putc(fd, c);
 5a6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 5a9:	0f be c0             	movsbl %al,%eax
 5ac:	89 44 24 04          	mov    %eax,0x4(%esp)
 5b0:	8b 45 08             	mov    0x8(%ebp),%eax
 5b3:	89 04 24             	mov    %eax,(%esp)
 5b6:	e8 95 fd ff ff       	call   350 <putc>
      }
      state = 0;
 5bb:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 5c2:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 5c6:	8b 55 0c             	mov    0xc(%ebp),%edx
 5c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
 5cc:	01 d0                	add    %edx,%eax
 5ce:	0f b6 00             	movzbl (%eax),%eax
 5d1:	84 c0                	test   %al,%al
 5d3:	0f 85 70 fe ff ff    	jne    449 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 5d9:	c9                   	leave  
 5da:	c3                   	ret    
 5db:	90                   	nop

000005dc <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 5dc:	55                   	push   %ebp
 5dd:	89 e5                	mov    %esp,%ebp
 5df:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 5e2:	8b 45 08             	mov    0x8(%ebp),%eax
 5e5:	83 e8 08             	sub    $0x8,%eax
 5e8:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 5eb:	a1 4c 0a 00 00       	mov    0xa4c,%eax
 5f0:	89 45 fc             	mov    %eax,-0x4(%ebp)
 5f3:	eb 24                	jmp    619 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 5f5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 5f8:	8b 00                	mov    (%eax),%eax
 5fa:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 5fd:	77 12                	ja     611 <free+0x35>
 5ff:	8b 45 f8             	mov    -0x8(%ebp),%eax
 602:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 605:	77 24                	ja     62b <free+0x4f>
 607:	8b 45 fc             	mov    -0x4(%ebp),%eax
 60a:	8b 00                	mov    (%eax),%eax
 60c:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 60f:	77 1a                	ja     62b <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 611:	8b 45 fc             	mov    -0x4(%ebp),%eax
 614:	8b 00                	mov    (%eax),%eax
 616:	89 45 fc             	mov    %eax,-0x4(%ebp)
 619:	8b 45 f8             	mov    -0x8(%ebp),%eax
 61c:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 61f:	76 d4                	jbe    5f5 <free+0x19>
 621:	8b 45 fc             	mov    -0x4(%ebp),%eax
 624:	8b 00                	mov    (%eax),%eax
 626:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 629:	76 ca                	jbe    5f5 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 62b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 62e:	8b 40 04             	mov    0x4(%eax),%eax
 631:	c1 e0 03             	shl    $0x3,%eax
 634:	89 c2                	mov    %eax,%edx
 636:	03 55 f8             	add    -0x8(%ebp),%edx
 639:	8b 45 fc             	mov    -0x4(%ebp),%eax
 63c:	8b 00                	mov    (%eax),%eax
 63e:	39 c2                	cmp    %eax,%edx
 640:	75 24                	jne    666 <free+0x8a>
    bp->s.size += p->s.ptr->s.size;
 642:	8b 45 f8             	mov    -0x8(%ebp),%eax
 645:	8b 50 04             	mov    0x4(%eax),%edx
 648:	8b 45 fc             	mov    -0x4(%ebp),%eax
 64b:	8b 00                	mov    (%eax),%eax
 64d:	8b 40 04             	mov    0x4(%eax),%eax
 650:	01 c2                	add    %eax,%edx
 652:	8b 45 f8             	mov    -0x8(%ebp),%eax
 655:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 658:	8b 45 fc             	mov    -0x4(%ebp),%eax
 65b:	8b 00                	mov    (%eax),%eax
 65d:	8b 10                	mov    (%eax),%edx
 65f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 662:	89 10                	mov    %edx,(%eax)
 664:	eb 0a                	jmp    670 <free+0x94>
  } else
    bp->s.ptr = p->s.ptr;
 666:	8b 45 fc             	mov    -0x4(%ebp),%eax
 669:	8b 10                	mov    (%eax),%edx
 66b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 66e:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 670:	8b 45 fc             	mov    -0x4(%ebp),%eax
 673:	8b 40 04             	mov    0x4(%eax),%eax
 676:	c1 e0 03             	shl    $0x3,%eax
 679:	03 45 fc             	add    -0x4(%ebp),%eax
 67c:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 67f:	75 20                	jne    6a1 <free+0xc5>
    p->s.size += bp->s.size;
 681:	8b 45 fc             	mov    -0x4(%ebp),%eax
 684:	8b 50 04             	mov    0x4(%eax),%edx
 687:	8b 45 f8             	mov    -0x8(%ebp),%eax
 68a:	8b 40 04             	mov    0x4(%eax),%eax
 68d:	01 c2                	add    %eax,%edx
 68f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 692:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 695:	8b 45 f8             	mov    -0x8(%ebp),%eax
 698:	8b 10                	mov    (%eax),%edx
 69a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 69d:	89 10                	mov    %edx,(%eax)
 69f:	eb 08                	jmp    6a9 <free+0xcd>
  } else
    p->s.ptr = bp;
 6a1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6a4:	8b 55 f8             	mov    -0x8(%ebp),%edx
 6a7:	89 10                	mov    %edx,(%eax)
  freep = p;
 6a9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6ac:	a3 4c 0a 00 00       	mov    %eax,0xa4c
}
 6b1:	c9                   	leave  
 6b2:	c3                   	ret    

000006b3 <morecore>:

static Header*
morecore(uint nu)
{
 6b3:	55                   	push   %ebp
 6b4:	89 e5                	mov    %esp,%ebp
 6b6:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 6b9:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 6c0:	77 07                	ja     6c9 <morecore+0x16>
    nu = 4096;
 6c2:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 6c9:	8b 45 08             	mov    0x8(%ebp),%eax
 6cc:	c1 e0 03             	shl    $0x3,%eax
 6cf:	89 04 24             	mov    %eax,(%esp)
 6d2:	e8 41 fc ff ff       	call   318 <sbrk>
 6d7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 6da:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 6de:	75 07                	jne    6e7 <morecore+0x34>
    return 0;
 6e0:	b8 00 00 00 00       	mov    $0x0,%eax
 6e5:	eb 22                	jmp    709 <morecore+0x56>
  hp = (Header*)p;
 6e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6ea:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 6ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6f0:	8b 55 08             	mov    0x8(%ebp),%edx
 6f3:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 6f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6f9:	83 c0 08             	add    $0x8,%eax
 6fc:	89 04 24             	mov    %eax,(%esp)
 6ff:	e8 d8 fe ff ff       	call   5dc <free>
  return freep;
 704:	a1 4c 0a 00 00       	mov    0xa4c,%eax
}
 709:	c9                   	leave  
 70a:	c3                   	ret    

0000070b <malloc>:

void*
malloc(uint nbytes)
{
 70b:	55                   	push   %ebp
 70c:	89 e5                	mov    %esp,%ebp
 70e:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 711:	8b 45 08             	mov    0x8(%ebp),%eax
 714:	83 c0 07             	add    $0x7,%eax
 717:	c1 e8 03             	shr    $0x3,%eax
 71a:	83 c0 01             	add    $0x1,%eax
 71d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 720:	a1 4c 0a 00 00       	mov    0xa4c,%eax
 725:	89 45 f0             	mov    %eax,-0x10(%ebp)
 728:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 72c:	75 23                	jne    751 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 72e:	c7 45 f0 44 0a 00 00 	movl   $0xa44,-0x10(%ebp)
 735:	8b 45 f0             	mov    -0x10(%ebp),%eax
 738:	a3 4c 0a 00 00       	mov    %eax,0xa4c
 73d:	a1 4c 0a 00 00       	mov    0xa4c,%eax
 742:	a3 44 0a 00 00       	mov    %eax,0xa44
    base.s.size = 0;
 747:	c7 05 48 0a 00 00 00 	movl   $0x0,0xa48
 74e:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 751:	8b 45 f0             	mov    -0x10(%ebp),%eax
 754:	8b 00                	mov    (%eax),%eax
 756:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 759:	8b 45 f4             	mov    -0xc(%ebp),%eax
 75c:	8b 40 04             	mov    0x4(%eax),%eax
 75f:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 762:	72 4d                	jb     7b1 <malloc+0xa6>
      if(p->s.size == nunits)
 764:	8b 45 f4             	mov    -0xc(%ebp),%eax
 767:	8b 40 04             	mov    0x4(%eax),%eax
 76a:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 76d:	75 0c                	jne    77b <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 76f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 772:	8b 10                	mov    (%eax),%edx
 774:	8b 45 f0             	mov    -0x10(%ebp),%eax
 777:	89 10                	mov    %edx,(%eax)
 779:	eb 26                	jmp    7a1 <malloc+0x96>
      else {
        p->s.size -= nunits;
 77b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 77e:	8b 40 04             	mov    0x4(%eax),%eax
 781:	89 c2                	mov    %eax,%edx
 783:	2b 55 ec             	sub    -0x14(%ebp),%edx
 786:	8b 45 f4             	mov    -0xc(%ebp),%eax
 789:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 78c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 78f:	8b 40 04             	mov    0x4(%eax),%eax
 792:	c1 e0 03             	shl    $0x3,%eax
 795:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 798:	8b 45 f4             	mov    -0xc(%ebp),%eax
 79b:	8b 55 ec             	mov    -0x14(%ebp),%edx
 79e:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 7a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7a4:	a3 4c 0a 00 00       	mov    %eax,0xa4c
      return (void*)(p + 1);
 7a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7ac:	83 c0 08             	add    $0x8,%eax
 7af:	eb 38                	jmp    7e9 <malloc+0xde>
    }
    if(p == freep)
 7b1:	a1 4c 0a 00 00       	mov    0xa4c,%eax
 7b6:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 7b9:	75 1b                	jne    7d6 <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 7bb:	8b 45 ec             	mov    -0x14(%ebp),%eax
 7be:	89 04 24             	mov    %eax,(%esp)
 7c1:	e8 ed fe ff ff       	call   6b3 <morecore>
 7c6:	89 45 f4             	mov    %eax,-0xc(%ebp)
 7c9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 7cd:	75 07                	jne    7d6 <malloc+0xcb>
        return 0;
 7cf:	b8 00 00 00 00       	mov    $0x0,%eax
 7d4:	eb 13                	jmp    7e9 <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7d9:	89 45 f0             	mov    %eax,-0x10(%ebp)
 7dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7df:	8b 00                	mov    (%eax),%eax
 7e1:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 7e4:	e9 70 ff ff ff       	jmp    759 <malloc+0x4e>
}
 7e9:	c9                   	leave  
 7ea:	c3                   	ret    
