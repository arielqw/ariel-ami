
_grep:     file format elf32-i386


Disassembly of section .text:

00000000 <grep>:
char buf[1024];
int match(char*, char*);

void
grep(char *pattern, int fd)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 ec 28             	sub    $0x28,%esp
  int n, m;
  char *p, *q;
  
  m = 0;
   6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  while((n = read(fd, buf+m, sizeof(buf)-m)) > 0){
   d:	e9 bf 00 00 00       	jmp    d1 <grep+0xd1>
    m += n;
  12:	8b 45 ec             	mov    -0x14(%ebp),%eax
  15:	01 45 f4             	add    %eax,-0xc(%ebp)
    p = buf;
  18:	c7 45 f0 40 0e 00 00 	movl   $0xe40,-0x10(%ebp)
    while((q = strchr(p, '\n')) != 0){
  1f:	eb 53                	jmp    74 <grep+0x74>
      *q = 0;
  21:	8b 45 e8             	mov    -0x18(%ebp),%eax
  24:	c6 00 00             	movb   $0x0,(%eax)
      if(match(pattern, p)){
  27:	8b 45 f0             	mov    -0x10(%ebp),%eax
  2a:	89 44 24 04          	mov    %eax,0x4(%esp)
  2e:	8b 45 08             	mov    0x8(%ebp),%eax
  31:	89 04 24             	mov    %eax,(%esp)
  34:	e8 cf 01 00 00       	call   208 <match>
  39:	85 c0                	test   %eax,%eax
  3b:	74 2e                	je     6b <grep+0x6b>
        *q = '\n';
  3d:	8b 45 e8             	mov    -0x18(%ebp),%eax
  40:	c6 00 0a             	movb   $0xa,(%eax)
        write(1, p, q+1 - p);
  43:	8b 45 e8             	mov    -0x18(%ebp),%eax
  46:	83 c0 01             	add    $0x1,%eax
  49:	89 c2                	mov    %eax,%edx
  4b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  4e:	89 d1                	mov    %edx,%ecx
  50:	29 c1                	sub    %eax,%ecx
  52:	89 c8                	mov    %ecx,%eax
  54:	89 44 24 08          	mov    %eax,0x8(%esp)
  58:	8b 45 f0             	mov    -0x10(%ebp),%eax
  5b:	89 44 24 04          	mov    %eax,0x4(%esp)
  5f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  66:	e8 89 05 00 00       	call   5f4 <write>
      }
      p = q+1;
  6b:	8b 45 e8             	mov    -0x18(%ebp),%eax
  6e:	83 c0 01             	add    $0x1,%eax
  71:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  m = 0;
  while((n = read(fd, buf+m, sizeof(buf)-m)) > 0){
    m += n;
    p = buf;
    while((q = strchr(p, '\n')) != 0){
  74:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
  7b:	00 
  7c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  7f:	89 04 24             	mov    %eax,(%esp)
  82:	e8 cc 03 00 00       	call   453 <strchr>
  87:	89 45 e8             	mov    %eax,-0x18(%ebp)
  8a:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  8e:	75 91                	jne    21 <grep+0x21>
        *q = '\n';
        write(1, p, q+1 - p);
      }
      p = q+1;
    }
    if(p == buf)
  90:	81 7d f0 40 0e 00 00 	cmpl   $0xe40,-0x10(%ebp)
  97:	75 07                	jne    a0 <grep+0xa0>
      m = 0;
  99:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(m > 0){
  a0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  a4:	7e 2b                	jle    d1 <grep+0xd1>
      m -= p - buf;
  a6:	ba 40 0e 00 00       	mov    $0xe40,%edx
  ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
  ae:	89 d1                	mov    %edx,%ecx
  b0:	29 c1                	sub    %eax,%ecx
  b2:	89 c8                	mov    %ecx,%eax
  b4:	01 45 f4             	add    %eax,-0xc(%ebp)
      memmove(buf, p, m);
  b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  ba:	89 44 24 08          	mov    %eax,0x8(%esp)
  be:	8b 45 f0             	mov    -0x10(%ebp),%eax
  c1:	89 44 24 04          	mov    %eax,0x4(%esp)
  c5:	c7 04 24 40 0e 00 00 	movl   $0xe40,(%esp)
  cc:	e8 bd 04 00 00       	call   58e <memmove>
{
  int n, m;
  char *p, *q;
  
  m = 0;
  while((n = read(fd, buf+m, sizeof(buf)-m)) > 0){
  d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  d4:	ba 00 04 00 00       	mov    $0x400,%edx
  d9:	89 d1                	mov    %edx,%ecx
  db:	29 c1                	sub    %eax,%ecx
  dd:	89 c8                	mov    %ecx,%eax
  df:	8b 55 f4             	mov    -0xc(%ebp),%edx
  e2:	81 c2 40 0e 00 00    	add    $0xe40,%edx
  e8:	89 44 24 08          	mov    %eax,0x8(%esp)
  ec:	89 54 24 04          	mov    %edx,0x4(%esp)
  f0:	8b 45 0c             	mov    0xc(%ebp),%eax
  f3:	89 04 24             	mov    %eax,(%esp)
  f6:	e8 f1 04 00 00       	call   5ec <read>
  fb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  fe:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 102:	0f 8f 0a ff ff ff    	jg     12 <grep+0x12>
    if(m > 0){
      m -= p - buf;
      memmove(buf, p, m);
    }
  }
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
  char *pattern;
  
  if(argc <= 1){
 113:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
 117:	7f 20                	jg     139 <main+0x2f>
    printf(2, "usage: grep pattern [file ...]\n");
 119:	c7 44 24 04 10 0b 00 	movl   $0xb10,0x4(%esp)
 120:	00 
 121:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
 128:	e8 1e 06 00 00       	call   74b <printf>
    exit(EXIT_STATUS_DEFAULT);
 12d:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
 134:	e8 9b 04 00 00       	call   5d4 <exit>
  }
  pattern = argv[1];
 139:	8b 45 0c             	mov    0xc(%ebp),%eax
 13c:	8b 40 04             	mov    0x4(%eax),%eax
 13f:	89 44 24 18          	mov    %eax,0x18(%esp)
  
  if(argc <= 2){
 143:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
 147:	7f 20                	jg     169 <main+0x5f>
    grep(pattern, 0);
 149:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 150:	00 
 151:	8b 44 24 18          	mov    0x18(%esp),%eax
 155:	89 04 24             	mov    %eax,(%esp)
 158:	e8 a3 fe ff ff       	call   0 <grep>
    exit(EXIT_STATUS_DEFAULT);
 15d:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
 164:	e8 6b 04 00 00       	call   5d4 <exit>
  }

  for(i = 2; i < argc; i++){
 169:	c7 44 24 1c 02 00 00 	movl   $0x2,0x1c(%esp)
 170:	00 
 171:	eb 7c                	jmp    1ef <main+0xe5>
    if((fd = open(argv[i], 0)) < 0){
 173:	8b 44 24 1c          	mov    0x1c(%esp),%eax
 177:	c1 e0 02             	shl    $0x2,%eax
 17a:	03 45 0c             	add    0xc(%ebp),%eax
 17d:	8b 00                	mov    (%eax),%eax
 17f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 186:	00 
 187:	89 04 24             	mov    %eax,(%esp)
 18a:	e8 85 04 00 00       	call   614 <open>
 18f:	89 44 24 14          	mov    %eax,0x14(%esp)
 193:	83 7c 24 14 00       	cmpl   $0x0,0x14(%esp)
 198:	79 30                	jns    1ca <main+0xc0>
      printf(1, "grep: cannot open %s\n", argv[i]);
 19a:	8b 44 24 1c          	mov    0x1c(%esp),%eax
 19e:	c1 e0 02             	shl    $0x2,%eax
 1a1:	03 45 0c             	add    0xc(%ebp),%eax
 1a4:	8b 00                	mov    (%eax),%eax
 1a6:	89 44 24 08          	mov    %eax,0x8(%esp)
 1aa:	c7 44 24 04 30 0b 00 	movl   $0xb30,0x4(%esp)
 1b1:	00 
 1b2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 1b9:	e8 8d 05 00 00       	call   74b <printf>
      exit(EXIT_STATUS_DEFAULT);
 1be:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
 1c5:	e8 0a 04 00 00       	call   5d4 <exit>
    }
    grep(pattern, fd);
 1ca:	8b 44 24 14          	mov    0x14(%esp),%eax
 1ce:	89 44 24 04          	mov    %eax,0x4(%esp)
 1d2:	8b 44 24 18          	mov    0x18(%esp),%eax
 1d6:	89 04 24             	mov    %eax,(%esp)
 1d9:	e8 22 fe ff ff       	call   0 <grep>
    close(fd);
 1de:	8b 44 24 14          	mov    0x14(%esp),%eax
 1e2:	89 04 24             	mov    %eax,(%esp)
 1e5:	e8 12 04 00 00       	call   5fc <close>
  if(argc <= 2){
    grep(pattern, 0);
    exit(EXIT_STATUS_DEFAULT);
  }

  for(i = 2; i < argc; i++){
 1ea:	83 44 24 1c 01       	addl   $0x1,0x1c(%esp)
 1ef:	8b 44 24 1c          	mov    0x1c(%esp),%eax
 1f3:	3b 45 08             	cmp    0x8(%ebp),%eax
 1f6:	0f 8c 77 ff ff ff    	jl     173 <main+0x69>
      exit(EXIT_STATUS_DEFAULT);
    }
    grep(pattern, fd);
    close(fd);
  }
  exit(EXIT_STATUS_DEFAULT);
 1fc:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
 203:	e8 cc 03 00 00       	call   5d4 <exit>

00000208 <match>:
int matchhere(char*, char*);
int matchstar(int, char*, char*);

int
match(char *re, char *text)
{
 208:	55                   	push   %ebp
 209:	89 e5                	mov    %esp,%ebp
 20b:	83 ec 18             	sub    $0x18,%esp
  if(re[0] == '^')
 20e:	8b 45 08             	mov    0x8(%ebp),%eax
 211:	0f b6 00             	movzbl (%eax),%eax
 214:	3c 5e                	cmp    $0x5e,%al
 216:	75 17                	jne    22f <match+0x27>
    return matchhere(re+1, text);
 218:	8b 45 08             	mov    0x8(%ebp),%eax
 21b:	8d 50 01             	lea    0x1(%eax),%edx
 21e:	8b 45 0c             	mov    0xc(%ebp),%eax
 221:	89 44 24 04          	mov    %eax,0x4(%esp)
 225:	89 14 24             	mov    %edx,(%esp)
 228:	e8 39 00 00 00       	call   266 <matchhere>
 22d:	eb 35                	jmp    264 <match+0x5c>
  do{  // must look at empty string
    if(matchhere(re, text))
 22f:	8b 45 0c             	mov    0xc(%ebp),%eax
 232:	89 44 24 04          	mov    %eax,0x4(%esp)
 236:	8b 45 08             	mov    0x8(%ebp),%eax
 239:	89 04 24             	mov    %eax,(%esp)
 23c:	e8 25 00 00 00       	call   266 <matchhere>
 241:	85 c0                	test   %eax,%eax
 243:	74 07                	je     24c <match+0x44>
      return 1;
 245:	b8 01 00 00 00       	mov    $0x1,%eax
 24a:	eb 18                	jmp    264 <match+0x5c>
  }while(*text++ != '\0');
 24c:	8b 45 0c             	mov    0xc(%ebp),%eax
 24f:	0f b6 00             	movzbl (%eax),%eax
 252:	84 c0                	test   %al,%al
 254:	0f 95 c0             	setne  %al
 257:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 25b:	84 c0                	test   %al,%al
 25d:	75 d0                	jne    22f <match+0x27>
  return 0;
 25f:	b8 00 00 00 00       	mov    $0x0,%eax
}
 264:	c9                   	leave  
 265:	c3                   	ret    

00000266 <matchhere>:

// matchhere: search for re at beginning of text
int matchhere(char *re, char *text)
{
 266:	55                   	push   %ebp
 267:	89 e5                	mov    %esp,%ebp
 269:	83 ec 18             	sub    $0x18,%esp
  if(re[0] == '\0')
 26c:	8b 45 08             	mov    0x8(%ebp),%eax
 26f:	0f b6 00             	movzbl (%eax),%eax
 272:	84 c0                	test   %al,%al
 274:	75 0a                	jne    280 <matchhere+0x1a>
    return 1;
 276:	b8 01 00 00 00       	mov    $0x1,%eax
 27b:	e9 9b 00 00 00       	jmp    31b <matchhere+0xb5>
  if(re[1] == '*')
 280:	8b 45 08             	mov    0x8(%ebp),%eax
 283:	83 c0 01             	add    $0x1,%eax
 286:	0f b6 00             	movzbl (%eax),%eax
 289:	3c 2a                	cmp    $0x2a,%al
 28b:	75 24                	jne    2b1 <matchhere+0x4b>
    return matchstar(re[0], re+2, text);
 28d:	8b 45 08             	mov    0x8(%ebp),%eax
 290:	8d 48 02             	lea    0x2(%eax),%ecx
 293:	8b 45 08             	mov    0x8(%ebp),%eax
 296:	0f b6 00             	movzbl (%eax),%eax
 299:	0f be c0             	movsbl %al,%eax
 29c:	8b 55 0c             	mov    0xc(%ebp),%edx
 29f:	89 54 24 08          	mov    %edx,0x8(%esp)
 2a3:	89 4c 24 04          	mov    %ecx,0x4(%esp)
 2a7:	89 04 24             	mov    %eax,(%esp)
 2aa:	e8 6e 00 00 00       	call   31d <matchstar>
 2af:	eb 6a                	jmp    31b <matchhere+0xb5>
  if(re[0] == '$' && re[1] == '\0')
 2b1:	8b 45 08             	mov    0x8(%ebp),%eax
 2b4:	0f b6 00             	movzbl (%eax),%eax
 2b7:	3c 24                	cmp    $0x24,%al
 2b9:	75 1d                	jne    2d8 <matchhere+0x72>
 2bb:	8b 45 08             	mov    0x8(%ebp),%eax
 2be:	83 c0 01             	add    $0x1,%eax
 2c1:	0f b6 00             	movzbl (%eax),%eax
 2c4:	84 c0                	test   %al,%al
 2c6:	75 10                	jne    2d8 <matchhere+0x72>
    return *text == '\0';
 2c8:	8b 45 0c             	mov    0xc(%ebp),%eax
 2cb:	0f b6 00             	movzbl (%eax),%eax
 2ce:	84 c0                	test   %al,%al
 2d0:	0f 94 c0             	sete   %al
 2d3:	0f b6 c0             	movzbl %al,%eax
 2d6:	eb 43                	jmp    31b <matchhere+0xb5>
  if(*text!='\0' && (re[0]=='.' || re[0]==*text))
 2d8:	8b 45 0c             	mov    0xc(%ebp),%eax
 2db:	0f b6 00             	movzbl (%eax),%eax
 2de:	84 c0                	test   %al,%al
 2e0:	74 34                	je     316 <matchhere+0xb0>
 2e2:	8b 45 08             	mov    0x8(%ebp),%eax
 2e5:	0f b6 00             	movzbl (%eax),%eax
 2e8:	3c 2e                	cmp    $0x2e,%al
 2ea:	74 10                	je     2fc <matchhere+0x96>
 2ec:	8b 45 08             	mov    0x8(%ebp),%eax
 2ef:	0f b6 10             	movzbl (%eax),%edx
 2f2:	8b 45 0c             	mov    0xc(%ebp),%eax
 2f5:	0f b6 00             	movzbl (%eax),%eax
 2f8:	38 c2                	cmp    %al,%dl
 2fa:	75 1a                	jne    316 <matchhere+0xb0>
    return matchhere(re+1, text+1);
 2fc:	8b 45 0c             	mov    0xc(%ebp),%eax
 2ff:	8d 50 01             	lea    0x1(%eax),%edx
 302:	8b 45 08             	mov    0x8(%ebp),%eax
 305:	83 c0 01             	add    $0x1,%eax
 308:	89 54 24 04          	mov    %edx,0x4(%esp)
 30c:	89 04 24             	mov    %eax,(%esp)
 30f:	e8 52 ff ff ff       	call   266 <matchhere>
 314:	eb 05                	jmp    31b <matchhere+0xb5>
  return 0;
 316:	b8 00 00 00 00       	mov    $0x0,%eax
}
 31b:	c9                   	leave  
 31c:	c3                   	ret    

0000031d <matchstar>:

// matchstar: search for c*re at beginning of text
int matchstar(int c, char *re, char *text)
{
 31d:	55                   	push   %ebp
 31e:	89 e5                	mov    %esp,%ebp
 320:	83 ec 18             	sub    $0x18,%esp
  do{  // a * matches zero or more instances
    if(matchhere(re, text))
 323:	8b 45 10             	mov    0x10(%ebp),%eax
 326:	89 44 24 04          	mov    %eax,0x4(%esp)
 32a:	8b 45 0c             	mov    0xc(%ebp),%eax
 32d:	89 04 24             	mov    %eax,(%esp)
 330:	e8 31 ff ff ff       	call   266 <matchhere>
 335:	85 c0                	test   %eax,%eax
 337:	74 07                	je     340 <matchstar+0x23>
      return 1;
 339:	b8 01 00 00 00       	mov    $0x1,%eax
 33e:	eb 2c                	jmp    36c <matchstar+0x4f>
  }while(*text!='\0' && (*text++==c || c=='.'));
 340:	8b 45 10             	mov    0x10(%ebp),%eax
 343:	0f b6 00             	movzbl (%eax),%eax
 346:	84 c0                	test   %al,%al
 348:	74 1d                	je     367 <matchstar+0x4a>
 34a:	8b 45 10             	mov    0x10(%ebp),%eax
 34d:	0f b6 00             	movzbl (%eax),%eax
 350:	0f be c0             	movsbl %al,%eax
 353:	3b 45 08             	cmp    0x8(%ebp),%eax
 356:	0f 94 c0             	sete   %al
 359:	83 45 10 01          	addl   $0x1,0x10(%ebp)
 35d:	84 c0                	test   %al,%al
 35f:	75 c2                	jne    323 <matchstar+0x6>
 361:	83 7d 08 2e          	cmpl   $0x2e,0x8(%ebp)
 365:	74 bc                	je     323 <matchstar+0x6>
  return 0;
 367:	b8 00 00 00 00       	mov    $0x0,%eax
}
 36c:	c9                   	leave  
 36d:	c3                   	ret    
 36e:	90                   	nop
 36f:	90                   	nop

00000370 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 370:	55                   	push   %ebp
 371:	89 e5                	mov    %esp,%ebp
 373:	57                   	push   %edi
 374:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 375:	8b 4d 08             	mov    0x8(%ebp),%ecx
 378:	8b 55 10             	mov    0x10(%ebp),%edx
 37b:	8b 45 0c             	mov    0xc(%ebp),%eax
 37e:	89 cb                	mov    %ecx,%ebx
 380:	89 df                	mov    %ebx,%edi
 382:	89 d1                	mov    %edx,%ecx
 384:	fc                   	cld    
 385:	f3 aa                	rep stos %al,%es:(%edi)
 387:	89 ca                	mov    %ecx,%edx
 389:	89 fb                	mov    %edi,%ebx
 38b:	89 5d 08             	mov    %ebx,0x8(%ebp)
 38e:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 391:	5b                   	pop    %ebx
 392:	5f                   	pop    %edi
 393:	5d                   	pop    %ebp
 394:	c3                   	ret    

00000395 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 395:	55                   	push   %ebp
 396:	89 e5                	mov    %esp,%ebp
 398:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 39b:	8b 45 08             	mov    0x8(%ebp),%eax
 39e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 3a1:	90                   	nop
 3a2:	8b 45 0c             	mov    0xc(%ebp),%eax
 3a5:	0f b6 10             	movzbl (%eax),%edx
 3a8:	8b 45 08             	mov    0x8(%ebp),%eax
 3ab:	88 10                	mov    %dl,(%eax)
 3ad:	8b 45 08             	mov    0x8(%ebp),%eax
 3b0:	0f b6 00             	movzbl (%eax),%eax
 3b3:	84 c0                	test   %al,%al
 3b5:	0f 95 c0             	setne  %al
 3b8:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 3bc:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 3c0:	84 c0                	test   %al,%al
 3c2:	75 de                	jne    3a2 <strcpy+0xd>
    ;
  return os;
 3c4:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 3c7:	c9                   	leave  
 3c8:	c3                   	ret    

000003c9 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 3c9:	55                   	push   %ebp
 3ca:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 3cc:	eb 08                	jmp    3d6 <strcmp+0xd>
    p++, q++;
 3ce:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 3d2:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 3d6:	8b 45 08             	mov    0x8(%ebp),%eax
 3d9:	0f b6 00             	movzbl (%eax),%eax
 3dc:	84 c0                	test   %al,%al
 3de:	74 10                	je     3f0 <strcmp+0x27>
 3e0:	8b 45 08             	mov    0x8(%ebp),%eax
 3e3:	0f b6 10             	movzbl (%eax),%edx
 3e6:	8b 45 0c             	mov    0xc(%ebp),%eax
 3e9:	0f b6 00             	movzbl (%eax),%eax
 3ec:	38 c2                	cmp    %al,%dl
 3ee:	74 de                	je     3ce <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 3f0:	8b 45 08             	mov    0x8(%ebp),%eax
 3f3:	0f b6 00             	movzbl (%eax),%eax
 3f6:	0f b6 d0             	movzbl %al,%edx
 3f9:	8b 45 0c             	mov    0xc(%ebp),%eax
 3fc:	0f b6 00             	movzbl (%eax),%eax
 3ff:	0f b6 c0             	movzbl %al,%eax
 402:	89 d1                	mov    %edx,%ecx
 404:	29 c1                	sub    %eax,%ecx
 406:	89 c8                	mov    %ecx,%eax
}
 408:	5d                   	pop    %ebp
 409:	c3                   	ret    

0000040a <strlen>:

uint
strlen(char *s)
{
 40a:	55                   	push   %ebp
 40b:	89 e5                	mov    %esp,%ebp
 40d:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 410:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 417:	eb 04                	jmp    41d <strlen+0x13>
 419:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 41d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 420:	03 45 08             	add    0x8(%ebp),%eax
 423:	0f b6 00             	movzbl (%eax),%eax
 426:	84 c0                	test   %al,%al
 428:	75 ef                	jne    419 <strlen+0xf>
    ;
  return n;
 42a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 42d:	c9                   	leave  
 42e:	c3                   	ret    

0000042f <memset>:

void*
memset(void *dst, int c, uint n)
{
 42f:	55                   	push   %ebp
 430:	89 e5                	mov    %esp,%ebp
 432:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 435:	8b 45 10             	mov    0x10(%ebp),%eax
 438:	89 44 24 08          	mov    %eax,0x8(%esp)
 43c:	8b 45 0c             	mov    0xc(%ebp),%eax
 43f:	89 44 24 04          	mov    %eax,0x4(%esp)
 443:	8b 45 08             	mov    0x8(%ebp),%eax
 446:	89 04 24             	mov    %eax,(%esp)
 449:	e8 22 ff ff ff       	call   370 <stosb>
  return dst;
 44e:	8b 45 08             	mov    0x8(%ebp),%eax
}
 451:	c9                   	leave  
 452:	c3                   	ret    

00000453 <strchr>:

char*
strchr(const char *s, char c)
{
 453:	55                   	push   %ebp
 454:	89 e5                	mov    %esp,%ebp
 456:	83 ec 04             	sub    $0x4,%esp
 459:	8b 45 0c             	mov    0xc(%ebp),%eax
 45c:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 45f:	eb 14                	jmp    475 <strchr+0x22>
    if(*s == c)
 461:	8b 45 08             	mov    0x8(%ebp),%eax
 464:	0f b6 00             	movzbl (%eax),%eax
 467:	3a 45 fc             	cmp    -0x4(%ebp),%al
 46a:	75 05                	jne    471 <strchr+0x1e>
      return (char*)s;
 46c:	8b 45 08             	mov    0x8(%ebp),%eax
 46f:	eb 13                	jmp    484 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 471:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 475:	8b 45 08             	mov    0x8(%ebp),%eax
 478:	0f b6 00             	movzbl (%eax),%eax
 47b:	84 c0                	test   %al,%al
 47d:	75 e2                	jne    461 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 47f:	b8 00 00 00 00       	mov    $0x0,%eax
}
 484:	c9                   	leave  
 485:	c3                   	ret    

00000486 <gets>:

char*
gets(char *buf, int max)
{
 486:	55                   	push   %ebp
 487:	89 e5                	mov    %esp,%ebp
 489:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 48c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 493:	eb 44                	jmp    4d9 <gets+0x53>
    cc = read(0, &c, 1);
 495:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 49c:	00 
 49d:	8d 45 ef             	lea    -0x11(%ebp),%eax
 4a0:	89 44 24 04          	mov    %eax,0x4(%esp)
 4a4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 4ab:	e8 3c 01 00 00       	call   5ec <read>
 4b0:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 4b3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 4b7:	7e 2d                	jle    4e6 <gets+0x60>
      break;
    buf[i++] = c;
 4b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4bc:	03 45 08             	add    0x8(%ebp),%eax
 4bf:	0f b6 55 ef          	movzbl -0x11(%ebp),%edx
 4c3:	88 10                	mov    %dl,(%eax)
 4c5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(c == '\n' || c == '\r')
 4c9:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 4cd:	3c 0a                	cmp    $0xa,%al
 4cf:	74 16                	je     4e7 <gets+0x61>
 4d1:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 4d5:	3c 0d                	cmp    $0xd,%al
 4d7:	74 0e                	je     4e7 <gets+0x61>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 4d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4dc:	83 c0 01             	add    $0x1,%eax
 4df:	3b 45 0c             	cmp    0xc(%ebp),%eax
 4e2:	7c b1                	jl     495 <gets+0xf>
 4e4:	eb 01                	jmp    4e7 <gets+0x61>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 4e6:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 4e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4ea:	03 45 08             	add    0x8(%ebp),%eax
 4ed:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 4f0:	8b 45 08             	mov    0x8(%ebp),%eax
}
 4f3:	c9                   	leave  
 4f4:	c3                   	ret    

000004f5 <stat>:

int
stat(char *n, struct stat *st)
{
 4f5:	55                   	push   %ebp
 4f6:	89 e5                	mov    %esp,%ebp
 4f8:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 4fb:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 502:	00 
 503:	8b 45 08             	mov    0x8(%ebp),%eax
 506:	89 04 24             	mov    %eax,(%esp)
 509:	e8 06 01 00 00       	call   614 <open>
 50e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 511:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 515:	79 07                	jns    51e <stat+0x29>
    return -1;
 517:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 51c:	eb 23                	jmp    541 <stat+0x4c>
  r = fstat(fd, st);
 51e:	8b 45 0c             	mov    0xc(%ebp),%eax
 521:	89 44 24 04          	mov    %eax,0x4(%esp)
 525:	8b 45 f4             	mov    -0xc(%ebp),%eax
 528:	89 04 24             	mov    %eax,(%esp)
 52b:	e8 fc 00 00 00       	call   62c <fstat>
 530:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 533:	8b 45 f4             	mov    -0xc(%ebp),%eax
 536:	89 04 24             	mov    %eax,(%esp)
 539:	e8 be 00 00 00       	call   5fc <close>
  return r;
 53e:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 541:	c9                   	leave  
 542:	c3                   	ret    

00000543 <atoi>:

int
atoi(const char *s)
{
 543:	55                   	push   %ebp
 544:	89 e5                	mov    %esp,%ebp
 546:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 549:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 550:	eb 23                	jmp    575 <atoi+0x32>
    n = n*10 + *s++ - '0';
 552:	8b 55 fc             	mov    -0x4(%ebp),%edx
 555:	89 d0                	mov    %edx,%eax
 557:	c1 e0 02             	shl    $0x2,%eax
 55a:	01 d0                	add    %edx,%eax
 55c:	01 c0                	add    %eax,%eax
 55e:	89 c2                	mov    %eax,%edx
 560:	8b 45 08             	mov    0x8(%ebp),%eax
 563:	0f b6 00             	movzbl (%eax),%eax
 566:	0f be c0             	movsbl %al,%eax
 569:	01 d0                	add    %edx,%eax
 56b:	83 e8 30             	sub    $0x30,%eax
 56e:	89 45 fc             	mov    %eax,-0x4(%ebp)
 571:	83 45 08 01          	addl   $0x1,0x8(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 575:	8b 45 08             	mov    0x8(%ebp),%eax
 578:	0f b6 00             	movzbl (%eax),%eax
 57b:	3c 2f                	cmp    $0x2f,%al
 57d:	7e 0a                	jle    589 <atoi+0x46>
 57f:	8b 45 08             	mov    0x8(%ebp),%eax
 582:	0f b6 00             	movzbl (%eax),%eax
 585:	3c 39                	cmp    $0x39,%al
 587:	7e c9                	jle    552 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 589:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 58c:	c9                   	leave  
 58d:	c3                   	ret    

0000058e <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 58e:	55                   	push   %ebp
 58f:	89 e5                	mov    %esp,%ebp
 591:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 594:	8b 45 08             	mov    0x8(%ebp),%eax
 597:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 59a:	8b 45 0c             	mov    0xc(%ebp),%eax
 59d:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 5a0:	eb 13                	jmp    5b5 <memmove+0x27>
    *dst++ = *src++;
 5a2:	8b 45 f8             	mov    -0x8(%ebp),%eax
 5a5:	0f b6 10             	movzbl (%eax),%edx
 5a8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 5ab:	88 10                	mov    %dl,(%eax)
 5ad:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 5b1:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 5b5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 5b9:	0f 9f c0             	setg   %al
 5bc:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 5c0:	84 c0                	test   %al,%al
 5c2:	75 de                	jne    5a2 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 5c4:	8b 45 08             	mov    0x8(%ebp),%eax
}
 5c7:	c9                   	leave  
 5c8:	c3                   	ret    
 5c9:	90                   	nop
 5ca:	90                   	nop
 5cb:	90                   	nop

000005cc <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 5cc:	b8 01 00 00 00       	mov    $0x1,%eax
 5d1:	cd 40                	int    $0x40
 5d3:	c3                   	ret    

000005d4 <exit>:
SYSCALL(exit)
 5d4:	b8 02 00 00 00       	mov    $0x2,%eax
 5d9:	cd 40                	int    $0x40
 5db:	c3                   	ret    

000005dc <wait>:
SYSCALL(wait)
 5dc:	b8 03 00 00 00       	mov    $0x3,%eax
 5e1:	cd 40                	int    $0x40
 5e3:	c3                   	ret    

000005e4 <pipe>:
SYSCALL(pipe)
 5e4:	b8 04 00 00 00       	mov    $0x4,%eax
 5e9:	cd 40                	int    $0x40
 5eb:	c3                   	ret    

000005ec <read>:
SYSCALL(read)
 5ec:	b8 05 00 00 00       	mov    $0x5,%eax
 5f1:	cd 40                	int    $0x40
 5f3:	c3                   	ret    

000005f4 <write>:
SYSCALL(write)
 5f4:	b8 10 00 00 00       	mov    $0x10,%eax
 5f9:	cd 40                	int    $0x40
 5fb:	c3                   	ret    

000005fc <close>:
SYSCALL(close)
 5fc:	b8 15 00 00 00       	mov    $0x15,%eax
 601:	cd 40                	int    $0x40
 603:	c3                   	ret    

00000604 <kill>:
SYSCALL(kill)
 604:	b8 06 00 00 00       	mov    $0x6,%eax
 609:	cd 40                	int    $0x40
 60b:	c3                   	ret    

0000060c <exec>:
SYSCALL(exec)
 60c:	b8 07 00 00 00       	mov    $0x7,%eax
 611:	cd 40                	int    $0x40
 613:	c3                   	ret    

00000614 <open>:
SYSCALL(open)
 614:	b8 0f 00 00 00       	mov    $0xf,%eax
 619:	cd 40                	int    $0x40
 61b:	c3                   	ret    

0000061c <mknod>:
SYSCALL(mknod)
 61c:	b8 11 00 00 00       	mov    $0x11,%eax
 621:	cd 40                	int    $0x40
 623:	c3                   	ret    

00000624 <unlink>:
SYSCALL(unlink)
 624:	b8 12 00 00 00       	mov    $0x12,%eax
 629:	cd 40                	int    $0x40
 62b:	c3                   	ret    

0000062c <fstat>:
SYSCALL(fstat)
 62c:	b8 08 00 00 00       	mov    $0x8,%eax
 631:	cd 40                	int    $0x40
 633:	c3                   	ret    

00000634 <link>:
SYSCALL(link)
 634:	b8 13 00 00 00       	mov    $0x13,%eax
 639:	cd 40                	int    $0x40
 63b:	c3                   	ret    

0000063c <mkdir>:
SYSCALL(mkdir)
 63c:	b8 14 00 00 00       	mov    $0x14,%eax
 641:	cd 40                	int    $0x40
 643:	c3                   	ret    

00000644 <chdir>:
SYSCALL(chdir)
 644:	b8 09 00 00 00       	mov    $0x9,%eax
 649:	cd 40                	int    $0x40
 64b:	c3                   	ret    

0000064c <dup>:
SYSCALL(dup)
 64c:	b8 0a 00 00 00       	mov    $0xa,%eax
 651:	cd 40                	int    $0x40
 653:	c3                   	ret    

00000654 <getpid>:
SYSCALL(getpid)
 654:	b8 0b 00 00 00       	mov    $0xb,%eax
 659:	cd 40                	int    $0x40
 65b:	c3                   	ret    

0000065c <sbrk>:
SYSCALL(sbrk)
 65c:	b8 0c 00 00 00       	mov    $0xc,%eax
 661:	cd 40                	int    $0x40
 663:	c3                   	ret    

00000664 <sleep>:
SYSCALL(sleep)
 664:	b8 0d 00 00 00       	mov    $0xd,%eax
 669:	cd 40                	int    $0x40
 66b:	c3                   	ret    

0000066c <uptime>:
SYSCALL(uptime)
 66c:	b8 0e 00 00 00       	mov    $0xe,%eax
 671:	cd 40                	int    $0x40
 673:	c3                   	ret    

00000674 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 674:	55                   	push   %ebp
 675:	89 e5                	mov    %esp,%ebp
 677:	83 ec 28             	sub    $0x28,%esp
 67a:	8b 45 0c             	mov    0xc(%ebp),%eax
 67d:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 680:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 687:	00 
 688:	8d 45 f4             	lea    -0xc(%ebp),%eax
 68b:	89 44 24 04          	mov    %eax,0x4(%esp)
 68f:	8b 45 08             	mov    0x8(%ebp),%eax
 692:	89 04 24             	mov    %eax,(%esp)
 695:	e8 5a ff ff ff       	call   5f4 <write>
}
 69a:	c9                   	leave  
 69b:	c3                   	ret    

0000069c <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 69c:	55                   	push   %ebp
 69d:	89 e5                	mov    %esp,%ebp
 69f:	83 ec 48             	sub    $0x48,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 6a2:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 6a9:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 6ad:	74 17                	je     6c6 <printint+0x2a>
 6af:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 6b3:	79 11                	jns    6c6 <printint+0x2a>
    neg = 1;
 6b5:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 6bc:	8b 45 0c             	mov    0xc(%ebp),%eax
 6bf:	f7 d8                	neg    %eax
 6c1:	89 45 ec             	mov    %eax,-0x14(%ebp)
 6c4:	eb 06                	jmp    6cc <printint+0x30>
  } else {
    x = xx;
 6c6:	8b 45 0c             	mov    0xc(%ebp),%eax
 6c9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 6cc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 6d3:	8b 4d 10             	mov    0x10(%ebp),%ecx
 6d6:	8b 45 ec             	mov    -0x14(%ebp),%eax
 6d9:	ba 00 00 00 00       	mov    $0x0,%edx
 6de:	f7 f1                	div    %ecx
 6e0:	89 d0                	mov    %edx,%eax
 6e2:	0f b6 90 0c 0e 00 00 	movzbl 0xe0c(%eax),%edx
 6e9:	8d 45 dc             	lea    -0x24(%ebp),%eax
 6ec:	03 45 f4             	add    -0xc(%ebp),%eax
 6ef:	88 10                	mov    %dl,(%eax)
 6f1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  }while((x /= base) != 0);
 6f5:	8b 55 10             	mov    0x10(%ebp),%edx
 6f8:	89 55 d4             	mov    %edx,-0x2c(%ebp)
 6fb:	8b 45 ec             	mov    -0x14(%ebp),%eax
 6fe:	ba 00 00 00 00       	mov    $0x0,%edx
 703:	f7 75 d4             	divl   -0x2c(%ebp)
 706:	89 45 ec             	mov    %eax,-0x14(%ebp)
 709:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 70d:	75 c4                	jne    6d3 <printint+0x37>
  if(neg)
 70f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 713:	74 2a                	je     73f <printint+0xa3>
    buf[i++] = '-';
 715:	8d 45 dc             	lea    -0x24(%ebp),%eax
 718:	03 45 f4             	add    -0xc(%ebp),%eax
 71b:	c6 00 2d             	movb   $0x2d,(%eax)
 71e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

  while(--i >= 0)
 722:	eb 1b                	jmp    73f <printint+0xa3>
    putc(fd, buf[i]);
 724:	8d 45 dc             	lea    -0x24(%ebp),%eax
 727:	03 45 f4             	add    -0xc(%ebp),%eax
 72a:	0f b6 00             	movzbl (%eax),%eax
 72d:	0f be c0             	movsbl %al,%eax
 730:	89 44 24 04          	mov    %eax,0x4(%esp)
 734:	8b 45 08             	mov    0x8(%ebp),%eax
 737:	89 04 24             	mov    %eax,(%esp)
 73a:	e8 35 ff ff ff       	call   674 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 73f:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 743:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 747:	79 db                	jns    724 <printint+0x88>
    putc(fd, buf[i]);
}
 749:	c9                   	leave  
 74a:	c3                   	ret    

0000074b <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 74b:	55                   	push   %ebp
 74c:	89 e5                	mov    %esp,%ebp
 74e:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 751:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 758:	8d 45 0c             	lea    0xc(%ebp),%eax
 75b:	83 c0 04             	add    $0x4,%eax
 75e:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 761:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 768:	e9 7d 01 00 00       	jmp    8ea <printf+0x19f>
    c = fmt[i] & 0xff;
 76d:	8b 55 0c             	mov    0xc(%ebp),%edx
 770:	8b 45 f0             	mov    -0x10(%ebp),%eax
 773:	01 d0                	add    %edx,%eax
 775:	0f b6 00             	movzbl (%eax),%eax
 778:	0f be c0             	movsbl %al,%eax
 77b:	25 ff 00 00 00       	and    $0xff,%eax
 780:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 783:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 787:	75 2c                	jne    7b5 <printf+0x6a>
      if(c == '%'){
 789:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 78d:	75 0c                	jne    79b <printf+0x50>
        state = '%';
 78f:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 796:	e9 4b 01 00 00       	jmp    8e6 <printf+0x19b>
      } else {
        putc(fd, c);
 79b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 79e:	0f be c0             	movsbl %al,%eax
 7a1:	89 44 24 04          	mov    %eax,0x4(%esp)
 7a5:	8b 45 08             	mov    0x8(%ebp),%eax
 7a8:	89 04 24             	mov    %eax,(%esp)
 7ab:	e8 c4 fe ff ff       	call   674 <putc>
 7b0:	e9 31 01 00 00       	jmp    8e6 <printf+0x19b>
      }
    } else if(state == '%'){
 7b5:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 7b9:	0f 85 27 01 00 00    	jne    8e6 <printf+0x19b>
      if(c == 'd'){
 7bf:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 7c3:	75 2d                	jne    7f2 <printf+0xa7>
        printint(fd, *ap, 10, 1);
 7c5:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7c8:	8b 00                	mov    (%eax),%eax
 7ca:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 7d1:	00 
 7d2:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 7d9:	00 
 7da:	89 44 24 04          	mov    %eax,0x4(%esp)
 7de:	8b 45 08             	mov    0x8(%ebp),%eax
 7e1:	89 04 24             	mov    %eax,(%esp)
 7e4:	e8 b3 fe ff ff       	call   69c <printint>
        ap++;
 7e9:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 7ed:	e9 ed 00 00 00       	jmp    8df <printf+0x194>
      } else if(c == 'x' || c == 'p'){
 7f2:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 7f6:	74 06                	je     7fe <printf+0xb3>
 7f8:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 7fc:	75 2d                	jne    82b <printf+0xe0>
        printint(fd, *ap, 16, 0);
 7fe:	8b 45 e8             	mov    -0x18(%ebp),%eax
 801:	8b 00                	mov    (%eax),%eax
 803:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 80a:	00 
 80b:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 812:	00 
 813:	89 44 24 04          	mov    %eax,0x4(%esp)
 817:	8b 45 08             	mov    0x8(%ebp),%eax
 81a:	89 04 24             	mov    %eax,(%esp)
 81d:	e8 7a fe ff ff       	call   69c <printint>
        ap++;
 822:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 826:	e9 b4 00 00 00       	jmp    8df <printf+0x194>
      } else if(c == 's'){
 82b:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 82f:	75 46                	jne    877 <printf+0x12c>
        s = (char*)*ap;
 831:	8b 45 e8             	mov    -0x18(%ebp),%eax
 834:	8b 00                	mov    (%eax),%eax
 836:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 839:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 83d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 841:	75 27                	jne    86a <printf+0x11f>
          s = "(null)";
 843:	c7 45 f4 46 0b 00 00 	movl   $0xb46,-0xc(%ebp)
        while(*s != 0){
 84a:	eb 1e                	jmp    86a <printf+0x11f>
          putc(fd, *s);
 84c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 84f:	0f b6 00             	movzbl (%eax),%eax
 852:	0f be c0             	movsbl %al,%eax
 855:	89 44 24 04          	mov    %eax,0x4(%esp)
 859:	8b 45 08             	mov    0x8(%ebp),%eax
 85c:	89 04 24             	mov    %eax,(%esp)
 85f:	e8 10 fe ff ff       	call   674 <putc>
          s++;
 864:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 868:	eb 01                	jmp    86b <printf+0x120>
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 86a:	90                   	nop
 86b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 86e:	0f b6 00             	movzbl (%eax),%eax
 871:	84 c0                	test   %al,%al
 873:	75 d7                	jne    84c <printf+0x101>
 875:	eb 68                	jmp    8df <printf+0x194>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 877:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 87b:	75 1d                	jne    89a <printf+0x14f>
        putc(fd, *ap);
 87d:	8b 45 e8             	mov    -0x18(%ebp),%eax
 880:	8b 00                	mov    (%eax),%eax
 882:	0f be c0             	movsbl %al,%eax
 885:	89 44 24 04          	mov    %eax,0x4(%esp)
 889:	8b 45 08             	mov    0x8(%ebp),%eax
 88c:	89 04 24             	mov    %eax,(%esp)
 88f:	e8 e0 fd ff ff       	call   674 <putc>
        ap++;
 894:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 898:	eb 45                	jmp    8df <printf+0x194>
      } else if(c == '%'){
 89a:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 89e:	75 17                	jne    8b7 <printf+0x16c>
        putc(fd, c);
 8a0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 8a3:	0f be c0             	movsbl %al,%eax
 8a6:	89 44 24 04          	mov    %eax,0x4(%esp)
 8aa:	8b 45 08             	mov    0x8(%ebp),%eax
 8ad:	89 04 24             	mov    %eax,(%esp)
 8b0:	e8 bf fd ff ff       	call   674 <putc>
 8b5:	eb 28                	jmp    8df <printf+0x194>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 8b7:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 8be:	00 
 8bf:	8b 45 08             	mov    0x8(%ebp),%eax
 8c2:	89 04 24             	mov    %eax,(%esp)
 8c5:	e8 aa fd ff ff       	call   674 <putc>
        putc(fd, c);
 8ca:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 8cd:	0f be c0             	movsbl %al,%eax
 8d0:	89 44 24 04          	mov    %eax,0x4(%esp)
 8d4:	8b 45 08             	mov    0x8(%ebp),%eax
 8d7:	89 04 24             	mov    %eax,(%esp)
 8da:	e8 95 fd ff ff       	call   674 <putc>
      }
      state = 0;
 8df:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 8e6:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 8ea:	8b 55 0c             	mov    0xc(%ebp),%edx
 8ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8f0:	01 d0                	add    %edx,%eax
 8f2:	0f b6 00             	movzbl (%eax),%eax
 8f5:	84 c0                	test   %al,%al
 8f7:	0f 85 70 fe ff ff    	jne    76d <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 8fd:	c9                   	leave  
 8fe:	c3                   	ret    
 8ff:	90                   	nop

00000900 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 900:	55                   	push   %ebp
 901:	89 e5                	mov    %esp,%ebp
 903:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 906:	8b 45 08             	mov    0x8(%ebp),%eax
 909:	83 e8 08             	sub    $0x8,%eax
 90c:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 90f:	a1 28 0e 00 00       	mov    0xe28,%eax
 914:	89 45 fc             	mov    %eax,-0x4(%ebp)
 917:	eb 24                	jmp    93d <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 919:	8b 45 fc             	mov    -0x4(%ebp),%eax
 91c:	8b 00                	mov    (%eax),%eax
 91e:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 921:	77 12                	ja     935 <free+0x35>
 923:	8b 45 f8             	mov    -0x8(%ebp),%eax
 926:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 929:	77 24                	ja     94f <free+0x4f>
 92b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 92e:	8b 00                	mov    (%eax),%eax
 930:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 933:	77 1a                	ja     94f <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 935:	8b 45 fc             	mov    -0x4(%ebp),%eax
 938:	8b 00                	mov    (%eax),%eax
 93a:	89 45 fc             	mov    %eax,-0x4(%ebp)
 93d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 940:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 943:	76 d4                	jbe    919 <free+0x19>
 945:	8b 45 fc             	mov    -0x4(%ebp),%eax
 948:	8b 00                	mov    (%eax),%eax
 94a:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 94d:	76 ca                	jbe    919 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 94f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 952:	8b 40 04             	mov    0x4(%eax),%eax
 955:	c1 e0 03             	shl    $0x3,%eax
 958:	89 c2                	mov    %eax,%edx
 95a:	03 55 f8             	add    -0x8(%ebp),%edx
 95d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 960:	8b 00                	mov    (%eax),%eax
 962:	39 c2                	cmp    %eax,%edx
 964:	75 24                	jne    98a <free+0x8a>
    bp->s.size += p->s.ptr->s.size;
 966:	8b 45 f8             	mov    -0x8(%ebp),%eax
 969:	8b 50 04             	mov    0x4(%eax),%edx
 96c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 96f:	8b 00                	mov    (%eax),%eax
 971:	8b 40 04             	mov    0x4(%eax),%eax
 974:	01 c2                	add    %eax,%edx
 976:	8b 45 f8             	mov    -0x8(%ebp),%eax
 979:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 97c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 97f:	8b 00                	mov    (%eax),%eax
 981:	8b 10                	mov    (%eax),%edx
 983:	8b 45 f8             	mov    -0x8(%ebp),%eax
 986:	89 10                	mov    %edx,(%eax)
 988:	eb 0a                	jmp    994 <free+0x94>
  } else
    bp->s.ptr = p->s.ptr;
 98a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 98d:	8b 10                	mov    (%eax),%edx
 98f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 992:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 994:	8b 45 fc             	mov    -0x4(%ebp),%eax
 997:	8b 40 04             	mov    0x4(%eax),%eax
 99a:	c1 e0 03             	shl    $0x3,%eax
 99d:	03 45 fc             	add    -0x4(%ebp),%eax
 9a0:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 9a3:	75 20                	jne    9c5 <free+0xc5>
    p->s.size += bp->s.size;
 9a5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9a8:	8b 50 04             	mov    0x4(%eax),%edx
 9ab:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9ae:	8b 40 04             	mov    0x4(%eax),%eax
 9b1:	01 c2                	add    %eax,%edx
 9b3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9b6:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 9b9:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9bc:	8b 10                	mov    (%eax),%edx
 9be:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9c1:	89 10                	mov    %edx,(%eax)
 9c3:	eb 08                	jmp    9cd <free+0xcd>
  } else
    p->s.ptr = bp;
 9c5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9c8:	8b 55 f8             	mov    -0x8(%ebp),%edx
 9cb:	89 10                	mov    %edx,(%eax)
  freep = p;
 9cd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9d0:	a3 28 0e 00 00       	mov    %eax,0xe28
}
 9d5:	c9                   	leave  
 9d6:	c3                   	ret    

000009d7 <morecore>:

static Header*
morecore(uint nu)
{
 9d7:	55                   	push   %ebp
 9d8:	89 e5                	mov    %esp,%ebp
 9da:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 9dd:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 9e4:	77 07                	ja     9ed <morecore+0x16>
    nu = 4096;
 9e6:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 9ed:	8b 45 08             	mov    0x8(%ebp),%eax
 9f0:	c1 e0 03             	shl    $0x3,%eax
 9f3:	89 04 24             	mov    %eax,(%esp)
 9f6:	e8 61 fc ff ff       	call   65c <sbrk>
 9fb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 9fe:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 a02:	75 07                	jne    a0b <morecore+0x34>
    return 0;
 a04:	b8 00 00 00 00       	mov    $0x0,%eax
 a09:	eb 22                	jmp    a2d <morecore+0x56>
  hp = (Header*)p;
 a0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a0e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 a11:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a14:	8b 55 08             	mov    0x8(%ebp),%edx
 a17:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 a1a:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a1d:	83 c0 08             	add    $0x8,%eax
 a20:	89 04 24             	mov    %eax,(%esp)
 a23:	e8 d8 fe ff ff       	call   900 <free>
  return freep;
 a28:	a1 28 0e 00 00       	mov    0xe28,%eax
}
 a2d:	c9                   	leave  
 a2e:	c3                   	ret    

00000a2f <malloc>:

void*
malloc(uint nbytes)
{
 a2f:	55                   	push   %ebp
 a30:	89 e5                	mov    %esp,%ebp
 a32:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 a35:	8b 45 08             	mov    0x8(%ebp),%eax
 a38:	83 c0 07             	add    $0x7,%eax
 a3b:	c1 e8 03             	shr    $0x3,%eax
 a3e:	83 c0 01             	add    $0x1,%eax
 a41:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 a44:	a1 28 0e 00 00       	mov    0xe28,%eax
 a49:	89 45 f0             	mov    %eax,-0x10(%ebp)
 a4c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 a50:	75 23                	jne    a75 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 a52:	c7 45 f0 20 0e 00 00 	movl   $0xe20,-0x10(%ebp)
 a59:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a5c:	a3 28 0e 00 00       	mov    %eax,0xe28
 a61:	a1 28 0e 00 00       	mov    0xe28,%eax
 a66:	a3 20 0e 00 00       	mov    %eax,0xe20
    base.s.size = 0;
 a6b:	c7 05 24 0e 00 00 00 	movl   $0x0,0xe24
 a72:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a75:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a78:	8b 00                	mov    (%eax),%eax
 a7a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 a7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a80:	8b 40 04             	mov    0x4(%eax),%eax
 a83:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 a86:	72 4d                	jb     ad5 <malloc+0xa6>
      if(p->s.size == nunits)
 a88:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a8b:	8b 40 04             	mov    0x4(%eax),%eax
 a8e:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 a91:	75 0c                	jne    a9f <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 a93:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a96:	8b 10                	mov    (%eax),%edx
 a98:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a9b:	89 10                	mov    %edx,(%eax)
 a9d:	eb 26                	jmp    ac5 <malloc+0x96>
      else {
        p->s.size -= nunits;
 a9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 aa2:	8b 40 04             	mov    0x4(%eax),%eax
 aa5:	89 c2                	mov    %eax,%edx
 aa7:	2b 55 ec             	sub    -0x14(%ebp),%edx
 aaa:	8b 45 f4             	mov    -0xc(%ebp),%eax
 aad:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 ab0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ab3:	8b 40 04             	mov    0x4(%eax),%eax
 ab6:	c1 e0 03             	shl    $0x3,%eax
 ab9:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 abc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 abf:	8b 55 ec             	mov    -0x14(%ebp),%edx
 ac2:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 ac5:	8b 45 f0             	mov    -0x10(%ebp),%eax
 ac8:	a3 28 0e 00 00       	mov    %eax,0xe28
      return (void*)(p + 1);
 acd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ad0:	83 c0 08             	add    $0x8,%eax
 ad3:	eb 38                	jmp    b0d <malloc+0xde>
    }
    if(p == freep)
 ad5:	a1 28 0e 00 00       	mov    0xe28,%eax
 ada:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 add:	75 1b                	jne    afa <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 adf:	8b 45 ec             	mov    -0x14(%ebp),%eax
 ae2:	89 04 24             	mov    %eax,(%esp)
 ae5:	e8 ed fe ff ff       	call   9d7 <morecore>
 aea:	89 45 f4             	mov    %eax,-0xc(%ebp)
 aed:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 af1:	75 07                	jne    afa <malloc+0xcb>
        return 0;
 af3:	b8 00 00 00 00       	mov    $0x0,%eax
 af8:	eb 13                	jmp    b0d <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 afa:	8b 45 f4             	mov    -0xc(%ebp),%eax
 afd:	89 45 f0             	mov    %eax,-0x10(%ebp)
 b00:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b03:	8b 00                	mov    (%eax),%eax
 b05:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 b08:	e9 70 ff ff ff       	jmp    a7d <malloc+0x4e>
}
 b0d:	c9                   	leave  
 b0e:	c3                   	ret    
