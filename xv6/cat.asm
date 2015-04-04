
_cat:     file format elf32-i386


Disassembly of section .text:

00000000 <cat>:

char buf[512];

void
cat(int fd)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 ec 28             	sub    $0x28,%esp
  int n;

  while((n = read(fd, buf, sizeof(buf))) > 0)
   6:	eb 1b                	jmp    23 <cat+0x23>
    write(1, buf, n);
   8:	8b 45 f4             	mov    -0xc(%ebp),%eax
   b:	89 44 24 08          	mov    %eax,0x8(%esp)
   f:	c7 44 24 04 a0 0b 00 	movl   $0xba0,0x4(%esp)
  16:	00 
  17:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1e:	e8 8d 03 00 00       	call   3b0 <write>
void
cat(int fd)
{
  int n;

  while((n = read(fd, buf, sizeof(buf))) > 0)
  23:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  2a:	00 
  2b:	c7 44 24 04 a0 0b 00 	movl   $0xba0,0x4(%esp)
  32:	00 
  33:	8b 45 08             	mov    0x8(%ebp),%eax
  36:	89 04 24             	mov    %eax,(%esp)
  39:	e8 6a 03 00 00       	call   3a8 <read>
  3e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  41:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  45:	7f c1                	jg     8 <cat+0x8>
    write(1, buf, n);
  if(n < 0){
  47:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  4b:	79 20                	jns    6d <cat+0x6d>
    printf(1, "cat: read error\n");
  4d:	c7 44 24 04 db 08 00 	movl   $0x8db,0x4(%esp)
  54:	00 
  55:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  5c:	e8 b6 04 00 00       	call   517 <printf>
    exit(EXIT_STATUS_FAILURE);
  61:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  68:	e8 23 03 00 00       	call   390 <exit>
  }
}
  6d:	c9                   	leave  
  6e:	c3                   	ret    

0000006f <main>:

int
main(int argc, char *argv[])
{
  6f:	55                   	push   %ebp
  70:	89 e5                	mov    %esp,%ebp
  72:	83 e4 f0             	and    $0xfffffff0,%esp
  75:	83 ec 20             	sub    $0x20,%esp
  int fd, i;

  if(argc <= 1){
  78:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
  7c:	7f 18                	jg     96 <main+0x27>
    cat(0);
  7e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  85:	e8 76 ff ff ff       	call   0 <cat>
    exit(EXIT_STATUS_FAILURE);
  8a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  91:	e8 fa 02 00 00       	call   390 <exit>
  }

  for(i = 1; i < argc; i++){
  96:	c7 44 24 1c 01 00 00 	movl   $0x1,0x1c(%esp)
  9d:	00 
  9e:	eb 74                	jmp    114 <main+0xa5>
    if((fd = open(argv[i], 0)) < 0){
  a0:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  a4:	c1 e0 02             	shl    $0x2,%eax
  a7:	03 45 0c             	add    0xc(%ebp),%eax
  aa:	8b 00                	mov    (%eax),%eax
  ac:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  b3:	00 
  b4:	89 04 24             	mov    %eax,(%esp)
  b7:	e8 14 03 00 00       	call   3d0 <open>
  bc:	89 44 24 18          	mov    %eax,0x18(%esp)
  c0:	83 7c 24 18 00       	cmpl   $0x0,0x18(%esp)
  c5:	79 30                	jns    f7 <main+0x88>
      printf(1, "cat: cannot open %s\n", argv[i]);
  c7:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  cb:	c1 e0 02             	shl    $0x2,%eax
  ce:	03 45 0c             	add    0xc(%ebp),%eax
  d1:	8b 00                	mov    (%eax),%eax
  d3:	89 44 24 08          	mov    %eax,0x8(%esp)
  d7:	c7 44 24 04 ec 08 00 	movl   $0x8ec,0x4(%esp)
  de:	00 
  df:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  e6:	e8 2c 04 00 00       	call   517 <printf>
      exit(EXIT_STATUS_FAILURE);
  eb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  f2:	e8 99 02 00 00       	call   390 <exit>
    }
    cat(fd);
  f7:	8b 44 24 18          	mov    0x18(%esp),%eax
  fb:	89 04 24             	mov    %eax,(%esp)
  fe:	e8 fd fe ff ff       	call   0 <cat>
    close(fd);
 103:	8b 44 24 18          	mov    0x18(%esp),%eax
 107:	89 04 24             	mov    %eax,(%esp)
 10a:	e8 a9 02 00 00       	call   3b8 <close>
  if(argc <= 1){
    cat(0);
    exit(EXIT_STATUS_FAILURE);
  }

  for(i = 1; i < argc; i++){
 10f:	83 44 24 1c 01       	addl   $0x1,0x1c(%esp)
 114:	8b 44 24 1c          	mov    0x1c(%esp),%eax
 118:	3b 45 08             	cmp    0x8(%ebp),%eax
 11b:	7c 83                	jl     a0 <main+0x31>
      exit(EXIT_STATUS_FAILURE);
    }
    cat(fd);
    close(fd);
  }
  exit(EXIT_STATUS_SUCCESS);
 11d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 124:	e8 67 02 00 00       	call   390 <exit>
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

00000440 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 440:	55                   	push   %ebp
 441:	89 e5                	mov    %esp,%ebp
 443:	83 ec 28             	sub    $0x28,%esp
 446:	8b 45 0c             	mov    0xc(%ebp),%eax
 449:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 44c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 453:	00 
 454:	8d 45 f4             	lea    -0xc(%ebp),%eax
 457:	89 44 24 04          	mov    %eax,0x4(%esp)
 45b:	8b 45 08             	mov    0x8(%ebp),%eax
 45e:	89 04 24             	mov    %eax,(%esp)
 461:	e8 4a ff ff ff       	call   3b0 <write>
}
 466:	c9                   	leave  
 467:	c3                   	ret    

00000468 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 468:	55                   	push   %ebp
 469:	89 e5                	mov    %esp,%ebp
 46b:	83 ec 48             	sub    $0x48,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 46e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 475:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 479:	74 17                	je     492 <printint+0x2a>
 47b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 47f:	79 11                	jns    492 <printint+0x2a>
    neg = 1;
 481:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 488:	8b 45 0c             	mov    0xc(%ebp),%eax
 48b:	f7 d8                	neg    %eax
 48d:	89 45 ec             	mov    %eax,-0x14(%ebp)
 490:	eb 06                	jmp    498 <printint+0x30>
  } else {
    x = xx;
 492:	8b 45 0c             	mov    0xc(%ebp),%eax
 495:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 498:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 49f:	8b 4d 10             	mov    0x10(%ebp),%ecx
 4a2:	8b 45 ec             	mov    -0x14(%ebp),%eax
 4a5:	ba 00 00 00 00       	mov    $0x0,%edx
 4aa:	f7 f1                	div    %ecx
 4ac:	89 d0                	mov    %edx,%eax
 4ae:	0f b6 90 64 0b 00 00 	movzbl 0xb64(%eax),%edx
 4b5:	8d 45 dc             	lea    -0x24(%ebp),%eax
 4b8:	03 45 f4             	add    -0xc(%ebp),%eax
 4bb:	88 10                	mov    %dl,(%eax)
 4bd:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  }while((x /= base) != 0);
 4c1:	8b 55 10             	mov    0x10(%ebp),%edx
 4c4:	89 55 d4             	mov    %edx,-0x2c(%ebp)
 4c7:	8b 45 ec             	mov    -0x14(%ebp),%eax
 4ca:	ba 00 00 00 00       	mov    $0x0,%edx
 4cf:	f7 75 d4             	divl   -0x2c(%ebp)
 4d2:	89 45 ec             	mov    %eax,-0x14(%ebp)
 4d5:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 4d9:	75 c4                	jne    49f <printint+0x37>
  if(neg)
 4db:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 4df:	74 2a                	je     50b <printint+0xa3>
    buf[i++] = '-';
 4e1:	8d 45 dc             	lea    -0x24(%ebp),%eax
 4e4:	03 45 f4             	add    -0xc(%ebp),%eax
 4e7:	c6 00 2d             	movb   $0x2d,(%eax)
 4ea:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

  while(--i >= 0)
 4ee:	eb 1b                	jmp    50b <printint+0xa3>
    putc(fd, buf[i]);
 4f0:	8d 45 dc             	lea    -0x24(%ebp),%eax
 4f3:	03 45 f4             	add    -0xc(%ebp),%eax
 4f6:	0f b6 00             	movzbl (%eax),%eax
 4f9:	0f be c0             	movsbl %al,%eax
 4fc:	89 44 24 04          	mov    %eax,0x4(%esp)
 500:	8b 45 08             	mov    0x8(%ebp),%eax
 503:	89 04 24             	mov    %eax,(%esp)
 506:	e8 35 ff ff ff       	call   440 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 50b:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 50f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 513:	79 db                	jns    4f0 <printint+0x88>
    putc(fd, buf[i]);
}
 515:	c9                   	leave  
 516:	c3                   	ret    

00000517 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 517:	55                   	push   %ebp
 518:	89 e5                	mov    %esp,%ebp
 51a:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 51d:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 524:	8d 45 0c             	lea    0xc(%ebp),%eax
 527:	83 c0 04             	add    $0x4,%eax
 52a:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 52d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 534:	e9 7d 01 00 00       	jmp    6b6 <printf+0x19f>
    c = fmt[i] & 0xff;
 539:	8b 55 0c             	mov    0xc(%ebp),%edx
 53c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 53f:	01 d0                	add    %edx,%eax
 541:	0f b6 00             	movzbl (%eax),%eax
 544:	0f be c0             	movsbl %al,%eax
 547:	25 ff 00 00 00       	and    $0xff,%eax
 54c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 54f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 553:	75 2c                	jne    581 <printf+0x6a>
      if(c == '%'){
 555:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 559:	75 0c                	jne    567 <printf+0x50>
        state = '%';
 55b:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 562:	e9 4b 01 00 00       	jmp    6b2 <printf+0x19b>
      } else {
        putc(fd, c);
 567:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 56a:	0f be c0             	movsbl %al,%eax
 56d:	89 44 24 04          	mov    %eax,0x4(%esp)
 571:	8b 45 08             	mov    0x8(%ebp),%eax
 574:	89 04 24             	mov    %eax,(%esp)
 577:	e8 c4 fe ff ff       	call   440 <putc>
 57c:	e9 31 01 00 00       	jmp    6b2 <printf+0x19b>
      }
    } else if(state == '%'){
 581:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 585:	0f 85 27 01 00 00    	jne    6b2 <printf+0x19b>
      if(c == 'd'){
 58b:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 58f:	75 2d                	jne    5be <printf+0xa7>
        printint(fd, *ap, 10, 1);
 591:	8b 45 e8             	mov    -0x18(%ebp),%eax
 594:	8b 00                	mov    (%eax),%eax
 596:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 59d:	00 
 59e:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 5a5:	00 
 5a6:	89 44 24 04          	mov    %eax,0x4(%esp)
 5aa:	8b 45 08             	mov    0x8(%ebp),%eax
 5ad:	89 04 24             	mov    %eax,(%esp)
 5b0:	e8 b3 fe ff ff       	call   468 <printint>
        ap++;
 5b5:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 5b9:	e9 ed 00 00 00       	jmp    6ab <printf+0x194>
      } else if(c == 'x' || c == 'p'){
 5be:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 5c2:	74 06                	je     5ca <printf+0xb3>
 5c4:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 5c8:	75 2d                	jne    5f7 <printf+0xe0>
        printint(fd, *ap, 16, 0);
 5ca:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5cd:	8b 00                	mov    (%eax),%eax
 5cf:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 5d6:	00 
 5d7:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 5de:	00 
 5df:	89 44 24 04          	mov    %eax,0x4(%esp)
 5e3:	8b 45 08             	mov    0x8(%ebp),%eax
 5e6:	89 04 24             	mov    %eax,(%esp)
 5e9:	e8 7a fe ff ff       	call   468 <printint>
        ap++;
 5ee:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 5f2:	e9 b4 00 00 00       	jmp    6ab <printf+0x194>
      } else if(c == 's'){
 5f7:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 5fb:	75 46                	jne    643 <printf+0x12c>
        s = (char*)*ap;
 5fd:	8b 45 e8             	mov    -0x18(%ebp),%eax
 600:	8b 00                	mov    (%eax),%eax
 602:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 605:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 609:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 60d:	75 27                	jne    636 <printf+0x11f>
          s = "(null)";
 60f:	c7 45 f4 01 09 00 00 	movl   $0x901,-0xc(%ebp)
        while(*s != 0){
 616:	eb 1e                	jmp    636 <printf+0x11f>
          putc(fd, *s);
 618:	8b 45 f4             	mov    -0xc(%ebp),%eax
 61b:	0f b6 00             	movzbl (%eax),%eax
 61e:	0f be c0             	movsbl %al,%eax
 621:	89 44 24 04          	mov    %eax,0x4(%esp)
 625:	8b 45 08             	mov    0x8(%ebp),%eax
 628:	89 04 24             	mov    %eax,(%esp)
 62b:	e8 10 fe ff ff       	call   440 <putc>
          s++;
 630:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 634:	eb 01                	jmp    637 <printf+0x120>
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 636:	90                   	nop
 637:	8b 45 f4             	mov    -0xc(%ebp),%eax
 63a:	0f b6 00             	movzbl (%eax),%eax
 63d:	84 c0                	test   %al,%al
 63f:	75 d7                	jne    618 <printf+0x101>
 641:	eb 68                	jmp    6ab <printf+0x194>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 643:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 647:	75 1d                	jne    666 <printf+0x14f>
        putc(fd, *ap);
 649:	8b 45 e8             	mov    -0x18(%ebp),%eax
 64c:	8b 00                	mov    (%eax),%eax
 64e:	0f be c0             	movsbl %al,%eax
 651:	89 44 24 04          	mov    %eax,0x4(%esp)
 655:	8b 45 08             	mov    0x8(%ebp),%eax
 658:	89 04 24             	mov    %eax,(%esp)
 65b:	e8 e0 fd ff ff       	call   440 <putc>
        ap++;
 660:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 664:	eb 45                	jmp    6ab <printf+0x194>
      } else if(c == '%'){
 666:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 66a:	75 17                	jne    683 <printf+0x16c>
        putc(fd, c);
 66c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 66f:	0f be c0             	movsbl %al,%eax
 672:	89 44 24 04          	mov    %eax,0x4(%esp)
 676:	8b 45 08             	mov    0x8(%ebp),%eax
 679:	89 04 24             	mov    %eax,(%esp)
 67c:	e8 bf fd ff ff       	call   440 <putc>
 681:	eb 28                	jmp    6ab <printf+0x194>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 683:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 68a:	00 
 68b:	8b 45 08             	mov    0x8(%ebp),%eax
 68e:	89 04 24             	mov    %eax,(%esp)
 691:	e8 aa fd ff ff       	call   440 <putc>
        putc(fd, c);
 696:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 699:	0f be c0             	movsbl %al,%eax
 69c:	89 44 24 04          	mov    %eax,0x4(%esp)
 6a0:	8b 45 08             	mov    0x8(%ebp),%eax
 6a3:	89 04 24             	mov    %eax,(%esp)
 6a6:	e8 95 fd ff ff       	call   440 <putc>
      }
      state = 0;
 6ab:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 6b2:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 6b6:	8b 55 0c             	mov    0xc(%ebp),%edx
 6b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6bc:	01 d0                	add    %edx,%eax
 6be:	0f b6 00             	movzbl (%eax),%eax
 6c1:	84 c0                	test   %al,%al
 6c3:	0f 85 70 fe ff ff    	jne    539 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 6c9:	c9                   	leave  
 6ca:	c3                   	ret    
 6cb:	90                   	nop

000006cc <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 6cc:	55                   	push   %ebp
 6cd:	89 e5                	mov    %esp,%ebp
 6cf:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 6d2:	8b 45 08             	mov    0x8(%ebp),%eax
 6d5:	83 e8 08             	sub    $0x8,%eax
 6d8:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6db:	a1 88 0b 00 00       	mov    0xb88,%eax
 6e0:	89 45 fc             	mov    %eax,-0x4(%ebp)
 6e3:	eb 24                	jmp    709 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6e5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6e8:	8b 00                	mov    (%eax),%eax
 6ea:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 6ed:	77 12                	ja     701 <free+0x35>
 6ef:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6f2:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 6f5:	77 24                	ja     71b <free+0x4f>
 6f7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6fa:	8b 00                	mov    (%eax),%eax
 6fc:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 6ff:	77 1a                	ja     71b <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 701:	8b 45 fc             	mov    -0x4(%ebp),%eax
 704:	8b 00                	mov    (%eax),%eax
 706:	89 45 fc             	mov    %eax,-0x4(%ebp)
 709:	8b 45 f8             	mov    -0x8(%ebp),%eax
 70c:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 70f:	76 d4                	jbe    6e5 <free+0x19>
 711:	8b 45 fc             	mov    -0x4(%ebp),%eax
 714:	8b 00                	mov    (%eax),%eax
 716:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 719:	76 ca                	jbe    6e5 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 71b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 71e:	8b 40 04             	mov    0x4(%eax),%eax
 721:	c1 e0 03             	shl    $0x3,%eax
 724:	89 c2                	mov    %eax,%edx
 726:	03 55 f8             	add    -0x8(%ebp),%edx
 729:	8b 45 fc             	mov    -0x4(%ebp),%eax
 72c:	8b 00                	mov    (%eax),%eax
 72e:	39 c2                	cmp    %eax,%edx
 730:	75 24                	jne    756 <free+0x8a>
    bp->s.size += p->s.ptr->s.size;
 732:	8b 45 f8             	mov    -0x8(%ebp),%eax
 735:	8b 50 04             	mov    0x4(%eax),%edx
 738:	8b 45 fc             	mov    -0x4(%ebp),%eax
 73b:	8b 00                	mov    (%eax),%eax
 73d:	8b 40 04             	mov    0x4(%eax),%eax
 740:	01 c2                	add    %eax,%edx
 742:	8b 45 f8             	mov    -0x8(%ebp),%eax
 745:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 748:	8b 45 fc             	mov    -0x4(%ebp),%eax
 74b:	8b 00                	mov    (%eax),%eax
 74d:	8b 10                	mov    (%eax),%edx
 74f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 752:	89 10                	mov    %edx,(%eax)
 754:	eb 0a                	jmp    760 <free+0x94>
  } else
    bp->s.ptr = p->s.ptr;
 756:	8b 45 fc             	mov    -0x4(%ebp),%eax
 759:	8b 10                	mov    (%eax),%edx
 75b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 75e:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 760:	8b 45 fc             	mov    -0x4(%ebp),%eax
 763:	8b 40 04             	mov    0x4(%eax),%eax
 766:	c1 e0 03             	shl    $0x3,%eax
 769:	03 45 fc             	add    -0x4(%ebp),%eax
 76c:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 76f:	75 20                	jne    791 <free+0xc5>
    p->s.size += bp->s.size;
 771:	8b 45 fc             	mov    -0x4(%ebp),%eax
 774:	8b 50 04             	mov    0x4(%eax),%edx
 777:	8b 45 f8             	mov    -0x8(%ebp),%eax
 77a:	8b 40 04             	mov    0x4(%eax),%eax
 77d:	01 c2                	add    %eax,%edx
 77f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 782:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 785:	8b 45 f8             	mov    -0x8(%ebp),%eax
 788:	8b 10                	mov    (%eax),%edx
 78a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 78d:	89 10                	mov    %edx,(%eax)
 78f:	eb 08                	jmp    799 <free+0xcd>
  } else
    p->s.ptr = bp;
 791:	8b 45 fc             	mov    -0x4(%ebp),%eax
 794:	8b 55 f8             	mov    -0x8(%ebp),%edx
 797:	89 10                	mov    %edx,(%eax)
  freep = p;
 799:	8b 45 fc             	mov    -0x4(%ebp),%eax
 79c:	a3 88 0b 00 00       	mov    %eax,0xb88
}
 7a1:	c9                   	leave  
 7a2:	c3                   	ret    

000007a3 <morecore>:

static Header*
morecore(uint nu)
{
 7a3:	55                   	push   %ebp
 7a4:	89 e5                	mov    %esp,%ebp
 7a6:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 7a9:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 7b0:	77 07                	ja     7b9 <morecore+0x16>
    nu = 4096;
 7b2:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 7b9:	8b 45 08             	mov    0x8(%ebp),%eax
 7bc:	c1 e0 03             	shl    $0x3,%eax
 7bf:	89 04 24             	mov    %eax,(%esp)
 7c2:	e8 51 fc ff ff       	call   418 <sbrk>
 7c7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 7ca:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 7ce:	75 07                	jne    7d7 <morecore+0x34>
    return 0;
 7d0:	b8 00 00 00 00       	mov    $0x0,%eax
 7d5:	eb 22                	jmp    7f9 <morecore+0x56>
  hp = (Header*)p;
 7d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7da:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 7dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7e0:	8b 55 08             	mov    0x8(%ebp),%edx
 7e3:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 7e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7e9:	83 c0 08             	add    $0x8,%eax
 7ec:	89 04 24             	mov    %eax,(%esp)
 7ef:	e8 d8 fe ff ff       	call   6cc <free>
  return freep;
 7f4:	a1 88 0b 00 00       	mov    0xb88,%eax
}
 7f9:	c9                   	leave  
 7fa:	c3                   	ret    

000007fb <malloc>:

void*
malloc(uint nbytes)
{
 7fb:	55                   	push   %ebp
 7fc:	89 e5                	mov    %esp,%ebp
 7fe:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 801:	8b 45 08             	mov    0x8(%ebp),%eax
 804:	83 c0 07             	add    $0x7,%eax
 807:	c1 e8 03             	shr    $0x3,%eax
 80a:	83 c0 01             	add    $0x1,%eax
 80d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 810:	a1 88 0b 00 00       	mov    0xb88,%eax
 815:	89 45 f0             	mov    %eax,-0x10(%ebp)
 818:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 81c:	75 23                	jne    841 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 81e:	c7 45 f0 80 0b 00 00 	movl   $0xb80,-0x10(%ebp)
 825:	8b 45 f0             	mov    -0x10(%ebp),%eax
 828:	a3 88 0b 00 00       	mov    %eax,0xb88
 82d:	a1 88 0b 00 00       	mov    0xb88,%eax
 832:	a3 80 0b 00 00       	mov    %eax,0xb80
    base.s.size = 0;
 837:	c7 05 84 0b 00 00 00 	movl   $0x0,0xb84
 83e:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 841:	8b 45 f0             	mov    -0x10(%ebp),%eax
 844:	8b 00                	mov    (%eax),%eax
 846:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 849:	8b 45 f4             	mov    -0xc(%ebp),%eax
 84c:	8b 40 04             	mov    0x4(%eax),%eax
 84f:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 852:	72 4d                	jb     8a1 <malloc+0xa6>
      if(p->s.size == nunits)
 854:	8b 45 f4             	mov    -0xc(%ebp),%eax
 857:	8b 40 04             	mov    0x4(%eax),%eax
 85a:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 85d:	75 0c                	jne    86b <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 85f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 862:	8b 10                	mov    (%eax),%edx
 864:	8b 45 f0             	mov    -0x10(%ebp),%eax
 867:	89 10                	mov    %edx,(%eax)
 869:	eb 26                	jmp    891 <malloc+0x96>
      else {
        p->s.size -= nunits;
 86b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 86e:	8b 40 04             	mov    0x4(%eax),%eax
 871:	89 c2                	mov    %eax,%edx
 873:	2b 55 ec             	sub    -0x14(%ebp),%edx
 876:	8b 45 f4             	mov    -0xc(%ebp),%eax
 879:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 87c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 87f:	8b 40 04             	mov    0x4(%eax),%eax
 882:	c1 e0 03             	shl    $0x3,%eax
 885:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 888:	8b 45 f4             	mov    -0xc(%ebp),%eax
 88b:	8b 55 ec             	mov    -0x14(%ebp),%edx
 88e:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 891:	8b 45 f0             	mov    -0x10(%ebp),%eax
 894:	a3 88 0b 00 00       	mov    %eax,0xb88
      return (void*)(p + 1);
 899:	8b 45 f4             	mov    -0xc(%ebp),%eax
 89c:	83 c0 08             	add    $0x8,%eax
 89f:	eb 38                	jmp    8d9 <malloc+0xde>
    }
    if(p == freep)
 8a1:	a1 88 0b 00 00       	mov    0xb88,%eax
 8a6:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 8a9:	75 1b                	jne    8c6 <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 8ab:	8b 45 ec             	mov    -0x14(%ebp),%eax
 8ae:	89 04 24             	mov    %eax,(%esp)
 8b1:	e8 ed fe ff ff       	call   7a3 <morecore>
 8b6:	89 45 f4             	mov    %eax,-0xc(%ebp)
 8b9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 8bd:	75 07                	jne    8c6 <malloc+0xcb>
        return 0;
 8bf:	b8 00 00 00 00       	mov    $0x0,%eax
 8c4:	eb 13                	jmp    8d9 <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8c9:	89 45 f0             	mov    %eax,-0x10(%ebp)
 8cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8cf:	8b 00                	mov    (%eax),%eax
 8d1:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 8d4:	e9 70 ff ff ff       	jmp    849 <malloc+0x4e>
}
 8d9:	c9                   	leave  
 8da:	c3                   	ret    
