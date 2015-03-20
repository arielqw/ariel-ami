
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
  11:	c7 04 24 c6 08 00 00 	movl   $0x8c6,(%esp)
  18:	e8 ab 03 00 00       	call   3c8 <open>
  1d:	85 c0                	test   %eax,%eax
  1f:	79 30                	jns    51 <main+0x51>
    mknod("console", 1, 1);
  21:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  28:	00 
  29:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  30:	00 
  31:	c7 04 24 c6 08 00 00 	movl   $0x8c6,(%esp)
  38:	e8 93 03 00 00       	call   3d0 <mknod>
    open("console", O_RDWR);
  3d:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  44:	00 
  45:	c7 04 24 c6 08 00 00 	movl   $0x8c6,(%esp)
  4c:	e8 77 03 00 00       	call   3c8 <open>
  }
  dup(0);  // stdout
  51:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  58:	e8 a3 03 00 00       	call   400 <dup>
  dup(0);  // stderr
  5d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  64:	e8 97 03 00 00       	call   400 <dup>
  69:	eb 01                	jmp    6c <main+0x6c>
      printf(1, "init: exec sh failed\n");
      exit(EXIT_STATUS_DEFAULT);
    }
    while((wpid=wait()) >= 0 && wpid != pid)
      printf(1, "zombie!\n");
  }
  6b:	90                   	nop
  }
  dup(0);  // stdout
  dup(0);  // stderr

  for(;;){
    printf(1, "init: starting sh\n");
  6c:	c7 44 24 04 ce 08 00 	movl   $0x8ce,0x4(%esp)
  73:	00 
  74:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  7b:	e8 7f 04 00 00       	call   4ff <printf>
    pid = fork();
  80:	e8 fb 02 00 00       	call   380 <fork>
  85:	89 44 24 1c          	mov    %eax,0x1c(%esp)
    if(pid < 0){
  89:	83 7c 24 1c 00       	cmpl   $0x0,0x1c(%esp)
  8e:	79 20                	jns    b0 <main+0xb0>
      printf(1, "init: fork failed\n");
  90:	c7 44 24 04 e1 08 00 	movl   $0x8e1,0x4(%esp)
  97:	00 
  98:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  9f:	e8 5b 04 00 00       	call   4ff <printf>
      exit(EXIT_STATUS_DEFAULT);
  a4:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  ab:	e8 d8 02 00 00       	call   388 <exit>
    }
    if(pid == 0){
  b0:	83 7c 24 1c 00       	cmpl   $0x0,0x1c(%esp)
  b5:	75 48                	jne    ff <main+0xff>
      exec("sh", argv);
  b7:	c7 44 24 04 58 0b 00 	movl   $0xb58,0x4(%esp)
  be:	00 
  bf:	c7 04 24 c3 08 00 00 	movl   $0x8c3,(%esp)
  c6:	e8 f5 02 00 00       	call   3c0 <exec>
      printf(1, "init: exec sh failed\n");
  cb:	c7 44 24 04 f4 08 00 	movl   $0x8f4,0x4(%esp)
  d2:	00 
  d3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  da:	e8 20 04 00 00       	call   4ff <printf>
      exit(EXIT_STATUS_DEFAULT);
  df:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  e6:	e8 9d 02 00 00       	call   388 <exit>
    }
    while((wpid=wait()) >= 0 && wpid != pid)
      printf(1, "zombie!\n");
  eb:	c7 44 24 04 0a 09 00 	movl   $0x90a,0x4(%esp)
  f2:	00 
  f3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  fa:	e8 00 04 00 00       	call   4ff <printf>
    if(pid == 0){
      exec("sh", argv);
      printf(1, "init: exec sh failed\n");
      exit(EXIT_STATUS_DEFAULT);
    }
    while((wpid=wait()) >= 0 && wpid != pid)
  ff:	e8 8c 02 00 00       	call   390 <wait>
 104:	89 44 24 18          	mov    %eax,0x18(%esp)
 108:	83 7c 24 18 00       	cmpl   $0x0,0x18(%esp)
 10d:	0f 88 58 ff ff ff    	js     6b <main+0x6b>
 113:	8b 44 24 18          	mov    0x18(%esp),%eax
 117:	3b 44 24 1c          	cmp    0x1c(%esp),%eax
 11b:	75 ce                	jne    eb <main+0xeb>
      printf(1, "zombie!\n");
  }
 11d:	e9 49 ff ff ff       	jmp    6b <main+0x6b>
 122:	90                   	nop
 123:	90                   	nop

00000124 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 124:	55                   	push   %ebp
 125:	89 e5                	mov    %esp,%ebp
 127:	57                   	push   %edi
 128:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 129:	8b 4d 08             	mov    0x8(%ebp),%ecx
 12c:	8b 55 10             	mov    0x10(%ebp),%edx
 12f:	8b 45 0c             	mov    0xc(%ebp),%eax
 132:	89 cb                	mov    %ecx,%ebx
 134:	89 df                	mov    %ebx,%edi
 136:	89 d1                	mov    %edx,%ecx
 138:	fc                   	cld    
 139:	f3 aa                	rep stos %al,%es:(%edi)
 13b:	89 ca                	mov    %ecx,%edx
 13d:	89 fb                	mov    %edi,%ebx
 13f:	89 5d 08             	mov    %ebx,0x8(%ebp)
 142:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 145:	5b                   	pop    %ebx
 146:	5f                   	pop    %edi
 147:	5d                   	pop    %ebp
 148:	c3                   	ret    

00000149 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 149:	55                   	push   %ebp
 14a:	89 e5                	mov    %esp,%ebp
 14c:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 14f:	8b 45 08             	mov    0x8(%ebp),%eax
 152:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 155:	90                   	nop
 156:	8b 45 0c             	mov    0xc(%ebp),%eax
 159:	0f b6 10             	movzbl (%eax),%edx
 15c:	8b 45 08             	mov    0x8(%ebp),%eax
 15f:	88 10                	mov    %dl,(%eax)
 161:	8b 45 08             	mov    0x8(%ebp),%eax
 164:	0f b6 00             	movzbl (%eax),%eax
 167:	84 c0                	test   %al,%al
 169:	0f 95 c0             	setne  %al
 16c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 170:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 174:	84 c0                	test   %al,%al
 176:	75 de                	jne    156 <strcpy+0xd>
    ;
  return os;
 178:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 17b:	c9                   	leave  
 17c:	c3                   	ret    

0000017d <strcmp>:

int
strcmp(const char *p, const char *q)
{
 17d:	55                   	push   %ebp
 17e:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 180:	eb 08                	jmp    18a <strcmp+0xd>
    p++, q++;
 182:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 186:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 18a:	8b 45 08             	mov    0x8(%ebp),%eax
 18d:	0f b6 00             	movzbl (%eax),%eax
 190:	84 c0                	test   %al,%al
 192:	74 10                	je     1a4 <strcmp+0x27>
 194:	8b 45 08             	mov    0x8(%ebp),%eax
 197:	0f b6 10             	movzbl (%eax),%edx
 19a:	8b 45 0c             	mov    0xc(%ebp),%eax
 19d:	0f b6 00             	movzbl (%eax),%eax
 1a0:	38 c2                	cmp    %al,%dl
 1a2:	74 de                	je     182 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 1a4:	8b 45 08             	mov    0x8(%ebp),%eax
 1a7:	0f b6 00             	movzbl (%eax),%eax
 1aa:	0f b6 d0             	movzbl %al,%edx
 1ad:	8b 45 0c             	mov    0xc(%ebp),%eax
 1b0:	0f b6 00             	movzbl (%eax),%eax
 1b3:	0f b6 c0             	movzbl %al,%eax
 1b6:	89 d1                	mov    %edx,%ecx
 1b8:	29 c1                	sub    %eax,%ecx
 1ba:	89 c8                	mov    %ecx,%eax
}
 1bc:	5d                   	pop    %ebp
 1bd:	c3                   	ret    

000001be <strlen>:

uint
strlen(char *s)
{
 1be:	55                   	push   %ebp
 1bf:	89 e5                	mov    %esp,%ebp
 1c1:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 1c4:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 1cb:	eb 04                	jmp    1d1 <strlen+0x13>
 1cd:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 1d1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 1d4:	03 45 08             	add    0x8(%ebp),%eax
 1d7:	0f b6 00             	movzbl (%eax),%eax
 1da:	84 c0                	test   %al,%al
 1dc:	75 ef                	jne    1cd <strlen+0xf>
    ;
  return n;
 1de:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 1e1:	c9                   	leave  
 1e2:	c3                   	ret    

000001e3 <memset>:

void*
memset(void *dst, int c, uint n)
{
 1e3:	55                   	push   %ebp
 1e4:	89 e5                	mov    %esp,%ebp
 1e6:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 1e9:	8b 45 10             	mov    0x10(%ebp),%eax
 1ec:	89 44 24 08          	mov    %eax,0x8(%esp)
 1f0:	8b 45 0c             	mov    0xc(%ebp),%eax
 1f3:	89 44 24 04          	mov    %eax,0x4(%esp)
 1f7:	8b 45 08             	mov    0x8(%ebp),%eax
 1fa:	89 04 24             	mov    %eax,(%esp)
 1fd:	e8 22 ff ff ff       	call   124 <stosb>
  return dst;
 202:	8b 45 08             	mov    0x8(%ebp),%eax
}
 205:	c9                   	leave  
 206:	c3                   	ret    

00000207 <strchr>:

char*
strchr(const char *s, char c)
{
 207:	55                   	push   %ebp
 208:	89 e5                	mov    %esp,%ebp
 20a:	83 ec 04             	sub    $0x4,%esp
 20d:	8b 45 0c             	mov    0xc(%ebp),%eax
 210:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 213:	eb 14                	jmp    229 <strchr+0x22>
    if(*s == c)
 215:	8b 45 08             	mov    0x8(%ebp),%eax
 218:	0f b6 00             	movzbl (%eax),%eax
 21b:	3a 45 fc             	cmp    -0x4(%ebp),%al
 21e:	75 05                	jne    225 <strchr+0x1e>
      return (char*)s;
 220:	8b 45 08             	mov    0x8(%ebp),%eax
 223:	eb 13                	jmp    238 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 225:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 229:	8b 45 08             	mov    0x8(%ebp),%eax
 22c:	0f b6 00             	movzbl (%eax),%eax
 22f:	84 c0                	test   %al,%al
 231:	75 e2                	jne    215 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 233:	b8 00 00 00 00       	mov    $0x0,%eax
}
 238:	c9                   	leave  
 239:	c3                   	ret    

0000023a <gets>:

char*
gets(char *buf, int max)
{
 23a:	55                   	push   %ebp
 23b:	89 e5                	mov    %esp,%ebp
 23d:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 240:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 247:	eb 44                	jmp    28d <gets+0x53>
    cc = read(0, &c, 1);
 249:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 250:	00 
 251:	8d 45 ef             	lea    -0x11(%ebp),%eax
 254:	89 44 24 04          	mov    %eax,0x4(%esp)
 258:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 25f:	e8 3c 01 00 00       	call   3a0 <read>
 264:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 267:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 26b:	7e 2d                	jle    29a <gets+0x60>
      break;
    buf[i++] = c;
 26d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 270:	03 45 08             	add    0x8(%ebp),%eax
 273:	0f b6 55 ef          	movzbl -0x11(%ebp),%edx
 277:	88 10                	mov    %dl,(%eax)
 279:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(c == '\n' || c == '\r')
 27d:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 281:	3c 0a                	cmp    $0xa,%al
 283:	74 16                	je     29b <gets+0x61>
 285:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 289:	3c 0d                	cmp    $0xd,%al
 28b:	74 0e                	je     29b <gets+0x61>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 28d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 290:	83 c0 01             	add    $0x1,%eax
 293:	3b 45 0c             	cmp    0xc(%ebp),%eax
 296:	7c b1                	jl     249 <gets+0xf>
 298:	eb 01                	jmp    29b <gets+0x61>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 29a:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 29b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 29e:	03 45 08             	add    0x8(%ebp),%eax
 2a1:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 2a4:	8b 45 08             	mov    0x8(%ebp),%eax
}
 2a7:	c9                   	leave  
 2a8:	c3                   	ret    

000002a9 <stat>:

int
stat(char *n, struct stat *st)
{
 2a9:	55                   	push   %ebp
 2aa:	89 e5                	mov    %esp,%ebp
 2ac:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2af:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 2b6:	00 
 2b7:	8b 45 08             	mov    0x8(%ebp),%eax
 2ba:	89 04 24             	mov    %eax,(%esp)
 2bd:	e8 06 01 00 00       	call   3c8 <open>
 2c2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 2c5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 2c9:	79 07                	jns    2d2 <stat+0x29>
    return -1;
 2cb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 2d0:	eb 23                	jmp    2f5 <stat+0x4c>
  r = fstat(fd, st);
 2d2:	8b 45 0c             	mov    0xc(%ebp),%eax
 2d5:	89 44 24 04          	mov    %eax,0x4(%esp)
 2d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2dc:	89 04 24             	mov    %eax,(%esp)
 2df:	e8 fc 00 00 00       	call   3e0 <fstat>
 2e4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 2e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2ea:	89 04 24             	mov    %eax,(%esp)
 2ed:	e8 be 00 00 00       	call   3b0 <close>
  return r;
 2f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 2f5:	c9                   	leave  
 2f6:	c3                   	ret    

000002f7 <atoi>:

int
atoi(const char *s)
{
 2f7:	55                   	push   %ebp
 2f8:	89 e5                	mov    %esp,%ebp
 2fa:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 2fd:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 304:	eb 23                	jmp    329 <atoi+0x32>
    n = n*10 + *s++ - '0';
 306:	8b 55 fc             	mov    -0x4(%ebp),%edx
 309:	89 d0                	mov    %edx,%eax
 30b:	c1 e0 02             	shl    $0x2,%eax
 30e:	01 d0                	add    %edx,%eax
 310:	01 c0                	add    %eax,%eax
 312:	89 c2                	mov    %eax,%edx
 314:	8b 45 08             	mov    0x8(%ebp),%eax
 317:	0f b6 00             	movzbl (%eax),%eax
 31a:	0f be c0             	movsbl %al,%eax
 31d:	01 d0                	add    %edx,%eax
 31f:	83 e8 30             	sub    $0x30,%eax
 322:	89 45 fc             	mov    %eax,-0x4(%ebp)
 325:	83 45 08 01          	addl   $0x1,0x8(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 329:	8b 45 08             	mov    0x8(%ebp),%eax
 32c:	0f b6 00             	movzbl (%eax),%eax
 32f:	3c 2f                	cmp    $0x2f,%al
 331:	7e 0a                	jle    33d <atoi+0x46>
 333:	8b 45 08             	mov    0x8(%ebp),%eax
 336:	0f b6 00             	movzbl (%eax),%eax
 339:	3c 39                	cmp    $0x39,%al
 33b:	7e c9                	jle    306 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 33d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 340:	c9                   	leave  
 341:	c3                   	ret    

00000342 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 342:	55                   	push   %ebp
 343:	89 e5                	mov    %esp,%ebp
 345:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 348:	8b 45 08             	mov    0x8(%ebp),%eax
 34b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 34e:	8b 45 0c             	mov    0xc(%ebp),%eax
 351:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 354:	eb 13                	jmp    369 <memmove+0x27>
    *dst++ = *src++;
 356:	8b 45 f8             	mov    -0x8(%ebp),%eax
 359:	0f b6 10             	movzbl (%eax),%edx
 35c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 35f:	88 10                	mov    %dl,(%eax)
 361:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 365:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 369:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 36d:	0f 9f c0             	setg   %al
 370:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 374:	84 c0                	test   %al,%al
 376:	75 de                	jne    356 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 378:	8b 45 08             	mov    0x8(%ebp),%eax
}
 37b:	c9                   	leave  
 37c:	c3                   	ret    
 37d:	90                   	nop
 37e:	90                   	nop
 37f:	90                   	nop

00000380 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 380:	b8 01 00 00 00       	mov    $0x1,%eax
 385:	cd 40                	int    $0x40
 387:	c3                   	ret    

00000388 <exit>:
SYSCALL(exit)
 388:	b8 02 00 00 00       	mov    $0x2,%eax
 38d:	cd 40                	int    $0x40
 38f:	c3                   	ret    

00000390 <wait>:
SYSCALL(wait)
 390:	b8 03 00 00 00       	mov    $0x3,%eax
 395:	cd 40                	int    $0x40
 397:	c3                   	ret    

00000398 <pipe>:
SYSCALL(pipe)
 398:	b8 04 00 00 00       	mov    $0x4,%eax
 39d:	cd 40                	int    $0x40
 39f:	c3                   	ret    

000003a0 <read>:
SYSCALL(read)
 3a0:	b8 05 00 00 00       	mov    $0x5,%eax
 3a5:	cd 40                	int    $0x40
 3a7:	c3                   	ret    

000003a8 <write>:
SYSCALL(write)
 3a8:	b8 10 00 00 00       	mov    $0x10,%eax
 3ad:	cd 40                	int    $0x40
 3af:	c3                   	ret    

000003b0 <close>:
SYSCALL(close)
 3b0:	b8 15 00 00 00       	mov    $0x15,%eax
 3b5:	cd 40                	int    $0x40
 3b7:	c3                   	ret    

000003b8 <kill>:
SYSCALL(kill)
 3b8:	b8 06 00 00 00       	mov    $0x6,%eax
 3bd:	cd 40                	int    $0x40
 3bf:	c3                   	ret    

000003c0 <exec>:
SYSCALL(exec)
 3c0:	b8 07 00 00 00       	mov    $0x7,%eax
 3c5:	cd 40                	int    $0x40
 3c7:	c3                   	ret    

000003c8 <open>:
SYSCALL(open)
 3c8:	b8 0f 00 00 00       	mov    $0xf,%eax
 3cd:	cd 40                	int    $0x40
 3cf:	c3                   	ret    

000003d0 <mknod>:
SYSCALL(mknod)
 3d0:	b8 11 00 00 00       	mov    $0x11,%eax
 3d5:	cd 40                	int    $0x40
 3d7:	c3                   	ret    

000003d8 <unlink>:
SYSCALL(unlink)
 3d8:	b8 12 00 00 00       	mov    $0x12,%eax
 3dd:	cd 40                	int    $0x40
 3df:	c3                   	ret    

000003e0 <fstat>:
SYSCALL(fstat)
 3e0:	b8 08 00 00 00       	mov    $0x8,%eax
 3e5:	cd 40                	int    $0x40
 3e7:	c3                   	ret    

000003e8 <link>:
SYSCALL(link)
 3e8:	b8 13 00 00 00       	mov    $0x13,%eax
 3ed:	cd 40                	int    $0x40
 3ef:	c3                   	ret    

000003f0 <mkdir>:
SYSCALL(mkdir)
 3f0:	b8 14 00 00 00       	mov    $0x14,%eax
 3f5:	cd 40                	int    $0x40
 3f7:	c3                   	ret    

000003f8 <chdir>:
SYSCALL(chdir)
 3f8:	b8 09 00 00 00       	mov    $0x9,%eax
 3fd:	cd 40                	int    $0x40
 3ff:	c3                   	ret    

00000400 <dup>:
SYSCALL(dup)
 400:	b8 0a 00 00 00       	mov    $0xa,%eax
 405:	cd 40                	int    $0x40
 407:	c3                   	ret    

00000408 <getpid>:
SYSCALL(getpid)
 408:	b8 0b 00 00 00       	mov    $0xb,%eax
 40d:	cd 40                	int    $0x40
 40f:	c3                   	ret    

00000410 <sbrk>:
SYSCALL(sbrk)
 410:	b8 0c 00 00 00       	mov    $0xc,%eax
 415:	cd 40                	int    $0x40
 417:	c3                   	ret    

00000418 <sleep>:
SYSCALL(sleep)
 418:	b8 0d 00 00 00       	mov    $0xd,%eax
 41d:	cd 40                	int    $0x40
 41f:	c3                   	ret    

00000420 <uptime>:
SYSCALL(uptime)
 420:	b8 0e 00 00 00       	mov    $0xe,%eax
 425:	cd 40                	int    $0x40
 427:	c3                   	ret    

00000428 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 428:	55                   	push   %ebp
 429:	89 e5                	mov    %esp,%ebp
 42b:	83 ec 28             	sub    $0x28,%esp
 42e:	8b 45 0c             	mov    0xc(%ebp),%eax
 431:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 434:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 43b:	00 
 43c:	8d 45 f4             	lea    -0xc(%ebp),%eax
 43f:	89 44 24 04          	mov    %eax,0x4(%esp)
 443:	8b 45 08             	mov    0x8(%ebp),%eax
 446:	89 04 24             	mov    %eax,(%esp)
 449:	e8 5a ff ff ff       	call   3a8 <write>
}
 44e:	c9                   	leave  
 44f:	c3                   	ret    

00000450 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 450:	55                   	push   %ebp
 451:	89 e5                	mov    %esp,%ebp
 453:	83 ec 48             	sub    $0x48,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 456:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 45d:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 461:	74 17                	je     47a <printint+0x2a>
 463:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 467:	79 11                	jns    47a <printint+0x2a>
    neg = 1;
 469:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 470:	8b 45 0c             	mov    0xc(%ebp),%eax
 473:	f7 d8                	neg    %eax
 475:	89 45 ec             	mov    %eax,-0x14(%ebp)
 478:	eb 06                	jmp    480 <printint+0x30>
  } else {
    x = xx;
 47a:	8b 45 0c             	mov    0xc(%ebp),%eax
 47d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 480:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 487:	8b 4d 10             	mov    0x10(%ebp),%ecx
 48a:	8b 45 ec             	mov    -0x14(%ebp),%eax
 48d:	ba 00 00 00 00       	mov    $0x0,%edx
 492:	f7 f1                	div    %ecx
 494:	89 d0                	mov    %edx,%eax
 496:	0f b6 90 60 0b 00 00 	movzbl 0xb60(%eax),%edx
 49d:	8d 45 dc             	lea    -0x24(%ebp),%eax
 4a0:	03 45 f4             	add    -0xc(%ebp),%eax
 4a3:	88 10                	mov    %dl,(%eax)
 4a5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  }while((x /= base) != 0);
 4a9:	8b 55 10             	mov    0x10(%ebp),%edx
 4ac:	89 55 d4             	mov    %edx,-0x2c(%ebp)
 4af:	8b 45 ec             	mov    -0x14(%ebp),%eax
 4b2:	ba 00 00 00 00       	mov    $0x0,%edx
 4b7:	f7 75 d4             	divl   -0x2c(%ebp)
 4ba:	89 45 ec             	mov    %eax,-0x14(%ebp)
 4bd:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 4c1:	75 c4                	jne    487 <printint+0x37>
  if(neg)
 4c3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 4c7:	74 2a                	je     4f3 <printint+0xa3>
    buf[i++] = '-';
 4c9:	8d 45 dc             	lea    -0x24(%ebp),%eax
 4cc:	03 45 f4             	add    -0xc(%ebp),%eax
 4cf:	c6 00 2d             	movb   $0x2d,(%eax)
 4d2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

  while(--i >= 0)
 4d6:	eb 1b                	jmp    4f3 <printint+0xa3>
    putc(fd, buf[i]);
 4d8:	8d 45 dc             	lea    -0x24(%ebp),%eax
 4db:	03 45 f4             	add    -0xc(%ebp),%eax
 4de:	0f b6 00             	movzbl (%eax),%eax
 4e1:	0f be c0             	movsbl %al,%eax
 4e4:	89 44 24 04          	mov    %eax,0x4(%esp)
 4e8:	8b 45 08             	mov    0x8(%ebp),%eax
 4eb:	89 04 24             	mov    %eax,(%esp)
 4ee:	e8 35 ff ff ff       	call   428 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 4f3:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 4f7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 4fb:	79 db                	jns    4d8 <printint+0x88>
    putc(fd, buf[i]);
}
 4fd:	c9                   	leave  
 4fe:	c3                   	ret    

000004ff <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 4ff:	55                   	push   %ebp
 500:	89 e5                	mov    %esp,%ebp
 502:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 505:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 50c:	8d 45 0c             	lea    0xc(%ebp),%eax
 50f:	83 c0 04             	add    $0x4,%eax
 512:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 515:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 51c:	e9 7d 01 00 00       	jmp    69e <printf+0x19f>
    c = fmt[i] & 0xff;
 521:	8b 55 0c             	mov    0xc(%ebp),%edx
 524:	8b 45 f0             	mov    -0x10(%ebp),%eax
 527:	01 d0                	add    %edx,%eax
 529:	0f b6 00             	movzbl (%eax),%eax
 52c:	0f be c0             	movsbl %al,%eax
 52f:	25 ff 00 00 00       	and    $0xff,%eax
 534:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 537:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 53b:	75 2c                	jne    569 <printf+0x6a>
      if(c == '%'){
 53d:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 541:	75 0c                	jne    54f <printf+0x50>
        state = '%';
 543:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 54a:	e9 4b 01 00 00       	jmp    69a <printf+0x19b>
      } else {
        putc(fd, c);
 54f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 552:	0f be c0             	movsbl %al,%eax
 555:	89 44 24 04          	mov    %eax,0x4(%esp)
 559:	8b 45 08             	mov    0x8(%ebp),%eax
 55c:	89 04 24             	mov    %eax,(%esp)
 55f:	e8 c4 fe ff ff       	call   428 <putc>
 564:	e9 31 01 00 00       	jmp    69a <printf+0x19b>
      }
    } else if(state == '%'){
 569:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 56d:	0f 85 27 01 00 00    	jne    69a <printf+0x19b>
      if(c == 'd'){
 573:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 577:	75 2d                	jne    5a6 <printf+0xa7>
        printint(fd, *ap, 10, 1);
 579:	8b 45 e8             	mov    -0x18(%ebp),%eax
 57c:	8b 00                	mov    (%eax),%eax
 57e:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 585:	00 
 586:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 58d:	00 
 58e:	89 44 24 04          	mov    %eax,0x4(%esp)
 592:	8b 45 08             	mov    0x8(%ebp),%eax
 595:	89 04 24             	mov    %eax,(%esp)
 598:	e8 b3 fe ff ff       	call   450 <printint>
        ap++;
 59d:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 5a1:	e9 ed 00 00 00       	jmp    693 <printf+0x194>
      } else if(c == 'x' || c == 'p'){
 5a6:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 5aa:	74 06                	je     5b2 <printf+0xb3>
 5ac:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 5b0:	75 2d                	jne    5df <printf+0xe0>
        printint(fd, *ap, 16, 0);
 5b2:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5b5:	8b 00                	mov    (%eax),%eax
 5b7:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 5be:	00 
 5bf:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 5c6:	00 
 5c7:	89 44 24 04          	mov    %eax,0x4(%esp)
 5cb:	8b 45 08             	mov    0x8(%ebp),%eax
 5ce:	89 04 24             	mov    %eax,(%esp)
 5d1:	e8 7a fe ff ff       	call   450 <printint>
        ap++;
 5d6:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 5da:	e9 b4 00 00 00       	jmp    693 <printf+0x194>
      } else if(c == 's'){
 5df:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 5e3:	75 46                	jne    62b <printf+0x12c>
        s = (char*)*ap;
 5e5:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5e8:	8b 00                	mov    (%eax),%eax
 5ea:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 5ed:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 5f1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 5f5:	75 27                	jne    61e <printf+0x11f>
          s = "(null)";
 5f7:	c7 45 f4 13 09 00 00 	movl   $0x913,-0xc(%ebp)
        while(*s != 0){
 5fe:	eb 1e                	jmp    61e <printf+0x11f>
          putc(fd, *s);
 600:	8b 45 f4             	mov    -0xc(%ebp),%eax
 603:	0f b6 00             	movzbl (%eax),%eax
 606:	0f be c0             	movsbl %al,%eax
 609:	89 44 24 04          	mov    %eax,0x4(%esp)
 60d:	8b 45 08             	mov    0x8(%ebp),%eax
 610:	89 04 24             	mov    %eax,(%esp)
 613:	e8 10 fe ff ff       	call   428 <putc>
          s++;
 618:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 61c:	eb 01                	jmp    61f <printf+0x120>
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 61e:	90                   	nop
 61f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 622:	0f b6 00             	movzbl (%eax),%eax
 625:	84 c0                	test   %al,%al
 627:	75 d7                	jne    600 <printf+0x101>
 629:	eb 68                	jmp    693 <printf+0x194>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 62b:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 62f:	75 1d                	jne    64e <printf+0x14f>
        putc(fd, *ap);
 631:	8b 45 e8             	mov    -0x18(%ebp),%eax
 634:	8b 00                	mov    (%eax),%eax
 636:	0f be c0             	movsbl %al,%eax
 639:	89 44 24 04          	mov    %eax,0x4(%esp)
 63d:	8b 45 08             	mov    0x8(%ebp),%eax
 640:	89 04 24             	mov    %eax,(%esp)
 643:	e8 e0 fd ff ff       	call   428 <putc>
        ap++;
 648:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 64c:	eb 45                	jmp    693 <printf+0x194>
      } else if(c == '%'){
 64e:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 652:	75 17                	jne    66b <printf+0x16c>
        putc(fd, c);
 654:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 657:	0f be c0             	movsbl %al,%eax
 65a:	89 44 24 04          	mov    %eax,0x4(%esp)
 65e:	8b 45 08             	mov    0x8(%ebp),%eax
 661:	89 04 24             	mov    %eax,(%esp)
 664:	e8 bf fd ff ff       	call   428 <putc>
 669:	eb 28                	jmp    693 <printf+0x194>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 66b:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 672:	00 
 673:	8b 45 08             	mov    0x8(%ebp),%eax
 676:	89 04 24             	mov    %eax,(%esp)
 679:	e8 aa fd ff ff       	call   428 <putc>
        putc(fd, c);
 67e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 681:	0f be c0             	movsbl %al,%eax
 684:	89 44 24 04          	mov    %eax,0x4(%esp)
 688:	8b 45 08             	mov    0x8(%ebp),%eax
 68b:	89 04 24             	mov    %eax,(%esp)
 68e:	e8 95 fd ff ff       	call   428 <putc>
      }
      state = 0;
 693:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 69a:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 69e:	8b 55 0c             	mov    0xc(%ebp),%edx
 6a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6a4:	01 d0                	add    %edx,%eax
 6a6:	0f b6 00             	movzbl (%eax),%eax
 6a9:	84 c0                	test   %al,%al
 6ab:	0f 85 70 fe ff ff    	jne    521 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 6b1:	c9                   	leave  
 6b2:	c3                   	ret    
 6b3:	90                   	nop

000006b4 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 6b4:	55                   	push   %ebp
 6b5:	89 e5                	mov    %esp,%ebp
 6b7:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 6ba:	8b 45 08             	mov    0x8(%ebp),%eax
 6bd:	83 e8 08             	sub    $0x8,%eax
 6c0:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6c3:	a1 7c 0b 00 00       	mov    0xb7c,%eax
 6c8:	89 45 fc             	mov    %eax,-0x4(%ebp)
 6cb:	eb 24                	jmp    6f1 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6cd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6d0:	8b 00                	mov    (%eax),%eax
 6d2:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 6d5:	77 12                	ja     6e9 <free+0x35>
 6d7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6da:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 6dd:	77 24                	ja     703 <free+0x4f>
 6df:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6e2:	8b 00                	mov    (%eax),%eax
 6e4:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 6e7:	77 1a                	ja     703 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6e9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6ec:	8b 00                	mov    (%eax),%eax
 6ee:	89 45 fc             	mov    %eax,-0x4(%ebp)
 6f1:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6f4:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 6f7:	76 d4                	jbe    6cd <free+0x19>
 6f9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6fc:	8b 00                	mov    (%eax),%eax
 6fe:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 701:	76 ca                	jbe    6cd <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 703:	8b 45 f8             	mov    -0x8(%ebp),%eax
 706:	8b 40 04             	mov    0x4(%eax),%eax
 709:	c1 e0 03             	shl    $0x3,%eax
 70c:	89 c2                	mov    %eax,%edx
 70e:	03 55 f8             	add    -0x8(%ebp),%edx
 711:	8b 45 fc             	mov    -0x4(%ebp),%eax
 714:	8b 00                	mov    (%eax),%eax
 716:	39 c2                	cmp    %eax,%edx
 718:	75 24                	jne    73e <free+0x8a>
    bp->s.size += p->s.ptr->s.size;
 71a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 71d:	8b 50 04             	mov    0x4(%eax),%edx
 720:	8b 45 fc             	mov    -0x4(%ebp),%eax
 723:	8b 00                	mov    (%eax),%eax
 725:	8b 40 04             	mov    0x4(%eax),%eax
 728:	01 c2                	add    %eax,%edx
 72a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 72d:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 730:	8b 45 fc             	mov    -0x4(%ebp),%eax
 733:	8b 00                	mov    (%eax),%eax
 735:	8b 10                	mov    (%eax),%edx
 737:	8b 45 f8             	mov    -0x8(%ebp),%eax
 73a:	89 10                	mov    %edx,(%eax)
 73c:	eb 0a                	jmp    748 <free+0x94>
  } else
    bp->s.ptr = p->s.ptr;
 73e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 741:	8b 10                	mov    (%eax),%edx
 743:	8b 45 f8             	mov    -0x8(%ebp),%eax
 746:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 748:	8b 45 fc             	mov    -0x4(%ebp),%eax
 74b:	8b 40 04             	mov    0x4(%eax),%eax
 74e:	c1 e0 03             	shl    $0x3,%eax
 751:	03 45 fc             	add    -0x4(%ebp),%eax
 754:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 757:	75 20                	jne    779 <free+0xc5>
    p->s.size += bp->s.size;
 759:	8b 45 fc             	mov    -0x4(%ebp),%eax
 75c:	8b 50 04             	mov    0x4(%eax),%edx
 75f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 762:	8b 40 04             	mov    0x4(%eax),%eax
 765:	01 c2                	add    %eax,%edx
 767:	8b 45 fc             	mov    -0x4(%ebp),%eax
 76a:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 76d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 770:	8b 10                	mov    (%eax),%edx
 772:	8b 45 fc             	mov    -0x4(%ebp),%eax
 775:	89 10                	mov    %edx,(%eax)
 777:	eb 08                	jmp    781 <free+0xcd>
  } else
    p->s.ptr = bp;
 779:	8b 45 fc             	mov    -0x4(%ebp),%eax
 77c:	8b 55 f8             	mov    -0x8(%ebp),%edx
 77f:	89 10                	mov    %edx,(%eax)
  freep = p;
 781:	8b 45 fc             	mov    -0x4(%ebp),%eax
 784:	a3 7c 0b 00 00       	mov    %eax,0xb7c
}
 789:	c9                   	leave  
 78a:	c3                   	ret    

0000078b <morecore>:

static Header*
morecore(uint nu)
{
 78b:	55                   	push   %ebp
 78c:	89 e5                	mov    %esp,%ebp
 78e:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 791:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 798:	77 07                	ja     7a1 <morecore+0x16>
    nu = 4096;
 79a:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 7a1:	8b 45 08             	mov    0x8(%ebp),%eax
 7a4:	c1 e0 03             	shl    $0x3,%eax
 7a7:	89 04 24             	mov    %eax,(%esp)
 7aa:	e8 61 fc ff ff       	call   410 <sbrk>
 7af:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 7b2:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 7b6:	75 07                	jne    7bf <morecore+0x34>
    return 0;
 7b8:	b8 00 00 00 00       	mov    $0x0,%eax
 7bd:	eb 22                	jmp    7e1 <morecore+0x56>
  hp = (Header*)p;
 7bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7c2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 7c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7c8:	8b 55 08             	mov    0x8(%ebp),%edx
 7cb:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 7ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7d1:	83 c0 08             	add    $0x8,%eax
 7d4:	89 04 24             	mov    %eax,(%esp)
 7d7:	e8 d8 fe ff ff       	call   6b4 <free>
  return freep;
 7dc:	a1 7c 0b 00 00       	mov    0xb7c,%eax
}
 7e1:	c9                   	leave  
 7e2:	c3                   	ret    

000007e3 <malloc>:

void*
malloc(uint nbytes)
{
 7e3:	55                   	push   %ebp
 7e4:	89 e5                	mov    %esp,%ebp
 7e6:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 7e9:	8b 45 08             	mov    0x8(%ebp),%eax
 7ec:	83 c0 07             	add    $0x7,%eax
 7ef:	c1 e8 03             	shr    $0x3,%eax
 7f2:	83 c0 01             	add    $0x1,%eax
 7f5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 7f8:	a1 7c 0b 00 00       	mov    0xb7c,%eax
 7fd:	89 45 f0             	mov    %eax,-0x10(%ebp)
 800:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 804:	75 23                	jne    829 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 806:	c7 45 f0 74 0b 00 00 	movl   $0xb74,-0x10(%ebp)
 80d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 810:	a3 7c 0b 00 00       	mov    %eax,0xb7c
 815:	a1 7c 0b 00 00       	mov    0xb7c,%eax
 81a:	a3 74 0b 00 00       	mov    %eax,0xb74
    base.s.size = 0;
 81f:	c7 05 78 0b 00 00 00 	movl   $0x0,0xb78
 826:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 829:	8b 45 f0             	mov    -0x10(%ebp),%eax
 82c:	8b 00                	mov    (%eax),%eax
 82e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 831:	8b 45 f4             	mov    -0xc(%ebp),%eax
 834:	8b 40 04             	mov    0x4(%eax),%eax
 837:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 83a:	72 4d                	jb     889 <malloc+0xa6>
      if(p->s.size == nunits)
 83c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 83f:	8b 40 04             	mov    0x4(%eax),%eax
 842:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 845:	75 0c                	jne    853 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 847:	8b 45 f4             	mov    -0xc(%ebp),%eax
 84a:	8b 10                	mov    (%eax),%edx
 84c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 84f:	89 10                	mov    %edx,(%eax)
 851:	eb 26                	jmp    879 <malloc+0x96>
      else {
        p->s.size -= nunits;
 853:	8b 45 f4             	mov    -0xc(%ebp),%eax
 856:	8b 40 04             	mov    0x4(%eax),%eax
 859:	89 c2                	mov    %eax,%edx
 85b:	2b 55 ec             	sub    -0x14(%ebp),%edx
 85e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 861:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 864:	8b 45 f4             	mov    -0xc(%ebp),%eax
 867:	8b 40 04             	mov    0x4(%eax),%eax
 86a:	c1 e0 03             	shl    $0x3,%eax
 86d:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 870:	8b 45 f4             	mov    -0xc(%ebp),%eax
 873:	8b 55 ec             	mov    -0x14(%ebp),%edx
 876:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 879:	8b 45 f0             	mov    -0x10(%ebp),%eax
 87c:	a3 7c 0b 00 00       	mov    %eax,0xb7c
      return (void*)(p + 1);
 881:	8b 45 f4             	mov    -0xc(%ebp),%eax
 884:	83 c0 08             	add    $0x8,%eax
 887:	eb 38                	jmp    8c1 <malloc+0xde>
    }
    if(p == freep)
 889:	a1 7c 0b 00 00       	mov    0xb7c,%eax
 88e:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 891:	75 1b                	jne    8ae <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 893:	8b 45 ec             	mov    -0x14(%ebp),%eax
 896:	89 04 24             	mov    %eax,(%esp)
 899:	e8 ed fe ff ff       	call   78b <morecore>
 89e:	89 45 f4             	mov    %eax,-0xc(%ebp)
 8a1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 8a5:	75 07                	jne    8ae <malloc+0xcb>
        return 0;
 8a7:	b8 00 00 00 00       	mov    $0x0,%eax
 8ac:	eb 13                	jmp    8c1 <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8b1:	89 45 f0             	mov    %eax,-0x10(%ebp)
 8b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8b7:	8b 00                	mov    (%eax),%eax
 8b9:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 8bc:	e9 70 ff ff ff       	jmp    831 <malloc+0x4e>
}
 8c1:	c9                   	leave  
 8c2:	c3                   	ret    
