
_ln:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "stat.h"
#include "user.h"

int
main(int argc, char *argv[])
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 e4 f0             	and    $0xfffffff0,%esp
   6:	83 ec 10             	sub    $0x10,%esp
  if(argc != 3){
   9:	83 7d 08 03          	cmpl   $0x3,0x8(%ebp)
   d:	74 20                	je     2f <main+0x2f>
    printf(2, "Usage: ln old new\n");
   f:	c7 44 24 04 2f 08 00 	movl   $0x82f,0x4(%esp)
  16:	00 
  17:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  1e:	e8 48 04 00 00       	call   46b <printf>
    exit(EXIT_STATUS_DEFAULT);
  23:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  2a:	e8 bd 02 00 00       	call   2ec <exit>
  }
  if(link(argv[1], argv[2]) < 0)
  2f:	8b 45 0c             	mov    0xc(%ebp),%eax
  32:	83 c0 08             	add    $0x8,%eax
  35:	8b 10                	mov    (%eax),%edx
  37:	8b 45 0c             	mov    0xc(%ebp),%eax
  3a:	83 c0 04             	add    $0x4,%eax
  3d:	8b 00                	mov    (%eax),%eax
  3f:	89 54 24 04          	mov    %edx,0x4(%esp)
  43:	89 04 24             	mov    %eax,(%esp)
  46:	e8 01 03 00 00       	call   34c <link>
  4b:	85 c0                	test   %eax,%eax
  4d:	79 2c                	jns    7b <main+0x7b>
    printf(2, "link %s %s: failed\n", argv[1], argv[2]);
  4f:	8b 45 0c             	mov    0xc(%ebp),%eax
  52:	83 c0 08             	add    $0x8,%eax
  55:	8b 10                	mov    (%eax),%edx
  57:	8b 45 0c             	mov    0xc(%ebp),%eax
  5a:	83 c0 04             	add    $0x4,%eax
  5d:	8b 00                	mov    (%eax),%eax
  5f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  63:	89 44 24 08          	mov    %eax,0x8(%esp)
  67:	c7 44 24 04 42 08 00 	movl   $0x842,0x4(%esp)
  6e:	00 
  6f:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  76:	e8 f0 03 00 00       	call   46b <printf>
  exit(EXIT_STATUS_DEFAULT);
  7b:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  82:	e8 65 02 00 00       	call   2ec <exit>
  87:	90                   	nop

00000088 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
  88:	55                   	push   %ebp
  89:	89 e5                	mov    %esp,%ebp
  8b:	57                   	push   %edi
  8c:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
  8d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  90:	8b 55 10             	mov    0x10(%ebp),%edx
  93:	8b 45 0c             	mov    0xc(%ebp),%eax
  96:	89 cb                	mov    %ecx,%ebx
  98:	89 df                	mov    %ebx,%edi
  9a:	89 d1                	mov    %edx,%ecx
  9c:	fc                   	cld    
  9d:	f3 aa                	rep stos %al,%es:(%edi)
  9f:	89 ca                	mov    %ecx,%edx
  a1:	89 fb                	mov    %edi,%ebx
  a3:	89 5d 08             	mov    %ebx,0x8(%ebp)
  a6:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
  a9:	5b                   	pop    %ebx
  aa:	5f                   	pop    %edi
  ab:	5d                   	pop    %ebp
  ac:	c3                   	ret    

000000ad <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
  ad:	55                   	push   %ebp
  ae:	89 e5                	mov    %esp,%ebp
  b0:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
  b3:	8b 45 08             	mov    0x8(%ebp),%eax
  b6:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
  b9:	90                   	nop
  ba:	8b 45 0c             	mov    0xc(%ebp),%eax
  bd:	0f b6 10             	movzbl (%eax),%edx
  c0:	8b 45 08             	mov    0x8(%ebp),%eax
  c3:	88 10                	mov    %dl,(%eax)
  c5:	8b 45 08             	mov    0x8(%ebp),%eax
  c8:	0f b6 00             	movzbl (%eax),%eax
  cb:	84 c0                	test   %al,%al
  cd:	0f 95 c0             	setne  %al
  d0:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  d4:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  d8:	84 c0                	test   %al,%al
  da:	75 de                	jne    ba <strcpy+0xd>
    ;
  return os;
  dc:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  df:	c9                   	leave  
  e0:	c3                   	ret    

000000e1 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  e1:	55                   	push   %ebp
  e2:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
  e4:	eb 08                	jmp    ee <strcmp+0xd>
    p++, q++;
  e6:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  ea:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
  ee:	8b 45 08             	mov    0x8(%ebp),%eax
  f1:	0f b6 00             	movzbl (%eax),%eax
  f4:	84 c0                	test   %al,%al
  f6:	74 10                	je     108 <strcmp+0x27>
  f8:	8b 45 08             	mov    0x8(%ebp),%eax
  fb:	0f b6 10             	movzbl (%eax),%edx
  fe:	8b 45 0c             	mov    0xc(%ebp),%eax
 101:	0f b6 00             	movzbl (%eax),%eax
 104:	38 c2                	cmp    %al,%dl
 106:	74 de                	je     e6 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 108:	8b 45 08             	mov    0x8(%ebp),%eax
 10b:	0f b6 00             	movzbl (%eax),%eax
 10e:	0f b6 d0             	movzbl %al,%edx
 111:	8b 45 0c             	mov    0xc(%ebp),%eax
 114:	0f b6 00             	movzbl (%eax),%eax
 117:	0f b6 c0             	movzbl %al,%eax
 11a:	89 d1                	mov    %edx,%ecx
 11c:	29 c1                	sub    %eax,%ecx
 11e:	89 c8                	mov    %ecx,%eax
}
 120:	5d                   	pop    %ebp
 121:	c3                   	ret    

00000122 <strlen>:

uint
strlen(char *s)
{
 122:	55                   	push   %ebp
 123:	89 e5                	mov    %esp,%ebp
 125:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 128:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 12f:	eb 04                	jmp    135 <strlen+0x13>
 131:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 135:	8b 45 fc             	mov    -0x4(%ebp),%eax
 138:	03 45 08             	add    0x8(%ebp),%eax
 13b:	0f b6 00             	movzbl (%eax),%eax
 13e:	84 c0                	test   %al,%al
 140:	75 ef                	jne    131 <strlen+0xf>
    ;
  return n;
 142:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 145:	c9                   	leave  
 146:	c3                   	ret    

00000147 <memset>:

void*
memset(void *dst, int c, uint n)
{
 147:	55                   	push   %ebp
 148:	89 e5                	mov    %esp,%ebp
 14a:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 14d:	8b 45 10             	mov    0x10(%ebp),%eax
 150:	89 44 24 08          	mov    %eax,0x8(%esp)
 154:	8b 45 0c             	mov    0xc(%ebp),%eax
 157:	89 44 24 04          	mov    %eax,0x4(%esp)
 15b:	8b 45 08             	mov    0x8(%ebp),%eax
 15e:	89 04 24             	mov    %eax,(%esp)
 161:	e8 22 ff ff ff       	call   88 <stosb>
  return dst;
 166:	8b 45 08             	mov    0x8(%ebp),%eax
}
 169:	c9                   	leave  
 16a:	c3                   	ret    

0000016b <strchr>:

char*
strchr(const char *s, char c)
{
 16b:	55                   	push   %ebp
 16c:	89 e5                	mov    %esp,%ebp
 16e:	83 ec 04             	sub    $0x4,%esp
 171:	8b 45 0c             	mov    0xc(%ebp),%eax
 174:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 177:	eb 14                	jmp    18d <strchr+0x22>
    if(*s == c)
 179:	8b 45 08             	mov    0x8(%ebp),%eax
 17c:	0f b6 00             	movzbl (%eax),%eax
 17f:	3a 45 fc             	cmp    -0x4(%ebp),%al
 182:	75 05                	jne    189 <strchr+0x1e>
      return (char*)s;
 184:	8b 45 08             	mov    0x8(%ebp),%eax
 187:	eb 13                	jmp    19c <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 189:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 18d:	8b 45 08             	mov    0x8(%ebp),%eax
 190:	0f b6 00             	movzbl (%eax),%eax
 193:	84 c0                	test   %al,%al
 195:	75 e2                	jne    179 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 197:	b8 00 00 00 00       	mov    $0x0,%eax
}
 19c:	c9                   	leave  
 19d:	c3                   	ret    

0000019e <gets>:

char*
gets(char *buf, int max)
{
 19e:	55                   	push   %ebp
 19f:	89 e5                	mov    %esp,%ebp
 1a1:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1a4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 1ab:	eb 44                	jmp    1f1 <gets+0x53>
    cc = read(0, &c, 1);
 1ad:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 1b4:	00 
 1b5:	8d 45 ef             	lea    -0x11(%ebp),%eax
 1b8:	89 44 24 04          	mov    %eax,0x4(%esp)
 1bc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 1c3:	e8 3c 01 00 00       	call   304 <read>
 1c8:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 1cb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 1cf:	7e 2d                	jle    1fe <gets+0x60>
      break;
    buf[i++] = c;
 1d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1d4:	03 45 08             	add    0x8(%ebp),%eax
 1d7:	0f b6 55 ef          	movzbl -0x11(%ebp),%edx
 1db:	88 10                	mov    %dl,(%eax)
 1dd:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(c == '\n' || c == '\r')
 1e1:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1e5:	3c 0a                	cmp    $0xa,%al
 1e7:	74 16                	je     1ff <gets+0x61>
 1e9:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1ed:	3c 0d                	cmp    $0xd,%al
 1ef:	74 0e                	je     1ff <gets+0x61>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1f4:	83 c0 01             	add    $0x1,%eax
 1f7:	3b 45 0c             	cmp    0xc(%ebp),%eax
 1fa:	7c b1                	jl     1ad <gets+0xf>
 1fc:	eb 01                	jmp    1ff <gets+0x61>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 1fe:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 1ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
 202:	03 45 08             	add    0x8(%ebp),%eax
 205:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 208:	8b 45 08             	mov    0x8(%ebp),%eax
}
 20b:	c9                   	leave  
 20c:	c3                   	ret    

0000020d <stat>:

int
stat(char *n, struct stat *st)
{
 20d:	55                   	push   %ebp
 20e:	89 e5                	mov    %esp,%ebp
 210:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 213:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 21a:	00 
 21b:	8b 45 08             	mov    0x8(%ebp),%eax
 21e:	89 04 24             	mov    %eax,(%esp)
 221:	e8 06 01 00 00       	call   32c <open>
 226:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 229:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 22d:	79 07                	jns    236 <stat+0x29>
    return -1;
 22f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 234:	eb 23                	jmp    259 <stat+0x4c>
  r = fstat(fd, st);
 236:	8b 45 0c             	mov    0xc(%ebp),%eax
 239:	89 44 24 04          	mov    %eax,0x4(%esp)
 23d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 240:	89 04 24             	mov    %eax,(%esp)
 243:	e8 fc 00 00 00       	call   344 <fstat>
 248:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 24b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 24e:	89 04 24             	mov    %eax,(%esp)
 251:	e8 be 00 00 00       	call   314 <close>
  return r;
 256:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 259:	c9                   	leave  
 25a:	c3                   	ret    

0000025b <atoi>:

int
atoi(const char *s)
{
 25b:	55                   	push   %ebp
 25c:	89 e5                	mov    %esp,%ebp
 25e:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 261:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 268:	eb 23                	jmp    28d <atoi+0x32>
    n = n*10 + *s++ - '0';
 26a:	8b 55 fc             	mov    -0x4(%ebp),%edx
 26d:	89 d0                	mov    %edx,%eax
 26f:	c1 e0 02             	shl    $0x2,%eax
 272:	01 d0                	add    %edx,%eax
 274:	01 c0                	add    %eax,%eax
 276:	89 c2                	mov    %eax,%edx
 278:	8b 45 08             	mov    0x8(%ebp),%eax
 27b:	0f b6 00             	movzbl (%eax),%eax
 27e:	0f be c0             	movsbl %al,%eax
 281:	01 d0                	add    %edx,%eax
 283:	83 e8 30             	sub    $0x30,%eax
 286:	89 45 fc             	mov    %eax,-0x4(%ebp)
 289:	83 45 08 01          	addl   $0x1,0x8(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 28d:	8b 45 08             	mov    0x8(%ebp),%eax
 290:	0f b6 00             	movzbl (%eax),%eax
 293:	3c 2f                	cmp    $0x2f,%al
 295:	7e 0a                	jle    2a1 <atoi+0x46>
 297:	8b 45 08             	mov    0x8(%ebp),%eax
 29a:	0f b6 00             	movzbl (%eax),%eax
 29d:	3c 39                	cmp    $0x39,%al
 29f:	7e c9                	jle    26a <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 2a1:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 2a4:	c9                   	leave  
 2a5:	c3                   	ret    

000002a6 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 2a6:	55                   	push   %ebp
 2a7:	89 e5                	mov    %esp,%ebp
 2a9:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 2ac:	8b 45 08             	mov    0x8(%ebp),%eax
 2af:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 2b2:	8b 45 0c             	mov    0xc(%ebp),%eax
 2b5:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 2b8:	eb 13                	jmp    2cd <memmove+0x27>
    *dst++ = *src++;
 2ba:	8b 45 f8             	mov    -0x8(%ebp),%eax
 2bd:	0f b6 10             	movzbl (%eax),%edx
 2c0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 2c3:	88 10                	mov    %dl,(%eax)
 2c5:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 2c9:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 2cd:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 2d1:	0f 9f c0             	setg   %al
 2d4:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 2d8:	84 c0                	test   %al,%al
 2da:	75 de                	jne    2ba <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 2dc:	8b 45 08             	mov    0x8(%ebp),%eax
}
 2df:	c9                   	leave  
 2e0:	c3                   	ret    
 2e1:	90                   	nop
 2e2:	90                   	nop
 2e3:	90                   	nop

000002e4 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 2e4:	b8 01 00 00 00       	mov    $0x1,%eax
 2e9:	cd 40                	int    $0x40
 2eb:	c3                   	ret    

000002ec <exit>:
SYSCALL(exit)
 2ec:	b8 02 00 00 00       	mov    $0x2,%eax
 2f1:	cd 40                	int    $0x40
 2f3:	c3                   	ret    

000002f4 <wait>:
SYSCALL(wait)
 2f4:	b8 03 00 00 00       	mov    $0x3,%eax
 2f9:	cd 40                	int    $0x40
 2fb:	c3                   	ret    

000002fc <pipe>:
SYSCALL(pipe)
 2fc:	b8 04 00 00 00       	mov    $0x4,%eax
 301:	cd 40                	int    $0x40
 303:	c3                   	ret    

00000304 <read>:
SYSCALL(read)
 304:	b8 05 00 00 00       	mov    $0x5,%eax
 309:	cd 40                	int    $0x40
 30b:	c3                   	ret    

0000030c <write>:
SYSCALL(write)
 30c:	b8 10 00 00 00       	mov    $0x10,%eax
 311:	cd 40                	int    $0x40
 313:	c3                   	ret    

00000314 <close>:
SYSCALL(close)
 314:	b8 15 00 00 00       	mov    $0x15,%eax
 319:	cd 40                	int    $0x40
 31b:	c3                   	ret    

0000031c <kill>:
SYSCALL(kill)
 31c:	b8 06 00 00 00       	mov    $0x6,%eax
 321:	cd 40                	int    $0x40
 323:	c3                   	ret    

00000324 <exec>:
SYSCALL(exec)
 324:	b8 07 00 00 00       	mov    $0x7,%eax
 329:	cd 40                	int    $0x40
 32b:	c3                   	ret    

0000032c <open>:
SYSCALL(open)
 32c:	b8 0f 00 00 00       	mov    $0xf,%eax
 331:	cd 40                	int    $0x40
 333:	c3                   	ret    

00000334 <mknod>:
SYSCALL(mknod)
 334:	b8 11 00 00 00       	mov    $0x11,%eax
 339:	cd 40                	int    $0x40
 33b:	c3                   	ret    

0000033c <unlink>:
SYSCALL(unlink)
 33c:	b8 12 00 00 00       	mov    $0x12,%eax
 341:	cd 40                	int    $0x40
 343:	c3                   	ret    

00000344 <fstat>:
SYSCALL(fstat)
 344:	b8 08 00 00 00       	mov    $0x8,%eax
 349:	cd 40                	int    $0x40
 34b:	c3                   	ret    

0000034c <link>:
SYSCALL(link)
 34c:	b8 13 00 00 00       	mov    $0x13,%eax
 351:	cd 40                	int    $0x40
 353:	c3                   	ret    

00000354 <mkdir>:
SYSCALL(mkdir)
 354:	b8 14 00 00 00       	mov    $0x14,%eax
 359:	cd 40                	int    $0x40
 35b:	c3                   	ret    

0000035c <chdir>:
SYSCALL(chdir)
 35c:	b8 09 00 00 00       	mov    $0x9,%eax
 361:	cd 40                	int    $0x40
 363:	c3                   	ret    

00000364 <dup>:
SYSCALL(dup)
 364:	b8 0a 00 00 00       	mov    $0xa,%eax
 369:	cd 40                	int    $0x40
 36b:	c3                   	ret    

0000036c <getpid>:
SYSCALL(getpid)
 36c:	b8 0b 00 00 00       	mov    $0xb,%eax
 371:	cd 40                	int    $0x40
 373:	c3                   	ret    

00000374 <sbrk>:
SYSCALL(sbrk)
 374:	b8 0c 00 00 00       	mov    $0xc,%eax
 379:	cd 40                	int    $0x40
 37b:	c3                   	ret    

0000037c <sleep>:
SYSCALL(sleep)
 37c:	b8 0d 00 00 00       	mov    $0xd,%eax
 381:	cd 40                	int    $0x40
 383:	c3                   	ret    

00000384 <uptime>:
SYSCALL(uptime)
 384:	b8 0e 00 00 00       	mov    $0xe,%eax
 389:	cd 40                	int    $0x40
 38b:	c3                   	ret    

0000038c <waitpid>:
SYSCALL(waitpid)
 38c:	b8 16 00 00 00       	mov    $0x16,%eax
 391:	cd 40                	int    $0x40
 393:	c3                   	ret    

00000394 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 394:	55                   	push   %ebp
 395:	89 e5                	mov    %esp,%ebp
 397:	83 ec 28             	sub    $0x28,%esp
 39a:	8b 45 0c             	mov    0xc(%ebp),%eax
 39d:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 3a0:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 3a7:	00 
 3a8:	8d 45 f4             	lea    -0xc(%ebp),%eax
 3ab:	89 44 24 04          	mov    %eax,0x4(%esp)
 3af:	8b 45 08             	mov    0x8(%ebp),%eax
 3b2:	89 04 24             	mov    %eax,(%esp)
 3b5:	e8 52 ff ff ff       	call   30c <write>
}
 3ba:	c9                   	leave  
 3bb:	c3                   	ret    

000003bc <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 3bc:	55                   	push   %ebp
 3bd:	89 e5                	mov    %esp,%ebp
 3bf:	83 ec 48             	sub    $0x48,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 3c2:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 3c9:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 3cd:	74 17                	je     3e6 <printint+0x2a>
 3cf:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 3d3:	79 11                	jns    3e6 <printint+0x2a>
    neg = 1;
 3d5:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 3dc:	8b 45 0c             	mov    0xc(%ebp),%eax
 3df:	f7 d8                	neg    %eax
 3e1:	89 45 ec             	mov    %eax,-0x14(%ebp)
 3e4:	eb 06                	jmp    3ec <printint+0x30>
  } else {
    x = xx;
 3e6:	8b 45 0c             	mov    0xc(%ebp),%eax
 3e9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 3ec:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 3f3:	8b 4d 10             	mov    0x10(%ebp),%ecx
 3f6:	8b 45 ec             	mov    -0x14(%ebp),%eax
 3f9:	ba 00 00 00 00       	mov    $0x0,%edx
 3fe:	f7 f1                	div    %ecx
 400:	89 d0                	mov    %edx,%eax
 402:	0f b6 90 9c 0a 00 00 	movzbl 0xa9c(%eax),%edx
 409:	8d 45 dc             	lea    -0x24(%ebp),%eax
 40c:	03 45 f4             	add    -0xc(%ebp),%eax
 40f:	88 10                	mov    %dl,(%eax)
 411:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  }while((x /= base) != 0);
 415:	8b 55 10             	mov    0x10(%ebp),%edx
 418:	89 55 d4             	mov    %edx,-0x2c(%ebp)
 41b:	8b 45 ec             	mov    -0x14(%ebp),%eax
 41e:	ba 00 00 00 00       	mov    $0x0,%edx
 423:	f7 75 d4             	divl   -0x2c(%ebp)
 426:	89 45 ec             	mov    %eax,-0x14(%ebp)
 429:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 42d:	75 c4                	jne    3f3 <printint+0x37>
  if(neg)
 42f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 433:	74 2a                	je     45f <printint+0xa3>
    buf[i++] = '-';
 435:	8d 45 dc             	lea    -0x24(%ebp),%eax
 438:	03 45 f4             	add    -0xc(%ebp),%eax
 43b:	c6 00 2d             	movb   $0x2d,(%eax)
 43e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

  while(--i >= 0)
 442:	eb 1b                	jmp    45f <printint+0xa3>
    putc(fd, buf[i]);
 444:	8d 45 dc             	lea    -0x24(%ebp),%eax
 447:	03 45 f4             	add    -0xc(%ebp),%eax
 44a:	0f b6 00             	movzbl (%eax),%eax
 44d:	0f be c0             	movsbl %al,%eax
 450:	89 44 24 04          	mov    %eax,0x4(%esp)
 454:	8b 45 08             	mov    0x8(%ebp),%eax
 457:	89 04 24             	mov    %eax,(%esp)
 45a:	e8 35 ff ff ff       	call   394 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 45f:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 463:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 467:	79 db                	jns    444 <printint+0x88>
    putc(fd, buf[i]);
}
 469:	c9                   	leave  
 46a:	c3                   	ret    

0000046b <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 46b:	55                   	push   %ebp
 46c:	89 e5                	mov    %esp,%ebp
 46e:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 471:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 478:	8d 45 0c             	lea    0xc(%ebp),%eax
 47b:	83 c0 04             	add    $0x4,%eax
 47e:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 481:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 488:	e9 7d 01 00 00       	jmp    60a <printf+0x19f>
    c = fmt[i] & 0xff;
 48d:	8b 55 0c             	mov    0xc(%ebp),%edx
 490:	8b 45 f0             	mov    -0x10(%ebp),%eax
 493:	01 d0                	add    %edx,%eax
 495:	0f b6 00             	movzbl (%eax),%eax
 498:	0f be c0             	movsbl %al,%eax
 49b:	25 ff 00 00 00       	and    $0xff,%eax
 4a0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 4a3:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 4a7:	75 2c                	jne    4d5 <printf+0x6a>
      if(c == '%'){
 4a9:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 4ad:	75 0c                	jne    4bb <printf+0x50>
        state = '%';
 4af:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 4b6:	e9 4b 01 00 00       	jmp    606 <printf+0x19b>
      } else {
        putc(fd, c);
 4bb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 4be:	0f be c0             	movsbl %al,%eax
 4c1:	89 44 24 04          	mov    %eax,0x4(%esp)
 4c5:	8b 45 08             	mov    0x8(%ebp),%eax
 4c8:	89 04 24             	mov    %eax,(%esp)
 4cb:	e8 c4 fe ff ff       	call   394 <putc>
 4d0:	e9 31 01 00 00       	jmp    606 <printf+0x19b>
      }
    } else if(state == '%'){
 4d5:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 4d9:	0f 85 27 01 00 00    	jne    606 <printf+0x19b>
      if(c == 'd'){
 4df:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 4e3:	75 2d                	jne    512 <printf+0xa7>
        printint(fd, *ap, 10, 1);
 4e5:	8b 45 e8             	mov    -0x18(%ebp),%eax
 4e8:	8b 00                	mov    (%eax),%eax
 4ea:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 4f1:	00 
 4f2:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 4f9:	00 
 4fa:	89 44 24 04          	mov    %eax,0x4(%esp)
 4fe:	8b 45 08             	mov    0x8(%ebp),%eax
 501:	89 04 24             	mov    %eax,(%esp)
 504:	e8 b3 fe ff ff       	call   3bc <printint>
        ap++;
 509:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 50d:	e9 ed 00 00 00       	jmp    5ff <printf+0x194>
      } else if(c == 'x' || c == 'p'){
 512:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 516:	74 06                	je     51e <printf+0xb3>
 518:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 51c:	75 2d                	jne    54b <printf+0xe0>
        printint(fd, *ap, 16, 0);
 51e:	8b 45 e8             	mov    -0x18(%ebp),%eax
 521:	8b 00                	mov    (%eax),%eax
 523:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 52a:	00 
 52b:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 532:	00 
 533:	89 44 24 04          	mov    %eax,0x4(%esp)
 537:	8b 45 08             	mov    0x8(%ebp),%eax
 53a:	89 04 24             	mov    %eax,(%esp)
 53d:	e8 7a fe ff ff       	call   3bc <printint>
        ap++;
 542:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 546:	e9 b4 00 00 00       	jmp    5ff <printf+0x194>
      } else if(c == 's'){
 54b:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 54f:	75 46                	jne    597 <printf+0x12c>
        s = (char*)*ap;
 551:	8b 45 e8             	mov    -0x18(%ebp),%eax
 554:	8b 00                	mov    (%eax),%eax
 556:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 559:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 55d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 561:	75 27                	jne    58a <printf+0x11f>
          s = "(null)";
 563:	c7 45 f4 56 08 00 00 	movl   $0x856,-0xc(%ebp)
        while(*s != 0){
 56a:	eb 1e                	jmp    58a <printf+0x11f>
          putc(fd, *s);
 56c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 56f:	0f b6 00             	movzbl (%eax),%eax
 572:	0f be c0             	movsbl %al,%eax
 575:	89 44 24 04          	mov    %eax,0x4(%esp)
 579:	8b 45 08             	mov    0x8(%ebp),%eax
 57c:	89 04 24             	mov    %eax,(%esp)
 57f:	e8 10 fe ff ff       	call   394 <putc>
          s++;
 584:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 588:	eb 01                	jmp    58b <printf+0x120>
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 58a:	90                   	nop
 58b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 58e:	0f b6 00             	movzbl (%eax),%eax
 591:	84 c0                	test   %al,%al
 593:	75 d7                	jne    56c <printf+0x101>
 595:	eb 68                	jmp    5ff <printf+0x194>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 597:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 59b:	75 1d                	jne    5ba <printf+0x14f>
        putc(fd, *ap);
 59d:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5a0:	8b 00                	mov    (%eax),%eax
 5a2:	0f be c0             	movsbl %al,%eax
 5a5:	89 44 24 04          	mov    %eax,0x4(%esp)
 5a9:	8b 45 08             	mov    0x8(%ebp),%eax
 5ac:	89 04 24             	mov    %eax,(%esp)
 5af:	e8 e0 fd ff ff       	call   394 <putc>
        ap++;
 5b4:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 5b8:	eb 45                	jmp    5ff <printf+0x194>
      } else if(c == '%'){
 5ba:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 5be:	75 17                	jne    5d7 <printf+0x16c>
        putc(fd, c);
 5c0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 5c3:	0f be c0             	movsbl %al,%eax
 5c6:	89 44 24 04          	mov    %eax,0x4(%esp)
 5ca:	8b 45 08             	mov    0x8(%ebp),%eax
 5cd:	89 04 24             	mov    %eax,(%esp)
 5d0:	e8 bf fd ff ff       	call   394 <putc>
 5d5:	eb 28                	jmp    5ff <printf+0x194>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 5d7:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 5de:	00 
 5df:	8b 45 08             	mov    0x8(%ebp),%eax
 5e2:	89 04 24             	mov    %eax,(%esp)
 5e5:	e8 aa fd ff ff       	call   394 <putc>
        putc(fd, c);
 5ea:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 5ed:	0f be c0             	movsbl %al,%eax
 5f0:	89 44 24 04          	mov    %eax,0x4(%esp)
 5f4:	8b 45 08             	mov    0x8(%ebp),%eax
 5f7:	89 04 24             	mov    %eax,(%esp)
 5fa:	e8 95 fd ff ff       	call   394 <putc>
      }
      state = 0;
 5ff:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 606:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 60a:	8b 55 0c             	mov    0xc(%ebp),%edx
 60d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 610:	01 d0                	add    %edx,%eax
 612:	0f b6 00             	movzbl (%eax),%eax
 615:	84 c0                	test   %al,%al
 617:	0f 85 70 fe ff ff    	jne    48d <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 61d:	c9                   	leave  
 61e:	c3                   	ret    
 61f:	90                   	nop

00000620 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 620:	55                   	push   %ebp
 621:	89 e5                	mov    %esp,%ebp
 623:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 626:	8b 45 08             	mov    0x8(%ebp),%eax
 629:	83 e8 08             	sub    $0x8,%eax
 62c:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 62f:	a1 b8 0a 00 00       	mov    0xab8,%eax
 634:	89 45 fc             	mov    %eax,-0x4(%ebp)
 637:	eb 24                	jmp    65d <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 639:	8b 45 fc             	mov    -0x4(%ebp),%eax
 63c:	8b 00                	mov    (%eax),%eax
 63e:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 641:	77 12                	ja     655 <free+0x35>
 643:	8b 45 f8             	mov    -0x8(%ebp),%eax
 646:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 649:	77 24                	ja     66f <free+0x4f>
 64b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 64e:	8b 00                	mov    (%eax),%eax
 650:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 653:	77 1a                	ja     66f <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 655:	8b 45 fc             	mov    -0x4(%ebp),%eax
 658:	8b 00                	mov    (%eax),%eax
 65a:	89 45 fc             	mov    %eax,-0x4(%ebp)
 65d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 660:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 663:	76 d4                	jbe    639 <free+0x19>
 665:	8b 45 fc             	mov    -0x4(%ebp),%eax
 668:	8b 00                	mov    (%eax),%eax
 66a:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 66d:	76 ca                	jbe    639 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 66f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 672:	8b 40 04             	mov    0x4(%eax),%eax
 675:	c1 e0 03             	shl    $0x3,%eax
 678:	89 c2                	mov    %eax,%edx
 67a:	03 55 f8             	add    -0x8(%ebp),%edx
 67d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 680:	8b 00                	mov    (%eax),%eax
 682:	39 c2                	cmp    %eax,%edx
 684:	75 24                	jne    6aa <free+0x8a>
    bp->s.size += p->s.ptr->s.size;
 686:	8b 45 f8             	mov    -0x8(%ebp),%eax
 689:	8b 50 04             	mov    0x4(%eax),%edx
 68c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 68f:	8b 00                	mov    (%eax),%eax
 691:	8b 40 04             	mov    0x4(%eax),%eax
 694:	01 c2                	add    %eax,%edx
 696:	8b 45 f8             	mov    -0x8(%ebp),%eax
 699:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 69c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 69f:	8b 00                	mov    (%eax),%eax
 6a1:	8b 10                	mov    (%eax),%edx
 6a3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6a6:	89 10                	mov    %edx,(%eax)
 6a8:	eb 0a                	jmp    6b4 <free+0x94>
  } else
    bp->s.ptr = p->s.ptr;
 6aa:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6ad:	8b 10                	mov    (%eax),%edx
 6af:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6b2:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 6b4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6b7:	8b 40 04             	mov    0x4(%eax),%eax
 6ba:	c1 e0 03             	shl    $0x3,%eax
 6bd:	03 45 fc             	add    -0x4(%ebp),%eax
 6c0:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 6c3:	75 20                	jne    6e5 <free+0xc5>
    p->s.size += bp->s.size;
 6c5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6c8:	8b 50 04             	mov    0x4(%eax),%edx
 6cb:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6ce:	8b 40 04             	mov    0x4(%eax),%eax
 6d1:	01 c2                	add    %eax,%edx
 6d3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6d6:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 6d9:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6dc:	8b 10                	mov    (%eax),%edx
 6de:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6e1:	89 10                	mov    %edx,(%eax)
 6e3:	eb 08                	jmp    6ed <free+0xcd>
  } else
    p->s.ptr = bp;
 6e5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6e8:	8b 55 f8             	mov    -0x8(%ebp),%edx
 6eb:	89 10                	mov    %edx,(%eax)
  freep = p;
 6ed:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6f0:	a3 b8 0a 00 00       	mov    %eax,0xab8
}
 6f5:	c9                   	leave  
 6f6:	c3                   	ret    

000006f7 <morecore>:

static Header*
morecore(uint nu)
{
 6f7:	55                   	push   %ebp
 6f8:	89 e5                	mov    %esp,%ebp
 6fa:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 6fd:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 704:	77 07                	ja     70d <morecore+0x16>
    nu = 4096;
 706:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 70d:	8b 45 08             	mov    0x8(%ebp),%eax
 710:	c1 e0 03             	shl    $0x3,%eax
 713:	89 04 24             	mov    %eax,(%esp)
 716:	e8 59 fc ff ff       	call   374 <sbrk>
 71b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 71e:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 722:	75 07                	jne    72b <morecore+0x34>
    return 0;
 724:	b8 00 00 00 00       	mov    $0x0,%eax
 729:	eb 22                	jmp    74d <morecore+0x56>
  hp = (Header*)p;
 72b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 72e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 731:	8b 45 f0             	mov    -0x10(%ebp),%eax
 734:	8b 55 08             	mov    0x8(%ebp),%edx
 737:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 73a:	8b 45 f0             	mov    -0x10(%ebp),%eax
 73d:	83 c0 08             	add    $0x8,%eax
 740:	89 04 24             	mov    %eax,(%esp)
 743:	e8 d8 fe ff ff       	call   620 <free>
  return freep;
 748:	a1 b8 0a 00 00       	mov    0xab8,%eax
}
 74d:	c9                   	leave  
 74e:	c3                   	ret    

0000074f <malloc>:

void*
malloc(uint nbytes)
{
 74f:	55                   	push   %ebp
 750:	89 e5                	mov    %esp,%ebp
 752:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 755:	8b 45 08             	mov    0x8(%ebp),%eax
 758:	83 c0 07             	add    $0x7,%eax
 75b:	c1 e8 03             	shr    $0x3,%eax
 75e:	83 c0 01             	add    $0x1,%eax
 761:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 764:	a1 b8 0a 00 00       	mov    0xab8,%eax
 769:	89 45 f0             	mov    %eax,-0x10(%ebp)
 76c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 770:	75 23                	jne    795 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 772:	c7 45 f0 b0 0a 00 00 	movl   $0xab0,-0x10(%ebp)
 779:	8b 45 f0             	mov    -0x10(%ebp),%eax
 77c:	a3 b8 0a 00 00       	mov    %eax,0xab8
 781:	a1 b8 0a 00 00       	mov    0xab8,%eax
 786:	a3 b0 0a 00 00       	mov    %eax,0xab0
    base.s.size = 0;
 78b:	c7 05 b4 0a 00 00 00 	movl   $0x0,0xab4
 792:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 795:	8b 45 f0             	mov    -0x10(%ebp),%eax
 798:	8b 00                	mov    (%eax),%eax
 79a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 79d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7a0:	8b 40 04             	mov    0x4(%eax),%eax
 7a3:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 7a6:	72 4d                	jb     7f5 <malloc+0xa6>
      if(p->s.size == nunits)
 7a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7ab:	8b 40 04             	mov    0x4(%eax),%eax
 7ae:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 7b1:	75 0c                	jne    7bf <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 7b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7b6:	8b 10                	mov    (%eax),%edx
 7b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7bb:	89 10                	mov    %edx,(%eax)
 7bd:	eb 26                	jmp    7e5 <malloc+0x96>
      else {
        p->s.size -= nunits;
 7bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7c2:	8b 40 04             	mov    0x4(%eax),%eax
 7c5:	89 c2                	mov    %eax,%edx
 7c7:	2b 55 ec             	sub    -0x14(%ebp),%edx
 7ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7cd:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 7d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7d3:	8b 40 04             	mov    0x4(%eax),%eax
 7d6:	c1 e0 03             	shl    $0x3,%eax
 7d9:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 7dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7df:	8b 55 ec             	mov    -0x14(%ebp),%edx
 7e2:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 7e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7e8:	a3 b8 0a 00 00       	mov    %eax,0xab8
      return (void*)(p + 1);
 7ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7f0:	83 c0 08             	add    $0x8,%eax
 7f3:	eb 38                	jmp    82d <malloc+0xde>
    }
    if(p == freep)
 7f5:	a1 b8 0a 00 00       	mov    0xab8,%eax
 7fa:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 7fd:	75 1b                	jne    81a <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 7ff:	8b 45 ec             	mov    -0x14(%ebp),%eax
 802:	89 04 24             	mov    %eax,(%esp)
 805:	e8 ed fe ff ff       	call   6f7 <morecore>
 80a:	89 45 f4             	mov    %eax,-0xc(%ebp)
 80d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 811:	75 07                	jne    81a <malloc+0xcb>
        return 0;
 813:	b8 00 00 00 00       	mov    $0x0,%eax
 818:	eb 13                	jmp    82d <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 81a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 81d:	89 45 f0             	mov    %eax,-0x10(%ebp)
 820:	8b 45 f4             	mov    -0xc(%ebp),%eax
 823:	8b 00                	mov    (%eax),%eax
 825:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 828:	e9 70 ff ff ff       	jmp    79d <malloc+0x4e>
}
 82d:	c9                   	leave  
 82e:	c3                   	ret    
