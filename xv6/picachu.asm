
_picachu:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:

//extern int retTest()



int main(int argc, char *argv[]){
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 e4 f0             	and    $0xfffffff0,%esp
   6:	83 ec 10             	sub    $0x10,%esp
//	for(i=0; i< size; i++){
//		printf(1,"%d - %s (%d) \n", i, arr[i].name, arr[i].pid);
//	}

	while(1){
		sleep(10000);
   9:	c7 04 24 10 27 00 00 	movl   $0x2710,(%esp)
  10:	e8 f7 02 00 00       	call   30c <sleep>
	}
  15:	eb f2                	jmp    9 <main+0x9>
  17:	90                   	nop

00000018 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
  18:	55                   	push   %ebp
  19:	89 e5                	mov    %esp,%ebp
  1b:	57                   	push   %edi
  1c:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
  1d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  20:	8b 55 10             	mov    0x10(%ebp),%edx
  23:	8b 45 0c             	mov    0xc(%ebp),%eax
  26:	89 cb                	mov    %ecx,%ebx
  28:	89 df                	mov    %ebx,%edi
  2a:	89 d1                	mov    %edx,%ecx
  2c:	fc                   	cld    
  2d:	f3 aa                	rep stos %al,%es:(%edi)
  2f:	89 ca                	mov    %ecx,%edx
  31:	89 fb                	mov    %edi,%ebx
  33:	89 5d 08             	mov    %ebx,0x8(%ebp)
  36:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
  39:	5b                   	pop    %ebx
  3a:	5f                   	pop    %edi
  3b:	5d                   	pop    %ebp
  3c:	c3                   	ret    

0000003d <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
  3d:	55                   	push   %ebp
  3e:	89 e5                	mov    %esp,%ebp
  40:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
  43:	8b 45 08             	mov    0x8(%ebp),%eax
  46:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
  49:	90                   	nop
  4a:	8b 45 0c             	mov    0xc(%ebp),%eax
  4d:	0f b6 10             	movzbl (%eax),%edx
  50:	8b 45 08             	mov    0x8(%ebp),%eax
  53:	88 10                	mov    %dl,(%eax)
  55:	8b 45 08             	mov    0x8(%ebp),%eax
  58:	0f b6 00             	movzbl (%eax),%eax
  5b:	84 c0                	test   %al,%al
  5d:	0f 95 c0             	setne  %al
  60:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  64:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  68:	84 c0                	test   %al,%al
  6a:	75 de                	jne    4a <strcpy+0xd>
    ;
  return os;
  6c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  6f:	c9                   	leave  
  70:	c3                   	ret    

00000071 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  71:	55                   	push   %ebp
  72:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
  74:	eb 08                	jmp    7e <strcmp+0xd>
    p++, q++;
  76:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  7a:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
  7e:	8b 45 08             	mov    0x8(%ebp),%eax
  81:	0f b6 00             	movzbl (%eax),%eax
  84:	84 c0                	test   %al,%al
  86:	74 10                	je     98 <strcmp+0x27>
  88:	8b 45 08             	mov    0x8(%ebp),%eax
  8b:	0f b6 10             	movzbl (%eax),%edx
  8e:	8b 45 0c             	mov    0xc(%ebp),%eax
  91:	0f b6 00             	movzbl (%eax),%eax
  94:	38 c2                	cmp    %al,%dl
  96:	74 de                	je     76 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
  98:	8b 45 08             	mov    0x8(%ebp),%eax
  9b:	0f b6 00             	movzbl (%eax),%eax
  9e:	0f b6 d0             	movzbl %al,%edx
  a1:	8b 45 0c             	mov    0xc(%ebp),%eax
  a4:	0f b6 00             	movzbl (%eax),%eax
  a7:	0f b6 c0             	movzbl %al,%eax
  aa:	89 d1                	mov    %edx,%ecx
  ac:	29 c1                	sub    %eax,%ecx
  ae:	89 c8                	mov    %ecx,%eax
}
  b0:	5d                   	pop    %ebp
  b1:	c3                   	ret    

000000b2 <strlen>:

uint
strlen(char *s)
{
  b2:	55                   	push   %ebp
  b3:	89 e5                	mov    %esp,%ebp
  b5:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
  b8:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  bf:	eb 04                	jmp    c5 <strlen+0x13>
  c1:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  c5:	8b 45 fc             	mov    -0x4(%ebp),%eax
  c8:	03 45 08             	add    0x8(%ebp),%eax
  cb:	0f b6 00             	movzbl (%eax),%eax
  ce:	84 c0                	test   %al,%al
  d0:	75 ef                	jne    c1 <strlen+0xf>
    ;
  return n;
  d2:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  d5:	c9                   	leave  
  d6:	c3                   	ret    

000000d7 <memset>:

void*
memset(void *dst, int c, uint n)
{
  d7:	55                   	push   %ebp
  d8:	89 e5                	mov    %esp,%ebp
  da:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
  dd:	8b 45 10             	mov    0x10(%ebp),%eax
  e0:	89 44 24 08          	mov    %eax,0x8(%esp)
  e4:	8b 45 0c             	mov    0xc(%ebp),%eax
  e7:	89 44 24 04          	mov    %eax,0x4(%esp)
  eb:	8b 45 08             	mov    0x8(%ebp),%eax
  ee:	89 04 24             	mov    %eax,(%esp)
  f1:	e8 22 ff ff ff       	call   18 <stosb>
  return dst;
  f6:	8b 45 08             	mov    0x8(%ebp),%eax
}
  f9:	c9                   	leave  
  fa:	c3                   	ret    

000000fb <strchr>:

char*
strchr(const char *s, char c)
{
  fb:	55                   	push   %ebp
  fc:	89 e5                	mov    %esp,%ebp
  fe:	83 ec 04             	sub    $0x4,%esp
 101:	8b 45 0c             	mov    0xc(%ebp),%eax
 104:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 107:	eb 14                	jmp    11d <strchr+0x22>
    if(*s == c)
 109:	8b 45 08             	mov    0x8(%ebp),%eax
 10c:	0f b6 00             	movzbl (%eax),%eax
 10f:	3a 45 fc             	cmp    -0x4(%ebp),%al
 112:	75 05                	jne    119 <strchr+0x1e>
      return (char*)s;
 114:	8b 45 08             	mov    0x8(%ebp),%eax
 117:	eb 13                	jmp    12c <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 119:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 11d:	8b 45 08             	mov    0x8(%ebp),%eax
 120:	0f b6 00             	movzbl (%eax),%eax
 123:	84 c0                	test   %al,%al
 125:	75 e2                	jne    109 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 127:	b8 00 00 00 00       	mov    $0x0,%eax
}
 12c:	c9                   	leave  
 12d:	c3                   	ret    

0000012e <gets>:

char*
gets(char *buf, int max)
{
 12e:	55                   	push   %ebp
 12f:	89 e5                	mov    %esp,%ebp
 131:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 134:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 13b:	eb 44                	jmp    181 <gets+0x53>
    cc = read(0, &c, 1);
 13d:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 144:	00 
 145:	8d 45 ef             	lea    -0x11(%ebp),%eax
 148:	89 44 24 04          	mov    %eax,0x4(%esp)
 14c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 153:	e8 3c 01 00 00       	call   294 <read>
 158:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 15b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 15f:	7e 2d                	jle    18e <gets+0x60>
      break;
    buf[i++] = c;
 161:	8b 45 f4             	mov    -0xc(%ebp),%eax
 164:	03 45 08             	add    0x8(%ebp),%eax
 167:	0f b6 55 ef          	movzbl -0x11(%ebp),%edx
 16b:	88 10                	mov    %dl,(%eax)
 16d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(c == '\n' || c == '\r')
 171:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 175:	3c 0a                	cmp    $0xa,%al
 177:	74 16                	je     18f <gets+0x61>
 179:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 17d:	3c 0d                	cmp    $0xd,%al
 17f:	74 0e                	je     18f <gets+0x61>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 181:	8b 45 f4             	mov    -0xc(%ebp),%eax
 184:	83 c0 01             	add    $0x1,%eax
 187:	3b 45 0c             	cmp    0xc(%ebp),%eax
 18a:	7c b1                	jl     13d <gets+0xf>
 18c:	eb 01                	jmp    18f <gets+0x61>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 18e:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 18f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 192:	03 45 08             	add    0x8(%ebp),%eax
 195:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 198:	8b 45 08             	mov    0x8(%ebp),%eax
}
 19b:	c9                   	leave  
 19c:	c3                   	ret    

0000019d <stat>:

int
stat(char *n, struct stat *st)
{
 19d:	55                   	push   %ebp
 19e:	89 e5                	mov    %esp,%ebp
 1a0:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1a3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 1aa:	00 
 1ab:	8b 45 08             	mov    0x8(%ebp),%eax
 1ae:	89 04 24             	mov    %eax,(%esp)
 1b1:	e8 06 01 00 00       	call   2bc <open>
 1b6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 1b9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 1bd:	79 07                	jns    1c6 <stat+0x29>
    return -1;
 1bf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 1c4:	eb 23                	jmp    1e9 <stat+0x4c>
  r = fstat(fd, st);
 1c6:	8b 45 0c             	mov    0xc(%ebp),%eax
 1c9:	89 44 24 04          	mov    %eax,0x4(%esp)
 1cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1d0:	89 04 24             	mov    %eax,(%esp)
 1d3:	e8 fc 00 00 00       	call   2d4 <fstat>
 1d8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 1db:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1de:	89 04 24             	mov    %eax,(%esp)
 1e1:	e8 be 00 00 00       	call   2a4 <close>
  return r;
 1e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 1e9:	c9                   	leave  
 1ea:	c3                   	ret    

000001eb <atoi>:

int
atoi(const char *s)
{
 1eb:	55                   	push   %ebp
 1ec:	89 e5                	mov    %esp,%ebp
 1ee:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 1f1:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 1f8:	eb 23                	jmp    21d <atoi+0x32>
    n = n*10 + *s++ - '0';
 1fa:	8b 55 fc             	mov    -0x4(%ebp),%edx
 1fd:	89 d0                	mov    %edx,%eax
 1ff:	c1 e0 02             	shl    $0x2,%eax
 202:	01 d0                	add    %edx,%eax
 204:	01 c0                	add    %eax,%eax
 206:	89 c2                	mov    %eax,%edx
 208:	8b 45 08             	mov    0x8(%ebp),%eax
 20b:	0f b6 00             	movzbl (%eax),%eax
 20e:	0f be c0             	movsbl %al,%eax
 211:	01 d0                	add    %edx,%eax
 213:	83 e8 30             	sub    $0x30,%eax
 216:	89 45 fc             	mov    %eax,-0x4(%ebp)
 219:	83 45 08 01          	addl   $0x1,0x8(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 21d:	8b 45 08             	mov    0x8(%ebp),%eax
 220:	0f b6 00             	movzbl (%eax),%eax
 223:	3c 2f                	cmp    $0x2f,%al
 225:	7e 0a                	jle    231 <atoi+0x46>
 227:	8b 45 08             	mov    0x8(%ebp),%eax
 22a:	0f b6 00             	movzbl (%eax),%eax
 22d:	3c 39                	cmp    $0x39,%al
 22f:	7e c9                	jle    1fa <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 231:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 234:	c9                   	leave  
 235:	c3                   	ret    

00000236 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 236:	55                   	push   %ebp
 237:	89 e5                	mov    %esp,%ebp
 239:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 23c:	8b 45 08             	mov    0x8(%ebp),%eax
 23f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 242:	8b 45 0c             	mov    0xc(%ebp),%eax
 245:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 248:	eb 13                	jmp    25d <memmove+0x27>
    *dst++ = *src++;
 24a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 24d:	0f b6 10             	movzbl (%eax),%edx
 250:	8b 45 fc             	mov    -0x4(%ebp),%eax
 253:	88 10                	mov    %dl,(%eax)
 255:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 259:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 25d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 261:	0f 9f c0             	setg   %al
 264:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 268:	84 c0                	test   %al,%al
 26a:	75 de                	jne    24a <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 26c:	8b 45 08             	mov    0x8(%ebp),%eax
}
 26f:	c9                   	leave  
 270:	c3                   	ret    
 271:	90                   	nop
 272:	90                   	nop
 273:	90                   	nop

00000274 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 274:	b8 01 00 00 00       	mov    $0x1,%eax
 279:	cd 40                	int    $0x40
 27b:	c3                   	ret    

0000027c <exit>:
SYSCALL(exit)
 27c:	b8 02 00 00 00       	mov    $0x2,%eax
 281:	cd 40                	int    $0x40
 283:	c3                   	ret    

00000284 <wait>:
SYSCALL(wait)
 284:	b8 03 00 00 00       	mov    $0x3,%eax
 289:	cd 40                	int    $0x40
 28b:	c3                   	ret    

0000028c <pipe>:
SYSCALL(pipe)
 28c:	b8 04 00 00 00       	mov    $0x4,%eax
 291:	cd 40                	int    $0x40
 293:	c3                   	ret    

00000294 <read>:
SYSCALL(read)
 294:	b8 05 00 00 00       	mov    $0x5,%eax
 299:	cd 40                	int    $0x40
 29b:	c3                   	ret    

0000029c <write>:
SYSCALL(write)
 29c:	b8 10 00 00 00       	mov    $0x10,%eax
 2a1:	cd 40                	int    $0x40
 2a3:	c3                   	ret    

000002a4 <close>:
SYSCALL(close)
 2a4:	b8 15 00 00 00       	mov    $0x15,%eax
 2a9:	cd 40                	int    $0x40
 2ab:	c3                   	ret    

000002ac <kill>:
SYSCALL(kill)
 2ac:	b8 06 00 00 00       	mov    $0x6,%eax
 2b1:	cd 40                	int    $0x40
 2b3:	c3                   	ret    

000002b4 <exec>:
SYSCALL(exec)
 2b4:	b8 07 00 00 00       	mov    $0x7,%eax
 2b9:	cd 40                	int    $0x40
 2bb:	c3                   	ret    

000002bc <open>:
SYSCALL(open)
 2bc:	b8 0f 00 00 00       	mov    $0xf,%eax
 2c1:	cd 40                	int    $0x40
 2c3:	c3                   	ret    

000002c4 <mknod>:
SYSCALL(mknod)
 2c4:	b8 11 00 00 00       	mov    $0x11,%eax
 2c9:	cd 40                	int    $0x40
 2cb:	c3                   	ret    

000002cc <unlink>:
SYSCALL(unlink)
 2cc:	b8 12 00 00 00       	mov    $0x12,%eax
 2d1:	cd 40                	int    $0x40
 2d3:	c3                   	ret    

000002d4 <fstat>:
SYSCALL(fstat)
 2d4:	b8 08 00 00 00       	mov    $0x8,%eax
 2d9:	cd 40                	int    $0x40
 2db:	c3                   	ret    

000002dc <link>:
SYSCALL(link)
 2dc:	b8 13 00 00 00       	mov    $0x13,%eax
 2e1:	cd 40                	int    $0x40
 2e3:	c3                   	ret    

000002e4 <mkdir>:
SYSCALL(mkdir)
 2e4:	b8 14 00 00 00       	mov    $0x14,%eax
 2e9:	cd 40                	int    $0x40
 2eb:	c3                   	ret    

000002ec <chdir>:
SYSCALL(chdir)
 2ec:	b8 09 00 00 00       	mov    $0x9,%eax
 2f1:	cd 40                	int    $0x40
 2f3:	c3                   	ret    

000002f4 <dup>:
SYSCALL(dup)
 2f4:	b8 0a 00 00 00       	mov    $0xa,%eax
 2f9:	cd 40                	int    $0x40
 2fb:	c3                   	ret    

000002fc <getpid>:
SYSCALL(getpid)
 2fc:	b8 0b 00 00 00       	mov    $0xb,%eax
 301:	cd 40                	int    $0x40
 303:	c3                   	ret    

00000304 <sbrk>:
SYSCALL(sbrk)
 304:	b8 0c 00 00 00       	mov    $0xc,%eax
 309:	cd 40                	int    $0x40
 30b:	c3                   	ret    

0000030c <sleep>:
SYSCALL(sleep)
 30c:	b8 0d 00 00 00       	mov    $0xd,%eax
 311:	cd 40                	int    $0x40
 313:	c3                   	ret    

00000314 <uptime>:
SYSCALL(uptime)
 314:	b8 0e 00 00 00       	mov    $0xe,%eax
 319:	cd 40                	int    $0x40
 31b:	c3                   	ret    

0000031c <waitpid>:
SYSCALL(waitpid)
 31c:	b8 16 00 00 00       	mov    $0x16,%eax
 321:	cd 40                	int    $0x40
 323:	c3                   	ret    

00000324 <wait_stat>:
SYSCALL(wait_stat)
 324:	b8 17 00 00 00       	mov    $0x17,%eax
 329:	cd 40                	int    $0x40
 32b:	c3                   	ret    

0000032c <list_pgroup>:
SYSCALL(list_pgroup)
 32c:	b8 18 00 00 00       	mov    $0x18,%eax
 331:	cd 40                	int    $0x40
 333:	c3                   	ret    

00000334 <foreground>:
SYSCALL(foreground)
 334:	b8 19 00 00 00       	mov    $0x19,%eax
 339:	cd 40                	int    $0x40
 33b:	c3                   	ret    

0000033c <set_priority>:
SYSCALL(set_priority)
 33c:	b8 1a 00 00 00       	mov    $0x1a,%eax
 341:	cd 40                	int    $0x40
 343:	c3                   	ret    

00000344 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 344:	55                   	push   %ebp
 345:	89 e5                	mov    %esp,%ebp
 347:	83 ec 28             	sub    $0x28,%esp
 34a:	8b 45 0c             	mov    0xc(%ebp),%eax
 34d:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 350:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 357:	00 
 358:	8d 45 f4             	lea    -0xc(%ebp),%eax
 35b:	89 44 24 04          	mov    %eax,0x4(%esp)
 35f:	8b 45 08             	mov    0x8(%ebp),%eax
 362:	89 04 24             	mov    %eax,(%esp)
 365:	e8 32 ff ff ff       	call   29c <write>
}
 36a:	c9                   	leave  
 36b:	c3                   	ret    

0000036c <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 36c:	55                   	push   %ebp
 36d:	89 e5                	mov    %esp,%ebp
 36f:	83 ec 48             	sub    $0x48,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 372:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 379:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 37d:	74 17                	je     396 <printint+0x2a>
 37f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 383:	79 11                	jns    396 <printint+0x2a>
    neg = 1;
 385:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 38c:	8b 45 0c             	mov    0xc(%ebp),%eax
 38f:	f7 d8                	neg    %eax
 391:	89 45 ec             	mov    %eax,-0x14(%ebp)
 394:	eb 06                	jmp    39c <printint+0x30>
  } else {
    x = xx;
 396:	8b 45 0c             	mov    0xc(%ebp),%eax
 399:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 39c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 3a3:	8b 4d 10             	mov    0x10(%ebp),%ecx
 3a6:	8b 45 ec             	mov    -0x14(%ebp),%eax
 3a9:	ba 00 00 00 00       	mov    $0x0,%edx
 3ae:	f7 f1                	div    %ecx
 3b0:	89 d0                	mov    %edx,%eax
 3b2:	0f b6 90 24 0a 00 00 	movzbl 0xa24(%eax),%edx
 3b9:	8d 45 dc             	lea    -0x24(%ebp),%eax
 3bc:	03 45 f4             	add    -0xc(%ebp),%eax
 3bf:	88 10                	mov    %dl,(%eax)
 3c1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  }while((x /= base) != 0);
 3c5:	8b 55 10             	mov    0x10(%ebp),%edx
 3c8:	89 55 d4             	mov    %edx,-0x2c(%ebp)
 3cb:	8b 45 ec             	mov    -0x14(%ebp),%eax
 3ce:	ba 00 00 00 00       	mov    $0x0,%edx
 3d3:	f7 75 d4             	divl   -0x2c(%ebp)
 3d6:	89 45 ec             	mov    %eax,-0x14(%ebp)
 3d9:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 3dd:	75 c4                	jne    3a3 <printint+0x37>
  if(neg)
 3df:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 3e3:	74 2a                	je     40f <printint+0xa3>
    buf[i++] = '-';
 3e5:	8d 45 dc             	lea    -0x24(%ebp),%eax
 3e8:	03 45 f4             	add    -0xc(%ebp),%eax
 3eb:	c6 00 2d             	movb   $0x2d,(%eax)
 3ee:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

  while(--i >= 0)
 3f2:	eb 1b                	jmp    40f <printint+0xa3>
    putc(fd, buf[i]);
 3f4:	8d 45 dc             	lea    -0x24(%ebp),%eax
 3f7:	03 45 f4             	add    -0xc(%ebp),%eax
 3fa:	0f b6 00             	movzbl (%eax),%eax
 3fd:	0f be c0             	movsbl %al,%eax
 400:	89 44 24 04          	mov    %eax,0x4(%esp)
 404:	8b 45 08             	mov    0x8(%ebp),%eax
 407:	89 04 24             	mov    %eax,(%esp)
 40a:	e8 35 ff ff ff       	call   344 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 40f:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 413:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 417:	79 db                	jns    3f4 <printint+0x88>
    putc(fd, buf[i]);
}
 419:	c9                   	leave  
 41a:	c3                   	ret    

0000041b <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 41b:	55                   	push   %ebp
 41c:	89 e5                	mov    %esp,%ebp
 41e:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 421:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 428:	8d 45 0c             	lea    0xc(%ebp),%eax
 42b:	83 c0 04             	add    $0x4,%eax
 42e:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 431:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 438:	e9 7d 01 00 00       	jmp    5ba <printf+0x19f>
    c = fmt[i] & 0xff;
 43d:	8b 55 0c             	mov    0xc(%ebp),%edx
 440:	8b 45 f0             	mov    -0x10(%ebp),%eax
 443:	01 d0                	add    %edx,%eax
 445:	0f b6 00             	movzbl (%eax),%eax
 448:	0f be c0             	movsbl %al,%eax
 44b:	25 ff 00 00 00       	and    $0xff,%eax
 450:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 453:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 457:	75 2c                	jne    485 <printf+0x6a>
      if(c == '%'){
 459:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 45d:	75 0c                	jne    46b <printf+0x50>
        state = '%';
 45f:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 466:	e9 4b 01 00 00       	jmp    5b6 <printf+0x19b>
      } else {
        putc(fd, c);
 46b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 46e:	0f be c0             	movsbl %al,%eax
 471:	89 44 24 04          	mov    %eax,0x4(%esp)
 475:	8b 45 08             	mov    0x8(%ebp),%eax
 478:	89 04 24             	mov    %eax,(%esp)
 47b:	e8 c4 fe ff ff       	call   344 <putc>
 480:	e9 31 01 00 00       	jmp    5b6 <printf+0x19b>
      }
    } else if(state == '%'){
 485:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 489:	0f 85 27 01 00 00    	jne    5b6 <printf+0x19b>
      if(c == 'd'){
 48f:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 493:	75 2d                	jne    4c2 <printf+0xa7>
        printint(fd, *ap, 10, 1);
 495:	8b 45 e8             	mov    -0x18(%ebp),%eax
 498:	8b 00                	mov    (%eax),%eax
 49a:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 4a1:	00 
 4a2:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 4a9:	00 
 4aa:	89 44 24 04          	mov    %eax,0x4(%esp)
 4ae:	8b 45 08             	mov    0x8(%ebp),%eax
 4b1:	89 04 24             	mov    %eax,(%esp)
 4b4:	e8 b3 fe ff ff       	call   36c <printint>
        ap++;
 4b9:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 4bd:	e9 ed 00 00 00       	jmp    5af <printf+0x194>
      } else if(c == 'x' || c == 'p'){
 4c2:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 4c6:	74 06                	je     4ce <printf+0xb3>
 4c8:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 4cc:	75 2d                	jne    4fb <printf+0xe0>
        printint(fd, *ap, 16, 0);
 4ce:	8b 45 e8             	mov    -0x18(%ebp),%eax
 4d1:	8b 00                	mov    (%eax),%eax
 4d3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 4da:	00 
 4db:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 4e2:	00 
 4e3:	89 44 24 04          	mov    %eax,0x4(%esp)
 4e7:	8b 45 08             	mov    0x8(%ebp),%eax
 4ea:	89 04 24             	mov    %eax,(%esp)
 4ed:	e8 7a fe ff ff       	call   36c <printint>
        ap++;
 4f2:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 4f6:	e9 b4 00 00 00       	jmp    5af <printf+0x194>
      } else if(c == 's'){
 4fb:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 4ff:	75 46                	jne    547 <printf+0x12c>
        s = (char*)*ap;
 501:	8b 45 e8             	mov    -0x18(%ebp),%eax
 504:	8b 00                	mov    (%eax),%eax
 506:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 509:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 50d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 511:	75 27                	jne    53a <printf+0x11f>
          s = "(null)";
 513:	c7 45 f4 df 07 00 00 	movl   $0x7df,-0xc(%ebp)
        while(*s != 0){
 51a:	eb 1e                	jmp    53a <printf+0x11f>
          putc(fd, *s);
 51c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 51f:	0f b6 00             	movzbl (%eax),%eax
 522:	0f be c0             	movsbl %al,%eax
 525:	89 44 24 04          	mov    %eax,0x4(%esp)
 529:	8b 45 08             	mov    0x8(%ebp),%eax
 52c:	89 04 24             	mov    %eax,(%esp)
 52f:	e8 10 fe ff ff       	call   344 <putc>
          s++;
 534:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 538:	eb 01                	jmp    53b <printf+0x120>
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 53a:	90                   	nop
 53b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 53e:	0f b6 00             	movzbl (%eax),%eax
 541:	84 c0                	test   %al,%al
 543:	75 d7                	jne    51c <printf+0x101>
 545:	eb 68                	jmp    5af <printf+0x194>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 547:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 54b:	75 1d                	jne    56a <printf+0x14f>
        putc(fd, *ap);
 54d:	8b 45 e8             	mov    -0x18(%ebp),%eax
 550:	8b 00                	mov    (%eax),%eax
 552:	0f be c0             	movsbl %al,%eax
 555:	89 44 24 04          	mov    %eax,0x4(%esp)
 559:	8b 45 08             	mov    0x8(%ebp),%eax
 55c:	89 04 24             	mov    %eax,(%esp)
 55f:	e8 e0 fd ff ff       	call   344 <putc>
        ap++;
 564:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 568:	eb 45                	jmp    5af <printf+0x194>
      } else if(c == '%'){
 56a:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 56e:	75 17                	jne    587 <printf+0x16c>
        putc(fd, c);
 570:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 573:	0f be c0             	movsbl %al,%eax
 576:	89 44 24 04          	mov    %eax,0x4(%esp)
 57a:	8b 45 08             	mov    0x8(%ebp),%eax
 57d:	89 04 24             	mov    %eax,(%esp)
 580:	e8 bf fd ff ff       	call   344 <putc>
 585:	eb 28                	jmp    5af <printf+0x194>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 587:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 58e:	00 
 58f:	8b 45 08             	mov    0x8(%ebp),%eax
 592:	89 04 24             	mov    %eax,(%esp)
 595:	e8 aa fd ff ff       	call   344 <putc>
        putc(fd, c);
 59a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 59d:	0f be c0             	movsbl %al,%eax
 5a0:	89 44 24 04          	mov    %eax,0x4(%esp)
 5a4:	8b 45 08             	mov    0x8(%ebp),%eax
 5a7:	89 04 24             	mov    %eax,(%esp)
 5aa:	e8 95 fd ff ff       	call   344 <putc>
      }
      state = 0;
 5af:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 5b6:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 5ba:	8b 55 0c             	mov    0xc(%ebp),%edx
 5bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
 5c0:	01 d0                	add    %edx,%eax
 5c2:	0f b6 00             	movzbl (%eax),%eax
 5c5:	84 c0                	test   %al,%al
 5c7:	0f 85 70 fe ff ff    	jne    43d <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 5cd:	c9                   	leave  
 5ce:	c3                   	ret    
 5cf:	90                   	nop

000005d0 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 5d0:	55                   	push   %ebp
 5d1:	89 e5                	mov    %esp,%ebp
 5d3:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 5d6:	8b 45 08             	mov    0x8(%ebp),%eax
 5d9:	83 e8 08             	sub    $0x8,%eax
 5dc:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 5df:	a1 40 0a 00 00       	mov    0xa40,%eax
 5e4:	89 45 fc             	mov    %eax,-0x4(%ebp)
 5e7:	eb 24                	jmp    60d <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 5e9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 5ec:	8b 00                	mov    (%eax),%eax
 5ee:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 5f1:	77 12                	ja     605 <free+0x35>
 5f3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 5f6:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 5f9:	77 24                	ja     61f <free+0x4f>
 5fb:	8b 45 fc             	mov    -0x4(%ebp),%eax
 5fe:	8b 00                	mov    (%eax),%eax
 600:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 603:	77 1a                	ja     61f <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 605:	8b 45 fc             	mov    -0x4(%ebp),%eax
 608:	8b 00                	mov    (%eax),%eax
 60a:	89 45 fc             	mov    %eax,-0x4(%ebp)
 60d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 610:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 613:	76 d4                	jbe    5e9 <free+0x19>
 615:	8b 45 fc             	mov    -0x4(%ebp),%eax
 618:	8b 00                	mov    (%eax),%eax
 61a:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 61d:	76 ca                	jbe    5e9 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 61f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 622:	8b 40 04             	mov    0x4(%eax),%eax
 625:	c1 e0 03             	shl    $0x3,%eax
 628:	89 c2                	mov    %eax,%edx
 62a:	03 55 f8             	add    -0x8(%ebp),%edx
 62d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 630:	8b 00                	mov    (%eax),%eax
 632:	39 c2                	cmp    %eax,%edx
 634:	75 24                	jne    65a <free+0x8a>
    bp->s.size += p->s.ptr->s.size;
 636:	8b 45 f8             	mov    -0x8(%ebp),%eax
 639:	8b 50 04             	mov    0x4(%eax),%edx
 63c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 63f:	8b 00                	mov    (%eax),%eax
 641:	8b 40 04             	mov    0x4(%eax),%eax
 644:	01 c2                	add    %eax,%edx
 646:	8b 45 f8             	mov    -0x8(%ebp),%eax
 649:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 64c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 64f:	8b 00                	mov    (%eax),%eax
 651:	8b 10                	mov    (%eax),%edx
 653:	8b 45 f8             	mov    -0x8(%ebp),%eax
 656:	89 10                	mov    %edx,(%eax)
 658:	eb 0a                	jmp    664 <free+0x94>
  } else
    bp->s.ptr = p->s.ptr;
 65a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 65d:	8b 10                	mov    (%eax),%edx
 65f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 662:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 664:	8b 45 fc             	mov    -0x4(%ebp),%eax
 667:	8b 40 04             	mov    0x4(%eax),%eax
 66a:	c1 e0 03             	shl    $0x3,%eax
 66d:	03 45 fc             	add    -0x4(%ebp),%eax
 670:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 673:	75 20                	jne    695 <free+0xc5>
    p->s.size += bp->s.size;
 675:	8b 45 fc             	mov    -0x4(%ebp),%eax
 678:	8b 50 04             	mov    0x4(%eax),%edx
 67b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 67e:	8b 40 04             	mov    0x4(%eax),%eax
 681:	01 c2                	add    %eax,%edx
 683:	8b 45 fc             	mov    -0x4(%ebp),%eax
 686:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 689:	8b 45 f8             	mov    -0x8(%ebp),%eax
 68c:	8b 10                	mov    (%eax),%edx
 68e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 691:	89 10                	mov    %edx,(%eax)
 693:	eb 08                	jmp    69d <free+0xcd>
  } else
    p->s.ptr = bp;
 695:	8b 45 fc             	mov    -0x4(%ebp),%eax
 698:	8b 55 f8             	mov    -0x8(%ebp),%edx
 69b:	89 10                	mov    %edx,(%eax)
  freep = p;
 69d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6a0:	a3 40 0a 00 00       	mov    %eax,0xa40
}
 6a5:	c9                   	leave  
 6a6:	c3                   	ret    

000006a7 <morecore>:

static Header*
morecore(uint nu)
{
 6a7:	55                   	push   %ebp
 6a8:	89 e5                	mov    %esp,%ebp
 6aa:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 6ad:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 6b4:	77 07                	ja     6bd <morecore+0x16>
    nu = 4096;
 6b6:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 6bd:	8b 45 08             	mov    0x8(%ebp),%eax
 6c0:	c1 e0 03             	shl    $0x3,%eax
 6c3:	89 04 24             	mov    %eax,(%esp)
 6c6:	e8 39 fc ff ff       	call   304 <sbrk>
 6cb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 6ce:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 6d2:	75 07                	jne    6db <morecore+0x34>
    return 0;
 6d4:	b8 00 00 00 00       	mov    $0x0,%eax
 6d9:	eb 22                	jmp    6fd <morecore+0x56>
  hp = (Header*)p;
 6db:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6de:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 6e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6e4:	8b 55 08             	mov    0x8(%ebp),%edx
 6e7:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 6ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6ed:	83 c0 08             	add    $0x8,%eax
 6f0:	89 04 24             	mov    %eax,(%esp)
 6f3:	e8 d8 fe ff ff       	call   5d0 <free>
  return freep;
 6f8:	a1 40 0a 00 00       	mov    0xa40,%eax
}
 6fd:	c9                   	leave  
 6fe:	c3                   	ret    

000006ff <malloc>:

void*
malloc(uint nbytes)
{
 6ff:	55                   	push   %ebp
 700:	89 e5                	mov    %esp,%ebp
 702:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 705:	8b 45 08             	mov    0x8(%ebp),%eax
 708:	83 c0 07             	add    $0x7,%eax
 70b:	c1 e8 03             	shr    $0x3,%eax
 70e:	83 c0 01             	add    $0x1,%eax
 711:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 714:	a1 40 0a 00 00       	mov    0xa40,%eax
 719:	89 45 f0             	mov    %eax,-0x10(%ebp)
 71c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 720:	75 23                	jne    745 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 722:	c7 45 f0 38 0a 00 00 	movl   $0xa38,-0x10(%ebp)
 729:	8b 45 f0             	mov    -0x10(%ebp),%eax
 72c:	a3 40 0a 00 00       	mov    %eax,0xa40
 731:	a1 40 0a 00 00       	mov    0xa40,%eax
 736:	a3 38 0a 00 00       	mov    %eax,0xa38
    base.s.size = 0;
 73b:	c7 05 3c 0a 00 00 00 	movl   $0x0,0xa3c
 742:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 745:	8b 45 f0             	mov    -0x10(%ebp),%eax
 748:	8b 00                	mov    (%eax),%eax
 74a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 74d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 750:	8b 40 04             	mov    0x4(%eax),%eax
 753:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 756:	72 4d                	jb     7a5 <malloc+0xa6>
      if(p->s.size == nunits)
 758:	8b 45 f4             	mov    -0xc(%ebp),%eax
 75b:	8b 40 04             	mov    0x4(%eax),%eax
 75e:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 761:	75 0c                	jne    76f <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 763:	8b 45 f4             	mov    -0xc(%ebp),%eax
 766:	8b 10                	mov    (%eax),%edx
 768:	8b 45 f0             	mov    -0x10(%ebp),%eax
 76b:	89 10                	mov    %edx,(%eax)
 76d:	eb 26                	jmp    795 <malloc+0x96>
      else {
        p->s.size -= nunits;
 76f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 772:	8b 40 04             	mov    0x4(%eax),%eax
 775:	89 c2                	mov    %eax,%edx
 777:	2b 55 ec             	sub    -0x14(%ebp),%edx
 77a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 77d:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 780:	8b 45 f4             	mov    -0xc(%ebp),%eax
 783:	8b 40 04             	mov    0x4(%eax),%eax
 786:	c1 e0 03             	shl    $0x3,%eax
 789:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 78c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 78f:	8b 55 ec             	mov    -0x14(%ebp),%edx
 792:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 795:	8b 45 f0             	mov    -0x10(%ebp),%eax
 798:	a3 40 0a 00 00       	mov    %eax,0xa40
      return (void*)(p + 1);
 79d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7a0:	83 c0 08             	add    $0x8,%eax
 7a3:	eb 38                	jmp    7dd <malloc+0xde>
    }
    if(p == freep)
 7a5:	a1 40 0a 00 00       	mov    0xa40,%eax
 7aa:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 7ad:	75 1b                	jne    7ca <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 7af:	8b 45 ec             	mov    -0x14(%ebp),%eax
 7b2:	89 04 24             	mov    %eax,(%esp)
 7b5:	e8 ed fe ff ff       	call   6a7 <morecore>
 7ba:	89 45 f4             	mov    %eax,-0xc(%ebp)
 7bd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 7c1:	75 07                	jne    7ca <malloc+0xcb>
        return 0;
 7c3:	b8 00 00 00 00       	mov    $0x0,%eax
 7c8:	eb 13                	jmp    7dd <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7cd:	89 45 f0             	mov    %eax,-0x10(%ebp)
 7d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7d3:	8b 00                	mov    (%eax),%eax
 7d5:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 7d8:	e9 70 ff ff ff       	jmp    74d <malloc+0x4e>
}
 7dd:	c9                   	leave  
 7de:	c3                   	ret    
