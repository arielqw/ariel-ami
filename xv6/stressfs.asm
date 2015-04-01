
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
  2c:	c7 44 24 04 6b 09 00 	movl   $0x96b,0x4(%esp)
  33:	00 
  34:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  3b:	e8 67 05 00 00       	call   5a7 <printf>
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
  92:	c7 44 24 04 7e 09 00 	movl   $0x97e,0x4(%esp)
  99:	00 
  9a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  a1:	e8 01 05 00 00       	call   5a7 <printf>

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
 12b:	c7 44 24 04 88 09 00 	movl   $0x988,0x4(%esp)
 132:	00 
 133:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 13a:	e8 68 04 00 00       	call   5a7 <printf>

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

000004d0 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 4d0:	55                   	push   %ebp
 4d1:	89 e5                	mov    %esp,%ebp
 4d3:	83 ec 28             	sub    $0x28,%esp
 4d6:	8b 45 0c             	mov    0xc(%ebp),%eax
 4d9:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 4dc:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 4e3:	00 
 4e4:	8d 45 f4             	lea    -0xc(%ebp),%eax
 4e7:	89 44 24 04          	mov    %eax,0x4(%esp)
 4eb:	8b 45 08             	mov    0x8(%ebp),%eax
 4ee:	89 04 24             	mov    %eax,(%esp)
 4f1:	e8 52 ff ff ff       	call   448 <write>
}
 4f6:	c9                   	leave  
 4f7:	c3                   	ret    

000004f8 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 4f8:	55                   	push   %ebp
 4f9:	89 e5                	mov    %esp,%ebp
 4fb:	83 ec 48             	sub    $0x48,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 4fe:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 505:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 509:	74 17                	je     522 <printint+0x2a>
 50b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 50f:	79 11                	jns    522 <printint+0x2a>
    neg = 1;
 511:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 518:	8b 45 0c             	mov    0xc(%ebp),%eax
 51b:	f7 d8                	neg    %eax
 51d:	89 45 ec             	mov    %eax,-0x14(%ebp)
 520:	eb 06                	jmp    528 <printint+0x30>
  } else {
    x = xx;
 522:	8b 45 0c             	mov    0xc(%ebp),%eax
 525:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 528:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 52f:	8b 4d 10             	mov    0x10(%ebp),%ecx
 532:	8b 45 ec             	mov    -0x14(%ebp),%eax
 535:	ba 00 00 00 00       	mov    $0x0,%edx
 53a:	f7 f1                	div    %ecx
 53c:	89 d0                	mov    %edx,%eax
 53e:	0f b6 90 d4 0b 00 00 	movzbl 0xbd4(%eax),%edx
 545:	8d 45 dc             	lea    -0x24(%ebp),%eax
 548:	03 45 f4             	add    -0xc(%ebp),%eax
 54b:	88 10                	mov    %dl,(%eax)
 54d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  }while((x /= base) != 0);
 551:	8b 55 10             	mov    0x10(%ebp),%edx
 554:	89 55 d4             	mov    %edx,-0x2c(%ebp)
 557:	8b 45 ec             	mov    -0x14(%ebp),%eax
 55a:	ba 00 00 00 00       	mov    $0x0,%edx
 55f:	f7 75 d4             	divl   -0x2c(%ebp)
 562:	89 45 ec             	mov    %eax,-0x14(%ebp)
 565:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 569:	75 c4                	jne    52f <printint+0x37>
  if(neg)
 56b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 56f:	74 2a                	je     59b <printint+0xa3>
    buf[i++] = '-';
 571:	8d 45 dc             	lea    -0x24(%ebp),%eax
 574:	03 45 f4             	add    -0xc(%ebp),%eax
 577:	c6 00 2d             	movb   $0x2d,(%eax)
 57a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

  while(--i >= 0)
 57e:	eb 1b                	jmp    59b <printint+0xa3>
    putc(fd, buf[i]);
 580:	8d 45 dc             	lea    -0x24(%ebp),%eax
 583:	03 45 f4             	add    -0xc(%ebp),%eax
 586:	0f b6 00             	movzbl (%eax),%eax
 589:	0f be c0             	movsbl %al,%eax
 58c:	89 44 24 04          	mov    %eax,0x4(%esp)
 590:	8b 45 08             	mov    0x8(%ebp),%eax
 593:	89 04 24             	mov    %eax,(%esp)
 596:	e8 35 ff ff ff       	call   4d0 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 59b:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 59f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 5a3:	79 db                	jns    580 <printint+0x88>
    putc(fd, buf[i]);
}
 5a5:	c9                   	leave  
 5a6:	c3                   	ret    

000005a7 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 5a7:	55                   	push   %ebp
 5a8:	89 e5                	mov    %esp,%ebp
 5aa:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 5ad:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 5b4:	8d 45 0c             	lea    0xc(%ebp),%eax
 5b7:	83 c0 04             	add    $0x4,%eax
 5ba:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 5bd:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 5c4:	e9 7d 01 00 00       	jmp    746 <printf+0x19f>
    c = fmt[i] & 0xff;
 5c9:	8b 55 0c             	mov    0xc(%ebp),%edx
 5cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
 5cf:	01 d0                	add    %edx,%eax
 5d1:	0f b6 00             	movzbl (%eax),%eax
 5d4:	0f be c0             	movsbl %al,%eax
 5d7:	25 ff 00 00 00       	and    $0xff,%eax
 5dc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 5df:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 5e3:	75 2c                	jne    611 <printf+0x6a>
      if(c == '%'){
 5e5:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 5e9:	75 0c                	jne    5f7 <printf+0x50>
        state = '%';
 5eb:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 5f2:	e9 4b 01 00 00       	jmp    742 <printf+0x19b>
      } else {
        putc(fd, c);
 5f7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 5fa:	0f be c0             	movsbl %al,%eax
 5fd:	89 44 24 04          	mov    %eax,0x4(%esp)
 601:	8b 45 08             	mov    0x8(%ebp),%eax
 604:	89 04 24             	mov    %eax,(%esp)
 607:	e8 c4 fe ff ff       	call   4d0 <putc>
 60c:	e9 31 01 00 00       	jmp    742 <printf+0x19b>
      }
    } else if(state == '%'){
 611:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 615:	0f 85 27 01 00 00    	jne    742 <printf+0x19b>
      if(c == 'd'){
 61b:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 61f:	75 2d                	jne    64e <printf+0xa7>
        printint(fd, *ap, 10, 1);
 621:	8b 45 e8             	mov    -0x18(%ebp),%eax
 624:	8b 00                	mov    (%eax),%eax
 626:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 62d:	00 
 62e:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 635:	00 
 636:	89 44 24 04          	mov    %eax,0x4(%esp)
 63a:	8b 45 08             	mov    0x8(%ebp),%eax
 63d:	89 04 24             	mov    %eax,(%esp)
 640:	e8 b3 fe ff ff       	call   4f8 <printint>
        ap++;
 645:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 649:	e9 ed 00 00 00       	jmp    73b <printf+0x194>
      } else if(c == 'x' || c == 'p'){
 64e:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 652:	74 06                	je     65a <printf+0xb3>
 654:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 658:	75 2d                	jne    687 <printf+0xe0>
        printint(fd, *ap, 16, 0);
 65a:	8b 45 e8             	mov    -0x18(%ebp),%eax
 65d:	8b 00                	mov    (%eax),%eax
 65f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 666:	00 
 667:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 66e:	00 
 66f:	89 44 24 04          	mov    %eax,0x4(%esp)
 673:	8b 45 08             	mov    0x8(%ebp),%eax
 676:	89 04 24             	mov    %eax,(%esp)
 679:	e8 7a fe ff ff       	call   4f8 <printint>
        ap++;
 67e:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 682:	e9 b4 00 00 00       	jmp    73b <printf+0x194>
      } else if(c == 's'){
 687:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 68b:	75 46                	jne    6d3 <printf+0x12c>
        s = (char*)*ap;
 68d:	8b 45 e8             	mov    -0x18(%ebp),%eax
 690:	8b 00                	mov    (%eax),%eax
 692:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 695:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 699:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 69d:	75 27                	jne    6c6 <printf+0x11f>
          s = "(null)";
 69f:	c7 45 f4 8e 09 00 00 	movl   $0x98e,-0xc(%ebp)
        while(*s != 0){
 6a6:	eb 1e                	jmp    6c6 <printf+0x11f>
          putc(fd, *s);
 6a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6ab:	0f b6 00             	movzbl (%eax),%eax
 6ae:	0f be c0             	movsbl %al,%eax
 6b1:	89 44 24 04          	mov    %eax,0x4(%esp)
 6b5:	8b 45 08             	mov    0x8(%ebp),%eax
 6b8:	89 04 24             	mov    %eax,(%esp)
 6bb:	e8 10 fe ff ff       	call   4d0 <putc>
          s++;
 6c0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 6c4:	eb 01                	jmp    6c7 <printf+0x120>
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 6c6:	90                   	nop
 6c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6ca:	0f b6 00             	movzbl (%eax),%eax
 6cd:	84 c0                	test   %al,%al
 6cf:	75 d7                	jne    6a8 <printf+0x101>
 6d1:	eb 68                	jmp    73b <printf+0x194>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 6d3:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 6d7:	75 1d                	jne    6f6 <printf+0x14f>
        putc(fd, *ap);
 6d9:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6dc:	8b 00                	mov    (%eax),%eax
 6de:	0f be c0             	movsbl %al,%eax
 6e1:	89 44 24 04          	mov    %eax,0x4(%esp)
 6e5:	8b 45 08             	mov    0x8(%ebp),%eax
 6e8:	89 04 24             	mov    %eax,(%esp)
 6eb:	e8 e0 fd ff ff       	call   4d0 <putc>
        ap++;
 6f0:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 6f4:	eb 45                	jmp    73b <printf+0x194>
      } else if(c == '%'){
 6f6:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 6fa:	75 17                	jne    713 <printf+0x16c>
        putc(fd, c);
 6fc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 6ff:	0f be c0             	movsbl %al,%eax
 702:	89 44 24 04          	mov    %eax,0x4(%esp)
 706:	8b 45 08             	mov    0x8(%ebp),%eax
 709:	89 04 24             	mov    %eax,(%esp)
 70c:	e8 bf fd ff ff       	call   4d0 <putc>
 711:	eb 28                	jmp    73b <printf+0x194>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 713:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 71a:	00 
 71b:	8b 45 08             	mov    0x8(%ebp),%eax
 71e:	89 04 24             	mov    %eax,(%esp)
 721:	e8 aa fd ff ff       	call   4d0 <putc>
        putc(fd, c);
 726:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 729:	0f be c0             	movsbl %al,%eax
 72c:	89 44 24 04          	mov    %eax,0x4(%esp)
 730:	8b 45 08             	mov    0x8(%ebp),%eax
 733:	89 04 24             	mov    %eax,(%esp)
 736:	e8 95 fd ff ff       	call   4d0 <putc>
      }
      state = 0;
 73b:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 742:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 746:	8b 55 0c             	mov    0xc(%ebp),%edx
 749:	8b 45 f0             	mov    -0x10(%ebp),%eax
 74c:	01 d0                	add    %edx,%eax
 74e:	0f b6 00             	movzbl (%eax),%eax
 751:	84 c0                	test   %al,%al
 753:	0f 85 70 fe ff ff    	jne    5c9 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 759:	c9                   	leave  
 75a:	c3                   	ret    
 75b:	90                   	nop

0000075c <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 75c:	55                   	push   %ebp
 75d:	89 e5                	mov    %esp,%ebp
 75f:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 762:	8b 45 08             	mov    0x8(%ebp),%eax
 765:	83 e8 08             	sub    $0x8,%eax
 768:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 76b:	a1 f0 0b 00 00       	mov    0xbf0,%eax
 770:	89 45 fc             	mov    %eax,-0x4(%ebp)
 773:	eb 24                	jmp    799 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 775:	8b 45 fc             	mov    -0x4(%ebp),%eax
 778:	8b 00                	mov    (%eax),%eax
 77a:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 77d:	77 12                	ja     791 <free+0x35>
 77f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 782:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 785:	77 24                	ja     7ab <free+0x4f>
 787:	8b 45 fc             	mov    -0x4(%ebp),%eax
 78a:	8b 00                	mov    (%eax),%eax
 78c:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 78f:	77 1a                	ja     7ab <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 791:	8b 45 fc             	mov    -0x4(%ebp),%eax
 794:	8b 00                	mov    (%eax),%eax
 796:	89 45 fc             	mov    %eax,-0x4(%ebp)
 799:	8b 45 f8             	mov    -0x8(%ebp),%eax
 79c:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 79f:	76 d4                	jbe    775 <free+0x19>
 7a1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7a4:	8b 00                	mov    (%eax),%eax
 7a6:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 7a9:	76 ca                	jbe    775 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 7ab:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7ae:	8b 40 04             	mov    0x4(%eax),%eax
 7b1:	c1 e0 03             	shl    $0x3,%eax
 7b4:	89 c2                	mov    %eax,%edx
 7b6:	03 55 f8             	add    -0x8(%ebp),%edx
 7b9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7bc:	8b 00                	mov    (%eax),%eax
 7be:	39 c2                	cmp    %eax,%edx
 7c0:	75 24                	jne    7e6 <free+0x8a>
    bp->s.size += p->s.ptr->s.size;
 7c2:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7c5:	8b 50 04             	mov    0x4(%eax),%edx
 7c8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7cb:	8b 00                	mov    (%eax),%eax
 7cd:	8b 40 04             	mov    0x4(%eax),%eax
 7d0:	01 c2                	add    %eax,%edx
 7d2:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7d5:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 7d8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7db:	8b 00                	mov    (%eax),%eax
 7dd:	8b 10                	mov    (%eax),%edx
 7df:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7e2:	89 10                	mov    %edx,(%eax)
 7e4:	eb 0a                	jmp    7f0 <free+0x94>
  } else
    bp->s.ptr = p->s.ptr;
 7e6:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7e9:	8b 10                	mov    (%eax),%edx
 7eb:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7ee:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 7f0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7f3:	8b 40 04             	mov    0x4(%eax),%eax
 7f6:	c1 e0 03             	shl    $0x3,%eax
 7f9:	03 45 fc             	add    -0x4(%ebp),%eax
 7fc:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 7ff:	75 20                	jne    821 <free+0xc5>
    p->s.size += bp->s.size;
 801:	8b 45 fc             	mov    -0x4(%ebp),%eax
 804:	8b 50 04             	mov    0x4(%eax),%edx
 807:	8b 45 f8             	mov    -0x8(%ebp),%eax
 80a:	8b 40 04             	mov    0x4(%eax),%eax
 80d:	01 c2                	add    %eax,%edx
 80f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 812:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 815:	8b 45 f8             	mov    -0x8(%ebp),%eax
 818:	8b 10                	mov    (%eax),%edx
 81a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 81d:	89 10                	mov    %edx,(%eax)
 81f:	eb 08                	jmp    829 <free+0xcd>
  } else
    p->s.ptr = bp;
 821:	8b 45 fc             	mov    -0x4(%ebp),%eax
 824:	8b 55 f8             	mov    -0x8(%ebp),%edx
 827:	89 10                	mov    %edx,(%eax)
  freep = p;
 829:	8b 45 fc             	mov    -0x4(%ebp),%eax
 82c:	a3 f0 0b 00 00       	mov    %eax,0xbf0
}
 831:	c9                   	leave  
 832:	c3                   	ret    

00000833 <morecore>:

static Header*
morecore(uint nu)
{
 833:	55                   	push   %ebp
 834:	89 e5                	mov    %esp,%ebp
 836:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 839:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 840:	77 07                	ja     849 <morecore+0x16>
    nu = 4096;
 842:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 849:	8b 45 08             	mov    0x8(%ebp),%eax
 84c:	c1 e0 03             	shl    $0x3,%eax
 84f:	89 04 24             	mov    %eax,(%esp)
 852:	e8 59 fc ff ff       	call   4b0 <sbrk>
 857:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 85a:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 85e:	75 07                	jne    867 <morecore+0x34>
    return 0;
 860:	b8 00 00 00 00       	mov    $0x0,%eax
 865:	eb 22                	jmp    889 <morecore+0x56>
  hp = (Header*)p;
 867:	8b 45 f4             	mov    -0xc(%ebp),%eax
 86a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 86d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 870:	8b 55 08             	mov    0x8(%ebp),%edx
 873:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 876:	8b 45 f0             	mov    -0x10(%ebp),%eax
 879:	83 c0 08             	add    $0x8,%eax
 87c:	89 04 24             	mov    %eax,(%esp)
 87f:	e8 d8 fe ff ff       	call   75c <free>
  return freep;
 884:	a1 f0 0b 00 00       	mov    0xbf0,%eax
}
 889:	c9                   	leave  
 88a:	c3                   	ret    

0000088b <malloc>:

void*
malloc(uint nbytes)
{
 88b:	55                   	push   %ebp
 88c:	89 e5                	mov    %esp,%ebp
 88e:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 891:	8b 45 08             	mov    0x8(%ebp),%eax
 894:	83 c0 07             	add    $0x7,%eax
 897:	c1 e8 03             	shr    $0x3,%eax
 89a:	83 c0 01             	add    $0x1,%eax
 89d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 8a0:	a1 f0 0b 00 00       	mov    0xbf0,%eax
 8a5:	89 45 f0             	mov    %eax,-0x10(%ebp)
 8a8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 8ac:	75 23                	jne    8d1 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 8ae:	c7 45 f0 e8 0b 00 00 	movl   $0xbe8,-0x10(%ebp)
 8b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8b8:	a3 f0 0b 00 00       	mov    %eax,0xbf0
 8bd:	a1 f0 0b 00 00       	mov    0xbf0,%eax
 8c2:	a3 e8 0b 00 00       	mov    %eax,0xbe8
    base.s.size = 0;
 8c7:	c7 05 ec 0b 00 00 00 	movl   $0x0,0xbec
 8ce:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8d4:	8b 00                	mov    (%eax),%eax
 8d6:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 8d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8dc:	8b 40 04             	mov    0x4(%eax),%eax
 8df:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 8e2:	72 4d                	jb     931 <malloc+0xa6>
      if(p->s.size == nunits)
 8e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8e7:	8b 40 04             	mov    0x4(%eax),%eax
 8ea:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 8ed:	75 0c                	jne    8fb <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 8ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8f2:	8b 10                	mov    (%eax),%edx
 8f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8f7:	89 10                	mov    %edx,(%eax)
 8f9:	eb 26                	jmp    921 <malloc+0x96>
      else {
        p->s.size -= nunits;
 8fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8fe:	8b 40 04             	mov    0x4(%eax),%eax
 901:	89 c2                	mov    %eax,%edx
 903:	2b 55 ec             	sub    -0x14(%ebp),%edx
 906:	8b 45 f4             	mov    -0xc(%ebp),%eax
 909:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 90c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 90f:	8b 40 04             	mov    0x4(%eax),%eax
 912:	c1 e0 03             	shl    $0x3,%eax
 915:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 918:	8b 45 f4             	mov    -0xc(%ebp),%eax
 91b:	8b 55 ec             	mov    -0x14(%ebp),%edx
 91e:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 921:	8b 45 f0             	mov    -0x10(%ebp),%eax
 924:	a3 f0 0b 00 00       	mov    %eax,0xbf0
      return (void*)(p + 1);
 929:	8b 45 f4             	mov    -0xc(%ebp),%eax
 92c:	83 c0 08             	add    $0x8,%eax
 92f:	eb 38                	jmp    969 <malloc+0xde>
    }
    if(p == freep)
 931:	a1 f0 0b 00 00       	mov    0xbf0,%eax
 936:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 939:	75 1b                	jne    956 <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 93b:	8b 45 ec             	mov    -0x14(%ebp),%eax
 93e:	89 04 24             	mov    %eax,(%esp)
 941:	e8 ed fe ff ff       	call   833 <morecore>
 946:	89 45 f4             	mov    %eax,-0xc(%ebp)
 949:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 94d:	75 07                	jne    956 <malloc+0xcb>
        return 0;
 94f:	b8 00 00 00 00       	mov    $0x0,%eax
 954:	eb 13                	jmp    969 <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 956:	8b 45 f4             	mov    -0xc(%ebp),%eax
 959:	89 45 f0             	mov    %eax,-0x10(%ebp)
 95c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 95f:	8b 00                	mov    (%eax),%eax
 961:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 964:	e9 70 ff ff ff       	jmp    8d9 <malloc+0x4e>
}
 969:	c9                   	leave  
 96a:	c3                   	ret    
