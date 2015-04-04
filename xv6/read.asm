
_read:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "stat.h"
#include "user.h"

int
main(int argc, char *argv[])
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 e4 f0             	and    $0xfffffff0,%esp
   6:	83 ec 30             	sub    $0x30,%esp
  char c = -1;
   9:	c6 44 24 2f ff       	movb   $0xff,0x2f(%esp)
  int wtime, rtime, iotime;
  while (c!='q')  {
   e:	e9 b4 00 00 00       	jmp    c7 <main+0xc7>
	  if (c!=-1){
  13:	0f b6 44 24 2f       	movzbl 0x2f(%esp),%eax
  18:	3c ff                	cmp    $0xff,%al
  1a:	74 2d                	je     49 <main+0x49>
		  if (write(1,&c,1) != 1)	exit(EXIT_STATUS_FAILURE);
  1c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  23:	00 
  24:	8d 44 24 2f          	lea    0x2f(%esp),%eax
  28:	89 44 24 04          	mov    %eax,0x4(%esp)
  2c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  33:	e8 2c 03 00 00       	call   364 <write>
  38:	83 f8 01             	cmp    $0x1,%eax
  3b:	74 0c                	je     49 <main+0x49>
  3d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  44:	e8 fb 02 00 00       	call   344 <exit>
	  }

	  if (c=='p')
  49:	0f b6 44 24 2f       	movzbl 0x2f(%esp),%eax
  4e:	3c 70                	cmp    $0x70,%al
  50:	75 48                	jne    9a <main+0x9a>
	  {
		  wait_stat(&wtime, &rtime, &iotime);
  52:	8d 44 24 20          	lea    0x20(%esp),%eax
  56:	89 44 24 08          	mov    %eax,0x8(%esp)
  5a:	8d 44 24 24          	lea    0x24(%esp),%eax
  5e:	89 44 24 04          	mov    %eax,0x4(%esp)
  62:	8d 44 24 28          	lea    0x28(%esp),%eax
  66:	89 04 24             	mov    %eax,(%esp)
  69:	e8 7e 03 00 00       	call   3ec <wait_stat>
		  printf(1, "wtime %d, rtime %d, iotime %d", wtime, rtime, iotime);
  6e:	8b 4c 24 20          	mov    0x20(%esp),%ecx
  72:	8b 54 24 24          	mov    0x24(%esp),%edx
  76:	8b 44 24 28          	mov    0x28(%esp),%eax
  7a:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  7e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  82:	89 44 24 08          	mov    %eax,0x8(%esp)
  86:	c7 44 24 04 8f 08 00 	movl   $0x88f,0x4(%esp)
  8d:	00 
  8e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  95:	e8 31 04 00 00       	call   4cb <printf>
	  }

	  if (read(0,&c,1) != 1)	exit(EXIT_STATUS_FAILURE);
  9a:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  a1:	00 
  a2:	8d 44 24 2f          	lea    0x2f(%esp),%eax
  a6:	89 44 24 04          	mov    %eax,0x4(%esp)
  aa:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  b1:	e8 a6 02 00 00       	call   35c <read>
  b6:	83 f8 01             	cmp    $0x1,%eax
  b9:	74 0c                	je     c7 <main+0xc7>
  bb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  c2:	e8 7d 02 00 00       	call   344 <exit>
int
main(int argc, char *argv[])
{
  char c = -1;
  int wtime, rtime, iotime;
  while (c!='q')  {
  c7:	0f b6 44 24 2f       	movzbl 0x2f(%esp),%eax
  cc:	3c 71                	cmp    $0x71,%al
  ce:	0f 85 3f ff ff ff    	jne    13 <main+0x13>
		  printf(1, "wtime %d, rtime %d, iotime %d", wtime, rtime, iotime);
	  }

	  if (read(0,&c,1) != 1)	exit(EXIT_STATUS_FAILURE);
  }
  exit(EXIT_STATUS_SUCCESS);
  d4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  db:	e8 64 02 00 00       	call   344 <exit>

000000e0 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
  e0:	55                   	push   %ebp
  e1:	89 e5                	mov    %esp,%ebp
  e3:	57                   	push   %edi
  e4:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
  e5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  e8:	8b 55 10             	mov    0x10(%ebp),%edx
  eb:	8b 45 0c             	mov    0xc(%ebp),%eax
  ee:	89 cb                	mov    %ecx,%ebx
  f0:	89 df                	mov    %ebx,%edi
  f2:	89 d1                	mov    %edx,%ecx
  f4:	fc                   	cld    
  f5:	f3 aa                	rep stos %al,%es:(%edi)
  f7:	89 ca                	mov    %ecx,%edx
  f9:	89 fb                	mov    %edi,%ebx
  fb:	89 5d 08             	mov    %ebx,0x8(%ebp)
  fe:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 101:	5b                   	pop    %ebx
 102:	5f                   	pop    %edi
 103:	5d                   	pop    %ebp
 104:	c3                   	ret    

00000105 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 105:	55                   	push   %ebp
 106:	89 e5                	mov    %esp,%ebp
 108:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 10b:	8b 45 08             	mov    0x8(%ebp),%eax
 10e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 111:	90                   	nop
 112:	8b 45 0c             	mov    0xc(%ebp),%eax
 115:	0f b6 10             	movzbl (%eax),%edx
 118:	8b 45 08             	mov    0x8(%ebp),%eax
 11b:	88 10                	mov    %dl,(%eax)
 11d:	8b 45 08             	mov    0x8(%ebp),%eax
 120:	0f b6 00             	movzbl (%eax),%eax
 123:	84 c0                	test   %al,%al
 125:	0f 95 c0             	setne  %al
 128:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 12c:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 130:	84 c0                	test   %al,%al
 132:	75 de                	jne    112 <strcpy+0xd>
    ;
  return os;
 134:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 137:	c9                   	leave  
 138:	c3                   	ret    

00000139 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 139:	55                   	push   %ebp
 13a:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 13c:	eb 08                	jmp    146 <strcmp+0xd>
    p++, q++;
 13e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 142:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 146:	8b 45 08             	mov    0x8(%ebp),%eax
 149:	0f b6 00             	movzbl (%eax),%eax
 14c:	84 c0                	test   %al,%al
 14e:	74 10                	je     160 <strcmp+0x27>
 150:	8b 45 08             	mov    0x8(%ebp),%eax
 153:	0f b6 10             	movzbl (%eax),%edx
 156:	8b 45 0c             	mov    0xc(%ebp),%eax
 159:	0f b6 00             	movzbl (%eax),%eax
 15c:	38 c2                	cmp    %al,%dl
 15e:	74 de                	je     13e <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 160:	8b 45 08             	mov    0x8(%ebp),%eax
 163:	0f b6 00             	movzbl (%eax),%eax
 166:	0f b6 d0             	movzbl %al,%edx
 169:	8b 45 0c             	mov    0xc(%ebp),%eax
 16c:	0f b6 00             	movzbl (%eax),%eax
 16f:	0f b6 c0             	movzbl %al,%eax
 172:	89 d1                	mov    %edx,%ecx
 174:	29 c1                	sub    %eax,%ecx
 176:	89 c8                	mov    %ecx,%eax
}
 178:	5d                   	pop    %ebp
 179:	c3                   	ret    

0000017a <strlen>:

uint
strlen(char *s)
{
 17a:	55                   	push   %ebp
 17b:	89 e5                	mov    %esp,%ebp
 17d:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 180:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 187:	eb 04                	jmp    18d <strlen+0x13>
 189:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 18d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 190:	03 45 08             	add    0x8(%ebp),%eax
 193:	0f b6 00             	movzbl (%eax),%eax
 196:	84 c0                	test   %al,%al
 198:	75 ef                	jne    189 <strlen+0xf>
    ;
  return n;
 19a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 19d:	c9                   	leave  
 19e:	c3                   	ret    

0000019f <memset>:

void*
memset(void *dst, int c, uint n)
{
 19f:	55                   	push   %ebp
 1a0:	89 e5                	mov    %esp,%ebp
 1a2:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 1a5:	8b 45 10             	mov    0x10(%ebp),%eax
 1a8:	89 44 24 08          	mov    %eax,0x8(%esp)
 1ac:	8b 45 0c             	mov    0xc(%ebp),%eax
 1af:	89 44 24 04          	mov    %eax,0x4(%esp)
 1b3:	8b 45 08             	mov    0x8(%ebp),%eax
 1b6:	89 04 24             	mov    %eax,(%esp)
 1b9:	e8 22 ff ff ff       	call   e0 <stosb>
  return dst;
 1be:	8b 45 08             	mov    0x8(%ebp),%eax
}
 1c1:	c9                   	leave  
 1c2:	c3                   	ret    

000001c3 <strchr>:

char*
strchr(const char *s, char c)
{
 1c3:	55                   	push   %ebp
 1c4:	89 e5                	mov    %esp,%ebp
 1c6:	83 ec 04             	sub    $0x4,%esp
 1c9:	8b 45 0c             	mov    0xc(%ebp),%eax
 1cc:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 1cf:	eb 14                	jmp    1e5 <strchr+0x22>
    if(*s == c)
 1d1:	8b 45 08             	mov    0x8(%ebp),%eax
 1d4:	0f b6 00             	movzbl (%eax),%eax
 1d7:	3a 45 fc             	cmp    -0x4(%ebp),%al
 1da:	75 05                	jne    1e1 <strchr+0x1e>
      return (char*)s;
 1dc:	8b 45 08             	mov    0x8(%ebp),%eax
 1df:	eb 13                	jmp    1f4 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 1e1:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 1e5:	8b 45 08             	mov    0x8(%ebp),%eax
 1e8:	0f b6 00             	movzbl (%eax),%eax
 1eb:	84 c0                	test   %al,%al
 1ed:	75 e2                	jne    1d1 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 1ef:	b8 00 00 00 00       	mov    $0x0,%eax
}
 1f4:	c9                   	leave  
 1f5:	c3                   	ret    

000001f6 <gets>:

char*
gets(char *buf, int max)
{
 1f6:	55                   	push   %ebp
 1f7:	89 e5                	mov    %esp,%ebp
 1f9:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1fc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 203:	eb 44                	jmp    249 <gets+0x53>
    cc = read(0, &c, 1);
 205:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 20c:	00 
 20d:	8d 45 ef             	lea    -0x11(%ebp),%eax
 210:	89 44 24 04          	mov    %eax,0x4(%esp)
 214:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 21b:	e8 3c 01 00 00       	call   35c <read>
 220:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 223:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 227:	7e 2d                	jle    256 <gets+0x60>
      break;
    buf[i++] = c;
 229:	8b 45 f4             	mov    -0xc(%ebp),%eax
 22c:	03 45 08             	add    0x8(%ebp),%eax
 22f:	0f b6 55 ef          	movzbl -0x11(%ebp),%edx
 233:	88 10                	mov    %dl,(%eax)
 235:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(c == '\n' || c == '\r')
 239:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 23d:	3c 0a                	cmp    $0xa,%al
 23f:	74 16                	je     257 <gets+0x61>
 241:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 245:	3c 0d                	cmp    $0xd,%al
 247:	74 0e                	je     257 <gets+0x61>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 249:	8b 45 f4             	mov    -0xc(%ebp),%eax
 24c:	83 c0 01             	add    $0x1,%eax
 24f:	3b 45 0c             	cmp    0xc(%ebp),%eax
 252:	7c b1                	jl     205 <gets+0xf>
 254:	eb 01                	jmp    257 <gets+0x61>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 256:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 257:	8b 45 f4             	mov    -0xc(%ebp),%eax
 25a:	03 45 08             	add    0x8(%ebp),%eax
 25d:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 260:	8b 45 08             	mov    0x8(%ebp),%eax
}
 263:	c9                   	leave  
 264:	c3                   	ret    

00000265 <stat>:

int
stat(char *n, struct stat *st)
{
 265:	55                   	push   %ebp
 266:	89 e5                	mov    %esp,%ebp
 268:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 26b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 272:	00 
 273:	8b 45 08             	mov    0x8(%ebp),%eax
 276:	89 04 24             	mov    %eax,(%esp)
 279:	e8 06 01 00 00       	call   384 <open>
 27e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 281:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 285:	79 07                	jns    28e <stat+0x29>
    return -1;
 287:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 28c:	eb 23                	jmp    2b1 <stat+0x4c>
  r = fstat(fd, st);
 28e:	8b 45 0c             	mov    0xc(%ebp),%eax
 291:	89 44 24 04          	mov    %eax,0x4(%esp)
 295:	8b 45 f4             	mov    -0xc(%ebp),%eax
 298:	89 04 24             	mov    %eax,(%esp)
 29b:	e8 fc 00 00 00       	call   39c <fstat>
 2a0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 2a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2a6:	89 04 24             	mov    %eax,(%esp)
 2a9:	e8 be 00 00 00       	call   36c <close>
  return r;
 2ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 2b1:	c9                   	leave  
 2b2:	c3                   	ret    

000002b3 <atoi>:

int
atoi(const char *s)
{
 2b3:	55                   	push   %ebp
 2b4:	89 e5                	mov    %esp,%ebp
 2b6:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 2b9:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 2c0:	eb 23                	jmp    2e5 <atoi+0x32>
    n = n*10 + *s++ - '0';
 2c2:	8b 55 fc             	mov    -0x4(%ebp),%edx
 2c5:	89 d0                	mov    %edx,%eax
 2c7:	c1 e0 02             	shl    $0x2,%eax
 2ca:	01 d0                	add    %edx,%eax
 2cc:	01 c0                	add    %eax,%eax
 2ce:	89 c2                	mov    %eax,%edx
 2d0:	8b 45 08             	mov    0x8(%ebp),%eax
 2d3:	0f b6 00             	movzbl (%eax),%eax
 2d6:	0f be c0             	movsbl %al,%eax
 2d9:	01 d0                	add    %edx,%eax
 2db:	83 e8 30             	sub    $0x30,%eax
 2de:	89 45 fc             	mov    %eax,-0x4(%ebp)
 2e1:	83 45 08 01          	addl   $0x1,0x8(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 2e5:	8b 45 08             	mov    0x8(%ebp),%eax
 2e8:	0f b6 00             	movzbl (%eax),%eax
 2eb:	3c 2f                	cmp    $0x2f,%al
 2ed:	7e 0a                	jle    2f9 <atoi+0x46>
 2ef:	8b 45 08             	mov    0x8(%ebp),%eax
 2f2:	0f b6 00             	movzbl (%eax),%eax
 2f5:	3c 39                	cmp    $0x39,%al
 2f7:	7e c9                	jle    2c2 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 2f9:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 2fc:	c9                   	leave  
 2fd:	c3                   	ret    

000002fe <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 2fe:	55                   	push   %ebp
 2ff:	89 e5                	mov    %esp,%ebp
 301:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 304:	8b 45 08             	mov    0x8(%ebp),%eax
 307:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 30a:	8b 45 0c             	mov    0xc(%ebp),%eax
 30d:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 310:	eb 13                	jmp    325 <memmove+0x27>
    *dst++ = *src++;
 312:	8b 45 f8             	mov    -0x8(%ebp),%eax
 315:	0f b6 10             	movzbl (%eax),%edx
 318:	8b 45 fc             	mov    -0x4(%ebp),%eax
 31b:	88 10                	mov    %dl,(%eax)
 31d:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 321:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 325:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 329:	0f 9f c0             	setg   %al
 32c:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 330:	84 c0                	test   %al,%al
 332:	75 de                	jne    312 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 334:	8b 45 08             	mov    0x8(%ebp),%eax
}
 337:	c9                   	leave  
 338:	c3                   	ret    
 339:	90                   	nop
 33a:	90                   	nop
 33b:	90                   	nop

0000033c <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 33c:	b8 01 00 00 00       	mov    $0x1,%eax
 341:	cd 40                	int    $0x40
 343:	c3                   	ret    

00000344 <exit>:
SYSCALL(exit)
 344:	b8 02 00 00 00       	mov    $0x2,%eax
 349:	cd 40                	int    $0x40
 34b:	c3                   	ret    

0000034c <wait>:
SYSCALL(wait)
 34c:	b8 03 00 00 00       	mov    $0x3,%eax
 351:	cd 40                	int    $0x40
 353:	c3                   	ret    

00000354 <pipe>:
SYSCALL(pipe)
 354:	b8 04 00 00 00       	mov    $0x4,%eax
 359:	cd 40                	int    $0x40
 35b:	c3                   	ret    

0000035c <read>:
SYSCALL(read)
 35c:	b8 05 00 00 00       	mov    $0x5,%eax
 361:	cd 40                	int    $0x40
 363:	c3                   	ret    

00000364 <write>:
SYSCALL(write)
 364:	b8 10 00 00 00       	mov    $0x10,%eax
 369:	cd 40                	int    $0x40
 36b:	c3                   	ret    

0000036c <close>:
SYSCALL(close)
 36c:	b8 15 00 00 00       	mov    $0x15,%eax
 371:	cd 40                	int    $0x40
 373:	c3                   	ret    

00000374 <kill>:
SYSCALL(kill)
 374:	b8 06 00 00 00       	mov    $0x6,%eax
 379:	cd 40                	int    $0x40
 37b:	c3                   	ret    

0000037c <exec>:
SYSCALL(exec)
 37c:	b8 07 00 00 00       	mov    $0x7,%eax
 381:	cd 40                	int    $0x40
 383:	c3                   	ret    

00000384 <open>:
SYSCALL(open)
 384:	b8 0f 00 00 00       	mov    $0xf,%eax
 389:	cd 40                	int    $0x40
 38b:	c3                   	ret    

0000038c <mknod>:
SYSCALL(mknod)
 38c:	b8 11 00 00 00       	mov    $0x11,%eax
 391:	cd 40                	int    $0x40
 393:	c3                   	ret    

00000394 <unlink>:
SYSCALL(unlink)
 394:	b8 12 00 00 00       	mov    $0x12,%eax
 399:	cd 40                	int    $0x40
 39b:	c3                   	ret    

0000039c <fstat>:
SYSCALL(fstat)
 39c:	b8 08 00 00 00       	mov    $0x8,%eax
 3a1:	cd 40                	int    $0x40
 3a3:	c3                   	ret    

000003a4 <link>:
SYSCALL(link)
 3a4:	b8 13 00 00 00       	mov    $0x13,%eax
 3a9:	cd 40                	int    $0x40
 3ab:	c3                   	ret    

000003ac <mkdir>:
SYSCALL(mkdir)
 3ac:	b8 14 00 00 00       	mov    $0x14,%eax
 3b1:	cd 40                	int    $0x40
 3b3:	c3                   	ret    

000003b4 <chdir>:
SYSCALL(chdir)
 3b4:	b8 09 00 00 00       	mov    $0x9,%eax
 3b9:	cd 40                	int    $0x40
 3bb:	c3                   	ret    

000003bc <dup>:
SYSCALL(dup)
 3bc:	b8 0a 00 00 00       	mov    $0xa,%eax
 3c1:	cd 40                	int    $0x40
 3c3:	c3                   	ret    

000003c4 <getpid>:
SYSCALL(getpid)
 3c4:	b8 0b 00 00 00       	mov    $0xb,%eax
 3c9:	cd 40                	int    $0x40
 3cb:	c3                   	ret    

000003cc <sbrk>:
SYSCALL(sbrk)
 3cc:	b8 0c 00 00 00       	mov    $0xc,%eax
 3d1:	cd 40                	int    $0x40
 3d3:	c3                   	ret    

000003d4 <sleep>:
SYSCALL(sleep)
 3d4:	b8 0d 00 00 00       	mov    $0xd,%eax
 3d9:	cd 40                	int    $0x40
 3db:	c3                   	ret    

000003dc <uptime>:
SYSCALL(uptime)
 3dc:	b8 0e 00 00 00       	mov    $0xe,%eax
 3e1:	cd 40                	int    $0x40
 3e3:	c3                   	ret    

000003e4 <waitpid>:
SYSCALL(waitpid)
 3e4:	b8 16 00 00 00       	mov    $0x16,%eax
 3e9:	cd 40                	int    $0x40
 3eb:	c3                   	ret    

000003ec <wait_stat>:
SYSCALL(wait_stat)
 3ec:	b8 17 00 00 00       	mov    $0x17,%eax
 3f1:	cd 40                	int    $0x40
 3f3:	c3                   	ret    

000003f4 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 3f4:	55                   	push   %ebp
 3f5:	89 e5                	mov    %esp,%ebp
 3f7:	83 ec 28             	sub    $0x28,%esp
 3fa:	8b 45 0c             	mov    0xc(%ebp),%eax
 3fd:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 400:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 407:	00 
 408:	8d 45 f4             	lea    -0xc(%ebp),%eax
 40b:	89 44 24 04          	mov    %eax,0x4(%esp)
 40f:	8b 45 08             	mov    0x8(%ebp),%eax
 412:	89 04 24             	mov    %eax,(%esp)
 415:	e8 4a ff ff ff       	call   364 <write>
}
 41a:	c9                   	leave  
 41b:	c3                   	ret    

0000041c <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 41c:	55                   	push   %ebp
 41d:	89 e5                	mov    %esp,%ebp
 41f:	83 ec 48             	sub    $0x48,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 422:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 429:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 42d:	74 17                	je     446 <printint+0x2a>
 42f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 433:	79 11                	jns    446 <printint+0x2a>
    neg = 1;
 435:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 43c:	8b 45 0c             	mov    0xc(%ebp),%eax
 43f:	f7 d8                	neg    %eax
 441:	89 45 ec             	mov    %eax,-0x14(%ebp)
 444:	eb 06                	jmp    44c <printint+0x30>
  } else {
    x = xx;
 446:	8b 45 0c             	mov    0xc(%ebp),%eax
 449:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 44c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 453:	8b 4d 10             	mov    0x10(%ebp),%ecx
 456:	8b 45 ec             	mov    -0x14(%ebp),%eax
 459:	ba 00 00 00 00       	mov    $0x0,%edx
 45e:	f7 f1                	div    %ecx
 460:	89 d0                	mov    %edx,%eax
 462:	0f b6 90 f0 0a 00 00 	movzbl 0xaf0(%eax),%edx
 469:	8d 45 dc             	lea    -0x24(%ebp),%eax
 46c:	03 45 f4             	add    -0xc(%ebp),%eax
 46f:	88 10                	mov    %dl,(%eax)
 471:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  }while((x /= base) != 0);
 475:	8b 55 10             	mov    0x10(%ebp),%edx
 478:	89 55 d4             	mov    %edx,-0x2c(%ebp)
 47b:	8b 45 ec             	mov    -0x14(%ebp),%eax
 47e:	ba 00 00 00 00       	mov    $0x0,%edx
 483:	f7 75 d4             	divl   -0x2c(%ebp)
 486:	89 45 ec             	mov    %eax,-0x14(%ebp)
 489:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 48d:	75 c4                	jne    453 <printint+0x37>
  if(neg)
 48f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 493:	74 2a                	je     4bf <printint+0xa3>
    buf[i++] = '-';
 495:	8d 45 dc             	lea    -0x24(%ebp),%eax
 498:	03 45 f4             	add    -0xc(%ebp),%eax
 49b:	c6 00 2d             	movb   $0x2d,(%eax)
 49e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

  while(--i >= 0)
 4a2:	eb 1b                	jmp    4bf <printint+0xa3>
    putc(fd, buf[i]);
 4a4:	8d 45 dc             	lea    -0x24(%ebp),%eax
 4a7:	03 45 f4             	add    -0xc(%ebp),%eax
 4aa:	0f b6 00             	movzbl (%eax),%eax
 4ad:	0f be c0             	movsbl %al,%eax
 4b0:	89 44 24 04          	mov    %eax,0x4(%esp)
 4b4:	8b 45 08             	mov    0x8(%ebp),%eax
 4b7:	89 04 24             	mov    %eax,(%esp)
 4ba:	e8 35 ff ff ff       	call   3f4 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 4bf:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 4c3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 4c7:	79 db                	jns    4a4 <printint+0x88>
    putc(fd, buf[i]);
}
 4c9:	c9                   	leave  
 4ca:	c3                   	ret    

000004cb <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 4cb:	55                   	push   %ebp
 4cc:	89 e5                	mov    %esp,%ebp
 4ce:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 4d1:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 4d8:	8d 45 0c             	lea    0xc(%ebp),%eax
 4db:	83 c0 04             	add    $0x4,%eax
 4de:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 4e1:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 4e8:	e9 7d 01 00 00       	jmp    66a <printf+0x19f>
    c = fmt[i] & 0xff;
 4ed:	8b 55 0c             	mov    0xc(%ebp),%edx
 4f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
 4f3:	01 d0                	add    %edx,%eax
 4f5:	0f b6 00             	movzbl (%eax),%eax
 4f8:	0f be c0             	movsbl %al,%eax
 4fb:	25 ff 00 00 00       	and    $0xff,%eax
 500:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 503:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 507:	75 2c                	jne    535 <printf+0x6a>
      if(c == '%'){
 509:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 50d:	75 0c                	jne    51b <printf+0x50>
        state = '%';
 50f:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 516:	e9 4b 01 00 00       	jmp    666 <printf+0x19b>
      } else {
        putc(fd, c);
 51b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 51e:	0f be c0             	movsbl %al,%eax
 521:	89 44 24 04          	mov    %eax,0x4(%esp)
 525:	8b 45 08             	mov    0x8(%ebp),%eax
 528:	89 04 24             	mov    %eax,(%esp)
 52b:	e8 c4 fe ff ff       	call   3f4 <putc>
 530:	e9 31 01 00 00       	jmp    666 <printf+0x19b>
      }
    } else if(state == '%'){
 535:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 539:	0f 85 27 01 00 00    	jne    666 <printf+0x19b>
      if(c == 'd'){
 53f:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 543:	75 2d                	jne    572 <printf+0xa7>
        printint(fd, *ap, 10, 1);
 545:	8b 45 e8             	mov    -0x18(%ebp),%eax
 548:	8b 00                	mov    (%eax),%eax
 54a:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 551:	00 
 552:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 559:	00 
 55a:	89 44 24 04          	mov    %eax,0x4(%esp)
 55e:	8b 45 08             	mov    0x8(%ebp),%eax
 561:	89 04 24             	mov    %eax,(%esp)
 564:	e8 b3 fe ff ff       	call   41c <printint>
        ap++;
 569:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 56d:	e9 ed 00 00 00       	jmp    65f <printf+0x194>
      } else if(c == 'x' || c == 'p'){
 572:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 576:	74 06                	je     57e <printf+0xb3>
 578:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 57c:	75 2d                	jne    5ab <printf+0xe0>
        printint(fd, *ap, 16, 0);
 57e:	8b 45 e8             	mov    -0x18(%ebp),%eax
 581:	8b 00                	mov    (%eax),%eax
 583:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 58a:	00 
 58b:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 592:	00 
 593:	89 44 24 04          	mov    %eax,0x4(%esp)
 597:	8b 45 08             	mov    0x8(%ebp),%eax
 59a:	89 04 24             	mov    %eax,(%esp)
 59d:	e8 7a fe ff ff       	call   41c <printint>
        ap++;
 5a2:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 5a6:	e9 b4 00 00 00       	jmp    65f <printf+0x194>
      } else if(c == 's'){
 5ab:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 5af:	75 46                	jne    5f7 <printf+0x12c>
        s = (char*)*ap;
 5b1:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5b4:	8b 00                	mov    (%eax),%eax
 5b6:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 5b9:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 5bd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 5c1:	75 27                	jne    5ea <printf+0x11f>
          s = "(null)";
 5c3:	c7 45 f4 ad 08 00 00 	movl   $0x8ad,-0xc(%ebp)
        while(*s != 0){
 5ca:	eb 1e                	jmp    5ea <printf+0x11f>
          putc(fd, *s);
 5cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5cf:	0f b6 00             	movzbl (%eax),%eax
 5d2:	0f be c0             	movsbl %al,%eax
 5d5:	89 44 24 04          	mov    %eax,0x4(%esp)
 5d9:	8b 45 08             	mov    0x8(%ebp),%eax
 5dc:	89 04 24             	mov    %eax,(%esp)
 5df:	e8 10 fe ff ff       	call   3f4 <putc>
          s++;
 5e4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 5e8:	eb 01                	jmp    5eb <printf+0x120>
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 5ea:	90                   	nop
 5eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5ee:	0f b6 00             	movzbl (%eax),%eax
 5f1:	84 c0                	test   %al,%al
 5f3:	75 d7                	jne    5cc <printf+0x101>
 5f5:	eb 68                	jmp    65f <printf+0x194>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 5f7:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 5fb:	75 1d                	jne    61a <printf+0x14f>
        putc(fd, *ap);
 5fd:	8b 45 e8             	mov    -0x18(%ebp),%eax
 600:	8b 00                	mov    (%eax),%eax
 602:	0f be c0             	movsbl %al,%eax
 605:	89 44 24 04          	mov    %eax,0x4(%esp)
 609:	8b 45 08             	mov    0x8(%ebp),%eax
 60c:	89 04 24             	mov    %eax,(%esp)
 60f:	e8 e0 fd ff ff       	call   3f4 <putc>
        ap++;
 614:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 618:	eb 45                	jmp    65f <printf+0x194>
      } else if(c == '%'){
 61a:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 61e:	75 17                	jne    637 <printf+0x16c>
        putc(fd, c);
 620:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 623:	0f be c0             	movsbl %al,%eax
 626:	89 44 24 04          	mov    %eax,0x4(%esp)
 62a:	8b 45 08             	mov    0x8(%ebp),%eax
 62d:	89 04 24             	mov    %eax,(%esp)
 630:	e8 bf fd ff ff       	call   3f4 <putc>
 635:	eb 28                	jmp    65f <printf+0x194>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 637:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 63e:	00 
 63f:	8b 45 08             	mov    0x8(%ebp),%eax
 642:	89 04 24             	mov    %eax,(%esp)
 645:	e8 aa fd ff ff       	call   3f4 <putc>
        putc(fd, c);
 64a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 64d:	0f be c0             	movsbl %al,%eax
 650:	89 44 24 04          	mov    %eax,0x4(%esp)
 654:	8b 45 08             	mov    0x8(%ebp),%eax
 657:	89 04 24             	mov    %eax,(%esp)
 65a:	e8 95 fd ff ff       	call   3f4 <putc>
      }
      state = 0;
 65f:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 666:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 66a:	8b 55 0c             	mov    0xc(%ebp),%edx
 66d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 670:	01 d0                	add    %edx,%eax
 672:	0f b6 00             	movzbl (%eax),%eax
 675:	84 c0                	test   %al,%al
 677:	0f 85 70 fe ff ff    	jne    4ed <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 67d:	c9                   	leave  
 67e:	c3                   	ret    
 67f:	90                   	nop

00000680 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 680:	55                   	push   %ebp
 681:	89 e5                	mov    %esp,%ebp
 683:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 686:	8b 45 08             	mov    0x8(%ebp),%eax
 689:	83 e8 08             	sub    $0x8,%eax
 68c:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 68f:	a1 0c 0b 00 00       	mov    0xb0c,%eax
 694:	89 45 fc             	mov    %eax,-0x4(%ebp)
 697:	eb 24                	jmp    6bd <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 699:	8b 45 fc             	mov    -0x4(%ebp),%eax
 69c:	8b 00                	mov    (%eax),%eax
 69e:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 6a1:	77 12                	ja     6b5 <free+0x35>
 6a3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6a6:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 6a9:	77 24                	ja     6cf <free+0x4f>
 6ab:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6ae:	8b 00                	mov    (%eax),%eax
 6b0:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 6b3:	77 1a                	ja     6cf <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6b5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6b8:	8b 00                	mov    (%eax),%eax
 6ba:	89 45 fc             	mov    %eax,-0x4(%ebp)
 6bd:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6c0:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 6c3:	76 d4                	jbe    699 <free+0x19>
 6c5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6c8:	8b 00                	mov    (%eax),%eax
 6ca:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 6cd:	76 ca                	jbe    699 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 6cf:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6d2:	8b 40 04             	mov    0x4(%eax),%eax
 6d5:	c1 e0 03             	shl    $0x3,%eax
 6d8:	89 c2                	mov    %eax,%edx
 6da:	03 55 f8             	add    -0x8(%ebp),%edx
 6dd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6e0:	8b 00                	mov    (%eax),%eax
 6e2:	39 c2                	cmp    %eax,%edx
 6e4:	75 24                	jne    70a <free+0x8a>
    bp->s.size += p->s.ptr->s.size;
 6e6:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6e9:	8b 50 04             	mov    0x4(%eax),%edx
 6ec:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6ef:	8b 00                	mov    (%eax),%eax
 6f1:	8b 40 04             	mov    0x4(%eax),%eax
 6f4:	01 c2                	add    %eax,%edx
 6f6:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6f9:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 6fc:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6ff:	8b 00                	mov    (%eax),%eax
 701:	8b 10                	mov    (%eax),%edx
 703:	8b 45 f8             	mov    -0x8(%ebp),%eax
 706:	89 10                	mov    %edx,(%eax)
 708:	eb 0a                	jmp    714 <free+0x94>
  } else
    bp->s.ptr = p->s.ptr;
 70a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 70d:	8b 10                	mov    (%eax),%edx
 70f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 712:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 714:	8b 45 fc             	mov    -0x4(%ebp),%eax
 717:	8b 40 04             	mov    0x4(%eax),%eax
 71a:	c1 e0 03             	shl    $0x3,%eax
 71d:	03 45 fc             	add    -0x4(%ebp),%eax
 720:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 723:	75 20                	jne    745 <free+0xc5>
    p->s.size += bp->s.size;
 725:	8b 45 fc             	mov    -0x4(%ebp),%eax
 728:	8b 50 04             	mov    0x4(%eax),%edx
 72b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 72e:	8b 40 04             	mov    0x4(%eax),%eax
 731:	01 c2                	add    %eax,%edx
 733:	8b 45 fc             	mov    -0x4(%ebp),%eax
 736:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 739:	8b 45 f8             	mov    -0x8(%ebp),%eax
 73c:	8b 10                	mov    (%eax),%edx
 73e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 741:	89 10                	mov    %edx,(%eax)
 743:	eb 08                	jmp    74d <free+0xcd>
  } else
    p->s.ptr = bp;
 745:	8b 45 fc             	mov    -0x4(%ebp),%eax
 748:	8b 55 f8             	mov    -0x8(%ebp),%edx
 74b:	89 10                	mov    %edx,(%eax)
  freep = p;
 74d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 750:	a3 0c 0b 00 00       	mov    %eax,0xb0c
}
 755:	c9                   	leave  
 756:	c3                   	ret    

00000757 <morecore>:

static Header*
morecore(uint nu)
{
 757:	55                   	push   %ebp
 758:	89 e5                	mov    %esp,%ebp
 75a:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 75d:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 764:	77 07                	ja     76d <morecore+0x16>
    nu = 4096;
 766:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 76d:	8b 45 08             	mov    0x8(%ebp),%eax
 770:	c1 e0 03             	shl    $0x3,%eax
 773:	89 04 24             	mov    %eax,(%esp)
 776:	e8 51 fc ff ff       	call   3cc <sbrk>
 77b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 77e:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 782:	75 07                	jne    78b <morecore+0x34>
    return 0;
 784:	b8 00 00 00 00       	mov    $0x0,%eax
 789:	eb 22                	jmp    7ad <morecore+0x56>
  hp = (Header*)p;
 78b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 78e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 791:	8b 45 f0             	mov    -0x10(%ebp),%eax
 794:	8b 55 08             	mov    0x8(%ebp),%edx
 797:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 79a:	8b 45 f0             	mov    -0x10(%ebp),%eax
 79d:	83 c0 08             	add    $0x8,%eax
 7a0:	89 04 24             	mov    %eax,(%esp)
 7a3:	e8 d8 fe ff ff       	call   680 <free>
  return freep;
 7a8:	a1 0c 0b 00 00       	mov    0xb0c,%eax
}
 7ad:	c9                   	leave  
 7ae:	c3                   	ret    

000007af <malloc>:

void*
malloc(uint nbytes)
{
 7af:	55                   	push   %ebp
 7b0:	89 e5                	mov    %esp,%ebp
 7b2:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 7b5:	8b 45 08             	mov    0x8(%ebp),%eax
 7b8:	83 c0 07             	add    $0x7,%eax
 7bb:	c1 e8 03             	shr    $0x3,%eax
 7be:	83 c0 01             	add    $0x1,%eax
 7c1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 7c4:	a1 0c 0b 00 00       	mov    0xb0c,%eax
 7c9:	89 45 f0             	mov    %eax,-0x10(%ebp)
 7cc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 7d0:	75 23                	jne    7f5 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 7d2:	c7 45 f0 04 0b 00 00 	movl   $0xb04,-0x10(%ebp)
 7d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7dc:	a3 0c 0b 00 00       	mov    %eax,0xb0c
 7e1:	a1 0c 0b 00 00       	mov    0xb0c,%eax
 7e6:	a3 04 0b 00 00       	mov    %eax,0xb04
    base.s.size = 0;
 7eb:	c7 05 08 0b 00 00 00 	movl   $0x0,0xb08
 7f2:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7f8:	8b 00                	mov    (%eax),%eax
 7fa:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 7fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 800:	8b 40 04             	mov    0x4(%eax),%eax
 803:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 806:	72 4d                	jb     855 <malloc+0xa6>
      if(p->s.size == nunits)
 808:	8b 45 f4             	mov    -0xc(%ebp),%eax
 80b:	8b 40 04             	mov    0x4(%eax),%eax
 80e:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 811:	75 0c                	jne    81f <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 813:	8b 45 f4             	mov    -0xc(%ebp),%eax
 816:	8b 10                	mov    (%eax),%edx
 818:	8b 45 f0             	mov    -0x10(%ebp),%eax
 81b:	89 10                	mov    %edx,(%eax)
 81d:	eb 26                	jmp    845 <malloc+0x96>
      else {
        p->s.size -= nunits;
 81f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 822:	8b 40 04             	mov    0x4(%eax),%eax
 825:	89 c2                	mov    %eax,%edx
 827:	2b 55 ec             	sub    -0x14(%ebp),%edx
 82a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 82d:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 830:	8b 45 f4             	mov    -0xc(%ebp),%eax
 833:	8b 40 04             	mov    0x4(%eax),%eax
 836:	c1 e0 03             	shl    $0x3,%eax
 839:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 83c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 83f:	8b 55 ec             	mov    -0x14(%ebp),%edx
 842:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 845:	8b 45 f0             	mov    -0x10(%ebp),%eax
 848:	a3 0c 0b 00 00       	mov    %eax,0xb0c
      return (void*)(p + 1);
 84d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 850:	83 c0 08             	add    $0x8,%eax
 853:	eb 38                	jmp    88d <malloc+0xde>
    }
    if(p == freep)
 855:	a1 0c 0b 00 00       	mov    0xb0c,%eax
 85a:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 85d:	75 1b                	jne    87a <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 85f:	8b 45 ec             	mov    -0x14(%ebp),%eax
 862:	89 04 24             	mov    %eax,(%esp)
 865:	e8 ed fe ff ff       	call   757 <morecore>
 86a:	89 45 f4             	mov    %eax,-0xc(%ebp)
 86d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 871:	75 07                	jne    87a <malloc+0xcb>
        return 0;
 873:	b8 00 00 00 00       	mov    $0x0,%eax
 878:	eb 13                	jmp    88d <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 87a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 87d:	89 45 f0             	mov    %eax,-0x10(%ebp)
 880:	8b 45 f4             	mov    -0xc(%ebp),%eax
 883:	8b 00                	mov    (%eax),%eax
 885:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 888:	e9 70 ff ff ff       	jmp    7fd <malloc+0x4e>
}
 88d:	c9                   	leave  
 88e:	c3                   	ret    
