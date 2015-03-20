
_wc:     file format elf32-i386


Disassembly of section .text:

00000000 <wc>:

char buf[512];

void
wc(int fd, char *name)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 ec 48             	sub    $0x48,%esp
  int i, n;
  int l, w, c, inword;

  l = w = c = 0;
   6:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
   d:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10:	89 45 ec             	mov    %eax,-0x14(%ebp)
  13:	8b 45 ec             	mov    -0x14(%ebp),%eax
  16:	89 45 f0             	mov    %eax,-0x10(%ebp)
  inword = 0;
  19:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  while((n = read(fd, buf, sizeof(buf))) > 0){
  20:	eb 68                	jmp    8a <wc+0x8a>
    for(i=0; i<n; i++){
  22:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  29:	eb 57                	jmp    82 <wc+0x82>
      c++;
  2b:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
      if(buf[i] == '\n')
  2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  32:	05 60 0c 00 00       	add    $0xc60,%eax
  37:	0f b6 00             	movzbl (%eax),%eax
  3a:	3c 0a                	cmp    $0xa,%al
  3c:	75 04                	jne    42 <wc+0x42>
        l++;
  3e:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
      if(strchr(" \r\t\n\v", buf[i]))
  42:	8b 45 f4             	mov    -0xc(%ebp),%eax
  45:	05 60 0c 00 00       	add    $0xc60,%eax
  4a:	0f b6 00             	movzbl (%eax),%eax
  4d:	0f be c0             	movsbl %al,%eax
  50:	89 44 24 04          	mov    %eax,0x4(%esp)
  54:	c7 04 24 83 09 00 00 	movl   $0x983,(%esp)
  5b:	e8 67 02 00 00       	call   2c7 <strchr>
  60:	85 c0                	test   %eax,%eax
  62:	74 09                	je     6d <wc+0x6d>
        inword = 0;
  64:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  6b:	eb 11                	jmp    7e <wc+0x7e>
      else if(!inword){
  6d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  71:	75 0b                	jne    7e <wc+0x7e>
        w++;
  73:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
        inword = 1;
  77:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
  int l, w, c, inword;

  l = w = c = 0;
  inword = 0;
  while((n = read(fd, buf, sizeof(buf))) > 0){
    for(i=0; i<n; i++){
  7e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  82:	8b 45 f4             	mov    -0xc(%ebp),%eax
  85:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  88:	7c a1                	jl     2b <wc+0x2b>
  int i, n;
  int l, w, c, inword;

  l = w = c = 0;
  inword = 0;
  while((n = read(fd, buf, sizeof(buf))) > 0){
  8a:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  91:	00 
  92:	c7 44 24 04 60 0c 00 	movl   $0xc60,0x4(%esp)
  99:	00 
  9a:	8b 45 08             	mov    0x8(%ebp),%eax
  9d:	89 04 24             	mov    %eax,(%esp)
  a0:	e8 bb 03 00 00       	call   460 <read>
  a5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  a8:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  ac:	0f 8f 70 ff ff ff    	jg     22 <wc+0x22>
        w++;
        inword = 1;
      }
    }
  }
  if(n < 0){
  b2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  b6:	79 20                	jns    d8 <wc+0xd8>
    printf(1, "wc: read error\n");
  b8:	c7 44 24 04 89 09 00 	movl   $0x989,0x4(%esp)
  bf:	00 
  c0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  c7:	e8 f3 04 00 00       	call   5bf <printf>
    exit(EXIT_STATUS_DEFAULT);
  cc:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  d3:	e8 70 03 00 00       	call   448 <exit>
  }
  printf(1, "%d %d %d %s\n", l, w, c, name);
  d8:	8b 45 0c             	mov    0xc(%ebp),%eax
  db:	89 44 24 14          	mov    %eax,0x14(%esp)
  df:	8b 45 e8             	mov    -0x18(%ebp),%eax
  e2:	89 44 24 10          	mov    %eax,0x10(%esp)
  e6:	8b 45 ec             	mov    -0x14(%ebp),%eax
  e9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
  f0:	89 44 24 08          	mov    %eax,0x8(%esp)
  f4:	c7 44 24 04 99 09 00 	movl   $0x999,0x4(%esp)
  fb:	00 
  fc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 103:	e8 b7 04 00 00       	call   5bf <printf>
}
 108:	c9                   	leave  
 109:	c3                   	ret    

0000010a <main>:

int
main(int argc, char *argv[])
{
 10a:	55                   	push   %ebp
 10b:	89 e5                	mov    %esp,%ebp
 10d:	83 e4 f0             	and    $0xfffffff0,%esp
 110:	83 ec 20             	sub    $0x20,%esp
  int fd, i;

  if(argc <= 1){
 113:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
 117:	7f 20                	jg     139 <main+0x2f>
    wc(0, "");
 119:	c7 44 24 04 a6 09 00 	movl   $0x9a6,0x4(%esp)
 120:	00 
 121:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 128:	e8 d3 fe ff ff       	call   0 <wc>
    exit(EXIT_STATUS_DEFAULT);
 12d:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
 134:	e8 0f 03 00 00       	call   448 <exit>
  }

  for(i = 1; i < argc; i++){
 139:	c7 44 24 1c 01 00 00 	movl   $0x1,0x1c(%esp)
 140:	00 
 141:	e9 84 00 00 00       	jmp    1ca <main+0xc0>
    if((fd = open(argv[i], 0)) < 0){
 146:	8b 44 24 1c          	mov    0x1c(%esp),%eax
 14a:	c1 e0 02             	shl    $0x2,%eax
 14d:	03 45 0c             	add    0xc(%ebp),%eax
 150:	8b 00                	mov    (%eax),%eax
 152:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 159:	00 
 15a:	89 04 24             	mov    %eax,(%esp)
 15d:	e8 26 03 00 00       	call   488 <open>
 162:	89 44 24 18          	mov    %eax,0x18(%esp)
 166:	83 7c 24 18 00       	cmpl   $0x0,0x18(%esp)
 16b:	79 30                	jns    19d <main+0x93>
      printf(1, "wc: cannot open %s\n", argv[i]);
 16d:	8b 44 24 1c          	mov    0x1c(%esp),%eax
 171:	c1 e0 02             	shl    $0x2,%eax
 174:	03 45 0c             	add    0xc(%ebp),%eax
 177:	8b 00                	mov    (%eax),%eax
 179:	89 44 24 08          	mov    %eax,0x8(%esp)
 17d:	c7 44 24 04 a7 09 00 	movl   $0x9a7,0x4(%esp)
 184:	00 
 185:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 18c:	e8 2e 04 00 00       	call   5bf <printf>
      exit(EXIT_STATUS_DEFAULT);
 191:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
 198:	e8 ab 02 00 00       	call   448 <exit>
    }
    wc(fd, argv[i]);
 19d:	8b 44 24 1c          	mov    0x1c(%esp),%eax
 1a1:	c1 e0 02             	shl    $0x2,%eax
 1a4:	03 45 0c             	add    0xc(%ebp),%eax
 1a7:	8b 00                	mov    (%eax),%eax
 1a9:	89 44 24 04          	mov    %eax,0x4(%esp)
 1ad:	8b 44 24 18          	mov    0x18(%esp),%eax
 1b1:	89 04 24             	mov    %eax,(%esp)
 1b4:	e8 47 fe ff ff       	call   0 <wc>
    close(fd);
 1b9:	8b 44 24 18          	mov    0x18(%esp),%eax
 1bd:	89 04 24             	mov    %eax,(%esp)
 1c0:	e8 ab 02 00 00       	call   470 <close>
  if(argc <= 1){
    wc(0, "");
    exit(EXIT_STATUS_DEFAULT);
  }

  for(i = 1; i < argc; i++){
 1c5:	83 44 24 1c 01       	addl   $0x1,0x1c(%esp)
 1ca:	8b 44 24 1c          	mov    0x1c(%esp),%eax
 1ce:	3b 45 08             	cmp    0x8(%ebp),%eax
 1d1:	0f 8c 6f ff ff ff    	jl     146 <main+0x3c>
      exit(EXIT_STATUS_DEFAULT);
    }
    wc(fd, argv[i]);
    close(fd);
  }
  exit(EXIT_STATUS_DEFAULT);
 1d7:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
 1de:	e8 65 02 00 00       	call   448 <exit>
 1e3:	90                   	nop

000001e4 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 1e4:	55                   	push   %ebp
 1e5:	89 e5                	mov    %esp,%ebp
 1e7:	57                   	push   %edi
 1e8:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 1e9:	8b 4d 08             	mov    0x8(%ebp),%ecx
 1ec:	8b 55 10             	mov    0x10(%ebp),%edx
 1ef:	8b 45 0c             	mov    0xc(%ebp),%eax
 1f2:	89 cb                	mov    %ecx,%ebx
 1f4:	89 df                	mov    %ebx,%edi
 1f6:	89 d1                	mov    %edx,%ecx
 1f8:	fc                   	cld    
 1f9:	f3 aa                	rep stos %al,%es:(%edi)
 1fb:	89 ca                	mov    %ecx,%edx
 1fd:	89 fb                	mov    %edi,%ebx
 1ff:	89 5d 08             	mov    %ebx,0x8(%ebp)
 202:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 205:	5b                   	pop    %ebx
 206:	5f                   	pop    %edi
 207:	5d                   	pop    %ebp
 208:	c3                   	ret    

00000209 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 209:	55                   	push   %ebp
 20a:	89 e5                	mov    %esp,%ebp
 20c:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 20f:	8b 45 08             	mov    0x8(%ebp),%eax
 212:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 215:	90                   	nop
 216:	8b 45 0c             	mov    0xc(%ebp),%eax
 219:	0f b6 10             	movzbl (%eax),%edx
 21c:	8b 45 08             	mov    0x8(%ebp),%eax
 21f:	88 10                	mov    %dl,(%eax)
 221:	8b 45 08             	mov    0x8(%ebp),%eax
 224:	0f b6 00             	movzbl (%eax),%eax
 227:	84 c0                	test   %al,%al
 229:	0f 95 c0             	setne  %al
 22c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 230:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 234:	84 c0                	test   %al,%al
 236:	75 de                	jne    216 <strcpy+0xd>
    ;
  return os;
 238:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 23b:	c9                   	leave  
 23c:	c3                   	ret    

0000023d <strcmp>:

int
strcmp(const char *p, const char *q)
{
 23d:	55                   	push   %ebp
 23e:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 240:	eb 08                	jmp    24a <strcmp+0xd>
    p++, q++;
 242:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 246:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 24a:	8b 45 08             	mov    0x8(%ebp),%eax
 24d:	0f b6 00             	movzbl (%eax),%eax
 250:	84 c0                	test   %al,%al
 252:	74 10                	je     264 <strcmp+0x27>
 254:	8b 45 08             	mov    0x8(%ebp),%eax
 257:	0f b6 10             	movzbl (%eax),%edx
 25a:	8b 45 0c             	mov    0xc(%ebp),%eax
 25d:	0f b6 00             	movzbl (%eax),%eax
 260:	38 c2                	cmp    %al,%dl
 262:	74 de                	je     242 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 264:	8b 45 08             	mov    0x8(%ebp),%eax
 267:	0f b6 00             	movzbl (%eax),%eax
 26a:	0f b6 d0             	movzbl %al,%edx
 26d:	8b 45 0c             	mov    0xc(%ebp),%eax
 270:	0f b6 00             	movzbl (%eax),%eax
 273:	0f b6 c0             	movzbl %al,%eax
 276:	89 d1                	mov    %edx,%ecx
 278:	29 c1                	sub    %eax,%ecx
 27a:	89 c8                	mov    %ecx,%eax
}
 27c:	5d                   	pop    %ebp
 27d:	c3                   	ret    

0000027e <strlen>:

uint
strlen(char *s)
{
 27e:	55                   	push   %ebp
 27f:	89 e5                	mov    %esp,%ebp
 281:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 284:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 28b:	eb 04                	jmp    291 <strlen+0x13>
 28d:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 291:	8b 45 fc             	mov    -0x4(%ebp),%eax
 294:	03 45 08             	add    0x8(%ebp),%eax
 297:	0f b6 00             	movzbl (%eax),%eax
 29a:	84 c0                	test   %al,%al
 29c:	75 ef                	jne    28d <strlen+0xf>
    ;
  return n;
 29e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 2a1:	c9                   	leave  
 2a2:	c3                   	ret    

000002a3 <memset>:

void*
memset(void *dst, int c, uint n)
{
 2a3:	55                   	push   %ebp
 2a4:	89 e5                	mov    %esp,%ebp
 2a6:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 2a9:	8b 45 10             	mov    0x10(%ebp),%eax
 2ac:	89 44 24 08          	mov    %eax,0x8(%esp)
 2b0:	8b 45 0c             	mov    0xc(%ebp),%eax
 2b3:	89 44 24 04          	mov    %eax,0x4(%esp)
 2b7:	8b 45 08             	mov    0x8(%ebp),%eax
 2ba:	89 04 24             	mov    %eax,(%esp)
 2bd:	e8 22 ff ff ff       	call   1e4 <stosb>
  return dst;
 2c2:	8b 45 08             	mov    0x8(%ebp),%eax
}
 2c5:	c9                   	leave  
 2c6:	c3                   	ret    

000002c7 <strchr>:

char*
strchr(const char *s, char c)
{
 2c7:	55                   	push   %ebp
 2c8:	89 e5                	mov    %esp,%ebp
 2ca:	83 ec 04             	sub    $0x4,%esp
 2cd:	8b 45 0c             	mov    0xc(%ebp),%eax
 2d0:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 2d3:	eb 14                	jmp    2e9 <strchr+0x22>
    if(*s == c)
 2d5:	8b 45 08             	mov    0x8(%ebp),%eax
 2d8:	0f b6 00             	movzbl (%eax),%eax
 2db:	3a 45 fc             	cmp    -0x4(%ebp),%al
 2de:	75 05                	jne    2e5 <strchr+0x1e>
      return (char*)s;
 2e0:	8b 45 08             	mov    0x8(%ebp),%eax
 2e3:	eb 13                	jmp    2f8 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 2e5:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 2e9:	8b 45 08             	mov    0x8(%ebp),%eax
 2ec:	0f b6 00             	movzbl (%eax),%eax
 2ef:	84 c0                	test   %al,%al
 2f1:	75 e2                	jne    2d5 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 2f3:	b8 00 00 00 00       	mov    $0x0,%eax
}
 2f8:	c9                   	leave  
 2f9:	c3                   	ret    

000002fa <gets>:

char*
gets(char *buf, int max)
{
 2fa:	55                   	push   %ebp
 2fb:	89 e5                	mov    %esp,%ebp
 2fd:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 300:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 307:	eb 44                	jmp    34d <gets+0x53>
    cc = read(0, &c, 1);
 309:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 310:	00 
 311:	8d 45 ef             	lea    -0x11(%ebp),%eax
 314:	89 44 24 04          	mov    %eax,0x4(%esp)
 318:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 31f:	e8 3c 01 00 00       	call   460 <read>
 324:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 327:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 32b:	7e 2d                	jle    35a <gets+0x60>
      break;
    buf[i++] = c;
 32d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 330:	03 45 08             	add    0x8(%ebp),%eax
 333:	0f b6 55 ef          	movzbl -0x11(%ebp),%edx
 337:	88 10                	mov    %dl,(%eax)
 339:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(c == '\n' || c == '\r')
 33d:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 341:	3c 0a                	cmp    $0xa,%al
 343:	74 16                	je     35b <gets+0x61>
 345:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 349:	3c 0d                	cmp    $0xd,%al
 34b:	74 0e                	je     35b <gets+0x61>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 34d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 350:	83 c0 01             	add    $0x1,%eax
 353:	3b 45 0c             	cmp    0xc(%ebp),%eax
 356:	7c b1                	jl     309 <gets+0xf>
 358:	eb 01                	jmp    35b <gets+0x61>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 35a:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 35b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 35e:	03 45 08             	add    0x8(%ebp),%eax
 361:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 364:	8b 45 08             	mov    0x8(%ebp),%eax
}
 367:	c9                   	leave  
 368:	c3                   	ret    

00000369 <stat>:

int
stat(char *n, struct stat *st)
{
 369:	55                   	push   %ebp
 36a:	89 e5                	mov    %esp,%ebp
 36c:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 36f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 376:	00 
 377:	8b 45 08             	mov    0x8(%ebp),%eax
 37a:	89 04 24             	mov    %eax,(%esp)
 37d:	e8 06 01 00 00       	call   488 <open>
 382:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 385:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 389:	79 07                	jns    392 <stat+0x29>
    return -1;
 38b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 390:	eb 23                	jmp    3b5 <stat+0x4c>
  r = fstat(fd, st);
 392:	8b 45 0c             	mov    0xc(%ebp),%eax
 395:	89 44 24 04          	mov    %eax,0x4(%esp)
 399:	8b 45 f4             	mov    -0xc(%ebp),%eax
 39c:	89 04 24             	mov    %eax,(%esp)
 39f:	e8 fc 00 00 00       	call   4a0 <fstat>
 3a4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 3a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3aa:	89 04 24             	mov    %eax,(%esp)
 3ad:	e8 be 00 00 00       	call   470 <close>
  return r;
 3b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 3b5:	c9                   	leave  
 3b6:	c3                   	ret    

000003b7 <atoi>:

int
atoi(const char *s)
{
 3b7:	55                   	push   %ebp
 3b8:	89 e5                	mov    %esp,%ebp
 3ba:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 3bd:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 3c4:	eb 23                	jmp    3e9 <atoi+0x32>
    n = n*10 + *s++ - '0';
 3c6:	8b 55 fc             	mov    -0x4(%ebp),%edx
 3c9:	89 d0                	mov    %edx,%eax
 3cb:	c1 e0 02             	shl    $0x2,%eax
 3ce:	01 d0                	add    %edx,%eax
 3d0:	01 c0                	add    %eax,%eax
 3d2:	89 c2                	mov    %eax,%edx
 3d4:	8b 45 08             	mov    0x8(%ebp),%eax
 3d7:	0f b6 00             	movzbl (%eax),%eax
 3da:	0f be c0             	movsbl %al,%eax
 3dd:	01 d0                	add    %edx,%eax
 3df:	83 e8 30             	sub    $0x30,%eax
 3e2:	89 45 fc             	mov    %eax,-0x4(%ebp)
 3e5:	83 45 08 01          	addl   $0x1,0x8(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 3e9:	8b 45 08             	mov    0x8(%ebp),%eax
 3ec:	0f b6 00             	movzbl (%eax),%eax
 3ef:	3c 2f                	cmp    $0x2f,%al
 3f1:	7e 0a                	jle    3fd <atoi+0x46>
 3f3:	8b 45 08             	mov    0x8(%ebp),%eax
 3f6:	0f b6 00             	movzbl (%eax),%eax
 3f9:	3c 39                	cmp    $0x39,%al
 3fb:	7e c9                	jle    3c6 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 3fd:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 400:	c9                   	leave  
 401:	c3                   	ret    

00000402 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 402:	55                   	push   %ebp
 403:	89 e5                	mov    %esp,%ebp
 405:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 408:	8b 45 08             	mov    0x8(%ebp),%eax
 40b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 40e:	8b 45 0c             	mov    0xc(%ebp),%eax
 411:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 414:	eb 13                	jmp    429 <memmove+0x27>
    *dst++ = *src++;
 416:	8b 45 f8             	mov    -0x8(%ebp),%eax
 419:	0f b6 10             	movzbl (%eax),%edx
 41c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 41f:	88 10                	mov    %dl,(%eax)
 421:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 425:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 429:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 42d:	0f 9f c0             	setg   %al
 430:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 434:	84 c0                	test   %al,%al
 436:	75 de                	jne    416 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 438:	8b 45 08             	mov    0x8(%ebp),%eax
}
 43b:	c9                   	leave  
 43c:	c3                   	ret    
 43d:	90                   	nop
 43e:	90                   	nop
 43f:	90                   	nop

00000440 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 440:	b8 01 00 00 00       	mov    $0x1,%eax
 445:	cd 40                	int    $0x40
 447:	c3                   	ret    

00000448 <exit>:
SYSCALL(exit)
 448:	b8 02 00 00 00       	mov    $0x2,%eax
 44d:	cd 40                	int    $0x40
 44f:	c3                   	ret    

00000450 <wait>:
SYSCALL(wait)
 450:	b8 03 00 00 00       	mov    $0x3,%eax
 455:	cd 40                	int    $0x40
 457:	c3                   	ret    

00000458 <pipe>:
SYSCALL(pipe)
 458:	b8 04 00 00 00       	mov    $0x4,%eax
 45d:	cd 40                	int    $0x40
 45f:	c3                   	ret    

00000460 <read>:
SYSCALL(read)
 460:	b8 05 00 00 00       	mov    $0x5,%eax
 465:	cd 40                	int    $0x40
 467:	c3                   	ret    

00000468 <write>:
SYSCALL(write)
 468:	b8 10 00 00 00       	mov    $0x10,%eax
 46d:	cd 40                	int    $0x40
 46f:	c3                   	ret    

00000470 <close>:
SYSCALL(close)
 470:	b8 15 00 00 00       	mov    $0x15,%eax
 475:	cd 40                	int    $0x40
 477:	c3                   	ret    

00000478 <kill>:
SYSCALL(kill)
 478:	b8 06 00 00 00       	mov    $0x6,%eax
 47d:	cd 40                	int    $0x40
 47f:	c3                   	ret    

00000480 <exec>:
SYSCALL(exec)
 480:	b8 07 00 00 00       	mov    $0x7,%eax
 485:	cd 40                	int    $0x40
 487:	c3                   	ret    

00000488 <open>:
SYSCALL(open)
 488:	b8 0f 00 00 00       	mov    $0xf,%eax
 48d:	cd 40                	int    $0x40
 48f:	c3                   	ret    

00000490 <mknod>:
SYSCALL(mknod)
 490:	b8 11 00 00 00       	mov    $0x11,%eax
 495:	cd 40                	int    $0x40
 497:	c3                   	ret    

00000498 <unlink>:
SYSCALL(unlink)
 498:	b8 12 00 00 00       	mov    $0x12,%eax
 49d:	cd 40                	int    $0x40
 49f:	c3                   	ret    

000004a0 <fstat>:
SYSCALL(fstat)
 4a0:	b8 08 00 00 00       	mov    $0x8,%eax
 4a5:	cd 40                	int    $0x40
 4a7:	c3                   	ret    

000004a8 <link>:
SYSCALL(link)
 4a8:	b8 13 00 00 00       	mov    $0x13,%eax
 4ad:	cd 40                	int    $0x40
 4af:	c3                   	ret    

000004b0 <mkdir>:
SYSCALL(mkdir)
 4b0:	b8 14 00 00 00       	mov    $0x14,%eax
 4b5:	cd 40                	int    $0x40
 4b7:	c3                   	ret    

000004b8 <chdir>:
SYSCALL(chdir)
 4b8:	b8 09 00 00 00       	mov    $0x9,%eax
 4bd:	cd 40                	int    $0x40
 4bf:	c3                   	ret    

000004c0 <dup>:
SYSCALL(dup)
 4c0:	b8 0a 00 00 00       	mov    $0xa,%eax
 4c5:	cd 40                	int    $0x40
 4c7:	c3                   	ret    

000004c8 <getpid>:
SYSCALL(getpid)
 4c8:	b8 0b 00 00 00       	mov    $0xb,%eax
 4cd:	cd 40                	int    $0x40
 4cf:	c3                   	ret    

000004d0 <sbrk>:
SYSCALL(sbrk)
 4d0:	b8 0c 00 00 00       	mov    $0xc,%eax
 4d5:	cd 40                	int    $0x40
 4d7:	c3                   	ret    

000004d8 <sleep>:
SYSCALL(sleep)
 4d8:	b8 0d 00 00 00       	mov    $0xd,%eax
 4dd:	cd 40                	int    $0x40
 4df:	c3                   	ret    

000004e0 <uptime>:
SYSCALL(uptime)
 4e0:	b8 0e 00 00 00       	mov    $0xe,%eax
 4e5:	cd 40                	int    $0x40
 4e7:	c3                   	ret    

000004e8 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 4e8:	55                   	push   %ebp
 4e9:	89 e5                	mov    %esp,%ebp
 4eb:	83 ec 28             	sub    $0x28,%esp
 4ee:	8b 45 0c             	mov    0xc(%ebp),%eax
 4f1:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 4f4:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 4fb:	00 
 4fc:	8d 45 f4             	lea    -0xc(%ebp),%eax
 4ff:	89 44 24 04          	mov    %eax,0x4(%esp)
 503:	8b 45 08             	mov    0x8(%ebp),%eax
 506:	89 04 24             	mov    %eax,(%esp)
 509:	e8 5a ff ff ff       	call   468 <write>
}
 50e:	c9                   	leave  
 50f:	c3                   	ret    

00000510 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 510:	55                   	push   %ebp
 511:	89 e5                	mov    %esp,%ebp
 513:	83 ec 48             	sub    $0x48,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 516:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 51d:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 521:	74 17                	je     53a <printint+0x2a>
 523:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 527:	79 11                	jns    53a <printint+0x2a>
    neg = 1;
 529:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 530:	8b 45 0c             	mov    0xc(%ebp),%eax
 533:	f7 d8                	neg    %eax
 535:	89 45 ec             	mov    %eax,-0x14(%ebp)
 538:	eb 06                	jmp    540 <printint+0x30>
  } else {
    x = xx;
 53a:	8b 45 0c             	mov    0xc(%ebp),%eax
 53d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 540:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 547:	8b 4d 10             	mov    0x10(%ebp),%ecx
 54a:	8b 45 ec             	mov    -0x14(%ebp),%eax
 54d:	ba 00 00 00 00       	mov    $0x0,%edx
 552:	f7 f1                	div    %ecx
 554:	89 d0                	mov    %edx,%eax
 556:	0f b6 90 20 0c 00 00 	movzbl 0xc20(%eax),%edx
 55d:	8d 45 dc             	lea    -0x24(%ebp),%eax
 560:	03 45 f4             	add    -0xc(%ebp),%eax
 563:	88 10                	mov    %dl,(%eax)
 565:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  }while((x /= base) != 0);
 569:	8b 55 10             	mov    0x10(%ebp),%edx
 56c:	89 55 d4             	mov    %edx,-0x2c(%ebp)
 56f:	8b 45 ec             	mov    -0x14(%ebp),%eax
 572:	ba 00 00 00 00       	mov    $0x0,%edx
 577:	f7 75 d4             	divl   -0x2c(%ebp)
 57a:	89 45 ec             	mov    %eax,-0x14(%ebp)
 57d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 581:	75 c4                	jne    547 <printint+0x37>
  if(neg)
 583:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 587:	74 2a                	je     5b3 <printint+0xa3>
    buf[i++] = '-';
 589:	8d 45 dc             	lea    -0x24(%ebp),%eax
 58c:	03 45 f4             	add    -0xc(%ebp),%eax
 58f:	c6 00 2d             	movb   $0x2d,(%eax)
 592:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

  while(--i >= 0)
 596:	eb 1b                	jmp    5b3 <printint+0xa3>
    putc(fd, buf[i]);
 598:	8d 45 dc             	lea    -0x24(%ebp),%eax
 59b:	03 45 f4             	add    -0xc(%ebp),%eax
 59e:	0f b6 00             	movzbl (%eax),%eax
 5a1:	0f be c0             	movsbl %al,%eax
 5a4:	89 44 24 04          	mov    %eax,0x4(%esp)
 5a8:	8b 45 08             	mov    0x8(%ebp),%eax
 5ab:	89 04 24             	mov    %eax,(%esp)
 5ae:	e8 35 ff ff ff       	call   4e8 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 5b3:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 5b7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 5bb:	79 db                	jns    598 <printint+0x88>
    putc(fd, buf[i]);
}
 5bd:	c9                   	leave  
 5be:	c3                   	ret    

000005bf <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 5bf:	55                   	push   %ebp
 5c0:	89 e5                	mov    %esp,%ebp
 5c2:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 5c5:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 5cc:	8d 45 0c             	lea    0xc(%ebp),%eax
 5cf:	83 c0 04             	add    $0x4,%eax
 5d2:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 5d5:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 5dc:	e9 7d 01 00 00       	jmp    75e <printf+0x19f>
    c = fmt[i] & 0xff;
 5e1:	8b 55 0c             	mov    0xc(%ebp),%edx
 5e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
 5e7:	01 d0                	add    %edx,%eax
 5e9:	0f b6 00             	movzbl (%eax),%eax
 5ec:	0f be c0             	movsbl %al,%eax
 5ef:	25 ff 00 00 00       	and    $0xff,%eax
 5f4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 5f7:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 5fb:	75 2c                	jne    629 <printf+0x6a>
      if(c == '%'){
 5fd:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 601:	75 0c                	jne    60f <printf+0x50>
        state = '%';
 603:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 60a:	e9 4b 01 00 00       	jmp    75a <printf+0x19b>
      } else {
        putc(fd, c);
 60f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 612:	0f be c0             	movsbl %al,%eax
 615:	89 44 24 04          	mov    %eax,0x4(%esp)
 619:	8b 45 08             	mov    0x8(%ebp),%eax
 61c:	89 04 24             	mov    %eax,(%esp)
 61f:	e8 c4 fe ff ff       	call   4e8 <putc>
 624:	e9 31 01 00 00       	jmp    75a <printf+0x19b>
      }
    } else if(state == '%'){
 629:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 62d:	0f 85 27 01 00 00    	jne    75a <printf+0x19b>
      if(c == 'd'){
 633:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 637:	75 2d                	jne    666 <printf+0xa7>
        printint(fd, *ap, 10, 1);
 639:	8b 45 e8             	mov    -0x18(%ebp),%eax
 63c:	8b 00                	mov    (%eax),%eax
 63e:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 645:	00 
 646:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 64d:	00 
 64e:	89 44 24 04          	mov    %eax,0x4(%esp)
 652:	8b 45 08             	mov    0x8(%ebp),%eax
 655:	89 04 24             	mov    %eax,(%esp)
 658:	e8 b3 fe ff ff       	call   510 <printint>
        ap++;
 65d:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 661:	e9 ed 00 00 00       	jmp    753 <printf+0x194>
      } else if(c == 'x' || c == 'p'){
 666:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 66a:	74 06                	je     672 <printf+0xb3>
 66c:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 670:	75 2d                	jne    69f <printf+0xe0>
        printint(fd, *ap, 16, 0);
 672:	8b 45 e8             	mov    -0x18(%ebp),%eax
 675:	8b 00                	mov    (%eax),%eax
 677:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 67e:	00 
 67f:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 686:	00 
 687:	89 44 24 04          	mov    %eax,0x4(%esp)
 68b:	8b 45 08             	mov    0x8(%ebp),%eax
 68e:	89 04 24             	mov    %eax,(%esp)
 691:	e8 7a fe ff ff       	call   510 <printint>
        ap++;
 696:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 69a:	e9 b4 00 00 00       	jmp    753 <printf+0x194>
      } else if(c == 's'){
 69f:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 6a3:	75 46                	jne    6eb <printf+0x12c>
        s = (char*)*ap;
 6a5:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6a8:	8b 00                	mov    (%eax),%eax
 6aa:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 6ad:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 6b1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 6b5:	75 27                	jne    6de <printf+0x11f>
          s = "(null)";
 6b7:	c7 45 f4 bb 09 00 00 	movl   $0x9bb,-0xc(%ebp)
        while(*s != 0){
 6be:	eb 1e                	jmp    6de <printf+0x11f>
          putc(fd, *s);
 6c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6c3:	0f b6 00             	movzbl (%eax),%eax
 6c6:	0f be c0             	movsbl %al,%eax
 6c9:	89 44 24 04          	mov    %eax,0x4(%esp)
 6cd:	8b 45 08             	mov    0x8(%ebp),%eax
 6d0:	89 04 24             	mov    %eax,(%esp)
 6d3:	e8 10 fe ff ff       	call   4e8 <putc>
          s++;
 6d8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 6dc:	eb 01                	jmp    6df <printf+0x120>
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 6de:	90                   	nop
 6df:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6e2:	0f b6 00             	movzbl (%eax),%eax
 6e5:	84 c0                	test   %al,%al
 6e7:	75 d7                	jne    6c0 <printf+0x101>
 6e9:	eb 68                	jmp    753 <printf+0x194>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 6eb:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 6ef:	75 1d                	jne    70e <printf+0x14f>
        putc(fd, *ap);
 6f1:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6f4:	8b 00                	mov    (%eax),%eax
 6f6:	0f be c0             	movsbl %al,%eax
 6f9:	89 44 24 04          	mov    %eax,0x4(%esp)
 6fd:	8b 45 08             	mov    0x8(%ebp),%eax
 700:	89 04 24             	mov    %eax,(%esp)
 703:	e8 e0 fd ff ff       	call   4e8 <putc>
        ap++;
 708:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 70c:	eb 45                	jmp    753 <printf+0x194>
      } else if(c == '%'){
 70e:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 712:	75 17                	jne    72b <printf+0x16c>
        putc(fd, c);
 714:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 717:	0f be c0             	movsbl %al,%eax
 71a:	89 44 24 04          	mov    %eax,0x4(%esp)
 71e:	8b 45 08             	mov    0x8(%ebp),%eax
 721:	89 04 24             	mov    %eax,(%esp)
 724:	e8 bf fd ff ff       	call   4e8 <putc>
 729:	eb 28                	jmp    753 <printf+0x194>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 72b:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 732:	00 
 733:	8b 45 08             	mov    0x8(%ebp),%eax
 736:	89 04 24             	mov    %eax,(%esp)
 739:	e8 aa fd ff ff       	call   4e8 <putc>
        putc(fd, c);
 73e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 741:	0f be c0             	movsbl %al,%eax
 744:	89 44 24 04          	mov    %eax,0x4(%esp)
 748:	8b 45 08             	mov    0x8(%ebp),%eax
 74b:	89 04 24             	mov    %eax,(%esp)
 74e:	e8 95 fd ff ff       	call   4e8 <putc>
      }
      state = 0;
 753:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 75a:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 75e:	8b 55 0c             	mov    0xc(%ebp),%edx
 761:	8b 45 f0             	mov    -0x10(%ebp),%eax
 764:	01 d0                	add    %edx,%eax
 766:	0f b6 00             	movzbl (%eax),%eax
 769:	84 c0                	test   %al,%al
 76b:	0f 85 70 fe ff ff    	jne    5e1 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 771:	c9                   	leave  
 772:	c3                   	ret    
 773:	90                   	nop

00000774 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 774:	55                   	push   %ebp
 775:	89 e5                	mov    %esp,%ebp
 777:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 77a:	8b 45 08             	mov    0x8(%ebp),%eax
 77d:	83 e8 08             	sub    $0x8,%eax
 780:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 783:	a1 48 0c 00 00       	mov    0xc48,%eax
 788:	89 45 fc             	mov    %eax,-0x4(%ebp)
 78b:	eb 24                	jmp    7b1 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 78d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 790:	8b 00                	mov    (%eax),%eax
 792:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 795:	77 12                	ja     7a9 <free+0x35>
 797:	8b 45 f8             	mov    -0x8(%ebp),%eax
 79a:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 79d:	77 24                	ja     7c3 <free+0x4f>
 79f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7a2:	8b 00                	mov    (%eax),%eax
 7a4:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 7a7:	77 1a                	ja     7c3 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7a9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7ac:	8b 00                	mov    (%eax),%eax
 7ae:	89 45 fc             	mov    %eax,-0x4(%ebp)
 7b1:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7b4:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 7b7:	76 d4                	jbe    78d <free+0x19>
 7b9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7bc:	8b 00                	mov    (%eax),%eax
 7be:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 7c1:	76 ca                	jbe    78d <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 7c3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7c6:	8b 40 04             	mov    0x4(%eax),%eax
 7c9:	c1 e0 03             	shl    $0x3,%eax
 7cc:	89 c2                	mov    %eax,%edx
 7ce:	03 55 f8             	add    -0x8(%ebp),%edx
 7d1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7d4:	8b 00                	mov    (%eax),%eax
 7d6:	39 c2                	cmp    %eax,%edx
 7d8:	75 24                	jne    7fe <free+0x8a>
    bp->s.size += p->s.ptr->s.size;
 7da:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7dd:	8b 50 04             	mov    0x4(%eax),%edx
 7e0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7e3:	8b 00                	mov    (%eax),%eax
 7e5:	8b 40 04             	mov    0x4(%eax),%eax
 7e8:	01 c2                	add    %eax,%edx
 7ea:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7ed:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 7f0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7f3:	8b 00                	mov    (%eax),%eax
 7f5:	8b 10                	mov    (%eax),%edx
 7f7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7fa:	89 10                	mov    %edx,(%eax)
 7fc:	eb 0a                	jmp    808 <free+0x94>
  } else
    bp->s.ptr = p->s.ptr;
 7fe:	8b 45 fc             	mov    -0x4(%ebp),%eax
 801:	8b 10                	mov    (%eax),%edx
 803:	8b 45 f8             	mov    -0x8(%ebp),%eax
 806:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 808:	8b 45 fc             	mov    -0x4(%ebp),%eax
 80b:	8b 40 04             	mov    0x4(%eax),%eax
 80e:	c1 e0 03             	shl    $0x3,%eax
 811:	03 45 fc             	add    -0x4(%ebp),%eax
 814:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 817:	75 20                	jne    839 <free+0xc5>
    p->s.size += bp->s.size;
 819:	8b 45 fc             	mov    -0x4(%ebp),%eax
 81c:	8b 50 04             	mov    0x4(%eax),%edx
 81f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 822:	8b 40 04             	mov    0x4(%eax),%eax
 825:	01 c2                	add    %eax,%edx
 827:	8b 45 fc             	mov    -0x4(%ebp),%eax
 82a:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 82d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 830:	8b 10                	mov    (%eax),%edx
 832:	8b 45 fc             	mov    -0x4(%ebp),%eax
 835:	89 10                	mov    %edx,(%eax)
 837:	eb 08                	jmp    841 <free+0xcd>
  } else
    p->s.ptr = bp;
 839:	8b 45 fc             	mov    -0x4(%ebp),%eax
 83c:	8b 55 f8             	mov    -0x8(%ebp),%edx
 83f:	89 10                	mov    %edx,(%eax)
  freep = p;
 841:	8b 45 fc             	mov    -0x4(%ebp),%eax
 844:	a3 48 0c 00 00       	mov    %eax,0xc48
}
 849:	c9                   	leave  
 84a:	c3                   	ret    

0000084b <morecore>:

static Header*
morecore(uint nu)
{
 84b:	55                   	push   %ebp
 84c:	89 e5                	mov    %esp,%ebp
 84e:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 851:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 858:	77 07                	ja     861 <morecore+0x16>
    nu = 4096;
 85a:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 861:	8b 45 08             	mov    0x8(%ebp),%eax
 864:	c1 e0 03             	shl    $0x3,%eax
 867:	89 04 24             	mov    %eax,(%esp)
 86a:	e8 61 fc ff ff       	call   4d0 <sbrk>
 86f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 872:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 876:	75 07                	jne    87f <morecore+0x34>
    return 0;
 878:	b8 00 00 00 00       	mov    $0x0,%eax
 87d:	eb 22                	jmp    8a1 <morecore+0x56>
  hp = (Header*)p;
 87f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 882:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 885:	8b 45 f0             	mov    -0x10(%ebp),%eax
 888:	8b 55 08             	mov    0x8(%ebp),%edx
 88b:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 88e:	8b 45 f0             	mov    -0x10(%ebp),%eax
 891:	83 c0 08             	add    $0x8,%eax
 894:	89 04 24             	mov    %eax,(%esp)
 897:	e8 d8 fe ff ff       	call   774 <free>
  return freep;
 89c:	a1 48 0c 00 00       	mov    0xc48,%eax
}
 8a1:	c9                   	leave  
 8a2:	c3                   	ret    

000008a3 <malloc>:

void*
malloc(uint nbytes)
{
 8a3:	55                   	push   %ebp
 8a4:	89 e5                	mov    %esp,%ebp
 8a6:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8a9:	8b 45 08             	mov    0x8(%ebp),%eax
 8ac:	83 c0 07             	add    $0x7,%eax
 8af:	c1 e8 03             	shr    $0x3,%eax
 8b2:	83 c0 01             	add    $0x1,%eax
 8b5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 8b8:	a1 48 0c 00 00       	mov    0xc48,%eax
 8bd:	89 45 f0             	mov    %eax,-0x10(%ebp)
 8c0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 8c4:	75 23                	jne    8e9 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 8c6:	c7 45 f0 40 0c 00 00 	movl   $0xc40,-0x10(%ebp)
 8cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8d0:	a3 48 0c 00 00       	mov    %eax,0xc48
 8d5:	a1 48 0c 00 00       	mov    0xc48,%eax
 8da:	a3 40 0c 00 00       	mov    %eax,0xc40
    base.s.size = 0;
 8df:	c7 05 44 0c 00 00 00 	movl   $0x0,0xc44
 8e6:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8ec:	8b 00                	mov    (%eax),%eax
 8ee:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 8f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8f4:	8b 40 04             	mov    0x4(%eax),%eax
 8f7:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 8fa:	72 4d                	jb     949 <malloc+0xa6>
      if(p->s.size == nunits)
 8fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8ff:	8b 40 04             	mov    0x4(%eax),%eax
 902:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 905:	75 0c                	jne    913 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 907:	8b 45 f4             	mov    -0xc(%ebp),%eax
 90a:	8b 10                	mov    (%eax),%edx
 90c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 90f:	89 10                	mov    %edx,(%eax)
 911:	eb 26                	jmp    939 <malloc+0x96>
      else {
        p->s.size -= nunits;
 913:	8b 45 f4             	mov    -0xc(%ebp),%eax
 916:	8b 40 04             	mov    0x4(%eax),%eax
 919:	89 c2                	mov    %eax,%edx
 91b:	2b 55 ec             	sub    -0x14(%ebp),%edx
 91e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 921:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 924:	8b 45 f4             	mov    -0xc(%ebp),%eax
 927:	8b 40 04             	mov    0x4(%eax),%eax
 92a:	c1 e0 03             	shl    $0x3,%eax
 92d:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 930:	8b 45 f4             	mov    -0xc(%ebp),%eax
 933:	8b 55 ec             	mov    -0x14(%ebp),%edx
 936:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 939:	8b 45 f0             	mov    -0x10(%ebp),%eax
 93c:	a3 48 0c 00 00       	mov    %eax,0xc48
      return (void*)(p + 1);
 941:	8b 45 f4             	mov    -0xc(%ebp),%eax
 944:	83 c0 08             	add    $0x8,%eax
 947:	eb 38                	jmp    981 <malloc+0xde>
    }
    if(p == freep)
 949:	a1 48 0c 00 00       	mov    0xc48,%eax
 94e:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 951:	75 1b                	jne    96e <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 953:	8b 45 ec             	mov    -0x14(%ebp),%eax
 956:	89 04 24             	mov    %eax,(%esp)
 959:	e8 ed fe ff ff       	call   84b <morecore>
 95e:	89 45 f4             	mov    %eax,-0xc(%ebp)
 961:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 965:	75 07                	jne    96e <malloc+0xcb>
        return 0;
 967:	b8 00 00 00 00       	mov    $0x0,%eax
 96c:	eb 13                	jmp    981 <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 96e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 971:	89 45 f0             	mov    %eax,-0x10(%ebp)
 974:	8b 45 f4             	mov    -0xc(%ebp),%eax
 977:	8b 00                	mov    (%eax),%eax
 979:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 97c:	e9 70 ff ff ff       	jmp    8f1 <malloc+0x4e>
}
 981:	c9                   	leave  
 982:	c3                   	ret    
