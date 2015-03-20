
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
      13:	e8 74 0f 00 00       	call   f8c <exit>
  
  switch(cmd->type){
      18:	8b 45 08             	mov    0x8(%ebp),%eax
      1b:	8b 00                	mov    (%eax),%eax
      1d:	83 f8 05             	cmp    $0x5,%eax
      20:	77 09                	ja     2b <runcmd+0x2b>
      22:	8b 04 85 f4 14 00 00 	mov    0x14f4(,%eax,4),%eax
      29:	ff e0                	jmp    *%eax
  default:
    panic("runcmd");
      2b:	c7 04 24 c8 14 00 00 	movl   $0x14c8,(%esp)
      32:	e8 46 03 00 00       	call   37d <panic>

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
      4e:	e8 39 0f 00 00       	call   f8c <exit>
    exec(ecmd->argv[0], ecmd->argv);
      53:	8b 45 f4             	mov    -0xc(%ebp),%eax
      56:	8d 50 04             	lea    0x4(%eax),%edx
      59:	8b 45 f4             	mov    -0xc(%ebp),%eax
      5c:	8b 40 04             	mov    0x4(%eax),%eax
      5f:	89 54 24 04          	mov    %edx,0x4(%esp)
      63:	89 04 24             	mov    %eax,(%esp)
      66:	e8 59 0f 00 00       	call   fc4 <exec>
    printf(2, "exec %s failed\n", ecmd->argv[0]);
      6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
      6e:	8b 40 04             	mov    0x4(%eax),%eax
      71:	89 44 24 08          	mov    %eax,0x8(%esp)
      75:	c7 44 24 04 cf 14 00 	movl   $0x14cf,0x4(%esp)
      7c:	00 
      7d:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
      84:	e8 7a 10 00 00       	call   1103 <printf>
    break;
      89:	e9 8b 01 00 00       	jmp    219 <runcmd+0x219>

  case REDIR:
    rcmd = (struct redircmd*)cmd;
      8e:	8b 45 08             	mov    0x8(%ebp),%eax
      91:	89 45 f0             	mov    %eax,-0x10(%ebp)
    close(rcmd->fd);
      94:	8b 45 f0             	mov    -0x10(%ebp),%eax
      97:	8b 40 14             	mov    0x14(%eax),%eax
      9a:	89 04 24             	mov    %eax,(%esp)
      9d:	e8 12 0f 00 00       	call   fb4 <close>
    if(open(rcmd->file, rcmd->mode) < 0){
      a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
      a5:	8b 50 10             	mov    0x10(%eax),%edx
      a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
      ab:	8b 40 08             	mov    0x8(%eax),%eax
      ae:	89 54 24 04          	mov    %edx,0x4(%esp)
      b2:	89 04 24             	mov    %eax,(%esp)
      b5:	e8 12 0f 00 00       	call   fcc <open>
      ba:	85 c0                	test   %eax,%eax
      bc:	79 2a                	jns    e8 <runcmd+0xe8>
      printf(2, "open %s failed\n", rcmd->file);
      be:	8b 45 f0             	mov    -0x10(%ebp),%eax
      c1:	8b 40 08             	mov    0x8(%eax),%eax
      c4:	89 44 24 08          	mov    %eax,0x8(%esp)
      c8:	c7 44 24 04 df 14 00 	movl   $0x14df,0x4(%esp)
      cf:	00 
      d0:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
      d7:	e8 27 10 00 00       	call   1103 <printf>
      exit(EXIT_STATUS_DEFAULT);
      dc:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
      e3:	e8 a4 0e 00 00       	call   f8c <exit>
    }
    runcmd(rcmd->cmd);
      e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
      eb:	8b 40 04             	mov    0x4(%eax),%eax
      ee:	89 04 24             	mov    %eax,(%esp)
      f1:	e8 0a ff ff ff       	call   0 <runcmd>
    break;
      f6:	e9 1e 01 00 00       	jmp    219 <runcmd+0x219>

  case LIST:
    lcmd = (struct listcmd*)cmd;
      fb:	8b 45 08             	mov    0x8(%ebp),%eax
      fe:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(fork1() == 0)
     101:	e8 a4 02 00 00       	call   3aa <fork1>
     106:	85 c0                	test   %eax,%eax
     108:	75 0e                	jne    118 <runcmd+0x118>
      runcmd(lcmd->left);
     10a:	8b 45 ec             	mov    -0x14(%ebp),%eax
     10d:	8b 40 04             	mov    0x4(%eax),%eax
     110:	89 04 24             	mov    %eax,(%esp)
     113:	e8 e8 fe ff ff       	call   0 <runcmd>
    wait();
     118:	e8 77 0e 00 00       	call   f94 <wait>
    runcmd(lcmd->right);
     11d:	8b 45 ec             	mov    -0x14(%ebp),%eax
     120:	8b 40 08             	mov    0x8(%eax),%eax
     123:	89 04 24             	mov    %eax,(%esp)
     126:	e8 d5 fe ff ff       	call   0 <runcmd>
    break;
     12b:	e9 e9 00 00 00       	jmp    219 <runcmd+0x219>

  case PIPE:
    pcmd = (struct pipecmd*)cmd;
     130:	8b 45 08             	mov    0x8(%ebp),%eax
     133:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pipe(p) < 0)
     136:	8d 45 dc             	lea    -0x24(%ebp),%eax
     139:	89 04 24             	mov    %eax,(%esp)
     13c:	e8 5b 0e 00 00       	call   f9c <pipe>
     141:	85 c0                	test   %eax,%eax
     143:	79 0c                	jns    151 <runcmd+0x151>
      panic("pipe");
     145:	c7 04 24 ef 14 00 00 	movl   $0x14ef,(%esp)
     14c:	e8 2c 02 00 00       	call   37d <panic>
    if(fork1() == 0){
     151:	e8 54 02 00 00       	call   3aa <fork1>
     156:	85 c0                	test   %eax,%eax
     158:	75 3b                	jne    195 <runcmd+0x195>
      close(1);
     15a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     161:	e8 4e 0e 00 00       	call   fb4 <close>
      dup(p[1]);
     166:	8b 45 e0             	mov    -0x20(%ebp),%eax
     169:	89 04 24             	mov    %eax,(%esp)
     16c:	e8 93 0e 00 00       	call   1004 <dup>
      close(p[0]);
     171:	8b 45 dc             	mov    -0x24(%ebp),%eax
     174:	89 04 24             	mov    %eax,(%esp)
     177:	e8 38 0e 00 00       	call   fb4 <close>
      close(p[1]);
     17c:	8b 45 e0             	mov    -0x20(%ebp),%eax
     17f:	89 04 24             	mov    %eax,(%esp)
     182:	e8 2d 0e 00 00       	call   fb4 <close>
      runcmd(pcmd->left);
     187:	8b 45 e8             	mov    -0x18(%ebp),%eax
     18a:	8b 40 04             	mov    0x4(%eax),%eax
     18d:	89 04 24             	mov    %eax,(%esp)
     190:	e8 6b fe ff ff       	call   0 <runcmd>
    }
    if(fork1() == 0){
     195:	e8 10 02 00 00       	call   3aa <fork1>
     19a:	85 c0                	test   %eax,%eax
     19c:	75 3b                	jne    1d9 <runcmd+0x1d9>
      close(0);
     19e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
     1a5:	e8 0a 0e 00 00       	call   fb4 <close>
      dup(p[0]);
     1aa:	8b 45 dc             	mov    -0x24(%ebp),%eax
     1ad:	89 04 24             	mov    %eax,(%esp)
     1b0:	e8 4f 0e 00 00       	call   1004 <dup>
      close(p[0]);
     1b5:	8b 45 dc             	mov    -0x24(%ebp),%eax
     1b8:	89 04 24             	mov    %eax,(%esp)
     1bb:	e8 f4 0d 00 00       	call   fb4 <close>
      close(p[1]);
     1c0:	8b 45 e0             	mov    -0x20(%ebp),%eax
     1c3:	89 04 24             	mov    %eax,(%esp)
     1c6:	e8 e9 0d 00 00       	call   fb4 <close>
      runcmd(pcmd->right);
     1cb:	8b 45 e8             	mov    -0x18(%ebp),%eax
     1ce:	8b 40 08             	mov    0x8(%eax),%eax
     1d1:	89 04 24             	mov    %eax,(%esp)
     1d4:	e8 27 fe ff ff       	call   0 <runcmd>
    }
    close(p[0]);
     1d9:	8b 45 dc             	mov    -0x24(%ebp),%eax
     1dc:	89 04 24             	mov    %eax,(%esp)
     1df:	e8 d0 0d 00 00       	call   fb4 <close>
    close(p[1]);
     1e4:	8b 45 e0             	mov    -0x20(%ebp),%eax
     1e7:	89 04 24             	mov    %eax,(%esp)
     1ea:	e8 c5 0d 00 00       	call   fb4 <close>
    wait();
     1ef:	e8 a0 0d 00 00       	call   f94 <wait>
    wait();
     1f4:	e8 9b 0d 00 00       	call   f94 <wait>
    break;
     1f9:	eb 1e                	jmp    219 <runcmd+0x219>
    
  case BACK:
    bcmd = (struct backcmd*)cmd;
     1fb:	8b 45 08             	mov    0x8(%ebp),%eax
     1fe:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(fork1() == 0)
     201:	e8 a4 01 00 00       	call   3aa <fork1>
     206:	85 c0                	test   %eax,%eax
     208:	75 0e                	jne    218 <runcmd+0x218>
      runcmd(bcmd->cmd);
     20a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     20d:	8b 40 04             	mov    0x4(%eax),%eax
     210:	89 04 24             	mov    %eax,(%esp)
     213:	e8 e8 fd ff ff       	call   0 <runcmd>
    break;
     218:	90                   	nop
  }
  exit(EXIT_STATUS_DEFAULT);
     219:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     220:	e8 67 0d 00 00       	call   f8c <exit>

00000225 <getcmd>:
}

int
getcmd(char *buf, int nbuf)
{
     225:	55                   	push   %ebp
     226:	89 e5                	mov    %esp,%ebp
     228:	83 ec 18             	sub    $0x18,%esp
  printf(2, "$ ");
     22b:	c7 44 24 04 0c 15 00 	movl   $0x150c,0x4(%esp)
     232:	00 
     233:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     23a:	e8 c4 0e 00 00       	call   1103 <printf>
  memset(buf, 0, nbuf);
     23f:	8b 45 0c             	mov    0xc(%ebp),%eax
     242:	89 44 24 08          	mov    %eax,0x8(%esp)
     246:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     24d:	00 
     24e:	8b 45 08             	mov    0x8(%ebp),%eax
     251:	89 04 24             	mov    %eax,(%esp)
     254:	e8 8e 0b 00 00       	call   de7 <memset>
  gets(buf, nbuf);
     259:	8b 45 0c             	mov    0xc(%ebp),%eax
     25c:	89 44 24 04          	mov    %eax,0x4(%esp)
     260:	8b 45 08             	mov    0x8(%ebp),%eax
     263:	89 04 24             	mov    %eax,(%esp)
     266:	e8 d3 0b 00 00       	call   e3e <gets>
  if(buf[0] == 0) // EOF
     26b:	8b 45 08             	mov    0x8(%ebp),%eax
     26e:	0f b6 00             	movzbl (%eax),%eax
     271:	84 c0                	test   %al,%al
     273:	75 07                	jne    27c <getcmd+0x57>
    return -1;
     275:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
     27a:	eb 05                	jmp    281 <getcmd+0x5c>
  return 0;
     27c:	b8 00 00 00 00       	mov    $0x0,%eax
}
     281:	c9                   	leave  
     282:	c3                   	ret    

00000283 <main>:

int
main(void)
{
     283:	55                   	push   %ebp
     284:	89 e5                	mov    %esp,%ebp
     286:	83 e4 f0             	and    $0xfffffff0,%esp
     289:	83 ec 20             	sub    $0x20,%esp
  static char buf[100];
  int fd;
  
  // Assumes three file descriptors open.
  while((fd = open("console", O_RDWR)) >= 0){
     28c:	eb 19                	jmp    2a7 <main+0x24>
    if(fd >= 3){
     28e:	83 7c 24 1c 02       	cmpl   $0x2,0x1c(%esp)
     293:	7e 12                	jle    2a7 <main+0x24>
      close(fd);
     295:	8b 44 24 1c          	mov    0x1c(%esp),%eax
     299:	89 04 24             	mov    %eax,(%esp)
     29c:	e8 13 0d 00 00       	call   fb4 <close>
      break;
     2a1:	90                   	nop
    }
  }
  
  // Read and run input commands.
  while(getcmd(buf, sizeof(buf)) >= 0){
     2a2:	e9 ae 00 00 00       	jmp    355 <main+0xd2>
{
  static char buf[100];
  int fd;
  
  // Assumes three file descriptors open.
  while((fd = open("console", O_RDWR)) >= 0){
     2a7:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
     2ae:	00 
     2af:	c7 04 24 0f 15 00 00 	movl   $0x150f,(%esp)
     2b6:	e8 11 0d 00 00       	call   fcc <open>
     2bb:	89 44 24 1c          	mov    %eax,0x1c(%esp)
     2bf:	83 7c 24 1c 00       	cmpl   $0x0,0x1c(%esp)
     2c4:	79 c8                	jns    28e <main+0xb>
      break;
    }
  }
  
  // Read and run input commands.
  while(getcmd(buf, sizeof(buf)) >= 0){
     2c6:	e9 8a 00 00 00       	jmp    355 <main+0xd2>
    if(buf[0] == 'c' && buf[1] == 'd' && buf[2] == ' '){
     2cb:	0f b6 05 60 1a 00 00 	movzbl 0x1a60,%eax
     2d2:	3c 63                	cmp    $0x63,%al
     2d4:	75 5a                	jne    330 <main+0xad>
     2d6:	0f b6 05 61 1a 00 00 	movzbl 0x1a61,%eax
     2dd:	3c 64                	cmp    $0x64,%al
     2df:	75 4f                	jne    330 <main+0xad>
     2e1:	0f b6 05 62 1a 00 00 	movzbl 0x1a62,%eax
     2e8:	3c 20                	cmp    $0x20,%al
     2ea:	75 44                	jne    330 <main+0xad>
      // Clumsy but will have to do for now.
      // Chdir has no effect on the parent if run in the child.
      buf[strlen(buf)-1] = 0;  // chop \n
     2ec:	c7 04 24 60 1a 00 00 	movl   $0x1a60,(%esp)
     2f3:	e8 ca 0a 00 00       	call   dc2 <strlen>
     2f8:	83 e8 01             	sub    $0x1,%eax
     2fb:	c6 80 60 1a 00 00 00 	movb   $0x0,0x1a60(%eax)
      if(chdir(buf+3) < 0)
     302:	c7 04 24 63 1a 00 00 	movl   $0x1a63,(%esp)
     309:	e8 ee 0c 00 00       	call   ffc <chdir>
     30e:	85 c0                	test   %eax,%eax
     310:	79 42                	jns    354 <main+0xd1>
        printf(2, "cannot cd %s\n", buf+3);
     312:	c7 44 24 08 63 1a 00 	movl   $0x1a63,0x8(%esp)
     319:	00 
     31a:	c7 44 24 04 17 15 00 	movl   $0x1517,0x4(%esp)
     321:	00 
     322:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     329:	e8 d5 0d 00 00       	call   1103 <printf>
      continue;
     32e:	eb 24                	jmp    354 <main+0xd1>
    }
    if(fork1() == 0)
     330:	e8 75 00 00 00       	call   3aa <fork1>
     335:	85 c0                	test   %eax,%eax
     337:	75 14                	jne    34d <main+0xca>
      runcmd(parsecmd(buf));
     339:	c7 04 24 60 1a 00 00 	movl   $0x1a60,(%esp)
     340:	e8 d7 03 00 00       	call   71c <parsecmd>
     345:	89 04 24             	mov    %eax,(%esp)
     348:	e8 b3 fc ff ff       	call   0 <runcmd>
    wait();
     34d:	e8 42 0c 00 00       	call   f94 <wait>
     352:	eb 01                	jmp    355 <main+0xd2>
      // Clumsy but will have to do for now.
      // Chdir has no effect on the parent if run in the child.
      buf[strlen(buf)-1] = 0;  // chop \n
      if(chdir(buf+3) < 0)
        printf(2, "cannot cd %s\n", buf+3);
      continue;
     354:	90                   	nop
      break;
    }
  }
  
  // Read and run input commands.
  while(getcmd(buf, sizeof(buf)) >= 0){
     355:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
     35c:	00 
     35d:	c7 04 24 60 1a 00 00 	movl   $0x1a60,(%esp)
     364:	e8 bc fe ff ff       	call   225 <getcmd>
     369:	85 c0                	test   %eax,%eax
     36b:	0f 89 5a ff ff ff    	jns    2cb <main+0x48>
    }
    if(fork1() == 0)
      runcmd(parsecmd(buf));
    wait();
  }
  exit(EXIT_STATUS_DEFAULT);
     371:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     378:	e8 0f 0c 00 00       	call   f8c <exit>

0000037d <panic>:
}

void
panic(char *s)
{
     37d:	55                   	push   %ebp
     37e:	89 e5                	mov    %esp,%ebp
     380:	83 ec 18             	sub    $0x18,%esp
  printf(2, "%s\n", s);
     383:	8b 45 08             	mov    0x8(%ebp),%eax
     386:	89 44 24 08          	mov    %eax,0x8(%esp)
     38a:	c7 44 24 04 25 15 00 	movl   $0x1525,0x4(%esp)
     391:	00 
     392:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     399:	e8 65 0d 00 00       	call   1103 <printf>
  exit(EXIT_STATUS_DEFAULT);
     39e:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     3a5:	e8 e2 0b 00 00       	call   f8c <exit>

000003aa <fork1>:
}

int
fork1(void)
{
     3aa:	55                   	push   %ebp
     3ab:	89 e5                	mov    %esp,%ebp
     3ad:	83 ec 28             	sub    $0x28,%esp
  int pid;
  
  pid = fork();
     3b0:	e8 cf 0b 00 00       	call   f84 <fork>
     3b5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pid == -1)
     3b8:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
     3bc:	75 0c                	jne    3ca <fork1+0x20>
    panic("fork");
     3be:	c7 04 24 29 15 00 00 	movl   $0x1529,(%esp)
     3c5:	e8 b3 ff ff ff       	call   37d <panic>
  return pid;
     3ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     3cd:	c9                   	leave  
     3ce:	c3                   	ret    

000003cf <execcmd>:
//PAGEBREAK!
// Constructors

struct cmd*
execcmd(void)
{
     3cf:	55                   	push   %ebp
     3d0:	89 e5                	mov    %esp,%ebp
     3d2:	83 ec 28             	sub    $0x28,%esp
  struct execcmd *cmd;

  cmd = malloc(sizeof(*cmd));
     3d5:	c7 04 24 54 00 00 00 	movl   $0x54,(%esp)
     3dc:	e8 06 10 00 00       	call   13e7 <malloc>
     3e1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(cmd, 0, sizeof(*cmd));
     3e4:	c7 44 24 08 54 00 00 	movl   $0x54,0x8(%esp)
     3eb:	00 
     3ec:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     3f3:	00 
     3f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
     3f7:	89 04 24             	mov    %eax,(%esp)
     3fa:	e8 e8 09 00 00       	call   de7 <memset>
  cmd->type = EXEC;
     3ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
     402:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  return (struct cmd*)cmd;
     408:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     40b:	c9                   	leave  
     40c:	c3                   	ret    

0000040d <redircmd>:

struct cmd*
redircmd(struct cmd *subcmd, char *file, char *efile, int mode, int fd)
{
     40d:	55                   	push   %ebp
     40e:	89 e5                	mov    %esp,%ebp
     410:	83 ec 28             	sub    $0x28,%esp
  struct redircmd *cmd;

  cmd = malloc(sizeof(*cmd));
     413:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
     41a:	e8 c8 0f 00 00       	call   13e7 <malloc>
     41f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(cmd, 0, sizeof(*cmd));
     422:	c7 44 24 08 18 00 00 	movl   $0x18,0x8(%esp)
     429:	00 
     42a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     431:	00 
     432:	8b 45 f4             	mov    -0xc(%ebp),%eax
     435:	89 04 24             	mov    %eax,(%esp)
     438:	e8 aa 09 00 00       	call   de7 <memset>
  cmd->type = REDIR;
     43d:	8b 45 f4             	mov    -0xc(%ebp),%eax
     440:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  cmd->cmd = subcmd;
     446:	8b 45 f4             	mov    -0xc(%ebp),%eax
     449:	8b 55 08             	mov    0x8(%ebp),%edx
     44c:	89 50 04             	mov    %edx,0x4(%eax)
  cmd->file = file;
     44f:	8b 45 f4             	mov    -0xc(%ebp),%eax
     452:	8b 55 0c             	mov    0xc(%ebp),%edx
     455:	89 50 08             	mov    %edx,0x8(%eax)
  cmd->efile = efile;
     458:	8b 45 f4             	mov    -0xc(%ebp),%eax
     45b:	8b 55 10             	mov    0x10(%ebp),%edx
     45e:	89 50 0c             	mov    %edx,0xc(%eax)
  cmd->mode = mode;
     461:	8b 45 f4             	mov    -0xc(%ebp),%eax
     464:	8b 55 14             	mov    0x14(%ebp),%edx
     467:	89 50 10             	mov    %edx,0x10(%eax)
  cmd->fd = fd;
     46a:	8b 45 f4             	mov    -0xc(%ebp),%eax
     46d:	8b 55 18             	mov    0x18(%ebp),%edx
     470:	89 50 14             	mov    %edx,0x14(%eax)
  return (struct cmd*)cmd;
     473:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     476:	c9                   	leave  
     477:	c3                   	ret    

00000478 <pipecmd>:

struct cmd*
pipecmd(struct cmd *left, struct cmd *right)
{
     478:	55                   	push   %ebp
     479:	89 e5                	mov    %esp,%ebp
     47b:	83 ec 28             	sub    $0x28,%esp
  struct pipecmd *cmd;

  cmd = malloc(sizeof(*cmd));
     47e:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
     485:	e8 5d 0f 00 00       	call   13e7 <malloc>
     48a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(cmd, 0, sizeof(*cmd));
     48d:	c7 44 24 08 0c 00 00 	movl   $0xc,0x8(%esp)
     494:	00 
     495:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     49c:	00 
     49d:	8b 45 f4             	mov    -0xc(%ebp),%eax
     4a0:	89 04 24             	mov    %eax,(%esp)
     4a3:	e8 3f 09 00 00       	call   de7 <memset>
  cmd->type = PIPE;
     4a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
     4ab:	c7 00 03 00 00 00    	movl   $0x3,(%eax)
  cmd->left = left;
     4b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
     4b4:	8b 55 08             	mov    0x8(%ebp),%edx
     4b7:	89 50 04             	mov    %edx,0x4(%eax)
  cmd->right = right;
     4ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
     4bd:	8b 55 0c             	mov    0xc(%ebp),%edx
     4c0:	89 50 08             	mov    %edx,0x8(%eax)
  return (struct cmd*)cmd;
     4c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     4c6:	c9                   	leave  
     4c7:	c3                   	ret    

000004c8 <listcmd>:

struct cmd*
listcmd(struct cmd *left, struct cmd *right)
{
     4c8:	55                   	push   %ebp
     4c9:	89 e5                	mov    %esp,%ebp
     4cb:	83 ec 28             	sub    $0x28,%esp
  struct listcmd *cmd;

  cmd = malloc(sizeof(*cmd));
     4ce:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
     4d5:	e8 0d 0f 00 00       	call   13e7 <malloc>
     4da:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(cmd, 0, sizeof(*cmd));
     4dd:	c7 44 24 08 0c 00 00 	movl   $0xc,0x8(%esp)
     4e4:	00 
     4e5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     4ec:	00 
     4ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
     4f0:	89 04 24             	mov    %eax,(%esp)
     4f3:	e8 ef 08 00 00       	call   de7 <memset>
  cmd->type = LIST;
     4f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
     4fb:	c7 00 04 00 00 00    	movl   $0x4,(%eax)
  cmd->left = left;
     501:	8b 45 f4             	mov    -0xc(%ebp),%eax
     504:	8b 55 08             	mov    0x8(%ebp),%edx
     507:	89 50 04             	mov    %edx,0x4(%eax)
  cmd->right = right;
     50a:	8b 45 f4             	mov    -0xc(%ebp),%eax
     50d:	8b 55 0c             	mov    0xc(%ebp),%edx
     510:	89 50 08             	mov    %edx,0x8(%eax)
  return (struct cmd*)cmd;
     513:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     516:	c9                   	leave  
     517:	c3                   	ret    

00000518 <backcmd>:

struct cmd*
backcmd(struct cmd *subcmd)
{
     518:	55                   	push   %ebp
     519:	89 e5                	mov    %esp,%ebp
     51b:	83 ec 28             	sub    $0x28,%esp
  struct backcmd *cmd;

  cmd = malloc(sizeof(*cmd));
     51e:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
     525:	e8 bd 0e 00 00       	call   13e7 <malloc>
     52a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(cmd, 0, sizeof(*cmd));
     52d:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
     534:	00 
     535:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     53c:	00 
     53d:	8b 45 f4             	mov    -0xc(%ebp),%eax
     540:	89 04 24             	mov    %eax,(%esp)
     543:	e8 9f 08 00 00       	call   de7 <memset>
  cmd->type = BACK;
     548:	8b 45 f4             	mov    -0xc(%ebp),%eax
     54b:	c7 00 05 00 00 00    	movl   $0x5,(%eax)
  cmd->cmd = subcmd;
     551:	8b 45 f4             	mov    -0xc(%ebp),%eax
     554:	8b 55 08             	mov    0x8(%ebp),%edx
     557:	89 50 04             	mov    %edx,0x4(%eax)
  return (struct cmd*)cmd;
     55a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     55d:	c9                   	leave  
     55e:	c3                   	ret    

0000055f <gettoken>:
char whitespace[] = " \t\r\n\v";
char symbols[] = "<|>&;()";

int
gettoken(char **ps, char *es, char **q, char **eq)
{
     55f:	55                   	push   %ebp
     560:	89 e5                	mov    %esp,%ebp
     562:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int ret;
  
  s = *ps;
     565:	8b 45 08             	mov    0x8(%ebp),%eax
     568:	8b 00                	mov    (%eax),%eax
     56a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(s < es && strchr(whitespace, *s))
     56d:	eb 04                	jmp    573 <gettoken+0x14>
    s++;
     56f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
{
  char *s;
  int ret;
  
  s = *ps;
  while(s < es && strchr(whitespace, *s))
     573:	8b 45 f4             	mov    -0xc(%ebp),%eax
     576:	3b 45 0c             	cmp    0xc(%ebp),%eax
     579:	73 1d                	jae    598 <gettoken+0x39>
     57b:	8b 45 f4             	mov    -0xc(%ebp),%eax
     57e:	0f b6 00             	movzbl (%eax),%eax
     581:	0f be c0             	movsbl %al,%eax
     584:	89 44 24 04          	mov    %eax,0x4(%esp)
     588:	c7 04 24 38 1a 00 00 	movl   $0x1a38,(%esp)
     58f:	e8 77 08 00 00       	call   e0b <strchr>
     594:	85 c0                	test   %eax,%eax
     596:	75 d7                	jne    56f <gettoken+0x10>
    s++;
  if(q)
     598:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
     59c:	74 08                	je     5a6 <gettoken+0x47>
    *q = s;
     59e:	8b 45 10             	mov    0x10(%ebp),%eax
     5a1:	8b 55 f4             	mov    -0xc(%ebp),%edx
     5a4:	89 10                	mov    %edx,(%eax)
  ret = *s;
     5a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
     5a9:	0f b6 00             	movzbl (%eax),%eax
     5ac:	0f be c0             	movsbl %al,%eax
     5af:	89 45 f0             	mov    %eax,-0x10(%ebp)
  switch(*s){
     5b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
     5b5:	0f b6 00             	movzbl (%eax),%eax
     5b8:	0f be c0             	movsbl %al,%eax
     5bb:	83 f8 3c             	cmp    $0x3c,%eax
     5be:	7f 1e                	jg     5de <gettoken+0x7f>
     5c0:	83 f8 3b             	cmp    $0x3b,%eax
     5c3:	7d 23                	jge    5e8 <gettoken+0x89>
     5c5:	83 f8 29             	cmp    $0x29,%eax
     5c8:	7f 3f                	jg     609 <gettoken+0xaa>
     5ca:	83 f8 28             	cmp    $0x28,%eax
     5cd:	7d 19                	jge    5e8 <gettoken+0x89>
     5cf:	85 c0                	test   %eax,%eax
     5d1:	0f 84 83 00 00 00    	je     65a <gettoken+0xfb>
     5d7:	83 f8 26             	cmp    $0x26,%eax
     5da:	74 0c                	je     5e8 <gettoken+0x89>
     5dc:	eb 2b                	jmp    609 <gettoken+0xaa>
     5de:	83 f8 3e             	cmp    $0x3e,%eax
     5e1:	74 0b                	je     5ee <gettoken+0x8f>
     5e3:	83 f8 7c             	cmp    $0x7c,%eax
     5e6:	75 21                	jne    609 <gettoken+0xaa>
  case '(':
  case ')':
  case ';':
  case '&':
  case '<':
    s++;
     5e8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    break;
     5ec:	eb 73                	jmp    661 <gettoken+0x102>
  case '>':
    s++;
     5ee:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(*s == '>'){
     5f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
     5f5:	0f b6 00             	movzbl (%eax),%eax
     5f8:	3c 3e                	cmp    $0x3e,%al
     5fa:	75 61                	jne    65d <gettoken+0xfe>
      ret = '+';
     5fc:	c7 45 f0 2b 00 00 00 	movl   $0x2b,-0x10(%ebp)
      s++;
     603:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    }
    break;
     607:	eb 54                	jmp    65d <gettoken+0xfe>
  default:
    ret = 'a';
     609:	c7 45 f0 61 00 00 00 	movl   $0x61,-0x10(%ebp)
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
     610:	eb 04                	jmp    616 <gettoken+0xb7>
      s++;
     612:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      s++;
    }
    break;
  default:
    ret = 'a';
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
     616:	8b 45 f4             	mov    -0xc(%ebp),%eax
     619:	3b 45 0c             	cmp    0xc(%ebp),%eax
     61c:	73 42                	jae    660 <gettoken+0x101>
     61e:	8b 45 f4             	mov    -0xc(%ebp),%eax
     621:	0f b6 00             	movzbl (%eax),%eax
     624:	0f be c0             	movsbl %al,%eax
     627:	89 44 24 04          	mov    %eax,0x4(%esp)
     62b:	c7 04 24 38 1a 00 00 	movl   $0x1a38,(%esp)
     632:	e8 d4 07 00 00       	call   e0b <strchr>
     637:	85 c0                	test   %eax,%eax
     639:	75 25                	jne    660 <gettoken+0x101>
     63b:	8b 45 f4             	mov    -0xc(%ebp),%eax
     63e:	0f b6 00             	movzbl (%eax),%eax
     641:	0f be c0             	movsbl %al,%eax
     644:	89 44 24 04          	mov    %eax,0x4(%esp)
     648:	c7 04 24 3e 1a 00 00 	movl   $0x1a3e,(%esp)
     64f:	e8 b7 07 00 00       	call   e0b <strchr>
     654:	85 c0                	test   %eax,%eax
     656:	74 ba                	je     612 <gettoken+0xb3>
      s++;
    break;
     658:	eb 06                	jmp    660 <gettoken+0x101>
  if(q)
    *q = s;
  ret = *s;
  switch(*s){
  case 0:
    break;
     65a:	90                   	nop
     65b:	eb 04                	jmp    661 <gettoken+0x102>
    s++;
    if(*s == '>'){
      ret = '+';
      s++;
    }
    break;
     65d:	90                   	nop
     65e:	eb 01                	jmp    661 <gettoken+0x102>
  default:
    ret = 'a';
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
      s++;
    break;
     660:	90                   	nop
  }
  if(eq)
     661:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
     665:	74 0e                	je     675 <gettoken+0x116>
    *eq = s;
     667:	8b 45 14             	mov    0x14(%ebp),%eax
     66a:	8b 55 f4             	mov    -0xc(%ebp),%edx
     66d:	89 10                	mov    %edx,(%eax)
  
  while(s < es && strchr(whitespace, *s))
     66f:	eb 04                	jmp    675 <gettoken+0x116>
    s++;
     671:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    break;
  }
  if(eq)
    *eq = s;
  
  while(s < es && strchr(whitespace, *s))
     675:	8b 45 f4             	mov    -0xc(%ebp),%eax
     678:	3b 45 0c             	cmp    0xc(%ebp),%eax
     67b:	73 1d                	jae    69a <gettoken+0x13b>
     67d:	8b 45 f4             	mov    -0xc(%ebp),%eax
     680:	0f b6 00             	movzbl (%eax),%eax
     683:	0f be c0             	movsbl %al,%eax
     686:	89 44 24 04          	mov    %eax,0x4(%esp)
     68a:	c7 04 24 38 1a 00 00 	movl   $0x1a38,(%esp)
     691:	e8 75 07 00 00       	call   e0b <strchr>
     696:	85 c0                	test   %eax,%eax
     698:	75 d7                	jne    671 <gettoken+0x112>
    s++;
  *ps = s;
     69a:	8b 45 08             	mov    0x8(%ebp),%eax
     69d:	8b 55 f4             	mov    -0xc(%ebp),%edx
     6a0:	89 10                	mov    %edx,(%eax)
  return ret;
     6a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
     6a5:	c9                   	leave  
     6a6:	c3                   	ret    

000006a7 <peek>:

int
peek(char **ps, char *es, char *toks)
{
     6a7:	55                   	push   %ebp
     6a8:	89 e5                	mov    %esp,%ebp
     6aa:	83 ec 28             	sub    $0x28,%esp
  char *s;
  
  s = *ps;
     6ad:	8b 45 08             	mov    0x8(%ebp),%eax
     6b0:	8b 00                	mov    (%eax),%eax
     6b2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(s < es && strchr(whitespace, *s))
     6b5:	eb 04                	jmp    6bb <peek+0x14>
    s++;
     6b7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
peek(char **ps, char *es, char *toks)
{
  char *s;
  
  s = *ps;
  while(s < es && strchr(whitespace, *s))
     6bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
     6be:	3b 45 0c             	cmp    0xc(%ebp),%eax
     6c1:	73 1d                	jae    6e0 <peek+0x39>
     6c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
     6c6:	0f b6 00             	movzbl (%eax),%eax
     6c9:	0f be c0             	movsbl %al,%eax
     6cc:	89 44 24 04          	mov    %eax,0x4(%esp)
     6d0:	c7 04 24 38 1a 00 00 	movl   $0x1a38,(%esp)
     6d7:	e8 2f 07 00 00       	call   e0b <strchr>
     6dc:	85 c0                	test   %eax,%eax
     6de:	75 d7                	jne    6b7 <peek+0x10>
    s++;
  *ps = s;
     6e0:	8b 45 08             	mov    0x8(%ebp),%eax
     6e3:	8b 55 f4             	mov    -0xc(%ebp),%edx
     6e6:	89 10                	mov    %edx,(%eax)
  return *s && strchr(toks, *s);
     6e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
     6eb:	0f b6 00             	movzbl (%eax),%eax
     6ee:	84 c0                	test   %al,%al
     6f0:	74 23                	je     715 <peek+0x6e>
     6f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
     6f5:	0f b6 00             	movzbl (%eax),%eax
     6f8:	0f be c0             	movsbl %al,%eax
     6fb:	89 44 24 04          	mov    %eax,0x4(%esp)
     6ff:	8b 45 10             	mov    0x10(%ebp),%eax
     702:	89 04 24             	mov    %eax,(%esp)
     705:	e8 01 07 00 00       	call   e0b <strchr>
     70a:	85 c0                	test   %eax,%eax
     70c:	74 07                	je     715 <peek+0x6e>
     70e:	b8 01 00 00 00       	mov    $0x1,%eax
     713:	eb 05                	jmp    71a <peek+0x73>
     715:	b8 00 00 00 00       	mov    $0x0,%eax
}
     71a:	c9                   	leave  
     71b:	c3                   	ret    

0000071c <parsecmd>:
struct cmd *parseexec(char**, char*);
struct cmd *nulterminate(struct cmd*);

struct cmd*
parsecmd(char *s)
{
     71c:	55                   	push   %ebp
     71d:	89 e5                	mov    %esp,%ebp
     71f:	53                   	push   %ebx
     720:	83 ec 24             	sub    $0x24,%esp
  char *es;
  struct cmd *cmd;

  es = s + strlen(s);
     723:	8b 5d 08             	mov    0x8(%ebp),%ebx
     726:	8b 45 08             	mov    0x8(%ebp),%eax
     729:	89 04 24             	mov    %eax,(%esp)
     72c:	e8 91 06 00 00       	call   dc2 <strlen>
     731:	01 d8                	add    %ebx,%eax
     733:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cmd = parseline(&s, es);
     736:	8b 45 f4             	mov    -0xc(%ebp),%eax
     739:	89 44 24 04          	mov    %eax,0x4(%esp)
     73d:	8d 45 08             	lea    0x8(%ebp),%eax
     740:	89 04 24             	mov    %eax,(%esp)
     743:	e8 60 00 00 00       	call   7a8 <parseline>
     748:	89 45 f0             	mov    %eax,-0x10(%ebp)
  peek(&s, es, "");
     74b:	c7 44 24 08 2e 15 00 	movl   $0x152e,0x8(%esp)
     752:	00 
     753:	8b 45 f4             	mov    -0xc(%ebp),%eax
     756:	89 44 24 04          	mov    %eax,0x4(%esp)
     75a:	8d 45 08             	lea    0x8(%ebp),%eax
     75d:	89 04 24             	mov    %eax,(%esp)
     760:	e8 42 ff ff ff       	call   6a7 <peek>
  if(s != es){
     765:	8b 45 08             	mov    0x8(%ebp),%eax
     768:	3b 45 f4             	cmp    -0xc(%ebp),%eax
     76b:	74 27                	je     794 <parsecmd+0x78>
    printf(2, "leftovers: %s\n", s);
     76d:	8b 45 08             	mov    0x8(%ebp),%eax
     770:	89 44 24 08          	mov    %eax,0x8(%esp)
     774:	c7 44 24 04 2f 15 00 	movl   $0x152f,0x4(%esp)
     77b:	00 
     77c:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     783:	e8 7b 09 00 00       	call   1103 <printf>
    panic("syntax");
     788:	c7 04 24 3e 15 00 00 	movl   $0x153e,(%esp)
     78f:	e8 e9 fb ff ff       	call   37d <panic>
  }
  nulterminate(cmd);
     794:	8b 45 f0             	mov    -0x10(%ebp),%eax
     797:	89 04 24             	mov    %eax,(%esp)
     79a:	e8 a5 04 00 00       	call   c44 <nulterminate>
  return cmd;
     79f:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
     7a2:	83 c4 24             	add    $0x24,%esp
     7a5:	5b                   	pop    %ebx
     7a6:	5d                   	pop    %ebp
     7a7:	c3                   	ret    

000007a8 <parseline>:

struct cmd*
parseline(char **ps, char *es)
{
     7a8:	55                   	push   %ebp
     7a9:	89 e5                	mov    %esp,%ebp
     7ab:	83 ec 28             	sub    $0x28,%esp
  struct cmd *cmd;

  cmd = parsepipe(ps, es);
     7ae:	8b 45 0c             	mov    0xc(%ebp),%eax
     7b1:	89 44 24 04          	mov    %eax,0x4(%esp)
     7b5:	8b 45 08             	mov    0x8(%ebp),%eax
     7b8:	89 04 24             	mov    %eax,(%esp)
     7bb:	e8 bc 00 00 00       	call   87c <parsepipe>
     7c0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(peek(ps, es, "&")){
     7c3:	eb 30                	jmp    7f5 <parseline+0x4d>
    gettoken(ps, es, 0, 0);
     7c5:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
     7cc:	00 
     7cd:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
     7d4:	00 
     7d5:	8b 45 0c             	mov    0xc(%ebp),%eax
     7d8:	89 44 24 04          	mov    %eax,0x4(%esp)
     7dc:	8b 45 08             	mov    0x8(%ebp),%eax
     7df:	89 04 24             	mov    %eax,(%esp)
     7e2:	e8 78 fd ff ff       	call   55f <gettoken>
    cmd = backcmd(cmd);
     7e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
     7ea:	89 04 24             	mov    %eax,(%esp)
     7ed:	e8 26 fd ff ff       	call   518 <backcmd>
     7f2:	89 45 f4             	mov    %eax,-0xc(%ebp)
parseline(char **ps, char *es)
{
  struct cmd *cmd;

  cmd = parsepipe(ps, es);
  while(peek(ps, es, "&")){
     7f5:	c7 44 24 08 45 15 00 	movl   $0x1545,0x8(%esp)
     7fc:	00 
     7fd:	8b 45 0c             	mov    0xc(%ebp),%eax
     800:	89 44 24 04          	mov    %eax,0x4(%esp)
     804:	8b 45 08             	mov    0x8(%ebp),%eax
     807:	89 04 24             	mov    %eax,(%esp)
     80a:	e8 98 fe ff ff       	call   6a7 <peek>
     80f:	85 c0                	test   %eax,%eax
     811:	75 b2                	jne    7c5 <parseline+0x1d>
    gettoken(ps, es, 0, 0);
    cmd = backcmd(cmd);
  }
  if(peek(ps, es, ";")){
     813:	c7 44 24 08 47 15 00 	movl   $0x1547,0x8(%esp)
     81a:	00 
     81b:	8b 45 0c             	mov    0xc(%ebp),%eax
     81e:	89 44 24 04          	mov    %eax,0x4(%esp)
     822:	8b 45 08             	mov    0x8(%ebp),%eax
     825:	89 04 24             	mov    %eax,(%esp)
     828:	e8 7a fe ff ff       	call   6a7 <peek>
     82d:	85 c0                	test   %eax,%eax
     82f:	74 46                	je     877 <parseline+0xcf>
    gettoken(ps, es, 0, 0);
     831:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
     838:	00 
     839:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
     840:	00 
     841:	8b 45 0c             	mov    0xc(%ebp),%eax
     844:	89 44 24 04          	mov    %eax,0x4(%esp)
     848:	8b 45 08             	mov    0x8(%ebp),%eax
     84b:	89 04 24             	mov    %eax,(%esp)
     84e:	e8 0c fd ff ff       	call   55f <gettoken>
    cmd = listcmd(cmd, parseline(ps, es));
     853:	8b 45 0c             	mov    0xc(%ebp),%eax
     856:	89 44 24 04          	mov    %eax,0x4(%esp)
     85a:	8b 45 08             	mov    0x8(%ebp),%eax
     85d:	89 04 24             	mov    %eax,(%esp)
     860:	e8 43 ff ff ff       	call   7a8 <parseline>
     865:	89 44 24 04          	mov    %eax,0x4(%esp)
     869:	8b 45 f4             	mov    -0xc(%ebp),%eax
     86c:	89 04 24             	mov    %eax,(%esp)
     86f:	e8 54 fc ff ff       	call   4c8 <listcmd>
     874:	89 45 f4             	mov    %eax,-0xc(%ebp)
  }
  return cmd;
     877:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     87a:	c9                   	leave  
     87b:	c3                   	ret    

0000087c <parsepipe>:

struct cmd*
parsepipe(char **ps, char *es)
{
     87c:	55                   	push   %ebp
     87d:	89 e5                	mov    %esp,%ebp
     87f:	83 ec 28             	sub    $0x28,%esp
  struct cmd *cmd;

  cmd = parseexec(ps, es);
     882:	8b 45 0c             	mov    0xc(%ebp),%eax
     885:	89 44 24 04          	mov    %eax,0x4(%esp)
     889:	8b 45 08             	mov    0x8(%ebp),%eax
     88c:	89 04 24             	mov    %eax,(%esp)
     88f:	e8 68 02 00 00       	call   afc <parseexec>
     894:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(peek(ps, es, "|")){
     897:	c7 44 24 08 49 15 00 	movl   $0x1549,0x8(%esp)
     89e:	00 
     89f:	8b 45 0c             	mov    0xc(%ebp),%eax
     8a2:	89 44 24 04          	mov    %eax,0x4(%esp)
     8a6:	8b 45 08             	mov    0x8(%ebp),%eax
     8a9:	89 04 24             	mov    %eax,(%esp)
     8ac:	e8 f6 fd ff ff       	call   6a7 <peek>
     8b1:	85 c0                	test   %eax,%eax
     8b3:	74 46                	je     8fb <parsepipe+0x7f>
    gettoken(ps, es, 0, 0);
     8b5:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
     8bc:	00 
     8bd:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
     8c4:	00 
     8c5:	8b 45 0c             	mov    0xc(%ebp),%eax
     8c8:	89 44 24 04          	mov    %eax,0x4(%esp)
     8cc:	8b 45 08             	mov    0x8(%ebp),%eax
     8cf:	89 04 24             	mov    %eax,(%esp)
     8d2:	e8 88 fc ff ff       	call   55f <gettoken>
    cmd = pipecmd(cmd, parsepipe(ps, es));
     8d7:	8b 45 0c             	mov    0xc(%ebp),%eax
     8da:	89 44 24 04          	mov    %eax,0x4(%esp)
     8de:	8b 45 08             	mov    0x8(%ebp),%eax
     8e1:	89 04 24             	mov    %eax,(%esp)
     8e4:	e8 93 ff ff ff       	call   87c <parsepipe>
     8e9:	89 44 24 04          	mov    %eax,0x4(%esp)
     8ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
     8f0:	89 04 24             	mov    %eax,(%esp)
     8f3:	e8 80 fb ff ff       	call   478 <pipecmd>
     8f8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  }
  return cmd;
     8fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     8fe:	c9                   	leave  
     8ff:	c3                   	ret    

00000900 <parseredirs>:

struct cmd*
parseredirs(struct cmd *cmd, char **ps, char *es)
{
     900:	55                   	push   %ebp
     901:	89 e5                	mov    %esp,%ebp
     903:	83 ec 38             	sub    $0x38,%esp
  int tok;
  char *q, *eq;

  while(peek(ps, es, "<>")){
     906:	e9 f6 00 00 00       	jmp    a01 <parseredirs+0x101>
    tok = gettoken(ps, es, 0, 0);
     90b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
     912:	00 
     913:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
     91a:	00 
     91b:	8b 45 10             	mov    0x10(%ebp),%eax
     91e:	89 44 24 04          	mov    %eax,0x4(%esp)
     922:	8b 45 0c             	mov    0xc(%ebp),%eax
     925:	89 04 24             	mov    %eax,(%esp)
     928:	e8 32 fc ff ff       	call   55f <gettoken>
     92d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(gettoken(ps, es, &q, &eq) != 'a')
     930:	8d 45 ec             	lea    -0x14(%ebp),%eax
     933:	89 44 24 0c          	mov    %eax,0xc(%esp)
     937:	8d 45 f0             	lea    -0x10(%ebp),%eax
     93a:	89 44 24 08          	mov    %eax,0x8(%esp)
     93e:	8b 45 10             	mov    0x10(%ebp),%eax
     941:	89 44 24 04          	mov    %eax,0x4(%esp)
     945:	8b 45 0c             	mov    0xc(%ebp),%eax
     948:	89 04 24             	mov    %eax,(%esp)
     94b:	e8 0f fc ff ff       	call   55f <gettoken>
     950:	83 f8 61             	cmp    $0x61,%eax
     953:	74 0c                	je     961 <parseredirs+0x61>
      panic("missing file for redirection");
     955:	c7 04 24 4b 15 00 00 	movl   $0x154b,(%esp)
     95c:	e8 1c fa ff ff       	call   37d <panic>
    switch(tok){
     961:	8b 45 f4             	mov    -0xc(%ebp),%eax
     964:	83 f8 3c             	cmp    $0x3c,%eax
     967:	74 0f                	je     978 <parseredirs+0x78>
     969:	83 f8 3e             	cmp    $0x3e,%eax
     96c:	74 38                	je     9a6 <parseredirs+0xa6>
     96e:	83 f8 2b             	cmp    $0x2b,%eax
     971:	74 61                	je     9d4 <parseredirs+0xd4>
     973:	e9 89 00 00 00       	jmp    a01 <parseredirs+0x101>
    case '<':
      cmd = redircmd(cmd, q, eq, O_RDONLY, 0);
     978:	8b 55 ec             	mov    -0x14(%ebp),%edx
     97b:	8b 45 f0             	mov    -0x10(%ebp),%eax
     97e:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
     985:	00 
     986:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
     98d:	00 
     98e:	89 54 24 08          	mov    %edx,0x8(%esp)
     992:	89 44 24 04          	mov    %eax,0x4(%esp)
     996:	8b 45 08             	mov    0x8(%ebp),%eax
     999:	89 04 24             	mov    %eax,(%esp)
     99c:	e8 6c fa ff ff       	call   40d <redircmd>
     9a1:	89 45 08             	mov    %eax,0x8(%ebp)
      break;
     9a4:	eb 5b                	jmp    a01 <parseredirs+0x101>
    case '>':
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE, 1);
     9a6:	8b 55 ec             	mov    -0x14(%ebp),%edx
     9a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
     9ac:	c7 44 24 10 01 00 00 	movl   $0x1,0x10(%esp)
     9b3:	00 
     9b4:	c7 44 24 0c 01 02 00 	movl   $0x201,0xc(%esp)
     9bb:	00 
     9bc:	89 54 24 08          	mov    %edx,0x8(%esp)
     9c0:	89 44 24 04          	mov    %eax,0x4(%esp)
     9c4:	8b 45 08             	mov    0x8(%ebp),%eax
     9c7:	89 04 24             	mov    %eax,(%esp)
     9ca:	e8 3e fa ff ff       	call   40d <redircmd>
     9cf:	89 45 08             	mov    %eax,0x8(%ebp)
      break;
     9d2:	eb 2d                	jmp    a01 <parseredirs+0x101>
    case '+':  // >>
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE, 1);
     9d4:	8b 55 ec             	mov    -0x14(%ebp),%edx
     9d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
     9da:	c7 44 24 10 01 00 00 	movl   $0x1,0x10(%esp)
     9e1:	00 
     9e2:	c7 44 24 0c 01 02 00 	movl   $0x201,0xc(%esp)
     9e9:	00 
     9ea:	89 54 24 08          	mov    %edx,0x8(%esp)
     9ee:	89 44 24 04          	mov    %eax,0x4(%esp)
     9f2:	8b 45 08             	mov    0x8(%ebp),%eax
     9f5:	89 04 24             	mov    %eax,(%esp)
     9f8:	e8 10 fa ff ff       	call   40d <redircmd>
     9fd:	89 45 08             	mov    %eax,0x8(%ebp)
      break;
     a00:	90                   	nop
parseredirs(struct cmd *cmd, char **ps, char *es)
{
  int tok;
  char *q, *eq;

  while(peek(ps, es, "<>")){
     a01:	c7 44 24 08 68 15 00 	movl   $0x1568,0x8(%esp)
     a08:	00 
     a09:	8b 45 10             	mov    0x10(%ebp),%eax
     a0c:	89 44 24 04          	mov    %eax,0x4(%esp)
     a10:	8b 45 0c             	mov    0xc(%ebp),%eax
     a13:	89 04 24             	mov    %eax,(%esp)
     a16:	e8 8c fc ff ff       	call   6a7 <peek>
     a1b:	85 c0                	test   %eax,%eax
     a1d:	0f 85 e8 fe ff ff    	jne    90b <parseredirs+0xb>
    case '+':  // >>
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE, 1);
      break;
    }
  }
  return cmd;
     a23:	8b 45 08             	mov    0x8(%ebp),%eax
}
     a26:	c9                   	leave  
     a27:	c3                   	ret    

00000a28 <parseblock>:

struct cmd*
parseblock(char **ps, char *es)
{
     a28:	55                   	push   %ebp
     a29:	89 e5                	mov    %esp,%ebp
     a2b:	83 ec 28             	sub    $0x28,%esp
  struct cmd *cmd;

  if(!peek(ps, es, "("))
     a2e:	c7 44 24 08 6b 15 00 	movl   $0x156b,0x8(%esp)
     a35:	00 
     a36:	8b 45 0c             	mov    0xc(%ebp),%eax
     a39:	89 44 24 04          	mov    %eax,0x4(%esp)
     a3d:	8b 45 08             	mov    0x8(%ebp),%eax
     a40:	89 04 24             	mov    %eax,(%esp)
     a43:	e8 5f fc ff ff       	call   6a7 <peek>
     a48:	85 c0                	test   %eax,%eax
     a4a:	75 0c                	jne    a58 <parseblock+0x30>
    panic("parseblock");
     a4c:	c7 04 24 6d 15 00 00 	movl   $0x156d,(%esp)
     a53:	e8 25 f9 ff ff       	call   37d <panic>
  gettoken(ps, es, 0, 0);
     a58:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
     a5f:	00 
     a60:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
     a67:	00 
     a68:	8b 45 0c             	mov    0xc(%ebp),%eax
     a6b:	89 44 24 04          	mov    %eax,0x4(%esp)
     a6f:	8b 45 08             	mov    0x8(%ebp),%eax
     a72:	89 04 24             	mov    %eax,(%esp)
     a75:	e8 e5 fa ff ff       	call   55f <gettoken>
  cmd = parseline(ps, es);
     a7a:	8b 45 0c             	mov    0xc(%ebp),%eax
     a7d:	89 44 24 04          	mov    %eax,0x4(%esp)
     a81:	8b 45 08             	mov    0x8(%ebp),%eax
     a84:	89 04 24             	mov    %eax,(%esp)
     a87:	e8 1c fd ff ff       	call   7a8 <parseline>
     a8c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(!peek(ps, es, ")"))
     a8f:	c7 44 24 08 78 15 00 	movl   $0x1578,0x8(%esp)
     a96:	00 
     a97:	8b 45 0c             	mov    0xc(%ebp),%eax
     a9a:	89 44 24 04          	mov    %eax,0x4(%esp)
     a9e:	8b 45 08             	mov    0x8(%ebp),%eax
     aa1:	89 04 24             	mov    %eax,(%esp)
     aa4:	e8 fe fb ff ff       	call   6a7 <peek>
     aa9:	85 c0                	test   %eax,%eax
     aab:	75 0c                	jne    ab9 <parseblock+0x91>
    panic("syntax - missing )");
     aad:	c7 04 24 7a 15 00 00 	movl   $0x157a,(%esp)
     ab4:	e8 c4 f8 ff ff       	call   37d <panic>
  gettoken(ps, es, 0, 0);
     ab9:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
     ac0:	00 
     ac1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
     ac8:	00 
     ac9:	8b 45 0c             	mov    0xc(%ebp),%eax
     acc:	89 44 24 04          	mov    %eax,0x4(%esp)
     ad0:	8b 45 08             	mov    0x8(%ebp),%eax
     ad3:	89 04 24             	mov    %eax,(%esp)
     ad6:	e8 84 fa ff ff       	call   55f <gettoken>
  cmd = parseredirs(cmd, ps, es);
     adb:	8b 45 0c             	mov    0xc(%ebp),%eax
     ade:	89 44 24 08          	mov    %eax,0x8(%esp)
     ae2:	8b 45 08             	mov    0x8(%ebp),%eax
     ae5:	89 44 24 04          	mov    %eax,0x4(%esp)
     ae9:	8b 45 f4             	mov    -0xc(%ebp),%eax
     aec:	89 04 24             	mov    %eax,(%esp)
     aef:	e8 0c fe ff ff       	call   900 <parseredirs>
     af4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  return cmd;
     af7:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     afa:	c9                   	leave  
     afb:	c3                   	ret    

00000afc <parseexec>:

struct cmd*
parseexec(char **ps, char *es)
{
     afc:	55                   	push   %ebp
     afd:	89 e5                	mov    %esp,%ebp
     aff:	83 ec 38             	sub    $0x38,%esp
  char *q, *eq;
  int tok, argc;
  struct execcmd *cmd;
  struct cmd *ret;
  
  if(peek(ps, es, "("))
     b02:	c7 44 24 08 6b 15 00 	movl   $0x156b,0x8(%esp)
     b09:	00 
     b0a:	8b 45 0c             	mov    0xc(%ebp),%eax
     b0d:	89 44 24 04          	mov    %eax,0x4(%esp)
     b11:	8b 45 08             	mov    0x8(%ebp),%eax
     b14:	89 04 24             	mov    %eax,(%esp)
     b17:	e8 8b fb ff ff       	call   6a7 <peek>
     b1c:	85 c0                	test   %eax,%eax
     b1e:	74 17                	je     b37 <parseexec+0x3b>
    return parseblock(ps, es);
     b20:	8b 45 0c             	mov    0xc(%ebp),%eax
     b23:	89 44 24 04          	mov    %eax,0x4(%esp)
     b27:	8b 45 08             	mov    0x8(%ebp),%eax
     b2a:	89 04 24             	mov    %eax,(%esp)
     b2d:	e8 f6 fe ff ff       	call   a28 <parseblock>
     b32:	e9 0b 01 00 00       	jmp    c42 <parseexec+0x146>

  ret = execcmd();
     b37:	e8 93 f8 ff ff       	call   3cf <execcmd>
     b3c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  cmd = (struct execcmd*)ret;
     b3f:	8b 45 f0             	mov    -0x10(%ebp),%eax
     b42:	89 45 ec             	mov    %eax,-0x14(%ebp)

  argc = 0;
     b45:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  ret = parseredirs(ret, ps, es);
     b4c:	8b 45 0c             	mov    0xc(%ebp),%eax
     b4f:	89 44 24 08          	mov    %eax,0x8(%esp)
     b53:	8b 45 08             	mov    0x8(%ebp),%eax
     b56:	89 44 24 04          	mov    %eax,0x4(%esp)
     b5a:	8b 45 f0             	mov    -0x10(%ebp),%eax
     b5d:	89 04 24             	mov    %eax,(%esp)
     b60:	e8 9b fd ff ff       	call   900 <parseredirs>
     b65:	89 45 f0             	mov    %eax,-0x10(%ebp)
  while(!peek(ps, es, "|)&;")){
     b68:	e9 8e 00 00 00       	jmp    bfb <parseexec+0xff>
    if((tok=gettoken(ps, es, &q, &eq)) == 0)
     b6d:	8d 45 e0             	lea    -0x20(%ebp),%eax
     b70:	89 44 24 0c          	mov    %eax,0xc(%esp)
     b74:	8d 45 e4             	lea    -0x1c(%ebp),%eax
     b77:	89 44 24 08          	mov    %eax,0x8(%esp)
     b7b:	8b 45 0c             	mov    0xc(%ebp),%eax
     b7e:	89 44 24 04          	mov    %eax,0x4(%esp)
     b82:	8b 45 08             	mov    0x8(%ebp),%eax
     b85:	89 04 24             	mov    %eax,(%esp)
     b88:	e8 d2 f9 ff ff       	call   55f <gettoken>
     b8d:	89 45 e8             	mov    %eax,-0x18(%ebp)
     b90:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
     b94:	0f 84 85 00 00 00    	je     c1f <parseexec+0x123>
      break;
    if(tok != 'a')
     b9a:	83 7d e8 61          	cmpl   $0x61,-0x18(%ebp)
     b9e:	74 0c                	je     bac <parseexec+0xb0>
      panic("syntax");
     ba0:	c7 04 24 3e 15 00 00 	movl   $0x153e,(%esp)
     ba7:	e8 d1 f7 ff ff       	call   37d <panic>
    cmd->argv[argc] = q;
     bac:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
     baf:	8b 45 ec             	mov    -0x14(%ebp),%eax
     bb2:	8b 55 f4             	mov    -0xc(%ebp),%edx
     bb5:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
    cmd->eargv[argc] = eq;
     bb9:	8b 55 e0             	mov    -0x20(%ebp),%edx
     bbc:	8b 45 ec             	mov    -0x14(%ebp),%eax
     bbf:	8b 4d f4             	mov    -0xc(%ebp),%ecx
     bc2:	83 c1 08             	add    $0x8,%ecx
     bc5:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    argc++;
     bc9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(argc >= MAXARGS)
     bcd:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
     bd1:	7e 0c                	jle    bdf <parseexec+0xe3>
      panic("too many args");
     bd3:	c7 04 24 8d 15 00 00 	movl   $0x158d,(%esp)
     bda:	e8 9e f7 ff ff       	call   37d <panic>
    ret = parseredirs(ret, ps, es);
     bdf:	8b 45 0c             	mov    0xc(%ebp),%eax
     be2:	89 44 24 08          	mov    %eax,0x8(%esp)
     be6:	8b 45 08             	mov    0x8(%ebp),%eax
     be9:	89 44 24 04          	mov    %eax,0x4(%esp)
     bed:	8b 45 f0             	mov    -0x10(%ebp),%eax
     bf0:	89 04 24             	mov    %eax,(%esp)
     bf3:	e8 08 fd ff ff       	call   900 <parseredirs>
     bf8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  ret = execcmd();
  cmd = (struct execcmd*)ret;

  argc = 0;
  ret = parseredirs(ret, ps, es);
  while(!peek(ps, es, "|)&;")){
     bfb:	c7 44 24 08 9b 15 00 	movl   $0x159b,0x8(%esp)
     c02:	00 
     c03:	8b 45 0c             	mov    0xc(%ebp),%eax
     c06:	89 44 24 04          	mov    %eax,0x4(%esp)
     c0a:	8b 45 08             	mov    0x8(%ebp),%eax
     c0d:	89 04 24             	mov    %eax,(%esp)
     c10:	e8 92 fa ff ff       	call   6a7 <peek>
     c15:	85 c0                	test   %eax,%eax
     c17:	0f 84 50 ff ff ff    	je     b6d <parseexec+0x71>
     c1d:	eb 01                	jmp    c20 <parseexec+0x124>
    if((tok=gettoken(ps, es, &q, &eq)) == 0)
      break;
     c1f:	90                   	nop
    argc++;
    if(argc >= MAXARGS)
      panic("too many args");
    ret = parseredirs(ret, ps, es);
  }
  cmd->argv[argc] = 0;
     c20:	8b 45 ec             	mov    -0x14(%ebp),%eax
     c23:	8b 55 f4             	mov    -0xc(%ebp),%edx
     c26:	c7 44 90 04 00 00 00 	movl   $0x0,0x4(%eax,%edx,4)
     c2d:	00 
  cmd->eargv[argc] = 0;
     c2e:	8b 45 ec             	mov    -0x14(%ebp),%eax
     c31:	8b 55 f4             	mov    -0xc(%ebp),%edx
     c34:	83 c2 08             	add    $0x8,%edx
     c37:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
     c3e:	00 
  return ret;
     c3f:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
     c42:	c9                   	leave  
     c43:	c3                   	ret    

00000c44 <nulterminate>:

// NUL-terminate all the counted strings.
struct cmd*
nulterminate(struct cmd *cmd)
{
     c44:	55                   	push   %ebp
     c45:	89 e5                	mov    %esp,%ebp
     c47:	83 ec 38             	sub    $0x38,%esp
  struct execcmd *ecmd;
  struct listcmd *lcmd;
  struct pipecmd *pcmd;
  struct redircmd *rcmd;

  if(cmd == 0)
     c4a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
     c4e:	75 0a                	jne    c5a <nulterminate+0x16>
    return 0;
     c50:	b8 00 00 00 00       	mov    $0x0,%eax
     c55:	e9 c9 00 00 00       	jmp    d23 <nulterminate+0xdf>
  
  switch(cmd->type){
     c5a:	8b 45 08             	mov    0x8(%ebp),%eax
     c5d:	8b 00                	mov    (%eax),%eax
     c5f:	83 f8 05             	cmp    $0x5,%eax
     c62:	0f 87 b8 00 00 00    	ja     d20 <nulterminate+0xdc>
     c68:	8b 04 85 a0 15 00 00 	mov    0x15a0(,%eax,4),%eax
     c6f:	ff e0                	jmp    *%eax
  case EXEC:
    ecmd = (struct execcmd*)cmd;
     c71:	8b 45 08             	mov    0x8(%ebp),%eax
     c74:	89 45 f0             	mov    %eax,-0x10(%ebp)
    for(i=0; ecmd->argv[i]; i++)
     c77:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     c7e:	eb 14                	jmp    c94 <nulterminate+0x50>
      *ecmd->eargv[i] = 0;
     c80:	8b 45 f0             	mov    -0x10(%ebp),%eax
     c83:	8b 55 f4             	mov    -0xc(%ebp),%edx
     c86:	83 c2 08             	add    $0x8,%edx
     c89:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
     c8d:	c6 00 00             	movb   $0x0,(%eax)
    return 0;
  
  switch(cmd->type){
  case EXEC:
    ecmd = (struct execcmd*)cmd;
    for(i=0; ecmd->argv[i]; i++)
     c90:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
     c94:	8b 45 f0             	mov    -0x10(%ebp),%eax
     c97:	8b 55 f4             	mov    -0xc(%ebp),%edx
     c9a:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
     c9e:	85 c0                	test   %eax,%eax
     ca0:	75 de                	jne    c80 <nulterminate+0x3c>
      *ecmd->eargv[i] = 0;
    break;
     ca2:	eb 7c                	jmp    d20 <nulterminate+0xdc>

  case REDIR:
    rcmd = (struct redircmd*)cmd;
     ca4:	8b 45 08             	mov    0x8(%ebp),%eax
     ca7:	89 45 ec             	mov    %eax,-0x14(%ebp)
    nulterminate(rcmd->cmd);
     caa:	8b 45 ec             	mov    -0x14(%ebp),%eax
     cad:	8b 40 04             	mov    0x4(%eax),%eax
     cb0:	89 04 24             	mov    %eax,(%esp)
     cb3:	e8 8c ff ff ff       	call   c44 <nulterminate>
    *rcmd->efile = 0;
     cb8:	8b 45 ec             	mov    -0x14(%ebp),%eax
     cbb:	8b 40 0c             	mov    0xc(%eax),%eax
     cbe:	c6 00 00             	movb   $0x0,(%eax)
    break;
     cc1:	eb 5d                	jmp    d20 <nulterminate+0xdc>

  case PIPE:
    pcmd = (struct pipecmd*)cmd;
     cc3:	8b 45 08             	mov    0x8(%ebp),%eax
     cc6:	89 45 e8             	mov    %eax,-0x18(%ebp)
    nulterminate(pcmd->left);
     cc9:	8b 45 e8             	mov    -0x18(%ebp),%eax
     ccc:	8b 40 04             	mov    0x4(%eax),%eax
     ccf:	89 04 24             	mov    %eax,(%esp)
     cd2:	e8 6d ff ff ff       	call   c44 <nulterminate>
    nulterminate(pcmd->right);
     cd7:	8b 45 e8             	mov    -0x18(%ebp),%eax
     cda:	8b 40 08             	mov    0x8(%eax),%eax
     cdd:	89 04 24             	mov    %eax,(%esp)
     ce0:	e8 5f ff ff ff       	call   c44 <nulterminate>
    break;
     ce5:	eb 39                	jmp    d20 <nulterminate+0xdc>
    
  case LIST:
    lcmd = (struct listcmd*)cmd;
     ce7:	8b 45 08             	mov    0x8(%ebp),%eax
     cea:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    nulterminate(lcmd->left);
     ced:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     cf0:	8b 40 04             	mov    0x4(%eax),%eax
     cf3:	89 04 24             	mov    %eax,(%esp)
     cf6:	e8 49 ff ff ff       	call   c44 <nulterminate>
    nulterminate(lcmd->right);
     cfb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     cfe:	8b 40 08             	mov    0x8(%eax),%eax
     d01:	89 04 24             	mov    %eax,(%esp)
     d04:	e8 3b ff ff ff       	call   c44 <nulterminate>
    break;
     d09:	eb 15                	jmp    d20 <nulterminate+0xdc>

  case BACK:
    bcmd = (struct backcmd*)cmd;
     d0b:	8b 45 08             	mov    0x8(%ebp),%eax
     d0e:	89 45 e0             	mov    %eax,-0x20(%ebp)
    nulterminate(bcmd->cmd);
     d11:	8b 45 e0             	mov    -0x20(%ebp),%eax
     d14:	8b 40 04             	mov    0x4(%eax),%eax
     d17:	89 04 24             	mov    %eax,(%esp)
     d1a:	e8 25 ff ff ff       	call   c44 <nulterminate>
    break;
     d1f:	90                   	nop
  }
  return cmd;
     d20:	8b 45 08             	mov    0x8(%ebp),%eax
}
     d23:	c9                   	leave  
     d24:	c3                   	ret    
     d25:	90                   	nop
     d26:	90                   	nop
     d27:	90                   	nop

00000d28 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
     d28:	55                   	push   %ebp
     d29:	89 e5                	mov    %esp,%ebp
     d2b:	57                   	push   %edi
     d2c:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
     d2d:	8b 4d 08             	mov    0x8(%ebp),%ecx
     d30:	8b 55 10             	mov    0x10(%ebp),%edx
     d33:	8b 45 0c             	mov    0xc(%ebp),%eax
     d36:	89 cb                	mov    %ecx,%ebx
     d38:	89 df                	mov    %ebx,%edi
     d3a:	89 d1                	mov    %edx,%ecx
     d3c:	fc                   	cld    
     d3d:	f3 aa                	rep stos %al,%es:(%edi)
     d3f:	89 ca                	mov    %ecx,%edx
     d41:	89 fb                	mov    %edi,%ebx
     d43:	89 5d 08             	mov    %ebx,0x8(%ebp)
     d46:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
     d49:	5b                   	pop    %ebx
     d4a:	5f                   	pop    %edi
     d4b:	5d                   	pop    %ebp
     d4c:	c3                   	ret    

00000d4d <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
     d4d:	55                   	push   %ebp
     d4e:	89 e5                	mov    %esp,%ebp
     d50:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
     d53:	8b 45 08             	mov    0x8(%ebp),%eax
     d56:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
     d59:	90                   	nop
     d5a:	8b 45 0c             	mov    0xc(%ebp),%eax
     d5d:	0f b6 10             	movzbl (%eax),%edx
     d60:	8b 45 08             	mov    0x8(%ebp),%eax
     d63:	88 10                	mov    %dl,(%eax)
     d65:	8b 45 08             	mov    0x8(%ebp),%eax
     d68:	0f b6 00             	movzbl (%eax),%eax
     d6b:	84 c0                	test   %al,%al
     d6d:	0f 95 c0             	setne  %al
     d70:	83 45 08 01          	addl   $0x1,0x8(%ebp)
     d74:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
     d78:	84 c0                	test   %al,%al
     d7a:	75 de                	jne    d5a <strcpy+0xd>
    ;
  return os;
     d7c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
     d7f:	c9                   	leave  
     d80:	c3                   	ret    

00000d81 <strcmp>:

int
strcmp(const char *p, const char *q)
{
     d81:	55                   	push   %ebp
     d82:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
     d84:	eb 08                	jmp    d8e <strcmp+0xd>
    p++, q++;
     d86:	83 45 08 01          	addl   $0x1,0x8(%ebp)
     d8a:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
     d8e:	8b 45 08             	mov    0x8(%ebp),%eax
     d91:	0f b6 00             	movzbl (%eax),%eax
     d94:	84 c0                	test   %al,%al
     d96:	74 10                	je     da8 <strcmp+0x27>
     d98:	8b 45 08             	mov    0x8(%ebp),%eax
     d9b:	0f b6 10             	movzbl (%eax),%edx
     d9e:	8b 45 0c             	mov    0xc(%ebp),%eax
     da1:	0f b6 00             	movzbl (%eax),%eax
     da4:	38 c2                	cmp    %al,%dl
     da6:	74 de                	je     d86 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
     da8:	8b 45 08             	mov    0x8(%ebp),%eax
     dab:	0f b6 00             	movzbl (%eax),%eax
     dae:	0f b6 d0             	movzbl %al,%edx
     db1:	8b 45 0c             	mov    0xc(%ebp),%eax
     db4:	0f b6 00             	movzbl (%eax),%eax
     db7:	0f b6 c0             	movzbl %al,%eax
     dba:	89 d1                	mov    %edx,%ecx
     dbc:	29 c1                	sub    %eax,%ecx
     dbe:	89 c8                	mov    %ecx,%eax
}
     dc0:	5d                   	pop    %ebp
     dc1:	c3                   	ret    

00000dc2 <strlen>:

uint
strlen(char *s)
{
     dc2:	55                   	push   %ebp
     dc3:	89 e5                	mov    %esp,%ebp
     dc5:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
     dc8:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
     dcf:	eb 04                	jmp    dd5 <strlen+0x13>
     dd1:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
     dd5:	8b 45 fc             	mov    -0x4(%ebp),%eax
     dd8:	03 45 08             	add    0x8(%ebp),%eax
     ddb:	0f b6 00             	movzbl (%eax),%eax
     dde:	84 c0                	test   %al,%al
     de0:	75 ef                	jne    dd1 <strlen+0xf>
    ;
  return n;
     de2:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
     de5:	c9                   	leave  
     de6:	c3                   	ret    

00000de7 <memset>:

void*
memset(void *dst, int c, uint n)
{
     de7:	55                   	push   %ebp
     de8:	89 e5                	mov    %esp,%ebp
     dea:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
     ded:	8b 45 10             	mov    0x10(%ebp),%eax
     df0:	89 44 24 08          	mov    %eax,0x8(%esp)
     df4:	8b 45 0c             	mov    0xc(%ebp),%eax
     df7:	89 44 24 04          	mov    %eax,0x4(%esp)
     dfb:	8b 45 08             	mov    0x8(%ebp),%eax
     dfe:	89 04 24             	mov    %eax,(%esp)
     e01:	e8 22 ff ff ff       	call   d28 <stosb>
  return dst;
     e06:	8b 45 08             	mov    0x8(%ebp),%eax
}
     e09:	c9                   	leave  
     e0a:	c3                   	ret    

00000e0b <strchr>:

char*
strchr(const char *s, char c)
{
     e0b:	55                   	push   %ebp
     e0c:	89 e5                	mov    %esp,%ebp
     e0e:	83 ec 04             	sub    $0x4,%esp
     e11:	8b 45 0c             	mov    0xc(%ebp),%eax
     e14:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
     e17:	eb 14                	jmp    e2d <strchr+0x22>
    if(*s == c)
     e19:	8b 45 08             	mov    0x8(%ebp),%eax
     e1c:	0f b6 00             	movzbl (%eax),%eax
     e1f:	3a 45 fc             	cmp    -0x4(%ebp),%al
     e22:	75 05                	jne    e29 <strchr+0x1e>
      return (char*)s;
     e24:	8b 45 08             	mov    0x8(%ebp),%eax
     e27:	eb 13                	jmp    e3c <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
     e29:	83 45 08 01          	addl   $0x1,0x8(%ebp)
     e2d:	8b 45 08             	mov    0x8(%ebp),%eax
     e30:	0f b6 00             	movzbl (%eax),%eax
     e33:	84 c0                	test   %al,%al
     e35:	75 e2                	jne    e19 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
     e37:	b8 00 00 00 00       	mov    $0x0,%eax
}
     e3c:	c9                   	leave  
     e3d:	c3                   	ret    

00000e3e <gets>:

char*
gets(char *buf, int max)
{
     e3e:	55                   	push   %ebp
     e3f:	89 e5                	mov    %esp,%ebp
     e41:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
     e44:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     e4b:	eb 44                	jmp    e91 <gets+0x53>
    cc = read(0, &c, 1);
     e4d:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
     e54:	00 
     e55:	8d 45 ef             	lea    -0x11(%ebp),%eax
     e58:	89 44 24 04          	mov    %eax,0x4(%esp)
     e5c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
     e63:	e8 3c 01 00 00       	call   fa4 <read>
     e68:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
     e6b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
     e6f:	7e 2d                	jle    e9e <gets+0x60>
      break;
    buf[i++] = c;
     e71:	8b 45 f4             	mov    -0xc(%ebp),%eax
     e74:	03 45 08             	add    0x8(%ebp),%eax
     e77:	0f b6 55 ef          	movzbl -0x11(%ebp),%edx
     e7b:	88 10                	mov    %dl,(%eax)
     e7d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(c == '\n' || c == '\r')
     e81:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
     e85:	3c 0a                	cmp    $0xa,%al
     e87:	74 16                	je     e9f <gets+0x61>
     e89:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
     e8d:	3c 0d                	cmp    $0xd,%al
     e8f:	74 0e                	je     e9f <gets+0x61>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
     e91:	8b 45 f4             	mov    -0xc(%ebp),%eax
     e94:	83 c0 01             	add    $0x1,%eax
     e97:	3b 45 0c             	cmp    0xc(%ebp),%eax
     e9a:	7c b1                	jl     e4d <gets+0xf>
     e9c:	eb 01                	jmp    e9f <gets+0x61>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
     e9e:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
     e9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
     ea2:	03 45 08             	add    0x8(%ebp),%eax
     ea5:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
     ea8:	8b 45 08             	mov    0x8(%ebp),%eax
}
     eab:	c9                   	leave  
     eac:	c3                   	ret    

00000ead <stat>:

int
stat(char *n, struct stat *st)
{
     ead:	55                   	push   %ebp
     eae:	89 e5                	mov    %esp,%ebp
     eb0:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
     eb3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     eba:	00 
     ebb:	8b 45 08             	mov    0x8(%ebp),%eax
     ebe:	89 04 24             	mov    %eax,(%esp)
     ec1:	e8 06 01 00 00       	call   fcc <open>
     ec6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
     ec9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
     ecd:	79 07                	jns    ed6 <stat+0x29>
    return -1;
     ecf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
     ed4:	eb 23                	jmp    ef9 <stat+0x4c>
  r = fstat(fd, st);
     ed6:	8b 45 0c             	mov    0xc(%ebp),%eax
     ed9:	89 44 24 04          	mov    %eax,0x4(%esp)
     edd:	8b 45 f4             	mov    -0xc(%ebp),%eax
     ee0:	89 04 24             	mov    %eax,(%esp)
     ee3:	e8 fc 00 00 00       	call   fe4 <fstat>
     ee8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
     eeb:	8b 45 f4             	mov    -0xc(%ebp),%eax
     eee:	89 04 24             	mov    %eax,(%esp)
     ef1:	e8 be 00 00 00       	call   fb4 <close>
  return r;
     ef6:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
     ef9:	c9                   	leave  
     efa:	c3                   	ret    

00000efb <atoi>:

int
atoi(const char *s)
{
     efb:	55                   	push   %ebp
     efc:	89 e5                	mov    %esp,%ebp
     efe:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
     f01:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
     f08:	eb 23                	jmp    f2d <atoi+0x32>
    n = n*10 + *s++ - '0';
     f0a:	8b 55 fc             	mov    -0x4(%ebp),%edx
     f0d:	89 d0                	mov    %edx,%eax
     f0f:	c1 e0 02             	shl    $0x2,%eax
     f12:	01 d0                	add    %edx,%eax
     f14:	01 c0                	add    %eax,%eax
     f16:	89 c2                	mov    %eax,%edx
     f18:	8b 45 08             	mov    0x8(%ebp),%eax
     f1b:	0f b6 00             	movzbl (%eax),%eax
     f1e:	0f be c0             	movsbl %al,%eax
     f21:	01 d0                	add    %edx,%eax
     f23:	83 e8 30             	sub    $0x30,%eax
     f26:	89 45 fc             	mov    %eax,-0x4(%ebp)
     f29:	83 45 08 01          	addl   $0x1,0x8(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
     f2d:	8b 45 08             	mov    0x8(%ebp),%eax
     f30:	0f b6 00             	movzbl (%eax),%eax
     f33:	3c 2f                	cmp    $0x2f,%al
     f35:	7e 0a                	jle    f41 <atoi+0x46>
     f37:	8b 45 08             	mov    0x8(%ebp),%eax
     f3a:	0f b6 00             	movzbl (%eax),%eax
     f3d:	3c 39                	cmp    $0x39,%al
     f3f:	7e c9                	jle    f0a <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
     f41:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
     f44:	c9                   	leave  
     f45:	c3                   	ret    

00000f46 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
     f46:	55                   	push   %ebp
     f47:	89 e5                	mov    %esp,%ebp
     f49:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
     f4c:	8b 45 08             	mov    0x8(%ebp),%eax
     f4f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
     f52:	8b 45 0c             	mov    0xc(%ebp),%eax
     f55:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
     f58:	eb 13                	jmp    f6d <memmove+0x27>
    *dst++ = *src++;
     f5a:	8b 45 f8             	mov    -0x8(%ebp),%eax
     f5d:	0f b6 10             	movzbl (%eax),%edx
     f60:	8b 45 fc             	mov    -0x4(%ebp),%eax
     f63:	88 10                	mov    %dl,(%eax)
     f65:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
     f69:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
     f6d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
     f71:	0f 9f c0             	setg   %al
     f74:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
     f78:	84 c0                	test   %al,%al
     f7a:	75 de                	jne    f5a <memmove+0x14>
    *dst++ = *src++;
  return vdst;
     f7c:	8b 45 08             	mov    0x8(%ebp),%eax
}
     f7f:	c9                   	leave  
     f80:	c3                   	ret    
     f81:	90                   	nop
     f82:	90                   	nop
     f83:	90                   	nop

00000f84 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
     f84:	b8 01 00 00 00       	mov    $0x1,%eax
     f89:	cd 40                	int    $0x40
     f8b:	c3                   	ret    

00000f8c <exit>:
SYSCALL(exit)
     f8c:	b8 02 00 00 00       	mov    $0x2,%eax
     f91:	cd 40                	int    $0x40
     f93:	c3                   	ret    

00000f94 <wait>:
SYSCALL(wait)
     f94:	b8 03 00 00 00       	mov    $0x3,%eax
     f99:	cd 40                	int    $0x40
     f9b:	c3                   	ret    

00000f9c <pipe>:
SYSCALL(pipe)
     f9c:	b8 04 00 00 00       	mov    $0x4,%eax
     fa1:	cd 40                	int    $0x40
     fa3:	c3                   	ret    

00000fa4 <read>:
SYSCALL(read)
     fa4:	b8 05 00 00 00       	mov    $0x5,%eax
     fa9:	cd 40                	int    $0x40
     fab:	c3                   	ret    

00000fac <write>:
SYSCALL(write)
     fac:	b8 10 00 00 00       	mov    $0x10,%eax
     fb1:	cd 40                	int    $0x40
     fb3:	c3                   	ret    

00000fb4 <close>:
SYSCALL(close)
     fb4:	b8 15 00 00 00       	mov    $0x15,%eax
     fb9:	cd 40                	int    $0x40
     fbb:	c3                   	ret    

00000fbc <kill>:
SYSCALL(kill)
     fbc:	b8 06 00 00 00       	mov    $0x6,%eax
     fc1:	cd 40                	int    $0x40
     fc3:	c3                   	ret    

00000fc4 <exec>:
SYSCALL(exec)
     fc4:	b8 07 00 00 00       	mov    $0x7,%eax
     fc9:	cd 40                	int    $0x40
     fcb:	c3                   	ret    

00000fcc <open>:
SYSCALL(open)
     fcc:	b8 0f 00 00 00       	mov    $0xf,%eax
     fd1:	cd 40                	int    $0x40
     fd3:	c3                   	ret    

00000fd4 <mknod>:
SYSCALL(mknod)
     fd4:	b8 11 00 00 00       	mov    $0x11,%eax
     fd9:	cd 40                	int    $0x40
     fdb:	c3                   	ret    

00000fdc <unlink>:
SYSCALL(unlink)
     fdc:	b8 12 00 00 00       	mov    $0x12,%eax
     fe1:	cd 40                	int    $0x40
     fe3:	c3                   	ret    

00000fe4 <fstat>:
SYSCALL(fstat)
     fe4:	b8 08 00 00 00       	mov    $0x8,%eax
     fe9:	cd 40                	int    $0x40
     feb:	c3                   	ret    

00000fec <link>:
SYSCALL(link)
     fec:	b8 13 00 00 00       	mov    $0x13,%eax
     ff1:	cd 40                	int    $0x40
     ff3:	c3                   	ret    

00000ff4 <mkdir>:
SYSCALL(mkdir)
     ff4:	b8 14 00 00 00       	mov    $0x14,%eax
     ff9:	cd 40                	int    $0x40
     ffb:	c3                   	ret    

00000ffc <chdir>:
SYSCALL(chdir)
     ffc:	b8 09 00 00 00       	mov    $0x9,%eax
    1001:	cd 40                	int    $0x40
    1003:	c3                   	ret    

00001004 <dup>:
SYSCALL(dup)
    1004:	b8 0a 00 00 00       	mov    $0xa,%eax
    1009:	cd 40                	int    $0x40
    100b:	c3                   	ret    

0000100c <getpid>:
SYSCALL(getpid)
    100c:	b8 0b 00 00 00       	mov    $0xb,%eax
    1011:	cd 40                	int    $0x40
    1013:	c3                   	ret    

00001014 <sbrk>:
SYSCALL(sbrk)
    1014:	b8 0c 00 00 00       	mov    $0xc,%eax
    1019:	cd 40                	int    $0x40
    101b:	c3                   	ret    

0000101c <sleep>:
SYSCALL(sleep)
    101c:	b8 0d 00 00 00       	mov    $0xd,%eax
    1021:	cd 40                	int    $0x40
    1023:	c3                   	ret    

00001024 <uptime>:
SYSCALL(uptime)
    1024:	b8 0e 00 00 00       	mov    $0xe,%eax
    1029:	cd 40                	int    $0x40
    102b:	c3                   	ret    

0000102c <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
    102c:	55                   	push   %ebp
    102d:	89 e5                	mov    %esp,%ebp
    102f:	83 ec 28             	sub    $0x28,%esp
    1032:	8b 45 0c             	mov    0xc(%ebp),%eax
    1035:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
    1038:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
    103f:	00 
    1040:	8d 45 f4             	lea    -0xc(%ebp),%eax
    1043:	89 44 24 04          	mov    %eax,0x4(%esp)
    1047:	8b 45 08             	mov    0x8(%ebp),%eax
    104a:	89 04 24             	mov    %eax,(%esp)
    104d:	e8 5a ff ff ff       	call   fac <write>
}
    1052:	c9                   	leave  
    1053:	c3                   	ret    

00001054 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
    1054:	55                   	push   %ebp
    1055:	89 e5                	mov    %esp,%ebp
    1057:	83 ec 48             	sub    $0x48,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
    105a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
    1061:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
    1065:	74 17                	je     107e <printint+0x2a>
    1067:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
    106b:	79 11                	jns    107e <printint+0x2a>
    neg = 1;
    106d:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
    1074:	8b 45 0c             	mov    0xc(%ebp),%eax
    1077:	f7 d8                	neg    %eax
    1079:	89 45 ec             	mov    %eax,-0x14(%ebp)
    107c:	eb 06                	jmp    1084 <printint+0x30>
  } else {
    x = xx;
    107e:	8b 45 0c             	mov    0xc(%ebp),%eax
    1081:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
    1084:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
    108b:	8b 4d 10             	mov    0x10(%ebp),%ecx
    108e:	8b 45 ec             	mov    -0x14(%ebp),%eax
    1091:	ba 00 00 00 00       	mov    $0x0,%edx
    1096:	f7 f1                	div    %ecx
    1098:	89 d0                	mov    %edx,%eax
    109a:	0f b6 90 48 1a 00 00 	movzbl 0x1a48(%eax),%edx
    10a1:	8d 45 dc             	lea    -0x24(%ebp),%eax
    10a4:	03 45 f4             	add    -0xc(%ebp),%eax
    10a7:	88 10                	mov    %dl,(%eax)
    10a9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  }while((x /= base) != 0);
    10ad:	8b 55 10             	mov    0x10(%ebp),%edx
    10b0:	89 55 d4             	mov    %edx,-0x2c(%ebp)
    10b3:	8b 45 ec             	mov    -0x14(%ebp),%eax
    10b6:	ba 00 00 00 00       	mov    $0x0,%edx
    10bb:	f7 75 d4             	divl   -0x2c(%ebp)
    10be:	89 45 ec             	mov    %eax,-0x14(%ebp)
    10c1:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    10c5:	75 c4                	jne    108b <printint+0x37>
  if(neg)
    10c7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    10cb:	74 2a                	je     10f7 <printint+0xa3>
    buf[i++] = '-';
    10cd:	8d 45 dc             	lea    -0x24(%ebp),%eax
    10d0:	03 45 f4             	add    -0xc(%ebp),%eax
    10d3:	c6 00 2d             	movb   $0x2d,(%eax)
    10d6:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

  while(--i >= 0)
    10da:	eb 1b                	jmp    10f7 <printint+0xa3>
    putc(fd, buf[i]);
    10dc:	8d 45 dc             	lea    -0x24(%ebp),%eax
    10df:	03 45 f4             	add    -0xc(%ebp),%eax
    10e2:	0f b6 00             	movzbl (%eax),%eax
    10e5:	0f be c0             	movsbl %al,%eax
    10e8:	89 44 24 04          	mov    %eax,0x4(%esp)
    10ec:	8b 45 08             	mov    0x8(%ebp),%eax
    10ef:	89 04 24             	mov    %eax,(%esp)
    10f2:	e8 35 ff ff ff       	call   102c <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
    10f7:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
    10fb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    10ff:	79 db                	jns    10dc <printint+0x88>
    putc(fd, buf[i]);
}
    1101:	c9                   	leave  
    1102:	c3                   	ret    

00001103 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
    1103:	55                   	push   %ebp
    1104:	89 e5                	mov    %esp,%ebp
    1106:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
    1109:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
    1110:	8d 45 0c             	lea    0xc(%ebp),%eax
    1113:	83 c0 04             	add    $0x4,%eax
    1116:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
    1119:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    1120:	e9 7d 01 00 00       	jmp    12a2 <printf+0x19f>
    c = fmt[i] & 0xff;
    1125:	8b 55 0c             	mov    0xc(%ebp),%edx
    1128:	8b 45 f0             	mov    -0x10(%ebp),%eax
    112b:	01 d0                	add    %edx,%eax
    112d:	0f b6 00             	movzbl (%eax),%eax
    1130:	0f be c0             	movsbl %al,%eax
    1133:	25 ff 00 00 00       	and    $0xff,%eax
    1138:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
    113b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    113f:	75 2c                	jne    116d <printf+0x6a>
      if(c == '%'){
    1141:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
    1145:	75 0c                	jne    1153 <printf+0x50>
        state = '%';
    1147:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
    114e:	e9 4b 01 00 00       	jmp    129e <printf+0x19b>
      } else {
        putc(fd, c);
    1153:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    1156:	0f be c0             	movsbl %al,%eax
    1159:	89 44 24 04          	mov    %eax,0x4(%esp)
    115d:	8b 45 08             	mov    0x8(%ebp),%eax
    1160:	89 04 24             	mov    %eax,(%esp)
    1163:	e8 c4 fe ff ff       	call   102c <putc>
    1168:	e9 31 01 00 00       	jmp    129e <printf+0x19b>
      }
    } else if(state == '%'){
    116d:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
    1171:	0f 85 27 01 00 00    	jne    129e <printf+0x19b>
      if(c == 'd'){
    1177:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
    117b:	75 2d                	jne    11aa <printf+0xa7>
        printint(fd, *ap, 10, 1);
    117d:	8b 45 e8             	mov    -0x18(%ebp),%eax
    1180:	8b 00                	mov    (%eax),%eax
    1182:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
    1189:	00 
    118a:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
    1191:	00 
    1192:	89 44 24 04          	mov    %eax,0x4(%esp)
    1196:	8b 45 08             	mov    0x8(%ebp),%eax
    1199:	89 04 24             	mov    %eax,(%esp)
    119c:	e8 b3 fe ff ff       	call   1054 <printint>
        ap++;
    11a1:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    11a5:	e9 ed 00 00 00       	jmp    1297 <printf+0x194>
      } else if(c == 'x' || c == 'p'){
    11aa:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
    11ae:	74 06                	je     11b6 <printf+0xb3>
    11b0:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
    11b4:	75 2d                	jne    11e3 <printf+0xe0>
        printint(fd, *ap, 16, 0);
    11b6:	8b 45 e8             	mov    -0x18(%ebp),%eax
    11b9:	8b 00                	mov    (%eax),%eax
    11bb:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
    11c2:	00 
    11c3:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
    11ca:	00 
    11cb:	89 44 24 04          	mov    %eax,0x4(%esp)
    11cf:	8b 45 08             	mov    0x8(%ebp),%eax
    11d2:	89 04 24             	mov    %eax,(%esp)
    11d5:	e8 7a fe ff ff       	call   1054 <printint>
        ap++;
    11da:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    11de:	e9 b4 00 00 00       	jmp    1297 <printf+0x194>
      } else if(c == 's'){
    11e3:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
    11e7:	75 46                	jne    122f <printf+0x12c>
        s = (char*)*ap;
    11e9:	8b 45 e8             	mov    -0x18(%ebp),%eax
    11ec:	8b 00                	mov    (%eax),%eax
    11ee:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
    11f1:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
    11f5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    11f9:	75 27                	jne    1222 <printf+0x11f>
          s = "(null)";
    11fb:	c7 45 f4 b8 15 00 00 	movl   $0x15b8,-0xc(%ebp)
        while(*s != 0){
    1202:	eb 1e                	jmp    1222 <printf+0x11f>
          putc(fd, *s);
    1204:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1207:	0f b6 00             	movzbl (%eax),%eax
    120a:	0f be c0             	movsbl %al,%eax
    120d:	89 44 24 04          	mov    %eax,0x4(%esp)
    1211:	8b 45 08             	mov    0x8(%ebp),%eax
    1214:	89 04 24             	mov    %eax,(%esp)
    1217:	e8 10 fe ff ff       	call   102c <putc>
          s++;
    121c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    1220:	eb 01                	jmp    1223 <printf+0x120>
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
    1222:	90                   	nop
    1223:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1226:	0f b6 00             	movzbl (%eax),%eax
    1229:	84 c0                	test   %al,%al
    122b:	75 d7                	jne    1204 <printf+0x101>
    122d:	eb 68                	jmp    1297 <printf+0x194>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
    122f:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
    1233:	75 1d                	jne    1252 <printf+0x14f>
        putc(fd, *ap);
    1235:	8b 45 e8             	mov    -0x18(%ebp),%eax
    1238:	8b 00                	mov    (%eax),%eax
    123a:	0f be c0             	movsbl %al,%eax
    123d:	89 44 24 04          	mov    %eax,0x4(%esp)
    1241:	8b 45 08             	mov    0x8(%ebp),%eax
    1244:	89 04 24             	mov    %eax,(%esp)
    1247:	e8 e0 fd ff ff       	call   102c <putc>
        ap++;
    124c:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    1250:	eb 45                	jmp    1297 <printf+0x194>
      } else if(c == '%'){
    1252:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
    1256:	75 17                	jne    126f <printf+0x16c>
        putc(fd, c);
    1258:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    125b:	0f be c0             	movsbl %al,%eax
    125e:	89 44 24 04          	mov    %eax,0x4(%esp)
    1262:	8b 45 08             	mov    0x8(%ebp),%eax
    1265:	89 04 24             	mov    %eax,(%esp)
    1268:	e8 bf fd ff ff       	call   102c <putc>
    126d:	eb 28                	jmp    1297 <printf+0x194>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
    126f:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
    1276:	00 
    1277:	8b 45 08             	mov    0x8(%ebp),%eax
    127a:	89 04 24             	mov    %eax,(%esp)
    127d:	e8 aa fd ff ff       	call   102c <putc>
        putc(fd, c);
    1282:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    1285:	0f be c0             	movsbl %al,%eax
    1288:	89 44 24 04          	mov    %eax,0x4(%esp)
    128c:	8b 45 08             	mov    0x8(%ebp),%eax
    128f:	89 04 24             	mov    %eax,(%esp)
    1292:	e8 95 fd ff ff       	call   102c <putc>
      }
      state = 0;
    1297:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    129e:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
    12a2:	8b 55 0c             	mov    0xc(%ebp),%edx
    12a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
    12a8:	01 d0                	add    %edx,%eax
    12aa:	0f b6 00             	movzbl (%eax),%eax
    12ad:	84 c0                	test   %al,%al
    12af:	0f 85 70 fe ff ff    	jne    1125 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
    12b5:	c9                   	leave  
    12b6:	c3                   	ret    
    12b7:	90                   	nop

000012b8 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    12b8:	55                   	push   %ebp
    12b9:	89 e5                	mov    %esp,%ebp
    12bb:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
    12be:	8b 45 08             	mov    0x8(%ebp),%eax
    12c1:	83 e8 08             	sub    $0x8,%eax
    12c4:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    12c7:	a1 cc 1a 00 00       	mov    0x1acc,%eax
    12cc:	89 45 fc             	mov    %eax,-0x4(%ebp)
    12cf:	eb 24                	jmp    12f5 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    12d1:	8b 45 fc             	mov    -0x4(%ebp),%eax
    12d4:	8b 00                	mov    (%eax),%eax
    12d6:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    12d9:	77 12                	ja     12ed <free+0x35>
    12db:	8b 45 f8             	mov    -0x8(%ebp),%eax
    12de:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    12e1:	77 24                	ja     1307 <free+0x4f>
    12e3:	8b 45 fc             	mov    -0x4(%ebp),%eax
    12e6:	8b 00                	mov    (%eax),%eax
    12e8:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    12eb:	77 1a                	ja     1307 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    12ed:	8b 45 fc             	mov    -0x4(%ebp),%eax
    12f0:	8b 00                	mov    (%eax),%eax
    12f2:	89 45 fc             	mov    %eax,-0x4(%ebp)
    12f5:	8b 45 f8             	mov    -0x8(%ebp),%eax
    12f8:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    12fb:	76 d4                	jbe    12d1 <free+0x19>
    12fd:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1300:	8b 00                	mov    (%eax),%eax
    1302:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    1305:	76 ca                	jbe    12d1 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    1307:	8b 45 f8             	mov    -0x8(%ebp),%eax
    130a:	8b 40 04             	mov    0x4(%eax),%eax
    130d:	c1 e0 03             	shl    $0x3,%eax
    1310:	89 c2                	mov    %eax,%edx
    1312:	03 55 f8             	add    -0x8(%ebp),%edx
    1315:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1318:	8b 00                	mov    (%eax),%eax
    131a:	39 c2                	cmp    %eax,%edx
    131c:	75 24                	jne    1342 <free+0x8a>
    bp->s.size += p->s.ptr->s.size;
    131e:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1321:	8b 50 04             	mov    0x4(%eax),%edx
    1324:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1327:	8b 00                	mov    (%eax),%eax
    1329:	8b 40 04             	mov    0x4(%eax),%eax
    132c:	01 c2                	add    %eax,%edx
    132e:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1331:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
    1334:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1337:	8b 00                	mov    (%eax),%eax
    1339:	8b 10                	mov    (%eax),%edx
    133b:	8b 45 f8             	mov    -0x8(%ebp),%eax
    133e:	89 10                	mov    %edx,(%eax)
    1340:	eb 0a                	jmp    134c <free+0x94>
  } else
    bp->s.ptr = p->s.ptr;
    1342:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1345:	8b 10                	mov    (%eax),%edx
    1347:	8b 45 f8             	mov    -0x8(%ebp),%eax
    134a:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
    134c:	8b 45 fc             	mov    -0x4(%ebp),%eax
    134f:	8b 40 04             	mov    0x4(%eax),%eax
    1352:	c1 e0 03             	shl    $0x3,%eax
    1355:	03 45 fc             	add    -0x4(%ebp),%eax
    1358:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    135b:	75 20                	jne    137d <free+0xc5>
    p->s.size += bp->s.size;
    135d:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1360:	8b 50 04             	mov    0x4(%eax),%edx
    1363:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1366:	8b 40 04             	mov    0x4(%eax),%eax
    1369:	01 c2                	add    %eax,%edx
    136b:	8b 45 fc             	mov    -0x4(%ebp),%eax
    136e:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
    1371:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1374:	8b 10                	mov    (%eax),%edx
    1376:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1379:	89 10                	mov    %edx,(%eax)
    137b:	eb 08                	jmp    1385 <free+0xcd>
  } else
    p->s.ptr = bp;
    137d:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1380:	8b 55 f8             	mov    -0x8(%ebp),%edx
    1383:	89 10                	mov    %edx,(%eax)
  freep = p;
    1385:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1388:	a3 cc 1a 00 00       	mov    %eax,0x1acc
}
    138d:	c9                   	leave  
    138e:	c3                   	ret    

0000138f <morecore>:

static Header*
morecore(uint nu)
{
    138f:	55                   	push   %ebp
    1390:	89 e5                	mov    %esp,%ebp
    1392:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
    1395:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
    139c:	77 07                	ja     13a5 <morecore+0x16>
    nu = 4096;
    139e:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
    13a5:	8b 45 08             	mov    0x8(%ebp),%eax
    13a8:	c1 e0 03             	shl    $0x3,%eax
    13ab:	89 04 24             	mov    %eax,(%esp)
    13ae:	e8 61 fc ff ff       	call   1014 <sbrk>
    13b3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
    13b6:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
    13ba:	75 07                	jne    13c3 <morecore+0x34>
    return 0;
    13bc:	b8 00 00 00 00       	mov    $0x0,%eax
    13c1:	eb 22                	jmp    13e5 <morecore+0x56>
  hp = (Header*)p;
    13c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
    13c6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
    13c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
    13cc:	8b 55 08             	mov    0x8(%ebp),%edx
    13cf:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
    13d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
    13d5:	83 c0 08             	add    $0x8,%eax
    13d8:	89 04 24             	mov    %eax,(%esp)
    13db:	e8 d8 fe ff ff       	call   12b8 <free>
  return freep;
    13e0:	a1 cc 1a 00 00       	mov    0x1acc,%eax
}
    13e5:	c9                   	leave  
    13e6:	c3                   	ret    

000013e7 <malloc>:

void*
malloc(uint nbytes)
{
    13e7:	55                   	push   %ebp
    13e8:	89 e5                	mov    %esp,%ebp
    13ea:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    13ed:	8b 45 08             	mov    0x8(%ebp),%eax
    13f0:	83 c0 07             	add    $0x7,%eax
    13f3:	c1 e8 03             	shr    $0x3,%eax
    13f6:	83 c0 01             	add    $0x1,%eax
    13f9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
    13fc:	a1 cc 1a 00 00       	mov    0x1acc,%eax
    1401:	89 45 f0             	mov    %eax,-0x10(%ebp)
    1404:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    1408:	75 23                	jne    142d <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
    140a:	c7 45 f0 c4 1a 00 00 	movl   $0x1ac4,-0x10(%ebp)
    1411:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1414:	a3 cc 1a 00 00       	mov    %eax,0x1acc
    1419:	a1 cc 1a 00 00       	mov    0x1acc,%eax
    141e:	a3 c4 1a 00 00       	mov    %eax,0x1ac4
    base.s.size = 0;
    1423:	c7 05 c8 1a 00 00 00 	movl   $0x0,0x1ac8
    142a:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    142d:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1430:	8b 00                	mov    (%eax),%eax
    1432:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
    1435:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1438:	8b 40 04             	mov    0x4(%eax),%eax
    143b:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    143e:	72 4d                	jb     148d <malloc+0xa6>
      if(p->s.size == nunits)
    1440:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1443:	8b 40 04             	mov    0x4(%eax),%eax
    1446:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    1449:	75 0c                	jne    1457 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
    144b:	8b 45 f4             	mov    -0xc(%ebp),%eax
    144e:	8b 10                	mov    (%eax),%edx
    1450:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1453:	89 10                	mov    %edx,(%eax)
    1455:	eb 26                	jmp    147d <malloc+0x96>
      else {
        p->s.size -= nunits;
    1457:	8b 45 f4             	mov    -0xc(%ebp),%eax
    145a:	8b 40 04             	mov    0x4(%eax),%eax
    145d:	89 c2                	mov    %eax,%edx
    145f:	2b 55 ec             	sub    -0x14(%ebp),%edx
    1462:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1465:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
    1468:	8b 45 f4             	mov    -0xc(%ebp),%eax
    146b:	8b 40 04             	mov    0x4(%eax),%eax
    146e:	c1 e0 03             	shl    $0x3,%eax
    1471:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
    1474:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1477:	8b 55 ec             	mov    -0x14(%ebp),%edx
    147a:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
    147d:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1480:	a3 cc 1a 00 00       	mov    %eax,0x1acc
      return (void*)(p + 1);
    1485:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1488:	83 c0 08             	add    $0x8,%eax
    148b:	eb 38                	jmp    14c5 <malloc+0xde>
    }
    if(p == freep)
    148d:	a1 cc 1a 00 00       	mov    0x1acc,%eax
    1492:	39 45 f4             	cmp    %eax,-0xc(%ebp)
    1495:	75 1b                	jne    14b2 <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
    1497:	8b 45 ec             	mov    -0x14(%ebp),%eax
    149a:	89 04 24             	mov    %eax,(%esp)
    149d:	e8 ed fe ff ff       	call   138f <morecore>
    14a2:	89 45 f4             	mov    %eax,-0xc(%ebp)
    14a5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    14a9:	75 07                	jne    14b2 <malloc+0xcb>
        return 0;
    14ab:	b8 00 00 00 00       	mov    $0x0,%eax
    14b0:	eb 13                	jmp    14c5 <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    14b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
    14b5:	89 45 f0             	mov    %eax,-0x10(%ebp)
    14b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
    14bb:	8b 00                	mov    (%eax),%eax
    14bd:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
    14c0:	e9 70 ff ff ff       	jmp    1435 <malloc+0x4e>
}
    14c5:	c9                   	leave  
    14c6:	c3                   	ret    
