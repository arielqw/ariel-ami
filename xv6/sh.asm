
_sh:     file format elf32-i386


Disassembly of section .text:

00000000 <runcmd>:
struct cmd *parsecmd(char*);

// Execute cmd.  Never returns.
void
runcmd(struct cmd *cmd)
{
       0:	55                   	push   %ebp
       1:	89 e5                	mov    %esp,%ebp
       3:	83 ec 38             	sub    $0x38,%esp
  struct execcmd *ecmd;
  struct listcmd *lcmd;
  struct pipecmd *pcmd;
  struct redircmd *rcmd;

  if(cmd == 0)
       6:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
       a:	75 0c                	jne    18 <runcmd+0x18>
    exit(EXIT_STATUS_DEFAULT);
       c:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
      13:	e8 90 0f 00 00       	call   fa8 <exit>
  
  switch(cmd->type){
      18:	8b 45 08             	mov    0x8(%ebp),%eax
      1b:	8b 00                	mov    (%eax),%eax
      1d:	83 f8 05             	cmp    $0x5,%eax
      20:	77 09                	ja     2b <runcmd+0x2b>
      22:	8b 04 85 18 15 00 00 	mov    0x1518(,%eax,4),%eax
      29:	ff e0                	jmp    *%eax
  default:
    panic("runcmd");
      2b:	c7 04 24 ec 14 00 00 	movl   $0x14ec,(%esp)
      32:	e8 62 03 00 00       	call   399 <panic>

  case EXEC:
    ecmd = (struct execcmd*)cmd;
      37:	8b 45 08             	mov    0x8(%ebp),%eax
      3a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ecmd->argv[0] == 0)
      3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
      40:	8b 40 04             	mov    0x4(%eax),%eax
      43:	85 c0                	test   %eax,%eax
      45:	75 0c                	jne    53 <runcmd+0x53>
      exit(EXIT_STATUS_DEFAULT);
      47:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
      4e:	e8 55 0f 00 00       	call   fa8 <exit>
    exec(ecmd->argv[0], ecmd->argv);
      53:	8b 45 f4             	mov    -0xc(%ebp),%eax
      56:	8d 50 04             	lea    0x4(%eax),%edx
      59:	8b 45 f4             	mov    -0xc(%ebp),%eax
      5c:	8b 40 04             	mov    0x4(%eax),%eax
      5f:	89 54 24 04          	mov    %edx,0x4(%esp)
      63:	89 04 24             	mov    %eax,(%esp)
      66:	e8 75 0f 00 00       	call   fe0 <exec>
    printf(2, "exec %s failed\n", ecmd->argv[0]);
      6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
      6e:	8b 40 04             	mov    0x4(%eax),%eax
      71:	89 44 24 08          	mov    %eax,0x8(%esp)
      75:	c7 44 24 04 f3 14 00 	movl   $0x14f3,0x4(%esp)
      7c:	00 
      7d:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
      84:	e8 9e 10 00 00       	call   1127 <printf>
    break;
      89:	e9 a0 01 00 00       	jmp    22e <runcmd+0x22e>

  case REDIR:
    rcmd = (struct redircmd*)cmd;
      8e:	8b 45 08             	mov    0x8(%ebp),%eax
      91:	89 45 f0             	mov    %eax,-0x10(%ebp)
    close(rcmd->fd);
      94:	8b 45 f0             	mov    -0x10(%ebp),%eax
      97:	8b 40 14             	mov    0x14(%eax),%eax
      9a:	89 04 24             	mov    %eax,(%esp)
      9d:	e8 2e 0f 00 00       	call   fd0 <close>
    if(open(rcmd->file, rcmd->mode) < 0){
      a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
      a5:	8b 50 10             	mov    0x10(%eax),%edx
      a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
      ab:	8b 40 08             	mov    0x8(%eax),%eax
      ae:	89 54 24 04          	mov    %edx,0x4(%esp)
      b2:	89 04 24             	mov    %eax,(%esp)
      b5:	e8 2e 0f 00 00       	call   fe8 <open>
      ba:	85 c0                	test   %eax,%eax
      bc:	79 2a                	jns    e8 <runcmd+0xe8>
      printf(2, "open %s failed\n", rcmd->file);
      be:	8b 45 f0             	mov    -0x10(%ebp),%eax
      c1:	8b 40 08             	mov    0x8(%eax),%eax
      c4:	89 44 24 08          	mov    %eax,0x8(%esp)
      c8:	c7 44 24 04 03 15 00 	movl   $0x1503,0x4(%esp)
      cf:	00 
      d0:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
      d7:	e8 4b 10 00 00       	call   1127 <printf>
      exit(EXIT_STATUS_DEFAULT);
      dc:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
      e3:	e8 c0 0e 00 00       	call   fa8 <exit>
    }
    runcmd(rcmd->cmd);
      e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
      eb:	8b 40 04             	mov    0x4(%eax),%eax
      ee:	89 04 24             	mov    %eax,(%esp)
      f1:	e8 0a ff ff ff       	call   0 <runcmd>
    break;
      f6:	e9 33 01 00 00       	jmp    22e <runcmd+0x22e>

  case LIST:
    lcmd = (struct listcmd*)cmd;
      fb:	8b 45 08             	mov    0x8(%ebp),%eax
      fe:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(fork1() == 0)
     101:	e8 c0 02 00 00       	call   3c6 <fork1>
     106:	85 c0                	test   %eax,%eax
     108:	75 0e                	jne    118 <runcmd+0x118>
      runcmd(lcmd->left);
     10a:	8b 45 ec             	mov    -0x14(%ebp),%eax
     10d:	8b 40 04             	mov    0x4(%eax),%eax
     110:	89 04 24             	mov    %eax,(%esp)
     113:	e8 e8 fe ff ff       	call   0 <runcmd>
    wait(0);
     118:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
     11f:	e8 8c 0e 00 00       	call   fb0 <wait>
    runcmd(lcmd->right);
     124:	8b 45 ec             	mov    -0x14(%ebp),%eax
     127:	8b 40 08             	mov    0x8(%eax),%eax
     12a:	89 04 24             	mov    %eax,(%esp)
     12d:	e8 ce fe ff ff       	call   0 <runcmd>
    break;
     132:	e9 f7 00 00 00       	jmp    22e <runcmd+0x22e>

  case PIPE:
    pcmd = (struct pipecmd*)cmd;
     137:	8b 45 08             	mov    0x8(%ebp),%eax
     13a:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pipe(p) < 0)
     13d:	8d 45 dc             	lea    -0x24(%ebp),%eax
     140:	89 04 24             	mov    %eax,(%esp)
     143:	e8 70 0e 00 00       	call   fb8 <pipe>
     148:	85 c0                	test   %eax,%eax
     14a:	79 0c                	jns    158 <runcmd+0x158>
      panic("pipe");
     14c:	c7 04 24 13 15 00 00 	movl   $0x1513,(%esp)
     153:	e8 41 02 00 00       	call   399 <panic>
    if(fork1() == 0){
     158:	e8 69 02 00 00       	call   3c6 <fork1>
     15d:	85 c0                	test   %eax,%eax
     15f:	75 3b                	jne    19c <runcmd+0x19c>
      close(1);
     161:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     168:	e8 63 0e 00 00       	call   fd0 <close>
      dup(p[1]);
     16d:	8b 45 e0             	mov    -0x20(%ebp),%eax
     170:	89 04 24             	mov    %eax,(%esp)
     173:	e8 a8 0e 00 00       	call   1020 <dup>
      close(p[0]);
     178:	8b 45 dc             	mov    -0x24(%ebp),%eax
     17b:	89 04 24             	mov    %eax,(%esp)
     17e:	e8 4d 0e 00 00       	call   fd0 <close>
      close(p[1]);
     183:	8b 45 e0             	mov    -0x20(%ebp),%eax
     186:	89 04 24             	mov    %eax,(%esp)
     189:	e8 42 0e 00 00       	call   fd0 <close>
      runcmd(pcmd->left);
     18e:	8b 45 e8             	mov    -0x18(%ebp),%eax
     191:	8b 40 04             	mov    0x4(%eax),%eax
     194:	89 04 24             	mov    %eax,(%esp)
     197:	e8 64 fe ff ff       	call   0 <runcmd>
    }
    if(fork1() == 0){
     19c:	e8 25 02 00 00       	call   3c6 <fork1>
     1a1:	85 c0                	test   %eax,%eax
     1a3:	75 3b                	jne    1e0 <runcmd+0x1e0>
      close(0);
     1a5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
     1ac:	e8 1f 0e 00 00       	call   fd0 <close>
      dup(p[0]);
     1b1:	8b 45 dc             	mov    -0x24(%ebp),%eax
     1b4:	89 04 24             	mov    %eax,(%esp)
     1b7:	e8 64 0e 00 00       	call   1020 <dup>
      close(p[0]);
     1bc:	8b 45 dc             	mov    -0x24(%ebp),%eax
     1bf:	89 04 24             	mov    %eax,(%esp)
     1c2:	e8 09 0e 00 00       	call   fd0 <close>
      close(p[1]);
     1c7:	8b 45 e0             	mov    -0x20(%ebp),%eax
     1ca:	89 04 24             	mov    %eax,(%esp)
     1cd:	e8 fe 0d 00 00       	call   fd0 <close>
      runcmd(pcmd->right);
     1d2:	8b 45 e8             	mov    -0x18(%ebp),%eax
     1d5:	8b 40 08             	mov    0x8(%eax),%eax
     1d8:	89 04 24             	mov    %eax,(%esp)
     1db:	e8 20 fe ff ff       	call   0 <runcmd>
    }
    close(p[0]);
     1e0:	8b 45 dc             	mov    -0x24(%ebp),%eax
     1e3:	89 04 24             	mov    %eax,(%esp)
     1e6:	e8 e5 0d 00 00       	call   fd0 <close>
    close(p[1]);
     1eb:	8b 45 e0             	mov    -0x20(%ebp),%eax
     1ee:	89 04 24             	mov    %eax,(%esp)
     1f1:	e8 da 0d 00 00       	call   fd0 <close>
    wait(0);
     1f6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
     1fd:	e8 ae 0d 00 00       	call   fb0 <wait>
    wait(0);
     202:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
     209:	e8 a2 0d 00 00       	call   fb0 <wait>
    break;
     20e:	eb 1e                	jmp    22e <runcmd+0x22e>
    
  case BACK:
    bcmd = (struct backcmd*)cmd;
     210:	8b 45 08             	mov    0x8(%ebp),%eax
     213:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(fork1() == 0)
     216:	e8 ab 01 00 00       	call   3c6 <fork1>
     21b:	85 c0                	test   %eax,%eax
     21d:	75 0e                	jne    22d <runcmd+0x22d>
      runcmd(bcmd->cmd);
     21f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     222:	8b 40 04             	mov    0x4(%eax),%eax
     225:	89 04 24             	mov    %eax,(%esp)
     228:	e8 d3 fd ff ff       	call   0 <runcmd>
    break;
     22d:	90                   	nop
  }
  exit(EXIT_STATUS_DEFAULT);
     22e:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     235:	e8 6e 0d 00 00       	call   fa8 <exit>

0000023a <getcmd>:
}

int
getcmd(char *buf, int nbuf)
{
     23a:	55                   	push   %ebp
     23b:	89 e5                	mov    %esp,%ebp
     23d:	83 ec 18             	sub    $0x18,%esp
  printf(2, "$ ");
     240:	c7 44 24 04 30 15 00 	movl   $0x1530,0x4(%esp)
     247:	00 
     248:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     24f:	e8 d3 0e 00 00       	call   1127 <printf>
  memset(buf, 0, nbuf);
     254:	8b 45 0c             	mov    0xc(%ebp),%eax
     257:	89 44 24 08          	mov    %eax,0x8(%esp)
     25b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     262:	00 
     263:	8b 45 08             	mov    0x8(%ebp),%eax
     266:	89 04 24             	mov    %eax,(%esp)
     269:	e8 95 0b 00 00       	call   e03 <memset>
  gets(buf, nbuf);
     26e:	8b 45 0c             	mov    0xc(%ebp),%eax
     271:	89 44 24 04          	mov    %eax,0x4(%esp)
     275:	8b 45 08             	mov    0x8(%ebp),%eax
     278:	89 04 24             	mov    %eax,(%esp)
     27b:	e8 da 0b 00 00       	call   e5a <gets>
  if(buf[0] == 0) // EOF
     280:	8b 45 08             	mov    0x8(%ebp),%eax
     283:	0f b6 00             	movzbl (%eax),%eax
     286:	84 c0                	test   %al,%al
     288:	75 07                	jne    291 <getcmd+0x57>
    return -1;
     28a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
     28f:	eb 05                	jmp    296 <getcmd+0x5c>
  return 0;
     291:	b8 00 00 00 00       	mov    $0x0,%eax
}
     296:	c9                   	leave  
     297:	c3                   	ret    

00000298 <main>:

int
main(void)
{
     298:	55                   	push   %ebp
     299:	89 e5                	mov    %esp,%ebp
     29b:	83 e4 f0             	and    $0xfffffff0,%esp
     29e:	83 ec 20             	sub    $0x20,%esp
  static char buf[100];
  int fd;
  
  // Assumes three file descriptors open.
  while((fd = open("console", O_RDWR)) >= 0){
     2a1:	eb 19                	jmp    2bc <main+0x24>
    if(fd >= 3){
     2a3:	83 7c 24 1c 02       	cmpl   $0x2,0x1c(%esp)
     2a8:	7e 12                	jle    2bc <main+0x24>
      close(fd);
     2aa:	8b 44 24 1c          	mov    0x1c(%esp),%eax
     2ae:	89 04 24             	mov    %eax,(%esp)
     2b1:	e8 1a 0d 00 00       	call   fd0 <close>
      break;
     2b6:	90                   	nop
    }
  }
  
  // Read and run input commands.
  while(getcmd(buf, sizeof(buf)) >= 0){
     2b7:	e9 b5 00 00 00       	jmp    371 <main+0xd9>
{
  static char buf[100];
  int fd;
  
  // Assumes three file descriptors open.
  while((fd = open("console", O_RDWR)) >= 0){
     2bc:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
     2c3:	00 
     2c4:	c7 04 24 33 15 00 00 	movl   $0x1533,(%esp)
     2cb:	e8 18 0d 00 00       	call   fe8 <open>
     2d0:	89 44 24 1c          	mov    %eax,0x1c(%esp)
     2d4:	83 7c 24 1c 00       	cmpl   $0x0,0x1c(%esp)
     2d9:	79 c8                	jns    2a3 <main+0xb>
      break;
    }
  }
  
  // Read and run input commands.
  while(getcmd(buf, sizeof(buf)) >= 0){
     2db:	e9 91 00 00 00       	jmp    371 <main+0xd9>
    if(buf[0] == 'c' && buf[1] == 'd' && buf[2] == ' '){
     2e0:	0f b6 05 80 1a 00 00 	movzbl 0x1a80,%eax
     2e7:	3c 63                	cmp    $0x63,%al
     2e9:	75 5a                	jne    345 <main+0xad>
     2eb:	0f b6 05 81 1a 00 00 	movzbl 0x1a81,%eax
     2f2:	3c 64                	cmp    $0x64,%al
     2f4:	75 4f                	jne    345 <main+0xad>
     2f6:	0f b6 05 82 1a 00 00 	movzbl 0x1a82,%eax
     2fd:	3c 20                	cmp    $0x20,%al
     2ff:	75 44                	jne    345 <main+0xad>
      // Clumsy but will have to do for now.
      // Chdir has no effect on the parent if run in the child.
      buf[strlen(buf)-1] = 0;  // chop \n
     301:	c7 04 24 80 1a 00 00 	movl   $0x1a80,(%esp)
     308:	e8 d1 0a 00 00       	call   dde <strlen>
     30d:	83 e8 01             	sub    $0x1,%eax
     310:	c6 80 80 1a 00 00 00 	movb   $0x0,0x1a80(%eax)
      if(chdir(buf+3) < 0)
     317:	c7 04 24 83 1a 00 00 	movl   $0x1a83,(%esp)
     31e:	e8 f5 0c 00 00       	call   1018 <chdir>
     323:	85 c0                	test   %eax,%eax
     325:	79 49                	jns    370 <main+0xd8>
        printf(2, "cannot cd %s\n", buf+3);
     327:	c7 44 24 08 83 1a 00 	movl   $0x1a83,0x8(%esp)
     32e:	00 
     32f:	c7 44 24 04 3b 15 00 	movl   $0x153b,0x4(%esp)
     336:	00 
     337:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     33e:	e8 e4 0d 00 00       	call   1127 <printf>
      continue;
     343:	eb 2b                	jmp    370 <main+0xd8>
    }
    if(fork1() == 0)
     345:	e8 7c 00 00 00       	call   3c6 <fork1>
     34a:	85 c0                	test   %eax,%eax
     34c:	75 14                	jne    362 <main+0xca>
      runcmd(parsecmd(buf));
     34e:	c7 04 24 80 1a 00 00 	movl   $0x1a80,(%esp)
     355:	e8 de 03 00 00       	call   738 <parsecmd>
     35a:	89 04 24             	mov    %eax,(%esp)
     35d:	e8 9e fc ff ff       	call   0 <runcmd>
    wait(0);
     362:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
     369:	e8 42 0c 00 00       	call   fb0 <wait>
     36e:	eb 01                	jmp    371 <main+0xd9>
      // Clumsy but will have to do for now.
      // Chdir has no effect on the parent if run in the child.
      buf[strlen(buf)-1] = 0;  // chop \n
      if(chdir(buf+3) < 0)
        printf(2, "cannot cd %s\n", buf+3);
      continue;
     370:	90                   	nop
      break;
    }
  }
  
  // Read and run input commands.
  while(getcmd(buf, sizeof(buf)) >= 0){
     371:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
     378:	00 
     379:	c7 04 24 80 1a 00 00 	movl   $0x1a80,(%esp)
     380:	e8 b5 fe ff ff       	call   23a <getcmd>
     385:	85 c0                	test   %eax,%eax
     387:	0f 89 53 ff ff ff    	jns    2e0 <main+0x48>
    }
    if(fork1() == 0)
      runcmd(parsecmd(buf));
    wait(0);
  }
  exit(EXIT_STATUS_DEFAULT);
     38d:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     394:	e8 0f 0c 00 00       	call   fa8 <exit>

00000399 <panic>:
}

void
panic(char *s)
{
     399:	55                   	push   %ebp
     39a:	89 e5                	mov    %esp,%ebp
     39c:	83 ec 18             	sub    $0x18,%esp
  printf(2, "%s\n", s);
     39f:	8b 45 08             	mov    0x8(%ebp),%eax
     3a2:	89 44 24 08          	mov    %eax,0x8(%esp)
     3a6:	c7 44 24 04 49 15 00 	movl   $0x1549,0x4(%esp)
     3ad:	00 
     3ae:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     3b5:	e8 6d 0d 00 00       	call   1127 <printf>
  exit(EXIT_STATUS_DEFAULT);
     3ba:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     3c1:	e8 e2 0b 00 00       	call   fa8 <exit>

000003c6 <fork1>:
}

int
fork1(void)
{
     3c6:	55                   	push   %ebp
     3c7:	89 e5                	mov    %esp,%ebp
     3c9:	83 ec 28             	sub    $0x28,%esp
  int pid;
  
  pid = fork();
     3cc:	e8 cf 0b 00 00       	call   fa0 <fork>
     3d1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pid == -1)
     3d4:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
     3d8:	75 0c                	jne    3e6 <fork1+0x20>
    panic("fork");
     3da:	c7 04 24 4d 15 00 00 	movl   $0x154d,(%esp)
     3e1:	e8 b3 ff ff ff       	call   399 <panic>
  return pid;
     3e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     3e9:	c9                   	leave  
     3ea:	c3                   	ret    

000003eb <execcmd>:
//PAGEBREAK!
// Constructors

struct cmd*
execcmd(void)
{
     3eb:	55                   	push   %ebp
     3ec:	89 e5                	mov    %esp,%ebp
     3ee:	83 ec 28             	sub    $0x28,%esp
  struct execcmd *cmd;

  cmd = malloc(sizeof(*cmd));
     3f1:	c7 04 24 54 00 00 00 	movl   $0x54,(%esp)
     3f8:	e8 0e 10 00 00       	call   140b <malloc>
     3fd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(cmd, 0, sizeof(*cmd));
     400:	c7 44 24 08 54 00 00 	movl   $0x54,0x8(%esp)
     407:	00 
     408:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     40f:	00 
     410:	8b 45 f4             	mov    -0xc(%ebp),%eax
     413:	89 04 24             	mov    %eax,(%esp)
     416:	e8 e8 09 00 00       	call   e03 <memset>
  cmd->type = EXEC;
     41b:	8b 45 f4             	mov    -0xc(%ebp),%eax
     41e:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  return (struct cmd*)cmd;
     424:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     427:	c9                   	leave  
     428:	c3                   	ret    

00000429 <redircmd>:

struct cmd*
redircmd(struct cmd *subcmd, char *file, char *efile, int mode, int fd)
{
     429:	55                   	push   %ebp
     42a:	89 e5                	mov    %esp,%ebp
     42c:	83 ec 28             	sub    $0x28,%esp
  struct redircmd *cmd;

  cmd = malloc(sizeof(*cmd));
     42f:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
     436:	e8 d0 0f 00 00       	call   140b <malloc>
     43b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(cmd, 0, sizeof(*cmd));
     43e:	c7 44 24 08 18 00 00 	movl   $0x18,0x8(%esp)
     445:	00 
     446:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     44d:	00 
     44e:	8b 45 f4             	mov    -0xc(%ebp),%eax
     451:	89 04 24             	mov    %eax,(%esp)
     454:	e8 aa 09 00 00       	call   e03 <memset>
  cmd->type = REDIR;
     459:	8b 45 f4             	mov    -0xc(%ebp),%eax
     45c:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  cmd->cmd = subcmd;
     462:	8b 45 f4             	mov    -0xc(%ebp),%eax
     465:	8b 55 08             	mov    0x8(%ebp),%edx
     468:	89 50 04             	mov    %edx,0x4(%eax)
  cmd->file = file;
     46b:	8b 45 f4             	mov    -0xc(%ebp),%eax
     46e:	8b 55 0c             	mov    0xc(%ebp),%edx
     471:	89 50 08             	mov    %edx,0x8(%eax)
  cmd->efile = efile;
     474:	8b 45 f4             	mov    -0xc(%ebp),%eax
     477:	8b 55 10             	mov    0x10(%ebp),%edx
     47a:	89 50 0c             	mov    %edx,0xc(%eax)
  cmd->mode = mode;
     47d:	8b 45 f4             	mov    -0xc(%ebp),%eax
     480:	8b 55 14             	mov    0x14(%ebp),%edx
     483:	89 50 10             	mov    %edx,0x10(%eax)
  cmd->fd = fd;
     486:	8b 45 f4             	mov    -0xc(%ebp),%eax
     489:	8b 55 18             	mov    0x18(%ebp),%edx
     48c:	89 50 14             	mov    %edx,0x14(%eax)
  return (struct cmd*)cmd;
     48f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     492:	c9                   	leave  
     493:	c3                   	ret    

00000494 <pipecmd>:

struct cmd*
pipecmd(struct cmd *left, struct cmd *right)
{
     494:	55                   	push   %ebp
     495:	89 e5                	mov    %esp,%ebp
     497:	83 ec 28             	sub    $0x28,%esp
  struct pipecmd *cmd;

  cmd = malloc(sizeof(*cmd));
     49a:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
     4a1:	e8 65 0f 00 00       	call   140b <malloc>
     4a6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(cmd, 0, sizeof(*cmd));
     4a9:	c7 44 24 08 0c 00 00 	movl   $0xc,0x8(%esp)
     4b0:	00 
     4b1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     4b8:	00 
     4b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
     4bc:	89 04 24             	mov    %eax,(%esp)
     4bf:	e8 3f 09 00 00       	call   e03 <memset>
  cmd->type = PIPE;
     4c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
     4c7:	c7 00 03 00 00 00    	movl   $0x3,(%eax)
  cmd->left = left;
     4cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
     4d0:	8b 55 08             	mov    0x8(%ebp),%edx
     4d3:	89 50 04             	mov    %edx,0x4(%eax)
  cmd->right = right;
     4d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
     4d9:	8b 55 0c             	mov    0xc(%ebp),%edx
     4dc:	89 50 08             	mov    %edx,0x8(%eax)
  return (struct cmd*)cmd;
     4df:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     4e2:	c9                   	leave  
     4e3:	c3                   	ret    

000004e4 <listcmd>:

struct cmd*
listcmd(struct cmd *left, struct cmd *right)
{
     4e4:	55                   	push   %ebp
     4e5:	89 e5                	mov    %esp,%ebp
     4e7:	83 ec 28             	sub    $0x28,%esp
  struct listcmd *cmd;

  cmd = malloc(sizeof(*cmd));
     4ea:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
     4f1:	e8 15 0f 00 00       	call   140b <malloc>
     4f6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(cmd, 0, sizeof(*cmd));
     4f9:	c7 44 24 08 0c 00 00 	movl   $0xc,0x8(%esp)
     500:	00 
     501:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     508:	00 
     509:	8b 45 f4             	mov    -0xc(%ebp),%eax
     50c:	89 04 24             	mov    %eax,(%esp)
     50f:	e8 ef 08 00 00       	call   e03 <memset>
  cmd->type = LIST;
     514:	8b 45 f4             	mov    -0xc(%ebp),%eax
     517:	c7 00 04 00 00 00    	movl   $0x4,(%eax)
  cmd->left = left;
     51d:	8b 45 f4             	mov    -0xc(%ebp),%eax
     520:	8b 55 08             	mov    0x8(%ebp),%edx
     523:	89 50 04             	mov    %edx,0x4(%eax)
  cmd->right = right;
     526:	8b 45 f4             	mov    -0xc(%ebp),%eax
     529:	8b 55 0c             	mov    0xc(%ebp),%edx
     52c:	89 50 08             	mov    %edx,0x8(%eax)
  return (struct cmd*)cmd;
     52f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     532:	c9                   	leave  
     533:	c3                   	ret    

00000534 <backcmd>:

struct cmd*
backcmd(struct cmd *subcmd)
{
     534:	55                   	push   %ebp
     535:	89 e5                	mov    %esp,%ebp
     537:	83 ec 28             	sub    $0x28,%esp
  struct backcmd *cmd;

  cmd = malloc(sizeof(*cmd));
     53a:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
     541:	e8 c5 0e 00 00       	call   140b <malloc>
     546:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(cmd, 0, sizeof(*cmd));
     549:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
     550:	00 
     551:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     558:	00 
     559:	8b 45 f4             	mov    -0xc(%ebp),%eax
     55c:	89 04 24             	mov    %eax,(%esp)
     55f:	e8 9f 08 00 00       	call   e03 <memset>
  cmd->type = BACK;
     564:	8b 45 f4             	mov    -0xc(%ebp),%eax
     567:	c7 00 05 00 00 00    	movl   $0x5,(%eax)
  cmd->cmd = subcmd;
     56d:	8b 45 f4             	mov    -0xc(%ebp),%eax
     570:	8b 55 08             	mov    0x8(%ebp),%edx
     573:	89 50 04             	mov    %edx,0x4(%eax)
  return (struct cmd*)cmd;
     576:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     579:	c9                   	leave  
     57a:	c3                   	ret    

0000057b <gettoken>:
char whitespace[] = " \t\r\n\v";
char symbols[] = "<|>&;()";

int
gettoken(char **ps, char *es, char **q, char **eq)
{
     57b:	55                   	push   %ebp
     57c:	89 e5                	mov    %esp,%ebp
     57e:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int ret;
  
  s = *ps;
     581:	8b 45 08             	mov    0x8(%ebp),%eax
     584:	8b 00                	mov    (%eax),%eax
     586:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(s < es && strchr(whitespace, *s))
     589:	eb 04                	jmp    58f <gettoken+0x14>
    s++;
     58b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
{
  char *s;
  int ret;
  
  s = *ps;
  while(s < es && strchr(whitespace, *s))
     58f:	8b 45 f4             	mov    -0xc(%ebp),%eax
     592:	3b 45 0c             	cmp    0xc(%ebp),%eax
     595:	73 1d                	jae    5b4 <gettoken+0x39>
     597:	8b 45 f4             	mov    -0xc(%ebp),%eax
     59a:	0f b6 00             	movzbl (%eax),%eax
     59d:	0f be c0             	movsbl %al,%eax
     5a0:	89 44 24 04          	mov    %eax,0x4(%esp)
     5a4:	c7 04 24 5c 1a 00 00 	movl   $0x1a5c,(%esp)
     5ab:	e8 77 08 00 00       	call   e27 <strchr>
     5b0:	85 c0                	test   %eax,%eax
     5b2:	75 d7                	jne    58b <gettoken+0x10>
    s++;
  if(q)
     5b4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
     5b8:	74 08                	je     5c2 <gettoken+0x47>
    *q = s;
     5ba:	8b 45 10             	mov    0x10(%ebp),%eax
     5bd:	8b 55 f4             	mov    -0xc(%ebp),%edx
     5c0:	89 10                	mov    %edx,(%eax)
  ret = *s;
     5c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
     5c5:	0f b6 00             	movzbl (%eax),%eax
     5c8:	0f be c0             	movsbl %al,%eax
     5cb:	89 45 f0             	mov    %eax,-0x10(%ebp)
  switch(*s){
     5ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
     5d1:	0f b6 00             	movzbl (%eax),%eax
     5d4:	0f be c0             	movsbl %al,%eax
     5d7:	83 f8 3c             	cmp    $0x3c,%eax
     5da:	7f 1e                	jg     5fa <gettoken+0x7f>
     5dc:	83 f8 3b             	cmp    $0x3b,%eax
     5df:	7d 23                	jge    604 <gettoken+0x89>
     5e1:	83 f8 29             	cmp    $0x29,%eax
     5e4:	7f 3f                	jg     625 <gettoken+0xaa>
     5e6:	83 f8 28             	cmp    $0x28,%eax
     5e9:	7d 19                	jge    604 <gettoken+0x89>
     5eb:	85 c0                	test   %eax,%eax
     5ed:	0f 84 83 00 00 00    	je     676 <gettoken+0xfb>
     5f3:	83 f8 26             	cmp    $0x26,%eax
     5f6:	74 0c                	je     604 <gettoken+0x89>
     5f8:	eb 2b                	jmp    625 <gettoken+0xaa>
     5fa:	83 f8 3e             	cmp    $0x3e,%eax
     5fd:	74 0b                	je     60a <gettoken+0x8f>
     5ff:	83 f8 7c             	cmp    $0x7c,%eax
     602:	75 21                	jne    625 <gettoken+0xaa>
  case '(':
  case ')':
  case ';':
  case '&':
  case '<':
    s++;
     604:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    break;
     608:	eb 73                	jmp    67d <gettoken+0x102>
  case '>':
    s++;
     60a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(*s == '>'){
     60e:	8b 45 f4             	mov    -0xc(%ebp),%eax
     611:	0f b6 00             	movzbl (%eax),%eax
     614:	3c 3e                	cmp    $0x3e,%al
     616:	75 61                	jne    679 <gettoken+0xfe>
      ret = '+';
     618:	c7 45 f0 2b 00 00 00 	movl   $0x2b,-0x10(%ebp)
      s++;
     61f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    }
    break;
     623:	eb 54                	jmp    679 <gettoken+0xfe>
  default:
    ret = 'a';
     625:	c7 45 f0 61 00 00 00 	movl   $0x61,-0x10(%ebp)
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
     62c:	eb 04                	jmp    632 <gettoken+0xb7>
      s++;
     62e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      s++;
    }
    break;
  default:
    ret = 'a';
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
     632:	8b 45 f4             	mov    -0xc(%ebp),%eax
     635:	3b 45 0c             	cmp    0xc(%ebp),%eax
     638:	73 42                	jae    67c <gettoken+0x101>
     63a:	8b 45 f4             	mov    -0xc(%ebp),%eax
     63d:	0f b6 00             	movzbl (%eax),%eax
     640:	0f be c0             	movsbl %al,%eax
     643:	89 44 24 04          	mov    %eax,0x4(%esp)
     647:	c7 04 24 5c 1a 00 00 	movl   $0x1a5c,(%esp)
     64e:	e8 d4 07 00 00       	call   e27 <strchr>
     653:	85 c0                	test   %eax,%eax
     655:	75 25                	jne    67c <gettoken+0x101>
     657:	8b 45 f4             	mov    -0xc(%ebp),%eax
     65a:	0f b6 00             	movzbl (%eax),%eax
     65d:	0f be c0             	movsbl %al,%eax
     660:	89 44 24 04          	mov    %eax,0x4(%esp)
     664:	c7 04 24 62 1a 00 00 	movl   $0x1a62,(%esp)
     66b:	e8 b7 07 00 00       	call   e27 <strchr>
     670:	85 c0                	test   %eax,%eax
     672:	74 ba                	je     62e <gettoken+0xb3>
      s++;
    break;
     674:	eb 06                	jmp    67c <gettoken+0x101>
  if(q)
    *q = s;
  ret = *s;
  switch(*s){
  case 0:
    break;
     676:	90                   	nop
     677:	eb 04                	jmp    67d <gettoken+0x102>
    s++;
    if(*s == '>'){
      ret = '+';
      s++;
    }
    break;
     679:	90                   	nop
     67a:	eb 01                	jmp    67d <gettoken+0x102>
  default:
    ret = 'a';
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
      s++;
    break;
     67c:	90                   	nop
  }
  if(eq)
     67d:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
     681:	74 0e                	je     691 <gettoken+0x116>
    *eq = s;
     683:	8b 45 14             	mov    0x14(%ebp),%eax
     686:	8b 55 f4             	mov    -0xc(%ebp),%edx
     689:	89 10                	mov    %edx,(%eax)
  
  while(s < es && strchr(whitespace, *s))
     68b:	eb 04                	jmp    691 <gettoken+0x116>
    s++;
     68d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    break;
  }
  if(eq)
    *eq = s;
  
  while(s < es && strchr(whitespace, *s))
     691:	8b 45 f4             	mov    -0xc(%ebp),%eax
     694:	3b 45 0c             	cmp    0xc(%ebp),%eax
     697:	73 1d                	jae    6b6 <gettoken+0x13b>
     699:	8b 45 f4             	mov    -0xc(%ebp),%eax
     69c:	0f b6 00             	movzbl (%eax),%eax
     69f:	0f be c0             	movsbl %al,%eax
     6a2:	89 44 24 04          	mov    %eax,0x4(%esp)
     6a6:	c7 04 24 5c 1a 00 00 	movl   $0x1a5c,(%esp)
     6ad:	e8 75 07 00 00       	call   e27 <strchr>
     6b2:	85 c0                	test   %eax,%eax
     6b4:	75 d7                	jne    68d <gettoken+0x112>
    s++;
  *ps = s;
     6b6:	8b 45 08             	mov    0x8(%ebp),%eax
     6b9:	8b 55 f4             	mov    -0xc(%ebp),%edx
     6bc:	89 10                	mov    %edx,(%eax)
  return ret;
     6be:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
     6c1:	c9                   	leave  
     6c2:	c3                   	ret    

000006c3 <peek>:

int
peek(char **ps, char *es, char *toks)
{
     6c3:	55                   	push   %ebp
     6c4:	89 e5                	mov    %esp,%ebp
     6c6:	83 ec 28             	sub    $0x28,%esp
  char *s;
  
  s = *ps;
     6c9:	8b 45 08             	mov    0x8(%ebp),%eax
     6cc:	8b 00                	mov    (%eax),%eax
     6ce:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(s < es && strchr(whitespace, *s))
     6d1:	eb 04                	jmp    6d7 <peek+0x14>
    s++;
     6d3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
peek(char **ps, char *es, char *toks)
{
  char *s;
  
  s = *ps;
  while(s < es && strchr(whitespace, *s))
     6d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
     6da:	3b 45 0c             	cmp    0xc(%ebp),%eax
     6dd:	73 1d                	jae    6fc <peek+0x39>
     6df:	8b 45 f4             	mov    -0xc(%ebp),%eax
     6e2:	0f b6 00             	movzbl (%eax),%eax
     6e5:	0f be c0             	movsbl %al,%eax
     6e8:	89 44 24 04          	mov    %eax,0x4(%esp)
     6ec:	c7 04 24 5c 1a 00 00 	movl   $0x1a5c,(%esp)
     6f3:	e8 2f 07 00 00       	call   e27 <strchr>
     6f8:	85 c0                	test   %eax,%eax
     6fa:	75 d7                	jne    6d3 <peek+0x10>
    s++;
  *ps = s;
     6fc:	8b 45 08             	mov    0x8(%ebp),%eax
     6ff:	8b 55 f4             	mov    -0xc(%ebp),%edx
     702:	89 10                	mov    %edx,(%eax)
  return *s && strchr(toks, *s);
     704:	8b 45 f4             	mov    -0xc(%ebp),%eax
     707:	0f b6 00             	movzbl (%eax),%eax
     70a:	84 c0                	test   %al,%al
     70c:	74 23                	je     731 <peek+0x6e>
     70e:	8b 45 f4             	mov    -0xc(%ebp),%eax
     711:	0f b6 00             	movzbl (%eax),%eax
     714:	0f be c0             	movsbl %al,%eax
     717:	89 44 24 04          	mov    %eax,0x4(%esp)
     71b:	8b 45 10             	mov    0x10(%ebp),%eax
     71e:	89 04 24             	mov    %eax,(%esp)
     721:	e8 01 07 00 00       	call   e27 <strchr>
     726:	85 c0                	test   %eax,%eax
     728:	74 07                	je     731 <peek+0x6e>
     72a:	b8 01 00 00 00       	mov    $0x1,%eax
     72f:	eb 05                	jmp    736 <peek+0x73>
     731:	b8 00 00 00 00       	mov    $0x0,%eax
}
     736:	c9                   	leave  
     737:	c3                   	ret    

00000738 <parsecmd>:
struct cmd *parseexec(char**, char*);
struct cmd *nulterminate(struct cmd*);

struct cmd*
parsecmd(char *s)
{
     738:	55                   	push   %ebp
     739:	89 e5                	mov    %esp,%ebp
     73b:	53                   	push   %ebx
     73c:	83 ec 24             	sub    $0x24,%esp
  char *es;
  struct cmd *cmd;

  es = s + strlen(s);
     73f:	8b 5d 08             	mov    0x8(%ebp),%ebx
     742:	8b 45 08             	mov    0x8(%ebp),%eax
     745:	89 04 24             	mov    %eax,(%esp)
     748:	e8 91 06 00 00       	call   dde <strlen>
     74d:	01 d8                	add    %ebx,%eax
     74f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cmd = parseline(&s, es);
     752:	8b 45 f4             	mov    -0xc(%ebp),%eax
     755:	89 44 24 04          	mov    %eax,0x4(%esp)
     759:	8d 45 08             	lea    0x8(%ebp),%eax
     75c:	89 04 24             	mov    %eax,(%esp)
     75f:	e8 60 00 00 00       	call   7c4 <parseline>
     764:	89 45 f0             	mov    %eax,-0x10(%ebp)
  peek(&s, es, "");
     767:	c7 44 24 08 52 15 00 	movl   $0x1552,0x8(%esp)
     76e:	00 
     76f:	8b 45 f4             	mov    -0xc(%ebp),%eax
     772:	89 44 24 04          	mov    %eax,0x4(%esp)
     776:	8d 45 08             	lea    0x8(%ebp),%eax
     779:	89 04 24             	mov    %eax,(%esp)
     77c:	e8 42 ff ff ff       	call   6c3 <peek>
  if(s != es){
     781:	8b 45 08             	mov    0x8(%ebp),%eax
     784:	3b 45 f4             	cmp    -0xc(%ebp),%eax
     787:	74 27                	je     7b0 <parsecmd+0x78>
    printf(2, "leftovers: %s\n", s);
     789:	8b 45 08             	mov    0x8(%ebp),%eax
     78c:	89 44 24 08          	mov    %eax,0x8(%esp)
     790:	c7 44 24 04 53 15 00 	movl   $0x1553,0x4(%esp)
     797:	00 
     798:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     79f:	e8 83 09 00 00       	call   1127 <printf>
    panic("syntax");
     7a4:	c7 04 24 62 15 00 00 	movl   $0x1562,(%esp)
     7ab:	e8 e9 fb ff ff       	call   399 <panic>
  }
  nulterminate(cmd);
     7b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
     7b3:	89 04 24             	mov    %eax,(%esp)
     7b6:	e8 a5 04 00 00       	call   c60 <nulterminate>
  return cmd;
     7bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
     7be:	83 c4 24             	add    $0x24,%esp
     7c1:	5b                   	pop    %ebx
     7c2:	5d                   	pop    %ebp
     7c3:	c3                   	ret    

000007c4 <parseline>:

struct cmd*
parseline(char **ps, char *es)
{
     7c4:	55                   	push   %ebp
     7c5:	89 e5                	mov    %esp,%ebp
     7c7:	83 ec 28             	sub    $0x28,%esp
  struct cmd *cmd;

  cmd = parsepipe(ps, es);
     7ca:	8b 45 0c             	mov    0xc(%ebp),%eax
     7cd:	89 44 24 04          	mov    %eax,0x4(%esp)
     7d1:	8b 45 08             	mov    0x8(%ebp),%eax
     7d4:	89 04 24             	mov    %eax,(%esp)
     7d7:	e8 bc 00 00 00       	call   898 <parsepipe>
     7dc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(peek(ps, es, "&")){
     7df:	eb 30                	jmp    811 <parseline+0x4d>
    gettoken(ps, es, 0, 0);
     7e1:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
     7e8:	00 
     7e9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
     7f0:	00 
     7f1:	8b 45 0c             	mov    0xc(%ebp),%eax
     7f4:	89 44 24 04          	mov    %eax,0x4(%esp)
     7f8:	8b 45 08             	mov    0x8(%ebp),%eax
     7fb:	89 04 24             	mov    %eax,(%esp)
     7fe:	e8 78 fd ff ff       	call   57b <gettoken>
    cmd = backcmd(cmd);
     803:	8b 45 f4             	mov    -0xc(%ebp),%eax
     806:	89 04 24             	mov    %eax,(%esp)
     809:	e8 26 fd ff ff       	call   534 <backcmd>
     80e:	89 45 f4             	mov    %eax,-0xc(%ebp)
parseline(char **ps, char *es)
{
  struct cmd *cmd;

  cmd = parsepipe(ps, es);
  while(peek(ps, es, "&")){
     811:	c7 44 24 08 69 15 00 	movl   $0x1569,0x8(%esp)
     818:	00 
     819:	8b 45 0c             	mov    0xc(%ebp),%eax
     81c:	89 44 24 04          	mov    %eax,0x4(%esp)
     820:	8b 45 08             	mov    0x8(%ebp),%eax
     823:	89 04 24             	mov    %eax,(%esp)
     826:	e8 98 fe ff ff       	call   6c3 <peek>
     82b:	85 c0                	test   %eax,%eax
     82d:	75 b2                	jne    7e1 <parseline+0x1d>
    gettoken(ps, es, 0, 0);
    cmd = backcmd(cmd);
  }
  if(peek(ps, es, ";")){
     82f:	c7 44 24 08 6b 15 00 	movl   $0x156b,0x8(%esp)
     836:	00 
     837:	8b 45 0c             	mov    0xc(%ebp),%eax
     83a:	89 44 24 04          	mov    %eax,0x4(%esp)
     83e:	8b 45 08             	mov    0x8(%ebp),%eax
     841:	89 04 24             	mov    %eax,(%esp)
     844:	e8 7a fe ff ff       	call   6c3 <peek>
     849:	85 c0                	test   %eax,%eax
     84b:	74 46                	je     893 <parseline+0xcf>
    gettoken(ps, es, 0, 0);
     84d:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
     854:	00 
     855:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
     85c:	00 
     85d:	8b 45 0c             	mov    0xc(%ebp),%eax
     860:	89 44 24 04          	mov    %eax,0x4(%esp)
     864:	8b 45 08             	mov    0x8(%ebp),%eax
     867:	89 04 24             	mov    %eax,(%esp)
     86a:	e8 0c fd ff ff       	call   57b <gettoken>
    cmd = listcmd(cmd, parseline(ps, es));
     86f:	8b 45 0c             	mov    0xc(%ebp),%eax
     872:	89 44 24 04          	mov    %eax,0x4(%esp)
     876:	8b 45 08             	mov    0x8(%ebp),%eax
     879:	89 04 24             	mov    %eax,(%esp)
     87c:	e8 43 ff ff ff       	call   7c4 <parseline>
     881:	89 44 24 04          	mov    %eax,0x4(%esp)
     885:	8b 45 f4             	mov    -0xc(%ebp),%eax
     888:	89 04 24             	mov    %eax,(%esp)
     88b:	e8 54 fc ff ff       	call   4e4 <listcmd>
     890:	89 45 f4             	mov    %eax,-0xc(%ebp)
  }
  return cmd;
     893:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     896:	c9                   	leave  
     897:	c3                   	ret    

00000898 <parsepipe>:

struct cmd*
parsepipe(char **ps, char *es)
{
     898:	55                   	push   %ebp
     899:	89 e5                	mov    %esp,%ebp
     89b:	83 ec 28             	sub    $0x28,%esp
  struct cmd *cmd;

  cmd = parseexec(ps, es);
     89e:	8b 45 0c             	mov    0xc(%ebp),%eax
     8a1:	89 44 24 04          	mov    %eax,0x4(%esp)
     8a5:	8b 45 08             	mov    0x8(%ebp),%eax
     8a8:	89 04 24             	mov    %eax,(%esp)
     8ab:	e8 68 02 00 00       	call   b18 <parseexec>
     8b0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(peek(ps, es, "|")){
     8b3:	c7 44 24 08 6d 15 00 	movl   $0x156d,0x8(%esp)
     8ba:	00 
     8bb:	8b 45 0c             	mov    0xc(%ebp),%eax
     8be:	89 44 24 04          	mov    %eax,0x4(%esp)
     8c2:	8b 45 08             	mov    0x8(%ebp),%eax
     8c5:	89 04 24             	mov    %eax,(%esp)
     8c8:	e8 f6 fd ff ff       	call   6c3 <peek>
     8cd:	85 c0                	test   %eax,%eax
     8cf:	74 46                	je     917 <parsepipe+0x7f>
    gettoken(ps, es, 0, 0);
     8d1:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
     8d8:	00 
     8d9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
     8e0:	00 
     8e1:	8b 45 0c             	mov    0xc(%ebp),%eax
     8e4:	89 44 24 04          	mov    %eax,0x4(%esp)
     8e8:	8b 45 08             	mov    0x8(%ebp),%eax
     8eb:	89 04 24             	mov    %eax,(%esp)
     8ee:	e8 88 fc ff ff       	call   57b <gettoken>
    cmd = pipecmd(cmd, parsepipe(ps, es));
     8f3:	8b 45 0c             	mov    0xc(%ebp),%eax
     8f6:	89 44 24 04          	mov    %eax,0x4(%esp)
     8fa:	8b 45 08             	mov    0x8(%ebp),%eax
     8fd:	89 04 24             	mov    %eax,(%esp)
     900:	e8 93 ff ff ff       	call   898 <parsepipe>
     905:	89 44 24 04          	mov    %eax,0x4(%esp)
     909:	8b 45 f4             	mov    -0xc(%ebp),%eax
     90c:	89 04 24             	mov    %eax,(%esp)
     90f:	e8 80 fb ff ff       	call   494 <pipecmd>
     914:	89 45 f4             	mov    %eax,-0xc(%ebp)
  }
  return cmd;
     917:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     91a:	c9                   	leave  
     91b:	c3                   	ret    

0000091c <parseredirs>:

struct cmd*
parseredirs(struct cmd *cmd, char **ps, char *es)
{
     91c:	55                   	push   %ebp
     91d:	89 e5                	mov    %esp,%ebp
     91f:	83 ec 38             	sub    $0x38,%esp
  int tok;
  char *q, *eq;

  while(peek(ps, es, "<>")){
     922:	e9 f6 00 00 00       	jmp    a1d <parseredirs+0x101>
    tok = gettoken(ps, es, 0, 0);
     927:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
     92e:	00 
     92f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
     936:	00 
     937:	8b 45 10             	mov    0x10(%ebp),%eax
     93a:	89 44 24 04          	mov    %eax,0x4(%esp)
     93e:	8b 45 0c             	mov    0xc(%ebp),%eax
     941:	89 04 24             	mov    %eax,(%esp)
     944:	e8 32 fc ff ff       	call   57b <gettoken>
     949:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(gettoken(ps, es, &q, &eq) != 'a')
     94c:	8d 45 ec             	lea    -0x14(%ebp),%eax
     94f:	89 44 24 0c          	mov    %eax,0xc(%esp)
     953:	8d 45 f0             	lea    -0x10(%ebp),%eax
     956:	89 44 24 08          	mov    %eax,0x8(%esp)
     95a:	8b 45 10             	mov    0x10(%ebp),%eax
     95d:	89 44 24 04          	mov    %eax,0x4(%esp)
     961:	8b 45 0c             	mov    0xc(%ebp),%eax
     964:	89 04 24             	mov    %eax,(%esp)
     967:	e8 0f fc ff ff       	call   57b <gettoken>
     96c:	83 f8 61             	cmp    $0x61,%eax
     96f:	74 0c                	je     97d <parseredirs+0x61>
      panic("missing file for redirection");
     971:	c7 04 24 6f 15 00 00 	movl   $0x156f,(%esp)
     978:	e8 1c fa ff ff       	call   399 <panic>
    switch(tok){
     97d:	8b 45 f4             	mov    -0xc(%ebp),%eax
     980:	83 f8 3c             	cmp    $0x3c,%eax
     983:	74 0f                	je     994 <parseredirs+0x78>
     985:	83 f8 3e             	cmp    $0x3e,%eax
     988:	74 38                	je     9c2 <parseredirs+0xa6>
     98a:	83 f8 2b             	cmp    $0x2b,%eax
     98d:	74 61                	je     9f0 <parseredirs+0xd4>
     98f:	e9 89 00 00 00       	jmp    a1d <parseredirs+0x101>
    case '<':
      cmd = redircmd(cmd, q, eq, O_RDONLY, 0);
     994:	8b 55 ec             	mov    -0x14(%ebp),%edx
     997:	8b 45 f0             	mov    -0x10(%ebp),%eax
     99a:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
     9a1:	00 
     9a2:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
     9a9:	00 
     9aa:	89 54 24 08          	mov    %edx,0x8(%esp)
     9ae:	89 44 24 04          	mov    %eax,0x4(%esp)
     9b2:	8b 45 08             	mov    0x8(%ebp),%eax
     9b5:	89 04 24             	mov    %eax,(%esp)
     9b8:	e8 6c fa ff ff       	call   429 <redircmd>
     9bd:	89 45 08             	mov    %eax,0x8(%ebp)
      break;
     9c0:	eb 5b                	jmp    a1d <parseredirs+0x101>
    case '>':
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE, 1);
     9c2:	8b 55 ec             	mov    -0x14(%ebp),%edx
     9c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
     9c8:	c7 44 24 10 01 00 00 	movl   $0x1,0x10(%esp)
     9cf:	00 
     9d0:	c7 44 24 0c 01 02 00 	movl   $0x201,0xc(%esp)
     9d7:	00 
     9d8:	89 54 24 08          	mov    %edx,0x8(%esp)
     9dc:	89 44 24 04          	mov    %eax,0x4(%esp)
     9e0:	8b 45 08             	mov    0x8(%ebp),%eax
     9e3:	89 04 24             	mov    %eax,(%esp)
     9e6:	e8 3e fa ff ff       	call   429 <redircmd>
     9eb:	89 45 08             	mov    %eax,0x8(%ebp)
      break;
     9ee:	eb 2d                	jmp    a1d <parseredirs+0x101>
    case '+':  // >>
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE, 1);
     9f0:	8b 55 ec             	mov    -0x14(%ebp),%edx
     9f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
     9f6:	c7 44 24 10 01 00 00 	movl   $0x1,0x10(%esp)
     9fd:	00 
     9fe:	c7 44 24 0c 01 02 00 	movl   $0x201,0xc(%esp)
     a05:	00 
     a06:	89 54 24 08          	mov    %edx,0x8(%esp)
     a0a:	89 44 24 04          	mov    %eax,0x4(%esp)
     a0e:	8b 45 08             	mov    0x8(%ebp),%eax
     a11:	89 04 24             	mov    %eax,(%esp)
     a14:	e8 10 fa ff ff       	call   429 <redircmd>
     a19:	89 45 08             	mov    %eax,0x8(%ebp)
      break;
     a1c:	90                   	nop
parseredirs(struct cmd *cmd, char **ps, char *es)
{
  int tok;
  char *q, *eq;

  while(peek(ps, es, "<>")){
     a1d:	c7 44 24 08 8c 15 00 	movl   $0x158c,0x8(%esp)
     a24:	00 
     a25:	8b 45 10             	mov    0x10(%ebp),%eax
     a28:	89 44 24 04          	mov    %eax,0x4(%esp)
     a2c:	8b 45 0c             	mov    0xc(%ebp),%eax
     a2f:	89 04 24             	mov    %eax,(%esp)
     a32:	e8 8c fc ff ff       	call   6c3 <peek>
     a37:	85 c0                	test   %eax,%eax
     a39:	0f 85 e8 fe ff ff    	jne    927 <parseredirs+0xb>
    case '+':  // >>
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE, 1);
      break;
    }
  }
  return cmd;
     a3f:	8b 45 08             	mov    0x8(%ebp),%eax
}
     a42:	c9                   	leave  
     a43:	c3                   	ret    

00000a44 <parseblock>:

struct cmd*
parseblock(char **ps, char *es)
{
     a44:	55                   	push   %ebp
     a45:	89 e5                	mov    %esp,%ebp
     a47:	83 ec 28             	sub    $0x28,%esp
  struct cmd *cmd;

  if(!peek(ps, es, "("))
     a4a:	c7 44 24 08 8f 15 00 	movl   $0x158f,0x8(%esp)
     a51:	00 
     a52:	8b 45 0c             	mov    0xc(%ebp),%eax
     a55:	89 44 24 04          	mov    %eax,0x4(%esp)
     a59:	8b 45 08             	mov    0x8(%ebp),%eax
     a5c:	89 04 24             	mov    %eax,(%esp)
     a5f:	e8 5f fc ff ff       	call   6c3 <peek>
     a64:	85 c0                	test   %eax,%eax
     a66:	75 0c                	jne    a74 <parseblock+0x30>
    panic("parseblock");
     a68:	c7 04 24 91 15 00 00 	movl   $0x1591,(%esp)
     a6f:	e8 25 f9 ff ff       	call   399 <panic>
  gettoken(ps, es, 0, 0);
     a74:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
     a7b:	00 
     a7c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
     a83:	00 
     a84:	8b 45 0c             	mov    0xc(%ebp),%eax
     a87:	89 44 24 04          	mov    %eax,0x4(%esp)
     a8b:	8b 45 08             	mov    0x8(%ebp),%eax
     a8e:	89 04 24             	mov    %eax,(%esp)
     a91:	e8 e5 fa ff ff       	call   57b <gettoken>
  cmd = parseline(ps, es);
     a96:	8b 45 0c             	mov    0xc(%ebp),%eax
     a99:	89 44 24 04          	mov    %eax,0x4(%esp)
     a9d:	8b 45 08             	mov    0x8(%ebp),%eax
     aa0:	89 04 24             	mov    %eax,(%esp)
     aa3:	e8 1c fd ff ff       	call   7c4 <parseline>
     aa8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(!peek(ps, es, ")"))
     aab:	c7 44 24 08 9c 15 00 	movl   $0x159c,0x8(%esp)
     ab2:	00 
     ab3:	8b 45 0c             	mov    0xc(%ebp),%eax
     ab6:	89 44 24 04          	mov    %eax,0x4(%esp)
     aba:	8b 45 08             	mov    0x8(%ebp),%eax
     abd:	89 04 24             	mov    %eax,(%esp)
     ac0:	e8 fe fb ff ff       	call   6c3 <peek>
     ac5:	85 c0                	test   %eax,%eax
     ac7:	75 0c                	jne    ad5 <parseblock+0x91>
    panic("syntax - missing )");
     ac9:	c7 04 24 9e 15 00 00 	movl   $0x159e,(%esp)
     ad0:	e8 c4 f8 ff ff       	call   399 <panic>
  gettoken(ps, es, 0, 0);
     ad5:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
     adc:	00 
     add:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
     ae4:	00 
     ae5:	8b 45 0c             	mov    0xc(%ebp),%eax
     ae8:	89 44 24 04          	mov    %eax,0x4(%esp)
     aec:	8b 45 08             	mov    0x8(%ebp),%eax
     aef:	89 04 24             	mov    %eax,(%esp)
     af2:	e8 84 fa ff ff       	call   57b <gettoken>
  cmd = parseredirs(cmd, ps, es);
     af7:	8b 45 0c             	mov    0xc(%ebp),%eax
     afa:	89 44 24 08          	mov    %eax,0x8(%esp)
     afe:	8b 45 08             	mov    0x8(%ebp),%eax
     b01:	89 44 24 04          	mov    %eax,0x4(%esp)
     b05:	8b 45 f4             	mov    -0xc(%ebp),%eax
     b08:	89 04 24             	mov    %eax,(%esp)
     b0b:	e8 0c fe ff ff       	call   91c <parseredirs>
     b10:	89 45 f4             	mov    %eax,-0xc(%ebp)
  return cmd;
     b13:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     b16:	c9                   	leave  
     b17:	c3                   	ret    

00000b18 <parseexec>:

struct cmd*
parseexec(char **ps, char *es)
{
     b18:	55                   	push   %ebp
     b19:	89 e5                	mov    %esp,%ebp
     b1b:	83 ec 38             	sub    $0x38,%esp
  char *q, *eq;
  int tok, argc;
  struct execcmd *cmd;
  struct cmd *ret;
  
  if(peek(ps, es, "("))
     b1e:	c7 44 24 08 8f 15 00 	movl   $0x158f,0x8(%esp)
     b25:	00 
     b26:	8b 45 0c             	mov    0xc(%ebp),%eax
     b29:	89 44 24 04          	mov    %eax,0x4(%esp)
     b2d:	8b 45 08             	mov    0x8(%ebp),%eax
     b30:	89 04 24             	mov    %eax,(%esp)
     b33:	e8 8b fb ff ff       	call   6c3 <peek>
     b38:	85 c0                	test   %eax,%eax
     b3a:	74 17                	je     b53 <parseexec+0x3b>
    return parseblock(ps, es);
     b3c:	8b 45 0c             	mov    0xc(%ebp),%eax
     b3f:	89 44 24 04          	mov    %eax,0x4(%esp)
     b43:	8b 45 08             	mov    0x8(%ebp),%eax
     b46:	89 04 24             	mov    %eax,(%esp)
     b49:	e8 f6 fe ff ff       	call   a44 <parseblock>
     b4e:	e9 0b 01 00 00       	jmp    c5e <parseexec+0x146>

  ret = execcmd();
     b53:	e8 93 f8 ff ff       	call   3eb <execcmd>
     b58:	89 45 f0             	mov    %eax,-0x10(%ebp)
  cmd = (struct execcmd*)ret;
     b5b:	8b 45 f0             	mov    -0x10(%ebp),%eax
     b5e:	89 45 ec             	mov    %eax,-0x14(%ebp)

  argc = 0;
     b61:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  ret = parseredirs(ret, ps, es);
     b68:	8b 45 0c             	mov    0xc(%ebp),%eax
     b6b:	89 44 24 08          	mov    %eax,0x8(%esp)
     b6f:	8b 45 08             	mov    0x8(%ebp),%eax
     b72:	89 44 24 04          	mov    %eax,0x4(%esp)
     b76:	8b 45 f0             	mov    -0x10(%ebp),%eax
     b79:	89 04 24             	mov    %eax,(%esp)
     b7c:	e8 9b fd ff ff       	call   91c <parseredirs>
     b81:	89 45 f0             	mov    %eax,-0x10(%ebp)
  while(!peek(ps, es, "|)&;")){
     b84:	e9 8e 00 00 00       	jmp    c17 <parseexec+0xff>
    if((tok=gettoken(ps, es, &q, &eq)) == 0)
     b89:	8d 45 e0             	lea    -0x20(%ebp),%eax
     b8c:	89 44 24 0c          	mov    %eax,0xc(%esp)
     b90:	8d 45 e4             	lea    -0x1c(%ebp),%eax
     b93:	89 44 24 08          	mov    %eax,0x8(%esp)
     b97:	8b 45 0c             	mov    0xc(%ebp),%eax
     b9a:	89 44 24 04          	mov    %eax,0x4(%esp)
     b9e:	8b 45 08             	mov    0x8(%ebp),%eax
     ba1:	89 04 24             	mov    %eax,(%esp)
     ba4:	e8 d2 f9 ff ff       	call   57b <gettoken>
     ba9:	89 45 e8             	mov    %eax,-0x18(%ebp)
     bac:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
     bb0:	0f 84 85 00 00 00    	je     c3b <parseexec+0x123>
      break;
    if(tok != 'a')
     bb6:	83 7d e8 61          	cmpl   $0x61,-0x18(%ebp)
     bba:	74 0c                	je     bc8 <parseexec+0xb0>
      panic("syntax");
     bbc:	c7 04 24 62 15 00 00 	movl   $0x1562,(%esp)
     bc3:	e8 d1 f7 ff ff       	call   399 <panic>
    cmd->argv[argc] = q;
     bc8:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
     bcb:	8b 45 ec             	mov    -0x14(%ebp),%eax
     bce:	8b 55 f4             	mov    -0xc(%ebp),%edx
     bd1:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
    cmd->eargv[argc] = eq;
     bd5:	8b 55 e0             	mov    -0x20(%ebp),%edx
     bd8:	8b 45 ec             	mov    -0x14(%ebp),%eax
     bdb:	8b 4d f4             	mov    -0xc(%ebp),%ecx
     bde:	83 c1 08             	add    $0x8,%ecx
     be1:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    argc++;
     be5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(argc >= MAXARGS)
     be9:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
     bed:	7e 0c                	jle    bfb <parseexec+0xe3>
      panic("too many args");
     bef:	c7 04 24 b1 15 00 00 	movl   $0x15b1,(%esp)
     bf6:	e8 9e f7 ff ff       	call   399 <panic>
    ret = parseredirs(ret, ps, es);
     bfb:	8b 45 0c             	mov    0xc(%ebp),%eax
     bfe:	89 44 24 08          	mov    %eax,0x8(%esp)
     c02:	8b 45 08             	mov    0x8(%ebp),%eax
     c05:	89 44 24 04          	mov    %eax,0x4(%esp)
     c09:	8b 45 f0             	mov    -0x10(%ebp),%eax
     c0c:	89 04 24             	mov    %eax,(%esp)
     c0f:	e8 08 fd ff ff       	call   91c <parseredirs>
     c14:	89 45 f0             	mov    %eax,-0x10(%ebp)
  ret = execcmd();
  cmd = (struct execcmd*)ret;

  argc = 0;
  ret = parseredirs(ret, ps, es);
  while(!peek(ps, es, "|)&;")){
     c17:	c7 44 24 08 bf 15 00 	movl   $0x15bf,0x8(%esp)
     c1e:	00 
     c1f:	8b 45 0c             	mov    0xc(%ebp),%eax
     c22:	89 44 24 04          	mov    %eax,0x4(%esp)
     c26:	8b 45 08             	mov    0x8(%ebp),%eax
     c29:	89 04 24             	mov    %eax,(%esp)
     c2c:	e8 92 fa ff ff       	call   6c3 <peek>
     c31:	85 c0                	test   %eax,%eax
     c33:	0f 84 50 ff ff ff    	je     b89 <parseexec+0x71>
     c39:	eb 01                	jmp    c3c <parseexec+0x124>
    if((tok=gettoken(ps, es, &q, &eq)) == 0)
      break;
     c3b:	90                   	nop
    argc++;
    if(argc >= MAXARGS)
      panic("too many args");
    ret = parseredirs(ret, ps, es);
  }
  cmd->argv[argc] = 0;
     c3c:	8b 45 ec             	mov    -0x14(%ebp),%eax
     c3f:	8b 55 f4             	mov    -0xc(%ebp),%edx
     c42:	c7 44 90 04 00 00 00 	movl   $0x0,0x4(%eax,%edx,4)
     c49:	00 
  cmd->eargv[argc] = 0;
     c4a:	8b 45 ec             	mov    -0x14(%ebp),%eax
     c4d:	8b 55 f4             	mov    -0xc(%ebp),%edx
     c50:	83 c2 08             	add    $0x8,%edx
     c53:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
     c5a:	00 
  return ret;
     c5b:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
     c5e:	c9                   	leave  
     c5f:	c3                   	ret    

00000c60 <nulterminate>:

// NUL-terminate all the counted strings.
struct cmd*
nulterminate(struct cmd *cmd)
{
     c60:	55                   	push   %ebp
     c61:	89 e5                	mov    %esp,%ebp
     c63:	83 ec 38             	sub    $0x38,%esp
  struct execcmd *ecmd;
  struct listcmd *lcmd;
  struct pipecmd *pcmd;
  struct redircmd *rcmd;

  if(cmd == 0)
     c66:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
     c6a:	75 0a                	jne    c76 <nulterminate+0x16>
    return 0;
     c6c:	b8 00 00 00 00       	mov    $0x0,%eax
     c71:	e9 c9 00 00 00       	jmp    d3f <nulterminate+0xdf>
  
  switch(cmd->type){
     c76:	8b 45 08             	mov    0x8(%ebp),%eax
     c79:	8b 00                	mov    (%eax),%eax
     c7b:	83 f8 05             	cmp    $0x5,%eax
     c7e:	0f 87 b8 00 00 00    	ja     d3c <nulterminate+0xdc>
     c84:	8b 04 85 c4 15 00 00 	mov    0x15c4(,%eax,4),%eax
     c8b:	ff e0                	jmp    *%eax
  case EXEC:
    ecmd = (struct execcmd*)cmd;
     c8d:	8b 45 08             	mov    0x8(%ebp),%eax
     c90:	89 45 f0             	mov    %eax,-0x10(%ebp)
    for(i=0; ecmd->argv[i]; i++)
     c93:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     c9a:	eb 14                	jmp    cb0 <nulterminate+0x50>
      *ecmd->eargv[i] = 0;
     c9c:	8b 45 f0             	mov    -0x10(%ebp),%eax
     c9f:	8b 55 f4             	mov    -0xc(%ebp),%edx
     ca2:	83 c2 08             	add    $0x8,%edx
     ca5:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
     ca9:	c6 00 00             	movb   $0x0,(%eax)
    return 0;
  
  switch(cmd->type){
  case EXEC:
    ecmd = (struct execcmd*)cmd;
    for(i=0; ecmd->argv[i]; i++)
     cac:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
     cb0:	8b 45 f0             	mov    -0x10(%ebp),%eax
     cb3:	8b 55 f4             	mov    -0xc(%ebp),%edx
     cb6:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
     cba:	85 c0                	test   %eax,%eax
     cbc:	75 de                	jne    c9c <nulterminate+0x3c>
      *ecmd->eargv[i] = 0;
    break;
     cbe:	eb 7c                	jmp    d3c <nulterminate+0xdc>

  case REDIR:
    rcmd = (struct redircmd*)cmd;
     cc0:	8b 45 08             	mov    0x8(%ebp),%eax
     cc3:	89 45 ec             	mov    %eax,-0x14(%ebp)
    nulterminate(rcmd->cmd);
     cc6:	8b 45 ec             	mov    -0x14(%ebp),%eax
     cc9:	8b 40 04             	mov    0x4(%eax),%eax
     ccc:	89 04 24             	mov    %eax,(%esp)
     ccf:	e8 8c ff ff ff       	call   c60 <nulterminate>
    *rcmd->efile = 0;
     cd4:	8b 45 ec             	mov    -0x14(%ebp),%eax
     cd7:	8b 40 0c             	mov    0xc(%eax),%eax
     cda:	c6 00 00             	movb   $0x0,(%eax)
    break;
     cdd:	eb 5d                	jmp    d3c <nulterminate+0xdc>

  case PIPE:
    pcmd = (struct pipecmd*)cmd;
     cdf:	8b 45 08             	mov    0x8(%ebp),%eax
     ce2:	89 45 e8             	mov    %eax,-0x18(%ebp)
    nulterminate(pcmd->left);
     ce5:	8b 45 e8             	mov    -0x18(%ebp),%eax
     ce8:	8b 40 04             	mov    0x4(%eax),%eax
     ceb:	89 04 24             	mov    %eax,(%esp)
     cee:	e8 6d ff ff ff       	call   c60 <nulterminate>
    nulterminate(pcmd->right);
     cf3:	8b 45 e8             	mov    -0x18(%ebp),%eax
     cf6:	8b 40 08             	mov    0x8(%eax),%eax
     cf9:	89 04 24             	mov    %eax,(%esp)
     cfc:	e8 5f ff ff ff       	call   c60 <nulterminate>
    break;
     d01:	eb 39                	jmp    d3c <nulterminate+0xdc>
    
  case LIST:
    lcmd = (struct listcmd*)cmd;
     d03:	8b 45 08             	mov    0x8(%ebp),%eax
     d06:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    nulterminate(lcmd->left);
     d09:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     d0c:	8b 40 04             	mov    0x4(%eax),%eax
     d0f:	89 04 24             	mov    %eax,(%esp)
     d12:	e8 49 ff ff ff       	call   c60 <nulterminate>
    nulterminate(lcmd->right);
     d17:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     d1a:	8b 40 08             	mov    0x8(%eax),%eax
     d1d:	89 04 24             	mov    %eax,(%esp)
     d20:	e8 3b ff ff ff       	call   c60 <nulterminate>
    break;
     d25:	eb 15                	jmp    d3c <nulterminate+0xdc>

  case BACK:
    bcmd = (struct backcmd*)cmd;
     d27:	8b 45 08             	mov    0x8(%ebp),%eax
     d2a:	89 45 e0             	mov    %eax,-0x20(%ebp)
    nulterminate(bcmd->cmd);
     d2d:	8b 45 e0             	mov    -0x20(%ebp),%eax
     d30:	8b 40 04             	mov    0x4(%eax),%eax
     d33:	89 04 24             	mov    %eax,(%esp)
     d36:	e8 25 ff ff ff       	call   c60 <nulterminate>
    break;
     d3b:	90                   	nop
  }
  return cmd;
     d3c:	8b 45 08             	mov    0x8(%ebp),%eax
}
     d3f:	c9                   	leave  
     d40:	c3                   	ret    
     d41:	90                   	nop
     d42:	90                   	nop
     d43:	90                   	nop

00000d44 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
     d44:	55                   	push   %ebp
     d45:	89 e5                	mov    %esp,%ebp
     d47:	57                   	push   %edi
     d48:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
     d49:	8b 4d 08             	mov    0x8(%ebp),%ecx
     d4c:	8b 55 10             	mov    0x10(%ebp),%edx
     d4f:	8b 45 0c             	mov    0xc(%ebp),%eax
     d52:	89 cb                	mov    %ecx,%ebx
     d54:	89 df                	mov    %ebx,%edi
     d56:	89 d1                	mov    %edx,%ecx
     d58:	fc                   	cld    
     d59:	f3 aa                	rep stos %al,%es:(%edi)
     d5b:	89 ca                	mov    %ecx,%edx
     d5d:	89 fb                	mov    %edi,%ebx
     d5f:	89 5d 08             	mov    %ebx,0x8(%ebp)
     d62:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
     d65:	5b                   	pop    %ebx
     d66:	5f                   	pop    %edi
     d67:	5d                   	pop    %ebp
     d68:	c3                   	ret    

00000d69 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
     d69:	55                   	push   %ebp
     d6a:	89 e5                	mov    %esp,%ebp
     d6c:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
     d6f:	8b 45 08             	mov    0x8(%ebp),%eax
     d72:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
     d75:	90                   	nop
     d76:	8b 45 0c             	mov    0xc(%ebp),%eax
     d79:	0f b6 10             	movzbl (%eax),%edx
     d7c:	8b 45 08             	mov    0x8(%ebp),%eax
     d7f:	88 10                	mov    %dl,(%eax)
     d81:	8b 45 08             	mov    0x8(%ebp),%eax
     d84:	0f b6 00             	movzbl (%eax),%eax
     d87:	84 c0                	test   %al,%al
     d89:	0f 95 c0             	setne  %al
     d8c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
     d90:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
     d94:	84 c0                	test   %al,%al
     d96:	75 de                	jne    d76 <strcpy+0xd>
    ;
  return os;
     d98:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
     d9b:	c9                   	leave  
     d9c:	c3                   	ret    

00000d9d <strcmp>:

int
strcmp(const char *p, const char *q)
{
     d9d:	55                   	push   %ebp
     d9e:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
     da0:	eb 08                	jmp    daa <strcmp+0xd>
    p++, q++;
     da2:	83 45 08 01          	addl   $0x1,0x8(%ebp)
     da6:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
     daa:	8b 45 08             	mov    0x8(%ebp),%eax
     dad:	0f b6 00             	movzbl (%eax),%eax
     db0:	84 c0                	test   %al,%al
     db2:	74 10                	je     dc4 <strcmp+0x27>
     db4:	8b 45 08             	mov    0x8(%ebp),%eax
     db7:	0f b6 10             	movzbl (%eax),%edx
     dba:	8b 45 0c             	mov    0xc(%ebp),%eax
     dbd:	0f b6 00             	movzbl (%eax),%eax
     dc0:	38 c2                	cmp    %al,%dl
     dc2:	74 de                	je     da2 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
     dc4:	8b 45 08             	mov    0x8(%ebp),%eax
     dc7:	0f b6 00             	movzbl (%eax),%eax
     dca:	0f b6 d0             	movzbl %al,%edx
     dcd:	8b 45 0c             	mov    0xc(%ebp),%eax
     dd0:	0f b6 00             	movzbl (%eax),%eax
     dd3:	0f b6 c0             	movzbl %al,%eax
     dd6:	89 d1                	mov    %edx,%ecx
     dd8:	29 c1                	sub    %eax,%ecx
     dda:	89 c8                	mov    %ecx,%eax
}
     ddc:	5d                   	pop    %ebp
     ddd:	c3                   	ret    

00000dde <strlen>:

uint
strlen(char *s)
{
     dde:	55                   	push   %ebp
     ddf:	89 e5                	mov    %esp,%ebp
     de1:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
     de4:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
     deb:	eb 04                	jmp    df1 <strlen+0x13>
     ded:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
     df1:	8b 45 fc             	mov    -0x4(%ebp),%eax
     df4:	03 45 08             	add    0x8(%ebp),%eax
     df7:	0f b6 00             	movzbl (%eax),%eax
     dfa:	84 c0                	test   %al,%al
     dfc:	75 ef                	jne    ded <strlen+0xf>
    ;
  return n;
     dfe:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
     e01:	c9                   	leave  
     e02:	c3                   	ret    

00000e03 <memset>:

void*
memset(void *dst, int c, uint n)
{
     e03:	55                   	push   %ebp
     e04:	89 e5                	mov    %esp,%ebp
     e06:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
     e09:	8b 45 10             	mov    0x10(%ebp),%eax
     e0c:	89 44 24 08          	mov    %eax,0x8(%esp)
     e10:	8b 45 0c             	mov    0xc(%ebp),%eax
     e13:	89 44 24 04          	mov    %eax,0x4(%esp)
     e17:	8b 45 08             	mov    0x8(%ebp),%eax
     e1a:	89 04 24             	mov    %eax,(%esp)
     e1d:	e8 22 ff ff ff       	call   d44 <stosb>
  return dst;
     e22:	8b 45 08             	mov    0x8(%ebp),%eax
}
     e25:	c9                   	leave  
     e26:	c3                   	ret    

00000e27 <strchr>:

char*
strchr(const char *s, char c)
{
     e27:	55                   	push   %ebp
     e28:	89 e5                	mov    %esp,%ebp
     e2a:	83 ec 04             	sub    $0x4,%esp
     e2d:	8b 45 0c             	mov    0xc(%ebp),%eax
     e30:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
     e33:	eb 14                	jmp    e49 <strchr+0x22>
    if(*s == c)
     e35:	8b 45 08             	mov    0x8(%ebp),%eax
     e38:	0f b6 00             	movzbl (%eax),%eax
     e3b:	3a 45 fc             	cmp    -0x4(%ebp),%al
     e3e:	75 05                	jne    e45 <strchr+0x1e>
      return (char*)s;
     e40:	8b 45 08             	mov    0x8(%ebp),%eax
     e43:	eb 13                	jmp    e58 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
     e45:	83 45 08 01          	addl   $0x1,0x8(%ebp)
     e49:	8b 45 08             	mov    0x8(%ebp),%eax
     e4c:	0f b6 00             	movzbl (%eax),%eax
     e4f:	84 c0                	test   %al,%al
     e51:	75 e2                	jne    e35 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
     e53:	b8 00 00 00 00       	mov    $0x0,%eax
}
     e58:	c9                   	leave  
     e59:	c3                   	ret    

00000e5a <gets>:

char*
gets(char *buf, int max)
{
     e5a:	55                   	push   %ebp
     e5b:	89 e5                	mov    %esp,%ebp
     e5d:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
     e60:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     e67:	eb 44                	jmp    ead <gets+0x53>
    cc = read(0, &c, 1);
     e69:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
     e70:	00 
     e71:	8d 45 ef             	lea    -0x11(%ebp),%eax
     e74:	89 44 24 04          	mov    %eax,0x4(%esp)
     e78:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
     e7f:	e8 3c 01 00 00       	call   fc0 <read>
     e84:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
     e87:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
     e8b:	7e 2d                	jle    eba <gets+0x60>
      break;
    buf[i++] = c;
     e8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
     e90:	03 45 08             	add    0x8(%ebp),%eax
     e93:	0f b6 55 ef          	movzbl -0x11(%ebp),%edx
     e97:	88 10                	mov    %dl,(%eax)
     e99:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(c == '\n' || c == '\r')
     e9d:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
     ea1:	3c 0a                	cmp    $0xa,%al
     ea3:	74 16                	je     ebb <gets+0x61>
     ea5:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
     ea9:	3c 0d                	cmp    $0xd,%al
     eab:	74 0e                	je     ebb <gets+0x61>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
     ead:	8b 45 f4             	mov    -0xc(%ebp),%eax
     eb0:	83 c0 01             	add    $0x1,%eax
     eb3:	3b 45 0c             	cmp    0xc(%ebp),%eax
     eb6:	7c b1                	jl     e69 <gets+0xf>
     eb8:	eb 01                	jmp    ebb <gets+0x61>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
     eba:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
     ebb:	8b 45 f4             	mov    -0xc(%ebp),%eax
     ebe:	03 45 08             	add    0x8(%ebp),%eax
     ec1:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
     ec4:	8b 45 08             	mov    0x8(%ebp),%eax
}
     ec7:	c9                   	leave  
     ec8:	c3                   	ret    

00000ec9 <stat>:

int
stat(char *n, struct stat *st)
{
     ec9:	55                   	push   %ebp
     eca:	89 e5                	mov    %esp,%ebp
     ecc:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
     ecf:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     ed6:	00 
     ed7:	8b 45 08             	mov    0x8(%ebp),%eax
     eda:	89 04 24             	mov    %eax,(%esp)
     edd:	e8 06 01 00 00       	call   fe8 <open>
     ee2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
     ee5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
     ee9:	79 07                	jns    ef2 <stat+0x29>
    return -1;
     eeb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
     ef0:	eb 23                	jmp    f15 <stat+0x4c>
  r = fstat(fd, st);
     ef2:	8b 45 0c             	mov    0xc(%ebp),%eax
     ef5:	89 44 24 04          	mov    %eax,0x4(%esp)
     ef9:	8b 45 f4             	mov    -0xc(%ebp),%eax
     efc:	89 04 24             	mov    %eax,(%esp)
     eff:	e8 fc 00 00 00       	call   1000 <fstat>
     f04:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
     f07:	8b 45 f4             	mov    -0xc(%ebp),%eax
     f0a:	89 04 24             	mov    %eax,(%esp)
     f0d:	e8 be 00 00 00       	call   fd0 <close>
  return r;
     f12:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
     f15:	c9                   	leave  
     f16:	c3                   	ret    

00000f17 <atoi>:

int
atoi(const char *s)
{
     f17:	55                   	push   %ebp
     f18:	89 e5                	mov    %esp,%ebp
     f1a:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
     f1d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
     f24:	eb 23                	jmp    f49 <atoi+0x32>
    n = n*10 + *s++ - '0';
     f26:	8b 55 fc             	mov    -0x4(%ebp),%edx
     f29:	89 d0                	mov    %edx,%eax
     f2b:	c1 e0 02             	shl    $0x2,%eax
     f2e:	01 d0                	add    %edx,%eax
     f30:	01 c0                	add    %eax,%eax
     f32:	89 c2                	mov    %eax,%edx
     f34:	8b 45 08             	mov    0x8(%ebp),%eax
     f37:	0f b6 00             	movzbl (%eax),%eax
     f3a:	0f be c0             	movsbl %al,%eax
     f3d:	01 d0                	add    %edx,%eax
     f3f:	83 e8 30             	sub    $0x30,%eax
     f42:	89 45 fc             	mov    %eax,-0x4(%ebp)
     f45:	83 45 08 01          	addl   $0x1,0x8(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
     f49:	8b 45 08             	mov    0x8(%ebp),%eax
     f4c:	0f b6 00             	movzbl (%eax),%eax
     f4f:	3c 2f                	cmp    $0x2f,%al
     f51:	7e 0a                	jle    f5d <atoi+0x46>
     f53:	8b 45 08             	mov    0x8(%ebp),%eax
     f56:	0f b6 00             	movzbl (%eax),%eax
     f59:	3c 39                	cmp    $0x39,%al
     f5b:	7e c9                	jle    f26 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
     f5d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
     f60:	c9                   	leave  
     f61:	c3                   	ret    

00000f62 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
     f62:	55                   	push   %ebp
     f63:	89 e5                	mov    %esp,%ebp
     f65:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
     f68:	8b 45 08             	mov    0x8(%ebp),%eax
     f6b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
     f6e:	8b 45 0c             	mov    0xc(%ebp),%eax
     f71:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
     f74:	eb 13                	jmp    f89 <memmove+0x27>
    *dst++ = *src++;
     f76:	8b 45 f8             	mov    -0x8(%ebp),%eax
     f79:	0f b6 10             	movzbl (%eax),%edx
     f7c:	8b 45 fc             	mov    -0x4(%ebp),%eax
     f7f:	88 10                	mov    %dl,(%eax)
     f81:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
     f85:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
     f89:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
     f8d:	0f 9f c0             	setg   %al
     f90:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
     f94:	84 c0                	test   %al,%al
     f96:	75 de                	jne    f76 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
     f98:	8b 45 08             	mov    0x8(%ebp),%eax
}
     f9b:	c9                   	leave  
     f9c:	c3                   	ret    
     f9d:	90                   	nop
     f9e:	90                   	nop
     f9f:	90                   	nop

00000fa0 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
     fa0:	b8 01 00 00 00       	mov    $0x1,%eax
     fa5:	cd 40                	int    $0x40
     fa7:	c3                   	ret    

00000fa8 <exit>:
SYSCALL(exit)
     fa8:	b8 02 00 00 00       	mov    $0x2,%eax
     fad:	cd 40                	int    $0x40
     faf:	c3                   	ret    

00000fb0 <wait>:
SYSCALL(wait)
     fb0:	b8 03 00 00 00       	mov    $0x3,%eax
     fb5:	cd 40                	int    $0x40
     fb7:	c3                   	ret    

00000fb8 <pipe>:
SYSCALL(pipe)
     fb8:	b8 04 00 00 00       	mov    $0x4,%eax
     fbd:	cd 40                	int    $0x40
     fbf:	c3                   	ret    

00000fc0 <read>:
SYSCALL(read)
     fc0:	b8 05 00 00 00       	mov    $0x5,%eax
     fc5:	cd 40                	int    $0x40
     fc7:	c3                   	ret    

00000fc8 <write>:
SYSCALL(write)
     fc8:	b8 10 00 00 00       	mov    $0x10,%eax
     fcd:	cd 40                	int    $0x40
     fcf:	c3                   	ret    

00000fd0 <close>:
SYSCALL(close)
     fd0:	b8 15 00 00 00       	mov    $0x15,%eax
     fd5:	cd 40                	int    $0x40
     fd7:	c3                   	ret    

00000fd8 <kill>:
SYSCALL(kill)
     fd8:	b8 06 00 00 00       	mov    $0x6,%eax
     fdd:	cd 40                	int    $0x40
     fdf:	c3                   	ret    

00000fe0 <exec>:
SYSCALL(exec)
     fe0:	b8 07 00 00 00       	mov    $0x7,%eax
     fe5:	cd 40                	int    $0x40
     fe7:	c3                   	ret    

00000fe8 <open>:
SYSCALL(open)
     fe8:	b8 0f 00 00 00       	mov    $0xf,%eax
     fed:	cd 40                	int    $0x40
     fef:	c3                   	ret    

00000ff0 <mknod>:
SYSCALL(mknod)
     ff0:	b8 11 00 00 00       	mov    $0x11,%eax
     ff5:	cd 40                	int    $0x40
     ff7:	c3                   	ret    

00000ff8 <unlink>:
SYSCALL(unlink)
     ff8:	b8 12 00 00 00       	mov    $0x12,%eax
     ffd:	cd 40                	int    $0x40
     fff:	c3                   	ret    

00001000 <fstat>:
SYSCALL(fstat)
    1000:	b8 08 00 00 00       	mov    $0x8,%eax
    1005:	cd 40                	int    $0x40
    1007:	c3                   	ret    

00001008 <link>:
SYSCALL(link)
    1008:	b8 13 00 00 00       	mov    $0x13,%eax
    100d:	cd 40                	int    $0x40
    100f:	c3                   	ret    

00001010 <mkdir>:
SYSCALL(mkdir)
    1010:	b8 14 00 00 00       	mov    $0x14,%eax
    1015:	cd 40                	int    $0x40
    1017:	c3                   	ret    

00001018 <chdir>:
SYSCALL(chdir)
    1018:	b8 09 00 00 00       	mov    $0x9,%eax
    101d:	cd 40                	int    $0x40
    101f:	c3                   	ret    

00001020 <dup>:
SYSCALL(dup)
    1020:	b8 0a 00 00 00       	mov    $0xa,%eax
    1025:	cd 40                	int    $0x40
    1027:	c3                   	ret    

00001028 <getpid>:
SYSCALL(getpid)
    1028:	b8 0b 00 00 00       	mov    $0xb,%eax
    102d:	cd 40                	int    $0x40
    102f:	c3                   	ret    

00001030 <sbrk>:
SYSCALL(sbrk)
    1030:	b8 0c 00 00 00       	mov    $0xc,%eax
    1035:	cd 40                	int    $0x40
    1037:	c3                   	ret    

00001038 <sleep>:
SYSCALL(sleep)
    1038:	b8 0d 00 00 00       	mov    $0xd,%eax
    103d:	cd 40                	int    $0x40
    103f:	c3                   	ret    

00001040 <uptime>:
SYSCALL(uptime)
    1040:	b8 0e 00 00 00       	mov    $0xe,%eax
    1045:	cd 40                	int    $0x40
    1047:	c3                   	ret    

00001048 <waitpid>:
SYSCALL(waitpid)
    1048:	b8 16 00 00 00       	mov    $0x16,%eax
    104d:	cd 40                	int    $0x40
    104f:	c3                   	ret    

00001050 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
    1050:	55                   	push   %ebp
    1051:	89 e5                	mov    %esp,%ebp
    1053:	83 ec 28             	sub    $0x28,%esp
    1056:	8b 45 0c             	mov    0xc(%ebp),%eax
    1059:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
    105c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
    1063:	00 
    1064:	8d 45 f4             	lea    -0xc(%ebp),%eax
    1067:	89 44 24 04          	mov    %eax,0x4(%esp)
    106b:	8b 45 08             	mov    0x8(%ebp),%eax
    106e:	89 04 24             	mov    %eax,(%esp)
    1071:	e8 52 ff ff ff       	call   fc8 <write>
}
    1076:	c9                   	leave  
    1077:	c3                   	ret    

00001078 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
    1078:	55                   	push   %ebp
    1079:	89 e5                	mov    %esp,%ebp
    107b:	83 ec 48             	sub    $0x48,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
    107e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
    1085:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
    1089:	74 17                	je     10a2 <printint+0x2a>
    108b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
    108f:	79 11                	jns    10a2 <printint+0x2a>
    neg = 1;
    1091:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
    1098:	8b 45 0c             	mov    0xc(%ebp),%eax
    109b:	f7 d8                	neg    %eax
    109d:	89 45 ec             	mov    %eax,-0x14(%ebp)
    10a0:	eb 06                	jmp    10a8 <printint+0x30>
  } else {
    x = xx;
    10a2:	8b 45 0c             	mov    0xc(%ebp),%eax
    10a5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
    10a8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
    10af:	8b 4d 10             	mov    0x10(%ebp),%ecx
    10b2:	8b 45 ec             	mov    -0x14(%ebp),%eax
    10b5:	ba 00 00 00 00       	mov    $0x0,%edx
    10ba:	f7 f1                	div    %ecx
    10bc:	89 d0                	mov    %edx,%eax
    10be:	0f b6 90 6c 1a 00 00 	movzbl 0x1a6c(%eax),%edx
    10c5:	8d 45 dc             	lea    -0x24(%ebp),%eax
    10c8:	03 45 f4             	add    -0xc(%ebp),%eax
    10cb:	88 10                	mov    %dl,(%eax)
    10cd:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  }while((x /= base) != 0);
    10d1:	8b 55 10             	mov    0x10(%ebp),%edx
    10d4:	89 55 d4             	mov    %edx,-0x2c(%ebp)
    10d7:	8b 45 ec             	mov    -0x14(%ebp),%eax
    10da:	ba 00 00 00 00       	mov    $0x0,%edx
    10df:	f7 75 d4             	divl   -0x2c(%ebp)
    10e2:	89 45 ec             	mov    %eax,-0x14(%ebp)
    10e5:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    10e9:	75 c4                	jne    10af <printint+0x37>
  if(neg)
    10eb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    10ef:	74 2a                	je     111b <printint+0xa3>
    buf[i++] = '-';
    10f1:	8d 45 dc             	lea    -0x24(%ebp),%eax
    10f4:	03 45 f4             	add    -0xc(%ebp),%eax
    10f7:	c6 00 2d             	movb   $0x2d,(%eax)
    10fa:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

  while(--i >= 0)
    10fe:	eb 1b                	jmp    111b <printint+0xa3>
    putc(fd, buf[i]);
    1100:	8d 45 dc             	lea    -0x24(%ebp),%eax
    1103:	03 45 f4             	add    -0xc(%ebp),%eax
    1106:	0f b6 00             	movzbl (%eax),%eax
    1109:	0f be c0             	movsbl %al,%eax
    110c:	89 44 24 04          	mov    %eax,0x4(%esp)
    1110:	8b 45 08             	mov    0x8(%ebp),%eax
    1113:	89 04 24             	mov    %eax,(%esp)
    1116:	e8 35 ff ff ff       	call   1050 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
    111b:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
    111f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    1123:	79 db                	jns    1100 <printint+0x88>
    putc(fd, buf[i]);
}
    1125:	c9                   	leave  
    1126:	c3                   	ret    

00001127 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
    1127:	55                   	push   %ebp
    1128:	89 e5                	mov    %esp,%ebp
    112a:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
    112d:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
    1134:	8d 45 0c             	lea    0xc(%ebp),%eax
    1137:	83 c0 04             	add    $0x4,%eax
    113a:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
    113d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    1144:	e9 7d 01 00 00       	jmp    12c6 <printf+0x19f>
    c = fmt[i] & 0xff;
    1149:	8b 55 0c             	mov    0xc(%ebp),%edx
    114c:	8b 45 f0             	mov    -0x10(%ebp),%eax
    114f:	01 d0                	add    %edx,%eax
    1151:	0f b6 00             	movzbl (%eax),%eax
    1154:	0f be c0             	movsbl %al,%eax
    1157:	25 ff 00 00 00       	and    $0xff,%eax
    115c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
    115f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    1163:	75 2c                	jne    1191 <printf+0x6a>
      if(c == '%'){
    1165:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
    1169:	75 0c                	jne    1177 <printf+0x50>
        state = '%';
    116b:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
    1172:	e9 4b 01 00 00       	jmp    12c2 <printf+0x19b>
      } else {
        putc(fd, c);
    1177:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    117a:	0f be c0             	movsbl %al,%eax
    117d:	89 44 24 04          	mov    %eax,0x4(%esp)
    1181:	8b 45 08             	mov    0x8(%ebp),%eax
    1184:	89 04 24             	mov    %eax,(%esp)
    1187:	e8 c4 fe ff ff       	call   1050 <putc>
    118c:	e9 31 01 00 00       	jmp    12c2 <printf+0x19b>
      }
    } else if(state == '%'){
    1191:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
    1195:	0f 85 27 01 00 00    	jne    12c2 <printf+0x19b>
      if(c == 'd'){
    119b:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
    119f:	75 2d                	jne    11ce <printf+0xa7>
        printint(fd, *ap, 10, 1);
    11a1:	8b 45 e8             	mov    -0x18(%ebp),%eax
    11a4:	8b 00                	mov    (%eax),%eax
    11a6:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
    11ad:	00 
    11ae:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
    11b5:	00 
    11b6:	89 44 24 04          	mov    %eax,0x4(%esp)
    11ba:	8b 45 08             	mov    0x8(%ebp),%eax
    11bd:	89 04 24             	mov    %eax,(%esp)
    11c0:	e8 b3 fe ff ff       	call   1078 <printint>
        ap++;
    11c5:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    11c9:	e9 ed 00 00 00       	jmp    12bb <printf+0x194>
      } else if(c == 'x' || c == 'p'){
    11ce:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
    11d2:	74 06                	je     11da <printf+0xb3>
    11d4:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
    11d8:	75 2d                	jne    1207 <printf+0xe0>
        printint(fd, *ap, 16, 0);
    11da:	8b 45 e8             	mov    -0x18(%ebp),%eax
    11dd:	8b 00                	mov    (%eax),%eax
    11df:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
    11e6:	00 
    11e7:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
    11ee:	00 
    11ef:	89 44 24 04          	mov    %eax,0x4(%esp)
    11f3:	8b 45 08             	mov    0x8(%ebp),%eax
    11f6:	89 04 24             	mov    %eax,(%esp)
    11f9:	e8 7a fe ff ff       	call   1078 <printint>
        ap++;
    11fe:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    1202:	e9 b4 00 00 00       	jmp    12bb <printf+0x194>
      } else if(c == 's'){
    1207:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
    120b:	75 46                	jne    1253 <printf+0x12c>
        s = (char*)*ap;
    120d:	8b 45 e8             	mov    -0x18(%ebp),%eax
    1210:	8b 00                	mov    (%eax),%eax
    1212:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
    1215:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
    1219:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    121d:	75 27                	jne    1246 <printf+0x11f>
          s = "(null)";
    121f:	c7 45 f4 dc 15 00 00 	movl   $0x15dc,-0xc(%ebp)
        while(*s != 0){
    1226:	eb 1e                	jmp    1246 <printf+0x11f>
          putc(fd, *s);
    1228:	8b 45 f4             	mov    -0xc(%ebp),%eax
    122b:	0f b6 00             	movzbl (%eax),%eax
    122e:	0f be c0             	movsbl %al,%eax
    1231:	89 44 24 04          	mov    %eax,0x4(%esp)
    1235:	8b 45 08             	mov    0x8(%ebp),%eax
    1238:	89 04 24             	mov    %eax,(%esp)
    123b:	e8 10 fe ff ff       	call   1050 <putc>
          s++;
    1240:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    1244:	eb 01                	jmp    1247 <printf+0x120>
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
    1246:	90                   	nop
    1247:	8b 45 f4             	mov    -0xc(%ebp),%eax
    124a:	0f b6 00             	movzbl (%eax),%eax
    124d:	84 c0                	test   %al,%al
    124f:	75 d7                	jne    1228 <printf+0x101>
    1251:	eb 68                	jmp    12bb <printf+0x194>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
    1253:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
    1257:	75 1d                	jne    1276 <printf+0x14f>
        putc(fd, *ap);
    1259:	8b 45 e8             	mov    -0x18(%ebp),%eax
    125c:	8b 00                	mov    (%eax),%eax
    125e:	0f be c0             	movsbl %al,%eax
    1261:	89 44 24 04          	mov    %eax,0x4(%esp)
    1265:	8b 45 08             	mov    0x8(%ebp),%eax
    1268:	89 04 24             	mov    %eax,(%esp)
    126b:	e8 e0 fd ff ff       	call   1050 <putc>
        ap++;
    1270:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    1274:	eb 45                	jmp    12bb <printf+0x194>
      } else if(c == '%'){
    1276:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
    127a:	75 17                	jne    1293 <printf+0x16c>
        putc(fd, c);
    127c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    127f:	0f be c0             	movsbl %al,%eax
    1282:	89 44 24 04          	mov    %eax,0x4(%esp)
    1286:	8b 45 08             	mov    0x8(%ebp),%eax
    1289:	89 04 24             	mov    %eax,(%esp)
    128c:	e8 bf fd ff ff       	call   1050 <putc>
    1291:	eb 28                	jmp    12bb <printf+0x194>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
    1293:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
    129a:	00 
    129b:	8b 45 08             	mov    0x8(%ebp),%eax
    129e:	89 04 24             	mov    %eax,(%esp)
    12a1:	e8 aa fd ff ff       	call   1050 <putc>
        putc(fd, c);
    12a6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    12a9:	0f be c0             	movsbl %al,%eax
    12ac:	89 44 24 04          	mov    %eax,0x4(%esp)
    12b0:	8b 45 08             	mov    0x8(%ebp),%eax
    12b3:	89 04 24             	mov    %eax,(%esp)
    12b6:	e8 95 fd ff ff       	call   1050 <putc>
      }
      state = 0;
    12bb:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    12c2:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
    12c6:	8b 55 0c             	mov    0xc(%ebp),%edx
    12c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
    12cc:	01 d0                	add    %edx,%eax
    12ce:	0f b6 00             	movzbl (%eax),%eax
    12d1:	84 c0                	test   %al,%al
    12d3:	0f 85 70 fe ff ff    	jne    1149 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
    12d9:	c9                   	leave  
    12da:	c3                   	ret    
    12db:	90                   	nop

000012dc <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    12dc:	55                   	push   %ebp
    12dd:	89 e5                	mov    %esp,%ebp
    12df:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
    12e2:	8b 45 08             	mov    0x8(%ebp),%eax
    12e5:	83 e8 08             	sub    $0x8,%eax
    12e8:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    12eb:	a1 ec 1a 00 00       	mov    0x1aec,%eax
    12f0:	89 45 fc             	mov    %eax,-0x4(%ebp)
    12f3:	eb 24                	jmp    1319 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    12f5:	8b 45 fc             	mov    -0x4(%ebp),%eax
    12f8:	8b 00                	mov    (%eax),%eax
    12fa:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    12fd:	77 12                	ja     1311 <free+0x35>
    12ff:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1302:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    1305:	77 24                	ja     132b <free+0x4f>
    1307:	8b 45 fc             	mov    -0x4(%ebp),%eax
    130a:	8b 00                	mov    (%eax),%eax
    130c:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    130f:	77 1a                	ja     132b <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    1311:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1314:	8b 00                	mov    (%eax),%eax
    1316:	89 45 fc             	mov    %eax,-0x4(%ebp)
    1319:	8b 45 f8             	mov    -0x8(%ebp),%eax
    131c:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    131f:	76 d4                	jbe    12f5 <free+0x19>
    1321:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1324:	8b 00                	mov    (%eax),%eax
    1326:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    1329:	76 ca                	jbe    12f5 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    132b:	8b 45 f8             	mov    -0x8(%ebp),%eax
    132e:	8b 40 04             	mov    0x4(%eax),%eax
    1331:	c1 e0 03             	shl    $0x3,%eax
    1334:	89 c2                	mov    %eax,%edx
    1336:	03 55 f8             	add    -0x8(%ebp),%edx
    1339:	8b 45 fc             	mov    -0x4(%ebp),%eax
    133c:	8b 00                	mov    (%eax),%eax
    133e:	39 c2                	cmp    %eax,%edx
    1340:	75 24                	jne    1366 <free+0x8a>
    bp->s.size += p->s.ptr->s.size;
    1342:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1345:	8b 50 04             	mov    0x4(%eax),%edx
    1348:	8b 45 fc             	mov    -0x4(%ebp),%eax
    134b:	8b 00                	mov    (%eax),%eax
    134d:	8b 40 04             	mov    0x4(%eax),%eax
    1350:	01 c2                	add    %eax,%edx
    1352:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1355:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
    1358:	8b 45 fc             	mov    -0x4(%ebp),%eax
    135b:	8b 00                	mov    (%eax),%eax
    135d:	8b 10                	mov    (%eax),%edx
    135f:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1362:	89 10                	mov    %edx,(%eax)
    1364:	eb 0a                	jmp    1370 <free+0x94>
  } else
    bp->s.ptr = p->s.ptr;
    1366:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1369:	8b 10                	mov    (%eax),%edx
    136b:	8b 45 f8             	mov    -0x8(%ebp),%eax
    136e:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
    1370:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1373:	8b 40 04             	mov    0x4(%eax),%eax
    1376:	c1 e0 03             	shl    $0x3,%eax
    1379:	03 45 fc             	add    -0x4(%ebp),%eax
    137c:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    137f:	75 20                	jne    13a1 <free+0xc5>
    p->s.size += bp->s.size;
    1381:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1384:	8b 50 04             	mov    0x4(%eax),%edx
    1387:	8b 45 f8             	mov    -0x8(%ebp),%eax
    138a:	8b 40 04             	mov    0x4(%eax),%eax
    138d:	01 c2                	add    %eax,%edx
    138f:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1392:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
    1395:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1398:	8b 10                	mov    (%eax),%edx
    139a:	8b 45 fc             	mov    -0x4(%ebp),%eax
    139d:	89 10                	mov    %edx,(%eax)
    139f:	eb 08                	jmp    13a9 <free+0xcd>
  } else
    p->s.ptr = bp;
    13a1:	8b 45 fc             	mov    -0x4(%ebp),%eax
    13a4:	8b 55 f8             	mov    -0x8(%ebp),%edx
    13a7:	89 10                	mov    %edx,(%eax)
  freep = p;
    13a9:	8b 45 fc             	mov    -0x4(%ebp),%eax
    13ac:	a3 ec 1a 00 00       	mov    %eax,0x1aec
}
    13b1:	c9                   	leave  
    13b2:	c3                   	ret    

000013b3 <morecore>:

static Header*
morecore(uint nu)
{
    13b3:	55                   	push   %ebp
    13b4:	89 e5                	mov    %esp,%ebp
    13b6:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
    13b9:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
    13c0:	77 07                	ja     13c9 <morecore+0x16>
    nu = 4096;
    13c2:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
    13c9:	8b 45 08             	mov    0x8(%ebp),%eax
    13cc:	c1 e0 03             	shl    $0x3,%eax
    13cf:	89 04 24             	mov    %eax,(%esp)
    13d2:	e8 59 fc ff ff       	call   1030 <sbrk>
    13d7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
    13da:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
    13de:	75 07                	jne    13e7 <morecore+0x34>
    return 0;
    13e0:	b8 00 00 00 00       	mov    $0x0,%eax
    13e5:	eb 22                	jmp    1409 <morecore+0x56>
  hp = (Header*)p;
    13e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
    13ea:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
    13ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
    13f0:	8b 55 08             	mov    0x8(%ebp),%edx
    13f3:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
    13f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
    13f9:	83 c0 08             	add    $0x8,%eax
    13fc:	89 04 24             	mov    %eax,(%esp)
    13ff:	e8 d8 fe ff ff       	call   12dc <free>
  return freep;
    1404:	a1 ec 1a 00 00       	mov    0x1aec,%eax
}
    1409:	c9                   	leave  
    140a:	c3                   	ret    

0000140b <malloc>:

void*
malloc(uint nbytes)
{
    140b:	55                   	push   %ebp
    140c:	89 e5                	mov    %esp,%ebp
    140e:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    1411:	8b 45 08             	mov    0x8(%ebp),%eax
    1414:	83 c0 07             	add    $0x7,%eax
    1417:	c1 e8 03             	shr    $0x3,%eax
    141a:	83 c0 01             	add    $0x1,%eax
    141d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
    1420:	a1 ec 1a 00 00       	mov    0x1aec,%eax
    1425:	89 45 f0             	mov    %eax,-0x10(%ebp)
    1428:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    142c:	75 23                	jne    1451 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
    142e:	c7 45 f0 e4 1a 00 00 	movl   $0x1ae4,-0x10(%ebp)
    1435:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1438:	a3 ec 1a 00 00       	mov    %eax,0x1aec
    143d:	a1 ec 1a 00 00       	mov    0x1aec,%eax
    1442:	a3 e4 1a 00 00       	mov    %eax,0x1ae4
    base.s.size = 0;
    1447:	c7 05 e8 1a 00 00 00 	movl   $0x0,0x1ae8
    144e:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    1451:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1454:	8b 00                	mov    (%eax),%eax
    1456:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
    1459:	8b 45 f4             	mov    -0xc(%ebp),%eax
    145c:	8b 40 04             	mov    0x4(%eax),%eax
    145f:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    1462:	72 4d                	jb     14b1 <malloc+0xa6>
      if(p->s.size == nunits)
    1464:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1467:	8b 40 04             	mov    0x4(%eax),%eax
    146a:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    146d:	75 0c                	jne    147b <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
    146f:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1472:	8b 10                	mov    (%eax),%edx
    1474:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1477:	89 10                	mov    %edx,(%eax)
    1479:	eb 26                	jmp    14a1 <malloc+0x96>
      else {
        p->s.size -= nunits;
    147b:	8b 45 f4             	mov    -0xc(%ebp),%eax
    147e:	8b 40 04             	mov    0x4(%eax),%eax
    1481:	89 c2                	mov    %eax,%edx
    1483:	2b 55 ec             	sub    -0x14(%ebp),%edx
    1486:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1489:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
    148c:	8b 45 f4             	mov    -0xc(%ebp),%eax
    148f:	8b 40 04             	mov    0x4(%eax),%eax
    1492:	c1 e0 03             	shl    $0x3,%eax
    1495:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
    1498:	8b 45 f4             	mov    -0xc(%ebp),%eax
    149b:	8b 55 ec             	mov    -0x14(%ebp),%edx
    149e:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
    14a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
    14a4:	a3 ec 1a 00 00       	mov    %eax,0x1aec
      return (void*)(p + 1);
    14a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
    14ac:	83 c0 08             	add    $0x8,%eax
    14af:	eb 38                	jmp    14e9 <malloc+0xde>
    }
    if(p == freep)
    14b1:	a1 ec 1a 00 00       	mov    0x1aec,%eax
    14b6:	39 45 f4             	cmp    %eax,-0xc(%ebp)
    14b9:	75 1b                	jne    14d6 <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
    14bb:	8b 45 ec             	mov    -0x14(%ebp),%eax
    14be:	89 04 24             	mov    %eax,(%esp)
    14c1:	e8 ed fe ff ff       	call   13b3 <morecore>
    14c6:	89 45 f4             	mov    %eax,-0xc(%ebp)
    14c9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    14cd:	75 07                	jne    14d6 <malloc+0xcb>
        return 0;
    14cf:	b8 00 00 00 00       	mov    $0x0,%eax
    14d4:	eb 13                	jmp    14e9 <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    14d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
    14d9:	89 45 f0             	mov    %eax,-0x10(%ebp)
    14dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
    14df:	8b 00                	mov    (%eax),%eax
    14e1:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
    14e4:	e9 70 ff ff ff       	jmp    1459 <malloc+0x4e>
}
    14e9:	c9                   	leave  
    14ea:	c3                   	ret    
