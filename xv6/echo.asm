
_echo:     file format elf32-i386


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
   6:	83 ec 20             	sub    $0x20,%esp
  int i;

  for(i = 1; i < argc; i++)
   9:	c7 44 24 1c 01 00 00 	movl   $0x1,0x1c(%esp)
  10:	00 
  11:	eb 45                	jmp    58 <main+0x58>
    printf(1, "%s%s", argv[i], i+1 < argc ? " " : "\n");
  13:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  17:	83 c0 01             	add    $0x1,%eax
  1a:	3b 45 08             	cmp    0x8(%ebp),%eax
  1d:	7d 07                	jge    26 <main+0x26>
  1f:	b8 1f 08 00 00       	mov    $0x81f,%eax
  24:	eb 05                	jmp    2b <main+0x2b>
  26:	b8 21 08 00 00       	mov    $0x821,%eax
  2b:	8b 54 24 1c          	mov    0x1c(%esp),%edx
  2f:	c1 e2 02             	shl    $0x2,%edx
  32:	03 55 0c             	add    0xc(%ebp),%edx
  35:	8b 12                	mov    (%edx),%edx
  37:	89 44 24 0c          	mov    %eax,0xc(%esp)
  3b:	89 54 24 08          	mov    %edx,0x8(%esp)
  3f:	c7 44 24 04 23 08 00 	movl   $0x823,0x4(%esp)
  46:	00 
  47:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  4e:	e8 08 04 00 00       	call   45b <printf>
int
main(int argc, char *argv[])
{
  int i;

  for(i = 1; i < argc; i++)
  53:	83 44 24 1c 01       	addl   $0x1,0x1c(%esp)
  58:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  5c:	3b 45 08             	cmp    0x8(%ebp),%eax
  5f:	7c b2                	jl     13 <main+0x13>
    printf(1, "%s%s", argv[i], i+1 < argc ? " " : "\n");
  exit(EXIT_STATUS_SUCCESS);
  61:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  68:	e8 67 02 00 00       	call   2d4 <exit>
  6d:	90                   	nop
  6e:	90                   	nop
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

0000037c <wait_stat>:
SYSCALL(wait_stat)
 37c:	b8 17 00 00 00       	mov    $0x17,%eax
 381:	cd 40                	int    $0x40
 383:	c3                   	ret    

00000384 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 384:	55                   	push   %ebp
 385:	89 e5                	mov    %esp,%ebp
 387:	83 ec 28             	sub    $0x28,%esp
 38a:	8b 45 0c             	mov    0xc(%ebp),%eax
 38d:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 390:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 397:	00 
 398:	8d 45 f4             	lea    -0xc(%ebp),%eax
 39b:	89 44 24 04          	mov    %eax,0x4(%esp)
 39f:	8b 45 08             	mov    0x8(%ebp),%eax
 3a2:	89 04 24             	mov    %eax,(%esp)
 3a5:	e8 4a ff ff ff       	call   2f4 <write>
}
 3aa:	c9                   	leave  
 3ab:	c3                   	ret    

000003ac <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 3ac:	55                   	push   %ebp
 3ad:	89 e5                	mov    %esp,%ebp
 3af:	83 ec 48             	sub    $0x48,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 3b2:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 3b9:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 3bd:	74 17                	je     3d6 <printint+0x2a>
 3bf:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 3c3:	79 11                	jns    3d6 <printint+0x2a>
    neg = 1;
 3c5:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 3cc:	8b 45 0c             	mov    0xc(%ebp),%eax
 3cf:	f7 d8                	neg    %eax
 3d1:	89 45 ec             	mov    %eax,-0x14(%ebp)
 3d4:	eb 06                	jmp    3dc <printint+0x30>
  } else {
    x = xx;
 3d6:	8b 45 0c             	mov    0xc(%ebp),%eax
 3d9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 3dc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 3e3:	8b 4d 10             	mov    0x10(%ebp),%ecx
 3e6:	8b 45 ec             	mov    -0x14(%ebp),%eax
 3e9:	ba 00 00 00 00       	mov    $0x0,%edx
 3ee:	f7 f1                	div    %ecx
 3f0:	89 d0                	mov    %edx,%eax
 3f2:	0f b6 90 6c 0a 00 00 	movzbl 0xa6c(%eax),%edx
 3f9:	8d 45 dc             	lea    -0x24(%ebp),%eax
 3fc:	03 45 f4             	add    -0xc(%ebp),%eax
 3ff:	88 10                	mov    %dl,(%eax)
 401:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  }while((x /= base) != 0);
 405:	8b 55 10             	mov    0x10(%ebp),%edx
 408:	89 55 d4             	mov    %edx,-0x2c(%ebp)
 40b:	8b 45 ec             	mov    -0x14(%ebp),%eax
 40e:	ba 00 00 00 00       	mov    $0x0,%edx
 413:	f7 75 d4             	divl   -0x2c(%ebp)
 416:	89 45 ec             	mov    %eax,-0x14(%ebp)
 419:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 41d:	75 c4                	jne    3e3 <printint+0x37>
  if(neg)
 41f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 423:	74 2a                	je     44f <printint+0xa3>
    buf[i++] = '-';
 425:	8d 45 dc             	lea    -0x24(%ebp),%eax
 428:	03 45 f4             	add    -0xc(%ebp),%eax
 42b:	c6 00 2d             	movb   $0x2d,(%eax)
 42e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

  while(--i >= 0)
 432:	eb 1b                	jmp    44f <printint+0xa3>
    putc(fd, buf[i]);
 434:	8d 45 dc             	lea    -0x24(%ebp),%eax
 437:	03 45 f4             	add    -0xc(%ebp),%eax
 43a:	0f b6 00             	movzbl (%eax),%eax
 43d:	0f be c0             	movsbl %al,%eax
 440:	89 44 24 04          	mov    %eax,0x4(%esp)
 444:	8b 45 08             	mov    0x8(%ebp),%eax
 447:	89 04 24             	mov    %eax,(%esp)
 44a:	e8 35 ff ff ff       	call   384 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 44f:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 453:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 457:	79 db                	jns    434 <printint+0x88>
    putc(fd, buf[i]);
}
 459:	c9                   	leave  
 45a:	c3                   	ret    

0000045b <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 45b:	55                   	push   %ebp
 45c:	89 e5                	mov    %esp,%ebp
 45e:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 461:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 468:	8d 45 0c             	lea    0xc(%ebp),%eax
 46b:	83 c0 04             	add    $0x4,%eax
 46e:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 471:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 478:	e9 7d 01 00 00       	jmp    5fa <printf+0x19f>
    c = fmt[i] & 0xff;
 47d:	8b 55 0c             	mov    0xc(%ebp),%edx
 480:	8b 45 f0             	mov    -0x10(%ebp),%eax
 483:	01 d0                	add    %edx,%eax
 485:	0f b6 00             	movzbl (%eax),%eax
 488:	0f be c0             	movsbl %al,%eax
 48b:	25 ff 00 00 00       	and    $0xff,%eax
 490:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 493:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 497:	75 2c                	jne    4c5 <printf+0x6a>
      if(c == '%'){
 499:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 49d:	75 0c                	jne    4ab <printf+0x50>
        state = '%';
 49f:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 4a6:	e9 4b 01 00 00       	jmp    5f6 <printf+0x19b>
      } else {
        putc(fd, c);
 4ab:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 4ae:	0f be c0             	movsbl %al,%eax
 4b1:	89 44 24 04          	mov    %eax,0x4(%esp)
 4b5:	8b 45 08             	mov    0x8(%ebp),%eax
 4b8:	89 04 24             	mov    %eax,(%esp)
 4bb:	e8 c4 fe ff ff       	call   384 <putc>
 4c0:	e9 31 01 00 00       	jmp    5f6 <printf+0x19b>
      }
    } else if(state == '%'){
 4c5:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 4c9:	0f 85 27 01 00 00    	jne    5f6 <printf+0x19b>
      if(c == 'd'){
 4cf:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 4d3:	75 2d                	jne    502 <printf+0xa7>
        printint(fd, *ap, 10, 1);
 4d5:	8b 45 e8             	mov    -0x18(%ebp),%eax
 4d8:	8b 00                	mov    (%eax),%eax
 4da:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 4e1:	00 
 4e2:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 4e9:	00 
 4ea:	89 44 24 04          	mov    %eax,0x4(%esp)
 4ee:	8b 45 08             	mov    0x8(%ebp),%eax
 4f1:	89 04 24             	mov    %eax,(%esp)
 4f4:	e8 b3 fe ff ff       	call   3ac <printint>
        ap++;
 4f9:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 4fd:	e9 ed 00 00 00       	jmp    5ef <printf+0x194>
      } else if(c == 'x' || c == 'p'){
 502:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 506:	74 06                	je     50e <printf+0xb3>
 508:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 50c:	75 2d                	jne    53b <printf+0xe0>
        printint(fd, *ap, 16, 0);
 50e:	8b 45 e8             	mov    -0x18(%ebp),%eax
 511:	8b 00                	mov    (%eax),%eax
 513:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 51a:	00 
 51b:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 522:	00 
 523:	89 44 24 04          	mov    %eax,0x4(%esp)
 527:	8b 45 08             	mov    0x8(%ebp),%eax
 52a:	89 04 24             	mov    %eax,(%esp)
 52d:	e8 7a fe ff ff       	call   3ac <printint>
        ap++;
 532:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 536:	e9 b4 00 00 00       	jmp    5ef <printf+0x194>
      } else if(c == 's'){
 53b:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 53f:	75 46                	jne    587 <printf+0x12c>
        s = (char*)*ap;
 541:	8b 45 e8             	mov    -0x18(%ebp),%eax
 544:	8b 00                	mov    (%eax),%eax
 546:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 549:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 54d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 551:	75 27                	jne    57a <printf+0x11f>
          s = "(null)";
 553:	c7 45 f4 28 08 00 00 	movl   $0x828,-0xc(%ebp)
        while(*s != 0){
 55a:	eb 1e                	jmp    57a <printf+0x11f>
          putc(fd, *s);
 55c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 55f:	0f b6 00             	movzbl (%eax),%eax
 562:	0f be c0             	movsbl %al,%eax
 565:	89 44 24 04          	mov    %eax,0x4(%esp)
 569:	8b 45 08             	mov    0x8(%ebp),%eax
 56c:	89 04 24             	mov    %eax,(%esp)
 56f:	e8 10 fe ff ff       	call   384 <putc>
          s++;
 574:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 578:	eb 01                	jmp    57b <printf+0x120>
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 57a:	90                   	nop
 57b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 57e:	0f b6 00             	movzbl (%eax),%eax
 581:	84 c0                	test   %al,%al
 583:	75 d7                	jne    55c <printf+0x101>
 585:	eb 68                	jmp    5ef <printf+0x194>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 587:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 58b:	75 1d                	jne    5aa <printf+0x14f>
        putc(fd, *ap);
 58d:	8b 45 e8             	mov    -0x18(%ebp),%eax
 590:	8b 00                	mov    (%eax),%eax
 592:	0f be c0             	movsbl %al,%eax
 595:	89 44 24 04          	mov    %eax,0x4(%esp)
 599:	8b 45 08             	mov    0x8(%ebp),%eax
 59c:	89 04 24             	mov    %eax,(%esp)
 59f:	e8 e0 fd ff ff       	call   384 <putc>
        ap++;
 5a4:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 5a8:	eb 45                	jmp    5ef <printf+0x194>
      } else if(c == '%'){
 5aa:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 5ae:	75 17                	jne    5c7 <printf+0x16c>
        putc(fd, c);
 5b0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 5b3:	0f be c0             	movsbl %al,%eax
 5b6:	89 44 24 04          	mov    %eax,0x4(%esp)
 5ba:	8b 45 08             	mov    0x8(%ebp),%eax
 5bd:	89 04 24             	mov    %eax,(%esp)
 5c0:	e8 bf fd ff ff       	call   384 <putc>
 5c5:	eb 28                	jmp    5ef <printf+0x194>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 5c7:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 5ce:	00 
 5cf:	8b 45 08             	mov    0x8(%ebp),%eax
 5d2:	89 04 24             	mov    %eax,(%esp)
 5d5:	e8 aa fd ff ff       	call   384 <putc>
        putc(fd, c);
 5da:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 5dd:	0f be c0             	movsbl %al,%eax
 5e0:	89 44 24 04          	mov    %eax,0x4(%esp)
 5e4:	8b 45 08             	mov    0x8(%ebp),%eax
 5e7:	89 04 24             	mov    %eax,(%esp)
 5ea:	e8 95 fd ff ff       	call   384 <putc>
      }
      state = 0;
 5ef:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 5f6:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 5fa:	8b 55 0c             	mov    0xc(%ebp),%edx
 5fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
 600:	01 d0                	add    %edx,%eax
 602:	0f b6 00             	movzbl (%eax),%eax
 605:	84 c0                	test   %al,%al
 607:	0f 85 70 fe ff ff    	jne    47d <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 60d:	c9                   	leave  
 60e:	c3                   	ret    
 60f:	90                   	nop

00000610 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 610:	55                   	push   %ebp
 611:	89 e5                	mov    %esp,%ebp
 613:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 616:	8b 45 08             	mov    0x8(%ebp),%eax
 619:	83 e8 08             	sub    $0x8,%eax
 61c:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 61f:	a1 88 0a 00 00       	mov    0xa88,%eax
 624:	89 45 fc             	mov    %eax,-0x4(%ebp)
 627:	eb 24                	jmp    64d <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 629:	8b 45 fc             	mov    -0x4(%ebp),%eax
 62c:	8b 00                	mov    (%eax),%eax
 62e:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 631:	77 12                	ja     645 <free+0x35>
 633:	8b 45 f8             	mov    -0x8(%ebp),%eax
 636:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 639:	77 24                	ja     65f <free+0x4f>
 63b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 63e:	8b 00                	mov    (%eax),%eax
 640:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 643:	77 1a                	ja     65f <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 645:	8b 45 fc             	mov    -0x4(%ebp),%eax
 648:	8b 00                	mov    (%eax),%eax
 64a:	89 45 fc             	mov    %eax,-0x4(%ebp)
 64d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 650:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 653:	76 d4                	jbe    629 <free+0x19>
 655:	8b 45 fc             	mov    -0x4(%ebp),%eax
 658:	8b 00                	mov    (%eax),%eax
 65a:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 65d:	76 ca                	jbe    629 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 65f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 662:	8b 40 04             	mov    0x4(%eax),%eax
 665:	c1 e0 03             	shl    $0x3,%eax
 668:	89 c2                	mov    %eax,%edx
 66a:	03 55 f8             	add    -0x8(%ebp),%edx
 66d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 670:	8b 00                	mov    (%eax),%eax
 672:	39 c2                	cmp    %eax,%edx
 674:	75 24                	jne    69a <free+0x8a>
    bp->s.size += p->s.ptr->s.size;
 676:	8b 45 f8             	mov    -0x8(%ebp),%eax
 679:	8b 50 04             	mov    0x4(%eax),%edx
 67c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 67f:	8b 00                	mov    (%eax),%eax
 681:	8b 40 04             	mov    0x4(%eax),%eax
 684:	01 c2                	add    %eax,%edx
 686:	8b 45 f8             	mov    -0x8(%ebp),%eax
 689:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 68c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 68f:	8b 00                	mov    (%eax),%eax
 691:	8b 10                	mov    (%eax),%edx
 693:	8b 45 f8             	mov    -0x8(%ebp),%eax
 696:	89 10                	mov    %edx,(%eax)
 698:	eb 0a                	jmp    6a4 <free+0x94>
  } else
    bp->s.ptr = p->s.ptr;
 69a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 69d:	8b 10                	mov    (%eax),%edx
 69f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6a2:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 6a4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6a7:	8b 40 04             	mov    0x4(%eax),%eax
 6aa:	c1 e0 03             	shl    $0x3,%eax
 6ad:	03 45 fc             	add    -0x4(%ebp),%eax
 6b0:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 6b3:	75 20                	jne    6d5 <free+0xc5>
    p->s.size += bp->s.size;
 6b5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6b8:	8b 50 04             	mov    0x4(%eax),%edx
 6bb:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6be:	8b 40 04             	mov    0x4(%eax),%eax
 6c1:	01 c2                	add    %eax,%edx
 6c3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6c6:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 6c9:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6cc:	8b 10                	mov    (%eax),%edx
 6ce:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6d1:	89 10                	mov    %edx,(%eax)
 6d3:	eb 08                	jmp    6dd <free+0xcd>
  } else
    p->s.ptr = bp;
 6d5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6d8:	8b 55 f8             	mov    -0x8(%ebp),%edx
 6db:	89 10                	mov    %edx,(%eax)
  freep = p;
 6dd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6e0:	a3 88 0a 00 00       	mov    %eax,0xa88
}
 6e5:	c9                   	leave  
 6e6:	c3                   	ret    

000006e7 <morecore>:

static Header*
morecore(uint nu)
{
 6e7:	55                   	push   %ebp
 6e8:	89 e5                	mov    %esp,%ebp
 6ea:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 6ed:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 6f4:	77 07                	ja     6fd <morecore+0x16>
    nu = 4096;
 6f6:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 6fd:	8b 45 08             	mov    0x8(%ebp),%eax
 700:	c1 e0 03             	shl    $0x3,%eax
 703:	89 04 24             	mov    %eax,(%esp)
 706:	e8 51 fc ff ff       	call   35c <sbrk>
 70b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 70e:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 712:	75 07                	jne    71b <morecore+0x34>
    return 0;
 714:	b8 00 00 00 00       	mov    $0x0,%eax
 719:	eb 22                	jmp    73d <morecore+0x56>
  hp = (Header*)p;
 71b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 71e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 721:	8b 45 f0             	mov    -0x10(%ebp),%eax
 724:	8b 55 08             	mov    0x8(%ebp),%edx
 727:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 72a:	8b 45 f0             	mov    -0x10(%ebp),%eax
 72d:	83 c0 08             	add    $0x8,%eax
 730:	89 04 24             	mov    %eax,(%esp)
 733:	e8 d8 fe ff ff       	call   610 <free>
  return freep;
 738:	a1 88 0a 00 00       	mov    0xa88,%eax
}
 73d:	c9                   	leave  
 73e:	c3                   	ret    

0000073f <malloc>:

void*
malloc(uint nbytes)
{
 73f:	55                   	push   %ebp
 740:	89 e5                	mov    %esp,%ebp
 742:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 745:	8b 45 08             	mov    0x8(%ebp),%eax
 748:	83 c0 07             	add    $0x7,%eax
 74b:	c1 e8 03             	shr    $0x3,%eax
 74e:	83 c0 01             	add    $0x1,%eax
 751:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 754:	a1 88 0a 00 00       	mov    0xa88,%eax
 759:	89 45 f0             	mov    %eax,-0x10(%ebp)
 75c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 760:	75 23                	jne    785 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 762:	c7 45 f0 80 0a 00 00 	movl   $0xa80,-0x10(%ebp)
 769:	8b 45 f0             	mov    -0x10(%ebp),%eax
 76c:	a3 88 0a 00 00       	mov    %eax,0xa88
 771:	a1 88 0a 00 00       	mov    0xa88,%eax
 776:	a3 80 0a 00 00       	mov    %eax,0xa80
    base.s.size = 0;
 77b:	c7 05 84 0a 00 00 00 	movl   $0x0,0xa84
 782:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 785:	8b 45 f0             	mov    -0x10(%ebp),%eax
 788:	8b 00                	mov    (%eax),%eax
 78a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 78d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 790:	8b 40 04             	mov    0x4(%eax),%eax
 793:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 796:	72 4d                	jb     7e5 <malloc+0xa6>
      if(p->s.size == nunits)
 798:	8b 45 f4             	mov    -0xc(%ebp),%eax
 79b:	8b 40 04             	mov    0x4(%eax),%eax
 79e:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 7a1:	75 0c                	jne    7af <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 7a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7a6:	8b 10                	mov    (%eax),%edx
 7a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7ab:	89 10                	mov    %edx,(%eax)
 7ad:	eb 26                	jmp    7d5 <malloc+0x96>
      else {
        p->s.size -= nunits;
 7af:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7b2:	8b 40 04             	mov    0x4(%eax),%eax
 7b5:	89 c2                	mov    %eax,%edx
 7b7:	2b 55 ec             	sub    -0x14(%ebp),%edx
 7ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7bd:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 7c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7c3:	8b 40 04             	mov    0x4(%eax),%eax
 7c6:	c1 e0 03             	shl    $0x3,%eax
 7c9:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 7cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7cf:	8b 55 ec             	mov    -0x14(%ebp),%edx
 7d2:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 7d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7d8:	a3 88 0a 00 00       	mov    %eax,0xa88
      return (void*)(p + 1);
 7dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7e0:	83 c0 08             	add    $0x8,%eax
 7e3:	eb 38                	jmp    81d <malloc+0xde>
    }
    if(p == freep)
 7e5:	a1 88 0a 00 00       	mov    0xa88,%eax
 7ea:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 7ed:	75 1b                	jne    80a <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 7ef:	8b 45 ec             	mov    -0x14(%ebp),%eax
 7f2:	89 04 24             	mov    %eax,(%esp)
 7f5:	e8 ed fe ff ff       	call   6e7 <morecore>
 7fa:	89 45 f4             	mov    %eax,-0xc(%ebp)
 7fd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 801:	75 07                	jne    80a <malloc+0xcb>
        return 0;
 803:	b8 00 00 00 00       	mov    $0x0,%eax
 808:	eb 13                	jmp    81d <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 80a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 80d:	89 45 f0             	mov    %eax,-0x10(%ebp)
 810:	8b 45 f4             	mov    -0xc(%ebp),%eax
 813:	8b 00                	mov    (%eax),%eax
 815:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 818:	e9 70 ff ff ff       	jmp    78d <malloc+0x4e>
}
 81d:	c9                   	leave  
 81e:	c3                   	ret    
