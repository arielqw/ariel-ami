
_init:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:

char *argv[] = { "sh", 0 };

int
main(void)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 e4 f0             	and    $0xfffffff0,%esp
   6:	83 ec 20             	sub    $0x20,%esp
  int pid, wpid;

  if(open("console", O_RDWR) < 0){
   9:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  10:	00 
  11:	c7 04 24 ee 08 00 00 	movl   $0x8ee,(%esp)
  18:	e8 b3 03 00 00       	call   3d0 <open>
  1d:	85 c0                	test   %eax,%eax
  1f:	79 30                	jns    51 <main+0x51>
    mknod("console", 1, 1);
  21:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  28:	00 
  29:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  30:	00 
  31:	c7 04 24 ee 08 00 00 	movl   $0x8ee,(%esp)
  38:	e8 9b 03 00 00       	call   3d8 <mknod>
    open("console", O_RDWR);
  3d:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  44:	00 
  45:	c7 04 24 ee 08 00 00 	movl   $0x8ee,(%esp)
  4c:	e8 7f 03 00 00       	call   3d0 <open>
  }
  dup(0);  // stdout
  51:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  58:	e8 ab 03 00 00       	call   408 <dup>
  dup(0);  // stderr
  5d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  64:	e8 9f 03 00 00       	call   408 <dup>
  69:	eb 01                	jmp    6c <main+0x6c>
      printf(1, "init: exec sh failed\n");
      exit(EXIT_STATUS_DEFAULT);
    }
    while((wpid=wait(0)) >= 0 && wpid != pid)
      printf(1, "zombie!\n");
  }
  6b:	90                   	nop
  }
  dup(0);  // stdout
  dup(0);  // stderr

  for(;;){
    printf(1, "init: starting sh\n");
  6c:	c7 44 24 04 f6 08 00 	movl   $0x8f6,0x4(%esp)
  73:	00 
  74:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  7b:	e8 a7 04 00 00       	call   527 <printf>
    pid = fork();
  80:	e8 03 03 00 00       	call   388 <fork>
  85:	89 44 24 1c          	mov    %eax,0x1c(%esp)
    if(pid < 0){
  89:	83 7c 24 1c 00       	cmpl   $0x0,0x1c(%esp)
  8e:	79 20                	jns    b0 <main+0xb0>
      printf(1, "init: fork failed\n");
  90:	c7 44 24 04 09 09 00 	movl   $0x909,0x4(%esp)
  97:	00 
  98:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  9f:	e8 83 04 00 00       	call   527 <printf>
      exit(EXIT_STATUS_DEFAULT);
  a4:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  ab:	e8 e0 02 00 00       	call   390 <exit>
    }
    if(pid == 0){
  b0:	83 7c 24 1c 00       	cmpl   $0x0,0x1c(%esp)
  b5:	75 48                	jne    ff <main+0xff>
      exec("sh", argv);
  b7:	c7 44 24 04 80 0b 00 	movl   $0xb80,0x4(%esp)
  be:	00 
  bf:	c7 04 24 eb 08 00 00 	movl   $0x8eb,(%esp)
  c6:	e8 fd 02 00 00       	call   3c8 <exec>
      printf(1, "init: exec sh failed\n");
  cb:	c7 44 24 04 1c 09 00 	movl   $0x91c,0x4(%esp)
  d2:	00 
  d3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  da:	e8 48 04 00 00       	call   527 <printf>
      exit(EXIT_STATUS_DEFAULT);
  df:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  e6:	e8 a5 02 00 00       	call   390 <exit>
    }
    while((wpid=wait(0)) >= 0 && wpid != pid)
      printf(1, "zombie!\n");
  eb:	c7 44 24 04 32 09 00 	movl   $0x932,0x4(%esp)
  f2:	00 
  f3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  fa:	e8 28 04 00 00       	call   527 <printf>
    if(pid == 0){
      exec("sh", argv);
      printf(1, "init: exec sh failed\n");
      exit(EXIT_STATUS_DEFAULT);
    }
    while((wpid=wait(0)) >= 0 && wpid != pid)
  ff:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 106:	e8 8d 02 00 00       	call   398 <wait>
 10b:	89 44 24 18          	mov    %eax,0x18(%esp)
 10f:	83 7c 24 18 00       	cmpl   $0x0,0x18(%esp)
 114:	0f 88 51 ff ff ff    	js     6b <main+0x6b>
 11a:	8b 44 24 18          	mov    0x18(%esp),%eax
 11e:	3b 44 24 1c          	cmp    0x1c(%esp),%eax
 122:	75 c7                	jne    eb <main+0xeb>
      printf(1, "zombie!\n");
  }
 124:	e9 42 ff ff ff       	jmp    6b <main+0x6b>
 129:	90                   	nop
 12a:	90                   	nop
 12b:	90                   	nop

0000012c <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 12c:	55                   	push   %ebp
 12d:	89 e5                	mov    %esp,%ebp
 12f:	57                   	push   %edi
 130:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 131:	8b 4d 08             	mov    0x8(%ebp),%ecx
 134:	8b 55 10             	mov    0x10(%ebp),%edx
 137:	8b 45 0c             	mov    0xc(%ebp),%eax
 13a:	89 cb                	mov    %ecx,%ebx
 13c:	89 df                	mov    %ebx,%edi
 13e:	89 d1                	mov    %edx,%ecx
 140:	fc                   	cld    
 141:	f3 aa                	rep stos %al,%es:(%edi)
 143:	89 ca                	mov    %ecx,%edx
 145:	89 fb                	mov    %edi,%ebx
 147:	89 5d 08             	mov    %ebx,0x8(%ebp)
 14a:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 14d:	5b                   	pop    %ebx
 14e:	5f                   	pop    %edi
 14f:	5d                   	pop    %ebp
 150:	c3                   	ret    

00000151 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 151:	55                   	push   %ebp
 152:	89 e5                	mov    %esp,%ebp
 154:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 157:	8b 45 08             	mov    0x8(%ebp),%eax
 15a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 15d:	90                   	nop
 15e:	8b 45 0c             	mov    0xc(%ebp),%eax
 161:	0f b6 10             	movzbl (%eax),%edx
 164:	8b 45 08             	mov    0x8(%ebp),%eax
 167:	88 10                	mov    %dl,(%eax)
 169:	8b 45 08             	mov    0x8(%ebp),%eax
 16c:	0f b6 00             	movzbl (%eax),%eax
 16f:	84 c0                	test   %al,%al
 171:	0f 95 c0             	setne  %al
 174:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 178:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 17c:	84 c0                	test   %al,%al
 17e:	75 de                	jne    15e <strcpy+0xd>
    ;
  return os;
 180:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 183:	c9                   	leave  
 184:	c3                   	ret    

00000185 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 185:	55                   	push   %ebp
 186:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 188:	eb 08                	jmp    192 <strcmp+0xd>
    p++, q++;
 18a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 18e:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 192:	8b 45 08             	mov    0x8(%ebp),%eax
 195:	0f b6 00             	movzbl (%eax),%eax
 198:	84 c0                	test   %al,%al
 19a:	74 10                	je     1ac <strcmp+0x27>
 19c:	8b 45 08             	mov    0x8(%ebp),%eax
 19f:	0f b6 10             	movzbl (%eax),%edx
 1a2:	8b 45 0c             	mov    0xc(%ebp),%eax
 1a5:	0f b6 00             	movzbl (%eax),%eax
 1a8:	38 c2                	cmp    %al,%dl
 1aa:	74 de                	je     18a <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 1ac:	8b 45 08             	mov    0x8(%ebp),%eax
 1af:	0f b6 00             	movzbl (%eax),%eax
 1b2:	0f b6 d0             	movzbl %al,%edx
 1b5:	8b 45 0c             	mov    0xc(%ebp),%eax
 1b8:	0f b6 00             	movzbl (%eax),%eax
 1bb:	0f b6 c0             	movzbl %al,%eax
 1be:	89 d1                	mov    %edx,%ecx
 1c0:	29 c1                	sub    %eax,%ecx
 1c2:	89 c8                	mov    %ecx,%eax
}
 1c4:	5d                   	pop    %ebp
 1c5:	c3                   	ret    

000001c6 <strlen>:

uint
strlen(char *s)
{
 1c6:	55                   	push   %ebp
 1c7:	89 e5                	mov    %esp,%ebp
 1c9:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 1cc:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 1d3:	eb 04                	jmp    1d9 <strlen+0x13>
 1d5:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 1d9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 1dc:	03 45 08             	add    0x8(%ebp),%eax
 1df:	0f b6 00             	movzbl (%eax),%eax
 1e2:	84 c0                	test   %al,%al
 1e4:	75 ef                	jne    1d5 <strlen+0xf>
    ;
  return n;
 1e6:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 1e9:	c9                   	leave  
 1ea:	c3                   	ret    

000001eb <memset>:

void*
memset(void *dst, int c, uint n)
{
 1eb:	55                   	push   %ebp
 1ec:	89 e5                	mov    %esp,%ebp
 1ee:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 1f1:	8b 45 10             	mov    0x10(%ebp),%eax
 1f4:	89 44 24 08          	mov    %eax,0x8(%esp)
 1f8:	8b 45 0c             	mov    0xc(%ebp),%eax
 1fb:	89 44 24 04          	mov    %eax,0x4(%esp)
 1ff:	8b 45 08             	mov    0x8(%ebp),%eax
 202:	89 04 24             	mov    %eax,(%esp)
 205:	e8 22 ff ff ff       	call   12c <stosb>
  return dst;
 20a:	8b 45 08             	mov    0x8(%ebp),%eax
}
 20d:	c9                   	leave  
 20e:	c3                   	ret    

0000020f <strchr>:

char*
strchr(const char *s, char c)
{
 20f:	55                   	push   %ebp
 210:	89 e5                	mov    %esp,%ebp
 212:	83 ec 04             	sub    $0x4,%esp
 215:	8b 45 0c             	mov    0xc(%ebp),%eax
 218:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 21b:	eb 14                	jmp    231 <strchr+0x22>
    if(*s == c)
 21d:	8b 45 08             	mov    0x8(%ebp),%eax
 220:	0f b6 00             	movzbl (%eax),%eax
 223:	3a 45 fc             	cmp    -0x4(%ebp),%al
 226:	75 05                	jne    22d <strchr+0x1e>
      return (char*)s;
 228:	8b 45 08             	mov    0x8(%ebp),%eax
 22b:	eb 13                	jmp    240 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 22d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 231:	8b 45 08             	mov    0x8(%ebp),%eax
 234:	0f b6 00             	movzbl (%eax),%eax
 237:	84 c0                	test   %al,%al
 239:	75 e2                	jne    21d <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 23b:	b8 00 00 00 00       	mov    $0x0,%eax
}
 240:	c9                   	leave  
 241:	c3                   	ret    

00000242 <gets>:

char*
gets(char *buf, int max)
{
 242:	55                   	push   %ebp
 243:	89 e5                	mov    %esp,%ebp
 245:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 248:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 24f:	eb 44                	jmp    295 <gets+0x53>
    cc = read(0, &c, 1);
 251:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 258:	00 
 259:	8d 45 ef             	lea    -0x11(%ebp),%eax
 25c:	89 44 24 04          	mov    %eax,0x4(%esp)
 260:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 267:	e8 3c 01 00 00       	call   3a8 <read>
 26c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 26f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 273:	7e 2d                	jle    2a2 <gets+0x60>
      break;
    buf[i++] = c;
 275:	8b 45 f4             	mov    -0xc(%ebp),%eax
 278:	03 45 08             	add    0x8(%ebp),%eax
 27b:	0f b6 55 ef          	movzbl -0x11(%ebp),%edx
 27f:	88 10                	mov    %dl,(%eax)
 281:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(c == '\n' || c == '\r')
 285:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 289:	3c 0a                	cmp    $0xa,%al
 28b:	74 16                	je     2a3 <gets+0x61>
 28d:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 291:	3c 0d                	cmp    $0xd,%al
 293:	74 0e                	je     2a3 <gets+0x61>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 295:	8b 45 f4             	mov    -0xc(%ebp),%eax
 298:	83 c0 01             	add    $0x1,%eax
 29b:	3b 45 0c             	cmp    0xc(%ebp),%eax
 29e:	7c b1                	jl     251 <gets+0xf>
 2a0:	eb 01                	jmp    2a3 <gets+0x61>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 2a2:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 2a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2a6:	03 45 08             	add    0x8(%ebp),%eax
 2a9:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 2ac:	8b 45 08             	mov    0x8(%ebp),%eax
}
 2af:	c9                   	leave  
 2b0:	c3                   	ret    

000002b1 <stat>:

int
stat(char *n, struct stat *st)
{
 2b1:	55                   	push   %ebp
 2b2:	89 e5                	mov    %esp,%ebp
 2b4:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2b7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 2be:	00 
 2bf:	8b 45 08             	mov    0x8(%ebp),%eax
 2c2:	89 04 24             	mov    %eax,(%esp)
 2c5:	e8 06 01 00 00       	call   3d0 <open>
 2ca:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 2cd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 2d1:	79 07                	jns    2da <stat+0x29>
    return -1;
 2d3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 2d8:	eb 23                	jmp    2fd <stat+0x4c>
  r = fstat(fd, st);
 2da:	8b 45 0c             	mov    0xc(%ebp),%eax
 2dd:	89 44 24 04          	mov    %eax,0x4(%esp)
 2e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2e4:	89 04 24             	mov    %eax,(%esp)
 2e7:	e8 fc 00 00 00       	call   3e8 <fstat>
 2ec:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 2ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2f2:	89 04 24             	mov    %eax,(%esp)
 2f5:	e8 be 00 00 00       	call   3b8 <close>
  return r;
 2fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 2fd:	c9                   	leave  
 2fe:	c3                   	ret    

000002ff <atoi>:

int
atoi(const char *s)
{
 2ff:	55                   	push   %ebp
 300:	89 e5                	mov    %esp,%ebp
 302:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 305:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 30c:	eb 23                	jmp    331 <atoi+0x32>
    n = n*10 + *s++ - '0';
 30e:	8b 55 fc             	mov    -0x4(%ebp),%edx
 311:	89 d0                	mov    %edx,%eax
 313:	c1 e0 02             	shl    $0x2,%eax
 316:	01 d0                	add    %edx,%eax
 318:	01 c0                	add    %eax,%eax
 31a:	89 c2                	mov    %eax,%edx
 31c:	8b 45 08             	mov    0x8(%ebp),%eax
 31f:	0f b6 00             	movzbl (%eax),%eax
 322:	0f be c0             	movsbl %al,%eax
 325:	01 d0                	add    %edx,%eax
 327:	83 e8 30             	sub    $0x30,%eax
 32a:	89 45 fc             	mov    %eax,-0x4(%ebp)
 32d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 331:	8b 45 08             	mov    0x8(%ebp),%eax
 334:	0f b6 00             	movzbl (%eax),%eax
 337:	3c 2f                	cmp    $0x2f,%al
 339:	7e 0a                	jle    345 <atoi+0x46>
 33b:	8b 45 08             	mov    0x8(%ebp),%eax
 33e:	0f b6 00             	movzbl (%eax),%eax
 341:	3c 39                	cmp    $0x39,%al
 343:	7e c9                	jle    30e <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 345:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 348:	c9                   	leave  
 349:	c3                   	ret    

0000034a <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 34a:	55                   	push   %ebp
 34b:	89 e5                	mov    %esp,%ebp
 34d:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 350:	8b 45 08             	mov    0x8(%ebp),%eax
 353:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 356:	8b 45 0c             	mov    0xc(%ebp),%eax
 359:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 35c:	eb 13                	jmp    371 <memmove+0x27>
    *dst++ = *src++;
 35e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 361:	0f b6 10             	movzbl (%eax),%edx
 364:	8b 45 fc             	mov    -0x4(%ebp),%eax
 367:	88 10                	mov    %dl,(%eax)
 369:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 36d:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 371:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 375:	0f 9f c0             	setg   %al
 378:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 37c:	84 c0                	test   %al,%al
 37e:	75 de                	jne    35e <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 380:	8b 45 08             	mov    0x8(%ebp),%eax
}
 383:	c9                   	leave  
 384:	c3                   	ret    
 385:	90                   	nop
 386:	90                   	nop
 387:	90                   	nop

00000388 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 388:	b8 01 00 00 00       	mov    $0x1,%eax
 38d:	cd 40                	int    $0x40
 38f:	c3                   	ret    

00000390 <exit>:
SYSCALL(exit)
 390:	b8 02 00 00 00       	mov    $0x2,%eax
 395:	cd 40                	int    $0x40
 397:	c3                   	ret    

00000398 <wait>:
SYSCALL(wait)
 398:	b8 03 00 00 00       	mov    $0x3,%eax
 39d:	cd 40                	int    $0x40
 39f:	c3                   	ret    

000003a0 <pipe>:
SYSCALL(pipe)
 3a0:	b8 04 00 00 00       	mov    $0x4,%eax
 3a5:	cd 40                	int    $0x40
 3a7:	c3                   	ret    

000003a8 <read>:
SYSCALL(read)
 3a8:	b8 05 00 00 00       	mov    $0x5,%eax
 3ad:	cd 40                	int    $0x40
 3af:	c3                   	ret    

000003b0 <write>:
SYSCALL(write)
 3b0:	b8 10 00 00 00       	mov    $0x10,%eax
 3b5:	cd 40                	int    $0x40
 3b7:	c3                   	ret    

000003b8 <close>:
SYSCALL(close)
 3b8:	b8 15 00 00 00       	mov    $0x15,%eax
 3bd:	cd 40                	int    $0x40
 3bf:	c3                   	ret    

000003c0 <kill>:
SYSCALL(kill)
 3c0:	b8 06 00 00 00       	mov    $0x6,%eax
 3c5:	cd 40                	int    $0x40
 3c7:	c3                   	ret    

000003c8 <exec>:
SYSCALL(exec)
 3c8:	b8 07 00 00 00       	mov    $0x7,%eax
 3cd:	cd 40                	int    $0x40
 3cf:	c3                   	ret    

000003d0 <open>:
SYSCALL(open)
 3d0:	b8 0f 00 00 00       	mov    $0xf,%eax
 3d5:	cd 40                	int    $0x40
 3d7:	c3                   	ret    

000003d8 <mknod>:
SYSCALL(mknod)
 3d8:	b8 11 00 00 00       	mov    $0x11,%eax
 3dd:	cd 40                	int    $0x40
 3df:	c3                   	ret    

000003e0 <unlink>:
SYSCALL(unlink)
 3e0:	b8 12 00 00 00       	mov    $0x12,%eax
 3e5:	cd 40                	int    $0x40
 3e7:	c3                   	ret    

000003e8 <fstat>:
SYSCALL(fstat)
 3e8:	b8 08 00 00 00       	mov    $0x8,%eax
 3ed:	cd 40                	int    $0x40
 3ef:	c3                   	ret    

000003f0 <link>:
SYSCALL(link)
 3f0:	b8 13 00 00 00       	mov    $0x13,%eax
 3f5:	cd 40                	int    $0x40
 3f7:	c3                   	ret    

000003f8 <mkdir>:
SYSCALL(mkdir)
 3f8:	b8 14 00 00 00       	mov    $0x14,%eax
 3fd:	cd 40                	int    $0x40
 3ff:	c3                   	ret    

00000400 <chdir>:
SYSCALL(chdir)
 400:	b8 09 00 00 00       	mov    $0x9,%eax
 405:	cd 40                	int    $0x40
 407:	c3                   	ret    

00000408 <dup>:
SYSCALL(dup)
 408:	b8 0a 00 00 00       	mov    $0xa,%eax
 40d:	cd 40                	int    $0x40
 40f:	c3                   	ret    

00000410 <getpid>:
SYSCALL(getpid)
 410:	b8 0b 00 00 00       	mov    $0xb,%eax
 415:	cd 40                	int    $0x40
 417:	c3                   	ret    

00000418 <sbrk>:
SYSCALL(sbrk)
 418:	b8 0c 00 00 00       	mov    $0xc,%eax
 41d:	cd 40                	int    $0x40
 41f:	c3                   	ret    

00000420 <sleep>:
SYSCALL(sleep)
 420:	b8 0d 00 00 00       	mov    $0xd,%eax
 425:	cd 40                	int    $0x40
 427:	c3                   	ret    

00000428 <uptime>:
SYSCALL(uptime)
 428:	b8 0e 00 00 00       	mov    $0xe,%eax
 42d:	cd 40                	int    $0x40
 42f:	c3                   	ret    

00000430 <waitpid>:
SYSCALL(waitpid)
 430:	b8 16 00 00 00       	mov    $0x16,%eax
 435:	cd 40                	int    $0x40
 437:	c3                   	ret    

00000438 <wait_stat>:
SYSCALL(wait_stat)
 438:	b8 17 00 00 00       	mov    $0x17,%eax
 43d:	cd 40                	int    $0x40
 43f:	c3                   	ret    

00000440 <list_pgroup>:
SYSCALL(list_pgroup)
 440:	b8 18 00 00 00       	mov    $0x18,%eax
 445:	cd 40                	int    $0x40
 447:	c3                   	ret    

00000448 <foreground>:
SYSCALL(foreground)
 448:	b8 19 00 00 00       	mov    $0x19,%eax
 44d:	cd 40                	int    $0x40
 44f:	c3                   	ret    

00000450 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 450:	55                   	push   %ebp
 451:	89 e5                	mov    %esp,%ebp
 453:	83 ec 28             	sub    $0x28,%esp
 456:	8b 45 0c             	mov    0xc(%ebp),%eax
 459:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 45c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 463:	00 
 464:	8d 45 f4             	lea    -0xc(%ebp),%eax
 467:	89 44 24 04          	mov    %eax,0x4(%esp)
 46b:	8b 45 08             	mov    0x8(%ebp),%eax
 46e:	89 04 24             	mov    %eax,(%esp)
 471:	e8 3a ff ff ff       	call   3b0 <write>
}
 476:	c9                   	leave  
 477:	c3                   	ret    

00000478 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 478:	55                   	push   %ebp
 479:	89 e5                	mov    %esp,%ebp
 47b:	83 ec 48             	sub    $0x48,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 47e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 485:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 489:	74 17                	je     4a2 <printint+0x2a>
 48b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 48f:	79 11                	jns    4a2 <printint+0x2a>
    neg = 1;
 491:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 498:	8b 45 0c             	mov    0xc(%ebp),%eax
 49b:	f7 d8                	neg    %eax
 49d:	89 45 ec             	mov    %eax,-0x14(%ebp)
 4a0:	eb 06                	jmp    4a8 <printint+0x30>
  } else {
    x = xx;
 4a2:	8b 45 0c             	mov    0xc(%ebp),%eax
 4a5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 4a8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 4af:	8b 4d 10             	mov    0x10(%ebp),%ecx
 4b2:	8b 45 ec             	mov    -0x14(%ebp),%eax
 4b5:	ba 00 00 00 00       	mov    $0x0,%edx
 4ba:	f7 f1                	div    %ecx
 4bc:	89 d0                	mov    %edx,%eax
 4be:	0f b6 90 88 0b 00 00 	movzbl 0xb88(%eax),%edx
 4c5:	8d 45 dc             	lea    -0x24(%ebp),%eax
 4c8:	03 45 f4             	add    -0xc(%ebp),%eax
 4cb:	88 10                	mov    %dl,(%eax)
 4cd:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  }while((x /= base) != 0);
 4d1:	8b 55 10             	mov    0x10(%ebp),%edx
 4d4:	89 55 d4             	mov    %edx,-0x2c(%ebp)
 4d7:	8b 45 ec             	mov    -0x14(%ebp),%eax
 4da:	ba 00 00 00 00       	mov    $0x0,%edx
 4df:	f7 75 d4             	divl   -0x2c(%ebp)
 4e2:	89 45 ec             	mov    %eax,-0x14(%ebp)
 4e5:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 4e9:	75 c4                	jne    4af <printint+0x37>
  if(neg)
 4eb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 4ef:	74 2a                	je     51b <printint+0xa3>
    buf[i++] = '-';
 4f1:	8d 45 dc             	lea    -0x24(%ebp),%eax
 4f4:	03 45 f4             	add    -0xc(%ebp),%eax
 4f7:	c6 00 2d             	movb   $0x2d,(%eax)
 4fa:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

  while(--i >= 0)
 4fe:	eb 1b                	jmp    51b <printint+0xa3>
    putc(fd, buf[i]);
 500:	8d 45 dc             	lea    -0x24(%ebp),%eax
 503:	03 45 f4             	add    -0xc(%ebp),%eax
 506:	0f b6 00             	movzbl (%eax),%eax
 509:	0f be c0             	movsbl %al,%eax
 50c:	89 44 24 04          	mov    %eax,0x4(%esp)
 510:	8b 45 08             	mov    0x8(%ebp),%eax
 513:	89 04 24             	mov    %eax,(%esp)
 516:	e8 35 ff ff ff       	call   450 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 51b:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 51f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 523:	79 db                	jns    500 <printint+0x88>
    putc(fd, buf[i]);
}
 525:	c9                   	leave  
 526:	c3                   	ret    

00000527 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 527:	55                   	push   %ebp
 528:	89 e5                	mov    %esp,%ebp
 52a:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 52d:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 534:	8d 45 0c             	lea    0xc(%ebp),%eax
 537:	83 c0 04             	add    $0x4,%eax
 53a:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 53d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 544:	e9 7d 01 00 00       	jmp    6c6 <printf+0x19f>
    c = fmt[i] & 0xff;
 549:	8b 55 0c             	mov    0xc(%ebp),%edx
 54c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 54f:	01 d0                	add    %edx,%eax
 551:	0f b6 00             	movzbl (%eax),%eax
 554:	0f be c0             	movsbl %al,%eax
 557:	25 ff 00 00 00       	and    $0xff,%eax
 55c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 55f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 563:	75 2c                	jne    591 <printf+0x6a>
      if(c == '%'){
 565:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 569:	75 0c                	jne    577 <printf+0x50>
        state = '%';
 56b:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 572:	e9 4b 01 00 00       	jmp    6c2 <printf+0x19b>
      } else {
        putc(fd, c);
 577:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 57a:	0f be c0             	movsbl %al,%eax
 57d:	89 44 24 04          	mov    %eax,0x4(%esp)
 581:	8b 45 08             	mov    0x8(%ebp),%eax
 584:	89 04 24             	mov    %eax,(%esp)
 587:	e8 c4 fe ff ff       	call   450 <putc>
 58c:	e9 31 01 00 00       	jmp    6c2 <printf+0x19b>
      }
    } else if(state == '%'){
 591:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 595:	0f 85 27 01 00 00    	jne    6c2 <printf+0x19b>
      if(c == 'd'){
 59b:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 59f:	75 2d                	jne    5ce <printf+0xa7>
        printint(fd, *ap, 10, 1);
 5a1:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5a4:	8b 00                	mov    (%eax),%eax
 5a6:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 5ad:	00 
 5ae:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 5b5:	00 
 5b6:	89 44 24 04          	mov    %eax,0x4(%esp)
 5ba:	8b 45 08             	mov    0x8(%ebp),%eax
 5bd:	89 04 24             	mov    %eax,(%esp)
 5c0:	e8 b3 fe ff ff       	call   478 <printint>
        ap++;
 5c5:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 5c9:	e9 ed 00 00 00       	jmp    6bb <printf+0x194>
      } else if(c == 'x' || c == 'p'){
 5ce:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 5d2:	74 06                	je     5da <printf+0xb3>
 5d4:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 5d8:	75 2d                	jne    607 <printf+0xe0>
        printint(fd, *ap, 16, 0);
 5da:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5dd:	8b 00                	mov    (%eax),%eax
 5df:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 5e6:	00 
 5e7:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 5ee:	00 
 5ef:	89 44 24 04          	mov    %eax,0x4(%esp)
 5f3:	8b 45 08             	mov    0x8(%ebp),%eax
 5f6:	89 04 24             	mov    %eax,(%esp)
 5f9:	e8 7a fe ff ff       	call   478 <printint>
        ap++;
 5fe:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 602:	e9 b4 00 00 00       	jmp    6bb <printf+0x194>
      } else if(c == 's'){
 607:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 60b:	75 46                	jne    653 <printf+0x12c>
        s = (char*)*ap;
 60d:	8b 45 e8             	mov    -0x18(%ebp),%eax
 610:	8b 00                	mov    (%eax),%eax
 612:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 615:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 619:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 61d:	75 27                	jne    646 <printf+0x11f>
          s = "(null)";
 61f:	c7 45 f4 3b 09 00 00 	movl   $0x93b,-0xc(%ebp)
        while(*s != 0){
 626:	eb 1e                	jmp    646 <printf+0x11f>
          putc(fd, *s);
 628:	8b 45 f4             	mov    -0xc(%ebp),%eax
 62b:	0f b6 00             	movzbl (%eax),%eax
 62e:	0f be c0             	movsbl %al,%eax
 631:	89 44 24 04          	mov    %eax,0x4(%esp)
 635:	8b 45 08             	mov    0x8(%ebp),%eax
 638:	89 04 24             	mov    %eax,(%esp)
 63b:	e8 10 fe ff ff       	call   450 <putc>
          s++;
 640:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 644:	eb 01                	jmp    647 <printf+0x120>
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 646:	90                   	nop
 647:	8b 45 f4             	mov    -0xc(%ebp),%eax
 64a:	0f b6 00             	movzbl (%eax),%eax
 64d:	84 c0                	test   %al,%al
 64f:	75 d7                	jne    628 <printf+0x101>
 651:	eb 68                	jmp    6bb <printf+0x194>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 653:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 657:	75 1d                	jne    676 <printf+0x14f>
        putc(fd, *ap);
 659:	8b 45 e8             	mov    -0x18(%ebp),%eax
 65c:	8b 00                	mov    (%eax),%eax
 65e:	0f be c0             	movsbl %al,%eax
 661:	89 44 24 04          	mov    %eax,0x4(%esp)
 665:	8b 45 08             	mov    0x8(%ebp),%eax
 668:	89 04 24             	mov    %eax,(%esp)
 66b:	e8 e0 fd ff ff       	call   450 <putc>
        ap++;
 670:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 674:	eb 45                	jmp    6bb <printf+0x194>
      } else if(c == '%'){
 676:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 67a:	75 17                	jne    693 <printf+0x16c>
        putc(fd, c);
 67c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 67f:	0f be c0             	movsbl %al,%eax
 682:	89 44 24 04          	mov    %eax,0x4(%esp)
 686:	8b 45 08             	mov    0x8(%ebp),%eax
 689:	89 04 24             	mov    %eax,(%esp)
 68c:	e8 bf fd ff ff       	call   450 <putc>
 691:	eb 28                	jmp    6bb <printf+0x194>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 693:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 69a:	00 
 69b:	8b 45 08             	mov    0x8(%ebp),%eax
 69e:	89 04 24             	mov    %eax,(%esp)
 6a1:	e8 aa fd ff ff       	call   450 <putc>
        putc(fd, c);
 6a6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 6a9:	0f be c0             	movsbl %al,%eax
 6ac:	89 44 24 04          	mov    %eax,0x4(%esp)
 6b0:	8b 45 08             	mov    0x8(%ebp),%eax
 6b3:	89 04 24             	mov    %eax,(%esp)
 6b6:	e8 95 fd ff ff       	call   450 <putc>
      }
      state = 0;
 6bb:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 6c2:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 6c6:	8b 55 0c             	mov    0xc(%ebp),%edx
 6c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6cc:	01 d0                	add    %edx,%eax
 6ce:	0f b6 00             	movzbl (%eax),%eax
 6d1:	84 c0                	test   %al,%al
 6d3:	0f 85 70 fe ff ff    	jne    549 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 6d9:	c9                   	leave  
 6da:	c3                   	ret    
 6db:	90                   	nop

000006dc <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 6dc:	55                   	push   %ebp
 6dd:	89 e5                	mov    %esp,%ebp
 6df:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 6e2:	8b 45 08             	mov    0x8(%ebp),%eax
 6e5:	83 e8 08             	sub    $0x8,%eax
 6e8:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6eb:	a1 a4 0b 00 00       	mov    0xba4,%eax
 6f0:	89 45 fc             	mov    %eax,-0x4(%ebp)
 6f3:	eb 24                	jmp    719 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6f5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6f8:	8b 00                	mov    (%eax),%eax
 6fa:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 6fd:	77 12                	ja     711 <free+0x35>
 6ff:	8b 45 f8             	mov    -0x8(%ebp),%eax
 702:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 705:	77 24                	ja     72b <free+0x4f>
 707:	8b 45 fc             	mov    -0x4(%ebp),%eax
 70a:	8b 00                	mov    (%eax),%eax
 70c:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 70f:	77 1a                	ja     72b <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 711:	8b 45 fc             	mov    -0x4(%ebp),%eax
 714:	8b 00                	mov    (%eax),%eax
 716:	89 45 fc             	mov    %eax,-0x4(%ebp)
 719:	8b 45 f8             	mov    -0x8(%ebp),%eax
 71c:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 71f:	76 d4                	jbe    6f5 <free+0x19>
 721:	8b 45 fc             	mov    -0x4(%ebp),%eax
 724:	8b 00                	mov    (%eax),%eax
 726:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 729:	76 ca                	jbe    6f5 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 72b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 72e:	8b 40 04             	mov    0x4(%eax),%eax
 731:	c1 e0 03             	shl    $0x3,%eax
 734:	89 c2                	mov    %eax,%edx
 736:	03 55 f8             	add    -0x8(%ebp),%edx
 739:	8b 45 fc             	mov    -0x4(%ebp),%eax
 73c:	8b 00                	mov    (%eax),%eax
 73e:	39 c2                	cmp    %eax,%edx
 740:	75 24                	jne    766 <free+0x8a>
    bp->s.size += p->s.ptr->s.size;
 742:	8b 45 f8             	mov    -0x8(%ebp),%eax
 745:	8b 50 04             	mov    0x4(%eax),%edx
 748:	8b 45 fc             	mov    -0x4(%ebp),%eax
 74b:	8b 00                	mov    (%eax),%eax
 74d:	8b 40 04             	mov    0x4(%eax),%eax
 750:	01 c2                	add    %eax,%edx
 752:	8b 45 f8             	mov    -0x8(%ebp),%eax
 755:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 758:	8b 45 fc             	mov    -0x4(%ebp),%eax
 75b:	8b 00                	mov    (%eax),%eax
 75d:	8b 10                	mov    (%eax),%edx
 75f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 762:	89 10                	mov    %edx,(%eax)
 764:	eb 0a                	jmp    770 <free+0x94>
  } else
    bp->s.ptr = p->s.ptr;
 766:	8b 45 fc             	mov    -0x4(%ebp),%eax
 769:	8b 10                	mov    (%eax),%edx
 76b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 76e:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 770:	8b 45 fc             	mov    -0x4(%ebp),%eax
 773:	8b 40 04             	mov    0x4(%eax),%eax
 776:	c1 e0 03             	shl    $0x3,%eax
 779:	03 45 fc             	add    -0x4(%ebp),%eax
 77c:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 77f:	75 20                	jne    7a1 <free+0xc5>
    p->s.size += bp->s.size;
 781:	8b 45 fc             	mov    -0x4(%ebp),%eax
 784:	8b 50 04             	mov    0x4(%eax),%edx
 787:	8b 45 f8             	mov    -0x8(%ebp),%eax
 78a:	8b 40 04             	mov    0x4(%eax),%eax
 78d:	01 c2                	add    %eax,%edx
 78f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 792:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 795:	8b 45 f8             	mov    -0x8(%ebp),%eax
 798:	8b 10                	mov    (%eax),%edx
 79a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 79d:	89 10                	mov    %edx,(%eax)
 79f:	eb 08                	jmp    7a9 <free+0xcd>
  } else
    p->s.ptr = bp;
 7a1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7a4:	8b 55 f8             	mov    -0x8(%ebp),%edx
 7a7:	89 10                	mov    %edx,(%eax)
  freep = p;
 7a9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7ac:	a3 a4 0b 00 00       	mov    %eax,0xba4
}
 7b1:	c9                   	leave  
 7b2:	c3                   	ret    

000007b3 <morecore>:

static Header*
morecore(uint nu)
{
 7b3:	55                   	push   %ebp
 7b4:	89 e5                	mov    %esp,%ebp
 7b6:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 7b9:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 7c0:	77 07                	ja     7c9 <morecore+0x16>
    nu = 4096;
 7c2:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 7c9:	8b 45 08             	mov    0x8(%ebp),%eax
 7cc:	c1 e0 03             	shl    $0x3,%eax
 7cf:	89 04 24             	mov    %eax,(%esp)
 7d2:	e8 41 fc ff ff       	call   418 <sbrk>
 7d7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 7da:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 7de:	75 07                	jne    7e7 <morecore+0x34>
    return 0;
 7e0:	b8 00 00 00 00       	mov    $0x0,%eax
 7e5:	eb 22                	jmp    809 <morecore+0x56>
  hp = (Header*)p;
 7e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7ea:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 7ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7f0:	8b 55 08             	mov    0x8(%ebp),%edx
 7f3:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 7f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7f9:	83 c0 08             	add    $0x8,%eax
 7fc:	89 04 24             	mov    %eax,(%esp)
 7ff:	e8 d8 fe ff ff       	call   6dc <free>
  return freep;
 804:	a1 a4 0b 00 00       	mov    0xba4,%eax
}
 809:	c9                   	leave  
 80a:	c3                   	ret    

0000080b <malloc>:

void*
malloc(uint nbytes)
{
 80b:	55                   	push   %ebp
 80c:	89 e5                	mov    %esp,%ebp
 80e:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 811:	8b 45 08             	mov    0x8(%ebp),%eax
 814:	83 c0 07             	add    $0x7,%eax
 817:	c1 e8 03             	shr    $0x3,%eax
 81a:	83 c0 01             	add    $0x1,%eax
 81d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 820:	a1 a4 0b 00 00       	mov    0xba4,%eax
 825:	89 45 f0             	mov    %eax,-0x10(%ebp)
 828:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 82c:	75 23                	jne    851 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 82e:	c7 45 f0 9c 0b 00 00 	movl   $0xb9c,-0x10(%ebp)
 835:	8b 45 f0             	mov    -0x10(%ebp),%eax
 838:	a3 a4 0b 00 00       	mov    %eax,0xba4
 83d:	a1 a4 0b 00 00       	mov    0xba4,%eax
 842:	a3 9c 0b 00 00       	mov    %eax,0xb9c
    base.s.size = 0;
 847:	c7 05 a0 0b 00 00 00 	movl   $0x0,0xba0
 84e:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 851:	8b 45 f0             	mov    -0x10(%ebp),%eax
 854:	8b 00                	mov    (%eax),%eax
 856:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 859:	8b 45 f4             	mov    -0xc(%ebp),%eax
 85c:	8b 40 04             	mov    0x4(%eax),%eax
 85f:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 862:	72 4d                	jb     8b1 <malloc+0xa6>
      if(p->s.size == nunits)
 864:	8b 45 f4             	mov    -0xc(%ebp),%eax
 867:	8b 40 04             	mov    0x4(%eax),%eax
 86a:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 86d:	75 0c                	jne    87b <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 86f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 872:	8b 10                	mov    (%eax),%edx
 874:	8b 45 f0             	mov    -0x10(%ebp),%eax
 877:	89 10                	mov    %edx,(%eax)
 879:	eb 26                	jmp    8a1 <malloc+0x96>
      else {
        p->s.size -= nunits;
 87b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 87e:	8b 40 04             	mov    0x4(%eax),%eax
 881:	89 c2                	mov    %eax,%edx
 883:	2b 55 ec             	sub    -0x14(%ebp),%edx
 886:	8b 45 f4             	mov    -0xc(%ebp),%eax
 889:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 88c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 88f:	8b 40 04             	mov    0x4(%eax),%eax
 892:	c1 e0 03             	shl    $0x3,%eax
 895:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 898:	8b 45 f4             	mov    -0xc(%ebp),%eax
 89b:	8b 55 ec             	mov    -0x14(%ebp),%edx
 89e:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 8a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8a4:	a3 a4 0b 00 00       	mov    %eax,0xba4
      return (void*)(p + 1);
 8a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8ac:	83 c0 08             	add    $0x8,%eax
 8af:	eb 38                	jmp    8e9 <malloc+0xde>
    }
    if(p == freep)
 8b1:	a1 a4 0b 00 00       	mov    0xba4,%eax
 8b6:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 8b9:	75 1b                	jne    8d6 <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 8bb:	8b 45 ec             	mov    -0x14(%ebp),%eax
 8be:	89 04 24             	mov    %eax,(%esp)
 8c1:	e8 ed fe ff ff       	call   7b3 <morecore>
 8c6:	89 45 f4             	mov    %eax,-0xc(%ebp)
 8c9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 8cd:	75 07                	jne    8d6 <malloc+0xcb>
        return 0;
 8cf:	b8 00 00 00 00       	mov    $0x0,%eax
 8d4:	eb 13                	jmp    8e9 <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8d9:	89 45 f0             	mov    %eax,-0x10(%ebp)
 8dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8df:	8b 00                	mov    (%eax),%eax
 8e1:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 8e4:	e9 70 ff ff ff       	jmp    859 <malloc+0x4e>
}
 8e9:	c9                   	leave  
 8ea:	c3                   	ret    
