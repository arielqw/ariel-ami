
_ls:     file format elf32-i386


Disassembly of section .text:

00000000 <fmtname>:
#include "user.h"
#include "fs.h"

char*
fmtname(char *path)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	53                   	push   %ebx
   4:	83 ec 24             	sub    $0x24,%esp
  static char buf[DIRSIZ+1];
  char *p;
  
  // Find first character after last slash.
  for(p=path+strlen(path); p >= path && *p != '/'; p--)
   7:	8b 45 08             	mov    0x8(%ebp),%eax
   a:	89 04 24             	mov    %eax,(%esp)
   d:	e8 ec 03 00 00       	call   3fe <strlen>
  12:	03 45 08             	add    0x8(%ebp),%eax
  15:	89 45 f4             	mov    %eax,-0xc(%ebp)
  18:	eb 04                	jmp    1e <fmtname+0x1e>
  1a:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
  1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  21:	3b 45 08             	cmp    0x8(%ebp),%eax
  24:	72 0a                	jb     30 <fmtname+0x30>
  26:	8b 45 f4             	mov    -0xc(%ebp),%eax
  29:	0f b6 00             	movzbl (%eax),%eax
  2c:	3c 2f                	cmp    $0x2f,%al
  2e:	75 ea                	jne    1a <fmtname+0x1a>
    ;
  p++;
  30:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  
  // Return blank-padded name.
  if(strlen(p) >= DIRSIZ)
  34:	8b 45 f4             	mov    -0xc(%ebp),%eax
  37:	89 04 24             	mov    %eax,(%esp)
  3a:	e8 bf 03 00 00       	call   3fe <strlen>
  3f:	83 f8 0d             	cmp    $0xd,%eax
  42:	76 05                	jbe    49 <fmtname+0x49>
    return p;
  44:	8b 45 f4             	mov    -0xc(%ebp),%eax
  47:	eb 5f                	jmp    a8 <fmtname+0xa8>
  memmove(buf, p, strlen(p));
  49:	8b 45 f4             	mov    -0xc(%ebp),%eax
  4c:	89 04 24             	mov    %eax,(%esp)
  4f:	e8 aa 03 00 00       	call   3fe <strlen>
  54:	89 44 24 08          	mov    %eax,0x8(%esp)
  58:	8b 45 f4             	mov    -0xc(%ebp),%eax
  5b:	89 44 24 04          	mov    %eax,0x4(%esp)
  5f:	c7 04 24 f8 0d 00 00 	movl   $0xdf8,(%esp)
  66:	e8 17 05 00 00       	call   582 <memmove>
  memset(buf+strlen(p), ' ', DIRSIZ-strlen(p));
  6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  6e:	89 04 24             	mov    %eax,(%esp)
  71:	e8 88 03 00 00       	call   3fe <strlen>
  76:	ba 0e 00 00 00       	mov    $0xe,%edx
  7b:	89 d3                	mov    %edx,%ebx
  7d:	29 c3                	sub    %eax,%ebx
  7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  82:	89 04 24             	mov    %eax,(%esp)
  85:	e8 74 03 00 00       	call   3fe <strlen>
  8a:	05 f8 0d 00 00       	add    $0xdf8,%eax
  8f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  93:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  9a:	00 
  9b:	89 04 24             	mov    %eax,(%esp)
  9e:	e8 80 03 00 00       	call   423 <memset>
  return buf;
  a3:	b8 f8 0d 00 00       	mov    $0xdf8,%eax
}
  a8:	83 c4 24             	add    $0x24,%esp
  ab:	5b                   	pop    %ebx
  ac:	5d                   	pop    %ebp
  ad:	c3                   	ret    

000000ae <ls>:

void
ls(char *path)
{
  ae:	55                   	push   %ebp
  af:	89 e5                	mov    %esp,%ebp
  b1:	57                   	push   %edi
  b2:	56                   	push   %esi
  b3:	53                   	push   %ebx
  b4:	81 ec 5c 02 00 00    	sub    $0x25c,%esp
  char buf[512], *p;
  int fd;
  struct dirent de;
  struct stat st;
  
  if((fd = open(path, 0)) < 0){
  ba:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  c1:	00 
  c2:	8b 45 08             	mov    0x8(%ebp),%eax
  c5:	89 04 24             	mov    %eax,(%esp)
  c8:	e8 3b 05 00 00       	call   608 <open>
  cd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  d0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  d4:	79 20                	jns    f6 <ls+0x48>
    printf(2, "ls: cannot open %s\n", path);
  d6:	8b 45 08             	mov    0x8(%ebp),%eax
  d9:	89 44 24 08          	mov    %eax,0x8(%esp)
  dd:	c7 44 24 04 03 0b 00 	movl   $0xb03,0x4(%esp)
  e4:	00 
  e5:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  ec:	e8 4e 06 00 00       	call   73f <printf>
    return;
  f1:	e9 01 02 00 00       	jmp    2f7 <ls+0x249>
  }
  
  if(fstat(fd, &st) < 0){
  f6:	8d 85 bc fd ff ff    	lea    -0x244(%ebp),%eax
  fc:	89 44 24 04          	mov    %eax,0x4(%esp)
 100:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 103:	89 04 24             	mov    %eax,(%esp)
 106:	e8 15 05 00 00       	call   620 <fstat>
 10b:	85 c0                	test   %eax,%eax
 10d:	79 2b                	jns    13a <ls+0x8c>
    printf(2, "ls: cannot stat %s\n", path);
 10f:	8b 45 08             	mov    0x8(%ebp),%eax
 112:	89 44 24 08          	mov    %eax,0x8(%esp)
 116:	c7 44 24 04 17 0b 00 	movl   $0xb17,0x4(%esp)
 11d:	00 
 11e:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
 125:	e8 15 06 00 00       	call   73f <printf>
    close(fd);
 12a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 12d:	89 04 24             	mov    %eax,(%esp)
 130:	e8 bb 04 00 00       	call   5f0 <close>
    return;
 135:	e9 bd 01 00 00       	jmp    2f7 <ls+0x249>
  }
  
  switch(st.type){
 13a:	0f b7 85 bc fd ff ff 	movzwl -0x244(%ebp),%eax
 141:	98                   	cwtl   
 142:	83 f8 01             	cmp    $0x1,%eax
 145:	74 53                	je     19a <ls+0xec>
 147:	83 f8 02             	cmp    $0x2,%eax
 14a:	0f 85 9c 01 00 00    	jne    2ec <ls+0x23e>
  case T_FILE:
    printf(1, "%s %d %d %d\n", fmtname(path), st.type, st.ino, st.size);
 150:	8b bd cc fd ff ff    	mov    -0x234(%ebp),%edi
 156:	8b b5 c4 fd ff ff    	mov    -0x23c(%ebp),%esi
 15c:	0f b7 85 bc fd ff ff 	movzwl -0x244(%ebp),%eax
 163:	0f bf d8             	movswl %ax,%ebx
 166:	8b 45 08             	mov    0x8(%ebp),%eax
 169:	89 04 24             	mov    %eax,(%esp)
 16c:	e8 8f fe ff ff       	call   0 <fmtname>
 171:	89 7c 24 14          	mov    %edi,0x14(%esp)
 175:	89 74 24 10          	mov    %esi,0x10(%esp)
 179:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
 17d:	89 44 24 08          	mov    %eax,0x8(%esp)
 181:	c7 44 24 04 2b 0b 00 	movl   $0xb2b,0x4(%esp)
 188:	00 
 189:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 190:	e8 aa 05 00 00       	call   73f <printf>
    break;
 195:	e9 52 01 00 00       	jmp    2ec <ls+0x23e>
  
  case T_DIR:
    if(strlen(path) + 1 + DIRSIZ + 1 > sizeof buf){
 19a:	8b 45 08             	mov    0x8(%ebp),%eax
 19d:	89 04 24             	mov    %eax,(%esp)
 1a0:	e8 59 02 00 00       	call   3fe <strlen>
 1a5:	83 c0 10             	add    $0x10,%eax
 1a8:	3d 00 02 00 00       	cmp    $0x200,%eax
 1ad:	76 19                	jbe    1c8 <ls+0x11a>
      printf(1, "ls: path too long\n");
 1af:	c7 44 24 04 38 0b 00 	movl   $0xb38,0x4(%esp)
 1b6:	00 
 1b7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 1be:	e8 7c 05 00 00       	call   73f <printf>
      break;
 1c3:	e9 24 01 00 00       	jmp    2ec <ls+0x23e>
    }
    strcpy(buf, path);
 1c8:	8b 45 08             	mov    0x8(%ebp),%eax
 1cb:	89 44 24 04          	mov    %eax,0x4(%esp)
 1cf:	8d 85 e0 fd ff ff    	lea    -0x220(%ebp),%eax
 1d5:	89 04 24             	mov    %eax,(%esp)
 1d8:	e8 ac 01 00 00       	call   389 <strcpy>
    p = buf+strlen(buf);
 1dd:	8d 85 e0 fd ff ff    	lea    -0x220(%ebp),%eax
 1e3:	89 04 24             	mov    %eax,(%esp)
 1e6:	e8 13 02 00 00       	call   3fe <strlen>
 1eb:	8d 95 e0 fd ff ff    	lea    -0x220(%ebp),%edx
 1f1:	01 d0                	add    %edx,%eax
 1f3:	89 45 e0             	mov    %eax,-0x20(%ebp)
    *p++ = '/';
 1f6:	8b 45 e0             	mov    -0x20(%ebp),%eax
 1f9:	c6 00 2f             	movb   $0x2f,(%eax)
 1fc:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
    while(read(fd, &de, sizeof(de)) == sizeof(de)){
 200:	e9 c0 00 00 00       	jmp    2c5 <ls+0x217>
      if(de.inum == 0)
 205:	0f b7 85 d0 fd ff ff 	movzwl -0x230(%ebp),%eax
 20c:	66 85 c0             	test   %ax,%ax
 20f:	0f 84 af 00 00 00    	je     2c4 <ls+0x216>
        continue;
      memmove(p, de.name, DIRSIZ);
 215:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
 21c:	00 
 21d:	8d 85 d0 fd ff ff    	lea    -0x230(%ebp),%eax
 223:	83 c0 02             	add    $0x2,%eax
 226:	89 44 24 04          	mov    %eax,0x4(%esp)
 22a:	8b 45 e0             	mov    -0x20(%ebp),%eax
 22d:	89 04 24             	mov    %eax,(%esp)
 230:	e8 4d 03 00 00       	call   582 <memmove>
      p[DIRSIZ] = 0;
 235:	8b 45 e0             	mov    -0x20(%ebp),%eax
 238:	83 c0 0e             	add    $0xe,%eax
 23b:	c6 00 00             	movb   $0x0,(%eax)
      if(stat(buf, &st) < 0){
 23e:	8d 85 bc fd ff ff    	lea    -0x244(%ebp),%eax
 244:	89 44 24 04          	mov    %eax,0x4(%esp)
 248:	8d 85 e0 fd ff ff    	lea    -0x220(%ebp),%eax
 24e:	89 04 24             	mov    %eax,(%esp)
 251:	e8 93 02 00 00       	call   4e9 <stat>
 256:	85 c0                	test   %eax,%eax
 258:	79 20                	jns    27a <ls+0x1cc>
        printf(1, "ls: cannot stat %s\n", buf);
 25a:	8d 85 e0 fd ff ff    	lea    -0x220(%ebp),%eax
 260:	89 44 24 08          	mov    %eax,0x8(%esp)
 264:	c7 44 24 04 17 0b 00 	movl   $0xb17,0x4(%esp)
 26b:	00 
 26c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 273:	e8 c7 04 00 00       	call   73f <printf>
        continue;
 278:	eb 4b                	jmp    2c5 <ls+0x217>
      }
      printf(1, "%s %d %d %d\n", fmtname(buf), st.type, st.ino, st.size);
 27a:	8b bd cc fd ff ff    	mov    -0x234(%ebp),%edi
 280:	8b b5 c4 fd ff ff    	mov    -0x23c(%ebp),%esi
 286:	0f b7 85 bc fd ff ff 	movzwl -0x244(%ebp),%eax
 28d:	0f bf d8             	movswl %ax,%ebx
 290:	8d 85 e0 fd ff ff    	lea    -0x220(%ebp),%eax
 296:	89 04 24             	mov    %eax,(%esp)
 299:	e8 62 fd ff ff       	call   0 <fmtname>
 29e:	89 7c 24 14          	mov    %edi,0x14(%esp)
 2a2:	89 74 24 10          	mov    %esi,0x10(%esp)
 2a6:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
 2aa:	89 44 24 08          	mov    %eax,0x8(%esp)
 2ae:	c7 44 24 04 2b 0b 00 	movl   $0xb2b,0x4(%esp)
 2b5:	00 
 2b6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 2bd:	e8 7d 04 00 00       	call   73f <printf>
 2c2:	eb 01                	jmp    2c5 <ls+0x217>
    strcpy(buf, path);
    p = buf+strlen(buf);
    *p++ = '/';
    while(read(fd, &de, sizeof(de)) == sizeof(de)){
      if(de.inum == 0)
        continue;
 2c4:	90                   	nop
      break;
    }
    strcpy(buf, path);
    p = buf+strlen(buf);
    *p++ = '/';
    while(read(fd, &de, sizeof(de)) == sizeof(de)){
 2c5:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 2cc:	00 
 2cd:	8d 85 d0 fd ff ff    	lea    -0x230(%ebp),%eax
 2d3:	89 44 24 04          	mov    %eax,0x4(%esp)
 2d7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 2da:	89 04 24             	mov    %eax,(%esp)
 2dd:	e8 fe 02 00 00       	call   5e0 <read>
 2e2:	83 f8 10             	cmp    $0x10,%eax
 2e5:	0f 84 1a ff ff ff    	je     205 <ls+0x157>
        printf(1, "ls: cannot stat %s\n", buf);
        continue;
      }
      printf(1, "%s %d %d %d\n", fmtname(buf), st.type, st.ino, st.size);
    }
    break;
 2eb:	90                   	nop
  }
  close(fd);
 2ec:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 2ef:	89 04 24             	mov    %eax,(%esp)
 2f2:	e8 f9 02 00 00       	call   5f0 <close>
}
 2f7:	81 c4 5c 02 00 00    	add    $0x25c,%esp
 2fd:	5b                   	pop    %ebx
 2fe:	5e                   	pop    %esi
 2ff:	5f                   	pop    %edi
 300:	5d                   	pop    %ebp
 301:	c3                   	ret    

00000302 <main>:

int
main(int argc, char *argv[])
{
 302:	55                   	push   %ebp
 303:	89 e5                	mov    %esp,%ebp
 305:	83 e4 f0             	and    $0xfffffff0,%esp
 308:	83 ec 20             	sub    $0x20,%esp
  int i;

  if(argc < 2){
 30b:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
 30f:	7f 18                	jg     329 <main+0x27>
    ls(".");
 311:	c7 04 24 4b 0b 00 00 	movl   $0xb4b,(%esp)
 318:	e8 91 fd ff ff       	call   ae <ls>
    exit(EXIT_STATUS_DEFAULT);
 31d:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
 324:	e8 9f 02 00 00       	call   5c8 <exit>
  }
  for(i=1; i<argc; i++)
 329:	c7 44 24 1c 01 00 00 	movl   $0x1,0x1c(%esp)
 330:	00 
 331:	eb 19                	jmp    34c <main+0x4a>
    ls(argv[i]);
 333:	8b 44 24 1c          	mov    0x1c(%esp),%eax
 337:	c1 e0 02             	shl    $0x2,%eax
 33a:	03 45 0c             	add    0xc(%ebp),%eax
 33d:	8b 00                	mov    (%eax),%eax
 33f:	89 04 24             	mov    %eax,(%esp)
 342:	e8 67 fd ff ff       	call   ae <ls>

  if(argc < 2){
    ls(".");
    exit(EXIT_STATUS_DEFAULT);
  }
  for(i=1; i<argc; i++)
 347:	83 44 24 1c 01       	addl   $0x1,0x1c(%esp)
 34c:	8b 44 24 1c          	mov    0x1c(%esp),%eax
 350:	3b 45 08             	cmp    0x8(%ebp),%eax
 353:	7c de                	jl     333 <main+0x31>
    ls(argv[i]);
  exit(EXIT_STATUS_DEFAULT);
 355:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
 35c:	e8 67 02 00 00       	call   5c8 <exit>
 361:	90                   	nop
 362:	90                   	nop
 363:	90                   	nop

00000364 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 364:	55                   	push   %ebp
 365:	89 e5                	mov    %esp,%ebp
 367:	57                   	push   %edi
 368:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 369:	8b 4d 08             	mov    0x8(%ebp),%ecx
 36c:	8b 55 10             	mov    0x10(%ebp),%edx
 36f:	8b 45 0c             	mov    0xc(%ebp),%eax
 372:	89 cb                	mov    %ecx,%ebx
 374:	89 df                	mov    %ebx,%edi
 376:	89 d1                	mov    %edx,%ecx
 378:	fc                   	cld    
 379:	f3 aa                	rep stos %al,%es:(%edi)
 37b:	89 ca                	mov    %ecx,%edx
 37d:	89 fb                	mov    %edi,%ebx
 37f:	89 5d 08             	mov    %ebx,0x8(%ebp)
 382:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 385:	5b                   	pop    %ebx
 386:	5f                   	pop    %edi
 387:	5d                   	pop    %ebp
 388:	c3                   	ret    

00000389 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 389:	55                   	push   %ebp
 38a:	89 e5                	mov    %esp,%ebp
 38c:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 38f:	8b 45 08             	mov    0x8(%ebp),%eax
 392:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 395:	90                   	nop
 396:	8b 45 0c             	mov    0xc(%ebp),%eax
 399:	0f b6 10             	movzbl (%eax),%edx
 39c:	8b 45 08             	mov    0x8(%ebp),%eax
 39f:	88 10                	mov    %dl,(%eax)
 3a1:	8b 45 08             	mov    0x8(%ebp),%eax
 3a4:	0f b6 00             	movzbl (%eax),%eax
 3a7:	84 c0                	test   %al,%al
 3a9:	0f 95 c0             	setne  %al
 3ac:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 3b0:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 3b4:	84 c0                	test   %al,%al
 3b6:	75 de                	jne    396 <strcpy+0xd>
    ;
  return os;
 3b8:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 3bb:	c9                   	leave  
 3bc:	c3                   	ret    

000003bd <strcmp>:

int
strcmp(const char *p, const char *q)
{
 3bd:	55                   	push   %ebp
 3be:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 3c0:	eb 08                	jmp    3ca <strcmp+0xd>
    p++, q++;
 3c2:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 3c6:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 3ca:	8b 45 08             	mov    0x8(%ebp),%eax
 3cd:	0f b6 00             	movzbl (%eax),%eax
 3d0:	84 c0                	test   %al,%al
 3d2:	74 10                	je     3e4 <strcmp+0x27>
 3d4:	8b 45 08             	mov    0x8(%ebp),%eax
 3d7:	0f b6 10             	movzbl (%eax),%edx
 3da:	8b 45 0c             	mov    0xc(%ebp),%eax
 3dd:	0f b6 00             	movzbl (%eax),%eax
 3e0:	38 c2                	cmp    %al,%dl
 3e2:	74 de                	je     3c2 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 3e4:	8b 45 08             	mov    0x8(%ebp),%eax
 3e7:	0f b6 00             	movzbl (%eax),%eax
 3ea:	0f b6 d0             	movzbl %al,%edx
 3ed:	8b 45 0c             	mov    0xc(%ebp),%eax
 3f0:	0f b6 00             	movzbl (%eax),%eax
 3f3:	0f b6 c0             	movzbl %al,%eax
 3f6:	89 d1                	mov    %edx,%ecx
 3f8:	29 c1                	sub    %eax,%ecx
 3fa:	89 c8                	mov    %ecx,%eax
}
 3fc:	5d                   	pop    %ebp
 3fd:	c3                   	ret    

000003fe <strlen>:

uint
strlen(char *s)
{
 3fe:	55                   	push   %ebp
 3ff:	89 e5                	mov    %esp,%ebp
 401:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 404:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 40b:	eb 04                	jmp    411 <strlen+0x13>
 40d:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 411:	8b 45 fc             	mov    -0x4(%ebp),%eax
 414:	03 45 08             	add    0x8(%ebp),%eax
 417:	0f b6 00             	movzbl (%eax),%eax
 41a:	84 c0                	test   %al,%al
 41c:	75 ef                	jne    40d <strlen+0xf>
    ;
  return n;
 41e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 421:	c9                   	leave  
 422:	c3                   	ret    

00000423 <memset>:

void*
memset(void *dst, int c, uint n)
{
 423:	55                   	push   %ebp
 424:	89 e5                	mov    %esp,%ebp
 426:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 429:	8b 45 10             	mov    0x10(%ebp),%eax
 42c:	89 44 24 08          	mov    %eax,0x8(%esp)
 430:	8b 45 0c             	mov    0xc(%ebp),%eax
 433:	89 44 24 04          	mov    %eax,0x4(%esp)
 437:	8b 45 08             	mov    0x8(%ebp),%eax
 43a:	89 04 24             	mov    %eax,(%esp)
 43d:	e8 22 ff ff ff       	call   364 <stosb>
  return dst;
 442:	8b 45 08             	mov    0x8(%ebp),%eax
}
 445:	c9                   	leave  
 446:	c3                   	ret    

00000447 <strchr>:

char*
strchr(const char *s, char c)
{
 447:	55                   	push   %ebp
 448:	89 e5                	mov    %esp,%ebp
 44a:	83 ec 04             	sub    $0x4,%esp
 44d:	8b 45 0c             	mov    0xc(%ebp),%eax
 450:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 453:	eb 14                	jmp    469 <strchr+0x22>
    if(*s == c)
 455:	8b 45 08             	mov    0x8(%ebp),%eax
 458:	0f b6 00             	movzbl (%eax),%eax
 45b:	3a 45 fc             	cmp    -0x4(%ebp),%al
 45e:	75 05                	jne    465 <strchr+0x1e>
      return (char*)s;
 460:	8b 45 08             	mov    0x8(%ebp),%eax
 463:	eb 13                	jmp    478 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 465:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 469:	8b 45 08             	mov    0x8(%ebp),%eax
 46c:	0f b6 00             	movzbl (%eax),%eax
 46f:	84 c0                	test   %al,%al
 471:	75 e2                	jne    455 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 473:	b8 00 00 00 00       	mov    $0x0,%eax
}
 478:	c9                   	leave  
 479:	c3                   	ret    

0000047a <gets>:

char*
gets(char *buf, int max)
{
 47a:	55                   	push   %ebp
 47b:	89 e5                	mov    %esp,%ebp
 47d:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 480:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 487:	eb 44                	jmp    4cd <gets+0x53>
    cc = read(0, &c, 1);
 489:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 490:	00 
 491:	8d 45 ef             	lea    -0x11(%ebp),%eax
 494:	89 44 24 04          	mov    %eax,0x4(%esp)
 498:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 49f:	e8 3c 01 00 00       	call   5e0 <read>
 4a4:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 4a7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 4ab:	7e 2d                	jle    4da <gets+0x60>
      break;
    buf[i++] = c;
 4ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4b0:	03 45 08             	add    0x8(%ebp),%eax
 4b3:	0f b6 55 ef          	movzbl -0x11(%ebp),%edx
 4b7:	88 10                	mov    %dl,(%eax)
 4b9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(c == '\n' || c == '\r')
 4bd:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 4c1:	3c 0a                	cmp    $0xa,%al
 4c3:	74 16                	je     4db <gets+0x61>
 4c5:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 4c9:	3c 0d                	cmp    $0xd,%al
 4cb:	74 0e                	je     4db <gets+0x61>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 4cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4d0:	83 c0 01             	add    $0x1,%eax
 4d3:	3b 45 0c             	cmp    0xc(%ebp),%eax
 4d6:	7c b1                	jl     489 <gets+0xf>
 4d8:	eb 01                	jmp    4db <gets+0x61>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 4da:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 4db:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4de:	03 45 08             	add    0x8(%ebp),%eax
 4e1:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 4e4:	8b 45 08             	mov    0x8(%ebp),%eax
}
 4e7:	c9                   	leave  
 4e8:	c3                   	ret    

000004e9 <stat>:

int
stat(char *n, struct stat *st)
{
 4e9:	55                   	push   %ebp
 4ea:	89 e5                	mov    %esp,%ebp
 4ec:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 4ef:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 4f6:	00 
 4f7:	8b 45 08             	mov    0x8(%ebp),%eax
 4fa:	89 04 24             	mov    %eax,(%esp)
 4fd:	e8 06 01 00 00       	call   608 <open>
 502:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 505:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 509:	79 07                	jns    512 <stat+0x29>
    return -1;
 50b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 510:	eb 23                	jmp    535 <stat+0x4c>
  r = fstat(fd, st);
 512:	8b 45 0c             	mov    0xc(%ebp),%eax
 515:	89 44 24 04          	mov    %eax,0x4(%esp)
 519:	8b 45 f4             	mov    -0xc(%ebp),%eax
 51c:	89 04 24             	mov    %eax,(%esp)
 51f:	e8 fc 00 00 00       	call   620 <fstat>
 524:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 527:	8b 45 f4             	mov    -0xc(%ebp),%eax
 52a:	89 04 24             	mov    %eax,(%esp)
 52d:	e8 be 00 00 00       	call   5f0 <close>
  return r;
 532:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 535:	c9                   	leave  
 536:	c3                   	ret    

00000537 <atoi>:

int
atoi(const char *s)
{
 537:	55                   	push   %ebp
 538:	89 e5                	mov    %esp,%ebp
 53a:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 53d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 544:	eb 23                	jmp    569 <atoi+0x32>
    n = n*10 + *s++ - '0';
 546:	8b 55 fc             	mov    -0x4(%ebp),%edx
 549:	89 d0                	mov    %edx,%eax
 54b:	c1 e0 02             	shl    $0x2,%eax
 54e:	01 d0                	add    %edx,%eax
 550:	01 c0                	add    %eax,%eax
 552:	89 c2                	mov    %eax,%edx
 554:	8b 45 08             	mov    0x8(%ebp),%eax
 557:	0f b6 00             	movzbl (%eax),%eax
 55a:	0f be c0             	movsbl %al,%eax
 55d:	01 d0                	add    %edx,%eax
 55f:	83 e8 30             	sub    $0x30,%eax
 562:	89 45 fc             	mov    %eax,-0x4(%ebp)
 565:	83 45 08 01          	addl   $0x1,0x8(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 569:	8b 45 08             	mov    0x8(%ebp),%eax
 56c:	0f b6 00             	movzbl (%eax),%eax
 56f:	3c 2f                	cmp    $0x2f,%al
 571:	7e 0a                	jle    57d <atoi+0x46>
 573:	8b 45 08             	mov    0x8(%ebp),%eax
 576:	0f b6 00             	movzbl (%eax),%eax
 579:	3c 39                	cmp    $0x39,%al
 57b:	7e c9                	jle    546 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 57d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 580:	c9                   	leave  
 581:	c3                   	ret    

00000582 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 582:	55                   	push   %ebp
 583:	89 e5                	mov    %esp,%ebp
 585:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 588:	8b 45 08             	mov    0x8(%ebp),%eax
 58b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 58e:	8b 45 0c             	mov    0xc(%ebp),%eax
 591:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 594:	eb 13                	jmp    5a9 <memmove+0x27>
    *dst++ = *src++;
 596:	8b 45 f8             	mov    -0x8(%ebp),%eax
 599:	0f b6 10             	movzbl (%eax),%edx
 59c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 59f:	88 10                	mov    %dl,(%eax)
 5a1:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 5a5:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 5a9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 5ad:	0f 9f c0             	setg   %al
 5b0:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 5b4:	84 c0                	test   %al,%al
 5b6:	75 de                	jne    596 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 5b8:	8b 45 08             	mov    0x8(%ebp),%eax
}
 5bb:	c9                   	leave  
 5bc:	c3                   	ret    
 5bd:	90                   	nop
 5be:	90                   	nop
 5bf:	90                   	nop

000005c0 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 5c0:	b8 01 00 00 00       	mov    $0x1,%eax
 5c5:	cd 40                	int    $0x40
 5c7:	c3                   	ret    

000005c8 <exit>:
SYSCALL(exit)
 5c8:	b8 02 00 00 00       	mov    $0x2,%eax
 5cd:	cd 40                	int    $0x40
 5cf:	c3                   	ret    

000005d0 <wait>:
SYSCALL(wait)
 5d0:	b8 03 00 00 00       	mov    $0x3,%eax
 5d5:	cd 40                	int    $0x40
 5d7:	c3                   	ret    

000005d8 <pipe>:
SYSCALL(pipe)
 5d8:	b8 04 00 00 00       	mov    $0x4,%eax
 5dd:	cd 40                	int    $0x40
 5df:	c3                   	ret    

000005e0 <read>:
SYSCALL(read)
 5e0:	b8 05 00 00 00       	mov    $0x5,%eax
 5e5:	cd 40                	int    $0x40
 5e7:	c3                   	ret    

000005e8 <write>:
SYSCALL(write)
 5e8:	b8 10 00 00 00       	mov    $0x10,%eax
 5ed:	cd 40                	int    $0x40
 5ef:	c3                   	ret    

000005f0 <close>:
SYSCALL(close)
 5f0:	b8 15 00 00 00       	mov    $0x15,%eax
 5f5:	cd 40                	int    $0x40
 5f7:	c3                   	ret    

000005f8 <kill>:
SYSCALL(kill)
 5f8:	b8 06 00 00 00       	mov    $0x6,%eax
 5fd:	cd 40                	int    $0x40
 5ff:	c3                   	ret    

00000600 <exec>:
SYSCALL(exec)
 600:	b8 07 00 00 00       	mov    $0x7,%eax
 605:	cd 40                	int    $0x40
 607:	c3                   	ret    

00000608 <open>:
SYSCALL(open)
 608:	b8 0f 00 00 00       	mov    $0xf,%eax
 60d:	cd 40                	int    $0x40
 60f:	c3                   	ret    

00000610 <mknod>:
SYSCALL(mknod)
 610:	b8 11 00 00 00       	mov    $0x11,%eax
 615:	cd 40                	int    $0x40
 617:	c3                   	ret    

00000618 <unlink>:
SYSCALL(unlink)
 618:	b8 12 00 00 00       	mov    $0x12,%eax
 61d:	cd 40                	int    $0x40
 61f:	c3                   	ret    

00000620 <fstat>:
SYSCALL(fstat)
 620:	b8 08 00 00 00       	mov    $0x8,%eax
 625:	cd 40                	int    $0x40
 627:	c3                   	ret    

00000628 <link>:
SYSCALL(link)
 628:	b8 13 00 00 00       	mov    $0x13,%eax
 62d:	cd 40                	int    $0x40
 62f:	c3                   	ret    

00000630 <mkdir>:
SYSCALL(mkdir)
 630:	b8 14 00 00 00       	mov    $0x14,%eax
 635:	cd 40                	int    $0x40
 637:	c3                   	ret    

00000638 <chdir>:
SYSCALL(chdir)
 638:	b8 09 00 00 00       	mov    $0x9,%eax
 63d:	cd 40                	int    $0x40
 63f:	c3                   	ret    

00000640 <dup>:
SYSCALL(dup)
 640:	b8 0a 00 00 00       	mov    $0xa,%eax
 645:	cd 40                	int    $0x40
 647:	c3                   	ret    

00000648 <getpid>:
SYSCALL(getpid)
 648:	b8 0b 00 00 00       	mov    $0xb,%eax
 64d:	cd 40                	int    $0x40
 64f:	c3                   	ret    

00000650 <sbrk>:
SYSCALL(sbrk)
 650:	b8 0c 00 00 00       	mov    $0xc,%eax
 655:	cd 40                	int    $0x40
 657:	c3                   	ret    

00000658 <sleep>:
SYSCALL(sleep)
 658:	b8 0d 00 00 00       	mov    $0xd,%eax
 65d:	cd 40                	int    $0x40
 65f:	c3                   	ret    

00000660 <uptime>:
SYSCALL(uptime)
 660:	b8 0e 00 00 00       	mov    $0xe,%eax
 665:	cd 40                	int    $0x40
 667:	c3                   	ret    

00000668 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 668:	55                   	push   %ebp
 669:	89 e5                	mov    %esp,%ebp
 66b:	83 ec 28             	sub    $0x28,%esp
 66e:	8b 45 0c             	mov    0xc(%ebp),%eax
 671:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 674:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 67b:	00 
 67c:	8d 45 f4             	lea    -0xc(%ebp),%eax
 67f:	89 44 24 04          	mov    %eax,0x4(%esp)
 683:	8b 45 08             	mov    0x8(%ebp),%eax
 686:	89 04 24             	mov    %eax,(%esp)
 689:	e8 5a ff ff ff       	call   5e8 <write>
}
 68e:	c9                   	leave  
 68f:	c3                   	ret    

00000690 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 690:	55                   	push   %ebp
 691:	89 e5                	mov    %esp,%ebp
 693:	83 ec 48             	sub    $0x48,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 696:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 69d:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 6a1:	74 17                	je     6ba <printint+0x2a>
 6a3:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 6a7:	79 11                	jns    6ba <printint+0x2a>
    neg = 1;
 6a9:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 6b0:	8b 45 0c             	mov    0xc(%ebp),%eax
 6b3:	f7 d8                	neg    %eax
 6b5:	89 45 ec             	mov    %eax,-0x14(%ebp)
 6b8:	eb 06                	jmp    6c0 <printint+0x30>
  } else {
    x = xx;
 6ba:	8b 45 0c             	mov    0xc(%ebp),%eax
 6bd:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 6c0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 6c7:	8b 4d 10             	mov    0x10(%ebp),%ecx
 6ca:	8b 45 ec             	mov    -0x14(%ebp),%eax
 6cd:	ba 00 00 00 00       	mov    $0x0,%edx
 6d2:	f7 f1                	div    %ecx
 6d4:	89 d0                	mov    %edx,%eax
 6d6:	0f b6 90 e4 0d 00 00 	movzbl 0xde4(%eax),%edx
 6dd:	8d 45 dc             	lea    -0x24(%ebp),%eax
 6e0:	03 45 f4             	add    -0xc(%ebp),%eax
 6e3:	88 10                	mov    %dl,(%eax)
 6e5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  }while((x /= base) != 0);
 6e9:	8b 55 10             	mov    0x10(%ebp),%edx
 6ec:	89 55 d4             	mov    %edx,-0x2c(%ebp)
 6ef:	8b 45 ec             	mov    -0x14(%ebp),%eax
 6f2:	ba 00 00 00 00       	mov    $0x0,%edx
 6f7:	f7 75 d4             	divl   -0x2c(%ebp)
 6fa:	89 45 ec             	mov    %eax,-0x14(%ebp)
 6fd:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 701:	75 c4                	jne    6c7 <printint+0x37>
  if(neg)
 703:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 707:	74 2a                	je     733 <printint+0xa3>
    buf[i++] = '-';
 709:	8d 45 dc             	lea    -0x24(%ebp),%eax
 70c:	03 45 f4             	add    -0xc(%ebp),%eax
 70f:	c6 00 2d             	movb   $0x2d,(%eax)
 712:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

  while(--i >= 0)
 716:	eb 1b                	jmp    733 <printint+0xa3>
    putc(fd, buf[i]);
 718:	8d 45 dc             	lea    -0x24(%ebp),%eax
 71b:	03 45 f4             	add    -0xc(%ebp),%eax
 71e:	0f b6 00             	movzbl (%eax),%eax
 721:	0f be c0             	movsbl %al,%eax
 724:	89 44 24 04          	mov    %eax,0x4(%esp)
 728:	8b 45 08             	mov    0x8(%ebp),%eax
 72b:	89 04 24             	mov    %eax,(%esp)
 72e:	e8 35 ff ff ff       	call   668 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 733:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 737:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 73b:	79 db                	jns    718 <printint+0x88>
    putc(fd, buf[i]);
}
 73d:	c9                   	leave  
 73e:	c3                   	ret    

0000073f <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 73f:	55                   	push   %ebp
 740:	89 e5                	mov    %esp,%ebp
 742:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 745:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 74c:	8d 45 0c             	lea    0xc(%ebp),%eax
 74f:	83 c0 04             	add    $0x4,%eax
 752:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 755:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 75c:	e9 7d 01 00 00       	jmp    8de <printf+0x19f>
    c = fmt[i] & 0xff;
 761:	8b 55 0c             	mov    0xc(%ebp),%edx
 764:	8b 45 f0             	mov    -0x10(%ebp),%eax
 767:	01 d0                	add    %edx,%eax
 769:	0f b6 00             	movzbl (%eax),%eax
 76c:	0f be c0             	movsbl %al,%eax
 76f:	25 ff 00 00 00       	and    $0xff,%eax
 774:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 777:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 77b:	75 2c                	jne    7a9 <printf+0x6a>
      if(c == '%'){
 77d:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 781:	75 0c                	jne    78f <printf+0x50>
        state = '%';
 783:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 78a:	e9 4b 01 00 00       	jmp    8da <printf+0x19b>
      } else {
        putc(fd, c);
 78f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 792:	0f be c0             	movsbl %al,%eax
 795:	89 44 24 04          	mov    %eax,0x4(%esp)
 799:	8b 45 08             	mov    0x8(%ebp),%eax
 79c:	89 04 24             	mov    %eax,(%esp)
 79f:	e8 c4 fe ff ff       	call   668 <putc>
 7a4:	e9 31 01 00 00       	jmp    8da <printf+0x19b>
      }
    } else if(state == '%'){
 7a9:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 7ad:	0f 85 27 01 00 00    	jne    8da <printf+0x19b>
      if(c == 'd'){
 7b3:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 7b7:	75 2d                	jne    7e6 <printf+0xa7>
        printint(fd, *ap, 10, 1);
 7b9:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7bc:	8b 00                	mov    (%eax),%eax
 7be:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 7c5:	00 
 7c6:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 7cd:	00 
 7ce:	89 44 24 04          	mov    %eax,0x4(%esp)
 7d2:	8b 45 08             	mov    0x8(%ebp),%eax
 7d5:	89 04 24             	mov    %eax,(%esp)
 7d8:	e8 b3 fe ff ff       	call   690 <printint>
        ap++;
 7dd:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 7e1:	e9 ed 00 00 00       	jmp    8d3 <printf+0x194>
      } else if(c == 'x' || c == 'p'){
 7e6:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 7ea:	74 06                	je     7f2 <printf+0xb3>
 7ec:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 7f0:	75 2d                	jne    81f <printf+0xe0>
        printint(fd, *ap, 16, 0);
 7f2:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7f5:	8b 00                	mov    (%eax),%eax
 7f7:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 7fe:	00 
 7ff:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 806:	00 
 807:	89 44 24 04          	mov    %eax,0x4(%esp)
 80b:	8b 45 08             	mov    0x8(%ebp),%eax
 80e:	89 04 24             	mov    %eax,(%esp)
 811:	e8 7a fe ff ff       	call   690 <printint>
        ap++;
 816:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 81a:	e9 b4 00 00 00       	jmp    8d3 <printf+0x194>
      } else if(c == 's'){
 81f:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 823:	75 46                	jne    86b <printf+0x12c>
        s = (char*)*ap;
 825:	8b 45 e8             	mov    -0x18(%ebp),%eax
 828:	8b 00                	mov    (%eax),%eax
 82a:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 82d:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 831:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 835:	75 27                	jne    85e <printf+0x11f>
          s = "(null)";
 837:	c7 45 f4 4d 0b 00 00 	movl   $0xb4d,-0xc(%ebp)
        while(*s != 0){
 83e:	eb 1e                	jmp    85e <printf+0x11f>
          putc(fd, *s);
 840:	8b 45 f4             	mov    -0xc(%ebp),%eax
 843:	0f b6 00             	movzbl (%eax),%eax
 846:	0f be c0             	movsbl %al,%eax
 849:	89 44 24 04          	mov    %eax,0x4(%esp)
 84d:	8b 45 08             	mov    0x8(%ebp),%eax
 850:	89 04 24             	mov    %eax,(%esp)
 853:	e8 10 fe ff ff       	call   668 <putc>
          s++;
 858:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 85c:	eb 01                	jmp    85f <printf+0x120>
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 85e:	90                   	nop
 85f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 862:	0f b6 00             	movzbl (%eax),%eax
 865:	84 c0                	test   %al,%al
 867:	75 d7                	jne    840 <printf+0x101>
 869:	eb 68                	jmp    8d3 <printf+0x194>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 86b:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 86f:	75 1d                	jne    88e <printf+0x14f>
        putc(fd, *ap);
 871:	8b 45 e8             	mov    -0x18(%ebp),%eax
 874:	8b 00                	mov    (%eax),%eax
 876:	0f be c0             	movsbl %al,%eax
 879:	89 44 24 04          	mov    %eax,0x4(%esp)
 87d:	8b 45 08             	mov    0x8(%ebp),%eax
 880:	89 04 24             	mov    %eax,(%esp)
 883:	e8 e0 fd ff ff       	call   668 <putc>
        ap++;
 888:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 88c:	eb 45                	jmp    8d3 <printf+0x194>
      } else if(c == '%'){
 88e:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 892:	75 17                	jne    8ab <printf+0x16c>
        putc(fd, c);
 894:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 897:	0f be c0             	movsbl %al,%eax
 89a:	89 44 24 04          	mov    %eax,0x4(%esp)
 89e:	8b 45 08             	mov    0x8(%ebp),%eax
 8a1:	89 04 24             	mov    %eax,(%esp)
 8a4:	e8 bf fd ff ff       	call   668 <putc>
 8a9:	eb 28                	jmp    8d3 <printf+0x194>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 8ab:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 8b2:	00 
 8b3:	8b 45 08             	mov    0x8(%ebp),%eax
 8b6:	89 04 24             	mov    %eax,(%esp)
 8b9:	e8 aa fd ff ff       	call   668 <putc>
        putc(fd, c);
 8be:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 8c1:	0f be c0             	movsbl %al,%eax
 8c4:	89 44 24 04          	mov    %eax,0x4(%esp)
 8c8:	8b 45 08             	mov    0x8(%ebp),%eax
 8cb:	89 04 24             	mov    %eax,(%esp)
 8ce:	e8 95 fd ff ff       	call   668 <putc>
      }
      state = 0;
 8d3:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 8da:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 8de:	8b 55 0c             	mov    0xc(%ebp),%edx
 8e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8e4:	01 d0                	add    %edx,%eax
 8e6:	0f b6 00             	movzbl (%eax),%eax
 8e9:	84 c0                	test   %al,%al
 8eb:	0f 85 70 fe ff ff    	jne    761 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 8f1:	c9                   	leave  
 8f2:	c3                   	ret    
 8f3:	90                   	nop

000008f4 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 8f4:	55                   	push   %ebp
 8f5:	89 e5                	mov    %esp,%ebp
 8f7:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 8fa:	8b 45 08             	mov    0x8(%ebp),%eax
 8fd:	83 e8 08             	sub    $0x8,%eax
 900:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 903:	a1 10 0e 00 00       	mov    0xe10,%eax
 908:	89 45 fc             	mov    %eax,-0x4(%ebp)
 90b:	eb 24                	jmp    931 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 90d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 910:	8b 00                	mov    (%eax),%eax
 912:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 915:	77 12                	ja     929 <free+0x35>
 917:	8b 45 f8             	mov    -0x8(%ebp),%eax
 91a:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 91d:	77 24                	ja     943 <free+0x4f>
 91f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 922:	8b 00                	mov    (%eax),%eax
 924:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 927:	77 1a                	ja     943 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 929:	8b 45 fc             	mov    -0x4(%ebp),%eax
 92c:	8b 00                	mov    (%eax),%eax
 92e:	89 45 fc             	mov    %eax,-0x4(%ebp)
 931:	8b 45 f8             	mov    -0x8(%ebp),%eax
 934:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 937:	76 d4                	jbe    90d <free+0x19>
 939:	8b 45 fc             	mov    -0x4(%ebp),%eax
 93c:	8b 00                	mov    (%eax),%eax
 93e:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 941:	76 ca                	jbe    90d <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 943:	8b 45 f8             	mov    -0x8(%ebp),%eax
 946:	8b 40 04             	mov    0x4(%eax),%eax
 949:	c1 e0 03             	shl    $0x3,%eax
 94c:	89 c2                	mov    %eax,%edx
 94e:	03 55 f8             	add    -0x8(%ebp),%edx
 951:	8b 45 fc             	mov    -0x4(%ebp),%eax
 954:	8b 00                	mov    (%eax),%eax
 956:	39 c2                	cmp    %eax,%edx
 958:	75 24                	jne    97e <free+0x8a>
    bp->s.size += p->s.ptr->s.size;
 95a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 95d:	8b 50 04             	mov    0x4(%eax),%edx
 960:	8b 45 fc             	mov    -0x4(%ebp),%eax
 963:	8b 00                	mov    (%eax),%eax
 965:	8b 40 04             	mov    0x4(%eax),%eax
 968:	01 c2                	add    %eax,%edx
 96a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 96d:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 970:	8b 45 fc             	mov    -0x4(%ebp),%eax
 973:	8b 00                	mov    (%eax),%eax
 975:	8b 10                	mov    (%eax),%edx
 977:	8b 45 f8             	mov    -0x8(%ebp),%eax
 97a:	89 10                	mov    %edx,(%eax)
 97c:	eb 0a                	jmp    988 <free+0x94>
  } else
    bp->s.ptr = p->s.ptr;
 97e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 981:	8b 10                	mov    (%eax),%edx
 983:	8b 45 f8             	mov    -0x8(%ebp),%eax
 986:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 988:	8b 45 fc             	mov    -0x4(%ebp),%eax
 98b:	8b 40 04             	mov    0x4(%eax),%eax
 98e:	c1 e0 03             	shl    $0x3,%eax
 991:	03 45 fc             	add    -0x4(%ebp),%eax
 994:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 997:	75 20                	jne    9b9 <free+0xc5>
    p->s.size += bp->s.size;
 999:	8b 45 fc             	mov    -0x4(%ebp),%eax
 99c:	8b 50 04             	mov    0x4(%eax),%edx
 99f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9a2:	8b 40 04             	mov    0x4(%eax),%eax
 9a5:	01 c2                	add    %eax,%edx
 9a7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9aa:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 9ad:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9b0:	8b 10                	mov    (%eax),%edx
 9b2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9b5:	89 10                	mov    %edx,(%eax)
 9b7:	eb 08                	jmp    9c1 <free+0xcd>
  } else
    p->s.ptr = bp;
 9b9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9bc:	8b 55 f8             	mov    -0x8(%ebp),%edx
 9bf:	89 10                	mov    %edx,(%eax)
  freep = p;
 9c1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9c4:	a3 10 0e 00 00       	mov    %eax,0xe10
}
 9c9:	c9                   	leave  
 9ca:	c3                   	ret    

000009cb <morecore>:

static Header*
morecore(uint nu)
{
 9cb:	55                   	push   %ebp
 9cc:	89 e5                	mov    %esp,%ebp
 9ce:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 9d1:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 9d8:	77 07                	ja     9e1 <morecore+0x16>
    nu = 4096;
 9da:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 9e1:	8b 45 08             	mov    0x8(%ebp),%eax
 9e4:	c1 e0 03             	shl    $0x3,%eax
 9e7:	89 04 24             	mov    %eax,(%esp)
 9ea:	e8 61 fc ff ff       	call   650 <sbrk>
 9ef:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 9f2:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 9f6:	75 07                	jne    9ff <morecore+0x34>
    return 0;
 9f8:	b8 00 00 00 00       	mov    $0x0,%eax
 9fd:	eb 22                	jmp    a21 <morecore+0x56>
  hp = (Header*)p;
 9ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a02:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 a05:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a08:	8b 55 08             	mov    0x8(%ebp),%edx
 a0b:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 a0e:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a11:	83 c0 08             	add    $0x8,%eax
 a14:	89 04 24             	mov    %eax,(%esp)
 a17:	e8 d8 fe ff ff       	call   8f4 <free>
  return freep;
 a1c:	a1 10 0e 00 00       	mov    0xe10,%eax
}
 a21:	c9                   	leave  
 a22:	c3                   	ret    

00000a23 <malloc>:

void*
malloc(uint nbytes)
{
 a23:	55                   	push   %ebp
 a24:	89 e5                	mov    %esp,%ebp
 a26:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 a29:	8b 45 08             	mov    0x8(%ebp),%eax
 a2c:	83 c0 07             	add    $0x7,%eax
 a2f:	c1 e8 03             	shr    $0x3,%eax
 a32:	83 c0 01             	add    $0x1,%eax
 a35:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 a38:	a1 10 0e 00 00       	mov    0xe10,%eax
 a3d:	89 45 f0             	mov    %eax,-0x10(%ebp)
 a40:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 a44:	75 23                	jne    a69 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 a46:	c7 45 f0 08 0e 00 00 	movl   $0xe08,-0x10(%ebp)
 a4d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a50:	a3 10 0e 00 00       	mov    %eax,0xe10
 a55:	a1 10 0e 00 00       	mov    0xe10,%eax
 a5a:	a3 08 0e 00 00       	mov    %eax,0xe08
    base.s.size = 0;
 a5f:	c7 05 0c 0e 00 00 00 	movl   $0x0,0xe0c
 a66:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a69:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a6c:	8b 00                	mov    (%eax),%eax
 a6e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 a71:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a74:	8b 40 04             	mov    0x4(%eax),%eax
 a77:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 a7a:	72 4d                	jb     ac9 <malloc+0xa6>
      if(p->s.size == nunits)
 a7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a7f:	8b 40 04             	mov    0x4(%eax),%eax
 a82:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 a85:	75 0c                	jne    a93 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 a87:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a8a:	8b 10                	mov    (%eax),%edx
 a8c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a8f:	89 10                	mov    %edx,(%eax)
 a91:	eb 26                	jmp    ab9 <malloc+0x96>
      else {
        p->s.size -= nunits;
 a93:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a96:	8b 40 04             	mov    0x4(%eax),%eax
 a99:	89 c2                	mov    %eax,%edx
 a9b:	2b 55 ec             	sub    -0x14(%ebp),%edx
 a9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 aa1:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 aa4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 aa7:	8b 40 04             	mov    0x4(%eax),%eax
 aaa:	c1 e0 03             	shl    $0x3,%eax
 aad:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 ab0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ab3:	8b 55 ec             	mov    -0x14(%ebp),%edx
 ab6:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 ab9:	8b 45 f0             	mov    -0x10(%ebp),%eax
 abc:	a3 10 0e 00 00       	mov    %eax,0xe10
      return (void*)(p + 1);
 ac1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ac4:	83 c0 08             	add    $0x8,%eax
 ac7:	eb 38                	jmp    b01 <malloc+0xde>
    }
    if(p == freep)
 ac9:	a1 10 0e 00 00       	mov    0xe10,%eax
 ace:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 ad1:	75 1b                	jne    aee <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 ad3:	8b 45 ec             	mov    -0x14(%ebp),%eax
 ad6:	89 04 24             	mov    %eax,(%esp)
 ad9:	e8 ed fe ff ff       	call   9cb <morecore>
 ade:	89 45 f4             	mov    %eax,-0xc(%ebp)
 ae1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 ae5:	75 07                	jne    aee <malloc+0xcb>
        return 0;
 ae7:	b8 00 00 00 00       	mov    $0x0,%eax
 aec:	eb 13                	jmp    b01 <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 aee:	8b 45 f4             	mov    -0xc(%ebp),%eax
 af1:	89 45 f0             	mov    %eax,-0x10(%ebp)
 af4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 af7:	8b 00                	mov    (%eax),%eax
 af9:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 afc:	e9 70 ff ff ff       	jmp    a71 <malloc+0x4e>
}
 b01:	c9                   	leave  
 b02:	c3                   	ret    
