
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
   f:	c7 44 24 04 4f 08 00 	movl   $0x84f,0x4(%esp)
  16:	00 
  17:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  1e:	e8 68 04 00 00       	call   48b <printf>
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
  67:	c7 44 24 04 62 08 00 	movl   $0x862,0x4(%esp)
  6e:	00 
  6f:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  76:	e8 10 04 00 00       	call   48b <printf>
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

00000394 <wait_stat>:
SYSCALL(wait_stat)
 394:	b8 17 00 00 00       	mov    $0x17,%eax
 399:	cd 40                	int    $0x40
 39b:	c3                   	ret    

0000039c <list_pgroup>:
SYSCALL(list_pgroup)
 39c:	b8 18 00 00 00       	mov    $0x18,%eax
 3a1:	cd 40                	int    $0x40
 3a3:	c3                   	ret    

000003a4 <foreground>:
SYSCALL(foreground)
 3a4:	b8 19 00 00 00       	mov    $0x19,%eax
 3a9:	cd 40                	int    $0x40
 3ab:	c3                   	ret    

000003ac <set_priority>:
SYSCALL(set_priority)
 3ac:	b8 1a 00 00 00       	mov    $0x1a,%eax
 3b1:	cd 40                	int    $0x40
 3b3:	c3                   	ret    

000003b4 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 3b4:	55                   	push   %ebp
 3b5:	89 e5                	mov    %esp,%ebp
 3b7:	83 ec 28             	sub    $0x28,%esp
 3ba:	8b 45 0c             	mov    0xc(%ebp),%eax
 3bd:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 3c0:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 3c7:	00 
 3c8:	8d 45 f4             	lea    -0xc(%ebp),%eax
 3cb:	89 44 24 04          	mov    %eax,0x4(%esp)
 3cf:	8b 45 08             	mov    0x8(%ebp),%eax
 3d2:	89 04 24             	mov    %eax,(%esp)
 3d5:	e8 32 ff ff ff       	call   30c <write>
}
 3da:	c9                   	leave  
 3db:	c3                   	ret    

000003dc <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 3dc:	55                   	push   %ebp
 3dd:	89 e5                	mov    %esp,%ebp
 3df:	83 ec 48             	sub    $0x48,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 3e2:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 3e9:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 3ed:	74 17                	je     406 <printint+0x2a>
 3ef:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 3f3:	79 11                	jns    406 <printint+0x2a>
    neg = 1;
 3f5:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 3fc:	8b 45 0c             	mov    0xc(%ebp),%eax
 3ff:	f7 d8                	neg    %eax
 401:	89 45 ec             	mov    %eax,-0x14(%ebp)
 404:	eb 06                	jmp    40c <printint+0x30>
  } else {
    x = xx;
 406:	8b 45 0c             	mov    0xc(%ebp),%eax
 409:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 40c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 413:	8b 4d 10             	mov    0x10(%ebp),%ecx
 416:	8b 45 ec             	mov    -0x14(%ebp),%eax
 419:	ba 00 00 00 00       	mov    $0x0,%edx
 41e:	f7 f1                	div    %ecx
 420:	89 d0                	mov    %edx,%eax
 422:	0f b6 90 bc 0a 00 00 	movzbl 0xabc(%eax),%edx
 429:	8d 45 dc             	lea    -0x24(%ebp),%eax
 42c:	03 45 f4             	add    -0xc(%ebp),%eax
 42f:	88 10                	mov    %dl,(%eax)
 431:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  }while((x /= base) != 0);
 435:	8b 55 10             	mov    0x10(%ebp),%edx
 438:	89 55 d4             	mov    %edx,-0x2c(%ebp)
 43b:	8b 45 ec             	mov    -0x14(%ebp),%eax
 43e:	ba 00 00 00 00       	mov    $0x0,%edx
 443:	f7 75 d4             	divl   -0x2c(%ebp)
 446:	89 45 ec             	mov    %eax,-0x14(%ebp)
 449:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 44d:	75 c4                	jne    413 <printint+0x37>
  if(neg)
 44f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 453:	74 2a                	je     47f <printint+0xa3>
    buf[i++] = '-';
 455:	8d 45 dc             	lea    -0x24(%ebp),%eax
 458:	03 45 f4             	add    -0xc(%ebp),%eax
 45b:	c6 00 2d             	movb   $0x2d,(%eax)
 45e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

  while(--i >= 0)
 462:	eb 1b                	jmp    47f <printint+0xa3>
    putc(fd, buf[i]);
 464:	8d 45 dc             	lea    -0x24(%ebp),%eax
 467:	03 45 f4             	add    -0xc(%ebp),%eax
 46a:	0f b6 00             	movzbl (%eax),%eax
 46d:	0f be c0             	movsbl %al,%eax
 470:	89 44 24 04          	mov    %eax,0x4(%esp)
 474:	8b 45 08             	mov    0x8(%ebp),%eax
 477:	89 04 24             	mov    %eax,(%esp)
 47a:	e8 35 ff ff ff       	call   3b4 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 47f:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 483:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 487:	79 db                	jns    464 <printint+0x88>
    putc(fd, buf[i]);
}
 489:	c9                   	leave  
 48a:	c3                   	ret    

0000048b <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 48b:	55                   	push   %ebp
 48c:	89 e5                	mov    %esp,%ebp
 48e:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 491:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 498:	8d 45 0c             	lea    0xc(%ebp),%eax
 49b:	83 c0 04             	add    $0x4,%eax
 49e:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 4a1:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 4a8:	e9 7d 01 00 00       	jmp    62a <printf+0x19f>
    c = fmt[i] & 0xff;
 4ad:	8b 55 0c             	mov    0xc(%ebp),%edx
 4b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
 4b3:	01 d0                	add    %edx,%eax
 4b5:	0f b6 00             	movzbl (%eax),%eax
 4b8:	0f be c0             	movsbl %al,%eax
 4bb:	25 ff 00 00 00       	and    $0xff,%eax
 4c0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 4c3:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 4c7:	75 2c                	jne    4f5 <printf+0x6a>
      if(c == '%'){
 4c9:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 4cd:	75 0c                	jne    4db <printf+0x50>
        state = '%';
 4cf:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 4d6:	e9 4b 01 00 00       	jmp    626 <printf+0x19b>
      } else {
        putc(fd, c);
 4db:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 4de:	0f be c0             	movsbl %al,%eax
 4e1:	89 44 24 04          	mov    %eax,0x4(%esp)
 4e5:	8b 45 08             	mov    0x8(%ebp),%eax
 4e8:	89 04 24             	mov    %eax,(%esp)
 4eb:	e8 c4 fe ff ff       	call   3b4 <putc>
 4f0:	e9 31 01 00 00       	jmp    626 <printf+0x19b>
      }
    } else if(state == '%'){
 4f5:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 4f9:	0f 85 27 01 00 00    	jne    626 <printf+0x19b>
      if(c == 'd'){
 4ff:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 503:	75 2d                	jne    532 <printf+0xa7>
        printint(fd, *ap, 10, 1);
 505:	8b 45 e8             	mov    -0x18(%ebp),%eax
 508:	8b 00                	mov    (%eax),%eax
 50a:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 511:	00 
 512:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 519:	00 
 51a:	89 44 24 04          	mov    %eax,0x4(%esp)
 51e:	8b 45 08             	mov    0x8(%ebp),%eax
 521:	89 04 24             	mov    %eax,(%esp)
 524:	e8 b3 fe ff ff       	call   3dc <printint>
        ap++;
 529:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 52d:	e9 ed 00 00 00       	jmp    61f <printf+0x194>
      } else if(c == 'x' || c == 'p'){
 532:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 536:	74 06                	je     53e <printf+0xb3>
 538:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 53c:	75 2d                	jne    56b <printf+0xe0>
        printint(fd, *ap, 16, 0);
 53e:	8b 45 e8             	mov    -0x18(%ebp),%eax
 541:	8b 00                	mov    (%eax),%eax
 543:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 54a:	00 
 54b:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 552:	00 
 553:	89 44 24 04          	mov    %eax,0x4(%esp)
 557:	8b 45 08             	mov    0x8(%ebp),%eax
 55a:	89 04 24             	mov    %eax,(%esp)
 55d:	e8 7a fe ff ff       	call   3dc <printint>
        ap++;
 562:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 566:	e9 b4 00 00 00       	jmp    61f <printf+0x194>
      } else if(c == 's'){
 56b:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 56f:	75 46                	jne    5b7 <printf+0x12c>
        s = (char*)*ap;
 571:	8b 45 e8             	mov    -0x18(%ebp),%eax
 574:	8b 00                	mov    (%eax),%eax
 576:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 579:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 57d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 581:	75 27                	jne    5aa <printf+0x11f>
          s = "(null)";
 583:	c7 45 f4 76 08 00 00 	movl   $0x876,-0xc(%ebp)
        while(*s != 0){
 58a:	eb 1e                	jmp    5aa <printf+0x11f>
          putc(fd, *s);
 58c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 58f:	0f b6 00             	movzbl (%eax),%eax
 592:	0f be c0             	movsbl %al,%eax
 595:	89 44 24 04          	mov    %eax,0x4(%esp)
 599:	8b 45 08             	mov    0x8(%ebp),%eax
 59c:	89 04 24             	mov    %eax,(%esp)
 59f:	e8 10 fe ff ff       	call   3b4 <putc>
          s++;
 5a4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 5a8:	eb 01                	jmp    5ab <printf+0x120>
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 5aa:	90                   	nop
 5ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5ae:	0f b6 00             	movzbl (%eax),%eax
 5b1:	84 c0                	test   %al,%al
 5b3:	75 d7                	jne    58c <printf+0x101>
 5b5:	eb 68                	jmp    61f <printf+0x194>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 5b7:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 5bb:	75 1d                	jne    5da <printf+0x14f>
        putc(fd, *ap);
 5bd:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5c0:	8b 00                	mov    (%eax),%eax
 5c2:	0f be c0             	movsbl %al,%eax
 5c5:	89 44 24 04          	mov    %eax,0x4(%esp)
 5c9:	8b 45 08             	mov    0x8(%ebp),%eax
 5cc:	89 04 24             	mov    %eax,(%esp)
 5cf:	e8 e0 fd ff ff       	call   3b4 <putc>
        ap++;
 5d4:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 5d8:	eb 45                	jmp    61f <printf+0x194>
      } else if(c == '%'){
 5da:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 5de:	75 17                	jne    5f7 <printf+0x16c>
        putc(fd, c);
 5e0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 5e3:	0f be c0             	movsbl %al,%eax
 5e6:	89 44 24 04          	mov    %eax,0x4(%esp)
 5ea:	8b 45 08             	mov    0x8(%ebp),%eax
 5ed:	89 04 24             	mov    %eax,(%esp)
 5f0:	e8 bf fd ff ff       	call   3b4 <putc>
 5f5:	eb 28                	jmp    61f <printf+0x194>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 5f7:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 5fe:	00 
 5ff:	8b 45 08             	mov    0x8(%ebp),%eax
 602:	89 04 24             	mov    %eax,(%esp)
 605:	e8 aa fd ff ff       	call   3b4 <putc>
        putc(fd, c);
 60a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 60d:	0f be c0             	movsbl %al,%eax
 610:	89 44 24 04          	mov    %eax,0x4(%esp)
 614:	8b 45 08             	mov    0x8(%ebp),%eax
 617:	89 04 24             	mov    %eax,(%esp)
 61a:	e8 95 fd ff ff       	call   3b4 <putc>
      }
      state = 0;
 61f:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 626:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 62a:	8b 55 0c             	mov    0xc(%ebp),%edx
 62d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 630:	01 d0                	add    %edx,%eax
 632:	0f b6 00             	movzbl (%eax),%eax
 635:	84 c0                	test   %al,%al
 637:	0f 85 70 fe ff ff    	jne    4ad <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 63d:	c9                   	leave  
 63e:	c3                   	ret    
 63f:	90                   	nop

00000640 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 640:	55                   	push   %ebp
 641:	89 e5                	mov    %esp,%ebp
 643:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 646:	8b 45 08             	mov    0x8(%ebp),%eax
 649:	83 e8 08             	sub    $0x8,%eax
 64c:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 64f:	a1 d8 0a 00 00       	mov    0xad8,%eax
 654:	89 45 fc             	mov    %eax,-0x4(%ebp)
 657:	eb 24                	jmp    67d <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 659:	8b 45 fc             	mov    -0x4(%ebp),%eax
 65c:	8b 00                	mov    (%eax),%eax
 65e:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 661:	77 12                	ja     675 <free+0x35>
 663:	8b 45 f8             	mov    -0x8(%ebp),%eax
 666:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 669:	77 24                	ja     68f <free+0x4f>
 66b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 66e:	8b 00                	mov    (%eax),%eax
 670:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 673:	77 1a                	ja     68f <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 675:	8b 45 fc             	mov    -0x4(%ebp),%eax
 678:	8b 00                	mov    (%eax),%eax
 67a:	89 45 fc             	mov    %eax,-0x4(%ebp)
 67d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 680:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 683:	76 d4                	jbe    659 <free+0x19>
 685:	8b 45 fc             	mov    -0x4(%ebp),%eax
 688:	8b 00                	mov    (%eax),%eax
 68a:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 68d:	76 ca                	jbe    659 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 68f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 692:	8b 40 04             	mov    0x4(%eax),%eax
 695:	c1 e0 03             	shl    $0x3,%eax
 698:	89 c2                	mov    %eax,%edx
 69a:	03 55 f8             	add    -0x8(%ebp),%edx
 69d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6a0:	8b 00                	mov    (%eax),%eax
 6a2:	39 c2                	cmp    %eax,%edx
 6a4:	75 24                	jne    6ca <free+0x8a>
    bp->s.size += p->s.ptr->s.size;
 6a6:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6a9:	8b 50 04             	mov    0x4(%eax),%edx
 6ac:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6af:	8b 00                	mov    (%eax),%eax
 6b1:	8b 40 04             	mov    0x4(%eax),%eax
 6b4:	01 c2                	add    %eax,%edx
 6b6:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6b9:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 6bc:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6bf:	8b 00                	mov    (%eax),%eax
 6c1:	8b 10                	mov    (%eax),%edx
 6c3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6c6:	89 10                	mov    %edx,(%eax)
 6c8:	eb 0a                	jmp    6d4 <free+0x94>
  } else
    bp->s.ptr = p->s.ptr;
 6ca:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6cd:	8b 10                	mov    (%eax),%edx
 6cf:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6d2:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 6d4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6d7:	8b 40 04             	mov    0x4(%eax),%eax
 6da:	c1 e0 03             	shl    $0x3,%eax
 6dd:	03 45 fc             	add    -0x4(%ebp),%eax
 6e0:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 6e3:	75 20                	jne    705 <free+0xc5>
    p->s.size += bp->s.size;
 6e5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6e8:	8b 50 04             	mov    0x4(%eax),%edx
 6eb:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6ee:	8b 40 04             	mov    0x4(%eax),%eax
 6f1:	01 c2                	add    %eax,%edx
 6f3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6f6:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 6f9:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6fc:	8b 10                	mov    (%eax),%edx
 6fe:	8b 45 fc             	mov    -0x4(%ebp),%eax
 701:	89 10                	mov    %edx,(%eax)
 703:	eb 08                	jmp    70d <free+0xcd>
  } else
    p->s.ptr = bp;
 705:	8b 45 fc             	mov    -0x4(%ebp),%eax
 708:	8b 55 f8             	mov    -0x8(%ebp),%edx
 70b:	89 10                	mov    %edx,(%eax)
  freep = p;
 70d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 710:	a3 d8 0a 00 00       	mov    %eax,0xad8
}
 715:	c9                   	leave  
 716:	c3                   	ret    

00000717 <morecore>:

static Header*
morecore(uint nu)
{
 717:	55                   	push   %ebp
 718:	89 e5                	mov    %esp,%ebp
 71a:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 71d:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 724:	77 07                	ja     72d <morecore+0x16>
    nu = 4096;
 726:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 72d:	8b 45 08             	mov    0x8(%ebp),%eax
 730:	c1 e0 03             	shl    $0x3,%eax
 733:	89 04 24             	mov    %eax,(%esp)
 736:	e8 39 fc ff ff       	call   374 <sbrk>
 73b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 73e:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 742:	75 07                	jne    74b <morecore+0x34>
    return 0;
 744:	b8 00 00 00 00       	mov    $0x0,%eax
 749:	eb 22                	jmp    76d <morecore+0x56>
  hp = (Header*)p;
 74b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 74e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 751:	8b 45 f0             	mov    -0x10(%ebp),%eax
 754:	8b 55 08             	mov    0x8(%ebp),%edx
 757:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 75a:	8b 45 f0             	mov    -0x10(%ebp),%eax
 75d:	83 c0 08             	add    $0x8,%eax
 760:	89 04 24             	mov    %eax,(%esp)
 763:	e8 d8 fe ff ff       	call   640 <free>
  return freep;
 768:	a1 d8 0a 00 00       	mov    0xad8,%eax
}
 76d:	c9                   	leave  
 76e:	c3                   	ret    

0000076f <malloc>:

void*
malloc(uint nbytes)
{
 76f:	55                   	push   %ebp
 770:	89 e5                	mov    %esp,%ebp
 772:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 775:	8b 45 08             	mov    0x8(%ebp),%eax
 778:	83 c0 07             	add    $0x7,%eax
 77b:	c1 e8 03             	shr    $0x3,%eax
 77e:	83 c0 01             	add    $0x1,%eax
 781:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 784:	a1 d8 0a 00 00       	mov    0xad8,%eax
 789:	89 45 f0             	mov    %eax,-0x10(%ebp)
 78c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 790:	75 23                	jne    7b5 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 792:	c7 45 f0 d0 0a 00 00 	movl   $0xad0,-0x10(%ebp)
 799:	8b 45 f0             	mov    -0x10(%ebp),%eax
 79c:	a3 d8 0a 00 00       	mov    %eax,0xad8
 7a1:	a1 d8 0a 00 00       	mov    0xad8,%eax
 7a6:	a3 d0 0a 00 00       	mov    %eax,0xad0
    base.s.size = 0;
 7ab:	c7 05 d4 0a 00 00 00 	movl   $0x0,0xad4
 7b2:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7b8:	8b 00                	mov    (%eax),%eax
 7ba:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 7bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7c0:	8b 40 04             	mov    0x4(%eax),%eax
 7c3:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 7c6:	72 4d                	jb     815 <malloc+0xa6>
      if(p->s.size == nunits)
 7c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7cb:	8b 40 04             	mov    0x4(%eax),%eax
 7ce:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 7d1:	75 0c                	jne    7df <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 7d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7d6:	8b 10                	mov    (%eax),%edx
 7d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7db:	89 10                	mov    %edx,(%eax)
 7dd:	eb 26                	jmp    805 <malloc+0x96>
      else {
        p->s.size -= nunits;
 7df:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7e2:	8b 40 04             	mov    0x4(%eax),%eax
 7e5:	89 c2                	mov    %eax,%edx
 7e7:	2b 55 ec             	sub    -0x14(%ebp),%edx
 7ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7ed:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 7f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7f3:	8b 40 04             	mov    0x4(%eax),%eax
 7f6:	c1 e0 03             	shl    $0x3,%eax
 7f9:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 7fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7ff:	8b 55 ec             	mov    -0x14(%ebp),%edx
 802:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 805:	8b 45 f0             	mov    -0x10(%ebp),%eax
 808:	a3 d8 0a 00 00       	mov    %eax,0xad8
      return (void*)(p + 1);
 80d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 810:	83 c0 08             	add    $0x8,%eax
 813:	eb 38                	jmp    84d <malloc+0xde>
    }
    if(p == freep)
 815:	a1 d8 0a 00 00       	mov    0xad8,%eax
 81a:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 81d:	75 1b                	jne    83a <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 81f:	8b 45 ec             	mov    -0x14(%ebp),%eax
 822:	89 04 24             	mov    %eax,(%esp)
 825:	e8 ed fe ff ff       	call   717 <morecore>
 82a:	89 45 f4             	mov    %eax,-0xc(%ebp)
 82d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 831:	75 07                	jne    83a <malloc+0xcb>
        return 0;
 833:	b8 00 00 00 00       	mov    $0x0,%eax
 838:	eb 13                	jmp    84d <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 83a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 83d:	89 45 f0             	mov    %eax,-0x10(%ebp)
 840:	8b 45 f4             	mov    -0xc(%ebp),%eax
 843:	8b 00                	mov    (%eax),%eax
 845:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 848:	e9 70 ff ff ff       	jmp    7bd <malloc+0x4e>
}
 84d:	c9                   	leave  
 84e:	c3                   	ret    
