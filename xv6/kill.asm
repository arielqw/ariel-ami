
_kill:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "stat.h"
#include "user.h"

int
main(int argc, char **argv)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 e4 f0             	and    $0xfffffff0,%esp
   6:	83 ec 20             	sub    $0x20,%esp
  int i;

  if(argc < 1){
   9:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
   d:	7f 20                	jg     2f <main+0x2f>
    printf(2, "usage: kill pid...\n");
   f:	c7 44 24 04 17 08 00 	movl   $0x817,0x4(%esp)
  16:	00 
  17:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  1e:	e8 30 04 00 00       	call   453 <printf>
    exit(EXIT_STATUS_DEFAULT);
  23:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  2a:	e8 a5 02 00 00       	call   2d4 <exit>
  }
  for(i=1; i<argc; i++)
  2f:	c7 44 24 1c 01 00 00 	movl   $0x1,0x1c(%esp)
  36:	00 
  37:	eb 21                	jmp    5a <main+0x5a>
    kill(atoi(argv[i]));
  39:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  3d:	c1 e0 02             	shl    $0x2,%eax
  40:	03 45 0c             	add    0xc(%ebp),%eax
  43:	8b 00                	mov    (%eax),%eax
  45:	89 04 24             	mov    %eax,(%esp)
  48:	e8 f6 01 00 00       	call   243 <atoi>
  4d:	89 04 24             	mov    %eax,(%esp)
  50:	e8 af 02 00 00       	call   304 <kill>

  if(argc < 1){
    printf(2, "usage: kill pid...\n");
    exit(EXIT_STATUS_DEFAULT);
  }
  for(i=1; i<argc; i++)
  55:	83 44 24 1c 01       	addl   $0x1,0x1c(%esp)
  5a:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  5e:	3b 45 08             	cmp    0x8(%ebp),%eax
  61:	7c d6                	jl     39 <main+0x39>
    kill(atoi(argv[i]));
  exit(EXIT_STATUS_DEFAULT);
  63:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  6a:	e8 65 02 00 00       	call   2d4 <exit>
  6f:	90                   	nop

00000070 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
  70:	55                   	push   %ebp
  71:	89 e5                	mov    %esp,%ebp
  73:	57                   	push   %edi
  74:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
  75:	8b 4d 08             	mov    0x8(%ebp),%ecx
  78:	8b 55 10             	mov    0x10(%ebp),%edx
  7b:	8b 45 0c             	mov    0xc(%ebp),%eax
  7e:	89 cb                	mov    %ecx,%ebx
  80:	89 df                	mov    %ebx,%edi
  82:	89 d1                	mov    %edx,%ecx
  84:	fc                   	cld    
  85:	f3 aa                	rep stos %al,%es:(%edi)
  87:	89 ca                	mov    %ecx,%edx
  89:	89 fb                	mov    %edi,%ebx
  8b:	89 5d 08             	mov    %ebx,0x8(%ebp)
  8e:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
  91:	5b                   	pop    %ebx
  92:	5f                   	pop    %edi
  93:	5d                   	pop    %ebp
  94:	c3                   	ret    

00000095 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
  95:	55                   	push   %ebp
  96:	89 e5                	mov    %esp,%ebp
  98:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
  9b:	8b 45 08             	mov    0x8(%ebp),%eax
  9e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
  a1:	90                   	nop
  a2:	8b 45 0c             	mov    0xc(%ebp),%eax
  a5:	0f b6 10             	movzbl (%eax),%edx
  a8:	8b 45 08             	mov    0x8(%ebp),%eax
  ab:	88 10                	mov    %dl,(%eax)
  ad:	8b 45 08             	mov    0x8(%ebp),%eax
  b0:	0f b6 00             	movzbl (%eax),%eax
  b3:	84 c0                	test   %al,%al
  b5:	0f 95 c0             	setne  %al
  b8:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  bc:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  c0:	84 c0                	test   %al,%al
  c2:	75 de                	jne    a2 <strcpy+0xd>
    ;
  return os;
  c4:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  c7:	c9                   	leave  
  c8:	c3                   	ret    

000000c9 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  c9:	55                   	push   %ebp
  ca:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
  cc:	eb 08                	jmp    d6 <strcmp+0xd>
    p++, q++;
  ce:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  d2:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
  d6:	8b 45 08             	mov    0x8(%ebp),%eax
  d9:	0f b6 00             	movzbl (%eax),%eax
  dc:	84 c0                	test   %al,%al
  de:	74 10                	je     f0 <strcmp+0x27>
  e0:	8b 45 08             	mov    0x8(%ebp),%eax
  e3:	0f b6 10             	movzbl (%eax),%edx
  e6:	8b 45 0c             	mov    0xc(%ebp),%eax
  e9:	0f b6 00             	movzbl (%eax),%eax
  ec:	38 c2                	cmp    %al,%dl
  ee:	74 de                	je     ce <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
  f0:	8b 45 08             	mov    0x8(%ebp),%eax
  f3:	0f b6 00             	movzbl (%eax),%eax
  f6:	0f b6 d0             	movzbl %al,%edx
  f9:	8b 45 0c             	mov    0xc(%ebp),%eax
  fc:	0f b6 00             	movzbl (%eax),%eax
  ff:	0f b6 c0             	movzbl %al,%eax
 102:	89 d1                	mov    %edx,%ecx
 104:	29 c1                	sub    %eax,%ecx
 106:	89 c8                	mov    %ecx,%eax
}
 108:	5d                   	pop    %ebp
 109:	c3                   	ret    

0000010a <strlen>:

uint
strlen(char *s)
{
 10a:	55                   	push   %ebp
 10b:	89 e5                	mov    %esp,%ebp
 10d:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 110:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 117:	eb 04                	jmp    11d <strlen+0x13>
 119:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 11d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 120:	03 45 08             	add    0x8(%ebp),%eax
 123:	0f b6 00             	movzbl (%eax),%eax
 126:	84 c0                	test   %al,%al
 128:	75 ef                	jne    119 <strlen+0xf>
    ;
  return n;
 12a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 12d:	c9                   	leave  
 12e:	c3                   	ret    

0000012f <memset>:

void*
memset(void *dst, int c, uint n)
{
 12f:	55                   	push   %ebp
 130:	89 e5                	mov    %esp,%ebp
 132:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 135:	8b 45 10             	mov    0x10(%ebp),%eax
 138:	89 44 24 08          	mov    %eax,0x8(%esp)
 13c:	8b 45 0c             	mov    0xc(%ebp),%eax
 13f:	89 44 24 04          	mov    %eax,0x4(%esp)
 143:	8b 45 08             	mov    0x8(%ebp),%eax
 146:	89 04 24             	mov    %eax,(%esp)
 149:	e8 22 ff ff ff       	call   70 <stosb>
  return dst;
 14e:	8b 45 08             	mov    0x8(%ebp),%eax
}
 151:	c9                   	leave  
 152:	c3                   	ret    

00000153 <strchr>:

char*
strchr(const char *s, char c)
{
 153:	55                   	push   %ebp
 154:	89 e5                	mov    %esp,%ebp
 156:	83 ec 04             	sub    $0x4,%esp
 159:	8b 45 0c             	mov    0xc(%ebp),%eax
 15c:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 15f:	eb 14                	jmp    175 <strchr+0x22>
    if(*s == c)
 161:	8b 45 08             	mov    0x8(%ebp),%eax
 164:	0f b6 00             	movzbl (%eax),%eax
 167:	3a 45 fc             	cmp    -0x4(%ebp),%al
 16a:	75 05                	jne    171 <strchr+0x1e>
      return (char*)s;
 16c:	8b 45 08             	mov    0x8(%ebp),%eax
 16f:	eb 13                	jmp    184 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 171:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 175:	8b 45 08             	mov    0x8(%ebp),%eax
 178:	0f b6 00             	movzbl (%eax),%eax
 17b:	84 c0                	test   %al,%al
 17d:	75 e2                	jne    161 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 17f:	b8 00 00 00 00       	mov    $0x0,%eax
}
 184:	c9                   	leave  
 185:	c3                   	ret    

00000186 <gets>:

char*
gets(char *buf, int max)
{
 186:	55                   	push   %ebp
 187:	89 e5                	mov    %esp,%ebp
 189:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 18c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 193:	eb 44                	jmp    1d9 <gets+0x53>
    cc = read(0, &c, 1);
 195:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 19c:	00 
 19d:	8d 45 ef             	lea    -0x11(%ebp),%eax
 1a0:	89 44 24 04          	mov    %eax,0x4(%esp)
 1a4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 1ab:	e8 3c 01 00 00       	call   2ec <read>
 1b0:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 1b3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 1b7:	7e 2d                	jle    1e6 <gets+0x60>
      break;
    buf[i++] = c;
 1b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1bc:	03 45 08             	add    0x8(%ebp),%eax
 1bf:	0f b6 55 ef          	movzbl -0x11(%ebp),%edx
 1c3:	88 10                	mov    %dl,(%eax)
 1c5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(c == '\n' || c == '\r')
 1c9:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1cd:	3c 0a                	cmp    $0xa,%al
 1cf:	74 16                	je     1e7 <gets+0x61>
 1d1:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1d5:	3c 0d                	cmp    $0xd,%al
 1d7:	74 0e                	je     1e7 <gets+0x61>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1dc:	83 c0 01             	add    $0x1,%eax
 1df:	3b 45 0c             	cmp    0xc(%ebp),%eax
 1e2:	7c b1                	jl     195 <gets+0xf>
 1e4:	eb 01                	jmp    1e7 <gets+0x61>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 1e6:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 1e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1ea:	03 45 08             	add    0x8(%ebp),%eax
 1ed:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 1f0:	8b 45 08             	mov    0x8(%ebp),%eax
}
 1f3:	c9                   	leave  
 1f4:	c3                   	ret    

000001f5 <stat>:

int
stat(char *n, struct stat *st)
{
 1f5:	55                   	push   %ebp
 1f6:	89 e5                	mov    %esp,%ebp
 1f8:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1fb:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 202:	00 
 203:	8b 45 08             	mov    0x8(%ebp),%eax
 206:	89 04 24             	mov    %eax,(%esp)
 209:	e8 06 01 00 00       	call   314 <open>
 20e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 211:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 215:	79 07                	jns    21e <stat+0x29>
    return -1;
 217:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 21c:	eb 23                	jmp    241 <stat+0x4c>
  r = fstat(fd, st);
 21e:	8b 45 0c             	mov    0xc(%ebp),%eax
 221:	89 44 24 04          	mov    %eax,0x4(%esp)
 225:	8b 45 f4             	mov    -0xc(%ebp),%eax
 228:	89 04 24             	mov    %eax,(%esp)
 22b:	e8 fc 00 00 00       	call   32c <fstat>
 230:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 233:	8b 45 f4             	mov    -0xc(%ebp),%eax
 236:	89 04 24             	mov    %eax,(%esp)
 239:	e8 be 00 00 00       	call   2fc <close>
  return r;
 23e:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 241:	c9                   	leave  
 242:	c3                   	ret    

00000243 <atoi>:

int
atoi(const char *s)
{
 243:	55                   	push   %ebp
 244:	89 e5                	mov    %esp,%ebp
 246:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 249:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 250:	eb 23                	jmp    275 <atoi+0x32>
    n = n*10 + *s++ - '0';
 252:	8b 55 fc             	mov    -0x4(%ebp),%edx
 255:	89 d0                	mov    %edx,%eax
 257:	c1 e0 02             	shl    $0x2,%eax
 25a:	01 d0                	add    %edx,%eax
 25c:	01 c0                	add    %eax,%eax
 25e:	89 c2                	mov    %eax,%edx
 260:	8b 45 08             	mov    0x8(%ebp),%eax
 263:	0f b6 00             	movzbl (%eax),%eax
 266:	0f be c0             	movsbl %al,%eax
 269:	01 d0                	add    %edx,%eax
 26b:	83 e8 30             	sub    $0x30,%eax
 26e:	89 45 fc             	mov    %eax,-0x4(%ebp)
 271:	83 45 08 01          	addl   $0x1,0x8(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 275:	8b 45 08             	mov    0x8(%ebp),%eax
 278:	0f b6 00             	movzbl (%eax),%eax
 27b:	3c 2f                	cmp    $0x2f,%al
 27d:	7e 0a                	jle    289 <atoi+0x46>
 27f:	8b 45 08             	mov    0x8(%ebp),%eax
 282:	0f b6 00             	movzbl (%eax),%eax
 285:	3c 39                	cmp    $0x39,%al
 287:	7e c9                	jle    252 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 289:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 28c:	c9                   	leave  
 28d:	c3                   	ret    

0000028e <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 28e:	55                   	push   %ebp
 28f:	89 e5                	mov    %esp,%ebp
 291:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 294:	8b 45 08             	mov    0x8(%ebp),%eax
 297:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 29a:	8b 45 0c             	mov    0xc(%ebp),%eax
 29d:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 2a0:	eb 13                	jmp    2b5 <memmove+0x27>
    *dst++ = *src++;
 2a2:	8b 45 f8             	mov    -0x8(%ebp),%eax
 2a5:	0f b6 10             	movzbl (%eax),%edx
 2a8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 2ab:	88 10                	mov    %dl,(%eax)
 2ad:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 2b1:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 2b5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 2b9:	0f 9f c0             	setg   %al
 2bc:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 2c0:	84 c0                	test   %al,%al
 2c2:	75 de                	jne    2a2 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 2c4:	8b 45 08             	mov    0x8(%ebp),%eax
}
 2c7:	c9                   	leave  
 2c8:	c3                   	ret    
 2c9:	90                   	nop
 2ca:	90                   	nop
 2cb:	90                   	nop

000002cc <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 2cc:	b8 01 00 00 00       	mov    $0x1,%eax
 2d1:	cd 40                	int    $0x40
 2d3:	c3                   	ret    

000002d4 <exit>:
SYSCALL(exit)
 2d4:	b8 02 00 00 00       	mov    $0x2,%eax
 2d9:	cd 40                	int    $0x40
 2db:	c3                   	ret    

000002dc <wait>:
SYSCALL(wait)
 2dc:	b8 03 00 00 00       	mov    $0x3,%eax
 2e1:	cd 40                	int    $0x40
 2e3:	c3                   	ret    

000002e4 <pipe>:
SYSCALL(pipe)
 2e4:	b8 04 00 00 00       	mov    $0x4,%eax
 2e9:	cd 40                	int    $0x40
 2eb:	c3                   	ret    

000002ec <read>:
SYSCALL(read)
 2ec:	b8 05 00 00 00       	mov    $0x5,%eax
 2f1:	cd 40                	int    $0x40
 2f3:	c3                   	ret    

000002f4 <write>:
SYSCALL(write)
 2f4:	b8 10 00 00 00       	mov    $0x10,%eax
 2f9:	cd 40                	int    $0x40
 2fb:	c3                   	ret    

000002fc <close>:
SYSCALL(close)
 2fc:	b8 15 00 00 00       	mov    $0x15,%eax
 301:	cd 40                	int    $0x40
 303:	c3                   	ret    

00000304 <kill>:
SYSCALL(kill)
 304:	b8 06 00 00 00       	mov    $0x6,%eax
 309:	cd 40                	int    $0x40
 30b:	c3                   	ret    

0000030c <exec>:
SYSCALL(exec)
 30c:	b8 07 00 00 00       	mov    $0x7,%eax
 311:	cd 40                	int    $0x40
 313:	c3                   	ret    

00000314 <open>:
SYSCALL(open)
 314:	b8 0f 00 00 00       	mov    $0xf,%eax
 319:	cd 40                	int    $0x40
 31b:	c3                   	ret    

0000031c <mknod>:
SYSCALL(mknod)
 31c:	b8 11 00 00 00       	mov    $0x11,%eax
 321:	cd 40                	int    $0x40
 323:	c3                   	ret    

00000324 <unlink>:
SYSCALL(unlink)
 324:	b8 12 00 00 00       	mov    $0x12,%eax
 329:	cd 40                	int    $0x40
 32b:	c3                   	ret    

0000032c <fstat>:
SYSCALL(fstat)
 32c:	b8 08 00 00 00       	mov    $0x8,%eax
 331:	cd 40                	int    $0x40
 333:	c3                   	ret    

00000334 <link>:
SYSCALL(link)
 334:	b8 13 00 00 00       	mov    $0x13,%eax
 339:	cd 40                	int    $0x40
 33b:	c3                   	ret    

0000033c <mkdir>:
SYSCALL(mkdir)
 33c:	b8 14 00 00 00       	mov    $0x14,%eax
 341:	cd 40                	int    $0x40
 343:	c3                   	ret    

00000344 <chdir>:
SYSCALL(chdir)
 344:	b8 09 00 00 00       	mov    $0x9,%eax
 349:	cd 40                	int    $0x40
 34b:	c3                   	ret    

0000034c <dup>:
SYSCALL(dup)
 34c:	b8 0a 00 00 00       	mov    $0xa,%eax
 351:	cd 40                	int    $0x40
 353:	c3                   	ret    

00000354 <getpid>:
SYSCALL(getpid)
 354:	b8 0b 00 00 00       	mov    $0xb,%eax
 359:	cd 40                	int    $0x40
 35b:	c3                   	ret    

0000035c <sbrk>:
SYSCALL(sbrk)
 35c:	b8 0c 00 00 00       	mov    $0xc,%eax
 361:	cd 40                	int    $0x40
 363:	c3                   	ret    

00000364 <sleep>:
SYSCALL(sleep)
 364:	b8 0d 00 00 00       	mov    $0xd,%eax
 369:	cd 40                	int    $0x40
 36b:	c3                   	ret    

0000036c <uptime>:
SYSCALL(uptime)
 36c:	b8 0e 00 00 00       	mov    $0xe,%eax
 371:	cd 40                	int    $0x40
 373:	c3                   	ret    

00000374 <waitpid>:
SYSCALL(waitpid)
 374:	b8 16 00 00 00       	mov    $0x16,%eax
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
 39d:	e8 52 ff ff ff       	call   2f4 <write>
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
 3ea:	0f b6 90 70 0a 00 00 	movzbl 0xa70(%eax),%edx
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
 54b:	c7 45 f4 2b 08 00 00 	movl   $0x82b,-0xc(%ebp)
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
 617:	a1 8c 0a 00 00       	mov    0xa8c,%eax
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
 6d8:	a3 8c 0a 00 00       	mov    %eax,0xa8c
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
 6fe:	e8 59 fc ff ff       	call   35c <sbrk>
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
 730:	a1 8c 0a 00 00       	mov    0xa8c,%eax
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
 74c:	a1 8c 0a 00 00       	mov    0xa8c,%eax
 751:	89 45 f0             	mov    %eax,-0x10(%ebp)
 754:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 758:	75 23                	jne    77d <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 75a:	c7 45 f0 84 0a 00 00 	movl   $0xa84,-0x10(%ebp)
 761:	8b 45 f0             	mov    -0x10(%ebp),%eax
 764:	a3 8c 0a 00 00       	mov    %eax,0xa8c
 769:	a1 8c 0a 00 00       	mov    0xa8c,%eax
 76e:	a3 84 0a 00 00       	mov    %eax,0xa84
    base.s.size = 0;
 773:	c7 05 88 0a 00 00 00 	movl   $0x0,0xa88
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
 7d0:	a3 8c 0a 00 00       	mov    %eax,0xa8c
      return (void*)(p + 1);
 7d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7d8:	83 c0 08             	add    $0x8,%eax
 7db:	eb 38                	jmp    815 <malloc+0xde>
    }
    if(p == freep)
 7dd:	a1 8c 0a 00 00       	mov    0xa8c,%eax
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
