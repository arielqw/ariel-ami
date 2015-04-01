
_picachu:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:

//extern int retTest()



int main(int argc, char *argv[]){
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
	//printf(1, "Address is: %d\n", (int)(*(&argc-1)));

	//printf(1,"%s", argv[0]);
	//exit(0);
	return 7;
   3:	b8 07 00 00 00       	mov    $0x7,%eax
}
   8:	5d                   	pop    %ebp
   9:	c3                   	ret    
   a:	90                   	nop
   b:	90                   	nop

0000000c <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
   c:	55                   	push   %ebp
   d:	89 e5                	mov    %esp,%ebp
   f:	57                   	push   %edi
  10:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
  11:	8b 4d 08             	mov    0x8(%ebp),%ecx
  14:	8b 55 10             	mov    0x10(%ebp),%edx
  17:	8b 45 0c             	mov    0xc(%ebp),%eax
  1a:	89 cb                	mov    %ecx,%ebx
  1c:	89 df                	mov    %ebx,%edi
  1e:	89 d1                	mov    %edx,%ecx
  20:	fc                   	cld    
  21:	f3 aa                	rep stos %al,%es:(%edi)
  23:	89 ca                	mov    %ecx,%edx
  25:	89 fb                	mov    %edi,%ebx
  27:	89 5d 08             	mov    %ebx,0x8(%ebp)
  2a:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
  2d:	5b                   	pop    %ebx
  2e:	5f                   	pop    %edi
  2f:	5d                   	pop    %ebp
  30:	c3                   	ret    

00000031 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
  31:	55                   	push   %ebp
  32:	89 e5                	mov    %esp,%ebp
  34:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
  37:	8b 45 08             	mov    0x8(%ebp),%eax
  3a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
  3d:	90                   	nop
  3e:	8b 45 0c             	mov    0xc(%ebp),%eax
  41:	0f b6 10             	movzbl (%eax),%edx
  44:	8b 45 08             	mov    0x8(%ebp),%eax
  47:	88 10                	mov    %dl,(%eax)
  49:	8b 45 08             	mov    0x8(%ebp),%eax
  4c:	0f b6 00             	movzbl (%eax),%eax
  4f:	84 c0                	test   %al,%al
  51:	0f 95 c0             	setne  %al
  54:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  58:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  5c:	84 c0                	test   %al,%al
  5e:	75 de                	jne    3e <strcpy+0xd>
    ;
  return os;
  60:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  63:	c9                   	leave  
  64:	c3                   	ret    

00000065 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  65:	55                   	push   %ebp
  66:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
  68:	eb 08                	jmp    72 <strcmp+0xd>
    p++, q++;
  6a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  6e:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
  72:	8b 45 08             	mov    0x8(%ebp),%eax
  75:	0f b6 00             	movzbl (%eax),%eax
  78:	84 c0                	test   %al,%al
  7a:	74 10                	je     8c <strcmp+0x27>
  7c:	8b 45 08             	mov    0x8(%ebp),%eax
  7f:	0f b6 10             	movzbl (%eax),%edx
  82:	8b 45 0c             	mov    0xc(%ebp),%eax
  85:	0f b6 00             	movzbl (%eax),%eax
  88:	38 c2                	cmp    %al,%dl
  8a:	74 de                	je     6a <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
  8c:	8b 45 08             	mov    0x8(%ebp),%eax
  8f:	0f b6 00             	movzbl (%eax),%eax
  92:	0f b6 d0             	movzbl %al,%edx
  95:	8b 45 0c             	mov    0xc(%ebp),%eax
  98:	0f b6 00             	movzbl (%eax),%eax
  9b:	0f b6 c0             	movzbl %al,%eax
  9e:	89 d1                	mov    %edx,%ecx
  a0:	29 c1                	sub    %eax,%ecx
  a2:	89 c8                	mov    %ecx,%eax
}
  a4:	5d                   	pop    %ebp
  a5:	c3                   	ret    

000000a6 <strlen>:

uint
strlen(char *s)
{
  a6:	55                   	push   %ebp
  a7:	89 e5                	mov    %esp,%ebp
  a9:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
  ac:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  b3:	eb 04                	jmp    b9 <strlen+0x13>
  b5:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  b9:	8b 45 fc             	mov    -0x4(%ebp),%eax
  bc:	03 45 08             	add    0x8(%ebp),%eax
  bf:	0f b6 00             	movzbl (%eax),%eax
  c2:	84 c0                	test   %al,%al
  c4:	75 ef                	jne    b5 <strlen+0xf>
    ;
  return n;
  c6:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  c9:	c9                   	leave  
  ca:	c3                   	ret    

000000cb <memset>:

void*
memset(void *dst, int c, uint n)
{
  cb:	55                   	push   %ebp
  cc:	89 e5                	mov    %esp,%ebp
  ce:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
  d1:	8b 45 10             	mov    0x10(%ebp),%eax
  d4:	89 44 24 08          	mov    %eax,0x8(%esp)
  d8:	8b 45 0c             	mov    0xc(%ebp),%eax
  db:	89 44 24 04          	mov    %eax,0x4(%esp)
  df:	8b 45 08             	mov    0x8(%ebp),%eax
  e2:	89 04 24             	mov    %eax,(%esp)
  e5:	e8 22 ff ff ff       	call   c <stosb>
  return dst;
  ea:	8b 45 08             	mov    0x8(%ebp),%eax
}
  ed:	c9                   	leave  
  ee:	c3                   	ret    

000000ef <strchr>:

char*
strchr(const char *s, char c)
{
  ef:	55                   	push   %ebp
  f0:	89 e5                	mov    %esp,%ebp
  f2:	83 ec 04             	sub    $0x4,%esp
  f5:	8b 45 0c             	mov    0xc(%ebp),%eax
  f8:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
  fb:	eb 14                	jmp    111 <strchr+0x22>
    if(*s == c)
  fd:	8b 45 08             	mov    0x8(%ebp),%eax
 100:	0f b6 00             	movzbl (%eax),%eax
 103:	3a 45 fc             	cmp    -0x4(%ebp),%al
 106:	75 05                	jne    10d <strchr+0x1e>
      return (char*)s;
 108:	8b 45 08             	mov    0x8(%ebp),%eax
 10b:	eb 13                	jmp    120 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 10d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 111:	8b 45 08             	mov    0x8(%ebp),%eax
 114:	0f b6 00             	movzbl (%eax),%eax
 117:	84 c0                	test   %al,%al
 119:	75 e2                	jne    fd <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 11b:	b8 00 00 00 00       	mov    $0x0,%eax
}
 120:	c9                   	leave  
 121:	c3                   	ret    

00000122 <gets>:

char*
gets(char *buf, int max)
{
 122:	55                   	push   %ebp
 123:	89 e5                	mov    %esp,%ebp
 125:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 128:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 12f:	eb 44                	jmp    175 <gets+0x53>
    cc = read(0, &c, 1);
 131:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 138:	00 
 139:	8d 45 ef             	lea    -0x11(%ebp),%eax
 13c:	89 44 24 04          	mov    %eax,0x4(%esp)
 140:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 147:	e8 3c 01 00 00       	call   288 <read>
 14c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 14f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 153:	7e 2d                	jle    182 <gets+0x60>
      break;
    buf[i++] = c;
 155:	8b 45 f4             	mov    -0xc(%ebp),%eax
 158:	03 45 08             	add    0x8(%ebp),%eax
 15b:	0f b6 55 ef          	movzbl -0x11(%ebp),%edx
 15f:	88 10                	mov    %dl,(%eax)
 161:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(c == '\n' || c == '\r')
 165:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 169:	3c 0a                	cmp    $0xa,%al
 16b:	74 16                	je     183 <gets+0x61>
 16d:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 171:	3c 0d                	cmp    $0xd,%al
 173:	74 0e                	je     183 <gets+0x61>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 175:	8b 45 f4             	mov    -0xc(%ebp),%eax
 178:	83 c0 01             	add    $0x1,%eax
 17b:	3b 45 0c             	cmp    0xc(%ebp),%eax
 17e:	7c b1                	jl     131 <gets+0xf>
 180:	eb 01                	jmp    183 <gets+0x61>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 182:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 183:	8b 45 f4             	mov    -0xc(%ebp),%eax
 186:	03 45 08             	add    0x8(%ebp),%eax
 189:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 18c:	8b 45 08             	mov    0x8(%ebp),%eax
}
 18f:	c9                   	leave  
 190:	c3                   	ret    

00000191 <stat>:

int
stat(char *n, struct stat *st)
{
 191:	55                   	push   %ebp
 192:	89 e5                	mov    %esp,%ebp
 194:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 197:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 19e:	00 
 19f:	8b 45 08             	mov    0x8(%ebp),%eax
 1a2:	89 04 24             	mov    %eax,(%esp)
 1a5:	e8 06 01 00 00       	call   2b0 <open>
 1aa:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 1ad:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 1b1:	79 07                	jns    1ba <stat+0x29>
    return -1;
 1b3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 1b8:	eb 23                	jmp    1dd <stat+0x4c>
  r = fstat(fd, st);
 1ba:	8b 45 0c             	mov    0xc(%ebp),%eax
 1bd:	89 44 24 04          	mov    %eax,0x4(%esp)
 1c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1c4:	89 04 24             	mov    %eax,(%esp)
 1c7:	e8 fc 00 00 00       	call   2c8 <fstat>
 1cc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 1cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1d2:	89 04 24             	mov    %eax,(%esp)
 1d5:	e8 be 00 00 00       	call   298 <close>
  return r;
 1da:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 1dd:	c9                   	leave  
 1de:	c3                   	ret    

000001df <atoi>:

int
atoi(const char *s)
{
 1df:	55                   	push   %ebp
 1e0:	89 e5                	mov    %esp,%ebp
 1e2:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 1e5:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 1ec:	eb 23                	jmp    211 <atoi+0x32>
    n = n*10 + *s++ - '0';
 1ee:	8b 55 fc             	mov    -0x4(%ebp),%edx
 1f1:	89 d0                	mov    %edx,%eax
 1f3:	c1 e0 02             	shl    $0x2,%eax
 1f6:	01 d0                	add    %edx,%eax
 1f8:	01 c0                	add    %eax,%eax
 1fa:	89 c2                	mov    %eax,%edx
 1fc:	8b 45 08             	mov    0x8(%ebp),%eax
 1ff:	0f b6 00             	movzbl (%eax),%eax
 202:	0f be c0             	movsbl %al,%eax
 205:	01 d0                	add    %edx,%eax
 207:	83 e8 30             	sub    $0x30,%eax
 20a:	89 45 fc             	mov    %eax,-0x4(%ebp)
 20d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 211:	8b 45 08             	mov    0x8(%ebp),%eax
 214:	0f b6 00             	movzbl (%eax),%eax
 217:	3c 2f                	cmp    $0x2f,%al
 219:	7e 0a                	jle    225 <atoi+0x46>
 21b:	8b 45 08             	mov    0x8(%ebp),%eax
 21e:	0f b6 00             	movzbl (%eax),%eax
 221:	3c 39                	cmp    $0x39,%al
 223:	7e c9                	jle    1ee <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 225:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 228:	c9                   	leave  
 229:	c3                   	ret    

0000022a <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 22a:	55                   	push   %ebp
 22b:	89 e5                	mov    %esp,%ebp
 22d:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 230:	8b 45 08             	mov    0x8(%ebp),%eax
 233:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 236:	8b 45 0c             	mov    0xc(%ebp),%eax
 239:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 23c:	eb 13                	jmp    251 <memmove+0x27>
    *dst++ = *src++;
 23e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 241:	0f b6 10             	movzbl (%eax),%edx
 244:	8b 45 fc             	mov    -0x4(%ebp),%eax
 247:	88 10                	mov    %dl,(%eax)
 249:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 24d:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 251:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 255:	0f 9f c0             	setg   %al
 258:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 25c:	84 c0                	test   %al,%al
 25e:	75 de                	jne    23e <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 260:	8b 45 08             	mov    0x8(%ebp),%eax
}
 263:	c9                   	leave  
 264:	c3                   	ret    
 265:	90                   	nop
 266:	90                   	nop
 267:	90                   	nop

00000268 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 268:	b8 01 00 00 00       	mov    $0x1,%eax
 26d:	cd 40                	int    $0x40
 26f:	c3                   	ret    

00000270 <exit>:
SYSCALL(exit)
 270:	b8 02 00 00 00       	mov    $0x2,%eax
 275:	cd 40                	int    $0x40
 277:	c3                   	ret    

00000278 <wait>:
SYSCALL(wait)
 278:	b8 03 00 00 00       	mov    $0x3,%eax
 27d:	cd 40                	int    $0x40
 27f:	c3                   	ret    

00000280 <pipe>:
SYSCALL(pipe)
 280:	b8 04 00 00 00       	mov    $0x4,%eax
 285:	cd 40                	int    $0x40
 287:	c3                   	ret    

00000288 <read>:
SYSCALL(read)
 288:	b8 05 00 00 00       	mov    $0x5,%eax
 28d:	cd 40                	int    $0x40
 28f:	c3                   	ret    

00000290 <write>:
SYSCALL(write)
 290:	b8 10 00 00 00       	mov    $0x10,%eax
 295:	cd 40                	int    $0x40
 297:	c3                   	ret    

00000298 <close>:
SYSCALL(close)
 298:	b8 15 00 00 00       	mov    $0x15,%eax
 29d:	cd 40                	int    $0x40
 29f:	c3                   	ret    

000002a0 <kill>:
SYSCALL(kill)
 2a0:	b8 06 00 00 00       	mov    $0x6,%eax
 2a5:	cd 40                	int    $0x40
 2a7:	c3                   	ret    

000002a8 <exec>:
SYSCALL(exec)
 2a8:	b8 07 00 00 00       	mov    $0x7,%eax
 2ad:	cd 40                	int    $0x40
 2af:	c3                   	ret    

000002b0 <open>:
SYSCALL(open)
 2b0:	b8 0f 00 00 00       	mov    $0xf,%eax
 2b5:	cd 40                	int    $0x40
 2b7:	c3                   	ret    

000002b8 <mknod>:
SYSCALL(mknod)
 2b8:	b8 11 00 00 00       	mov    $0x11,%eax
 2bd:	cd 40                	int    $0x40
 2bf:	c3                   	ret    

000002c0 <unlink>:
SYSCALL(unlink)
 2c0:	b8 12 00 00 00       	mov    $0x12,%eax
 2c5:	cd 40                	int    $0x40
 2c7:	c3                   	ret    

000002c8 <fstat>:
SYSCALL(fstat)
 2c8:	b8 08 00 00 00       	mov    $0x8,%eax
 2cd:	cd 40                	int    $0x40
 2cf:	c3                   	ret    

000002d0 <link>:
SYSCALL(link)
 2d0:	b8 13 00 00 00       	mov    $0x13,%eax
 2d5:	cd 40                	int    $0x40
 2d7:	c3                   	ret    

000002d8 <mkdir>:
SYSCALL(mkdir)
 2d8:	b8 14 00 00 00       	mov    $0x14,%eax
 2dd:	cd 40                	int    $0x40
 2df:	c3                   	ret    

000002e0 <chdir>:
SYSCALL(chdir)
 2e0:	b8 09 00 00 00       	mov    $0x9,%eax
 2e5:	cd 40                	int    $0x40
 2e7:	c3                   	ret    

000002e8 <dup>:
SYSCALL(dup)
 2e8:	b8 0a 00 00 00       	mov    $0xa,%eax
 2ed:	cd 40                	int    $0x40
 2ef:	c3                   	ret    

000002f0 <getpid>:
SYSCALL(getpid)
 2f0:	b8 0b 00 00 00       	mov    $0xb,%eax
 2f5:	cd 40                	int    $0x40
 2f7:	c3                   	ret    

000002f8 <sbrk>:
SYSCALL(sbrk)
 2f8:	b8 0c 00 00 00       	mov    $0xc,%eax
 2fd:	cd 40                	int    $0x40
 2ff:	c3                   	ret    

00000300 <sleep>:
SYSCALL(sleep)
 300:	b8 0d 00 00 00       	mov    $0xd,%eax
 305:	cd 40                	int    $0x40
 307:	c3                   	ret    

00000308 <uptime>:
SYSCALL(uptime)
 308:	b8 0e 00 00 00       	mov    $0xe,%eax
 30d:	cd 40                	int    $0x40
 30f:	c3                   	ret    

00000310 <waitpid>:
SYSCALL(waitpid)
 310:	b8 16 00 00 00       	mov    $0x16,%eax
 315:	cd 40                	int    $0x40
 317:	c3                   	ret    

00000318 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 318:	55                   	push   %ebp
 319:	89 e5                	mov    %esp,%ebp
 31b:	83 ec 28             	sub    $0x28,%esp
 31e:	8b 45 0c             	mov    0xc(%ebp),%eax
 321:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 324:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 32b:	00 
 32c:	8d 45 f4             	lea    -0xc(%ebp),%eax
 32f:	89 44 24 04          	mov    %eax,0x4(%esp)
 333:	8b 45 08             	mov    0x8(%ebp),%eax
 336:	89 04 24             	mov    %eax,(%esp)
 339:	e8 52 ff ff ff       	call   290 <write>
}
 33e:	c9                   	leave  
 33f:	c3                   	ret    

00000340 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 340:	55                   	push   %ebp
 341:	89 e5                	mov    %esp,%ebp
 343:	83 ec 48             	sub    $0x48,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 346:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 34d:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 351:	74 17                	je     36a <printint+0x2a>
 353:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 357:	79 11                	jns    36a <printint+0x2a>
    neg = 1;
 359:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 360:	8b 45 0c             	mov    0xc(%ebp),%eax
 363:	f7 d8                	neg    %eax
 365:	89 45 ec             	mov    %eax,-0x14(%ebp)
 368:	eb 06                	jmp    370 <printint+0x30>
  } else {
    x = xx;
 36a:	8b 45 0c             	mov    0xc(%ebp),%eax
 36d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 370:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 377:	8b 4d 10             	mov    0x10(%ebp),%ecx
 37a:	8b 45 ec             	mov    -0x14(%ebp),%eax
 37d:	ba 00 00 00 00       	mov    $0x0,%edx
 382:	f7 f1                	div    %ecx
 384:	89 d0                	mov    %edx,%eax
 386:	0f b6 90 fc 09 00 00 	movzbl 0x9fc(%eax),%edx
 38d:	8d 45 dc             	lea    -0x24(%ebp),%eax
 390:	03 45 f4             	add    -0xc(%ebp),%eax
 393:	88 10                	mov    %dl,(%eax)
 395:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  }while((x /= base) != 0);
 399:	8b 55 10             	mov    0x10(%ebp),%edx
 39c:	89 55 d4             	mov    %edx,-0x2c(%ebp)
 39f:	8b 45 ec             	mov    -0x14(%ebp),%eax
 3a2:	ba 00 00 00 00       	mov    $0x0,%edx
 3a7:	f7 75 d4             	divl   -0x2c(%ebp)
 3aa:	89 45 ec             	mov    %eax,-0x14(%ebp)
 3ad:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 3b1:	75 c4                	jne    377 <printint+0x37>
  if(neg)
 3b3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 3b7:	74 2a                	je     3e3 <printint+0xa3>
    buf[i++] = '-';
 3b9:	8d 45 dc             	lea    -0x24(%ebp),%eax
 3bc:	03 45 f4             	add    -0xc(%ebp),%eax
 3bf:	c6 00 2d             	movb   $0x2d,(%eax)
 3c2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

  while(--i >= 0)
 3c6:	eb 1b                	jmp    3e3 <printint+0xa3>
    putc(fd, buf[i]);
 3c8:	8d 45 dc             	lea    -0x24(%ebp),%eax
 3cb:	03 45 f4             	add    -0xc(%ebp),%eax
 3ce:	0f b6 00             	movzbl (%eax),%eax
 3d1:	0f be c0             	movsbl %al,%eax
 3d4:	89 44 24 04          	mov    %eax,0x4(%esp)
 3d8:	8b 45 08             	mov    0x8(%ebp),%eax
 3db:	89 04 24             	mov    %eax,(%esp)
 3de:	e8 35 ff ff ff       	call   318 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 3e3:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 3e7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 3eb:	79 db                	jns    3c8 <printint+0x88>
    putc(fd, buf[i]);
}
 3ed:	c9                   	leave  
 3ee:	c3                   	ret    

000003ef <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 3ef:	55                   	push   %ebp
 3f0:	89 e5                	mov    %esp,%ebp
 3f2:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 3f5:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 3fc:	8d 45 0c             	lea    0xc(%ebp),%eax
 3ff:	83 c0 04             	add    $0x4,%eax
 402:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 405:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 40c:	e9 7d 01 00 00       	jmp    58e <printf+0x19f>
    c = fmt[i] & 0xff;
 411:	8b 55 0c             	mov    0xc(%ebp),%edx
 414:	8b 45 f0             	mov    -0x10(%ebp),%eax
 417:	01 d0                	add    %edx,%eax
 419:	0f b6 00             	movzbl (%eax),%eax
 41c:	0f be c0             	movsbl %al,%eax
 41f:	25 ff 00 00 00       	and    $0xff,%eax
 424:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 427:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 42b:	75 2c                	jne    459 <printf+0x6a>
      if(c == '%'){
 42d:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 431:	75 0c                	jne    43f <printf+0x50>
        state = '%';
 433:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 43a:	e9 4b 01 00 00       	jmp    58a <printf+0x19b>
      } else {
        putc(fd, c);
 43f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 442:	0f be c0             	movsbl %al,%eax
 445:	89 44 24 04          	mov    %eax,0x4(%esp)
 449:	8b 45 08             	mov    0x8(%ebp),%eax
 44c:	89 04 24             	mov    %eax,(%esp)
 44f:	e8 c4 fe ff ff       	call   318 <putc>
 454:	e9 31 01 00 00       	jmp    58a <printf+0x19b>
      }
    } else if(state == '%'){
 459:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 45d:	0f 85 27 01 00 00    	jne    58a <printf+0x19b>
      if(c == 'd'){
 463:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 467:	75 2d                	jne    496 <printf+0xa7>
        printint(fd, *ap, 10, 1);
 469:	8b 45 e8             	mov    -0x18(%ebp),%eax
 46c:	8b 00                	mov    (%eax),%eax
 46e:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 475:	00 
 476:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 47d:	00 
 47e:	89 44 24 04          	mov    %eax,0x4(%esp)
 482:	8b 45 08             	mov    0x8(%ebp),%eax
 485:	89 04 24             	mov    %eax,(%esp)
 488:	e8 b3 fe ff ff       	call   340 <printint>
        ap++;
 48d:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 491:	e9 ed 00 00 00       	jmp    583 <printf+0x194>
      } else if(c == 'x' || c == 'p'){
 496:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 49a:	74 06                	je     4a2 <printf+0xb3>
 49c:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 4a0:	75 2d                	jne    4cf <printf+0xe0>
        printint(fd, *ap, 16, 0);
 4a2:	8b 45 e8             	mov    -0x18(%ebp),%eax
 4a5:	8b 00                	mov    (%eax),%eax
 4a7:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 4ae:	00 
 4af:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 4b6:	00 
 4b7:	89 44 24 04          	mov    %eax,0x4(%esp)
 4bb:	8b 45 08             	mov    0x8(%ebp),%eax
 4be:	89 04 24             	mov    %eax,(%esp)
 4c1:	e8 7a fe ff ff       	call   340 <printint>
        ap++;
 4c6:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 4ca:	e9 b4 00 00 00       	jmp    583 <printf+0x194>
      } else if(c == 's'){
 4cf:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 4d3:	75 46                	jne    51b <printf+0x12c>
        s = (char*)*ap;
 4d5:	8b 45 e8             	mov    -0x18(%ebp),%eax
 4d8:	8b 00                	mov    (%eax),%eax
 4da:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 4dd:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 4e1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 4e5:	75 27                	jne    50e <printf+0x11f>
          s = "(null)";
 4e7:	c7 45 f4 b3 07 00 00 	movl   $0x7b3,-0xc(%ebp)
        while(*s != 0){
 4ee:	eb 1e                	jmp    50e <printf+0x11f>
          putc(fd, *s);
 4f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4f3:	0f b6 00             	movzbl (%eax),%eax
 4f6:	0f be c0             	movsbl %al,%eax
 4f9:	89 44 24 04          	mov    %eax,0x4(%esp)
 4fd:	8b 45 08             	mov    0x8(%ebp),%eax
 500:	89 04 24             	mov    %eax,(%esp)
 503:	e8 10 fe ff ff       	call   318 <putc>
          s++;
 508:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 50c:	eb 01                	jmp    50f <printf+0x120>
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 50e:	90                   	nop
 50f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 512:	0f b6 00             	movzbl (%eax),%eax
 515:	84 c0                	test   %al,%al
 517:	75 d7                	jne    4f0 <printf+0x101>
 519:	eb 68                	jmp    583 <printf+0x194>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 51b:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 51f:	75 1d                	jne    53e <printf+0x14f>
        putc(fd, *ap);
 521:	8b 45 e8             	mov    -0x18(%ebp),%eax
 524:	8b 00                	mov    (%eax),%eax
 526:	0f be c0             	movsbl %al,%eax
 529:	89 44 24 04          	mov    %eax,0x4(%esp)
 52d:	8b 45 08             	mov    0x8(%ebp),%eax
 530:	89 04 24             	mov    %eax,(%esp)
 533:	e8 e0 fd ff ff       	call   318 <putc>
        ap++;
 538:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 53c:	eb 45                	jmp    583 <printf+0x194>
      } else if(c == '%'){
 53e:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 542:	75 17                	jne    55b <printf+0x16c>
        putc(fd, c);
 544:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 547:	0f be c0             	movsbl %al,%eax
 54a:	89 44 24 04          	mov    %eax,0x4(%esp)
 54e:	8b 45 08             	mov    0x8(%ebp),%eax
 551:	89 04 24             	mov    %eax,(%esp)
 554:	e8 bf fd ff ff       	call   318 <putc>
 559:	eb 28                	jmp    583 <printf+0x194>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 55b:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 562:	00 
 563:	8b 45 08             	mov    0x8(%ebp),%eax
 566:	89 04 24             	mov    %eax,(%esp)
 569:	e8 aa fd ff ff       	call   318 <putc>
        putc(fd, c);
 56e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 571:	0f be c0             	movsbl %al,%eax
 574:	89 44 24 04          	mov    %eax,0x4(%esp)
 578:	8b 45 08             	mov    0x8(%ebp),%eax
 57b:	89 04 24             	mov    %eax,(%esp)
 57e:	e8 95 fd ff ff       	call   318 <putc>
      }
      state = 0;
 583:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 58a:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 58e:	8b 55 0c             	mov    0xc(%ebp),%edx
 591:	8b 45 f0             	mov    -0x10(%ebp),%eax
 594:	01 d0                	add    %edx,%eax
 596:	0f b6 00             	movzbl (%eax),%eax
 599:	84 c0                	test   %al,%al
 59b:	0f 85 70 fe ff ff    	jne    411 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 5a1:	c9                   	leave  
 5a2:	c3                   	ret    
 5a3:	90                   	nop

000005a4 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 5a4:	55                   	push   %ebp
 5a5:	89 e5                	mov    %esp,%ebp
 5a7:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 5aa:	8b 45 08             	mov    0x8(%ebp),%eax
 5ad:	83 e8 08             	sub    $0x8,%eax
 5b0:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 5b3:	a1 18 0a 00 00       	mov    0xa18,%eax
 5b8:	89 45 fc             	mov    %eax,-0x4(%ebp)
 5bb:	eb 24                	jmp    5e1 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 5bd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 5c0:	8b 00                	mov    (%eax),%eax
 5c2:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 5c5:	77 12                	ja     5d9 <free+0x35>
 5c7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 5ca:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 5cd:	77 24                	ja     5f3 <free+0x4f>
 5cf:	8b 45 fc             	mov    -0x4(%ebp),%eax
 5d2:	8b 00                	mov    (%eax),%eax
 5d4:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 5d7:	77 1a                	ja     5f3 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 5d9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 5dc:	8b 00                	mov    (%eax),%eax
 5de:	89 45 fc             	mov    %eax,-0x4(%ebp)
 5e1:	8b 45 f8             	mov    -0x8(%ebp),%eax
 5e4:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 5e7:	76 d4                	jbe    5bd <free+0x19>
 5e9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 5ec:	8b 00                	mov    (%eax),%eax
 5ee:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 5f1:	76 ca                	jbe    5bd <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 5f3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 5f6:	8b 40 04             	mov    0x4(%eax),%eax
 5f9:	c1 e0 03             	shl    $0x3,%eax
 5fc:	89 c2                	mov    %eax,%edx
 5fe:	03 55 f8             	add    -0x8(%ebp),%edx
 601:	8b 45 fc             	mov    -0x4(%ebp),%eax
 604:	8b 00                	mov    (%eax),%eax
 606:	39 c2                	cmp    %eax,%edx
 608:	75 24                	jne    62e <free+0x8a>
    bp->s.size += p->s.ptr->s.size;
 60a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 60d:	8b 50 04             	mov    0x4(%eax),%edx
 610:	8b 45 fc             	mov    -0x4(%ebp),%eax
 613:	8b 00                	mov    (%eax),%eax
 615:	8b 40 04             	mov    0x4(%eax),%eax
 618:	01 c2                	add    %eax,%edx
 61a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 61d:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 620:	8b 45 fc             	mov    -0x4(%ebp),%eax
 623:	8b 00                	mov    (%eax),%eax
 625:	8b 10                	mov    (%eax),%edx
 627:	8b 45 f8             	mov    -0x8(%ebp),%eax
 62a:	89 10                	mov    %edx,(%eax)
 62c:	eb 0a                	jmp    638 <free+0x94>
  } else
    bp->s.ptr = p->s.ptr;
 62e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 631:	8b 10                	mov    (%eax),%edx
 633:	8b 45 f8             	mov    -0x8(%ebp),%eax
 636:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 638:	8b 45 fc             	mov    -0x4(%ebp),%eax
 63b:	8b 40 04             	mov    0x4(%eax),%eax
 63e:	c1 e0 03             	shl    $0x3,%eax
 641:	03 45 fc             	add    -0x4(%ebp),%eax
 644:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 647:	75 20                	jne    669 <free+0xc5>
    p->s.size += bp->s.size;
 649:	8b 45 fc             	mov    -0x4(%ebp),%eax
 64c:	8b 50 04             	mov    0x4(%eax),%edx
 64f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 652:	8b 40 04             	mov    0x4(%eax),%eax
 655:	01 c2                	add    %eax,%edx
 657:	8b 45 fc             	mov    -0x4(%ebp),%eax
 65a:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 65d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 660:	8b 10                	mov    (%eax),%edx
 662:	8b 45 fc             	mov    -0x4(%ebp),%eax
 665:	89 10                	mov    %edx,(%eax)
 667:	eb 08                	jmp    671 <free+0xcd>
  } else
    p->s.ptr = bp;
 669:	8b 45 fc             	mov    -0x4(%ebp),%eax
 66c:	8b 55 f8             	mov    -0x8(%ebp),%edx
 66f:	89 10                	mov    %edx,(%eax)
  freep = p;
 671:	8b 45 fc             	mov    -0x4(%ebp),%eax
 674:	a3 18 0a 00 00       	mov    %eax,0xa18
}
 679:	c9                   	leave  
 67a:	c3                   	ret    

0000067b <morecore>:

static Header*
morecore(uint nu)
{
 67b:	55                   	push   %ebp
 67c:	89 e5                	mov    %esp,%ebp
 67e:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 681:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 688:	77 07                	ja     691 <morecore+0x16>
    nu = 4096;
 68a:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 691:	8b 45 08             	mov    0x8(%ebp),%eax
 694:	c1 e0 03             	shl    $0x3,%eax
 697:	89 04 24             	mov    %eax,(%esp)
 69a:	e8 59 fc ff ff       	call   2f8 <sbrk>
 69f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 6a2:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 6a6:	75 07                	jne    6af <morecore+0x34>
    return 0;
 6a8:	b8 00 00 00 00       	mov    $0x0,%eax
 6ad:	eb 22                	jmp    6d1 <morecore+0x56>
  hp = (Header*)p;
 6af:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6b2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 6b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6b8:	8b 55 08             	mov    0x8(%ebp),%edx
 6bb:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 6be:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6c1:	83 c0 08             	add    $0x8,%eax
 6c4:	89 04 24             	mov    %eax,(%esp)
 6c7:	e8 d8 fe ff ff       	call   5a4 <free>
  return freep;
 6cc:	a1 18 0a 00 00       	mov    0xa18,%eax
}
 6d1:	c9                   	leave  
 6d2:	c3                   	ret    

000006d3 <malloc>:

void*
malloc(uint nbytes)
{
 6d3:	55                   	push   %ebp
 6d4:	89 e5                	mov    %esp,%ebp
 6d6:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 6d9:	8b 45 08             	mov    0x8(%ebp),%eax
 6dc:	83 c0 07             	add    $0x7,%eax
 6df:	c1 e8 03             	shr    $0x3,%eax
 6e2:	83 c0 01             	add    $0x1,%eax
 6e5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 6e8:	a1 18 0a 00 00       	mov    0xa18,%eax
 6ed:	89 45 f0             	mov    %eax,-0x10(%ebp)
 6f0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 6f4:	75 23                	jne    719 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 6f6:	c7 45 f0 10 0a 00 00 	movl   $0xa10,-0x10(%ebp)
 6fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
 700:	a3 18 0a 00 00       	mov    %eax,0xa18
 705:	a1 18 0a 00 00       	mov    0xa18,%eax
 70a:	a3 10 0a 00 00       	mov    %eax,0xa10
    base.s.size = 0;
 70f:	c7 05 14 0a 00 00 00 	movl   $0x0,0xa14
 716:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 719:	8b 45 f0             	mov    -0x10(%ebp),%eax
 71c:	8b 00                	mov    (%eax),%eax
 71e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 721:	8b 45 f4             	mov    -0xc(%ebp),%eax
 724:	8b 40 04             	mov    0x4(%eax),%eax
 727:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 72a:	72 4d                	jb     779 <malloc+0xa6>
      if(p->s.size == nunits)
 72c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 72f:	8b 40 04             	mov    0x4(%eax),%eax
 732:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 735:	75 0c                	jne    743 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 737:	8b 45 f4             	mov    -0xc(%ebp),%eax
 73a:	8b 10                	mov    (%eax),%edx
 73c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 73f:	89 10                	mov    %edx,(%eax)
 741:	eb 26                	jmp    769 <malloc+0x96>
      else {
        p->s.size -= nunits;
 743:	8b 45 f4             	mov    -0xc(%ebp),%eax
 746:	8b 40 04             	mov    0x4(%eax),%eax
 749:	89 c2                	mov    %eax,%edx
 74b:	2b 55 ec             	sub    -0x14(%ebp),%edx
 74e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 751:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 754:	8b 45 f4             	mov    -0xc(%ebp),%eax
 757:	8b 40 04             	mov    0x4(%eax),%eax
 75a:	c1 e0 03             	shl    $0x3,%eax
 75d:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 760:	8b 45 f4             	mov    -0xc(%ebp),%eax
 763:	8b 55 ec             	mov    -0x14(%ebp),%edx
 766:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 769:	8b 45 f0             	mov    -0x10(%ebp),%eax
 76c:	a3 18 0a 00 00       	mov    %eax,0xa18
      return (void*)(p + 1);
 771:	8b 45 f4             	mov    -0xc(%ebp),%eax
 774:	83 c0 08             	add    $0x8,%eax
 777:	eb 38                	jmp    7b1 <malloc+0xde>
    }
    if(p == freep)
 779:	a1 18 0a 00 00       	mov    0xa18,%eax
 77e:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 781:	75 1b                	jne    79e <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 783:	8b 45 ec             	mov    -0x14(%ebp),%eax
 786:	89 04 24             	mov    %eax,(%esp)
 789:	e8 ed fe ff ff       	call   67b <morecore>
 78e:	89 45 f4             	mov    %eax,-0xc(%ebp)
 791:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 795:	75 07                	jne    79e <malloc+0xcb>
        return 0;
 797:	b8 00 00 00 00       	mov    $0x0,%eax
 79c:	eb 13                	jmp    7b1 <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 79e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7a1:	89 45 f0             	mov    %eax,-0x10(%ebp)
 7a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7a7:	8b 00                	mov    (%eax),%eax
 7a9:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 7ac:	e9 70 ff ff ff       	jmp    721 <malloc+0x4e>
}
 7b1:	c9                   	leave  
 7b2:	c3                   	ret    
