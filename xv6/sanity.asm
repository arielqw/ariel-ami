
_sanity:     file format elf32-i386


Disassembly of section .text:

00000000 <getTheNPrimeNumber>:
#include "types.h"
#include "stat.h"
#include "user.h"

long getTheNPrimeNumber(int n)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 ec 10             	sub    $0x10,%esp
	long i=2;
   6:	c7 45 fc 02 00 00 00 	movl   $0x2,-0x4(%ebp)
	long j;
	int isPrime = 1;
   d:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)

	for (;;) {
		for (j = 2; j < i && isPrime; ++j) {
  14:	c7 45 f8 02 00 00 00 	movl   $0x2,-0x8(%ebp)
  1b:	eb 1e                	jmp    3b <getTheNPrimeNumber+0x3b>
			if (i%j == 0){
  1d:	8b 45 fc             	mov    -0x4(%ebp),%eax
  20:	89 c2                	mov    %eax,%edx
  22:	c1 fa 1f             	sar    $0x1f,%edx
  25:	f7 7d f8             	idivl  -0x8(%ebp)
  28:	89 d0                	mov    %edx,%eax
  2a:	85 c0                	test   %eax,%eax
  2c:	75 09                	jne    37 <getTheNPrimeNumber+0x37>
				isPrime = 0;
  2e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
				break;
  35:	eb 12                	jmp    49 <getTheNPrimeNumber+0x49>
	long i=2;
	long j;
	int isPrime = 1;

	for (;;) {
		for (j = 2; j < i && isPrime; ++j) {
  37:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
  3b:	8b 45 f8             	mov    -0x8(%ebp),%eax
  3e:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  41:	7d 06                	jge    49 <getTheNPrimeNumber+0x49>
  43:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  47:	75 d4                	jne    1d <getTheNPrimeNumber+0x1d>
			if (i%j == 0){
				isPrime = 0;
				break;
			}
		}
		if (isPrime && ((n--)==1))	return i;
  49:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  4d:	74 14                	je     63 <getTheNPrimeNumber+0x63>
  4f:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
  53:	0f 94 c0             	sete   %al
  56:	83 6d 08 01          	subl   $0x1,0x8(%ebp)
  5a:	84 c0                	test   %al,%al
  5c:	74 05                	je     63 <getTheNPrimeNumber+0x63>
  5e:	8b 45 fc             	mov    -0x4(%ebp),%eax
		i++;
		isPrime=1;
	}
}
  61:	c9                   	leave  
  62:	c3                   	ret    
				isPrime = 0;
				break;
			}
		}
		if (isPrime && ((n--)==1))	return i;
		i++;
  63:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
		isPrime=1;
  67:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
	}
  6e:	eb a4                	jmp    14 <getTheNPrimeNumber+0x14>

00000070 <main>:
}

int
main(int argc, char *argv[])
{
  70:	55                   	push   %ebp
  71:	89 e5                	mov    %esp,%ebp
  73:	83 e4 f0             	and    $0xfffffff0,%esp
  76:	83 ec 10             	sub    $0x10,%esp
  printf(1, "%d\n", getTheNPrimeNumber(8000));	//8000 is about a minute
  79:	c7 04 24 40 1f 00 00 	movl   $0x1f40,(%esp)
  80:	e8 7b ff ff ff       	call   0 <getTheNPrimeNumber>
  85:	89 44 24 08          	mov    %eax,0x8(%esp)
  89:	c7 44 24 04 6b 08 00 	movl   $0x86b,0x4(%esp)
  90:	00 
  91:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  98:	e8 0a 04 00 00       	call   4a7 <printf>
  exit(EXIT_STATUS_SUCCESS);
  9d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  a4:	e8 67 02 00 00       	call   310 <exit>
  a9:	90                   	nop
  aa:	90                   	nop
  ab:	90                   	nop

000000ac <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
  ac:	55                   	push   %ebp
  ad:	89 e5                	mov    %esp,%ebp
  af:	57                   	push   %edi
  b0:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
  b1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  b4:	8b 55 10             	mov    0x10(%ebp),%edx
  b7:	8b 45 0c             	mov    0xc(%ebp),%eax
  ba:	89 cb                	mov    %ecx,%ebx
  bc:	89 df                	mov    %ebx,%edi
  be:	89 d1                	mov    %edx,%ecx
  c0:	fc                   	cld    
  c1:	f3 aa                	rep stos %al,%es:(%edi)
  c3:	89 ca                	mov    %ecx,%edx
  c5:	89 fb                	mov    %edi,%ebx
  c7:	89 5d 08             	mov    %ebx,0x8(%ebp)
  ca:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
  cd:	5b                   	pop    %ebx
  ce:	5f                   	pop    %edi
  cf:	5d                   	pop    %ebp
  d0:	c3                   	ret    

000000d1 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
  d1:	55                   	push   %ebp
  d2:	89 e5                	mov    %esp,%ebp
  d4:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
  d7:	8b 45 08             	mov    0x8(%ebp),%eax
  da:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
  dd:	90                   	nop
  de:	8b 45 0c             	mov    0xc(%ebp),%eax
  e1:	0f b6 10             	movzbl (%eax),%edx
  e4:	8b 45 08             	mov    0x8(%ebp),%eax
  e7:	88 10                	mov    %dl,(%eax)
  e9:	8b 45 08             	mov    0x8(%ebp),%eax
  ec:	0f b6 00             	movzbl (%eax),%eax
  ef:	84 c0                	test   %al,%al
  f1:	0f 95 c0             	setne  %al
  f4:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  f8:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  fc:	84 c0                	test   %al,%al
  fe:	75 de                	jne    de <strcpy+0xd>
    ;
  return os;
 100:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 103:	c9                   	leave  
 104:	c3                   	ret    

00000105 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 105:	55                   	push   %ebp
 106:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 108:	eb 08                	jmp    112 <strcmp+0xd>
    p++, q++;
 10a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 10e:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 112:	8b 45 08             	mov    0x8(%ebp),%eax
 115:	0f b6 00             	movzbl (%eax),%eax
 118:	84 c0                	test   %al,%al
 11a:	74 10                	je     12c <strcmp+0x27>
 11c:	8b 45 08             	mov    0x8(%ebp),%eax
 11f:	0f b6 10             	movzbl (%eax),%edx
 122:	8b 45 0c             	mov    0xc(%ebp),%eax
 125:	0f b6 00             	movzbl (%eax),%eax
 128:	38 c2                	cmp    %al,%dl
 12a:	74 de                	je     10a <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 12c:	8b 45 08             	mov    0x8(%ebp),%eax
 12f:	0f b6 00             	movzbl (%eax),%eax
 132:	0f b6 d0             	movzbl %al,%edx
 135:	8b 45 0c             	mov    0xc(%ebp),%eax
 138:	0f b6 00             	movzbl (%eax),%eax
 13b:	0f b6 c0             	movzbl %al,%eax
 13e:	89 d1                	mov    %edx,%ecx
 140:	29 c1                	sub    %eax,%ecx
 142:	89 c8                	mov    %ecx,%eax
}
 144:	5d                   	pop    %ebp
 145:	c3                   	ret    

00000146 <strlen>:

uint
strlen(char *s)
{
 146:	55                   	push   %ebp
 147:	89 e5                	mov    %esp,%ebp
 149:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 14c:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 153:	eb 04                	jmp    159 <strlen+0x13>
 155:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 159:	8b 45 fc             	mov    -0x4(%ebp),%eax
 15c:	03 45 08             	add    0x8(%ebp),%eax
 15f:	0f b6 00             	movzbl (%eax),%eax
 162:	84 c0                	test   %al,%al
 164:	75 ef                	jne    155 <strlen+0xf>
    ;
  return n;
 166:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 169:	c9                   	leave  
 16a:	c3                   	ret    

0000016b <memset>:

void*
memset(void *dst, int c, uint n)
{
 16b:	55                   	push   %ebp
 16c:	89 e5                	mov    %esp,%ebp
 16e:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 171:	8b 45 10             	mov    0x10(%ebp),%eax
 174:	89 44 24 08          	mov    %eax,0x8(%esp)
 178:	8b 45 0c             	mov    0xc(%ebp),%eax
 17b:	89 44 24 04          	mov    %eax,0x4(%esp)
 17f:	8b 45 08             	mov    0x8(%ebp),%eax
 182:	89 04 24             	mov    %eax,(%esp)
 185:	e8 22 ff ff ff       	call   ac <stosb>
  return dst;
 18a:	8b 45 08             	mov    0x8(%ebp),%eax
}
 18d:	c9                   	leave  
 18e:	c3                   	ret    

0000018f <strchr>:

char*
strchr(const char *s, char c)
{
 18f:	55                   	push   %ebp
 190:	89 e5                	mov    %esp,%ebp
 192:	83 ec 04             	sub    $0x4,%esp
 195:	8b 45 0c             	mov    0xc(%ebp),%eax
 198:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 19b:	eb 14                	jmp    1b1 <strchr+0x22>
    if(*s == c)
 19d:	8b 45 08             	mov    0x8(%ebp),%eax
 1a0:	0f b6 00             	movzbl (%eax),%eax
 1a3:	3a 45 fc             	cmp    -0x4(%ebp),%al
 1a6:	75 05                	jne    1ad <strchr+0x1e>
      return (char*)s;
 1a8:	8b 45 08             	mov    0x8(%ebp),%eax
 1ab:	eb 13                	jmp    1c0 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 1ad:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 1b1:	8b 45 08             	mov    0x8(%ebp),%eax
 1b4:	0f b6 00             	movzbl (%eax),%eax
 1b7:	84 c0                	test   %al,%al
 1b9:	75 e2                	jne    19d <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 1bb:	b8 00 00 00 00       	mov    $0x0,%eax
}
 1c0:	c9                   	leave  
 1c1:	c3                   	ret    

000001c2 <gets>:

char*
gets(char *buf, int max)
{
 1c2:	55                   	push   %ebp
 1c3:	89 e5                	mov    %esp,%ebp
 1c5:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1c8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 1cf:	eb 44                	jmp    215 <gets+0x53>
    cc = read(0, &c, 1);
 1d1:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 1d8:	00 
 1d9:	8d 45 ef             	lea    -0x11(%ebp),%eax
 1dc:	89 44 24 04          	mov    %eax,0x4(%esp)
 1e0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 1e7:	e8 3c 01 00 00       	call   328 <read>
 1ec:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 1ef:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 1f3:	7e 2d                	jle    222 <gets+0x60>
      break;
    buf[i++] = c;
 1f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1f8:	03 45 08             	add    0x8(%ebp),%eax
 1fb:	0f b6 55 ef          	movzbl -0x11(%ebp),%edx
 1ff:	88 10                	mov    %dl,(%eax)
 201:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(c == '\n' || c == '\r')
 205:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 209:	3c 0a                	cmp    $0xa,%al
 20b:	74 16                	je     223 <gets+0x61>
 20d:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 211:	3c 0d                	cmp    $0xd,%al
 213:	74 0e                	je     223 <gets+0x61>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 215:	8b 45 f4             	mov    -0xc(%ebp),%eax
 218:	83 c0 01             	add    $0x1,%eax
 21b:	3b 45 0c             	cmp    0xc(%ebp),%eax
 21e:	7c b1                	jl     1d1 <gets+0xf>
 220:	eb 01                	jmp    223 <gets+0x61>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 222:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 223:	8b 45 f4             	mov    -0xc(%ebp),%eax
 226:	03 45 08             	add    0x8(%ebp),%eax
 229:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 22c:	8b 45 08             	mov    0x8(%ebp),%eax
}
 22f:	c9                   	leave  
 230:	c3                   	ret    

00000231 <stat>:

int
stat(char *n, struct stat *st)
{
 231:	55                   	push   %ebp
 232:	89 e5                	mov    %esp,%ebp
 234:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 237:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 23e:	00 
 23f:	8b 45 08             	mov    0x8(%ebp),%eax
 242:	89 04 24             	mov    %eax,(%esp)
 245:	e8 06 01 00 00       	call   350 <open>
 24a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 24d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 251:	79 07                	jns    25a <stat+0x29>
    return -1;
 253:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 258:	eb 23                	jmp    27d <stat+0x4c>
  r = fstat(fd, st);
 25a:	8b 45 0c             	mov    0xc(%ebp),%eax
 25d:	89 44 24 04          	mov    %eax,0x4(%esp)
 261:	8b 45 f4             	mov    -0xc(%ebp),%eax
 264:	89 04 24             	mov    %eax,(%esp)
 267:	e8 fc 00 00 00       	call   368 <fstat>
 26c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 26f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 272:	89 04 24             	mov    %eax,(%esp)
 275:	e8 be 00 00 00       	call   338 <close>
  return r;
 27a:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 27d:	c9                   	leave  
 27e:	c3                   	ret    

0000027f <atoi>:

int
atoi(const char *s)
{
 27f:	55                   	push   %ebp
 280:	89 e5                	mov    %esp,%ebp
 282:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 285:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 28c:	eb 23                	jmp    2b1 <atoi+0x32>
    n = n*10 + *s++ - '0';
 28e:	8b 55 fc             	mov    -0x4(%ebp),%edx
 291:	89 d0                	mov    %edx,%eax
 293:	c1 e0 02             	shl    $0x2,%eax
 296:	01 d0                	add    %edx,%eax
 298:	01 c0                	add    %eax,%eax
 29a:	89 c2                	mov    %eax,%edx
 29c:	8b 45 08             	mov    0x8(%ebp),%eax
 29f:	0f b6 00             	movzbl (%eax),%eax
 2a2:	0f be c0             	movsbl %al,%eax
 2a5:	01 d0                	add    %edx,%eax
 2a7:	83 e8 30             	sub    $0x30,%eax
 2aa:	89 45 fc             	mov    %eax,-0x4(%ebp)
 2ad:	83 45 08 01          	addl   $0x1,0x8(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 2b1:	8b 45 08             	mov    0x8(%ebp),%eax
 2b4:	0f b6 00             	movzbl (%eax),%eax
 2b7:	3c 2f                	cmp    $0x2f,%al
 2b9:	7e 0a                	jle    2c5 <atoi+0x46>
 2bb:	8b 45 08             	mov    0x8(%ebp),%eax
 2be:	0f b6 00             	movzbl (%eax),%eax
 2c1:	3c 39                	cmp    $0x39,%al
 2c3:	7e c9                	jle    28e <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 2c5:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 2c8:	c9                   	leave  
 2c9:	c3                   	ret    

000002ca <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 2ca:	55                   	push   %ebp
 2cb:	89 e5                	mov    %esp,%ebp
 2cd:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 2d0:	8b 45 08             	mov    0x8(%ebp),%eax
 2d3:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 2d6:	8b 45 0c             	mov    0xc(%ebp),%eax
 2d9:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 2dc:	eb 13                	jmp    2f1 <memmove+0x27>
    *dst++ = *src++;
 2de:	8b 45 f8             	mov    -0x8(%ebp),%eax
 2e1:	0f b6 10             	movzbl (%eax),%edx
 2e4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 2e7:	88 10                	mov    %dl,(%eax)
 2e9:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 2ed:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 2f1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 2f5:	0f 9f c0             	setg   %al
 2f8:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 2fc:	84 c0                	test   %al,%al
 2fe:	75 de                	jne    2de <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 300:	8b 45 08             	mov    0x8(%ebp),%eax
}
 303:	c9                   	leave  
 304:	c3                   	ret    
 305:	90                   	nop
 306:	90                   	nop
 307:	90                   	nop

00000308 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 308:	b8 01 00 00 00       	mov    $0x1,%eax
 30d:	cd 40                	int    $0x40
 30f:	c3                   	ret    

00000310 <exit>:
SYSCALL(exit)
 310:	b8 02 00 00 00       	mov    $0x2,%eax
 315:	cd 40                	int    $0x40
 317:	c3                   	ret    

00000318 <wait>:
SYSCALL(wait)
 318:	b8 03 00 00 00       	mov    $0x3,%eax
 31d:	cd 40                	int    $0x40
 31f:	c3                   	ret    

00000320 <pipe>:
SYSCALL(pipe)
 320:	b8 04 00 00 00       	mov    $0x4,%eax
 325:	cd 40                	int    $0x40
 327:	c3                   	ret    

00000328 <read>:
SYSCALL(read)
 328:	b8 05 00 00 00       	mov    $0x5,%eax
 32d:	cd 40                	int    $0x40
 32f:	c3                   	ret    

00000330 <write>:
SYSCALL(write)
 330:	b8 10 00 00 00       	mov    $0x10,%eax
 335:	cd 40                	int    $0x40
 337:	c3                   	ret    

00000338 <close>:
SYSCALL(close)
 338:	b8 15 00 00 00       	mov    $0x15,%eax
 33d:	cd 40                	int    $0x40
 33f:	c3                   	ret    

00000340 <kill>:
SYSCALL(kill)
 340:	b8 06 00 00 00       	mov    $0x6,%eax
 345:	cd 40                	int    $0x40
 347:	c3                   	ret    

00000348 <exec>:
SYSCALL(exec)
 348:	b8 07 00 00 00       	mov    $0x7,%eax
 34d:	cd 40                	int    $0x40
 34f:	c3                   	ret    

00000350 <open>:
SYSCALL(open)
 350:	b8 0f 00 00 00       	mov    $0xf,%eax
 355:	cd 40                	int    $0x40
 357:	c3                   	ret    

00000358 <mknod>:
SYSCALL(mknod)
 358:	b8 11 00 00 00       	mov    $0x11,%eax
 35d:	cd 40                	int    $0x40
 35f:	c3                   	ret    

00000360 <unlink>:
SYSCALL(unlink)
 360:	b8 12 00 00 00       	mov    $0x12,%eax
 365:	cd 40                	int    $0x40
 367:	c3                   	ret    

00000368 <fstat>:
SYSCALL(fstat)
 368:	b8 08 00 00 00       	mov    $0x8,%eax
 36d:	cd 40                	int    $0x40
 36f:	c3                   	ret    

00000370 <link>:
SYSCALL(link)
 370:	b8 13 00 00 00       	mov    $0x13,%eax
 375:	cd 40                	int    $0x40
 377:	c3                   	ret    

00000378 <mkdir>:
SYSCALL(mkdir)
 378:	b8 14 00 00 00       	mov    $0x14,%eax
 37d:	cd 40                	int    $0x40
 37f:	c3                   	ret    

00000380 <chdir>:
SYSCALL(chdir)
 380:	b8 09 00 00 00       	mov    $0x9,%eax
 385:	cd 40                	int    $0x40
 387:	c3                   	ret    

00000388 <dup>:
SYSCALL(dup)
 388:	b8 0a 00 00 00       	mov    $0xa,%eax
 38d:	cd 40                	int    $0x40
 38f:	c3                   	ret    

00000390 <getpid>:
SYSCALL(getpid)
 390:	b8 0b 00 00 00       	mov    $0xb,%eax
 395:	cd 40                	int    $0x40
 397:	c3                   	ret    

00000398 <sbrk>:
SYSCALL(sbrk)
 398:	b8 0c 00 00 00       	mov    $0xc,%eax
 39d:	cd 40                	int    $0x40
 39f:	c3                   	ret    

000003a0 <sleep>:
SYSCALL(sleep)
 3a0:	b8 0d 00 00 00       	mov    $0xd,%eax
 3a5:	cd 40                	int    $0x40
 3a7:	c3                   	ret    

000003a8 <uptime>:
SYSCALL(uptime)
 3a8:	b8 0e 00 00 00       	mov    $0xe,%eax
 3ad:	cd 40                	int    $0x40
 3af:	c3                   	ret    

000003b0 <waitpid>:
SYSCALL(waitpid)
 3b0:	b8 16 00 00 00       	mov    $0x16,%eax
 3b5:	cd 40                	int    $0x40
 3b7:	c3                   	ret    

000003b8 <wait_stat>:
SYSCALL(wait_stat)
 3b8:	b8 17 00 00 00       	mov    $0x17,%eax
 3bd:	cd 40                	int    $0x40
 3bf:	c3                   	ret    

000003c0 <list_pgroup>:
SYSCALL(list_pgroup)
 3c0:	b8 18 00 00 00       	mov    $0x18,%eax
 3c5:	cd 40                	int    $0x40
 3c7:	c3                   	ret    

000003c8 <foreground>:
SYSCALL(foreground)
 3c8:	b8 19 00 00 00       	mov    $0x19,%eax
 3cd:	cd 40                	int    $0x40
 3cf:	c3                   	ret    

000003d0 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 3d0:	55                   	push   %ebp
 3d1:	89 e5                	mov    %esp,%ebp
 3d3:	83 ec 28             	sub    $0x28,%esp
 3d6:	8b 45 0c             	mov    0xc(%ebp),%eax
 3d9:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 3dc:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 3e3:	00 
 3e4:	8d 45 f4             	lea    -0xc(%ebp),%eax
 3e7:	89 44 24 04          	mov    %eax,0x4(%esp)
 3eb:	8b 45 08             	mov    0x8(%ebp),%eax
 3ee:	89 04 24             	mov    %eax,(%esp)
 3f1:	e8 3a ff ff ff       	call   330 <write>
}
 3f6:	c9                   	leave  
 3f7:	c3                   	ret    

000003f8 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 3f8:	55                   	push   %ebp
 3f9:	89 e5                	mov    %esp,%ebp
 3fb:	83 ec 48             	sub    $0x48,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 3fe:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 405:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 409:	74 17                	je     422 <printint+0x2a>
 40b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 40f:	79 11                	jns    422 <printint+0x2a>
    neg = 1;
 411:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 418:	8b 45 0c             	mov    0xc(%ebp),%eax
 41b:	f7 d8                	neg    %eax
 41d:	89 45 ec             	mov    %eax,-0x14(%ebp)
 420:	eb 06                	jmp    428 <printint+0x30>
  } else {
    x = xx;
 422:	8b 45 0c             	mov    0xc(%ebp),%eax
 425:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 428:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 42f:	8b 4d 10             	mov    0x10(%ebp),%ecx
 432:	8b 45 ec             	mov    -0x14(%ebp),%eax
 435:	ba 00 00 00 00       	mov    $0x0,%edx
 43a:	f7 f1                	div    %ecx
 43c:	89 d0                	mov    %edx,%eax
 43e:	0f b6 90 d8 0a 00 00 	movzbl 0xad8(%eax),%edx
 445:	8d 45 dc             	lea    -0x24(%ebp),%eax
 448:	03 45 f4             	add    -0xc(%ebp),%eax
 44b:	88 10                	mov    %dl,(%eax)
 44d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  }while((x /= base) != 0);
 451:	8b 55 10             	mov    0x10(%ebp),%edx
 454:	89 55 d4             	mov    %edx,-0x2c(%ebp)
 457:	8b 45 ec             	mov    -0x14(%ebp),%eax
 45a:	ba 00 00 00 00       	mov    $0x0,%edx
 45f:	f7 75 d4             	divl   -0x2c(%ebp)
 462:	89 45 ec             	mov    %eax,-0x14(%ebp)
 465:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 469:	75 c4                	jne    42f <printint+0x37>
  if(neg)
 46b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 46f:	74 2a                	je     49b <printint+0xa3>
    buf[i++] = '-';
 471:	8d 45 dc             	lea    -0x24(%ebp),%eax
 474:	03 45 f4             	add    -0xc(%ebp),%eax
 477:	c6 00 2d             	movb   $0x2d,(%eax)
 47a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

  while(--i >= 0)
 47e:	eb 1b                	jmp    49b <printint+0xa3>
    putc(fd, buf[i]);
 480:	8d 45 dc             	lea    -0x24(%ebp),%eax
 483:	03 45 f4             	add    -0xc(%ebp),%eax
 486:	0f b6 00             	movzbl (%eax),%eax
 489:	0f be c0             	movsbl %al,%eax
 48c:	89 44 24 04          	mov    %eax,0x4(%esp)
 490:	8b 45 08             	mov    0x8(%ebp),%eax
 493:	89 04 24             	mov    %eax,(%esp)
 496:	e8 35 ff ff ff       	call   3d0 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 49b:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 49f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 4a3:	79 db                	jns    480 <printint+0x88>
    putc(fd, buf[i]);
}
 4a5:	c9                   	leave  
 4a6:	c3                   	ret    

000004a7 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 4a7:	55                   	push   %ebp
 4a8:	89 e5                	mov    %esp,%ebp
 4aa:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 4ad:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 4b4:	8d 45 0c             	lea    0xc(%ebp),%eax
 4b7:	83 c0 04             	add    $0x4,%eax
 4ba:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 4bd:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 4c4:	e9 7d 01 00 00       	jmp    646 <printf+0x19f>
    c = fmt[i] & 0xff;
 4c9:	8b 55 0c             	mov    0xc(%ebp),%edx
 4cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
 4cf:	01 d0                	add    %edx,%eax
 4d1:	0f b6 00             	movzbl (%eax),%eax
 4d4:	0f be c0             	movsbl %al,%eax
 4d7:	25 ff 00 00 00       	and    $0xff,%eax
 4dc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 4df:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 4e3:	75 2c                	jne    511 <printf+0x6a>
      if(c == '%'){
 4e5:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 4e9:	75 0c                	jne    4f7 <printf+0x50>
        state = '%';
 4eb:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 4f2:	e9 4b 01 00 00       	jmp    642 <printf+0x19b>
      } else {
        putc(fd, c);
 4f7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 4fa:	0f be c0             	movsbl %al,%eax
 4fd:	89 44 24 04          	mov    %eax,0x4(%esp)
 501:	8b 45 08             	mov    0x8(%ebp),%eax
 504:	89 04 24             	mov    %eax,(%esp)
 507:	e8 c4 fe ff ff       	call   3d0 <putc>
 50c:	e9 31 01 00 00       	jmp    642 <printf+0x19b>
      }
    } else if(state == '%'){
 511:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 515:	0f 85 27 01 00 00    	jne    642 <printf+0x19b>
      if(c == 'd'){
 51b:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 51f:	75 2d                	jne    54e <printf+0xa7>
        printint(fd, *ap, 10, 1);
 521:	8b 45 e8             	mov    -0x18(%ebp),%eax
 524:	8b 00                	mov    (%eax),%eax
 526:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 52d:	00 
 52e:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 535:	00 
 536:	89 44 24 04          	mov    %eax,0x4(%esp)
 53a:	8b 45 08             	mov    0x8(%ebp),%eax
 53d:	89 04 24             	mov    %eax,(%esp)
 540:	e8 b3 fe ff ff       	call   3f8 <printint>
        ap++;
 545:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 549:	e9 ed 00 00 00       	jmp    63b <printf+0x194>
      } else if(c == 'x' || c == 'p'){
 54e:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 552:	74 06                	je     55a <printf+0xb3>
 554:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 558:	75 2d                	jne    587 <printf+0xe0>
        printint(fd, *ap, 16, 0);
 55a:	8b 45 e8             	mov    -0x18(%ebp),%eax
 55d:	8b 00                	mov    (%eax),%eax
 55f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 566:	00 
 567:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 56e:	00 
 56f:	89 44 24 04          	mov    %eax,0x4(%esp)
 573:	8b 45 08             	mov    0x8(%ebp),%eax
 576:	89 04 24             	mov    %eax,(%esp)
 579:	e8 7a fe ff ff       	call   3f8 <printint>
        ap++;
 57e:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 582:	e9 b4 00 00 00       	jmp    63b <printf+0x194>
      } else if(c == 's'){
 587:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 58b:	75 46                	jne    5d3 <printf+0x12c>
        s = (char*)*ap;
 58d:	8b 45 e8             	mov    -0x18(%ebp),%eax
 590:	8b 00                	mov    (%eax),%eax
 592:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 595:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 599:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 59d:	75 27                	jne    5c6 <printf+0x11f>
          s = "(null)";
 59f:	c7 45 f4 6f 08 00 00 	movl   $0x86f,-0xc(%ebp)
        while(*s != 0){
 5a6:	eb 1e                	jmp    5c6 <printf+0x11f>
          putc(fd, *s);
 5a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5ab:	0f b6 00             	movzbl (%eax),%eax
 5ae:	0f be c0             	movsbl %al,%eax
 5b1:	89 44 24 04          	mov    %eax,0x4(%esp)
 5b5:	8b 45 08             	mov    0x8(%ebp),%eax
 5b8:	89 04 24             	mov    %eax,(%esp)
 5bb:	e8 10 fe ff ff       	call   3d0 <putc>
          s++;
 5c0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 5c4:	eb 01                	jmp    5c7 <printf+0x120>
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 5c6:	90                   	nop
 5c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5ca:	0f b6 00             	movzbl (%eax),%eax
 5cd:	84 c0                	test   %al,%al
 5cf:	75 d7                	jne    5a8 <printf+0x101>
 5d1:	eb 68                	jmp    63b <printf+0x194>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 5d3:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 5d7:	75 1d                	jne    5f6 <printf+0x14f>
        putc(fd, *ap);
 5d9:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5dc:	8b 00                	mov    (%eax),%eax
 5de:	0f be c0             	movsbl %al,%eax
 5e1:	89 44 24 04          	mov    %eax,0x4(%esp)
 5e5:	8b 45 08             	mov    0x8(%ebp),%eax
 5e8:	89 04 24             	mov    %eax,(%esp)
 5eb:	e8 e0 fd ff ff       	call   3d0 <putc>
        ap++;
 5f0:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 5f4:	eb 45                	jmp    63b <printf+0x194>
      } else if(c == '%'){
 5f6:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 5fa:	75 17                	jne    613 <printf+0x16c>
        putc(fd, c);
 5fc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 5ff:	0f be c0             	movsbl %al,%eax
 602:	89 44 24 04          	mov    %eax,0x4(%esp)
 606:	8b 45 08             	mov    0x8(%ebp),%eax
 609:	89 04 24             	mov    %eax,(%esp)
 60c:	e8 bf fd ff ff       	call   3d0 <putc>
 611:	eb 28                	jmp    63b <printf+0x194>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 613:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 61a:	00 
 61b:	8b 45 08             	mov    0x8(%ebp),%eax
 61e:	89 04 24             	mov    %eax,(%esp)
 621:	e8 aa fd ff ff       	call   3d0 <putc>
        putc(fd, c);
 626:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 629:	0f be c0             	movsbl %al,%eax
 62c:	89 44 24 04          	mov    %eax,0x4(%esp)
 630:	8b 45 08             	mov    0x8(%ebp),%eax
 633:	89 04 24             	mov    %eax,(%esp)
 636:	e8 95 fd ff ff       	call   3d0 <putc>
      }
      state = 0;
 63b:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 642:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 646:	8b 55 0c             	mov    0xc(%ebp),%edx
 649:	8b 45 f0             	mov    -0x10(%ebp),%eax
 64c:	01 d0                	add    %edx,%eax
 64e:	0f b6 00             	movzbl (%eax),%eax
 651:	84 c0                	test   %al,%al
 653:	0f 85 70 fe ff ff    	jne    4c9 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 659:	c9                   	leave  
 65a:	c3                   	ret    
 65b:	90                   	nop

0000065c <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 65c:	55                   	push   %ebp
 65d:	89 e5                	mov    %esp,%ebp
 65f:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 662:	8b 45 08             	mov    0x8(%ebp),%eax
 665:	83 e8 08             	sub    $0x8,%eax
 668:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 66b:	a1 f4 0a 00 00       	mov    0xaf4,%eax
 670:	89 45 fc             	mov    %eax,-0x4(%ebp)
 673:	eb 24                	jmp    699 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 675:	8b 45 fc             	mov    -0x4(%ebp),%eax
 678:	8b 00                	mov    (%eax),%eax
 67a:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 67d:	77 12                	ja     691 <free+0x35>
 67f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 682:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 685:	77 24                	ja     6ab <free+0x4f>
 687:	8b 45 fc             	mov    -0x4(%ebp),%eax
 68a:	8b 00                	mov    (%eax),%eax
 68c:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 68f:	77 1a                	ja     6ab <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 691:	8b 45 fc             	mov    -0x4(%ebp),%eax
 694:	8b 00                	mov    (%eax),%eax
 696:	89 45 fc             	mov    %eax,-0x4(%ebp)
 699:	8b 45 f8             	mov    -0x8(%ebp),%eax
 69c:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 69f:	76 d4                	jbe    675 <free+0x19>
 6a1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6a4:	8b 00                	mov    (%eax),%eax
 6a6:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 6a9:	76 ca                	jbe    675 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 6ab:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6ae:	8b 40 04             	mov    0x4(%eax),%eax
 6b1:	c1 e0 03             	shl    $0x3,%eax
 6b4:	89 c2                	mov    %eax,%edx
 6b6:	03 55 f8             	add    -0x8(%ebp),%edx
 6b9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6bc:	8b 00                	mov    (%eax),%eax
 6be:	39 c2                	cmp    %eax,%edx
 6c0:	75 24                	jne    6e6 <free+0x8a>
    bp->s.size += p->s.ptr->s.size;
 6c2:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6c5:	8b 50 04             	mov    0x4(%eax),%edx
 6c8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6cb:	8b 00                	mov    (%eax),%eax
 6cd:	8b 40 04             	mov    0x4(%eax),%eax
 6d0:	01 c2                	add    %eax,%edx
 6d2:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6d5:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 6d8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6db:	8b 00                	mov    (%eax),%eax
 6dd:	8b 10                	mov    (%eax),%edx
 6df:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6e2:	89 10                	mov    %edx,(%eax)
 6e4:	eb 0a                	jmp    6f0 <free+0x94>
  } else
    bp->s.ptr = p->s.ptr;
 6e6:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6e9:	8b 10                	mov    (%eax),%edx
 6eb:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6ee:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 6f0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6f3:	8b 40 04             	mov    0x4(%eax),%eax
 6f6:	c1 e0 03             	shl    $0x3,%eax
 6f9:	03 45 fc             	add    -0x4(%ebp),%eax
 6fc:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 6ff:	75 20                	jne    721 <free+0xc5>
    p->s.size += bp->s.size;
 701:	8b 45 fc             	mov    -0x4(%ebp),%eax
 704:	8b 50 04             	mov    0x4(%eax),%edx
 707:	8b 45 f8             	mov    -0x8(%ebp),%eax
 70a:	8b 40 04             	mov    0x4(%eax),%eax
 70d:	01 c2                	add    %eax,%edx
 70f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 712:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 715:	8b 45 f8             	mov    -0x8(%ebp),%eax
 718:	8b 10                	mov    (%eax),%edx
 71a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 71d:	89 10                	mov    %edx,(%eax)
 71f:	eb 08                	jmp    729 <free+0xcd>
  } else
    p->s.ptr = bp;
 721:	8b 45 fc             	mov    -0x4(%ebp),%eax
 724:	8b 55 f8             	mov    -0x8(%ebp),%edx
 727:	89 10                	mov    %edx,(%eax)
  freep = p;
 729:	8b 45 fc             	mov    -0x4(%ebp),%eax
 72c:	a3 f4 0a 00 00       	mov    %eax,0xaf4
}
 731:	c9                   	leave  
 732:	c3                   	ret    

00000733 <morecore>:

static Header*
morecore(uint nu)
{
 733:	55                   	push   %ebp
 734:	89 e5                	mov    %esp,%ebp
 736:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 739:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 740:	77 07                	ja     749 <morecore+0x16>
    nu = 4096;
 742:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 749:	8b 45 08             	mov    0x8(%ebp),%eax
 74c:	c1 e0 03             	shl    $0x3,%eax
 74f:	89 04 24             	mov    %eax,(%esp)
 752:	e8 41 fc ff ff       	call   398 <sbrk>
 757:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 75a:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 75e:	75 07                	jne    767 <morecore+0x34>
    return 0;
 760:	b8 00 00 00 00       	mov    $0x0,%eax
 765:	eb 22                	jmp    789 <morecore+0x56>
  hp = (Header*)p;
 767:	8b 45 f4             	mov    -0xc(%ebp),%eax
 76a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 76d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 770:	8b 55 08             	mov    0x8(%ebp),%edx
 773:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 776:	8b 45 f0             	mov    -0x10(%ebp),%eax
 779:	83 c0 08             	add    $0x8,%eax
 77c:	89 04 24             	mov    %eax,(%esp)
 77f:	e8 d8 fe ff ff       	call   65c <free>
  return freep;
 784:	a1 f4 0a 00 00       	mov    0xaf4,%eax
}
 789:	c9                   	leave  
 78a:	c3                   	ret    

0000078b <malloc>:

void*
malloc(uint nbytes)
{
 78b:	55                   	push   %ebp
 78c:	89 e5                	mov    %esp,%ebp
 78e:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 791:	8b 45 08             	mov    0x8(%ebp),%eax
 794:	83 c0 07             	add    $0x7,%eax
 797:	c1 e8 03             	shr    $0x3,%eax
 79a:	83 c0 01             	add    $0x1,%eax
 79d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 7a0:	a1 f4 0a 00 00       	mov    0xaf4,%eax
 7a5:	89 45 f0             	mov    %eax,-0x10(%ebp)
 7a8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 7ac:	75 23                	jne    7d1 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 7ae:	c7 45 f0 ec 0a 00 00 	movl   $0xaec,-0x10(%ebp)
 7b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7b8:	a3 f4 0a 00 00       	mov    %eax,0xaf4
 7bd:	a1 f4 0a 00 00       	mov    0xaf4,%eax
 7c2:	a3 ec 0a 00 00       	mov    %eax,0xaec
    base.s.size = 0;
 7c7:	c7 05 f0 0a 00 00 00 	movl   $0x0,0xaf0
 7ce:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7d4:	8b 00                	mov    (%eax),%eax
 7d6:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 7d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7dc:	8b 40 04             	mov    0x4(%eax),%eax
 7df:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 7e2:	72 4d                	jb     831 <malloc+0xa6>
      if(p->s.size == nunits)
 7e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7e7:	8b 40 04             	mov    0x4(%eax),%eax
 7ea:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 7ed:	75 0c                	jne    7fb <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 7ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7f2:	8b 10                	mov    (%eax),%edx
 7f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7f7:	89 10                	mov    %edx,(%eax)
 7f9:	eb 26                	jmp    821 <malloc+0x96>
      else {
        p->s.size -= nunits;
 7fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7fe:	8b 40 04             	mov    0x4(%eax),%eax
 801:	89 c2                	mov    %eax,%edx
 803:	2b 55 ec             	sub    -0x14(%ebp),%edx
 806:	8b 45 f4             	mov    -0xc(%ebp),%eax
 809:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 80c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 80f:	8b 40 04             	mov    0x4(%eax),%eax
 812:	c1 e0 03             	shl    $0x3,%eax
 815:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 818:	8b 45 f4             	mov    -0xc(%ebp),%eax
 81b:	8b 55 ec             	mov    -0x14(%ebp),%edx
 81e:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 821:	8b 45 f0             	mov    -0x10(%ebp),%eax
 824:	a3 f4 0a 00 00       	mov    %eax,0xaf4
      return (void*)(p + 1);
 829:	8b 45 f4             	mov    -0xc(%ebp),%eax
 82c:	83 c0 08             	add    $0x8,%eax
 82f:	eb 38                	jmp    869 <malloc+0xde>
    }
    if(p == freep)
 831:	a1 f4 0a 00 00       	mov    0xaf4,%eax
 836:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 839:	75 1b                	jne    856 <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 83b:	8b 45 ec             	mov    -0x14(%ebp),%eax
 83e:	89 04 24             	mov    %eax,(%esp)
 841:	e8 ed fe ff ff       	call   733 <morecore>
 846:	89 45 f4             	mov    %eax,-0xc(%ebp)
 849:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 84d:	75 07                	jne    856 <malloc+0xcb>
        return 0;
 84f:	b8 00 00 00 00       	mov    $0x0,%eax
 854:	eb 13                	jmp    869 <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 856:	8b 45 f4             	mov    -0xc(%ebp),%eax
 859:	89 45 f0             	mov    %eax,-0x10(%ebp)
 85c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 85f:	8b 00                	mov    (%eax),%eax
 861:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 864:	e9 70 ff ff ff       	jmp    7d9 <malloc+0x4e>
}
 869:	c9                   	leave  
 86a:	c3                   	ret    
