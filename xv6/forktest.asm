
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
   c:	e8 d1 01 00 00       	call   1e2 <strlen>
  11:	89 44 24 08          	mov    %eax,0x8(%esp)
  15:	8b 45 0c             	mov    0xc(%ebp),%eax
  18:	89 44 24 04          	mov    %eax,0x4(%esp)
  1c:	8b 45 08             	mov    0x8(%ebp),%eax
  1f:	89 04 24             	mov    %eax,(%esp)
  22:	e8 a5 03 00 00       	call   3cc <write>
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
  2f:	c7 44 24 04 6c 04 00 	movl   $0x46c,0x4(%esp)
  36:	00 
  37:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  3e:	e8 bd ff ff ff       	call   0 <printf>

  for(n=0; n<N; n++){
  43:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  4a:	eb 24                	jmp    70 <forktest+0x47>
    pid = fork();
  4c:	e8 53 03 00 00       	call   3a4 <fork>
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
  67:	e8 40 03 00 00       	call   3ac <exit>
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
  83:	75 5c                	jne    e1 <forktest+0xb8>
    printf(1, "fork claimed to work N times!\n", N);
  85:	c7 44 24 08 e8 03 00 	movl   $0x3e8,0x8(%esp)
  8c:	00 
  8d:	c7 44 24 04 78 04 00 	movl   $0x478,0x4(%esp)
  94:	00 
  95:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  9c:	e8 5f ff ff ff       	call   0 <printf>
    exit(EXIT_STATUS_DEFAULT);
  a1:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  a8:	e8 ff 02 00 00       	call   3ac <exit>
  }
  
  for(; n > 0; n--){
    if(wait(0) < 0){
  ad:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  b4:	e8 fb 02 00 00       	call   3b4 <wait>
  b9:	85 c0                	test   %eax,%eax
  bb:	79 20                	jns    dd <forktest+0xb4>
      printf(1, "wait stopped early\n");
  bd:	c7 44 24 04 97 04 00 	movl   $0x497,0x4(%esp)
  c4:	00 
  c5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  cc:	e8 2f ff ff ff       	call   0 <printf>
      exit(EXIT_STATUS_DEFAULT);
  d1:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  d8:	e8 cf 02 00 00       	call   3ac <exit>
  if(n == N){
    printf(1, "fork claimed to work N times!\n", N);
    exit(EXIT_STATUS_DEFAULT);
  }
  
  for(; n > 0; n--){
  dd:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
  e1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  e5:	7f c6                	jg     ad <forktest+0x84>
      printf(1, "wait stopped early\n");
      exit(EXIT_STATUS_DEFAULT);
    }
  }
  
  if(wait(0) != -1){
  e7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  ee:	e8 c1 02 00 00       	call   3b4 <wait>
  f3:	83 f8 ff             	cmp    $0xffffffff,%eax
  f6:	74 20                	je     118 <forktest+0xef>
    printf(1, "wait got too many\n");
  f8:	c7 44 24 04 ab 04 00 	movl   $0x4ab,0x4(%esp)
  ff:	00 
 100:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 107:	e8 f4 fe ff ff       	call   0 <printf>
    exit(EXIT_STATUS_DEFAULT);
 10c:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
 113:	e8 94 02 00 00       	call   3ac <exit>
  }
  
  printf(1, "fork test OK\n");
 118:	c7 44 24 04 be 04 00 	movl   $0x4be,0x4(%esp)
 11f:	00 
 120:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 127:	e8 d4 fe ff ff       	call   0 <printf>
}
 12c:	c9                   	leave  
 12d:	c3                   	ret    

0000012e <main>:

int
main(void)
{
 12e:	55                   	push   %ebp
 12f:	89 e5                	mov    %esp,%ebp
 131:	83 e4 f0             	and    $0xfffffff0,%esp
 134:	83 ec 10             	sub    $0x10,%esp
  forktest();
 137:	e8 ed fe ff ff       	call   29 <forktest>
  exit(EXIT_STATUS_DEFAULT);
 13c:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
 143:	e8 64 02 00 00       	call   3ac <exit>

00000148 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 148:	55                   	push   %ebp
 149:	89 e5                	mov    %esp,%ebp
 14b:	57                   	push   %edi
 14c:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 14d:	8b 4d 08             	mov    0x8(%ebp),%ecx
 150:	8b 55 10             	mov    0x10(%ebp),%edx
 153:	8b 45 0c             	mov    0xc(%ebp),%eax
 156:	89 cb                	mov    %ecx,%ebx
 158:	89 df                	mov    %ebx,%edi
 15a:	89 d1                	mov    %edx,%ecx
 15c:	fc                   	cld    
 15d:	f3 aa                	rep stos %al,%es:(%edi)
 15f:	89 ca                	mov    %ecx,%edx
 161:	89 fb                	mov    %edi,%ebx
 163:	89 5d 08             	mov    %ebx,0x8(%ebp)
 166:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 169:	5b                   	pop    %ebx
 16a:	5f                   	pop    %edi
 16b:	5d                   	pop    %ebp
 16c:	c3                   	ret    

0000016d <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 16d:	55                   	push   %ebp
 16e:	89 e5                	mov    %esp,%ebp
 170:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 173:	8b 45 08             	mov    0x8(%ebp),%eax
 176:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 179:	90                   	nop
 17a:	8b 45 0c             	mov    0xc(%ebp),%eax
 17d:	0f b6 10             	movzbl (%eax),%edx
 180:	8b 45 08             	mov    0x8(%ebp),%eax
 183:	88 10                	mov    %dl,(%eax)
 185:	8b 45 08             	mov    0x8(%ebp),%eax
 188:	0f b6 00             	movzbl (%eax),%eax
 18b:	84 c0                	test   %al,%al
 18d:	0f 95 c0             	setne  %al
 190:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 194:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 198:	84 c0                	test   %al,%al
 19a:	75 de                	jne    17a <strcpy+0xd>
    ;
  return os;
 19c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 19f:	c9                   	leave  
 1a0:	c3                   	ret    

000001a1 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 1a1:	55                   	push   %ebp
 1a2:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 1a4:	eb 08                	jmp    1ae <strcmp+0xd>
    p++, q++;
 1a6:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 1aa:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 1ae:	8b 45 08             	mov    0x8(%ebp),%eax
 1b1:	0f b6 00             	movzbl (%eax),%eax
 1b4:	84 c0                	test   %al,%al
 1b6:	74 10                	je     1c8 <strcmp+0x27>
 1b8:	8b 45 08             	mov    0x8(%ebp),%eax
 1bb:	0f b6 10             	movzbl (%eax),%edx
 1be:	8b 45 0c             	mov    0xc(%ebp),%eax
 1c1:	0f b6 00             	movzbl (%eax),%eax
 1c4:	38 c2                	cmp    %al,%dl
 1c6:	74 de                	je     1a6 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 1c8:	8b 45 08             	mov    0x8(%ebp),%eax
 1cb:	0f b6 00             	movzbl (%eax),%eax
 1ce:	0f b6 d0             	movzbl %al,%edx
 1d1:	8b 45 0c             	mov    0xc(%ebp),%eax
 1d4:	0f b6 00             	movzbl (%eax),%eax
 1d7:	0f b6 c0             	movzbl %al,%eax
 1da:	89 d1                	mov    %edx,%ecx
 1dc:	29 c1                	sub    %eax,%ecx
 1de:	89 c8                	mov    %ecx,%eax
}
 1e0:	5d                   	pop    %ebp
 1e1:	c3                   	ret    

000001e2 <strlen>:

uint
strlen(char *s)
{
 1e2:	55                   	push   %ebp
 1e3:	89 e5                	mov    %esp,%ebp
 1e5:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 1e8:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 1ef:	eb 04                	jmp    1f5 <strlen+0x13>
 1f1:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 1f5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 1f8:	03 45 08             	add    0x8(%ebp),%eax
 1fb:	0f b6 00             	movzbl (%eax),%eax
 1fe:	84 c0                	test   %al,%al
 200:	75 ef                	jne    1f1 <strlen+0xf>
    ;
  return n;
 202:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 205:	c9                   	leave  
 206:	c3                   	ret    

00000207 <memset>:

void*
memset(void *dst, int c, uint n)
{
 207:	55                   	push   %ebp
 208:	89 e5                	mov    %esp,%ebp
 20a:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 20d:	8b 45 10             	mov    0x10(%ebp),%eax
 210:	89 44 24 08          	mov    %eax,0x8(%esp)
 214:	8b 45 0c             	mov    0xc(%ebp),%eax
 217:	89 44 24 04          	mov    %eax,0x4(%esp)
 21b:	8b 45 08             	mov    0x8(%ebp),%eax
 21e:	89 04 24             	mov    %eax,(%esp)
 221:	e8 22 ff ff ff       	call   148 <stosb>
  return dst;
 226:	8b 45 08             	mov    0x8(%ebp),%eax
}
 229:	c9                   	leave  
 22a:	c3                   	ret    

0000022b <strchr>:

char*
strchr(const char *s, char c)
{
 22b:	55                   	push   %ebp
 22c:	89 e5                	mov    %esp,%ebp
 22e:	83 ec 04             	sub    $0x4,%esp
 231:	8b 45 0c             	mov    0xc(%ebp),%eax
 234:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 237:	eb 14                	jmp    24d <strchr+0x22>
    if(*s == c)
 239:	8b 45 08             	mov    0x8(%ebp),%eax
 23c:	0f b6 00             	movzbl (%eax),%eax
 23f:	3a 45 fc             	cmp    -0x4(%ebp),%al
 242:	75 05                	jne    249 <strchr+0x1e>
      return (char*)s;
 244:	8b 45 08             	mov    0x8(%ebp),%eax
 247:	eb 13                	jmp    25c <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 249:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 24d:	8b 45 08             	mov    0x8(%ebp),%eax
 250:	0f b6 00             	movzbl (%eax),%eax
 253:	84 c0                	test   %al,%al
 255:	75 e2                	jne    239 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 257:	b8 00 00 00 00       	mov    $0x0,%eax
}
 25c:	c9                   	leave  
 25d:	c3                   	ret    

0000025e <gets>:

char*
gets(char *buf, int max)
{
 25e:	55                   	push   %ebp
 25f:	89 e5                	mov    %esp,%ebp
 261:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 264:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 26b:	eb 44                	jmp    2b1 <gets+0x53>
    cc = read(0, &c, 1);
 26d:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 274:	00 
 275:	8d 45 ef             	lea    -0x11(%ebp),%eax
 278:	89 44 24 04          	mov    %eax,0x4(%esp)
 27c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 283:	e8 3c 01 00 00       	call   3c4 <read>
 288:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 28b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 28f:	7e 2d                	jle    2be <gets+0x60>
      break;
    buf[i++] = c;
 291:	8b 45 f4             	mov    -0xc(%ebp),%eax
 294:	03 45 08             	add    0x8(%ebp),%eax
 297:	0f b6 55 ef          	movzbl -0x11(%ebp),%edx
 29b:	88 10                	mov    %dl,(%eax)
 29d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(c == '\n' || c == '\r')
 2a1:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 2a5:	3c 0a                	cmp    $0xa,%al
 2a7:	74 16                	je     2bf <gets+0x61>
 2a9:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 2ad:	3c 0d                	cmp    $0xd,%al
 2af:	74 0e                	je     2bf <gets+0x61>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 2b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2b4:	83 c0 01             	add    $0x1,%eax
 2b7:	3b 45 0c             	cmp    0xc(%ebp),%eax
 2ba:	7c b1                	jl     26d <gets+0xf>
 2bc:	eb 01                	jmp    2bf <gets+0x61>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 2be:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 2bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2c2:	03 45 08             	add    0x8(%ebp),%eax
 2c5:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 2c8:	8b 45 08             	mov    0x8(%ebp),%eax
}
 2cb:	c9                   	leave  
 2cc:	c3                   	ret    

000002cd <stat>:

int
stat(char *n, struct stat *st)
{
 2cd:	55                   	push   %ebp
 2ce:	89 e5                	mov    %esp,%ebp
 2d0:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2d3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 2da:	00 
 2db:	8b 45 08             	mov    0x8(%ebp),%eax
 2de:	89 04 24             	mov    %eax,(%esp)
 2e1:	e8 06 01 00 00       	call   3ec <open>
 2e6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 2e9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 2ed:	79 07                	jns    2f6 <stat+0x29>
    return -1;
 2ef:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 2f4:	eb 23                	jmp    319 <stat+0x4c>
  r = fstat(fd, st);
 2f6:	8b 45 0c             	mov    0xc(%ebp),%eax
 2f9:	89 44 24 04          	mov    %eax,0x4(%esp)
 2fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 300:	89 04 24             	mov    %eax,(%esp)
 303:	e8 fc 00 00 00       	call   404 <fstat>
 308:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 30b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 30e:	89 04 24             	mov    %eax,(%esp)
 311:	e8 be 00 00 00       	call   3d4 <close>
  return r;
 316:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 319:	c9                   	leave  
 31a:	c3                   	ret    

0000031b <atoi>:

int
atoi(const char *s)
{
 31b:	55                   	push   %ebp
 31c:	89 e5                	mov    %esp,%ebp
 31e:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 321:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 328:	eb 23                	jmp    34d <atoi+0x32>
    n = n*10 + *s++ - '0';
 32a:	8b 55 fc             	mov    -0x4(%ebp),%edx
 32d:	89 d0                	mov    %edx,%eax
 32f:	c1 e0 02             	shl    $0x2,%eax
 332:	01 d0                	add    %edx,%eax
 334:	01 c0                	add    %eax,%eax
 336:	89 c2                	mov    %eax,%edx
 338:	8b 45 08             	mov    0x8(%ebp),%eax
 33b:	0f b6 00             	movzbl (%eax),%eax
 33e:	0f be c0             	movsbl %al,%eax
 341:	01 d0                	add    %edx,%eax
 343:	83 e8 30             	sub    $0x30,%eax
 346:	89 45 fc             	mov    %eax,-0x4(%ebp)
 349:	83 45 08 01          	addl   $0x1,0x8(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 34d:	8b 45 08             	mov    0x8(%ebp),%eax
 350:	0f b6 00             	movzbl (%eax),%eax
 353:	3c 2f                	cmp    $0x2f,%al
 355:	7e 0a                	jle    361 <atoi+0x46>
 357:	8b 45 08             	mov    0x8(%ebp),%eax
 35a:	0f b6 00             	movzbl (%eax),%eax
 35d:	3c 39                	cmp    $0x39,%al
 35f:	7e c9                	jle    32a <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 361:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 364:	c9                   	leave  
 365:	c3                   	ret    

00000366 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 366:	55                   	push   %ebp
 367:	89 e5                	mov    %esp,%ebp
 369:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 36c:	8b 45 08             	mov    0x8(%ebp),%eax
 36f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 372:	8b 45 0c             	mov    0xc(%ebp),%eax
 375:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 378:	eb 13                	jmp    38d <memmove+0x27>
    *dst++ = *src++;
 37a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 37d:	0f b6 10             	movzbl (%eax),%edx
 380:	8b 45 fc             	mov    -0x4(%ebp),%eax
 383:	88 10                	mov    %dl,(%eax)
 385:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 389:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 38d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 391:	0f 9f c0             	setg   %al
 394:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 398:	84 c0                	test   %al,%al
 39a:	75 de                	jne    37a <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 39c:	8b 45 08             	mov    0x8(%ebp),%eax
}
 39f:	c9                   	leave  
 3a0:	c3                   	ret    
 3a1:	90                   	nop
 3a2:	90                   	nop
 3a3:	90                   	nop

000003a4 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 3a4:	b8 01 00 00 00       	mov    $0x1,%eax
 3a9:	cd 40                	int    $0x40
 3ab:	c3                   	ret    

000003ac <exit>:
SYSCALL(exit)
 3ac:	b8 02 00 00 00       	mov    $0x2,%eax
 3b1:	cd 40                	int    $0x40
 3b3:	c3                   	ret    

000003b4 <wait>:
SYSCALL(wait)
 3b4:	b8 03 00 00 00       	mov    $0x3,%eax
 3b9:	cd 40                	int    $0x40
 3bb:	c3                   	ret    

000003bc <pipe>:
SYSCALL(pipe)
 3bc:	b8 04 00 00 00       	mov    $0x4,%eax
 3c1:	cd 40                	int    $0x40
 3c3:	c3                   	ret    

000003c4 <read>:
SYSCALL(read)
 3c4:	b8 05 00 00 00       	mov    $0x5,%eax
 3c9:	cd 40                	int    $0x40
 3cb:	c3                   	ret    

000003cc <write>:
SYSCALL(write)
 3cc:	b8 10 00 00 00       	mov    $0x10,%eax
 3d1:	cd 40                	int    $0x40
 3d3:	c3                   	ret    

000003d4 <close>:
SYSCALL(close)
 3d4:	b8 15 00 00 00       	mov    $0x15,%eax
 3d9:	cd 40                	int    $0x40
 3db:	c3                   	ret    

000003dc <kill>:
SYSCALL(kill)
 3dc:	b8 06 00 00 00       	mov    $0x6,%eax
 3e1:	cd 40                	int    $0x40
 3e3:	c3                   	ret    

000003e4 <exec>:
SYSCALL(exec)
 3e4:	b8 07 00 00 00       	mov    $0x7,%eax
 3e9:	cd 40                	int    $0x40
 3eb:	c3                   	ret    

000003ec <open>:
SYSCALL(open)
 3ec:	b8 0f 00 00 00       	mov    $0xf,%eax
 3f1:	cd 40                	int    $0x40
 3f3:	c3                   	ret    

000003f4 <mknod>:
SYSCALL(mknod)
 3f4:	b8 11 00 00 00       	mov    $0x11,%eax
 3f9:	cd 40                	int    $0x40
 3fb:	c3                   	ret    

000003fc <unlink>:
SYSCALL(unlink)
 3fc:	b8 12 00 00 00       	mov    $0x12,%eax
 401:	cd 40                	int    $0x40
 403:	c3                   	ret    

00000404 <fstat>:
SYSCALL(fstat)
 404:	b8 08 00 00 00       	mov    $0x8,%eax
 409:	cd 40                	int    $0x40
 40b:	c3                   	ret    

0000040c <link>:
SYSCALL(link)
 40c:	b8 13 00 00 00       	mov    $0x13,%eax
 411:	cd 40                	int    $0x40
 413:	c3                   	ret    

00000414 <mkdir>:
SYSCALL(mkdir)
 414:	b8 14 00 00 00       	mov    $0x14,%eax
 419:	cd 40                	int    $0x40
 41b:	c3                   	ret    

0000041c <chdir>:
SYSCALL(chdir)
 41c:	b8 09 00 00 00       	mov    $0x9,%eax
 421:	cd 40                	int    $0x40
 423:	c3                   	ret    

00000424 <dup>:
SYSCALL(dup)
 424:	b8 0a 00 00 00       	mov    $0xa,%eax
 429:	cd 40                	int    $0x40
 42b:	c3                   	ret    

0000042c <getpid>:
SYSCALL(getpid)
 42c:	b8 0b 00 00 00       	mov    $0xb,%eax
 431:	cd 40                	int    $0x40
 433:	c3                   	ret    

00000434 <sbrk>:
SYSCALL(sbrk)
 434:	b8 0c 00 00 00       	mov    $0xc,%eax
 439:	cd 40                	int    $0x40
 43b:	c3                   	ret    

0000043c <sleep>:
SYSCALL(sleep)
 43c:	b8 0d 00 00 00       	mov    $0xd,%eax
 441:	cd 40                	int    $0x40
 443:	c3                   	ret    

00000444 <uptime>:
SYSCALL(uptime)
 444:	b8 0e 00 00 00       	mov    $0xe,%eax
 449:	cd 40                	int    $0x40
 44b:	c3                   	ret    

0000044c <waitpid>:
SYSCALL(waitpid)
 44c:	b8 16 00 00 00       	mov    $0x16,%eax
 451:	cd 40                	int    $0x40
 453:	c3                   	ret    

00000454 <wait_stat>:
SYSCALL(wait_stat)
 454:	b8 17 00 00 00       	mov    $0x17,%eax
 459:	cd 40                	int    $0x40
 45b:	c3                   	ret    

0000045c <list_pgroup>:
SYSCALL(list_pgroup)
 45c:	b8 18 00 00 00       	mov    $0x18,%eax
 461:	cd 40                	int    $0x40
 463:	c3                   	ret    

00000464 <foreground>:
SYSCALL(foreground)
 464:	b8 19 00 00 00       	mov    $0x19,%eax
 469:	cd 40                	int    $0x40
 46b:	c3                   	ret    
