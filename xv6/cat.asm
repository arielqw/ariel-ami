
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
  4d:	c7 44 24 04 cb 08 00 	movl   $0x8cb,0x4(%esp)
  54:	00 
  55:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  5c:	e8 a6 04 00 00       	call   507 <printf>
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
  d7:	c7 44 24 04 dc 08 00 	movl   $0x8dc,0x4(%esp)
  de:	00 
  df:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  e6:	e8 1c 04 00 00       	call   507 <printf>
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

00000430 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 430:	55                   	push   %ebp
 431:	89 e5                	mov    %esp,%ebp
 433:	83 ec 28             	sub    $0x28,%esp
 436:	8b 45 0c             	mov    0xc(%ebp),%eax
 439:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 43c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 443:	00 
 444:	8d 45 f4             	lea    -0xc(%ebp),%eax
 447:	89 44 24 04          	mov    %eax,0x4(%esp)
 44b:	8b 45 08             	mov    0x8(%ebp),%eax
 44e:	89 04 24             	mov    %eax,(%esp)
 451:	e8 5a ff ff ff       	call   3b0 <write>
}
 456:	c9                   	leave  
 457:	c3                   	ret    

00000458 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 458:	55                   	push   %ebp
 459:	89 e5                	mov    %esp,%ebp
 45b:	83 ec 48             	sub    $0x48,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 45e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 465:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 469:	74 17                	je     482 <printint+0x2a>
 46b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 46f:	79 11                	jns    482 <printint+0x2a>
    neg = 1;
 471:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 478:	8b 45 0c             	mov    0xc(%ebp),%eax
 47b:	f7 d8                	neg    %eax
 47d:	89 45 ec             	mov    %eax,-0x14(%ebp)
 480:	eb 06                	jmp    488 <printint+0x30>
  } else {
    x = xx;
 482:	8b 45 0c             	mov    0xc(%ebp),%eax
 485:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 488:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 48f:	8b 4d 10             	mov    0x10(%ebp),%ecx
 492:	8b 45 ec             	mov    -0x14(%ebp),%eax
 495:	ba 00 00 00 00       	mov    $0x0,%edx
 49a:	f7 f1                	div    %ecx
 49c:	89 d0                	mov    %edx,%eax
 49e:	0f b6 90 54 0b 00 00 	movzbl 0xb54(%eax),%edx
 4a5:	8d 45 dc             	lea    -0x24(%ebp),%eax
 4a8:	03 45 f4             	add    -0xc(%ebp),%eax
 4ab:	88 10                	mov    %dl,(%eax)
 4ad:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  }while((x /= base) != 0);
 4b1:	8b 55 10             	mov    0x10(%ebp),%edx
 4b4:	89 55 d4             	mov    %edx,-0x2c(%ebp)
 4b7:	8b 45 ec             	mov    -0x14(%ebp),%eax
 4ba:	ba 00 00 00 00       	mov    $0x0,%edx
 4bf:	f7 75 d4             	divl   -0x2c(%ebp)
 4c2:	89 45 ec             	mov    %eax,-0x14(%ebp)
 4c5:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 4c9:	75 c4                	jne    48f <printint+0x37>
  if(neg)
 4cb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 4cf:	74 2a                	je     4fb <printint+0xa3>
    buf[i++] = '-';
 4d1:	8d 45 dc             	lea    -0x24(%ebp),%eax
 4d4:	03 45 f4             	add    -0xc(%ebp),%eax
 4d7:	c6 00 2d             	movb   $0x2d,(%eax)
 4da:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

  while(--i >= 0)
 4de:	eb 1b                	jmp    4fb <printint+0xa3>
    putc(fd, buf[i]);
 4e0:	8d 45 dc             	lea    -0x24(%ebp),%eax
 4e3:	03 45 f4             	add    -0xc(%ebp),%eax
 4e6:	0f b6 00             	movzbl (%eax),%eax
 4e9:	0f be c0             	movsbl %al,%eax
 4ec:	89 44 24 04          	mov    %eax,0x4(%esp)
 4f0:	8b 45 08             	mov    0x8(%ebp),%eax
 4f3:	89 04 24             	mov    %eax,(%esp)
 4f6:	e8 35 ff ff ff       	call   430 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 4fb:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 4ff:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 503:	79 db                	jns    4e0 <printint+0x88>
    putc(fd, buf[i]);
}
 505:	c9                   	leave  
 506:	c3                   	ret    

00000507 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 507:	55                   	push   %ebp
 508:	89 e5                	mov    %esp,%ebp
 50a:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 50d:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 514:	8d 45 0c             	lea    0xc(%ebp),%eax
 517:	83 c0 04             	add    $0x4,%eax
 51a:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 51d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 524:	e9 7d 01 00 00       	jmp    6a6 <printf+0x19f>
    c = fmt[i] & 0xff;
 529:	8b 55 0c             	mov    0xc(%ebp),%edx
 52c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 52f:	01 d0                	add    %edx,%eax
 531:	0f b6 00             	movzbl (%eax),%eax
 534:	0f be c0             	movsbl %al,%eax
 537:	25 ff 00 00 00       	and    $0xff,%eax
 53c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 53f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 543:	75 2c                	jne    571 <printf+0x6a>
      if(c == '%'){
 545:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 549:	75 0c                	jne    557 <printf+0x50>
        state = '%';
 54b:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 552:	e9 4b 01 00 00       	jmp    6a2 <printf+0x19b>
      } else {
        putc(fd, c);
 557:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 55a:	0f be c0             	movsbl %al,%eax
 55d:	89 44 24 04          	mov    %eax,0x4(%esp)
 561:	8b 45 08             	mov    0x8(%ebp),%eax
 564:	89 04 24             	mov    %eax,(%esp)
 567:	e8 c4 fe ff ff       	call   430 <putc>
 56c:	e9 31 01 00 00       	jmp    6a2 <printf+0x19b>
      }
    } else if(state == '%'){
 571:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 575:	0f 85 27 01 00 00    	jne    6a2 <printf+0x19b>
      if(c == 'd'){
 57b:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 57f:	75 2d                	jne    5ae <printf+0xa7>
        printint(fd, *ap, 10, 1);
 581:	8b 45 e8             	mov    -0x18(%ebp),%eax
 584:	8b 00                	mov    (%eax),%eax
 586:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 58d:	00 
 58e:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 595:	00 
 596:	89 44 24 04          	mov    %eax,0x4(%esp)
 59a:	8b 45 08             	mov    0x8(%ebp),%eax
 59d:	89 04 24             	mov    %eax,(%esp)
 5a0:	e8 b3 fe ff ff       	call   458 <printint>
        ap++;
 5a5:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 5a9:	e9 ed 00 00 00       	jmp    69b <printf+0x194>
      } else if(c == 'x' || c == 'p'){
 5ae:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 5b2:	74 06                	je     5ba <printf+0xb3>
 5b4:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 5b8:	75 2d                	jne    5e7 <printf+0xe0>
        printint(fd, *ap, 16, 0);
 5ba:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5bd:	8b 00                	mov    (%eax),%eax
 5bf:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 5c6:	00 
 5c7:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 5ce:	00 
 5cf:	89 44 24 04          	mov    %eax,0x4(%esp)
 5d3:	8b 45 08             	mov    0x8(%ebp),%eax
 5d6:	89 04 24             	mov    %eax,(%esp)
 5d9:	e8 7a fe ff ff       	call   458 <printint>
        ap++;
 5de:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 5e2:	e9 b4 00 00 00       	jmp    69b <printf+0x194>
      } else if(c == 's'){
 5e7:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 5eb:	75 46                	jne    633 <printf+0x12c>
        s = (char*)*ap;
 5ed:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5f0:	8b 00                	mov    (%eax),%eax
 5f2:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 5f5:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 5f9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 5fd:	75 27                	jne    626 <printf+0x11f>
          s = "(null)";
 5ff:	c7 45 f4 f1 08 00 00 	movl   $0x8f1,-0xc(%ebp)
        while(*s != 0){
 606:	eb 1e                	jmp    626 <printf+0x11f>
          putc(fd, *s);
 608:	8b 45 f4             	mov    -0xc(%ebp),%eax
 60b:	0f b6 00             	movzbl (%eax),%eax
 60e:	0f be c0             	movsbl %al,%eax
 611:	89 44 24 04          	mov    %eax,0x4(%esp)
 615:	8b 45 08             	mov    0x8(%ebp),%eax
 618:	89 04 24             	mov    %eax,(%esp)
 61b:	e8 10 fe ff ff       	call   430 <putc>
          s++;
 620:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 624:	eb 01                	jmp    627 <printf+0x120>
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 626:	90                   	nop
 627:	8b 45 f4             	mov    -0xc(%ebp),%eax
 62a:	0f b6 00             	movzbl (%eax),%eax
 62d:	84 c0                	test   %al,%al
 62f:	75 d7                	jne    608 <printf+0x101>
 631:	eb 68                	jmp    69b <printf+0x194>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 633:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 637:	75 1d                	jne    656 <printf+0x14f>
        putc(fd, *ap);
 639:	8b 45 e8             	mov    -0x18(%ebp),%eax
 63c:	8b 00                	mov    (%eax),%eax
 63e:	0f be c0             	movsbl %al,%eax
 641:	89 44 24 04          	mov    %eax,0x4(%esp)
 645:	8b 45 08             	mov    0x8(%ebp),%eax
 648:	89 04 24             	mov    %eax,(%esp)
 64b:	e8 e0 fd ff ff       	call   430 <putc>
        ap++;
 650:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 654:	eb 45                	jmp    69b <printf+0x194>
      } else if(c == '%'){
 656:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 65a:	75 17                	jne    673 <printf+0x16c>
        putc(fd, c);
 65c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 65f:	0f be c0             	movsbl %al,%eax
 662:	89 44 24 04          	mov    %eax,0x4(%esp)
 666:	8b 45 08             	mov    0x8(%ebp),%eax
 669:	89 04 24             	mov    %eax,(%esp)
 66c:	e8 bf fd ff ff       	call   430 <putc>
 671:	eb 28                	jmp    69b <printf+0x194>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 673:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 67a:	00 
 67b:	8b 45 08             	mov    0x8(%ebp),%eax
 67e:	89 04 24             	mov    %eax,(%esp)
 681:	e8 aa fd ff ff       	call   430 <putc>
        putc(fd, c);
 686:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 689:	0f be c0             	movsbl %al,%eax
 68c:	89 44 24 04          	mov    %eax,0x4(%esp)
 690:	8b 45 08             	mov    0x8(%ebp),%eax
 693:	89 04 24             	mov    %eax,(%esp)
 696:	e8 95 fd ff ff       	call   430 <putc>
      }
      state = 0;
 69b:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 6a2:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 6a6:	8b 55 0c             	mov    0xc(%ebp),%edx
 6a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6ac:	01 d0                	add    %edx,%eax
 6ae:	0f b6 00             	movzbl (%eax),%eax
 6b1:	84 c0                	test   %al,%al
 6b3:	0f 85 70 fe ff ff    	jne    529 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 6b9:	c9                   	leave  
 6ba:	c3                   	ret    
 6bb:	90                   	nop

000006bc <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 6bc:	55                   	push   %ebp
 6bd:	89 e5                	mov    %esp,%ebp
 6bf:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 6c2:	8b 45 08             	mov    0x8(%ebp),%eax
 6c5:	83 e8 08             	sub    $0x8,%eax
 6c8:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6cb:	a1 88 0b 00 00       	mov    0xb88,%eax
 6d0:	89 45 fc             	mov    %eax,-0x4(%ebp)
 6d3:	eb 24                	jmp    6f9 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6d5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6d8:	8b 00                	mov    (%eax),%eax
 6da:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 6dd:	77 12                	ja     6f1 <free+0x35>
 6df:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6e2:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 6e5:	77 24                	ja     70b <free+0x4f>
 6e7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6ea:	8b 00                	mov    (%eax),%eax
 6ec:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 6ef:	77 1a                	ja     70b <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6f1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6f4:	8b 00                	mov    (%eax),%eax
 6f6:	89 45 fc             	mov    %eax,-0x4(%ebp)
 6f9:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6fc:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 6ff:	76 d4                	jbe    6d5 <free+0x19>
 701:	8b 45 fc             	mov    -0x4(%ebp),%eax
 704:	8b 00                	mov    (%eax),%eax
 706:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 709:	76 ca                	jbe    6d5 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 70b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 70e:	8b 40 04             	mov    0x4(%eax),%eax
 711:	c1 e0 03             	shl    $0x3,%eax
 714:	89 c2                	mov    %eax,%edx
 716:	03 55 f8             	add    -0x8(%ebp),%edx
 719:	8b 45 fc             	mov    -0x4(%ebp),%eax
 71c:	8b 00                	mov    (%eax),%eax
 71e:	39 c2                	cmp    %eax,%edx
 720:	75 24                	jne    746 <free+0x8a>
    bp->s.size += p->s.ptr->s.size;
 722:	8b 45 f8             	mov    -0x8(%ebp),%eax
 725:	8b 50 04             	mov    0x4(%eax),%edx
 728:	8b 45 fc             	mov    -0x4(%ebp),%eax
 72b:	8b 00                	mov    (%eax),%eax
 72d:	8b 40 04             	mov    0x4(%eax),%eax
 730:	01 c2                	add    %eax,%edx
 732:	8b 45 f8             	mov    -0x8(%ebp),%eax
 735:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 738:	8b 45 fc             	mov    -0x4(%ebp),%eax
 73b:	8b 00                	mov    (%eax),%eax
 73d:	8b 10                	mov    (%eax),%edx
 73f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 742:	89 10                	mov    %edx,(%eax)
 744:	eb 0a                	jmp    750 <free+0x94>
  } else
    bp->s.ptr = p->s.ptr;
 746:	8b 45 fc             	mov    -0x4(%ebp),%eax
 749:	8b 10                	mov    (%eax),%edx
 74b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 74e:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 750:	8b 45 fc             	mov    -0x4(%ebp),%eax
 753:	8b 40 04             	mov    0x4(%eax),%eax
 756:	c1 e0 03             	shl    $0x3,%eax
 759:	03 45 fc             	add    -0x4(%ebp),%eax
 75c:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 75f:	75 20                	jne    781 <free+0xc5>
    p->s.size += bp->s.size;
 761:	8b 45 fc             	mov    -0x4(%ebp),%eax
 764:	8b 50 04             	mov    0x4(%eax),%edx
 767:	8b 45 f8             	mov    -0x8(%ebp),%eax
 76a:	8b 40 04             	mov    0x4(%eax),%eax
 76d:	01 c2                	add    %eax,%edx
 76f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 772:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 775:	8b 45 f8             	mov    -0x8(%ebp),%eax
 778:	8b 10                	mov    (%eax),%edx
 77a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 77d:	89 10                	mov    %edx,(%eax)
 77f:	eb 08                	jmp    789 <free+0xcd>
  } else
    p->s.ptr = bp;
 781:	8b 45 fc             	mov    -0x4(%ebp),%eax
 784:	8b 55 f8             	mov    -0x8(%ebp),%edx
 787:	89 10                	mov    %edx,(%eax)
  freep = p;
 789:	8b 45 fc             	mov    -0x4(%ebp),%eax
 78c:	a3 88 0b 00 00       	mov    %eax,0xb88
}
 791:	c9                   	leave  
 792:	c3                   	ret    

00000793 <morecore>:

static Header*
morecore(uint nu)
{
 793:	55                   	push   %ebp
 794:	89 e5                	mov    %esp,%ebp
 796:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 799:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 7a0:	77 07                	ja     7a9 <morecore+0x16>
    nu = 4096;
 7a2:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 7a9:	8b 45 08             	mov    0x8(%ebp),%eax
 7ac:	c1 e0 03             	shl    $0x3,%eax
 7af:	89 04 24             	mov    %eax,(%esp)
 7b2:	e8 61 fc ff ff       	call   418 <sbrk>
 7b7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 7ba:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 7be:	75 07                	jne    7c7 <morecore+0x34>
    return 0;
 7c0:	b8 00 00 00 00       	mov    $0x0,%eax
 7c5:	eb 22                	jmp    7e9 <morecore+0x56>
  hp = (Header*)p;
 7c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7ca:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 7cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7d0:	8b 55 08             	mov    0x8(%ebp),%edx
 7d3:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 7d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7d9:	83 c0 08             	add    $0x8,%eax
 7dc:	89 04 24             	mov    %eax,(%esp)
 7df:	e8 d8 fe ff ff       	call   6bc <free>
  return freep;
 7e4:	a1 88 0b 00 00       	mov    0xb88,%eax
}
 7e9:	c9                   	leave  
 7ea:	c3                   	ret    

000007eb <malloc>:

void*
malloc(uint nbytes)
{
 7eb:	55                   	push   %ebp
 7ec:	89 e5                	mov    %esp,%ebp
 7ee:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 7f1:	8b 45 08             	mov    0x8(%ebp),%eax
 7f4:	83 c0 07             	add    $0x7,%eax
 7f7:	c1 e8 03             	shr    $0x3,%eax
 7fa:	83 c0 01             	add    $0x1,%eax
 7fd:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 800:	a1 88 0b 00 00       	mov    0xb88,%eax
 805:	89 45 f0             	mov    %eax,-0x10(%ebp)
 808:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 80c:	75 23                	jne    831 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 80e:	c7 45 f0 80 0b 00 00 	movl   $0xb80,-0x10(%ebp)
 815:	8b 45 f0             	mov    -0x10(%ebp),%eax
 818:	a3 88 0b 00 00       	mov    %eax,0xb88
 81d:	a1 88 0b 00 00       	mov    0xb88,%eax
 822:	a3 80 0b 00 00       	mov    %eax,0xb80
    base.s.size = 0;
 827:	c7 05 84 0b 00 00 00 	movl   $0x0,0xb84
 82e:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 831:	8b 45 f0             	mov    -0x10(%ebp),%eax
 834:	8b 00                	mov    (%eax),%eax
 836:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 839:	8b 45 f4             	mov    -0xc(%ebp),%eax
 83c:	8b 40 04             	mov    0x4(%eax),%eax
 83f:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 842:	72 4d                	jb     891 <malloc+0xa6>
      if(p->s.size == nunits)
 844:	8b 45 f4             	mov    -0xc(%ebp),%eax
 847:	8b 40 04             	mov    0x4(%eax),%eax
 84a:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 84d:	75 0c                	jne    85b <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 84f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 852:	8b 10                	mov    (%eax),%edx
 854:	8b 45 f0             	mov    -0x10(%ebp),%eax
 857:	89 10                	mov    %edx,(%eax)
 859:	eb 26                	jmp    881 <malloc+0x96>
      else {
        p->s.size -= nunits;
 85b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 85e:	8b 40 04             	mov    0x4(%eax),%eax
 861:	89 c2                	mov    %eax,%edx
 863:	2b 55 ec             	sub    -0x14(%ebp),%edx
 866:	8b 45 f4             	mov    -0xc(%ebp),%eax
 869:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 86c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 86f:	8b 40 04             	mov    0x4(%eax),%eax
 872:	c1 e0 03             	shl    $0x3,%eax
 875:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 878:	8b 45 f4             	mov    -0xc(%ebp),%eax
 87b:	8b 55 ec             	mov    -0x14(%ebp),%edx
 87e:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 881:	8b 45 f0             	mov    -0x10(%ebp),%eax
 884:	a3 88 0b 00 00       	mov    %eax,0xb88
      return (void*)(p + 1);
 889:	8b 45 f4             	mov    -0xc(%ebp),%eax
 88c:	83 c0 08             	add    $0x8,%eax
 88f:	eb 38                	jmp    8c9 <malloc+0xde>
    }
    if(p == freep)
 891:	a1 88 0b 00 00       	mov    0xb88,%eax
 896:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 899:	75 1b                	jne    8b6 <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 89b:	8b 45 ec             	mov    -0x14(%ebp),%eax
 89e:	89 04 24             	mov    %eax,(%esp)
 8a1:	e8 ed fe ff ff       	call   793 <morecore>
 8a6:	89 45 f4             	mov    %eax,-0xc(%ebp)
 8a9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 8ad:	75 07                	jne    8b6 <malloc+0xcb>
        return 0;
 8af:	b8 00 00 00 00       	mov    $0x0,%eax
 8b4:	eb 13                	jmp    8c9 <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8b9:	89 45 f0             	mov    %eax,-0x10(%ebp)
 8bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8bf:	8b 00                	mov    (%eax),%eax
 8c1:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 8c4:	e9 70 ff ff ff       	jmp    839 <malloc+0x4e>
}
 8c9:	c9                   	leave  
 8ca:	c3                   	ret    
