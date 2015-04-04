
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
  18:	c7 45 f0 60 0e 00 00 	movl   $0xe60,-0x10(%ebp)
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
  90:	81 7d f0 60 0e 00 00 	cmpl   $0xe60,-0x10(%ebp)
  97:	75 07                	jne    a0 <grep+0xa0>
      m = 0;
  99:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(m > 0){
  a0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  a4:	7e 2b                	jle    d1 <grep+0xd1>
      m -= p - buf;
  a6:	ba 60 0e 00 00       	mov    $0xe60,%edx
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
  c5:	c7 04 24 60 0e 00 00 	movl   $0xe60,(%esp)
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
  e2:	81 c2 60 0e 00 00    	add    $0xe60,%edx
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
 119:	c7 44 24 04 28 0b 00 	movl   $0xb28,0x4(%esp)
 120:	00 
 121:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
 128:	e8 36 06 00 00       	call   763 <printf>
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
 1aa:	c7 44 24 04 48 0b 00 	movl   $0xb48,0x4(%esp)
 1b1:	00 
 1b2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 1b9:	e8 a5 05 00 00       	call   763 <printf>
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

00000674 <waitpid>:
SYSCALL(waitpid)
 674:	b8 16 00 00 00       	mov    $0x16,%eax
 679:	cd 40                	int    $0x40
 67b:	c3                   	ret    

0000067c <wait_stat>:
SYSCALL(wait_stat)
 67c:	b8 17 00 00 00       	mov    $0x17,%eax
 681:	cd 40                	int    $0x40
 683:	c3                   	ret    

00000684 <list_pgroup>:
SYSCALL(list_pgroup)
 684:	b8 18 00 00 00       	mov    $0x18,%eax
 689:	cd 40                	int    $0x40
 68b:	c3                   	ret    

0000068c <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 68c:	55                   	push   %ebp
 68d:	89 e5                	mov    %esp,%ebp
 68f:	83 ec 28             	sub    $0x28,%esp
 692:	8b 45 0c             	mov    0xc(%ebp),%eax
 695:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 698:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 69f:	00 
 6a0:	8d 45 f4             	lea    -0xc(%ebp),%eax
 6a3:	89 44 24 04          	mov    %eax,0x4(%esp)
 6a7:	8b 45 08             	mov    0x8(%ebp),%eax
 6aa:	89 04 24             	mov    %eax,(%esp)
 6ad:	e8 42 ff ff ff       	call   5f4 <write>
}
 6b2:	c9                   	leave  
 6b3:	c3                   	ret    

000006b4 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 6b4:	55                   	push   %ebp
 6b5:	89 e5                	mov    %esp,%ebp
 6b7:	83 ec 48             	sub    $0x48,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 6ba:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 6c1:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 6c5:	74 17                	je     6de <printint+0x2a>
 6c7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 6cb:	79 11                	jns    6de <printint+0x2a>
    neg = 1;
 6cd:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 6d4:	8b 45 0c             	mov    0xc(%ebp),%eax
 6d7:	f7 d8                	neg    %eax
 6d9:	89 45 ec             	mov    %eax,-0x14(%ebp)
 6dc:	eb 06                	jmp    6e4 <printint+0x30>
  } else {
    x = xx;
 6de:	8b 45 0c             	mov    0xc(%ebp),%eax
 6e1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 6e4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 6eb:	8b 4d 10             	mov    0x10(%ebp),%ecx
 6ee:	8b 45 ec             	mov    -0x14(%ebp),%eax
 6f1:	ba 00 00 00 00       	mov    $0x0,%edx
 6f6:	f7 f1                	div    %ecx
 6f8:	89 d0                	mov    %edx,%eax
 6fa:	0f b6 90 24 0e 00 00 	movzbl 0xe24(%eax),%edx
 701:	8d 45 dc             	lea    -0x24(%ebp),%eax
 704:	03 45 f4             	add    -0xc(%ebp),%eax
 707:	88 10                	mov    %dl,(%eax)
 709:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  }while((x /= base) != 0);
 70d:	8b 55 10             	mov    0x10(%ebp),%edx
 710:	89 55 d4             	mov    %edx,-0x2c(%ebp)
 713:	8b 45 ec             	mov    -0x14(%ebp),%eax
 716:	ba 00 00 00 00       	mov    $0x0,%edx
 71b:	f7 75 d4             	divl   -0x2c(%ebp)
 71e:	89 45 ec             	mov    %eax,-0x14(%ebp)
 721:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 725:	75 c4                	jne    6eb <printint+0x37>
  if(neg)
 727:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 72b:	74 2a                	je     757 <printint+0xa3>
    buf[i++] = '-';
 72d:	8d 45 dc             	lea    -0x24(%ebp),%eax
 730:	03 45 f4             	add    -0xc(%ebp),%eax
 733:	c6 00 2d             	movb   $0x2d,(%eax)
 736:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

  while(--i >= 0)
 73a:	eb 1b                	jmp    757 <printint+0xa3>
    putc(fd, buf[i]);
 73c:	8d 45 dc             	lea    -0x24(%ebp),%eax
 73f:	03 45 f4             	add    -0xc(%ebp),%eax
 742:	0f b6 00             	movzbl (%eax),%eax
 745:	0f be c0             	movsbl %al,%eax
 748:	89 44 24 04          	mov    %eax,0x4(%esp)
 74c:	8b 45 08             	mov    0x8(%ebp),%eax
 74f:	89 04 24             	mov    %eax,(%esp)
 752:	e8 35 ff ff ff       	call   68c <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 757:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 75b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 75f:	79 db                	jns    73c <printint+0x88>
    putc(fd, buf[i]);
}
 761:	c9                   	leave  
 762:	c3                   	ret    

00000763 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 763:	55                   	push   %ebp
 764:	89 e5                	mov    %esp,%ebp
 766:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 769:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 770:	8d 45 0c             	lea    0xc(%ebp),%eax
 773:	83 c0 04             	add    $0x4,%eax
 776:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 779:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 780:	e9 7d 01 00 00       	jmp    902 <printf+0x19f>
    c = fmt[i] & 0xff;
 785:	8b 55 0c             	mov    0xc(%ebp),%edx
 788:	8b 45 f0             	mov    -0x10(%ebp),%eax
 78b:	01 d0                	add    %edx,%eax
 78d:	0f b6 00             	movzbl (%eax),%eax
 790:	0f be c0             	movsbl %al,%eax
 793:	25 ff 00 00 00       	and    $0xff,%eax
 798:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 79b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 79f:	75 2c                	jne    7cd <printf+0x6a>
      if(c == '%'){
 7a1:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 7a5:	75 0c                	jne    7b3 <printf+0x50>
        state = '%';
 7a7:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 7ae:	e9 4b 01 00 00       	jmp    8fe <printf+0x19b>
      } else {
        putc(fd, c);
 7b3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 7b6:	0f be c0             	movsbl %al,%eax
 7b9:	89 44 24 04          	mov    %eax,0x4(%esp)
 7bd:	8b 45 08             	mov    0x8(%ebp),%eax
 7c0:	89 04 24             	mov    %eax,(%esp)
 7c3:	e8 c4 fe ff ff       	call   68c <putc>
 7c8:	e9 31 01 00 00       	jmp    8fe <printf+0x19b>
      }
    } else if(state == '%'){
 7cd:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 7d1:	0f 85 27 01 00 00    	jne    8fe <printf+0x19b>
      if(c == 'd'){
 7d7:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 7db:	75 2d                	jne    80a <printf+0xa7>
        printint(fd, *ap, 10, 1);
 7dd:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7e0:	8b 00                	mov    (%eax),%eax
 7e2:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 7e9:	00 
 7ea:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 7f1:	00 
 7f2:	89 44 24 04          	mov    %eax,0x4(%esp)
 7f6:	8b 45 08             	mov    0x8(%ebp),%eax
 7f9:	89 04 24             	mov    %eax,(%esp)
 7fc:	e8 b3 fe ff ff       	call   6b4 <printint>
        ap++;
 801:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 805:	e9 ed 00 00 00       	jmp    8f7 <printf+0x194>
      } else if(c == 'x' || c == 'p'){
 80a:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 80e:	74 06                	je     816 <printf+0xb3>
 810:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 814:	75 2d                	jne    843 <printf+0xe0>
        printint(fd, *ap, 16, 0);
 816:	8b 45 e8             	mov    -0x18(%ebp),%eax
 819:	8b 00                	mov    (%eax),%eax
 81b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 822:	00 
 823:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 82a:	00 
 82b:	89 44 24 04          	mov    %eax,0x4(%esp)
 82f:	8b 45 08             	mov    0x8(%ebp),%eax
 832:	89 04 24             	mov    %eax,(%esp)
 835:	e8 7a fe ff ff       	call   6b4 <printint>
        ap++;
 83a:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 83e:	e9 b4 00 00 00       	jmp    8f7 <printf+0x194>
      } else if(c == 's'){
 843:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 847:	75 46                	jne    88f <printf+0x12c>
        s = (char*)*ap;
 849:	8b 45 e8             	mov    -0x18(%ebp),%eax
 84c:	8b 00                	mov    (%eax),%eax
 84e:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 851:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 855:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 859:	75 27                	jne    882 <printf+0x11f>
          s = "(null)";
 85b:	c7 45 f4 5e 0b 00 00 	movl   $0xb5e,-0xc(%ebp)
        while(*s != 0){
 862:	eb 1e                	jmp    882 <printf+0x11f>
          putc(fd, *s);
 864:	8b 45 f4             	mov    -0xc(%ebp),%eax
 867:	0f b6 00             	movzbl (%eax),%eax
 86a:	0f be c0             	movsbl %al,%eax
 86d:	89 44 24 04          	mov    %eax,0x4(%esp)
 871:	8b 45 08             	mov    0x8(%ebp),%eax
 874:	89 04 24             	mov    %eax,(%esp)
 877:	e8 10 fe ff ff       	call   68c <putc>
          s++;
 87c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 880:	eb 01                	jmp    883 <printf+0x120>
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 882:	90                   	nop
 883:	8b 45 f4             	mov    -0xc(%ebp),%eax
 886:	0f b6 00             	movzbl (%eax),%eax
 889:	84 c0                	test   %al,%al
 88b:	75 d7                	jne    864 <printf+0x101>
 88d:	eb 68                	jmp    8f7 <printf+0x194>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 88f:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 893:	75 1d                	jne    8b2 <printf+0x14f>
        putc(fd, *ap);
 895:	8b 45 e8             	mov    -0x18(%ebp),%eax
 898:	8b 00                	mov    (%eax),%eax
 89a:	0f be c0             	movsbl %al,%eax
 89d:	89 44 24 04          	mov    %eax,0x4(%esp)
 8a1:	8b 45 08             	mov    0x8(%ebp),%eax
 8a4:	89 04 24             	mov    %eax,(%esp)
 8a7:	e8 e0 fd ff ff       	call   68c <putc>
        ap++;
 8ac:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 8b0:	eb 45                	jmp    8f7 <printf+0x194>
      } else if(c == '%'){
 8b2:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 8b6:	75 17                	jne    8cf <printf+0x16c>
        putc(fd, c);
 8b8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 8bb:	0f be c0             	movsbl %al,%eax
 8be:	89 44 24 04          	mov    %eax,0x4(%esp)
 8c2:	8b 45 08             	mov    0x8(%ebp),%eax
 8c5:	89 04 24             	mov    %eax,(%esp)
 8c8:	e8 bf fd ff ff       	call   68c <putc>
 8cd:	eb 28                	jmp    8f7 <printf+0x194>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 8cf:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 8d6:	00 
 8d7:	8b 45 08             	mov    0x8(%ebp),%eax
 8da:	89 04 24             	mov    %eax,(%esp)
 8dd:	e8 aa fd ff ff       	call   68c <putc>
        putc(fd, c);
 8e2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 8e5:	0f be c0             	movsbl %al,%eax
 8e8:	89 44 24 04          	mov    %eax,0x4(%esp)
 8ec:	8b 45 08             	mov    0x8(%ebp),%eax
 8ef:	89 04 24             	mov    %eax,(%esp)
 8f2:	e8 95 fd ff ff       	call   68c <putc>
      }
      state = 0;
 8f7:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 8fe:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 902:	8b 55 0c             	mov    0xc(%ebp),%edx
 905:	8b 45 f0             	mov    -0x10(%ebp),%eax
 908:	01 d0                	add    %edx,%eax
 90a:	0f b6 00             	movzbl (%eax),%eax
 90d:	84 c0                	test   %al,%al
 90f:	0f 85 70 fe ff ff    	jne    785 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 915:	c9                   	leave  
 916:	c3                   	ret    
 917:	90                   	nop

00000918 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 918:	55                   	push   %ebp
 919:	89 e5                	mov    %esp,%ebp
 91b:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 91e:	8b 45 08             	mov    0x8(%ebp),%eax
 921:	83 e8 08             	sub    $0x8,%eax
 924:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 927:	a1 48 0e 00 00       	mov    0xe48,%eax
 92c:	89 45 fc             	mov    %eax,-0x4(%ebp)
 92f:	eb 24                	jmp    955 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 931:	8b 45 fc             	mov    -0x4(%ebp),%eax
 934:	8b 00                	mov    (%eax),%eax
 936:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 939:	77 12                	ja     94d <free+0x35>
 93b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 93e:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 941:	77 24                	ja     967 <free+0x4f>
 943:	8b 45 fc             	mov    -0x4(%ebp),%eax
 946:	8b 00                	mov    (%eax),%eax
 948:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 94b:	77 1a                	ja     967 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 94d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 950:	8b 00                	mov    (%eax),%eax
 952:	89 45 fc             	mov    %eax,-0x4(%ebp)
 955:	8b 45 f8             	mov    -0x8(%ebp),%eax
 958:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 95b:	76 d4                	jbe    931 <free+0x19>
 95d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 960:	8b 00                	mov    (%eax),%eax
 962:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 965:	76 ca                	jbe    931 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 967:	8b 45 f8             	mov    -0x8(%ebp),%eax
 96a:	8b 40 04             	mov    0x4(%eax),%eax
 96d:	c1 e0 03             	shl    $0x3,%eax
 970:	89 c2                	mov    %eax,%edx
 972:	03 55 f8             	add    -0x8(%ebp),%edx
 975:	8b 45 fc             	mov    -0x4(%ebp),%eax
 978:	8b 00                	mov    (%eax),%eax
 97a:	39 c2                	cmp    %eax,%edx
 97c:	75 24                	jne    9a2 <free+0x8a>
    bp->s.size += p->s.ptr->s.size;
 97e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 981:	8b 50 04             	mov    0x4(%eax),%edx
 984:	8b 45 fc             	mov    -0x4(%ebp),%eax
 987:	8b 00                	mov    (%eax),%eax
 989:	8b 40 04             	mov    0x4(%eax),%eax
 98c:	01 c2                	add    %eax,%edx
 98e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 991:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 994:	8b 45 fc             	mov    -0x4(%ebp),%eax
 997:	8b 00                	mov    (%eax),%eax
 999:	8b 10                	mov    (%eax),%edx
 99b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 99e:	89 10                	mov    %edx,(%eax)
 9a0:	eb 0a                	jmp    9ac <free+0x94>
  } else
    bp->s.ptr = p->s.ptr;
 9a2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9a5:	8b 10                	mov    (%eax),%edx
 9a7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9aa:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 9ac:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9af:	8b 40 04             	mov    0x4(%eax),%eax
 9b2:	c1 e0 03             	shl    $0x3,%eax
 9b5:	03 45 fc             	add    -0x4(%ebp),%eax
 9b8:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 9bb:	75 20                	jne    9dd <free+0xc5>
    p->s.size += bp->s.size;
 9bd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9c0:	8b 50 04             	mov    0x4(%eax),%edx
 9c3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9c6:	8b 40 04             	mov    0x4(%eax),%eax
 9c9:	01 c2                	add    %eax,%edx
 9cb:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9ce:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 9d1:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9d4:	8b 10                	mov    (%eax),%edx
 9d6:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9d9:	89 10                	mov    %edx,(%eax)
 9db:	eb 08                	jmp    9e5 <free+0xcd>
  } else
    p->s.ptr = bp;
 9dd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9e0:	8b 55 f8             	mov    -0x8(%ebp),%edx
 9e3:	89 10                	mov    %edx,(%eax)
  freep = p;
 9e5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9e8:	a3 48 0e 00 00       	mov    %eax,0xe48
}
 9ed:	c9                   	leave  
 9ee:	c3                   	ret    

000009ef <morecore>:

static Header*
morecore(uint nu)
{
 9ef:	55                   	push   %ebp
 9f0:	89 e5                	mov    %esp,%ebp
 9f2:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 9f5:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 9fc:	77 07                	ja     a05 <morecore+0x16>
    nu = 4096;
 9fe:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 a05:	8b 45 08             	mov    0x8(%ebp),%eax
 a08:	c1 e0 03             	shl    $0x3,%eax
 a0b:	89 04 24             	mov    %eax,(%esp)
 a0e:	e8 49 fc ff ff       	call   65c <sbrk>
 a13:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 a16:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 a1a:	75 07                	jne    a23 <morecore+0x34>
    return 0;
 a1c:	b8 00 00 00 00       	mov    $0x0,%eax
 a21:	eb 22                	jmp    a45 <morecore+0x56>
  hp = (Header*)p;
 a23:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a26:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 a29:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a2c:	8b 55 08             	mov    0x8(%ebp),%edx
 a2f:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 a32:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a35:	83 c0 08             	add    $0x8,%eax
 a38:	89 04 24             	mov    %eax,(%esp)
 a3b:	e8 d8 fe ff ff       	call   918 <free>
  return freep;
 a40:	a1 48 0e 00 00       	mov    0xe48,%eax
}
 a45:	c9                   	leave  
 a46:	c3                   	ret    

00000a47 <malloc>:

void*
malloc(uint nbytes)
{
 a47:	55                   	push   %ebp
 a48:	89 e5                	mov    %esp,%ebp
 a4a:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 a4d:	8b 45 08             	mov    0x8(%ebp),%eax
 a50:	83 c0 07             	add    $0x7,%eax
 a53:	c1 e8 03             	shr    $0x3,%eax
 a56:	83 c0 01             	add    $0x1,%eax
 a59:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 a5c:	a1 48 0e 00 00       	mov    0xe48,%eax
 a61:	89 45 f0             	mov    %eax,-0x10(%ebp)
 a64:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 a68:	75 23                	jne    a8d <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 a6a:	c7 45 f0 40 0e 00 00 	movl   $0xe40,-0x10(%ebp)
 a71:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a74:	a3 48 0e 00 00       	mov    %eax,0xe48
 a79:	a1 48 0e 00 00       	mov    0xe48,%eax
 a7e:	a3 40 0e 00 00       	mov    %eax,0xe40
    base.s.size = 0;
 a83:	c7 05 44 0e 00 00 00 	movl   $0x0,0xe44
 a8a:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a8d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a90:	8b 00                	mov    (%eax),%eax
 a92:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 a95:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a98:	8b 40 04             	mov    0x4(%eax),%eax
 a9b:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 a9e:	72 4d                	jb     aed <malloc+0xa6>
      if(p->s.size == nunits)
 aa0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 aa3:	8b 40 04             	mov    0x4(%eax),%eax
 aa6:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 aa9:	75 0c                	jne    ab7 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 aab:	8b 45 f4             	mov    -0xc(%ebp),%eax
 aae:	8b 10                	mov    (%eax),%edx
 ab0:	8b 45 f0             	mov    -0x10(%ebp),%eax
 ab3:	89 10                	mov    %edx,(%eax)
 ab5:	eb 26                	jmp    add <malloc+0x96>
      else {
        p->s.size -= nunits;
 ab7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 aba:	8b 40 04             	mov    0x4(%eax),%eax
 abd:	89 c2                	mov    %eax,%edx
 abf:	2b 55 ec             	sub    -0x14(%ebp),%edx
 ac2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ac5:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 ac8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 acb:	8b 40 04             	mov    0x4(%eax),%eax
 ace:	c1 e0 03             	shl    $0x3,%eax
 ad1:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 ad4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ad7:	8b 55 ec             	mov    -0x14(%ebp),%edx
 ada:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 add:	8b 45 f0             	mov    -0x10(%ebp),%eax
 ae0:	a3 48 0e 00 00       	mov    %eax,0xe48
      return (void*)(p + 1);
 ae5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ae8:	83 c0 08             	add    $0x8,%eax
 aeb:	eb 38                	jmp    b25 <malloc+0xde>
    }
    if(p == freep)
 aed:	a1 48 0e 00 00       	mov    0xe48,%eax
 af2:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 af5:	75 1b                	jne    b12 <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 af7:	8b 45 ec             	mov    -0x14(%ebp),%eax
 afa:	89 04 24             	mov    %eax,(%esp)
 afd:	e8 ed fe ff ff       	call   9ef <morecore>
 b02:	89 45 f4             	mov    %eax,-0xc(%ebp)
 b05:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 b09:	75 07                	jne    b12 <malloc+0xcb>
        return 0;
 b0b:	b8 00 00 00 00       	mov    $0x0,%eax
 b10:	eb 13                	jmp    b25 <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 b12:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b15:	89 45 f0             	mov    %eax,-0x10(%ebp)
 b18:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b1b:	8b 00                	mov    (%eax),%eax
 b1d:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 b20:	e9 70 ff ff ff       	jmp    a95 <malloc+0x4e>
}
 b25:	c9                   	leave  
 b26:	c3                   	ret    
