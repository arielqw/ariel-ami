
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
  2c:	c7 44 24 04 5b 09 00 	movl   $0x95b,0x4(%esp)
  33:	00 
  34:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  3b:	e8 57 05 00 00       	call   597 <printf>
  memset(data, 'a', sizeof(data));
  40:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  47:	00 
  48:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
  4f:	00 
  50:	8d 44 24 1e          	lea    0x1e(%esp),%eax
  54:	89 04 24             	mov    %eax,(%esp)
  57:	e8 1f 02 00 00       	call   27b <memset>

  for(i = 0; i < 4; i++)
  5c:	c7 84 24 2c 02 00 00 	movl   $0x0,0x22c(%esp)
  63:	00 00 00 00 
  67:	eb 11                	jmp    7a <main+0x7a>
    if(fork() > 0)
  69:	e8 aa 03 00 00       	call   418 <fork>
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
  92:	c7 44 24 04 6e 09 00 	movl   $0x96e,0x4(%esp)
  99:	00 
  9a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  a1:	e8 f1 04 00 00       	call   597 <printf>

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
  d2:	e8 89 03 00 00       	call   460 <open>
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
 105:	e8 36 03 00 00       	call   440 <write>

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
 126:	e8 1d 03 00 00       	call   448 <close>

  printf(1, "read\n");
 12b:	c7 44 24 04 78 09 00 	movl   $0x978,0x4(%esp)
 132:	00 
 133:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 13a:	e8 58 04 00 00       	call   597 <printf>

  fd = open(path, O_RDONLY);
 13f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 146:	00 
 147:	8d 84 24 1e 02 00 00 	lea    0x21e(%esp),%eax
 14e:	89 04 24             	mov    %eax,(%esp)
 151:	e8 0a 03 00 00       	call   460 <open>
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
 184:	e8 af 02 00 00       	call   438 <read>
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
 1a5:	e8 9e 02 00 00       	call   448 <close>

  wait();
 1aa:	e8 79 02 00 00       	call   428 <wait>
  
  exit(EXIT_STATUS_DEFAULT);
 1af:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
 1b6:	e8 65 02 00 00       	call   420 <exit>
 1bb:	90                   	nop

000001bc <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 1bc:	55                   	push   %ebp
 1bd:	89 e5                	mov    %esp,%ebp
 1bf:	57                   	push   %edi
 1c0:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 1c1:	8b 4d 08             	mov    0x8(%ebp),%ecx
 1c4:	8b 55 10             	mov    0x10(%ebp),%edx
 1c7:	8b 45 0c             	mov    0xc(%ebp),%eax
 1ca:	89 cb                	mov    %ecx,%ebx
 1cc:	89 df                	mov    %ebx,%edi
 1ce:	89 d1                	mov    %edx,%ecx
 1d0:	fc                   	cld    
 1d1:	f3 aa                	rep stos %al,%es:(%edi)
 1d3:	89 ca                	mov    %ecx,%edx
 1d5:	89 fb                	mov    %edi,%ebx
 1d7:	89 5d 08             	mov    %ebx,0x8(%ebp)
 1da:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 1dd:	5b                   	pop    %ebx
 1de:	5f                   	pop    %edi
 1df:	5d                   	pop    %ebp
 1e0:	c3                   	ret    

000001e1 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 1e1:	55                   	push   %ebp
 1e2:	89 e5                	mov    %esp,%ebp
 1e4:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 1e7:	8b 45 08             	mov    0x8(%ebp),%eax
 1ea:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 1ed:	90                   	nop
 1ee:	8b 45 0c             	mov    0xc(%ebp),%eax
 1f1:	0f b6 10             	movzbl (%eax),%edx
 1f4:	8b 45 08             	mov    0x8(%ebp),%eax
 1f7:	88 10                	mov    %dl,(%eax)
 1f9:	8b 45 08             	mov    0x8(%ebp),%eax
 1fc:	0f b6 00             	movzbl (%eax),%eax
 1ff:	84 c0                	test   %al,%al
 201:	0f 95 c0             	setne  %al
 204:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 208:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 20c:	84 c0                	test   %al,%al
 20e:	75 de                	jne    1ee <strcpy+0xd>
    ;
  return os;
 210:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 213:	c9                   	leave  
 214:	c3                   	ret    

00000215 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 215:	55                   	push   %ebp
 216:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 218:	eb 08                	jmp    222 <strcmp+0xd>
    p++, q++;
 21a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 21e:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 222:	8b 45 08             	mov    0x8(%ebp),%eax
 225:	0f b6 00             	movzbl (%eax),%eax
 228:	84 c0                	test   %al,%al
 22a:	74 10                	je     23c <strcmp+0x27>
 22c:	8b 45 08             	mov    0x8(%ebp),%eax
 22f:	0f b6 10             	movzbl (%eax),%edx
 232:	8b 45 0c             	mov    0xc(%ebp),%eax
 235:	0f b6 00             	movzbl (%eax),%eax
 238:	38 c2                	cmp    %al,%dl
 23a:	74 de                	je     21a <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 23c:	8b 45 08             	mov    0x8(%ebp),%eax
 23f:	0f b6 00             	movzbl (%eax),%eax
 242:	0f b6 d0             	movzbl %al,%edx
 245:	8b 45 0c             	mov    0xc(%ebp),%eax
 248:	0f b6 00             	movzbl (%eax),%eax
 24b:	0f b6 c0             	movzbl %al,%eax
 24e:	89 d1                	mov    %edx,%ecx
 250:	29 c1                	sub    %eax,%ecx
 252:	89 c8                	mov    %ecx,%eax
}
 254:	5d                   	pop    %ebp
 255:	c3                   	ret    

00000256 <strlen>:

uint
strlen(char *s)
{
 256:	55                   	push   %ebp
 257:	89 e5                	mov    %esp,%ebp
 259:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 25c:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 263:	eb 04                	jmp    269 <strlen+0x13>
 265:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 269:	8b 45 fc             	mov    -0x4(%ebp),%eax
 26c:	03 45 08             	add    0x8(%ebp),%eax
 26f:	0f b6 00             	movzbl (%eax),%eax
 272:	84 c0                	test   %al,%al
 274:	75 ef                	jne    265 <strlen+0xf>
    ;
  return n;
 276:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 279:	c9                   	leave  
 27a:	c3                   	ret    

0000027b <memset>:

void*
memset(void *dst, int c, uint n)
{
 27b:	55                   	push   %ebp
 27c:	89 e5                	mov    %esp,%ebp
 27e:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 281:	8b 45 10             	mov    0x10(%ebp),%eax
 284:	89 44 24 08          	mov    %eax,0x8(%esp)
 288:	8b 45 0c             	mov    0xc(%ebp),%eax
 28b:	89 44 24 04          	mov    %eax,0x4(%esp)
 28f:	8b 45 08             	mov    0x8(%ebp),%eax
 292:	89 04 24             	mov    %eax,(%esp)
 295:	e8 22 ff ff ff       	call   1bc <stosb>
  return dst;
 29a:	8b 45 08             	mov    0x8(%ebp),%eax
}
 29d:	c9                   	leave  
 29e:	c3                   	ret    

0000029f <strchr>:

char*
strchr(const char *s, char c)
{
 29f:	55                   	push   %ebp
 2a0:	89 e5                	mov    %esp,%ebp
 2a2:	83 ec 04             	sub    $0x4,%esp
 2a5:	8b 45 0c             	mov    0xc(%ebp),%eax
 2a8:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 2ab:	eb 14                	jmp    2c1 <strchr+0x22>
    if(*s == c)
 2ad:	8b 45 08             	mov    0x8(%ebp),%eax
 2b0:	0f b6 00             	movzbl (%eax),%eax
 2b3:	3a 45 fc             	cmp    -0x4(%ebp),%al
 2b6:	75 05                	jne    2bd <strchr+0x1e>
      return (char*)s;
 2b8:	8b 45 08             	mov    0x8(%ebp),%eax
 2bb:	eb 13                	jmp    2d0 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 2bd:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 2c1:	8b 45 08             	mov    0x8(%ebp),%eax
 2c4:	0f b6 00             	movzbl (%eax),%eax
 2c7:	84 c0                	test   %al,%al
 2c9:	75 e2                	jne    2ad <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 2cb:	b8 00 00 00 00       	mov    $0x0,%eax
}
 2d0:	c9                   	leave  
 2d1:	c3                   	ret    

000002d2 <gets>:

char*
gets(char *buf, int max)
{
 2d2:	55                   	push   %ebp
 2d3:	89 e5                	mov    %esp,%ebp
 2d5:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 2d8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 2df:	eb 44                	jmp    325 <gets+0x53>
    cc = read(0, &c, 1);
 2e1:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 2e8:	00 
 2e9:	8d 45 ef             	lea    -0x11(%ebp),%eax
 2ec:	89 44 24 04          	mov    %eax,0x4(%esp)
 2f0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 2f7:	e8 3c 01 00 00       	call   438 <read>
 2fc:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 2ff:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 303:	7e 2d                	jle    332 <gets+0x60>
      break;
    buf[i++] = c;
 305:	8b 45 f4             	mov    -0xc(%ebp),%eax
 308:	03 45 08             	add    0x8(%ebp),%eax
 30b:	0f b6 55 ef          	movzbl -0x11(%ebp),%edx
 30f:	88 10                	mov    %dl,(%eax)
 311:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(c == '\n' || c == '\r')
 315:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 319:	3c 0a                	cmp    $0xa,%al
 31b:	74 16                	je     333 <gets+0x61>
 31d:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 321:	3c 0d                	cmp    $0xd,%al
 323:	74 0e                	je     333 <gets+0x61>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 325:	8b 45 f4             	mov    -0xc(%ebp),%eax
 328:	83 c0 01             	add    $0x1,%eax
 32b:	3b 45 0c             	cmp    0xc(%ebp),%eax
 32e:	7c b1                	jl     2e1 <gets+0xf>
 330:	eb 01                	jmp    333 <gets+0x61>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 332:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 333:	8b 45 f4             	mov    -0xc(%ebp),%eax
 336:	03 45 08             	add    0x8(%ebp),%eax
 339:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 33c:	8b 45 08             	mov    0x8(%ebp),%eax
}
 33f:	c9                   	leave  
 340:	c3                   	ret    

00000341 <stat>:

int
stat(char *n, struct stat *st)
{
 341:	55                   	push   %ebp
 342:	89 e5                	mov    %esp,%ebp
 344:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 347:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 34e:	00 
 34f:	8b 45 08             	mov    0x8(%ebp),%eax
 352:	89 04 24             	mov    %eax,(%esp)
 355:	e8 06 01 00 00       	call   460 <open>
 35a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 35d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 361:	79 07                	jns    36a <stat+0x29>
    return -1;
 363:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 368:	eb 23                	jmp    38d <stat+0x4c>
  r = fstat(fd, st);
 36a:	8b 45 0c             	mov    0xc(%ebp),%eax
 36d:	89 44 24 04          	mov    %eax,0x4(%esp)
 371:	8b 45 f4             	mov    -0xc(%ebp),%eax
 374:	89 04 24             	mov    %eax,(%esp)
 377:	e8 fc 00 00 00       	call   478 <fstat>
 37c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 37f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 382:	89 04 24             	mov    %eax,(%esp)
 385:	e8 be 00 00 00       	call   448 <close>
  return r;
 38a:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 38d:	c9                   	leave  
 38e:	c3                   	ret    

0000038f <atoi>:

int
atoi(const char *s)
{
 38f:	55                   	push   %ebp
 390:	89 e5                	mov    %esp,%ebp
 392:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 395:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 39c:	eb 23                	jmp    3c1 <atoi+0x32>
    n = n*10 + *s++ - '0';
 39e:	8b 55 fc             	mov    -0x4(%ebp),%edx
 3a1:	89 d0                	mov    %edx,%eax
 3a3:	c1 e0 02             	shl    $0x2,%eax
 3a6:	01 d0                	add    %edx,%eax
 3a8:	01 c0                	add    %eax,%eax
 3aa:	89 c2                	mov    %eax,%edx
 3ac:	8b 45 08             	mov    0x8(%ebp),%eax
 3af:	0f b6 00             	movzbl (%eax),%eax
 3b2:	0f be c0             	movsbl %al,%eax
 3b5:	01 d0                	add    %edx,%eax
 3b7:	83 e8 30             	sub    $0x30,%eax
 3ba:	89 45 fc             	mov    %eax,-0x4(%ebp)
 3bd:	83 45 08 01          	addl   $0x1,0x8(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 3c1:	8b 45 08             	mov    0x8(%ebp),%eax
 3c4:	0f b6 00             	movzbl (%eax),%eax
 3c7:	3c 2f                	cmp    $0x2f,%al
 3c9:	7e 0a                	jle    3d5 <atoi+0x46>
 3cb:	8b 45 08             	mov    0x8(%ebp),%eax
 3ce:	0f b6 00             	movzbl (%eax),%eax
 3d1:	3c 39                	cmp    $0x39,%al
 3d3:	7e c9                	jle    39e <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 3d5:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 3d8:	c9                   	leave  
 3d9:	c3                   	ret    

000003da <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 3da:	55                   	push   %ebp
 3db:	89 e5                	mov    %esp,%ebp
 3dd:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 3e0:	8b 45 08             	mov    0x8(%ebp),%eax
 3e3:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 3e6:	8b 45 0c             	mov    0xc(%ebp),%eax
 3e9:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 3ec:	eb 13                	jmp    401 <memmove+0x27>
    *dst++ = *src++;
 3ee:	8b 45 f8             	mov    -0x8(%ebp),%eax
 3f1:	0f b6 10             	movzbl (%eax),%edx
 3f4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 3f7:	88 10                	mov    %dl,(%eax)
 3f9:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 3fd:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 401:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 405:	0f 9f c0             	setg   %al
 408:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 40c:	84 c0                	test   %al,%al
 40e:	75 de                	jne    3ee <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 410:	8b 45 08             	mov    0x8(%ebp),%eax
}
 413:	c9                   	leave  
 414:	c3                   	ret    
 415:	90                   	nop
 416:	90                   	nop
 417:	90                   	nop

00000418 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 418:	b8 01 00 00 00       	mov    $0x1,%eax
 41d:	cd 40                	int    $0x40
 41f:	c3                   	ret    

00000420 <exit>:
SYSCALL(exit)
 420:	b8 02 00 00 00       	mov    $0x2,%eax
 425:	cd 40                	int    $0x40
 427:	c3                   	ret    

00000428 <wait>:
SYSCALL(wait)
 428:	b8 03 00 00 00       	mov    $0x3,%eax
 42d:	cd 40                	int    $0x40
 42f:	c3                   	ret    

00000430 <pipe>:
SYSCALL(pipe)
 430:	b8 04 00 00 00       	mov    $0x4,%eax
 435:	cd 40                	int    $0x40
 437:	c3                   	ret    

00000438 <read>:
SYSCALL(read)
 438:	b8 05 00 00 00       	mov    $0x5,%eax
 43d:	cd 40                	int    $0x40
 43f:	c3                   	ret    

00000440 <write>:
SYSCALL(write)
 440:	b8 10 00 00 00       	mov    $0x10,%eax
 445:	cd 40                	int    $0x40
 447:	c3                   	ret    

00000448 <close>:
SYSCALL(close)
 448:	b8 15 00 00 00       	mov    $0x15,%eax
 44d:	cd 40                	int    $0x40
 44f:	c3                   	ret    

00000450 <kill>:
SYSCALL(kill)
 450:	b8 06 00 00 00       	mov    $0x6,%eax
 455:	cd 40                	int    $0x40
 457:	c3                   	ret    

00000458 <exec>:
SYSCALL(exec)
 458:	b8 07 00 00 00       	mov    $0x7,%eax
 45d:	cd 40                	int    $0x40
 45f:	c3                   	ret    

00000460 <open>:
SYSCALL(open)
 460:	b8 0f 00 00 00       	mov    $0xf,%eax
 465:	cd 40                	int    $0x40
 467:	c3                   	ret    

00000468 <mknod>:
SYSCALL(mknod)
 468:	b8 11 00 00 00       	mov    $0x11,%eax
 46d:	cd 40                	int    $0x40
 46f:	c3                   	ret    

00000470 <unlink>:
SYSCALL(unlink)
 470:	b8 12 00 00 00       	mov    $0x12,%eax
 475:	cd 40                	int    $0x40
 477:	c3                   	ret    

00000478 <fstat>:
SYSCALL(fstat)
 478:	b8 08 00 00 00       	mov    $0x8,%eax
 47d:	cd 40                	int    $0x40
 47f:	c3                   	ret    

00000480 <link>:
SYSCALL(link)
 480:	b8 13 00 00 00       	mov    $0x13,%eax
 485:	cd 40                	int    $0x40
 487:	c3                   	ret    

00000488 <mkdir>:
SYSCALL(mkdir)
 488:	b8 14 00 00 00       	mov    $0x14,%eax
 48d:	cd 40                	int    $0x40
 48f:	c3                   	ret    

00000490 <chdir>:
SYSCALL(chdir)
 490:	b8 09 00 00 00       	mov    $0x9,%eax
 495:	cd 40                	int    $0x40
 497:	c3                   	ret    

00000498 <dup>:
SYSCALL(dup)
 498:	b8 0a 00 00 00       	mov    $0xa,%eax
 49d:	cd 40                	int    $0x40
 49f:	c3                   	ret    

000004a0 <getpid>:
SYSCALL(getpid)
 4a0:	b8 0b 00 00 00       	mov    $0xb,%eax
 4a5:	cd 40                	int    $0x40
 4a7:	c3                   	ret    

000004a8 <sbrk>:
SYSCALL(sbrk)
 4a8:	b8 0c 00 00 00       	mov    $0xc,%eax
 4ad:	cd 40                	int    $0x40
 4af:	c3                   	ret    

000004b0 <sleep>:
SYSCALL(sleep)
 4b0:	b8 0d 00 00 00       	mov    $0xd,%eax
 4b5:	cd 40                	int    $0x40
 4b7:	c3                   	ret    

000004b8 <uptime>:
SYSCALL(uptime)
 4b8:	b8 0e 00 00 00       	mov    $0xe,%eax
 4bd:	cd 40                	int    $0x40
 4bf:	c3                   	ret    

000004c0 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 4c0:	55                   	push   %ebp
 4c1:	89 e5                	mov    %esp,%ebp
 4c3:	83 ec 28             	sub    $0x28,%esp
 4c6:	8b 45 0c             	mov    0xc(%ebp),%eax
 4c9:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 4cc:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 4d3:	00 
 4d4:	8d 45 f4             	lea    -0xc(%ebp),%eax
 4d7:	89 44 24 04          	mov    %eax,0x4(%esp)
 4db:	8b 45 08             	mov    0x8(%ebp),%eax
 4de:	89 04 24             	mov    %eax,(%esp)
 4e1:	e8 5a ff ff ff       	call   440 <write>
}
 4e6:	c9                   	leave  
 4e7:	c3                   	ret    

000004e8 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 4e8:	55                   	push   %ebp
 4e9:	89 e5                	mov    %esp,%ebp
 4eb:	83 ec 48             	sub    $0x48,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 4ee:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 4f5:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 4f9:	74 17                	je     512 <printint+0x2a>
 4fb:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 4ff:	79 11                	jns    512 <printint+0x2a>
    neg = 1;
 501:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 508:	8b 45 0c             	mov    0xc(%ebp),%eax
 50b:	f7 d8                	neg    %eax
 50d:	89 45 ec             	mov    %eax,-0x14(%ebp)
 510:	eb 06                	jmp    518 <printint+0x30>
  } else {
    x = xx;
 512:	8b 45 0c             	mov    0xc(%ebp),%eax
 515:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 518:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 51f:	8b 4d 10             	mov    0x10(%ebp),%ecx
 522:	8b 45 ec             	mov    -0x14(%ebp),%eax
 525:	ba 00 00 00 00       	mov    $0x0,%edx
 52a:	f7 f1                	div    %ecx
 52c:	89 d0                	mov    %edx,%eax
 52e:	0f b6 90 c4 0b 00 00 	movzbl 0xbc4(%eax),%edx
 535:	8d 45 dc             	lea    -0x24(%ebp),%eax
 538:	03 45 f4             	add    -0xc(%ebp),%eax
 53b:	88 10                	mov    %dl,(%eax)
 53d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  }while((x /= base) != 0);
 541:	8b 55 10             	mov    0x10(%ebp),%edx
 544:	89 55 d4             	mov    %edx,-0x2c(%ebp)
 547:	8b 45 ec             	mov    -0x14(%ebp),%eax
 54a:	ba 00 00 00 00       	mov    $0x0,%edx
 54f:	f7 75 d4             	divl   -0x2c(%ebp)
 552:	89 45 ec             	mov    %eax,-0x14(%ebp)
 555:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 559:	75 c4                	jne    51f <printint+0x37>
  if(neg)
 55b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 55f:	74 2a                	je     58b <printint+0xa3>
    buf[i++] = '-';
 561:	8d 45 dc             	lea    -0x24(%ebp),%eax
 564:	03 45 f4             	add    -0xc(%ebp),%eax
 567:	c6 00 2d             	movb   $0x2d,(%eax)
 56a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

  while(--i >= 0)
 56e:	eb 1b                	jmp    58b <printint+0xa3>
    putc(fd, buf[i]);
 570:	8d 45 dc             	lea    -0x24(%ebp),%eax
 573:	03 45 f4             	add    -0xc(%ebp),%eax
 576:	0f b6 00             	movzbl (%eax),%eax
 579:	0f be c0             	movsbl %al,%eax
 57c:	89 44 24 04          	mov    %eax,0x4(%esp)
 580:	8b 45 08             	mov    0x8(%ebp),%eax
 583:	89 04 24             	mov    %eax,(%esp)
 586:	e8 35 ff ff ff       	call   4c0 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 58b:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 58f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 593:	79 db                	jns    570 <printint+0x88>
    putc(fd, buf[i]);
}
 595:	c9                   	leave  
 596:	c3                   	ret    

00000597 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 597:	55                   	push   %ebp
 598:	89 e5                	mov    %esp,%ebp
 59a:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 59d:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 5a4:	8d 45 0c             	lea    0xc(%ebp),%eax
 5a7:	83 c0 04             	add    $0x4,%eax
 5aa:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 5ad:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 5b4:	e9 7d 01 00 00       	jmp    736 <printf+0x19f>
    c = fmt[i] & 0xff;
 5b9:	8b 55 0c             	mov    0xc(%ebp),%edx
 5bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
 5bf:	01 d0                	add    %edx,%eax
 5c1:	0f b6 00             	movzbl (%eax),%eax
 5c4:	0f be c0             	movsbl %al,%eax
 5c7:	25 ff 00 00 00       	and    $0xff,%eax
 5cc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 5cf:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 5d3:	75 2c                	jne    601 <printf+0x6a>
      if(c == '%'){
 5d5:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 5d9:	75 0c                	jne    5e7 <printf+0x50>
        state = '%';
 5db:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 5e2:	e9 4b 01 00 00       	jmp    732 <printf+0x19b>
      } else {
        putc(fd, c);
 5e7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 5ea:	0f be c0             	movsbl %al,%eax
 5ed:	89 44 24 04          	mov    %eax,0x4(%esp)
 5f1:	8b 45 08             	mov    0x8(%ebp),%eax
 5f4:	89 04 24             	mov    %eax,(%esp)
 5f7:	e8 c4 fe ff ff       	call   4c0 <putc>
 5fc:	e9 31 01 00 00       	jmp    732 <printf+0x19b>
      }
    } else if(state == '%'){
 601:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 605:	0f 85 27 01 00 00    	jne    732 <printf+0x19b>
      if(c == 'd'){
 60b:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 60f:	75 2d                	jne    63e <printf+0xa7>
        printint(fd, *ap, 10, 1);
 611:	8b 45 e8             	mov    -0x18(%ebp),%eax
 614:	8b 00                	mov    (%eax),%eax
 616:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 61d:	00 
 61e:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 625:	00 
 626:	89 44 24 04          	mov    %eax,0x4(%esp)
 62a:	8b 45 08             	mov    0x8(%ebp),%eax
 62d:	89 04 24             	mov    %eax,(%esp)
 630:	e8 b3 fe ff ff       	call   4e8 <printint>
        ap++;
 635:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 639:	e9 ed 00 00 00       	jmp    72b <printf+0x194>
      } else if(c == 'x' || c == 'p'){
 63e:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 642:	74 06                	je     64a <printf+0xb3>
 644:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 648:	75 2d                	jne    677 <printf+0xe0>
        printint(fd, *ap, 16, 0);
 64a:	8b 45 e8             	mov    -0x18(%ebp),%eax
 64d:	8b 00                	mov    (%eax),%eax
 64f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 656:	00 
 657:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 65e:	00 
 65f:	89 44 24 04          	mov    %eax,0x4(%esp)
 663:	8b 45 08             	mov    0x8(%ebp),%eax
 666:	89 04 24             	mov    %eax,(%esp)
 669:	e8 7a fe ff ff       	call   4e8 <printint>
        ap++;
 66e:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 672:	e9 b4 00 00 00       	jmp    72b <printf+0x194>
      } else if(c == 's'){
 677:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 67b:	75 46                	jne    6c3 <printf+0x12c>
        s = (char*)*ap;
 67d:	8b 45 e8             	mov    -0x18(%ebp),%eax
 680:	8b 00                	mov    (%eax),%eax
 682:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 685:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 689:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 68d:	75 27                	jne    6b6 <printf+0x11f>
          s = "(null)";
 68f:	c7 45 f4 7e 09 00 00 	movl   $0x97e,-0xc(%ebp)
        while(*s != 0){
 696:	eb 1e                	jmp    6b6 <printf+0x11f>
          putc(fd, *s);
 698:	8b 45 f4             	mov    -0xc(%ebp),%eax
 69b:	0f b6 00             	movzbl (%eax),%eax
 69e:	0f be c0             	movsbl %al,%eax
 6a1:	89 44 24 04          	mov    %eax,0x4(%esp)
 6a5:	8b 45 08             	mov    0x8(%ebp),%eax
 6a8:	89 04 24             	mov    %eax,(%esp)
 6ab:	e8 10 fe ff ff       	call   4c0 <putc>
          s++;
 6b0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 6b4:	eb 01                	jmp    6b7 <printf+0x120>
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 6b6:	90                   	nop
 6b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6ba:	0f b6 00             	movzbl (%eax),%eax
 6bd:	84 c0                	test   %al,%al
 6bf:	75 d7                	jne    698 <printf+0x101>
 6c1:	eb 68                	jmp    72b <printf+0x194>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 6c3:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 6c7:	75 1d                	jne    6e6 <printf+0x14f>
        putc(fd, *ap);
 6c9:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6cc:	8b 00                	mov    (%eax),%eax
 6ce:	0f be c0             	movsbl %al,%eax
 6d1:	89 44 24 04          	mov    %eax,0x4(%esp)
 6d5:	8b 45 08             	mov    0x8(%ebp),%eax
 6d8:	89 04 24             	mov    %eax,(%esp)
 6db:	e8 e0 fd ff ff       	call   4c0 <putc>
        ap++;
 6e0:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 6e4:	eb 45                	jmp    72b <printf+0x194>
      } else if(c == '%'){
 6e6:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 6ea:	75 17                	jne    703 <printf+0x16c>
        putc(fd, c);
 6ec:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 6ef:	0f be c0             	movsbl %al,%eax
 6f2:	89 44 24 04          	mov    %eax,0x4(%esp)
 6f6:	8b 45 08             	mov    0x8(%ebp),%eax
 6f9:	89 04 24             	mov    %eax,(%esp)
 6fc:	e8 bf fd ff ff       	call   4c0 <putc>
 701:	eb 28                	jmp    72b <printf+0x194>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 703:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 70a:	00 
 70b:	8b 45 08             	mov    0x8(%ebp),%eax
 70e:	89 04 24             	mov    %eax,(%esp)
 711:	e8 aa fd ff ff       	call   4c0 <putc>
        putc(fd, c);
 716:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 719:	0f be c0             	movsbl %al,%eax
 71c:	89 44 24 04          	mov    %eax,0x4(%esp)
 720:	8b 45 08             	mov    0x8(%ebp),%eax
 723:	89 04 24             	mov    %eax,(%esp)
 726:	e8 95 fd ff ff       	call   4c0 <putc>
      }
      state = 0;
 72b:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 732:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 736:	8b 55 0c             	mov    0xc(%ebp),%edx
 739:	8b 45 f0             	mov    -0x10(%ebp),%eax
 73c:	01 d0                	add    %edx,%eax
 73e:	0f b6 00             	movzbl (%eax),%eax
 741:	84 c0                	test   %al,%al
 743:	0f 85 70 fe ff ff    	jne    5b9 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 749:	c9                   	leave  
 74a:	c3                   	ret    
 74b:	90                   	nop

0000074c <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 74c:	55                   	push   %ebp
 74d:	89 e5                	mov    %esp,%ebp
 74f:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 752:	8b 45 08             	mov    0x8(%ebp),%eax
 755:	83 e8 08             	sub    $0x8,%eax
 758:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 75b:	a1 e0 0b 00 00       	mov    0xbe0,%eax
 760:	89 45 fc             	mov    %eax,-0x4(%ebp)
 763:	eb 24                	jmp    789 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 765:	8b 45 fc             	mov    -0x4(%ebp),%eax
 768:	8b 00                	mov    (%eax),%eax
 76a:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 76d:	77 12                	ja     781 <free+0x35>
 76f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 772:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 775:	77 24                	ja     79b <free+0x4f>
 777:	8b 45 fc             	mov    -0x4(%ebp),%eax
 77a:	8b 00                	mov    (%eax),%eax
 77c:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 77f:	77 1a                	ja     79b <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 781:	8b 45 fc             	mov    -0x4(%ebp),%eax
 784:	8b 00                	mov    (%eax),%eax
 786:	89 45 fc             	mov    %eax,-0x4(%ebp)
 789:	8b 45 f8             	mov    -0x8(%ebp),%eax
 78c:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 78f:	76 d4                	jbe    765 <free+0x19>
 791:	8b 45 fc             	mov    -0x4(%ebp),%eax
 794:	8b 00                	mov    (%eax),%eax
 796:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 799:	76 ca                	jbe    765 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 79b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 79e:	8b 40 04             	mov    0x4(%eax),%eax
 7a1:	c1 e0 03             	shl    $0x3,%eax
 7a4:	89 c2                	mov    %eax,%edx
 7a6:	03 55 f8             	add    -0x8(%ebp),%edx
 7a9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7ac:	8b 00                	mov    (%eax),%eax
 7ae:	39 c2                	cmp    %eax,%edx
 7b0:	75 24                	jne    7d6 <free+0x8a>
    bp->s.size += p->s.ptr->s.size;
 7b2:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7b5:	8b 50 04             	mov    0x4(%eax),%edx
 7b8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7bb:	8b 00                	mov    (%eax),%eax
 7bd:	8b 40 04             	mov    0x4(%eax),%eax
 7c0:	01 c2                	add    %eax,%edx
 7c2:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7c5:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 7c8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7cb:	8b 00                	mov    (%eax),%eax
 7cd:	8b 10                	mov    (%eax),%edx
 7cf:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7d2:	89 10                	mov    %edx,(%eax)
 7d4:	eb 0a                	jmp    7e0 <free+0x94>
  } else
    bp->s.ptr = p->s.ptr;
 7d6:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7d9:	8b 10                	mov    (%eax),%edx
 7db:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7de:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 7e0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7e3:	8b 40 04             	mov    0x4(%eax),%eax
 7e6:	c1 e0 03             	shl    $0x3,%eax
 7e9:	03 45 fc             	add    -0x4(%ebp),%eax
 7ec:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 7ef:	75 20                	jne    811 <free+0xc5>
    p->s.size += bp->s.size;
 7f1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7f4:	8b 50 04             	mov    0x4(%eax),%edx
 7f7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7fa:	8b 40 04             	mov    0x4(%eax),%eax
 7fd:	01 c2                	add    %eax,%edx
 7ff:	8b 45 fc             	mov    -0x4(%ebp),%eax
 802:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 805:	8b 45 f8             	mov    -0x8(%ebp),%eax
 808:	8b 10                	mov    (%eax),%edx
 80a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 80d:	89 10                	mov    %edx,(%eax)
 80f:	eb 08                	jmp    819 <free+0xcd>
  } else
    p->s.ptr = bp;
 811:	8b 45 fc             	mov    -0x4(%ebp),%eax
 814:	8b 55 f8             	mov    -0x8(%ebp),%edx
 817:	89 10                	mov    %edx,(%eax)
  freep = p;
 819:	8b 45 fc             	mov    -0x4(%ebp),%eax
 81c:	a3 e0 0b 00 00       	mov    %eax,0xbe0
}
 821:	c9                   	leave  
 822:	c3                   	ret    

00000823 <morecore>:

static Header*
morecore(uint nu)
{
 823:	55                   	push   %ebp
 824:	89 e5                	mov    %esp,%ebp
 826:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 829:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 830:	77 07                	ja     839 <morecore+0x16>
    nu = 4096;
 832:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 839:	8b 45 08             	mov    0x8(%ebp),%eax
 83c:	c1 e0 03             	shl    $0x3,%eax
 83f:	89 04 24             	mov    %eax,(%esp)
 842:	e8 61 fc ff ff       	call   4a8 <sbrk>
 847:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 84a:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 84e:	75 07                	jne    857 <morecore+0x34>
    return 0;
 850:	b8 00 00 00 00       	mov    $0x0,%eax
 855:	eb 22                	jmp    879 <morecore+0x56>
  hp = (Header*)p;
 857:	8b 45 f4             	mov    -0xc(%ebp),%eax
 85a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 85d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 860:	8b 55 08             	mov    0x8(%ebp),%edx
 863:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 866:	8b 45 f0             	mov    -0x10(%ebp),%eax
 869:	83 c0 08             	add    $0x8,%eax
 86c:	89 04 24             	mov    %eax,(%esp)
 86f:	e8 d8 fe ff ff       	call   74c <free>
  return freep;
 874:	a1 e0 0b 00 00       	mov    0xbe0,%eax
}
 879:	c9                   	leave  
 87a:	c3                   	ret    

0000087b <malloc>:

void*
malloc(uint nbytes)
{
 87b:	55                   	push   %ebp
 87c:	89 e5                	mov    %esp,%ebp
 87e:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 881:	8b 45 08             	mov    0x8(%ebp),%eax
 884:	83 c0 07             	add    $0x7,%eax
 887:	c1 e8 03             	shr    $0x3,%eax
 88a:	83 c0 01             	add    $0x1,%eax
 88d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 890:	a1 e0 0b 00 00       	mov    0xbe0,%eax
 895:	89 45 f0             	mov    %eax,-0x10(%ebp)
 898:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 89c:	75 23                	jne    8c1 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 89e:	c7 45 f0 d8 0b 00 00 	movl   $0xbd8,-0x10(%ebp)
 8a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8a8:	a3 e0 0b 00 00       	mov    %eax,0xbe0
 8ad:	a1 e0 0b 00 00       	mov    0xbe0,%eax
 8b2:	a3 d8 0b 00 00       	mov    %eax,0xbd8
    base.s.size = 0;
 8b7:	c7 05 dc 0b 00 00 00 	movl   $0x0,0xbdc
 8be:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8c4:	8b 00                	mov    (%eax),%eax
 8c6:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 8c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8cc:	8b 40 04             	mov    0x4(%eax),%eax
 8cf:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 8d2:	72 4d                	jb     921 <malloc+0xa6>
      if(p->s.size == nunits)
 8d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8d7:	8b 40 04             	mov    0x4(%eax),%eax
 8da:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 8dd:	75 0c                	jne    8eb <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 8df:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8e2:	8b 10                	mov    (%eax),%edx
 8e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8e7:	89 10                	mov    %edx,(%eax)
 8e9:	eb 26                	jmp    911 <malloc+0x96>
      else {
        p->s.size -= nunits;
 8eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8ee:	8b 40 04             	mov    0x4(%eax),%eax
 8f1:	89 c2                	mov    %eax,%edx
 8f3:	2b 55 ec             	sub    -0x14(%ebp),%edx
 8f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8f9:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 8fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8ff:	8b 40 04             	mov    0x4(%eax),%eax
 902:	c1 e0 03             	shl    $0x3,%eax
 905:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 908:	8b 45 f4             	mov    -0xc(%ebp),%eax
 90b:	8b 55 ec             	mov    -0x14(%ebp),%edx
 90e:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 911:	8b 45 f0             	mov    -0x10(%ebp),%eax
 914:	a3 e0 0b 00 00       	mov    %eax,0xbe0
      return (void*)(p + 1);
 919:	8b 45 f4             	mov    -0xc(%ebp),%eax
 91c:	83 c0 08             	add    $0x8,%eax
 91f:	eb 38                	jmp    959 <malloc+0xde>
    }
    if(p == freep)
 921:	a1 e0 0b 00 00       	mov    0xbe0,%eax
 926:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 929:	75 1b                	jne    946 <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 92b:	8b 45 ec             	mov    -0x14(%ebp),%eax
 92e:	89 04 24             	mov    %eax,(%esp)
 931:	e8 ed fe ff ff       	call   823 <morecore>
 936:	89 45 f4             	mov    %eax,-0xc(%ebp)
 939:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 93d:	75 07                	jne    946 <malloc+0xcb>
        return 0;
 93f:	b8 00 00 00 00       	mov    $0x0,%eax
 944:	eb 13                	jmp    959 <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 946:	8b 45 f4             	mov    -0xc(%ebp),%eax
 949:	89 45 f0             	mov    %eax,-0x10(%ebp)
 94c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 94f:	8b 00                	mov    (%eax),%eax
 951:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 954:	e9 70 ff ff ff       	jmp    8c9 <malloc+0x4e>
}
 959:	c9                   	leave  
 95a:	c3                   	ret    
