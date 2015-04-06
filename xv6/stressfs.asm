
_stressfs:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "fs.h"
#include "fcntl.h"

int
main(int argc, char *argv[])
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 e4 f0             	and    $0xfffffff0,%esp
   6:	81 ec 30 02 00 00    	sub    $0x230,%esp
  int fd, i;
  char path[] = "stressfs0";
   c:	c7 84 24 1e 02 00 00 	movl   $0x65727473,0x21e(%esp)
  13:	73 74 72 65 
  17:	c7 84 24 22 02 00 00 	movl   $0x73667373,0x222(%esp)
  1e:	73 73 66 73 
  22:	66 c7 84 24 26 02 00 	movw   $0x30,0x226(%esp)
  29:	00 30 00 
  char data[512];

  printf(1, "stressfs starting\n");
  2c:	c7 44 24 04 8b 09 00 	movl   $0x98b,0x4(%esp)
  33:	00 
  34:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  3b:	e8 87 05 00 00       	call   5c7 <printf>
  memset(data, 'a', sizeof(data));
  40:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  47:	00 
  48:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
  4f:	00 
  50:	8d 44 24 1e          	lea    0x1e(%esp),%eax
  54:	89 04 24             	mov    %eax,(%esp)
  57:	e8 27 02 00 00       	call   283 <memset>

  for(i = 0; i < 4; i++)
  5c:	c7 84 24 2c 02 00 00 	movl   $0x0,0x22c(%esp)
  63:	00 00 00 00 
  67:	eb 11                	jmp    7a <main+0x7a>
    if(fork() > 0)
  69:	e8 b2 03 00 00       	call   420 <fork>
  6e:	85 c0                	test   %eax,%eax
  70:	7f 14                	jg     86 <main+0x86>
  char data[512];

  printf(1, "stressfs starting\n");
  memset(data, 'a', sizeof(data));

  for(i = 0; i < 4; i++)
  72:	83 84 24 2c 02 00 00 	addl   $0x1,0x22c(%esp)
  79:	01 
  7a:	83 bc 24 2c 02 00 00 	cmpl   $0x3,0x22c(%esp)
  81:	03 
  82:	7e e5                	jle    69 <main+0x69>
  84:	eb 01                	jmp    87 <main+0x87>
    if(fork() > 0)
      break;
  86:	90                   	nop

  printf(1, "write %d\n", i);
  87:	8b 84 24 2c 02 00 00 	mov    0x22c(%esp),%eax
  8e:	89 44 24 08          	mov    %eax,0x8(%esp)
  92:	c7 44 24 04 9e 09 00 	movl   $0x99e,0x4(%esp)
  99:	00 
  9a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  a1:	e8 21 05 00 00       	call   5c7 <printf>

  path[8] += i;
  a6:	0f b6 84 24 26 02 00 	movzbl 0x226(%esp),%eax
  ad:	00 
  ae:	89 c2                	mov    %eax,%edx
  b0:	8b 84 24 2c 02 00 00 	mov    0x22c(%esp),%eax
  b7:	01 d0                	add    %edx,%eax
  b9:	88 84 24 26 02 00 00 	mov    %al,0x226(%esp)
  fd = open(path, O_CREATE | O_RDWR);
  c0:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
  c7:	00 
  c8:	8d 84 24 1e 02 00 00 	lea    0x21e(%esp),%eax
  cf:	89 04 24             	mov    %eax,(%esp)
  d2:	e8 91 03 00 00       	call   468 <open>
  d7:	89 84 24 28 02 00 00 	mov    %eax,0x228(%esp)
  for(i = 0; i < 20; i++)
  de:	c7 84 24 2c 02 00 00 	movl   $0x0,0x22c(%esp)
  e5:	00 00 00 00 
  e9:	eb 27                	jmp    112 <main+0x112>
//    printf(fd, "%d\n", i);
    write(fd, data, sizeof(data));
  eb:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  f2:	00 
  f3:	8d 44 24 1e          	lea    0x1e(%esp),%eax
  f7:	89 44 24 04          	mov    %eax,0x4(%esp)
  fb:	8b 84 24 28 02 00 00 	mov    0x228(%esp),%eax
 102:	89 04 24             	mov    %eax,(%esp)
 105:	e8 3e 03 00 00       	call   448 <write>

  printf(1, "write %d\n", i);

  path[8] += i;
  fd = open(path, O_CREATE | O_RDWR);
  for(i = 0; i < 20; i++)
 10a:	83 84 24 2c 02 00 00 	addl   $0x1,0x22c(%esp)
 111:	01 
 112:	83 bc 24 2c 02 00 00 	cmpl   $0x13,0x22c(%esp)
 119:	13 
 11a:	7e cf                	jle    eb <main+0xeb>
//    printf(fd, "%d\n", i);
    write(fd, data, sizeof(data));
  close(fd);
 11c:	8b 84 24 28 02 00 00 	mov    0x228(%esp),%eax
 123:	89 04 24             	mov    %eax,(%esp)
 126:	e8 25 03 00 00       	call   450 <close>

  printf(1, "read\n");
 12b:	c7 44 24 04 a8 09 00 	movl   $0x9a8,0x4(%esp)
 132:	00 
 133:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 13a:	e8 88 04 00 00       	call   5c7 <printf>

  fd = open(path, O_RDONLY);
 13f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 146:	00 
 147:	8d 84 24 1e 02 00 00 	lea    0x21e(%esp),%eax
 14e:	89 04 24             	mov    %eax,(%esp)
 151:	e8 12 03 00 00       	call   468 <open>
 156:	89 84 24 28 02 00 00 	mov    %eax,0x228(%esp)
  for (i = 0; i < 20; i++)
 15d:	c7 84 24 2c 02 00 00 	movl   $0x0,0x22c(%esp)
 164:	00 00 00 00 
 168:	eb 27                	jmp    191 <main+0x191>
    read(fd, data, sizeof(data));
 16a:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
 171:	00 
 172:	8d 44 24 1e          	lea    0x1e(%esp),%eax
 176:	89 44 24 04          	mov    %eax,0x4(%esp)
 17a:	8b 84 24 28 02 00 00 	mov    0x228(%esp),%eax
 181:	89 04 24             	mov    %eax,(%esp)
 184:	e8 b7 02 00 00       	call   440 <read>
  close(fd);

  printf(1, "read\n");

  fd = open(path, O_RDONLY);
  for (i = 0; i < 20; i++)
 189:	83 84 24 2c 02 00 00 	addl   $0x1,0x22c(%esp)
 190:	01 
 191:	83 bc 24 2c 02 00 00 	cmpl   $0x13,0x22c(%esp)
 198:	13 
 199:	7e cf                	jle    16a <main+0x16a>
    read(fd, data, sizeof(data));
  close(fd);
 19b:	8b 84 24 28 02 00 00 	mov    0x228(%esp),%eax
 1a2:	89 04 24             	mov    %eax,(%esp)
 1a5:	e8 a6 02 00 00       	call   450 <close>

  wait(0);
 1aa:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 1b1:	e8 7a 02 00 00       	call   430 <wait>
  
  exit(EXIT_STATUS_DEFAULT);
 1b6:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
 1bd:	e8 66 02 00 00       	call   428 <exit>
 1c2:	90                   	nop
 1c3:	90                   	nop

000001c4 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 1c4:	55                   	push   %ebp
 1c5:	89 e5                	mov    %esp,%ebp
 1c7:	57                   	push   %edi
 1c8:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 1c9:	8b 4d 08             	mov    0x8(%ebp),%ecx
 1cc:	8b 55 10             	mov    0x10(%ebp),%edx
 1cf:	8b 45 0c             	mov    0xc(%ebp),%eax
 1d2:	89 cb                	mov    %ecx,%ebx
 1d4:	89 df                	mov    %ebx,%edi
 1d6:	89 d1                	mov    %edx,%ecx
 1d8:	fc                   	cld    
 1d9:	f3 aa                	rep stos %al,%es:(%edi)
 1db:	89 ca                	mov    %ecx,%edx
 1dd:	89 fb                	mov    %edi,%ebx
 1df:	89 5d 08             	mov    %ebx,0x8(%ebp)
 1e2:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 1e5:	5b                   	pop    %ebx
 1e6:	5f                   	pop    %edi
 1e7:	5d                   	pop    %ebp
 1e8:	c3                   	ret    

000001e9 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 1e9:	55                   	push   %ebp
 1ea:	89 e5                	mov    %esp,%ebp
 1ec:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 1ef:	8b 45 08             	mov    0x8(%ebp),%eax
 1f2:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 1f5:	90                   	nop
 1f6:	8b 45 0c             	mov    0xc(%ebp),%eax
 1f9:	0f b6 10             	movzbl (%eax),%edx
 1fc:	8b 45 08             	mov    0x8(%ebp),%eax
 1ff:	88 10                	mov    %dl,(%eax)
 201:	8b 45 08             	mov    0x8(%ebp),%eax
 204:	0f b6 00             	movzbl (%eax),%eax
 207:	84 c0                	test   %al,%al
 209:	0f 95 c0             	setne  %al
 20c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 210:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 214:	84 c0                	test   %al,%al
 216:	75 de                	jne    1f6 <strcpy+0xd>
    ;
  return os;
 218:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 21b:	c9                   	leave  
 21c:	c3                   	ret    

0000021d <strcmp>:

int
strcmp(const char *p, const char *q)
{
 21d:	55                   	push   %ebp
 21e:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 220:	eb 08                	jmp    22a <strcmp+0xd>
    p++, q++;
 222:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 226:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 22a:	8b 45 08             	mov    0x8(%ebp),%eax
 22d:	0f b6 00             	movzbl (%eax),%eax
 230:	84 c0                	test   %al,%al
 232:	74 10                	je     244 <strcmp+0x27>
 234:	8b 45 08             	mov    0x8(%ebp),%eax
 237:	0f b6 10             	movzbl (%eax),%edx
 23a:	8b 45 0c             	mov    0xc(%ebp),%eax
 23d:	0f b6 00             	movzbl (%eax),%eax
 240:	38 c2                	cmp    %al,%dl
 242:	74 de                	je     222 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 244:	8b 45 08             	mov    0x8(%ebp),%eax
 247:	0f b6 00             	movzbl (%eax),%eax
 24a:	0f b6 d0             	movzbl %al,%edx
 24d:	8b 45 0c             	mov    0xc(%ebp),%eax
 250:	0f b6 00             	movzbl (%eax),%eax
 253:	0f b6 c0             	movzbl %al,%eax
 256:	89 d1                	mov    %edx,%ecx
 258:	29 c1                	sub    %eax,%ecx
 25a:	89 c8                	mov    %ecx,%eax
}
 25c:	5d                   	pop    %ebp
 25d:	c3                   	ret    

0000025e <strlen>:

uint
strlen(char *s)
{
 25e:	55                   	push   %ebp
 25f:	89 e5                	mov    %esp,%ebp
 261:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 264:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 26b:	eb 04                	jmp    271 <strlen+0x13>
 26d:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 271:	8b 45 fc             	mov    -0x4(%ebp),%eax
 274:	03 45 08             	add    0x8(%ebp),%eax
 277:	0f b6 00             	movzbl (%eax),%eax
 27a:	84 c0                	test   %al,%al
 27c:	75 ef                	jne    26d <strlen+0xf>
    ;
  return n;
 27e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 281:	c9                   	leave  
 282:	c3                   	ret    

00000283 <memset>:

void*
memset(void *dst, int c, uint n)
{
 283:	55                   	push   %ebp
 284:	89 e5                	mov    %esp,%ebp
 286:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 289:	8b 45 10             	mov    0x10(%ebp),%eax
 28c:	89 44 24 08          	mov    %eax,0x8(%esp)
 290:	8b 45 0c             	mov    0xc(%ebp),%eax
 293:	89 44 24 04          	mov    %eax,0x4(%esp)
 297:	8b 45 08             	mov    0x8(%ebp),%eax
 29a:	89 04 24             	mov    %eax,(%esp)
 29d:	e8 22 ff ff ff       	call   1c4 <stosb>
  return dst;
 2a2:	8b 45 08             	mov    0x8(%ebp),%eax
}
 2a5:	c9                   	leave  
 2a6:	c3                   	ret    

000002a7 <strchr>:

char*
strchr(const char *s, char c)
{
 2a7:	55                   	push   %ebp
 2a8:	89 e5                	mov    %esp,%ebp
 2aa:	83 ec 04             	sub    $0x4,%esp
 2ad:	8b 45 0c             	mov    0xc(%ebp),%eax
 2b0:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 2b3:	eb 14                	jmp    2c9 <strchr+0x22>
    if(*s == c)
 2b5:	8b 45 08             	mov    0x8(%ebp),%eax
 2b8:	0f b6 00             	movzbl (%eax),%eax
 2bb:	3a 45 fc             	cmp    -0x4(%ebp),%al
 2be:	75 05                	jne    2c5 <strchr+0x1e>
      return (char*)s;
 2c0:	8b 45 08             	mov    0x8(%ebp),%eax
 2c3:	eb 13                	jmp    2d8 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 2c5:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 2c9:	8b 45 08             	mov    0x8(%ebp),%eax
 2cc:	0f b6 00             	movzbl (%eax),%eax
 2cf:	84 c0                	test   %al,%al
 2d1:	75 e2                	jne    2b5 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 2d3:	b8 00 00 00 00       	mov    $0x0,%eax
}
 2d8:	c9                   	leave  
 2d9:	c3                   	ret    

000002da <gets>:

char*
gets(char *buf, int max)
{
 2da:	55                   	push   %ebp
 2db:	89 e5                	mov    %esp,%ebp
 2dd:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 2e0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 2e7:	eb 44                	jmp    32d <gets+0x53>
    cc = read(0, &c, 1);
 2e9:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 2f0:	00 
 2f1:	8d 45 ef             	lea    -0x11(%ebp),%eax
 2f4:	89 44 24 04          	mov    %eax,0x4(%esp)
 2f8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 2ff:	e8 3c 01 00 00       	call   440 <read>
 304:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 307:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 30b:	7e 2d                	jle    33a <gets+0x60>
      break;
    buf[i++] = c;
 30d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 310:	03 45 08             	add    0x8(%ebp),%eax
 313:	0f b6 55 ef          	movzbl -0x11(%ebp),%edx
 317:	88 10                	mov    %dl,(%eax)
 319:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(c == '\n' || c == '\r')
 31d:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 321:	3c 0a                	cmp    $0xa,%al
 323:	74 16                	je     33b <gets+0x61>
 325:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 329:	3c 0d                	cmp    $0xd,%al
 32b:	74 0e                	je     33b <gets+0x61>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 32d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 330:	83 c0 01             	add    $0x1,%eax
 333:	3b 45 0c             	cmp    0xc(%ebp),%eax
 336:	7c b1                	jl     2e9 <gets+0xf>
 338:	eb 01                	jmp    33b <gets+0x61>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 33a:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 33b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 33e:	03 45 08             	add    0x8(%ebp),%eax
 341:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 344:	8b 45 08             	mov    0x8(%ebp),%eax
}
 347:	c9                   	leave  
 348:	c3                   	ret    

00000349 <stat>:

int
stat(char *n, struct stat *st)
{
 349:	55                   	push   %ebp
 34a:	89 e5                	mov    %esp,%ebp
 34c:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 34f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 356:	00 
 357:	8b 45 08             	mov    0x8(%ebp),%eax
 35a:	89 04 24             	mov    %eax,(%esp)
 35d:	e8 06 01 00 00       	call   468 <open>
 362:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 365:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 369:	79 07                	jns    372 <stat+0x29>
    return -1;
 36b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 370:	eb 23                	jmp    395 <stat+0x4c>
  r = fstat(fd, st);
 372:	8b 45 0c             	mov    0xc(%ebp),%eax
 375:	89 44 24 04          	mov    %eax,0x4(%esp)
 379:	8b 45 f4             	mov    -0xc(%ebp),%eax
 37c:	89 04 24             	mov    %eax,(%esp)
 37f:	e8 fc 00 00 00       	call   480 <fstat>
 384:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 387:	8b 45 f4             	mov    -0xc(%ebp),%eax
 38a:	89 04 24             	mov    %eax,(%esp)
 38d:	e8 be 00 00 00       	call   450 <close>
  return r;
 392:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 395:	c9                   	leave  
 396:	c3                   	ret    

00000397 <atoi>:

int
atoi(const char *s)
{
 397:	55                   	push   %ebp
 398:	89 e5                	mov    %esp,%ebp
 39a:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 39d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 3a4:	eb 23                	jmp    3c9 <atoi+0x32>
    n = n*10 + *s++ - '0';
 3a6:	8b 55 fc             	mov    -0x4(%ebp),%edx
 3a9:	89 d0                	mov    %edx,%eax
 3ab:	c1 e0 02             	shl    $0x2,%eax
 3ae:	01 d0                	add    %edx,%eax
 3b0:	01 c0                	add    %eax,%eax
 3b2:	89 c2                	mov    %eax,%edx
 3b4:	8b 45 08             	mov    0x8(%ebp),%eax
 3b7:	0f b6 00             	movzbl (%eax),%eax
 3ba:	0f be c0             	movsbl %al,%eax
 3bd:	01 d0                	add    %edx,%eax
 3bf:	83 e8 30             	sub    $0x30,%eax
 3c2:	89 45 fc             	mov    %eax,-0x4(%ebp)
 3c5:	83 45 08 01          	addl   $0x1,0x8(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 3c9:	8b 45 08             	mov    0x8(%ebp),%eax
 3cc:	0f b6 00             	movzbl (%eax),%eax
 3cf:	3c 2f                	cmp    $0x2f,%al
 3d1:	7e 0a                	jle    3dd <atoi+0x46>
 3d3:	8b 45 08             	mov    0x8(%ebp),%eax
 3d6:	0f b6 00             	movzbl (%eax),%eax
 3d9:	3c 39                	cmp    $0x39,%al
 3db:	7e c9                	jle    3a6 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 3dd:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 3e0:	c9                   	leave  
 3e1:	c3                   	ret    

000003e2 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 3e2:	55                   	push   %ebp
 3e3:	89 e5                	mov    %esp,%ebp
 3e5:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 3e8:	8b 45 08             	mov    0x8(%ebp),%eax
 3eb:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 3ee:	8b 45 0c             	mov    0xc(%ebp),%eax
 3f1:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 3f4:	eb 13                	jmp    409 <memmove+0x27>
    *dst++ = *src++;
 3f6:	8b 45 f8             	mov    -0x8(%ebp),%eax
 3f9:	0f b6 10             	movzbl (%eax),%edx
 3fc:	8b 45 fc             	mov    -0x4(%ebp),%eax
 3ff:	88 10                	mov    %dl,(%eax)
 401:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 405:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 409:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 40d:	0f 9f c0             	setg   %al
 410:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 414:	84 c0                	test   %al,%al
 416:	75 de                	jne    3f6 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 418:	8b 45 08             	mov    0x8(%ebp),%eax
}
 41b:	c9                   	leave  
 41c:	c3                   	ret    
 41d:	90                   	nop
 41e:	90                   	nop
 41f:	90                   	nop

00000420 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 420:	b8 01 00 00 00       	mov    $0x1,%eax
 425:	cd 40                	int    $0x40
 427:	c3                   	ret    

00000428 <exit>:
SYSCALL(exit)
 428:	b8 02 00 00 00       	mov    $0x2,%eax
 42d:	cd 40                	int    $0x40
 42f:	c3                   	ret    

00000430 <wait>:
SYSCALL(wait)
 430:	b8 03 00 00 00       	mov    $0x3,%eax
 435:	cd 40                	int    $0x40
 437:	c3                   	ret    

00000438 <pipe>:
SYSCALL(pipe)
 438:	b8 04 00 00 00       	mov    $0x4,%eax
 43d:	cd 40                	int    $0x40
 43f:	c3                   	ret    

00000440 <read>:
SYSCALL(read)
 440:	b8 05 00 00 00       	mov    $0x5,%eax
 445:	cd 40                	int    $0x40
 447:	c3                   	ret    

00000448 <write>:
SYSCALL(write)
 448:	b8 10 00 00 00       	mov    $0x10,%eax
 44d:	cd 40                	int    $0x40
 44f:	c3                   	ret    

00000450 <close>:
SYSCALL(close)
 450:	b8 15 00 00 00       	mov    $0x15,%eax
 455:	cd 40                	int    $0x40
 457:	c3                   	ret    

00000458 <kill>:
SYSCALL(kill)
 458:	b8 06 00 00 00       	mov    $0x6,%eax
 45d:	cd 40                	int    $0x40
 45f:	c3                   	ret    

00000460 <exec>:
SYSCALL(exec)
 460:	b8 07 00 00 00       	mov    $0x7,%eax
 465:	cd 40                	int    $0x40
 467:	c3                   	ret    

00000468 <open>:
SYSCALL(open)
 468:	b8 0f 00 00 00       	mov    $0xf,%eax
 46d:	cd 40                	int    $0x40
 46f:	c3                   	ret    

00000470 <mknod>:
SYSCALL(mknod)
 470:	b8 11 00 00 00       	mov    $0x11,%eax
 475:	cd 40                	int    $0x40
 477:	c3                   	ret    

00000478 <unlink>:
SYSCALL(unlink)
 478:	b8 12 00 00 00       	mov    $0x12,%eax
 47d:	cd 40                	int    $0x40
 47f:	c3                   	ret    

00000480 <fstat>:
SYSCALL(fstat)
 480:	b8 08 00 00 00       	mov    $0x8,%eax
 485:	cd 40                	int    $0x40
 487:	c3                   	ret    

00000488 <link>:
SYSCALL(link)
 488:	b8 13 00 00 00       	mov    $0x13,%eax
 48d:	cd 40                	int    $0x40
 48f:	c3                   	ret    

00000490 <mkdir>:
SYSCALL(mkdir)
 490:	b8 14 00 00 00       	mov    $0x14,%eax
 495:	cd 40                	int    $0x40
 497:	c3                   	ret    

00000498 <chdir>:
SYSCALL(chdir)
 498:	b8 09 00 00 00       	mov    $0x9,%eax
 49d:	cd 40                	int    $0x40
 49f:	c3                   	ret    

000004a0 <dup>:
SYSCALL(dup)
 4a0:	b8 0a 00 00 00       	mov    $0xa,%eax
 4a5:	cd 40                	int    $0x40
 4a7:	c3                   	ret    

000004a8 <getpid>:
SYSCALL(getpid)
 4a8:	b8 0b 00 00 00       	mov    $0xb,%eax
 4ad:	cd 40                	int    $0x40
 4af:	c3                   	ret    

000004b0 <sbrk>:
SYSCALL(sbrk)
 4b0:	b8 0c 00 00 00       	mov    $0xc,%eax
 4b5:	cd 40                	int    $0x40
 4b7:	c3                   	ret    

000004b8 <sleep>:
SYSCALL(sleep)
 4b8:	b8 0d 00 00 00       	mov    $0xd,%eax
 4bd:	cd 40                	int    $0x40
 4bf:	c3                   	ret    

000004c0 <uptime>:
SYSCALL(uptime)
 4c0:	b8 0e 00 00 00       	mov    $0xe,%eax
 4c5:	cd 40                	int    $0x40
 4c7:	c3                   	ret    

000004c8 <waitpid>:
SYSCALL(waitpid)
 4c8:	b8 16 00 00 00       	mov    $0x16,%eax
 4cd:	cd 40                	int    $0x40
 4cf:	c3                   	ret    

000004d0 <wait_stat>:
SYSCALL(wait_stat)
 4d0:	b8 17 00 00 00       	mov    $0x17,%eax
 4d5:	cd 40                	int    $0x40
 4d7:	c3                   	ret    

000004d8 <list_pgroup>:
SYSCALL(list_pgroup)
 4d8:	b8 18 00 00 00       	mov    $0x18,%eax
 4dd:	cd 40                	int    $0x40
 4df:	c3                   	ret    

000004e0 <foreground>:
SYSCALL(foreground)
 4e0:	b8 19 00 00 00       	mov    $0x19,%eax
 4e5:	cd 40                	int    $0x40
 4e7:	c3                   	ret    

000004e8 <set_priority>:
SYSCALL(set_priority)
 4e8:	b8 1a 00 00 00       	mov    $0x1a,%eax
 4ed:	cd 40                	int    $0x40
 4ef:	c3                   	ret    

000004f0 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 4f0:	55                   	push   %ebp
 4f1:	89 e5                	mov    %esp,%ebp
 4f3:	83 ec 28             	sub    $0x28,%esp
 4f6:	8b 45 0c             	mov    0xc(%ebp),%eax
 4f9:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 4fc:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 503:	00 
 504:	8d 45 f4             	lea    -0xc(%ebp),%eax
 507:	89 44 24 04          	mov    %eax,0x4(%esp)
 50b:	8b 45 08             	mov    0x8(%ebp),%eax
 50e:	89 04 24             	mov    %eax,(%esp)
 511:	e8 32 ff ff ff       	call   448 <write>
}
 516:	c9                   	leave  
 517:	c3                   	ret    

00000518 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 518:	55                   	push   %ebp
 519:	89 e5                	mov    %esp,%ebp
 51b:	83 ec 48             	sub    $0x48,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 51e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 525:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 529:	74 17                	je     542 <printint+0x2a>
 52b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 52f:	79 11                	jns    542 <printint+0x2a>
    neg = 1;
 531:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 538:	8b 45 0c             	mov    0xc(%ebp),%eax
 53b:	f7 d8                	neg    %eax
 53d:	89 45 ec             	mov    %eax,-0x14(%ebp)
 540:	eb 06                	jmp    548 <printint+0x30>
  } else {
    x = xx;
 542:	8b 45 0c             	mov    0xc(%ebp),%eax
 545:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 548:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 54f:	8b 4d 10             	mov    0x10(%ebp),%ecx
 552:	8b 45 ec             	mov    -0x14(%ebp),%eax
 555:	ba 00 00 00 00       	mov    $0x0,%edx
 55a:	f7 f1                	div    %ecx
 55c:	89 d0                	mov    %edx,%eax
 55e:	0f b6 90 f4 0b 00 00 	movzbl 0xbf4(%eax),%edx
 565:	8d 45 dc             	lea    -0x24(%ebp),%eax
 568:	03 45 f4             	add    -0xc(%ebp),%eax
 56b:	88 10                	mov    %dl,(%eax)
 56d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  }while((x /= base) != 0);
 571:	8b 55 10             	mov    0x10(%ebp),%edx
 574:	89 55 d4             	mov    %edx,-0x2c(%ebp)
 577:	8b 45 ec             	mov    -0x14(%ebp),%eax
 57a:	ba 00 00 00 00       	mov    $0x0,%edx
 57f:	f7 75 d4             	divl   -0x2c(%ebp)
 582:	89 45 ec             	mov    %eax,-0x14(%ebp)
 585:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 589:	75 c4                	jne    54f <printint+0x37>
  if(neg)
 58b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 58f:	74 2a                	je     5bb <printint+0xa3>
    buf[i++] = '-';
 591:	8d 45 dc             	lea    -0x24(%ebp),%eax
 594:	03 45 f4             	add    -0xc(%ebp),%eax
 597:	c6 00 2d             	movb   $0x2d,(%eax)
 59a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

  while(--i >= 0)
 59e:	eb 1b                	jmp    5bb <printint+0xa3>
    putc(fd, buf[i]);
 5a0:	8d 45 dc             	lea    -0x24(%ebp),%eax
 5a3:	03 45 f4             	add    -0xc(%ebp),%eax
 5a6:	0f b6 00             	movzbl (%eax),%eax
 5a9:	0f be c0             	movsbl %al,%eax
 5ac:	89 44 24 04          	mov    %eax,0x4(%esp)
 5b0:	8b 45 08             	mov    0x8(%ebp),%eax
 5b3:	89 04 24             	mov    %eax,(%esp)
 5b6:	e8 35 ff ff ff       	call   4f0 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 5bb:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 5bf:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 5c3:	79 db                	jns    5a0 <printint+0x88>
    putc(fd, buf[i]);
}
 5c5:	c9                   	leave  
 5c6:	c3                   	ret    

000005c7 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 5c7:	55                   	push   %ebp
 5c8:	89 e5                	mov    %esp,%ebp
 5ca:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 5cd:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 5d4:	8d 45 0c             	lea    0xc(%ebp),%eax
 5d7:	83 c0 04             	add    $0x4,%eax
 5da:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 5dd:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 5e4:	e9 7d 01 00 00       	jmp    766 <printf+0x19f>
    c = fmt[i] & 0xff;
 5e9:	8b 55 0c             	mov    0xc(%ebp),%edx
 5ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
 5ef:	01 d0                	add    %edx,%eax
 5f1:	0f b6 00             	movzbl (%eax),%eax
 5f4:	0f be c0             	movsbl %al,%eax
 5f7:	25 ff 00 00 00       	and    $0xff,%eax
 5fc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 5ff:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 603:	75 2c                	jne    631 <printf+0x6a>
      if(c == '%'){
 605:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 609:	75 0c                	jne    617 <printf+0x50>
        state = '%';
 60b:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 612:	e9 4b 01 00 00       	jmp    762 <printf+0x19b>
      } else {
        putc(fd, c);
 617:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 61a:	0f be c0             	movsbl %al,%eax
 61d:	89 44 24 04          	mov    %eax,0x4(%esp)
 621:	8b 45 08             	mov    0x8(%ebp),%eax
 624:	89 04 24             	mov    %eax,(%esp)
 627:	e8 c4 fe ff ff       	call   4f0 <putc>
 62c:	e9 31 01 00 00       	jmp    762 <printf+0x19b>
      }
    } else if(state == '%'){
 631:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 635:	0f 85 27 01 00 00    	jne    762 <printf+0x19b>
      if(c == 'd'){
 63b:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 63f:	75 2d                	jne    66e <printf+0xa7>
        printint(fd, *ap, 10, 1);
 641:	8b 45 e8             	mov    -0x18(%ebp),%eax
 644:	8b 00                	mov    (%eax),%eax
 646:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 64d:	00 
 64e:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 655:	00 
 656:	89 44 24 04          	mov    %eax,0x4(%esp)
 65a:	8b 45 08             	mov    0x8(%ebp),%eax
 65d:	89 04 24             	mov    %eax,(%esp)
 660:	e8 b3 fe ff ff       	call   518 <printint>
        ap++;
 665:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 669:	e9 ed 00 00 00       	jmp    75b <printf+0x194>
      } else if(c == 'x' || c == 'p'){
 66e:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 672:	74 06                	je     67a <printf+0xb3>
 674:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 678:	75 2d                	jne    6a7 <printf+0xe0>
        printint(fd, *ap, 16, 0);
 67a:	8b 45 e8             	mov    -0x18(%ebp),%eax
 67d:	8b 00                	mov    (%eax),%eax
 67f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 686:	00 
 687:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 68e:	00 
 68f:	89 44 24 04          	mov    %eax,0x4(%esp)
 693:	8b 45 08             	mov    0x8(%ebp),%eax
 696:	89 04 24             	mov    %eax,(%esp)
 699:	e8 7a fe ff ff       	call   518 <printint>
        ap++;
 69e:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 6a2:	e9 b4 00 00 00       	jmp    75b <printf+0x194>
      } else if(c == 's'){
 6a7:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 6ab:	75 46                	jne    6f3 <printf+0x12c>
        s = (char*)*ap;
 6ad:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6b0:	8b 00                	mov    (%eax),%eax
 6b2:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 6b5:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 6b9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 6bd:	75 27                	jne    6e6 <printf+0x11f>
          s = "(null)";
 6bf:	c7 45 f4 ae 09 00 00 	movl   $0x9ae,-0xc(%ebp)
        while(*s != 0){
 6c6:	eb 1e                	jmp    6e6 <printf+0x11f>
          putc(fd, *s);
 6c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6cb:	0f b6 00             	movzbl (%eax),%eax
 6ce:	0f be c0             	movsbl %al,%eax
 6d1:	89 44 24 04          	mov    %eax,0x4(%esp)
 6d5:	8b 45 08             	mov    0x8(%ebp),%eax
 6d8:	89 04 24             	mov    %eax,(%esp)
 6db:	e8 10 fe ff ff       	call   4f0 <putc>
          s++;
 6e0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 6e4:	eb 01                	jmp    6e7 <printf+0x120>
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 6e6:	90                   	nop
 6e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6ea:	0f b6 00             	movzbl (%eax),%eax
 6ed:	84 c0                	test   %al,%al
 6ef:	75 d7                	jne    6c8 <printf+0x101>
 6f1:	eb 68                	jmp    75b <printf+0x194>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 6f3:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 6f7:	75 1d                	jne    716 <printf+0x14f>
        putc(fd, *ap);
 6f9:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6fc:	8b 00                	mov    (%eax),%eax
 6fe:	0f be c0             	movsbl %al,%eax
 701:	89 44 24 04          	mov    %eax,0x4(%esp)
 705:	8b 45 08             	mov    0x8(%ebp),%eax
 708:	89 04 24             	mov    %eax,(%esp)
 70b:	e8 e0 fd ff ff       	call   4f0 <putc>
        ap++;
 710:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 714:	eb 45                	jmp    75b <printf+0x194>
      } else if(c == '%'){
 716:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 71a:	75 17                	jne    733 <printf+0x16c>
        putc(fd, c);
 71c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 71f:	0f be c0             	movsbl %al,%eax
 722:	89 44 24 04          	mov    %eax,0x4(%esp)
 726:	8b 45 08             	mov    0x8(%ebp),%eax
 729:	89 04 24             	mov    %eax,(%esp)
 72c:	e8 bf fd ff ff       	call   4f0 <putc>
 731:	eb 28                	jmp    75b <printf+0x194>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 733:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 73a:	00 
 73b:	8b 45 08             	mov    0x8(%ebp),%eax
 73e:	89 04 24             	mov    %eax,(%esp)
 741:	e8 aa fd ff ff       	call   4f0 <putc>
        putc(fd, c);
 746:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 749:	0f be c0             	movsbl %al,%eax
 74c:	89 44 24 04          	mov    %eax,0x4(%esp)
 750:	8b 45 08             	mov    0x8(%ebp),%eax
 753:	89 04 24             	mov    %eax,(%esp)
 756:	e8 95 fd ff ff       	call   4f0 <putc>
      }
      state = 0;
 75b:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 762:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 766:	8b 55 0c             	mov    0xc(%ebp),%edx
 769:	8b 45 f0             	mov    -0x10(%ebp),%eax
 76c:	01 d0                	add    %edx,%eax
 76e:	0f b6 00             	movzbl (%eax),%eax
 771:	84 c0                	test   %al,%al
 773:	0f 85 70 fe ff ff    	jne    5e9 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 779:	c9                   	leave  
 77a:	c3                   	ret    
 77b:	90                   	nop

0000077c <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 77c:	55                   	push   %ebp
 77d:	89 e5                	mov    %esp,%ebp
 77f:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 782:	8b 45 08             	mov    0x8(%ebp),%eax
 785:	83 e8 08             	sub    $0x8,%eax
 788:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 78b:	a1 10 0c 00 00       	mov    0xc10,%eax
 790:	89 45 fc             	mov    %eax,-0x4(%ebp)
 793:	eb 24                	jmp    7b9 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 795:	8b 45 fc             	mov    -0x4(%ebp),%eax
 798:	8b 00                	mov    (%eax),%eax
 79a:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 79d:	77 12                	ja     7b1 <free+0x35>
 79f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7a2:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 7a5:	77 24                	ja     7cb <free+0x4f>
 7a7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7aa:	8b 00                	mov    (%eax),%eax
 7ac:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 7af:	77 1a                	ja     7cb <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7b1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7b4:	8b 00                	mov    (%eax),%eax
 7b6:	89 45 fc             	mov    %eax,-0x4(%ebp)
 7b9:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7bc:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 7bf:	76 d4                	jbe    795 <free+0x19>
 7c1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7c4:	8b 00                	mov    (%eax),%eax
 7c6:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 7c9:	76 ca                	jbe    795 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 7cb:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7ce:	8b 40 04             	mov    0x4(%eax),%eax
 7d1:	c1 e0 03             	shl    $0x3,%eax
 7d4:	89 c2                	mov    %eax,%edx
 7d6:	03 55 f8             	add    -0x8(%ebp),%edx
 7d9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7dc:	8b 00                	mov    (%eax),%eax
 7de:	39 c2                	cmp    %eax,%edx
 7e0:	75 24                	jne    806 <free+0x8a>
    bp->s.size += p->s.ptr->s.size;
 7e2:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7e5:	8b 50 04             	mov    0x4(%eax),%edx
 7e8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7eb:	8b 00                	mov    (%eax),%eax
 7ed:	8b 40 04             	mov    0x4(%eax),%eax
 7f0:	01 c2                	add    %eax,%edx
 7f2:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7f5:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 7f8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7fb:	8b 00                	mov    (%eax),%eax
 7fd:	8b 10                	mov    (%eax),%edx
 7ff:	8b 45 f8             	mov    -0x8(%ebp),%eax
 802:	89 10                	mov    %edx,(%eax)
 804:	eb 0a                	jmp    810 <free+0x94>
  } else
    bp->s.ptr = p->s.ptr;
 806:	8b 45 fc             	mov    -0x4(%ebp),%eax
 809:	8b 10                	mov    (%eax),%edx
 80b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 80e:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 810:	8b 45 fc             	mov    -0x4(%ebp),%eax
 813:	8b 40 04             	mov    0x4(%eax),%eax
 816:	c1 e0 03             	shl    $0x3,%eax
 819:	03 45 fc             	add    -0x4(%ebp),%eax
 81c:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 81f:	75 20                	jne    841 <free+0xc5>
    p->s.size += bp->s.size;
 821:	8b 45 fc             	mov    -0x4(%ebp),%eax
 824:	8b 50 04             	mov    0x4(%eax),%edx
 827:	8b 45 f8             	mov    -0x8(%ebp),%eax
 82a:	8b 40 04             	mov    0x4(%eax),%eax
 82d:	01 c2                	add    %eax,%edx
 82f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 832:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 835:	8b 45 f8             	mov    -0x8(%ebp),%eax
 838:	8b 10                	mov    (%eax),%edx
 83a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 83d:	89 10                	mov    %edx,(%eax)
 83f:	eb 08                	jmp    849 <free+0xcd>
  } else
    p->s.ptr = bp;
 841:	8b 45 fc             	mov    -0x4(%ebp),%eax
 844:	8b 55 f8             	mov    -0x8(%ebp),%edx
 847:	89 10                	mov    %edx,(%eax)
  freep = p;
 849:	8b 45 fc             	mov    -0x4(%ebp),%eax
 84c:	a3 10 0c 00 00       	mov    %eax,0xc10
}
 851:	c9                   	leave  
 852:	c3                   	ret    

00000853 <morecore>:

static Header*
morecore(uint nu)
{
 853:	55                   	push   %ebp
 854:	89 e5                	mov    %esp,%ebp
 856:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 859:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 860:	77 07                	ja     869 <morecore+0x16>
    nu = 4096;
 862:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 869:	8b 45 08             	mov    0x8(%ebp),%eax
 86c:	c1 e0 03             	shl    $0x3,%eax
 86f:	89 04 24             	mov    %eax,(%esp)
 872:	e8 39 fc ff ff       	call   4b0 <sbrk>
 877:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 87a:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 87e:	75 07                	jne    887 <morecore+0x34>
    return 0;
 880:	b8 00 00 00 00       	mov    $0x0,%eax
 885:	eb 22                	jmp    8a9 <morecore+0x56>
  hp = (Header*)p;
 887:	8b 45 f4             	mov    -0xc(%ebp),%eax
 88a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 88d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 890:	8b 55 08             	mov    0x8(%ebp),%edx
 893:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 896:	8b 45 f0             	mov    -0x10(%ebp),%eax
 899:	83 c0 08             	add    $0x8,%eax
 89c:	89 04 24             	mov    %eax,(%esp)
 89f:	e8 d8 fe ff ff       	call   77c <free>
  return freep;
 8a4:	a1 10 0c 00 00       	mov    0xc10,%eax
}
 8a9:	c9                   	leave  
 8aa:	c3                   	ret    

000008ab <malloc>:

void*
malloc(uint nbytes)
{
 8ab:	55                   	push   %ebp
 8ac:	89 e5                	mov    %esp,%ebp
 8ae:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8b1:	8b 45 08             	mov    0x8(%ebp),%eax
 8b4:	83 c0 07             	add    $0x7,%eax
 8b7:	c1 e8 03             	shr    $0x3,%eax
 8ba:	83 c0 01             	add    $0x1,%eax
 8bd:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 8c0:	a1 10 0c 00 00       	mov    0xc10,%eax
 8c5:	89 45 f0             	mov    %eax,-0x10(%ebp)
 8c8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 8cc:	75 23                	jne    8f1 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 8ce:	c7 45 f0 08 0c 00 00 	movl   $0xc08,-0x10(%ebp)
 8d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8d8:	a3 10 0c 00 00       	mov    %eax,0xc10
 8dd:	a1 10 0c 00 00       	mov    0xc10,%eax
 8e2:	a3 08 0c 00 00       	mov    %eax,0xc08
    base.s.size = 0;
 8e7:	c7 05 0c 0c 00 00 00 	movl   $0x0,0xc0c
 8ee:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8f4:	8b 00                	mov    (%eax),%eax
 8f6:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 8f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8fc:	8b 40 04             	mov    0x4(%eax),%eax
 8ff:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 902:	72 4d                	jb     951 <malloc+0xa6>
      if(p->s.size == nunits)
 904:	8b 45 f4             	mov    -0xc(%ebp),%eax
 907:	8b 40 04             	mov    0x4(%eax),%eax
 90a:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 90d:	75 0c                	jne    91b <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 90f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 912:	8b 10                	mov    (%eax),%edx
 914:	8b 45 f0             	mov    -0x10(%ebp),%eax
 917:	89 10                	mov    %edx,(%eax)
 919:	eb 26                	jmp    941 <malloc+0x96>
      else {
        p->s.size -= nunits;
 91b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 91e:	8b 40 04             	mov    0x4(%eax),%eax
 921:	89 c2                	mov    %eax,%edx
 923:	2b 55 ec             	sub    -0x14(%ebp),%edx
 926:	8b 45 f4             	mov    -0xc(%ebp),%eax
 929:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 92c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 92f:	8b 40 04             	mov    0x4(%eax),%eax
 932:	c1 e0 03             	shl    $0x3,%eax
 935:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 938:	8b 45 f4             	mov    -0xc(%ebp),%eax
 93b:	8b 55 ec             	mov    -0x14(%ebp),%edx
 93e:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 941:	8b 45 f0             	mov    -0x10(%ebp),%eax
 944:	a3 10 0c 00 00       	mov    %eax,0xc10
      return (void*)(p + 1);
 949:	8b 45 f4             	mov    -0xc(%ebp),%eax
 94c:	83 c0 08             	add    $0x8,%eax
 94f:	eb 38                	jmp    989 <malloc+0xde>
    }
    if(p == freep)
 951:	a1 10 0c 00 00       	mov    0xc10,%eax
 956:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 959:	75 1b                	jne    976 <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 95b:	8b 45 ec             	mov    -0x14(%ebp),%eax
 95e:	89 04 24             	mov    %eax,(%esp)
 961:	e8 ed fe ff ff       	call   853 <morecore>
 966:	89 45 f4             	mov    %eax,-0xc(%ebp)
 969:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 96d:	75 07                	jne    976 <malloc+0xcb>
        return 0;
 96f:	b8 00 00 00 00       	mov    $0x0,%eax
 974:	eb 13                	jmp    989 <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 976:	8b 45 f4             	mov    -0xc(%ebp),%eax
 979:	89 45 f0             	mov    %eax,-0x10(%ebp)
 97c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 97f:	8b 00                	mov    (%eax),%eax
 981:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 984:	e9 70 ff ff ff       	jmp    8f9 <malloc+0x4e>
}
 989:	c9                   	leave  
 98a:	c3                   	ret    
