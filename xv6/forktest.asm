
_forktest:     file format elf32-i386


Disassembly of section .text:

00000000 <printf>:

#define N  1000

void
printf(int fd, char *s, ...)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 ec 18             	sub    $0x18,%esp
  write(fd, s, strlen(s));
   6:	8b 45 0c             	mov    0xc(%ebp),%eax
   9:	89 04 24             	mov    %eax,(%esp)
   c:	e8 c5 01 00 00       	call   1d6 <strlen>
  11:	89 44 24 08          	mov    %eax,0x8(%esp)
  15:	8b 45 0c             	mov    0xc(%ebp),%eax
  18:	89 44 24 04          	mov    %eax,0x4(%esp)
  1c:	8b 45 08             	mov    0x8(%ebp),%eax
  1f:	89 04 24             	mov    %eax,(%esp)
  22:	e8 99 03 00 00       	call   3c0 <write>
}
  27:	c9                   	leave  
  28:	c3                   	ret    

00000029 <forktest>:

void
forktest(void)
{
  29:	55                   	push   %ebp
  2a:	89 e5                	mov    %esp,%ebp
  2c:	83 ec 28             	sub    $0x28,%esp
  int n, pid;

  printf(1, "fork test\n");
  2f:	c7 44 24 04 40 04 00 	movl   $0x440,0x4(%esp)
  36:	00 
  37:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  3e:	e8 bd ff ff ff       	call   0 <printf>

  for(n=0; n<N; n++){
  43:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  4a:	eb 24                	jmp    70 <forktest+0x47>
    pid = fork();
  4c:	e8 47 03 00 00       	call   398 <fork>
  51:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(pid < 0)
  54:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  58:	78 21                	js     7b <forktest+0x52>
      break;
    if(pid == 0)
  5a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  5e:	75 0c                	jne    6c <forktest+0x43>
      exit(EXIT_STATUS_DEFAULT);
  60:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  67:	e8 34 03 00 00       	call   3a0 <exit>
{
  int n, pid;

  printf(1, "fork test\n");

  for(n=0; n<N; n++){
  6c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  70:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
  77:	7e d3                	jle    4c <forktest+0x23>
  79:	eb 01                	jmp    7c <forktest+0x53>
    pid = fork();
    if(pid < 0)
      break;
  7b:	90                   	nop
    if(pid == 0)
      exit(EXIT_STATUS_DEFAULT);
  }
  
  if(n == N){
  7c:	81 7d f4 e8 03 00 00 	cmpl   $0x3e8,-0xc(%ebp)
  83:	75 55                	jne    da <forktest+0xb1>
    printf(1, "fork claimed to work N times!\n", N);
  85:	c7 44 24 08 e8 03 00 	movl   $0x3e8,0x8(%esp)
  8c:	00 
  8d:	c7 44 24 04 4c 04 00 	movl   $0x44c,0x4(%esp)
  94:	00 
  95:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  9c:	e8 5f ff ff ff       	call   0 <printf>
    exit(EXIT_STATUS_DEFAULT);
  a1:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  a8:	e8 f3 02 00 00       	call   3a0 <exit>
  }
  
  for(; n > 0; n--){
    if(wait() < 0){
  ad:	e8 f6 02 00 00       	call   3a8 <wait>
  b2:	85 c0                	test   %eax,%eax
  b4:	79 20                	jns    d6 <forktest+0xad>
      printf(1, "wait stopped early\n");
  b6:	c7 44 24 04 6b 04 00 	movl   $0x46b,0x4(%esp)
  bd:	00 
  be:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  c5:	e8 36 ff ff ff       	call   0 <printf>
      exit(EXIT_STATUS_DEFAULT);
  ca:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  d1:	e8 ca 02 00 00       	call   3a0 <exit>
  if(n == N){
    printf(1, "fork claimed to work N times!\n", N);
    exit(EXIT_STATUS_DEFAULT);
  }
  
  for(; n > 0; n--){
  d6:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
  da:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  de:	7f cd                	jg     ad <forktest+0x84>
      printf(1, "wait stopped early\n");
      exit(EXIT_STATUS_DEFAULT);
    }
  }
  
  if(wait() != -1){
  e0:	e8 c3 02 00 00       	call   3a8 <wait>
  e5:	83 f8 ff             	cmp    $0xffffffff,%eax
  e8:	74 20                	je     10a <forktest+0xe1>
    printf(1, "wait got too many\n");
  ea:	c7 44 24 04 7f 04 00 	movl   $0x47f,0x4(%esp)
  f1:	00 
  f2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  f9:	e8 02 ff ff ff       	call   0 <printf>
    exit(EXIT_STATUS_DEFAULT);
  fe:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
 105:	e8 96 02 00 00       	call   3a0 <exit>
  }
  
  printf(1, "fork test OK\n");
 10a:	c7 44 24 04 92 04 00 	movl   $0x492,0x4(%esp)
 111:	00 
 112:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 119:	e8 e2 fe ff ff       	call   0 <printf>
}
 11e:	c9                   	leave  
 11f:	c3                   	ret    

00000120 <main>:

int
main(void)
{
 120:	55                   	push   %ebp
 121:	89 e5                	mov    %esp,%ebp
 123:	83 e4 f0             	and    $0xfffffff0,%esp
 126:	83 ec 10             	sub    $0x10,%esp
  forktest();
 129:	e8 fb fe ff ff       	call   29 <forktest>
  exit(EXIT_STATUS_DEFAULT);
 12e:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
 135:	e8 66 02 00 00       	call   3a0 <exit>
 13a:	90                   	nop
 13b:	90                   	nop

0000013c <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 13c:	55                   	push   %ebp
 13d:	89 e5                	mov    %esp,%ebp
 13f:	57                   	push   %edi
 140:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 141:	8b 4d 08             	mov    0x8(%ebp),%ecx
 144:	8b 55 10             	mov    0x10(%ebp),%edx
 147:	8b 45 0c             	mov    0xc(%ebp),%eax
 14a:	89 cb                	mov    %ecx,%ebx
 14c:	89 df                	mov    %ebx,%edi
 14e:	89 d1                	mov    %edx,%ecx
 150:	fc                   	cld    
 151:	f3 aa                	rep stos %al,%es:(%edi)
 153:	89 ca                	mov    %ecx,%edx
 155:	89 fb                	mov    %edi,%ebx
 157:	89 5d 08             	mov    %ebx,0x8(%ebp)
 15a:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 15d:	5b                   	pop    %ebx
 15e:	5f                   	pop    %edi
 15f:	5d                   	pop    %ebp
 160:	c3                   	ret    

00000161 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 161:	55                   	push   %ebp
 162:	89 e5                	mov    %esp,%ebp
 164:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 167:	8b 45 08             	mov    0x8(%ebp),%eax
 16a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 16d:	90                   	nop
 16e:	8b 45 0c             	mov    0xc(%ebp),%eax
 171:	0f b6 10             	movzbl (%eax),%edx
 174:	8b 45 08             	mov    0x8(%ebp),%eax
 177:	88 10                	mov    %dl,(%eax)
 179:	8b 45 08             	mov    0x8(%ebp),%eax
 17c:	0f b6 00             	movzbl (%eax),%eax
 17f:	84 c0                	test   %al,%al
 181:	0f 95 c0             	setne  %al
 184:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 188:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 18c:	84 c0                	test   %al,%al
 18e:	75 de                	jne    16e <strcpy+0xd>
    ;
  return os;
 190:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 193:	c9                   	leave  
 194:	c3                   	ret    

00000195 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 195:	55                   	push   %ebp
 196:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 198:	eb 08                	jmp    1a2 <strcmp+0xd>
    p++, q++;
 19a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 19e:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 1a2:	8b 45 08             	mov    0x8(%ebp),%eax
 1a5:	0f b6 00             	movzbl (%eax),%eax
 1a8:	84 c0                	test   %al,%al
 1aa:	74 10                	je     1bc <strcmp+0x27>
 1ac:	8b 45 08             	mov    0x8(%ebp),%eax
 1af:	0f b6 10             	movzbl (%eax),%edx
 1b2:	8b 45 0c             	mov    0xc(%ebp),%eax
 1b5:	0f b6 00             	movzbl (%eax),%eax
 1b8:	38 c2                	cmp    %al,%dl
 1ba:	74 de                	je     19a <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 1bc:	8b 45 08             	mov    0x8(%ebp),%eax
 1bf:	0f b6 00             	movzbl (%eax),%eax
 1c2:	0f b6 d0             	movzbl %al,%edx
 1c5:	8b 45 0c             	mov    0xc(%ebp),%eax
 1c8:	0f b6 00             	movzbl (%eax),%eax
 1cb:	0f b6 c0             	movzbl %al,%eax
 1ce:	89 d1                	mov    %edx,%ecx
 1d0:	29 c1                	sub    %eax,%ecx
 1d2:	89 c8                	mov    %ecx,%eax
}
 1d4:	5d                   	pop    %ebp
 1d5:	c3                   	ret    

000001d6 <strlen>:

uint
strlen(char *s)
{
 1d6:	55                   	push   %ebp
 1d7:	89 e5                	mov    %esp,%ebp
 1d9:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 1dc:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 1e3:	eb 04                	jmp    1e9 <strlen+0x13>
 1e5:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 1e9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 1ec:	03 45 08             	add    0x8(%ebp),%eax
 1ef:	0f b6 00             	movzbl (%eax),%eax
 1f2:	84 c0                	test   %al,%al
 1f4:	75 ef                	jne    1e5 <strlen+0xf>
    ;
  return n;
 1f6:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 1f9:	c9                   	leave  
 1fa:	c3                   	ret    

000001fb <memset>:

void*
memset(void *dst, int c, uint n)
{
 1fb:	55                   	push   %ebp
 1fc:	89 e5                	mov    %esp,%ebp
 1fe:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 201:	8b 45 10             	mov    0x10(%ebp),%eax
 204:	89 44 24 08          	mov    %eax,0x8(%esp)
 208:	8b 45 0c             	mov    0xc(%ebp),%eax
 20b:	89 44 24 04          	mov    %eax,0x4(%esp)
 20f:	8b 45 08             	mov    0x8(%ebp),%eax
 212:	89 04 24             	mov    %eax,(%esp)
 215:	e8 22 ff ff ff       	call   13c <stosb>
  return dst;
 21a:	8b 45 08             	mov    0x8(%ebp),%eax
}
 21d:	c9                   	leave  
 21e:	c3                   	ret    

0000021f <strchr>:

char*
strchr(const char *s, char c)
{
 21f:	55                   	push   %ebp
 220:	89 e5                	mov    %esp,%ebp
 222:	83 ec 04             	sub    $0x4,%esp
 225:	8b 45 0c             	mov    0xc(%ebp),%eax
 228:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 22b:	eb 14                	jmp    241 <strchr+0x22>
    if(*s == c)
 22d:	8b 45 08             	mov    0x8(%ebp),%eax
 230:	0f b6 00             	movzbl (%eax),%eax
 233:	3a 45 fc             	cmp    -0x4(%ebp),%al
 236:	75 05                	jne    23d <strchr+0x1e>
      return (char*)s;
 238:	8b 45 08             	mov    0x8(%ebp),%eax
 23b:	eb 13                	jmp    250 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 23d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 241:	8b 45 08             	mov    0x8(%ebp),%eax
 244:	0f b6 00             	movzbl (%eax),%eax
 247:	84 c0                	test   %al,%al
 249:	75 e2                	jne    22d <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 24b:	b8 00 00 00 00       	mov    $0x0,%eax
}
 250:	c9                   	leave  
 251:	c3                   	ret    

00000252 <gets>:

char*
gets(char *buf, int max)
{
 252:	55                   	push   %ebp
 253:	89 e5                	mov    %esp,%ebp
 255:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 258:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 25f:	eb 44                	jmp    2a5 <gets+0x53>
    cc = read(0, &c, 1);
 261:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 268:	00 
 269:	8d 45 ef             	lea    -0x11(%ebp),%eax
 26c:	89 44 24 04          	mov    %eax,0x4(%esp)
 270:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 277:	e8 3c 01 00 00       	call   3b8 <read>
 27c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 27f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 283:	7e 2d                	jle    2b2 <gets+0x60>
      break;
    buf[i++] = c;
 285:	8b 45 f4             	mov    -0xc(%ebp),%eax
 288:	03 45 08             	add    0x8(%ebp),%eax
 28b:	0f b6 55 ef          	movzbl -0x11(%ebp),%edx
 28f:	88 10                	mov    %dl,(%eax)
 291:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(c == '\n' || c == '\r')
 295:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 299:	3c 0a                	cmp    $0xa,%al
 29b:	74 16                	je     2b3 <gets+0x61>
 29d:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 2a1:	3c 0d                	cmp    $0xd,%al
 2a3:	74 0e                	je     2b3 <gets+0x61>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 2a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2a8:	83 c0 01             	add    $0x1,%eax
 2ab:	3b 45 0c             	cmp    0xc(%ebp),%eax
 2ae:	7c b1                	jl     261 <gets+0xf>
 2b0:	eb 01                	jmp    2b3 <gets+0x61>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 2b2:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 2b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2b6:	03 45 08             	add    0x8(%ebp),%eax
 2b9:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 2bc:	8b 45 08             	mov    0x8(%ebp),%eax
}
 2bf:	c9                   	leave  
 2c0:	c3                   	ret    

000002c1 <stat>:

int
stat(char *n, struct stat *st)
{
 2c1:	55                   	push   %ebp
 2c2:	89 e5                	mov    %esp,%ebp
 2c4:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2c7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 2ce:	00 
 2cf:	8b 45 08             	mov    0x8(%ebp),%eax
 2d2:	89 04 24             	mov    %eax,(%esp)
 2d5:	e8 06 01 00 00       	call   3e0 <open>
 2da:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 2dd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 2e1:	79 07                	jns    2ea <stat+0x29>
    return -1;
 2e3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 2e8:	eb 23                	jmp    30d <stat+0x4c>
  r = fstat(fd, st);
 2ea:	8b 45 0c             	mov    0xc(%ebp),%eax
 2ed:	89 44 24 04          	mov    %eax,0x4(%esp)
 2f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2f4:	89 04 24             	mov    %eax,(%esp)
 2f7:	e8 fc 00 00 00       	call   3f8 <fstat>
 2fc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 2ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
 302:	89 04 24             	mov    %eax,(%esp)
 305:	e8 be 00 00 00       	call   3c8 <close>
  return r;
 30a:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 30d:	c9                   	leave  
 30e:	c3                   	ret    

0000030f <atoi>:

int
atoi(const char *s)
{
 30f:	55                   	push   %ebp
 310:	89 e5                	mov    %esp,%ebp
 312:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 315:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 31c:	eb 23                	jmp    341 <atoi+0x32>
    n = n*10 + *s++ - '0';
 31e:	8b 55 fc             	mov    -0x4(%ebp),%edx
 321:	89 d0                	mov    %edx,%eax
 323:	c1 e0 02             	shl    $0x2,%eax
 326:	01 d0                	add    %edx,%eax
 328:	01 c0                	add    %eax,%eax
 32a:	89 c2                	mov    %eax,%edx
 32c:	8b 45 08             	mov    0x8(%ebp),%eax
 32f:	0f b6 00             	movzbl (%eax),%eax
 332:	0f be c0             	movsbl %al,%eax
 335:	01 d0                	add    %edx,%eax
 337:	83 e8 30             	sub    $0x30,%eax
 33a:	89 45 fc             	mov    %eax,-0x4(%ebp)
 33d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 341:	8b 45 08             	mov    0x8(%ebp),%eax
 344:	0f b6 00             	movzbl (%eax),%eax
 347:	3c 2f                	cmp    $0x2f,%al
 349:	7e 0a                	jle    355 <atoi+0x46>
 34b:	8b 45 08             	mov    0x8(%ebp),%eax
 34e:	0f b6 00             	movzbl (%eax),%eax
 351:	3c 39                	cmp    $0x39,%al
 353:	7e c9                	jle    31e <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 355:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 358:	c9                   	leave  
 359:	c3                   	ret    

0000035a <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 35a:	55                   	push   %ebp
 35b:	89 e5                	mov    %esp,%ebp
 35d:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 360:	8b 45 08             	mov    0x8(%ebp),%eax
 363:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 366:	8b 45 0c             	mov    0xc(%ebp),%eax
 369:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 36c:	eb 13                	jmp    381 <memmove+0x27>
    *dst++ = *src++;
 36e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 371:	0f b6 10             	movzbl (%eax),%edx
 374:	8b 45 fc             	mov    -0x4(%ebp),%eax
 377:	88 10                	mov    %dl,(%eax)
 379:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 37d:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 381:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 385:	0f 9f c0             	setg   %al
 388:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 38c:	84 c0                	test   %al,%al
 38e:	75 de                	jne    36e <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 390:	8b 45 08             	mov    0x8(%ebp),%eax
}
 393:	c9                   	leave  
 394:	c3                   	ret    
 395:	90                   	nop
 396:	90                   	nop
 397:	90                   	nop

00000398 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 398:	b8 01 00 00 00       	mov    $0x1,%eax
 39d:	cd 40                	int    $0x40
 39f:	c3                   	ret    

000003a0 <exit>:
SYSCALL(exit)
 3a0:	b8 02 00 00 00       	mov    $0x2,%eax
 3a5:	cd 40                	int    $0x40
 3a7:	c3                   	ret    

000003a8 <wait>:
SYSCALL(wait)
 3a8:	b8 03 00 00 00       	mov    $0x3,%eax
 3ad:	cd 40                	int    $0x40
 3af:	c3                   	ret    

000003b0 <pipe>:
SYSCALL(pipe)
 3b0:	b8 04 00 00 00       	mov    $0x4,%eax
 3b5:	cd 40                	int    $0x40
 3b7:	c3                   	ret    

000003b8 <read>:
SYSCALL(read)
 3b8:	b8 05 00 00 00       	mov    $0x5,%eax
 3bd:	cd 40                	int    $0x40
 3bf:	c3                   	ret    

000003c0 <write>:
SYSCALL(write)
 3c0:	b8 10 00 00 00       	mov    $0x10,%eax
 3c5:	cd 40                	int    $0x40
 3c7:	c3                   	ret    

000003c8 <close>:
SYSCALL(close)
 3c8:	b8 15 00 00 00       	mov    $0x15,%eax
 3cd:	cd 40                	int    $0x40
 3cf:	c3                   	ret    

000003d0 <kill>:
SYSCALL(kill)
 3d0:	b8 06 00 00 00       	mov    $0x6,%eax
 3d5:	cd 40                	int    $0x40
 3d7:	c3                   	ret    

000003d8 <exec>:
SYSCALL(exec)
 3d8:	b8 07 00 00 00       	mov    $0x7,%eax
 3dd:	cd 40                	int    $0x40
 3df:	c3                   	ret    

000003e0 <open>:
SYSCALL(open)
 3e0:	b8 0f 00 00 00       	mov    $0xf,%eax
 3e5:	cd 40                	int    $0x40
 3e7:	c3                   	ret    

000003e8 <mknod>:
SYSCALL(mknod)
 3e8:	b8 11 00 00 00       	mov    $0x11,%eax
 3ed:	cd 40                	int    $0x40
 3ef:	c3                   	ret    

000003f0 <unlink>:
SYSCALL(unlink)
 3f0:	b8 12 00 00 00       	mov    $0x12,%eax
 3f5:	cd 40                	int    $0x40
 3f7:	c3                   	ret    

000003f8 <fstat>:
SYSCALL(fstat)
 3f8:	b8 08 00 00 00       	mov    $0x8,%eax
 3fd:	cd 40                	int    $0x40
 3ff:	c3                   	ret    

00000400 <link>:
SYSCALL(link)
 400:	b8 13 00 00 00       	mov    $0x13,%eax
 405:	cd 40                	int    $0x40
 407:	c3                   	ret    

00000408 <mkdir>:
SYSCALL(mkdir)
 408:	b8 14 00 00 00       	mov    $0x14,%eax
 40d:	cd 40                	int    $0x40
 40f:	c3                   	ret    

00000410 <chdir>:
SYSCALL(chdir)
 410:	b8 09 00 00 00       	mov    $0x9,%eax
 415:	cd 40                	int    $0x40
 417:	c3                   	ret    

00000418 <dup>:
SYSCALL(dup)
 418:	b8 0a 00 00 00       	mov    $0xa,%eax
 41d:	cd 40                	int    $0x40
 41f:	c3                   	ret    

00000420 <getpid>:
SYSCALL(getpid)
 420:	b8 0b 00 00 00       	mov    $0xb,%eax
 425:	cd 40                	int    $0x40
 427:	c3                   	ret    

00000428 <sbrk>:
SYSCALL(sbrk)
 428:	b8 0c 00 00 00       	mov    $0xc,%eax
 42d:	cd 40                	int    $0x40
 42f:	c3                   	ret    

00000430 <sleep>:
SYSCALL(sleep)
 430:	b8 0d 00 00 00       	mov    $0xd,%eax
 435:	cd 40                	int    $0x40
 437:	c3                   	ret    

00000438 <uptime>:
SYSCALL(uptime)
 438:	b8 0e 00 00 00       	mov    $0xe,%eax
 43d:	cd 40                	int    $0x40
 43f:	c3                   	ret    
