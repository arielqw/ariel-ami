
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
  32:	05 80 0c 00 00       	add    $0xc80,%eax
  37:	0f b6 00             	movzbl (%eax),%eax
  3a:	3c 0a                	cmp    $0xa,%al
  3c:	75 04                	jne    42 <wc+0x42>
        l++;
  3e:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
      if(strchr(" \r\t\n\v", buf[i]))
  42:	8b 45 f4             	mov    -0xc(%ebp),%eax
  45:	05 80 0c 00 00       	add    $0xc80,%eax
  4a:	0f b6 00             	movzbl (%eax),%eax
  4d:	0f be c0             	movsbl %al,%eax
  50:	89 44 24 04          	mov    %eax,0x4(%esp)
  54:	c7 04 24 ab 09 00 00 	movl   $0x9ab,(%esp)
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
  92:	c7 44 24 04 80 0c 00 	movl   $0xc80,0x4(%esp)
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
  b8:	c7 44 24 04 b1 09 00 	movl   $0x9b1,0x4(%esp)
  bf:	00 
  c0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  c7:	e8 1b 05 00 00       	call   5e7 <printf>
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
  f4:	c7 44 24 04 c1 09 00 	movl   $0x9c1,0x4(%esp)
  fb:	00 
  fc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 103:	e8 df 04 00 00       	call   5e7 <printf>
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
 119:	c7 44 24 04 ce 09 00 	movl   $0x9ce,0x4(%esp)
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
 17d:	c7 44 24 04 cf 09 00 	movl   $0x9cf,0x4(%esp)
 184:	00 
 185:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 18c:	e8 56 04 00 00       	call   5e7 <printf>
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

000004e8 <waitpid>:
SYSCALL(waitpid)
 4e8:	b8 16 00 00 00       	mov    $0x16,%eax
 4ed:	cd 40                	int    $0x40
 4ef:	c3                   	ret    

000004f0 <wait_stat>:
SYSCALL(wait_stat)
 4f0:	b8 17 00 00 00       	mov    $0x17,%eax
 4f5:	cd 40                	int    $0x40
 4f7:	c3                   	ret    

000004f8 <list_pgroup>:
SYSCALL(list_pgroup)
 4f8:	b8 18 00 00 00       	mov    $0x18,%eax
 4fd:	cd 40                	int    $0x40
 4ff:	c3                   	ret    

00000500 <foreground>:
SYSCALL(foreground)
 500:	b8 19 00 00 00       	mov    $0x19,%eax
 505:	cd 40                	int    $0x40
 507:	c3                   	ret    

00000508 <set_priority>:
SYSCALL(set_priority)
 508:	b8 1a 00 00 00       	mov    $0x1a,%eax
 50d:	cd 40                	int    $0x40
 50f:	c3                   	ret    

00000510 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 510:	55                   	push   %ebp
 511:	89 e5                	mov    %esp,%ebp
 513:	83 ec 28             	sub    $0x28,%esp
 516:	8b 45 0c             	mov    0xc(%ebp),%eax
 519:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 51c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 523:	00 
 524:	8d 45 f4             	lea    -0xc(%ebp),%eax
 527:	89 44 24 04          	mov    %eax,0x4(%esp)
 52b:	8b 45 08             	mov    0x8(%ebp),%eax
 52e:	89 04 24             	mov    %eax,(%esp)
 531:	e8 32 ff ff ff       	call   468 <write>
}
 536:	c9                   	leave  
 537:	c3                   	ret    

00000538 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 538:	55                   	push   %ebp
 539:	89 e5                	mov    %esp,%ebp
 53b:	83 ec 48             	sub    $0x48,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 53e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 545:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 549:	74 17                	je     562 <printint+0x2a>
 54b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 54f:	79 11                	jns    562 <printint+0x2a>
    neg = 1;
 551:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 558:	8b 45 0c             	mov    0xc(%ebp),%eax
 55b:	f7 d8                	neg    %eax
 55d:	89 45 ec             	mov    %eax,-0x14(%ebp)
 560:	eb 06                	jmp    568 <printint+0x30>
  } else {
    x = xx;
 562:	8b 45 0c             	mov    0xc(%ebp),%eax
 565:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 568:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 56f:	8b 4d 10             	mov    0x10(%ebp),%ecx
 572:	8b 45 ec             	mov    -0x14(%ebp),%eax
 575:	ba 00 00 00 00       	mov    $0x0,%edx
 57a:	f7 f1                	div    %ecx
 57c:	89 d0                	mov    %edx,%eax
 57e:	0f b6 90 48 0c 00 00 	movzbl 0xc48(%eax),%edx
 585:	8d 45 dc             	lea    -0x24(%ebp),%eax
 588:	03 45 f4             	add    -0xc(%ebp),%eax
 58b:	88 10                	mov    %dl,(%eax)
 58d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  }while((x /= base) != 0);
 591:	8b 55 10             	mov    0x10(%ebp),%edx
 594:	89 55 d4             	mov    %edx,-0x2c(%ebp)
 597:	8b 45 ec             	mov    -0x14(%ebp),%eax
 59a:	ba 00 00 00 00       	mov    $0x0,%edx
 59f:	f7 75 d4             	divl   -0x2c(%ebp)
 5a2:	89 45 ec             	mov    %eax,-0x14(%ebp)
 5a5:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 5a9:	75 c4                	jne    56f <printint+0x37>
  if(neg)
 5ab:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 5af:	74 2a                	je     5db <printint+0xa3>
    buf[i++] = '-';
 5b1:	8d 45 dc             	lea    -0x24(%ebp),%eax
 5b4:	03 45 f4             	add    -0xc(%ebp),%eax
 5b7:	c6 00 2d             	movb   $0x2d,(%eax)
 5ba:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

  while(--i >= 0)
 5be:	eb 1b                	jmp    5db <printint+0xa3>
    putc(fd, buf[i]);
 5c0:	8d 45 dc             	lea    -0x24(%ebp),%eax
 5c3:	03 45 f4             	add    -0xc(%ebp),%eax
 5c6:	0f b6 00             	movzbl (%eax),%eax
 5c9:	0f be c0             	movsbl %al,%eax
 5cc:	89 44 24 04          	mov    %eax,0x4(%esp)
 5d0:	8b 45 08             	mov    0x8(%ebp),%eax
 5d3:	89 04 24             	mov    %eax,(%esp)
 5d6:	e8 35 ff ff ff       	call   510 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 5db:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 5df:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 5e3:	79 db                	jns    5c0 <printint+0x88>
    putc(fd, buf[i]);
}
 5e5:	c9                   	leave  
 5e6:	c3                   	ret    

000005e7 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 5e7:	55                   	push   %ebp
 5e8:	89 e5                	mov    %esp,%ebp
 5ea:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 5ed:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 5f4:	8d 45 0c             	lea    0xc(%ebp),%eax
 5f7:	83 c0 04             	add    $0x4,%eax
 5fa:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 5fd:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 604:	e9 7d 01 00 00       	jmp    786 <printf+0x19f>
    c = fmt[i] & 0xff;
 609:	8b 55 0c             	mov    0xc(%ebp),%edx
 60c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 60f:	01 d0                	add    %edx,%eax
 611:	0f b6 00             	movzbl (%eax),%eax
 614:	0f be c0             	movsbl %al,%eax
 617:	25 ff 00 00 00       	and    $0xff,%eax
 61c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 61f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 623:	75 2c                	jne    651 <printf+0x6a>
      if(c == '%'){
 625:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 629:	75 0c                	jne    637 <printf+0x50>
        state = '%';
 62b:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 632:	e9 4b 01 00 00       	jmp    782 <printf+0x19b>
      } else {
        putc(fd, c);
 637:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 63a:	0f be c0             	movsbl %al,%eax
 63d:	89 44 24 04          	mov    %eax,0x4(%esp)
 641:	8b 45 08             	mov    0x8(%ebp),%eax
 644:	89 04 24             	mov    %eax,(%esp)
 647:	e8 c4 fe ff ff       	call   510 <putc>
 64c:	e9 31 01 00 00       	jmp    782 <printf+0x19b>
      }
    } else if(state == '%'){
 651:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 655:	0f 85 27 01 00 00    	jne    782 <printf+0x19b>
      if(c == 'd'){
 65b:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 65f:	75 2d                	jne    68e <printf+0xa7>
        printint(fd, *ap, 10, 1);
 661:	8b 45 e8             	mov    -0x18(%ebp),%eax
 664:	8b 00                	mov    (%eax),%eax
 666:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 66d:	00 
 66e:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 675:	00 
 676:	89 44 24 04          	mov    %eax,0x4(%esp)
 67a:	8b 45 08             	mov    0x8(%ebp),%eax
 67d:	89 04 24             	mov    %eax,(%esp)
 680:	e8 b3 fe ff ff       	call   538 <printint>
        ap++;
 685:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 689:	e9 ed 00 00 00       	jmp    77b <printf+0x194>
      } else if(c == 'x' || c == 'p'){
 68e:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 692:	74 06                	je     69a <printf+0xb3>
 694:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 698:	75 2d                	jne    6c7 <printf+0xe0>
        printint(fd, *ap, 16, 0);
 69a:	8b 45 e8             	mov    -0x18(%ebp),%eax
 69d:	8b 00                	mov    (%eax),%eax
 69f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 6a6:	00 
 6a7:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 6ae:	00 
 6af:	89 44 24 04          	mov    %eax,0x4(%esp)
 6b3:	8b 45 08             	mov    0x8(%ebp),%eax
 6b6:	89 04 24             	mov    %eax,(%esp)
 6b9:	e8 7a fe ff ff       	call   538 <printint>
        ap++;
 6be:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 6c2:	e9 b4 00 00 00       	jmp    77b <printf+0x194>
      } else if(c == 's'){
 6c7:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 6cb:	75 46                	jne    713 <printf+0x12c>
        s = (char*)*ap;
 6cd:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6d0:	8b 00                	mov    (%eax),%eax
 6d2:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 6d5:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 6d9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 6dd:	75 27                	jne    706 <printf+0x11f>
          s = "(null)";
 6df:	c7 45 f4 e3 09 00 00 	movl   $0x9e3,-0xc(%ebp)
        while(*s != 0){
 6e6:	eb 1e                	jmp    706 <printf+0x11f>
          putc(fd, *s);
 6e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6eb:	0f b6 00             	movzbl (%eax),%eax
 6ee:	0f be c0             	movsbl %al,%eax
 6f1:	89 44 24 04          	mov    %eax,0x4(%esp)
 6f5:	8b 45 08             	mov    0x8(%ebp),%eax
 6f8:	89 04 24             	mov    %eax,(%esp)
 6fb:	e8 10 fe ff ff       	call   510 <putc>
          s++;
 700:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 704:	eb 01                	jmp    707 <printf+0x120>
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 706:	90                   	nop
 707:	8b 45 f4             	mov    -0xc(%ebp),%eax
 70a:	0f b6 00             	movzbl (%eax),%eax
 70d:	84 c0                	test   %al,%al
 70f:	75 d7                	jne    6e8 <printf+0x101>
 711:	eb 68                	jmp    77b <printf+0x194>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 713:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 717:	75 1d                	jne    736 <printf+0x14f>
        putc(fd, *ap);
 719:	8b 45 e8             	mov    -0x18(%ebp),%eax
 71c:	8b 00                	mov    (%eax),%eax
 71e:	0f be c0             	movsbl %al,%eax
 721:	89 44 24 04          	mov    %eax,0x4(%esp)
 725:	8b 45 08             	mov    0x8(%ebp),%eax
 728:	89 04 24             	mov    %eax,(%esp)
 72b:	e8 e0 fd ff ff       	call   510 <putc>
        ap++;
 730:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 734:	eb 45                	jmp    77b <printf+0x194>
      } else if(c == '%'){
 736:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 73a:	75 17                	jne    753 <printf+0x16c>
        putc(fd, c);
 73c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 73f:	0f be c0             	movsbl %al,%eax
 742:	89 44 24 04          	mov    %eax,0x4(%esp)
 746:	8b 45 08             	mov    0x8(%ebp),%eax
 749:	89 04 24             	mov    %eax,(%esp)
 74c:	e8 bf fd ff ff       	call   510 <putc>
 751:	eb 28                	jmp    77b <printf+0x194>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 753:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 75a:	00 
 75b:	8b 45 08             	mov    0x8(%ebp),%eax
 75e:	89 04 24             	mov    %eax,(%esp)
 761:	e8 aa fd ff ff       	call   510 <putc>
        putc(fd, c);
 766:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 769:	0f be c0             	movsbl %al,%eax
 76c:	89 44 24 04          	mov    %eax,0x4(%esp)
 770:	8b 45 08             	mov    0x8(%ebp),%eax
 773:	89 04 24             	mov    %eax,(%esp)
 776:	e8 95 fd ff ff       	call   510 <putc>
      }
      state = 0;
 77b:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 782:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 786:	8b 55 0c             	mov    0xc(%ebp),%edx
 789:	8b 45 f0             	mov    -0x10(%ebp),%eax
 78c:	01 d0                	add    %edx,%eax
 78e:	0f b6 00             	movzbl (%eax),%eax
 791:	84 c0                	test   %al,%al
 793:	0f 85 70 fe ff ff    	jne    609 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 799:	c9                   	leave  
 79a:	c3                   	ret    
 79b:	90                   	nop

0000079c <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 79c:	55                   	push   %ebp
 79d:	89 e5                	mov    %esp,%ebp
 79f:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7a2:	8b 45 08             	mov    0x8(%ebp),%eax
 7a5:	83 e8 08             	sub    $0x8,%eax
 7a8:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7ab:	a1 68 0c 00 00       	mov    0xc68,%eax
 7b0:	89 45 fc             	mov    %eax,-0x4(%ebp)
 7b3:	eb 24                	jmp    7d9 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7b5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7b8:	8b 00                	mov    (%eax),%eax
 7ba:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 7bd:	77 12                	ja     7d1 <free+0x35>
 7bf:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7c2:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 7c5:	77 24                	ja     7eb <free+0x4f>
 7c7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7ca:	8b 00                	mov    (%eax),%eax
 7cc:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 7cf:	77 1a                	ja     7eb <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7d1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7d4:	8b 00                	mov    (%eax),%eax
 7d6:	89 45 fc             	mov    %eax,-0x4(%ebp)
 7d9:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7dc:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 7df:	76 d4                	jbe    7b5 <free+0x19>
 7e1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7e4:	8b 00                	mov    (%eax),%eax
 7e6:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 7e9:	76 ca                	jbe    7b5 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 7eb:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7ee:	8b 40 04             	mov    0x4(%eax),%eax
 7f1:	c1 e0 03             	shl    $0x3,%eax
 7f4:	89 c2                	mov    %eax,%edx
 7f6:	03 55 f8             	add    -0x8(%ebp),%edx
 7f9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7fc:	8b 00                	mov    (%eax),%eax
 7fe:	39 c2                	cmp    %eax,%edx
 800:	75 24                	jne    826 <free+0x8a>
    bp->s.size += p->s.ptr->s.size;
 802:	8b 45 f8             	mov    -0x8(%ebp),%eax
 805:	8b 50 04             	mov    0x4(%eax),%edx
 808:	8b 45 fc             	mov    -0x4(%ebp),%eax
 80b:	8b 00                	mov    (%eax),%eax
 80d:	8b 40 04             	mov    0x4(%eax),%eax
 810:	01 c2                	add    %eax,%edx
 812:	8b 45 f8             	mov    -0x8(%ebp),%eax
 815:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 818:	8b 45 fc             	mov    -0x4(%ebp),%eax
 81b:	8b 00                	mov    (%eax),%eax
 81d:	8b 10                	mov    (%eax),%edx
 81f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 822:	89 10                	mov    %edx,(%eax)
 824:	eb 0a                	jmp    830 <free+0x94>
  } else
    bp->s.ptr = p->s.ptr;
 826:	8b 45 fc             	mov    -0x4(%ebp),%eax
 829:	8b 10                	mov    (%eax),%edx
 82b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 82e:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 830:	8b 45 fc             	mov    -0x4(%ebp),%eax
 833:	8b 40 04             	mov    0x4(%eax),%eax
 836:	c1 e0 03             	shl    $0x3,%eax
 839:	03 45 fc             	add    -0x4(%ebp),%eax
 83c:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 83f:	75 20                	jne    861 <free+0xc5>
    p->s.size += bp->s.size;
 841:	8b 45 fc             	mov    -0x4(%ebp),%eax
 844:	8b 50 04             	mov    0x4(%eax),%edx
 847:	8b 45 f8             	mov    -0x8(%ebp),%eax
 84a:	8b 40 04             	mov    0x4(%eax),%eax
 84d:	01 c2                	add    %eax,%edx
 84f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 852:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 855:	8b 45 f8             	mov    -0x8(%ebp),%eax
 858:	8b 10                	mov    (%eax),%edx
 85a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 85d:	89 10                	mov    %edx,(%eax)
 85f:	eb 08                	jmp    869 <free+0xcd>
  } else
    p->s.ptr = bp;
 861:	8b 45 fc             	mov    -0x4(%ebp),%eax
 864:	8b 55 f8             	mov    -0x8(%ebp),%edx
 867:	89 10                	mov    %edx,(%eax)
  freep = p;
 869:	8b 45 fc             	mov    -0x4(%ebp),%eax
 86c:	a3 68 0c 00 00       	mov    %eax,0xc68
}
 871:	c9                   	leave  
 872:	c3                   	ret    

00000873 <morecore>:

static Header*
morecore(uint nu)
{
 873:	55                   	push   %ebp
 874:	89 e5                	mov    %esp,%ebp
 876:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 879:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 880:	77 07                	ja     889 <morecore+0x16>
    nu = 4096;
 882:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 889:	8b 45 08             	mov    0x8(%ebp),%eax
 88c:	c1 e0 03             	shl    $0x3,%eax
 88f:	89 04 24             	mov    %eax,(%esp)
 892:	e8 39 fc ff ff       	call   4d0 <sbrk>
 897:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 89a:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 89e:	75 07                	jne    8a7 <morecore+0x34>
    return 0;
 8a0:	b8 00 00 00 00       	mov    $0x0,%eax
 8a5:	eb 22                	jmp    8c9 <morecore+0x56>
  hp = (Header*)p;
 8a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8aa:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 8ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8b0:	8b 55 08             	mov    0x8(%ebp),%edx
 8b3:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 8b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8b9:	83 c0 08             	add    $0x8,%eax
 8bc:	89 04 24             	mov    %eax,(%esp)
 8bf:	e8 d8 fe ff ff       	call   79c <free>
  return freep;
 8c4:	a1 68 0c 00 00       	mov    0xc68,%eax
}
 8c9:	c9                   	leave  
 8ca:	c3                   	ret    

000008cb <malloc>:

void*
malloc(uint nbytes)
{
 8cb:	55                   	push   %ebp
 8cc:	89 e5                	mov    %esp,%ebp
 8ce:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8d1:	8b 45 08             	mov    0x8(%ebp),%eax
 8d4:	83 c0 07             	add    $0x7,%eax
 8d7:	c1 e8 03             	shr    $0x3,%eax
 8da:	83 c0 01             	add    $0x1,%eax
 8dd:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 8e0:	a1 68 0c 00 00       	mov    0xc68,%eax
 8e5:	89 45 f0             	mov    %eax,-0x10(%ebp)
 8e8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 8ec:	75 23                	jne    911 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 8ee:	c7 45 f0 60 0c 00 00 	movl   $0xc60,-0x10(%ebp)
 8f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8f8:	a3 68 0c 00 00       	mov    %eax,0xc68
 8fd:	a1 68 0c 00 00       	mov    0xc68,%eax
 902:	a3 60 0c 00 00       	mov    %eax,0xc60
    base.s.size = 0;
 907:	c7 05 64 0c 00 00 00 	movl   $0x0,0xc64
 90e:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 911:	8b 45 f0             	mov    -0x10(%ebp),%eax
 914:	8b 00                	mov    (%eax),%eax
 916:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 919:	8b 45 f4             	mov    -0xc(%ebp),%eax
 91c:	8b 40 04             	mov    0x4(%eax),%eax
 91f:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 922:	72 4d                	jb     971 <malloc+0xa6>
      if(p->s.size == nunits)
 924:	8b 45 f4             	mov    -0xc(%ebp),%eax
 927:	8b 40 04             	mov    0x4(%eax),%eax
 92a:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 92d:	75 0c                	jne    93b <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 92f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 932:	8b 10                	mov    (%eax),%edx
 934:	8b 45 f0             	mov    -0x10(%ebp),%eax
 937:	89 10                	mov    %edx,(%eax)
 939:	eb 26                	jmp    961 <malloc+0x96>
      else {
        p->s.size -= nunits;
 93b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 93e:	8b 40 04             	mov    0x4(%eax),%eax
 941:	89 c2                	mov    %eax,%edx
 943:	2b 55 ec             	sub    -0x14(%ebp),%edx
 946:	8b 45 f4             	mov    -0xc(%ebp),%eax
 949:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 94c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 94f:	8b 40 04             	mov    0x4(%eax),%eax
 952:	c1 e0 03             	shl    $0x3,%eax
 955:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 958:	8b 45 f4             	mov    -0xc(%ebp),%eax
 95b:	8b 55 ec             	mov    -0x14(%ebp),%edx
 95e:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 961:	8b 45 f0             	mov    -0x10(%ebp),%eax
 964:	a3 68 0c 00 00       	mov    %eax,0xc68
      return (void*)(p + 1);
 969:	8b 45 f4             	mov    -0xc(%ebp),%eax
 96c:	83 c0 08             	add    $0x8,%eax
 96f:	eb 38                	jmp    9a9 <malloc+0xde>
    }
    if(p == freep)
 971:	a1 68 0c 00 00       	mov    0xc68,%eax
 976:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 979:	75 1b                	jne    996 <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 97b:	8b 45 ec             	mov    -0x14(%ebp),%eax
 97e:	89 04 24             	mov    %eax,(%esp)
 981:	e8 ed fe ff ff       	call   873 <morecore>
 986:	89 45 f4             	mov    %eax,-0xc(%ebp)
 989:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 98d:	75 07                	jne    996 <malloc+0xcb>
        return 0;
 98f:	b8 00 00 00 00       	mov    $0x0,%eax
 994:	eb 13                	jmp    9a9 <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 996:	8b 45 f4             	mov    -0xc(%ebp),%eax
 999:	89 45 f0             	mov    %eax,-0x10(%ebp)
 99c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 99f:	8b 00                	mov    (%eax),%eax
 9a1:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 9a4:	e9 70 ff ff ff       	jmp    919 <malloc+0x4e>
}
 9a9:	c9                   	leave  
 9aa:	c3                   	ret    
