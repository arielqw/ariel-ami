
_usertests:     file format elf32-i386


Disassembly of section .text:

00000000 <iputtest>:
int stdout = 1;

// does chdir() call iput(p->cwd) in a transaction?
void
iputtest(void)
{
       0:	55                   	push   %ebp
       1:	89 e5                	mov    %esp,%ebp
       3:	83 ec 18             	sub    $0x18,%esp
  printf(stdout, "iput test\n");
       6:	a1 68 68 00 00       	mov    0x6868,%eax
       b:	c7 44 24 04 be 49 00 	movl   $0x49be,0x4(%esp)
      12:	00 
      13:	89 04 24             	mov    %eax,(%esp)
      16:	e8 c8 45 00 00       	call   45e3 <printf>

  if(mkdir("iputdir") < 0){
      1b:	c7 04 24 c9 49 00 00 	movl   $0x49c9,(%esp)
      22:	e8 9d 44 00 00       	call   44c4 <mkdir>
      27:	85 c0                	test   %eax,%eax
      29:	79 21                	jns    4c <iputtest+0x4c>
    printf(stdout, "mkdir failed\n");
      2b:	a1 68 68 00 00       	mov    0x6868,%eax
      30:	c7 44 24 04 d1 49 00 	movl   $0x49d1,0x4(%esp)
      37:	00 
      38:	89 04 24             	mov    %eax,(%esp)
      3b:	e8 a3 45 00 00       	call   45e3 <printf>
    exit(EXIT_STATUS_DEFAULT);
      40:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
      47:	e8 10 44 00 00       	call   445c <exit>
  }
  if(chdir("iputdir") < 0){
      4c:	c7 04 24 c9 49 00 00 	movl   $0x49c9,(%esp)
      53:	e8 74 44 00 00       	call   44cc <chdir>
      58:	85 c0                	test   %eax,%eax
      5a:	79 21                	jns    7d <iputtest+0x7d>
    printf(stdout, "chdir iputdir failed\n");
      5c:	a1 68 68 00 00       	mov    0x6868,%eax
      61:	c7 44 24 04 df 49 00 	movl   $0x49df,0x4(%esp)
      68:	00 
      69:	89 04 24             	mov    %eax,(%esp)
      6c:	e8 72 45 00 00       	call   45e3 <printf>
    exit(EXIT_STATUS_DEFAULT);
      71:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
      78:	e8 df 43 00 00       	call   445c <exit>
  }
  if(unlink("../iputdir") < 0){
      7d:	c7 04 24 f5 49 00 00 	movl   $0x49f5,(%esp)
      84:	e8 23 44 00 00       	call   44ac <unlink>
      89:	85 c0                	test   %eax,%eax
      8b:	79 21                	jns    ae <iputtest+0xae>
    printf(stdout, "unlink ../iputdir failed\n");
      8d:	a1 68 68 00 00       	mov    0x6868,%eax
      92:	c7 44 24 04 00 4a 00 	movl   $0x4a00,0x4(%esp)
      99:	00 
      9a:	89 04 24             	mov    %eax,(%esp)
      9d:	e8 41 45 00 00       	call   45e3 <printf>
    exit(EXIT_STATUS_DEFAULT);
      a2:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
      a9:	e8 ae 43 00 00       	call   445c <exit>
  }
  if(chdir("/") < 0){
      ae:	c7 04 24 1a 4a 00 00 	movl   $0x4a1a,(%esp)
      b5:	e8 12 44 00 00       	call   44cc <chdir>
      ba:	85 c0                	test   %eax,%eax
      bc:	79 21                	jns    df <iputtest+0xdf>
    printf(stdout, "chdir / failed\n");
      be:	a1 68 68 00 00       	mov    0x6868,%eax
      c3:	c7 44 24 04 1c 4a 00 	movl   $0x4a1c,0x4(%esp)
      ca:	00 
      cb:	89 04 24             	mov    %eax,(%esp)
      ce:	e8 10 45 00 00       	call   45e3 <printf>
    exit(EXIT_STATUS_DEFAULT);
      d3:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
      da:	e8 7d 43 00 00       	call   445c <exit>
  }
  printf(stdout, "iput test ok\n");
      df:	a1 68 68 00 00       	mov    0x6868,%eax
      e4:	c7 44 24 04 2c 4a 00 	movl   $0x4a2c,0x4(%esp)
      eb:	00 
      ec:	89 04 24             	mov    %eax,(%esp)
      ef:	e8 ef 44 00 00       	call   45e3 <printf>
}
      f4:	c9                   	leave  
      f5:	c3                   	ret    

000000f6 <exitiputtest>:

// does exit(EXIT_STATUS_DEFAULT) call iput(p->cwd) in a transaction?
void
exitiputtest(void)
{
      f6:	55                   	push   %ebp
      f7:	89 e5                	mov    %esp,%ebp
      f9:	83 ec 28             	sub    $0x28,%esp
  int pid;

  printf(stdout, "exitiput test\n");
      fc:	a1 68 68 00 00       	mov    0x6868,%eax
     101:	c7 44 24 04 3a 4a 00 	movl   $0x4a3a,0x4(%esp)
     108:	00 
     109:	89 04 24             	mov    %eax,(%esp)
     10c:	e8 d2 44 00 00       	call   45e3 <printf>

  pid = fork();
     111:	e8 3e 43 00 00       	call   4454 <fork>
     116:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pid < 0){
     119:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
     11d:	79 21                	jns    140 <exitiputtest+0x4a>
    printf(stdout, "fork failed\n");
     11f:	a1 68 68 00 00       	mov    0x6868,%eax
     124:	c7 44 24 04 49 4a 00 	movl   $0x4a49,0x4(%esp)
     12b:	00 
     12c:	89 04 24             	mov    %eax,(%esp)
     12f:	e8 af 44 00 00       	call   45e3 <printf>
    exit(EXIT_STATUS_DEFAULT);
     134:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     13b:	e8 1c 43 00 00       	call   445c <exit>
  }
  if(pid == 0){
     140:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
     144:	0f 85 9f 00 00 00    	jne    1e9 <exitiputtest+0xf3>
    if(mkdir("iputdir") < 0){
     14a:	c7 04 24 c9 49 00 00 	movl   $0x49c9,(%esp)
     151:	e8 6e 43 00 00       	call   44c4 <mkdir>
     156:	85 c0                	test   %eax,%eax
     158:	79 21                	jns    17b <exitiputtest+0x85>
      printf(stdout, "mkdir failed\n");
     15a:	a1 68 68 00 00       	mov    0x6868,%eax
     15f:	c7 44 24 04 d1 49 00 	movl   $0x49d1,0x4(%esp)
     166:	00 
     167:	89 04 24             	mov    %eax,(%esp)
     16a:	e8 74 44 00 00       	call   45e3 <printf>
      exit(EXIT_STATUS_DEFAULT);
     16f:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     176:	e8 e1 42 00 00       	call   445c <exit>
    }
    if(chdir("iputdir") < 0){
     17b:	c7 04 24 c9 49 00 00 	movl   $0x49c9,(%esp)
     182:	e8 45 43 00 00       	call   44cc <chdir>
     187:	85 c0                	test   %eax,%eax
     189:	79 21                	jns    1ac <exitiputtest+0xb6>
      printf(stdout, "child chdir failed\n");
     18b:	a1 68 68 00 00       	mov    0x6868,%eax
     190:	c7 44 24 04 56 4a 00 	movl   $0x4a56,0x4(%esp)
     197:	00 
     198:	89 04 24             	mov    %eax,(%esp)
     19b:	e8 43 44 00 00       	call   45e3 <printf>
      exit(EXIT_STATUS_DEFAULT);
     1a0:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     1a7:	e8 b0 42 00 00       	call   445c <exit>
    }
    if(unlink("../iputdir") < 0){
     1ac:	c7 04 24 f5 49 00 00 	movl   $0x49f5,(%esp)
     1b3:	e8 f4 42 00 00       	call   44ac <unlink>
     1b8:	85 c0                	test   %eax,%eax
     1ba:	79 21                	jns    1dd <exitiputtest+0xe7>
      printf(stdout, "unlink ../iputdir failed\n");
     1bc:	a1 68 68 00 00       	mov    0x6868,%eax
     1c1:	c7 44 24 04 00 4a 00 	movl   $0x4a00,0x4(%esp)
     1c8:	00 
     1c9:	89 04 24             	mov    %eax,(%esp)
     1cc:	e8 12 44 00 00       	call   45e3 <printf>
      exit(EXIT_STATUS_DEFAULT);
     1d1:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     1d8:	e8 7f 42 00 00       	call   445c <exit>
    }
    exit(EXIT_STATUS_DEFAULT);
     1dd:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     1e4:	e8 73 42 00 00       	call   445c <exit>
  }
  wait(0);
     1e9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
     1f0:	e8 6f 42 00 00       	call   4464 <wait>
  printf(stdout, "exitiput test ok\n");
     1f5:	a1 68 68 00 00       	mov    0x6868,%eax
     1fa:	c7 44 24 04 6a 4a 00 	movl   $0x4a6a,0x4(%esp)
     201:	00 
     202:	89 04 24             	mov    %eax,(%esp)
     205:	e8 d9 43 00 00       	call   45e3 <printf>
}
     20a:	c9                   	leave  
     20b:	c3                   	ret    

0000020c <openiputtest>:
//      for(i = 0; i < 10000; i++)
//        yield();
//    }
void
openiputtest(void)
{
     20c:	55                   	push   %ebp
     20d:	89 e5                	mov    %esp,%ebp
     20f:	83 ec 28             	sub    $0x28,%esp
  int pid;

  printf(stdout, "openiput test\n");
     212:	a1 68 68 00 00       	mov    0x6868,%eax
     217:	c7 44 24 04 7c 4a 00 	movl   $0x4a7c,0x4(%esp)
     21e:	00 
     21f:	89 04 24             	mov    %eax,(%esp)
     222:	e8 bc 43 00 00       	call   45e3 <printf>
  if(mkdir("oidir") < 0){
     227:	c7 04 24 8b 4a 00 00 	movl   $0x4a8b,(%esp)
     22e:	e8 91 42 00 00       	call   44c4 <mkdir>
     233:	85 c0                	test   %eax,%eax
     235:	79 21                	jns    258 <openiputtest+0x4c>
    printf(stdout, "mkdir oidir failed\n");
     237:	a1 68 68 00 00       	mov    0x6868,%eax
     23c:	c7 44 24 04 91 4a 00 	movl   $0x4a91,0x4(%esp)
     243:	00 
     244:	89 04 24             	mov    %eax,(%esp)
     247:	e8 97 43 00 00       	call   45e3 <printf>
    exit(EXIT_STATUS_DEFAULT);
     24c:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     253:	e8 04 42 00 00       	call   445c <exit>
  }
  pid = fork();
     258:	e8 f7 41 00 00       	call   4454 <fork>
     25d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pid < 0){
     260:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
     264:	79 21                	jns    287 <openiputtest+0x7b>
    printf(stdout, "fork failed\n");
     266:	a1 68 68 00 00       	mov    0x6868,%eax
     26b:	c7 44 24 04 49 4a 00 	movl   $0x4a49,0x4(%esp)
     272:	00 
     273:	89 04 24             	mov    %eax,(%esp)
     276:	e8 68 43 00 00       	call   45e3 <printf>
    exit(EXIT_STATUS_DEFAULT);
     27b:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     282:	e8 d5 41 00 00       	call   445c <exit>
  }
  if(pid == 0){
     287:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
     28b:	75 4a                	jne    2d7 <openiputtest+0xcb>
    int fd = open("oidir", O_RDWR);
     28d:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
     294:	00 
     295:	c7 04 24 8b 4a 00 00 	movl   $0x4a8b,(%esp)
     29c:	e8 fb 41 00 00       	call   449c <open>
     2a1:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(fd >= 0){
     2a4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
     2a8:	78 21                	js     2cb <openiputtest+0xbf>
      printf(stdout, "open directory for write succeeded\n");
     2aa:	a1 68 68 00 00       	mov    0x6868,%eax
     2af:	c7 44 24 04 a8 4a 00 	movl   $0x4aa8,0x4(%esp)
     2b6:	00 
     2b7:	89 04 24             	mov    %eax,(%esp)
     2ba:	e8 24 43 00 00       	call   45e3 <printf>
      exit(EXIT_STATUS_DEFAULT);
     2bf:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     2c6:	e8 91 41 00 00       	call   445c <exit>
    }
    exit(EXIT_STATUS_DEFAULT);
     2cb:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     2d2:	e8 85 41 00 00       	call   445c <exit>
  }
  sleep(1);
     2d7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     2de:	e8 09 42 00 00       	call   44ec <sleep>
  if(unlink("oidir") != 0){
     2e3:	c7 04 24 8b 4a 00 00 	movl   $0x4a8b,(%esp)
     2ea:	e8 bd 41 00 00       	call   44ac <unlink>
     2ef:	85 c0                	test   %eax,%eax
     2f1:	74 21                	je     314 <openiputtest+0x108>
    printf(stdout, "unlink failed\n");
     2f3:	a1 68 68 00 00       	mov    0x6868,%eax
     2f8:	c7 44 24 04 cc 4a 00 	movl   $0x4acc,0x4(%esp)
     2ff:	00 
     300:	89 04 24             	mov    %eax,(%esp)
     303:	e8 db 42 00 00       	call   45e3 <printf>
    exit(EXIT_STATUS_DEFAULT);
     308:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     30f:	e8 48 41 00 00       	call   445c <exit>
  }
  wait(0);
     314:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
     31b:	e8 44 41 00 00       	call   4464 <wait>
  printf(stdout, "openiput test ok\n");
     320:	a1 68 68 00 00       	mov    0x6868,%eax
     325:	c7 44 24 04 db 4a 00 	movl   $0x4adb,0x4(%esp)
     32c:	00 
     32d:	89 04 24             	mov    %eax,(%esp)
     330:	e8 ae 42 00 00       	call   45e3 <printf>
}
     335:	c9                   	leave  
     336:	c3                   	ret    

00000337 <opentest>:

// simple file system tests

void
opentest(void)
{
     337:	55                   	push   %ebp
     338:	89 e5                	mov    %esp,%ebp
     33a:	83 ec 28             	sub    $0x28,%esp
  int fd;

  printf(stdout, "open test\n");
     33d:	a1 68 68 00 00       	mov    0x6868,%eax
     342:	c7 44 24 04 ed 4a 00 	movl   $0x4aed,0x4(%esp)
     349:	00 
     34a:	89 04 24             	mov    %eax,(%esp)
     34d:	e8 91 42 00 00       	call   45e3 <printf>
  fd = open("echo", 0);
     352:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     359:	00 
     35a:	c7 04 24 a8 49 00 00 	movl   $0x49a8,(%esp)
     361:	e8 36 41 00 00       	call   449c <open>
     366:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0){
     369:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
     36d:	79 21                	jns    390 <opentest+0x59>
    printf(stdout, "open echo failed!\n");
     36f:	a1 68 68 00 00       	mov    0x6868,%eax
     374:	c7 44 24 04 f8 4a 00 	movl   $0x4af8,0x4(%esp)
     37b:	00 
     37c:	89 04 24             	mov    %eax,(%esp)
     37f:	e8 5f 42 00 00       	call   45e3 <printf>
    exit(EXIT_STATUS_DEFAULT);
     384:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     38b:	e8 cc 40 00 00       	call   445c <exit>
  }
  close(fd);
     390:	8b 45 f4             	mov    -0xc(%ebp),%eax
     393:	89 04 24             	mov    %eax,(%esp)
     396:	e8 e9 40 00 00       	call   4484 <close>
  fd = open("doesnotexist", 0);
     39b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     3a2:	00 
     3a3:	c7 04 24 0b 4b 00 00 	movl   $0x4b0b,(%esp)
     3aa:	e8 ed 40 00 00       	call   449c <open>
     3af:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd >= 0){
     3b2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
     3b6:	78 21                	js     3d9 <opentest+0xa2>
    printf(stdout, "open doesnotexist succeeded!\n");
     3b8:	a1 68 68 00 00       	mov    0x6868,%eax
     3bd:	c7 44 24 04 18 4b 00 	movl   $0x4b18,0x4(%esp)
     3c4:	00 
     3c5:	89 04 24             	mov    %eax,(%esp)
     3c8:	e8 16 42 00 00       	call   45e3 <printf>
    exit(EXIT_STATUS_DEFAULT);
     3cd:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     3d4:	e8 83 40 00 00       	call   445c <exit>
  }
  printf(stdout, "open test ok\n");
     3d9:	a1 68 68 00 00       	mov    0x6868,%eax
     3de:	c7 44 24 04 36 4b 00 	movl   $0x4b36,0x4(%esp)
     3e5:	00 
     3e6:	89 04 24             	mov    %eax,(%esp)
     3e9:	e8 f5 41 00 00       	call   45e3 <printf>
}
     3ee:	c9                   	leave  
     3ef:	c3                   	ret    

000003f0 <writetest>:

void
writetest(void)
{
     3f0:	55                   	push   %ebp
     3f1:	89 e5                	mov    %esp,%ebp
     3f3:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int i;

  printf(stdout, "small file test\n");
     3f6:	a1 68 68 00 00       	mov    0x6868,%eax
     3fb:	c7 44 24 04 44 4b 00 	movl   $0x4b44,0x4(%esp)
     402:	00 
     403:	89 04 24             	mov    %eax,(%esp)
     406:	e8 d8 41 00 00       	call   45e3 <printf>
  fd = open("small", O_CREATE|O_RDWR);
     40b:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
     412:	00 
     413:	c7 04 24 55 4b 00 00 	movl   $0x4b55,(%esp)
     41a:	e8 7d 40 00 00       	call   449c <open>
     41f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(fd >= 0){
     422:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
     426:	78 21                	js     449 <writetest+0x59>
    printf(stdout, "creat small succeeded; ok\n");
     428:	a1 68 68 00 00       	mov    0x6868,%eax
     42d:	c7 44 24 04 5b 4b 00 	movl   $0x4b5b,0x4(%esp)
     434:	00 
     435:	89 04 24             	mov    %eax,(%esp)
     438:	e8 a6 41 00 00       	call   45e3 <printf>
  } else {
    printf(stdout, "error: creat small failed!\n");
    exit(EXIT_STATUS_DEFAULT);
  }
  for(i = 0; i < 100; i++){
     43d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     444:	e9 b5 00 00 00       	jmp    4fe <writetest+0x10e>
  printf(stdout, "small file test\n");
  fd = open("small", O_CREATE|O_RDWR);
  if(fd >= 0){
    printf(stdout, "creat small succeeded; ok\n");
  } else {
    printf(stdout, "error: creat small failed!\n");
     449:	a1 68 68 00 00       	mov    0x6868,%eax
     44e:	c7 44 24 04 76 4b 00 	movl   $0x4b76,0x4(%esp)
     455:	00 
     456:	89 04 24             	mov    %eax,(%esp)
     459:	e8 85 41 00 00       	call   45e3 <printf>
    exit(EXIT_STATUS_DEFAULT);
     45e:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     465:	e8 f2 3f 00 00       	call   445c <exit>
  }
  for(i = 0; i < 100; i++){
    if(write(fd, "aaaaaaaaaa", 10) != 10){
     46a:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
     471:	00 
     472:	c7 44 24 04 92 4b 00 	movl   $0x4b92,0x4(%esp)
     479:	00 
     47a:	8b 45 f0             	mov    -0x10(%ebp),%eax
     47d:	89 04 24             	mov    %eax,(%esp)
     480:	e8 f7 3f 00 00       	call   447c <write>
     485:	83 f8 0a             	cmp    $0xa,%eax
     488:	74 28                	je     4b2 <writetest+0xc2>
      printf(stdout, "error: write aa %d new file failed\n", i);
     48a:	a1 68 68 00 00       	mov    0x6868,%eax
     48f:	8b 55 f4             	mov    -0xc(%ebp),%edx
     492:	89 54 24 08          	mov    %edx,0x8(%esp)
     496:	c7 44 24 04 a0 4b 00 	movl   $0x4ba0,0x4(%esp)
     49d:	00 
     49e:	89 04 24             	mov    %eax,(%esp)
     4a1:	e8 3d 41 00 00       	call   45e3 <printf>
      exit(EXIT_STATUS_DEFAULT);
     4a6:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     4ad:	e8 aa 3f 00 00       	call   445c <exit>
    }
    if(write(fd, "bbbbbbbbbb", 10) != 10){
     4b2:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
     4b9:	00 
     4ba:	c7 44 24 04 c4 4b 00 	movl   $0x4bc4,0x4(%esp)
     4c1:	00 
     4c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
     4c5:	89 04 24             	mov    %eax,(%esp)
     4c8:	e8 af 3f 00 00       	call   447c <write>
     4cd:	83 f8 0a             	cmp    $0xa,%eax
     4d0:	74 28                	je     4fa <writetest+0x10a>
      printf(stdout, "error: write bb %d new file failed\n", i);
     4d2:	a1 68 68 00 00       	mov    0x6868,%eax
     4d7:	8b 55 f4             	mov    -0xc(%ebp),%edx
     4da:	89 54 24 08          	mov    %edx,0x8(%esp)
     4de:	c7 44 24 04 d0 4b 00 	movl   $0x4bd0,0x4(%esp)
     4e5:	00 
     4e6:	89 04 24             	mov    %eax,(%esp)
     4e9:	e8 f5 40 00 00       	call   45e3 <printf>
      exit(EXIT_STATUS_DEFAULT);
     4ee:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     4f5:	e8 62 3f 00 00       	call   445c <exit>
    printf(stdout, "creat small succeeded; ok\n");
  } else {
    printf(stdout, "error: creat small failed!\n");
    exit(EXIT_STATUS_DEFAULT);
  }
  for(i = 0; i < 100; i++){
     4fa:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
     4fe:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
     502:	0f 8e 62 ff ff ff    	jle    46a <writetest+0x7a>
    if(write(fd, "bbbbbbbbbb", 10) != 10){
      printf(stdout, "error: write bb %d new file failed\n", i);
      exit(EXIT_STATUS_DEFAULT);
    }
  }
  printf(stdout, "writes ok\n");
     508:	a1 68 68 00 00       	mov    0x6868,%eax
     50d:	c7 44 24 04 f4 4b 00 	movl   $0x4bf4,0x4(%esp)
     514:	00 
     515:	89 04 24             	mov    %eax,(%esp)
     518:	e8 c6 40 00 00       	call   45e3 <printf>
  close(fd);
     51d:	8b 45 f0             	mov    -0x10(%ebp),%eax
     520:	89 04 24             	mov    %eax,(%esp)
     523:	e8 5c 3f 00 00       	call   4484 <close>
  fd = open("small", O_RDONLY);
     528:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     52f:	00 
     530:	c7 04 24 55 4b 00 00 	movl   $0x4b55,(%esp)
     537:	e8 60 3f 00 00       	call   449c <open>
     53c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(fd >= 0){
     53f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
     543:	78 3e                	js     583 <writetest+0x193>
    printf(stdout, "open small succeeded ok\n");
     545:	a1 68 68 00 00       	mov    0x6868,%eax
     54a:	c7 44 24 04 ff 4b 00 	movl   $0x4bff,0x4(%esp)
     551:	00 
     552:	89 04 24             	mov    %eax,(%esp)
     555:	e8 89 40 00 00       	call   45e3 <printf>
  } else {
    printf(stdout, "error: open small failed!\n");
    exit(EXIT_STATUS_DEFAULT);
  }
  i = read(fd, buf, 2000);
     55a:	c7 44 24 08 d0 07 00 	movl   $0x7d0,0x8(%esp)
     561:	00 
     562:	c7 44 24 04 60 90 00 	movl   $0x9060,0x4(%esp)
     569:	00 
     56a:	8b 45 f0             	mov    -0x10(%ebp),%eax
     56d:	89 04 24             	mov    %eax,(%esp)
     570:	e8 ff 3e 00 00       	call   4474 <read>
     575:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(i == 2000){
     578:	81 7d f4 d0 07 00 00 	cmpl   $0x7d0,-0xc(%ebp)
     57f:	74 23                	je     5a4 <writetest+0x1b4>
     581:	eb 53                	jmp    5d6 <writetest+0x1e6>
  close(fd);
  fd = open("small", O_RDONLY);
  if(fd >= 0){
    printf(stdout, "open small succeeded ok\n");
  } else {
    printf(stdout, "error: open small failed!\n");
     583:	a1 68 68 00 00       	mov    0x6868,%eax
     588:	c7 44 24 04 18 4c 00 	movl   $0x4c18,0x4(%esp)
     58f:	00 
     590:	89 04 24             	mov    %eax,(%esp)
     593:	e8 4b 40 00 00       	call   45e3 <printf>
    exit(EXIT_STATUS_DEFAULT);
     598:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     59f:	e8 b8 3e 00 00       	call   445c <exit>
  }
  i = read(fd, buf, 2000);
  if(i == 2000){
    printf(stdout, "read succeeded ok\n");
     5a4:	a1 68 68 00 00       	mov    0x6868,%eax
     5a9:	c7 44 24 04 33 4c 00 	movl   $0x4c33,0x4(%esp)
     5b0:	00 
     5b1:	89 04 24             	mov    %eax,(%esp)
     5b4:	e8 2a 40 00 00       	call   45e3 <printf>
  } else {
    printf(stdout, "read failed\n");
    exit(EXIT_STATUS_DEFAULT);
  }
  close(fd);
     5b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
     5bc:	89 04 24             	mov    %eax,(%esp)
     5bf:	e8 c0 3e 00 00       	call   4484 <close>

  if(unlink("small") < 0){
     5c4:	c7 04 24 55 4b 00 00 	movl   $0x4b55,(%esp)
     5cb:	e8 dc 3e 00 00       	call   44ac <unlink>
     5d0:	85 c0                	test   %eax,%eax
     5d2:	78 23                	js     5f7 <writetest+0x207>
     5d4:	eb 42                	jmp    618 <writetest+0x228>
  }
  i = read(fd, buf, 2000);
  if(i == 2000){
    printf(stdout, "read succeeded ok\n");
  } else {
    printf(stdout, "read failed\n");
     5d6:	a1 68 68 00 00       	mov    0x6868,%eax
     5db:	c7 44 24 04 46 4c 00 	movl   $0x4c46,0x4(%esp)
     5e2:	00 
     5e3:	89 04 24             	mov    %eax,(%esp)
     5e6:	e8 f8 3f 00 00       	call   45e3 <printf>
    exit(EXIT_STATUS_DEFAULT);
     5eb:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     5f2:	e8 65 3e 00 00       	call   445c <exit>
  }
  close(fd);

  if(unlink("small") < 0){
    printf(stdout, "unlink small failed\n");
     5f7:	a1 68 68 00 00       	mov    0x6868,%eax
     5fc:	c7 44 24 04 53 4c 00 	movl   $0x4c53,0x4(%esp)
     603:	00 
     604:	89 04 24             	mov    %eax,(%esp)
     607:	e8 d7 3f 00 00       	call   45e3 <printf>
    exit(EXIT_STATUS_DEFAULT);
     60c:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     613:	e8 44 3e 00 00       	call   445c <exit>
  }
  printf(stdout, "small file test ok\n");
     618:	a1 68 68 00 00       	mov    0x6868,%eax
     61d:	c7 44 24 04 68 4c 00 	movl   $0x4c68,0x4(%esp)
     624:	00 
     625:	89 04 24             	mov    %eax,(%esp)
     628:	e8 b6 3f 00 00       	call   45e3 <printf>
}
     62d:	c9                   	leave  
     62e:	c3                   	ret    

0000062f <writetest1>:

void
writetest1(void)
{
     62f:	55                   	push   %ebp
     630:	89 e5                	mov    %esp,%ebp
     632:	83 ec 28             	sub    $0x28,%esp
  int i, fd, n;

  printf(stdout, "big files test\n");
     635:	a1 68 68 00 00       	mov    0x6868,%eax
     63a:	c7 44 24 04 7c 4c 00 	movl   $0x4c7c,0x4(%esp)
     641:	00 
     642:	89 04 24             	mov    %eax,(%esp)
     645:	e8 99 3f 00 00       	call   45e3 <printf>

  fd = open("big", O_CREATE|O_RDWR);
     64a:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
     651:	00 
     652:	c7 04 24 8c 4c 00 00 	movl   $0x4c8c,(%esp)
     659:	e8 3e 3e 00 00       	call   449c <open>
     65e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(fd < 0){
     661:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
     665:	79 21                	jns    688 <writetest1+0x59>
    printf(stdout, "error: creat big failed!\n");
     667:	a1 68 68 00 00       	mov    0x6868,%eax
     66c:	c7 44 24 04 90 4c 00 	movl   $0x4c90,0x4(%esp)
     673:	00 
     674:	89 04 24             	mov    %eax,(%esp)
     677:	e8 67 3f 00 00       	call   45e3 <printf>
    exit(EXIT_STATUS_DEFAULT);
     67c:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     683:	e8 d4 3d 00 00       	call   445c <exit>
  }

  for(i = 0; i < MAXFILE; i++){
     688:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     68f:	eb 58                	jmp    6e9 <writetest1+0xba>
    ((int*)buf)[0] = i;
     691:	b8 60 90 00 00       	mov    $0x9060,%eax
     696:	8b 55 f4             	mov    -0xc(%ebp),%edx
     699:	89 10                	mov    %edx,(%eax)
    if(write(fd, buf, 512) != 512){
     69b:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
     6a2:	00 
     6a3:	c7 44 24 04 60 90 00 	movl   $0x9060,0x4(%esp)
     6aa:	00 
     6ab:	8b 45 ec             	mov    -0x14(%ebp),%eax
     6ae:	89 04 24             	mov    %eax,(%esp)
     6b1:	e8 c6 3d 00 00       	call   447c <write>
     6b6:	3d 00 02 00 00       	cmp    $0x200,%eax
     6bb:	74 28                	je     6e5 <writetest1+0xb6>
      printf(stdout, "error: write big file failed\n", i);
     6bd:	a1 68 68 00 00       	mov    0x6868,%eax
     6c2:	8b 55 f4             	mov    -0xc(%ebp),%edx
     6c5:	89 54 24 08          	mov    %edx,0x8(%esp)
     6c9:	c7 44 24 04 aa 4c 00 	movl   $0x4caa,0x4(%esp)
     6d0:	00 
     6d1:	89 04 24             	mov    %eax,(%esp)
     6d4:	e8 0a 3f 00 00       	call   45e3 <printf>
      exit(EXIT_STATUS_DEFAULT);
     6d9:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     6e0:	e8 77 3d 00 00       	call   445c <exit>
  if(fd < 0){
    printf(stdout, "error: creat big failed!\n");
    exit(EXIT_STATUS_DEFAULT);
  }

  for(i = 0; i < MAXFILE; i++){
     6e5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
     6e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
     6ec:	3d 8b 00 00 00       	cmp    $0x8b,%eax
     6f1:	76 9e                	jbe    691 <writetest1+0x62>
      printf(stdout, "error: write big file failed\n", i);
      exit(EXIT_STATUS_DEFAULT);
    }
  }

  close(fd);
     6f3:	8b 45 ec             	mov    -0x14(%ebp),%eax
     6f6:	89 04 24             	mov    %eax,(%esp)
     6f9:	e8 86 3d 00 00       	call   4484 <close>

  fd = open("big", O_RDONLY);
     6fe:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     705:	00 
     706:	c7 04 24 8c 4c 00 00 	movl   $0x4c8c,(%esp)
     70d:	e8 8a 3d 00 00       	call   449c <open>
     712:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(fd < 0){
     715:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
     719:	79 21                	jns    73c <writetest1+0x10d>
    printf(stdout, "error: open big failed!\n");
     71b:	a1 68 68 00 00       	mov    0x6868,%eax
     720:	c7 44 24 04 c8 4c 00 	movl   $0x4cc8,0x4(%esp)
     727:	00 
     728:	89 04 24             	mov    %eax,(%esp)
     72b:	e8 b3 3e 00 00       	call   45e3 <printf>
    exit(EXIT_STATUS_DEFAULT);
     730:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     737:	e8 20 3d 00 00       	call   445c <exit>
  }

  n = 0;
     73c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(;;){
    i = read(fd, buf, 512);
     743:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
     74a:	00 
     74b:	c7 44 24 04 60 90 00 	movl   $0x9060,0x4(%esp)
     752:	00 
     753:	8b 45 ec             	mov    -0x14(%ebp),%eax
     756:	89 04 24             	mov    %eax,(%esp)
     759:	e8 16 3d 00 00       	call   4474 <read>
     75e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(i == 0){
     761:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
     765:	75 35                	jne    79c <writetest1+0x16d>
      if(n == MAXFILE - 1){
     767:	81 7d f0 8b 00 00 00 	cmpl   $0x8b,-0x10(%ebp)
     76e:	0f 85 a1 00 00 00    	jne    815 <writetest1+0x1e6>
        printf(stdout, "read only %d blocks from big", n);
     774:	a1 68 68 00 00       	mov    0x6868,%eax
     779:	8b 55 f0             	mov    -0x10(%ebp),%edx
     77c:	89 54 24 08          	mov    %edx,0x8(%esp)
     780:	c7 44 24 04 e1 4c 00 	movl   $0x4ce1,0x4(%esp)
     787:	00 
     788:	89 04 24             	mov    %eax,(%esp)
     78b:	e8 53 3e 00 00       	call   45e3 <printf>
        exit(EXIT_STATUS_DEFAULT);
     790:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     797:	e8 c0 3c 00 00       	call   445c <exit>
      }
      break;
    } else if(i != 512){
     79c:	81 7d f4 00 02 00 00 	cmpl   $0x200,-0xc(%ebp)
     7a3:	74 28                	je     7cd <writetest1+0x19e>
      printf(stdout, "read failed %d\n", i);
     7a5:	a1 68 68 00 00       	mov    0x6868,%eax
     7aa:	8b 55 f4             	mov    -0xc(%ebp),%edx
     7ad:	89 54 24 08          	mov    %edx,0x8(%esp)
     7b1:	c7 44 24 04 fe 4c 00 	movl   $0x4cfe,0x4(%esp)
     7b8:	00 
     7b9:	89 04 24             	mov    %eax,(%esp)
     7bc:	e8 22 3e 00 00       	call   45e3 <printf>
      exit(EXIT_STATUS_DEFAULT);
     7c1:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     7c8:	e8 8f 3c 00 00       	call   445c <exit>
    }
    if(((int*)buf)[0] != n){
     7cd:	b8 60 90 00 00       	mov    $0x9060,%eax
     7d2:	8b 00                	mov    (%eax),%eax
     7d4:	3b 45 f0             	cmp    -0x10(%ebp),%eax
     7d7:	74 33                	je     80c <writetest1+0x1dd>
      printf(stdout, "read content of block %d is %d\n",
             n, ((int*)buf)[0]);
     7d9:	b8 60 90 00 00       	mov    $0x9060,%eax
    } else if(i != 512){
      printf(stdout, "read failed %d\n", i);
      exit(EXIT_STATUS_DEFAULT);
    }
    if(((int*)buf)[0] != n){
      printf(stdout, "read content of block %d is %d\n",
     7de:	8b 10                	mov    (%eax),%edx
     7e0:	a1 68 68 00 00       	mov    0x6868,%eax
     7e5:	89 54 24 0c          	mov    %edx,0xc(%esp)
     7e9:	8b 55 f0             	mov    -0x10(%ebp),%edx
     7ec:	89 54 24 08          	mov    %edx,0x8(%esp)
     7f0:	c7 44 24 04 10 4d 00 	movl   $0x4d10,0x4(%esp)
     7f7:	00 
     7f8:	89 04 24             	mov    %eax,(%esp)
     7fb:	e8 e3 3d 00 00       	call   45e3 <printf>
             n, ((int*)buf)[0]);
      exit(EXIT_STATUS_DEFAULT);
     800:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     807:	e8 50 3c 00 00       	call   445c <exit>
    }
    n++;
     80c:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
  }
     810:	e9 2e ff ff ff       	jmp    743 <writetest1+0x114>
    if(i == 0){
      if(n == MAXFILE - 1){
        printf(stdout, "read only %d blocks from big", n);
        exit(EXIT_STATUS_DEFAULT);
      }
      break;
     815:	90                   	nop
             n, ((int*)buf)[0]);
      exit(EXIT_STATUS_DEFAULT);
    }
    n++;
  }
  close(fd);
     816:	8b 45 ec             	mov    -0x14(%ebp),%eax
     819:	89 04 24             	mov    %eax,(%esp)
     81c:	e8 63 3c 00 00       	call   4484 <close>
  if(unlink("big") < 0){
     821:	c7 04 24 8c 4c 00 00 	movl   $0x4c8c,(%esp)
     828:	e8 7f 3c 00 00       	call   44ac <unlink>
     82d:	85 c0                	test   %eax,%eax
     82f:	79 21                	jns    852 <writetest1+0x223>
    printf(stdout, "unlink big failed\n");
     831:	a1 68 68 00 00       	mov    0x6868,%eax
     836:	c7 44 24 04 30 4d 00 	movl   $0x4d30,0x4(%esp)
     83d:	00 
     83e:	89 04 24             	mov    %eax,(%esp)
     841:	e8 9d 3d 00 00       	call   45e3 <printf>
    exit(EXIT_STATUS_DEFAULT);
     846:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     84d:	e8 0a 3c 00 00       	call   445c <exit>
  }
  printf(stdout, "big files ok\n");
     852:	a1 68 68 00 00       	mov    0x6868,%eax
     857:	c7 44 24 04 43 4d 00 	movl   $0x4d43,0x4(%esp)
     85e:	00 
     85f:	89 04 24             	mov    %eax,(%esp)
     862:	e8 7c 3d 00 00       	call   45e3 <printf>
}
     867:	c9                   	leave  
     868:	c3                   	ret    

00000869 <createtest>:

void
createtest(void)
{
     869:	55                   	push   %ebp
     86a:	89 e5                	mov    %esp,%ebp
     86c:	83 ec 28             	sub    $0x28,%esp
  int i, fd;

  printf(stdout, "many creates, followed by unlink test\n");
     86f:	a1 68 68 00 00       	mov    0x6868,%eax
     874:	c7 44 24 04 54 4d 00 	movl   $0x4d54,0x4(%esp)
     87b:	00 
     87c:	89 04 24             	mov    %eax,(%esp)
     87f:	e8 5f 3d 00 00       	call   45e3 <printf>

  name[0] = 'a';
     884:	c6 05 60 b0 00 00 61 	movb   $0x61,0xb060
  name[2] = '\0';
     88b:	c6 05 62 b0 00 00 00 	movb   $0x0,0xb062
  for(i = 0; i < 52; i++){
     892:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     899:	eb 31                	jmp    8cc <createtest+0x63>
    name[1] = '0' + i;
     89b:	8b 45 f4             	mov    -0xc(%ebp),%eax
     89e:	83 c0 30             	add    $0x30,%eax
     8a1:	a2 61 b0 00 00       	mov    %al,0xb061
    fd = open(name, O_CREATE|O_RDWR);
     8a6:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
     8ad:	00 
     8ae:	c7 04 24 60 b0 00 00 	movl   $0xb060,(%esp)
     8b5:	e8 e2 3b 00 00       	call   449c <open>
     8ba:	89 45 f0             	mov    %eax,-0x10(%ebp)
    close(fd);
     8bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
     8c0:	89 04 24             	mov    %eax,(%esp)
     8c3:	e8 bc 3b 00 00       	call   4484 <close>

  printf(stdout, "many creates, followed by unlink test\n");

  name[0] = 'a';
  name[2] = '\0';
  for(i = 0; i < 52; i++){
     8c8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
     8cc:	83 7d f4 33          	cmpl   $0x33,-0xc(%ebp)
     8d0:	7e c9                	jle    89b <createtest+0x32>
    name[1] = '0' + i;
    fd = open(name, O_CREATE|O_RDWR);
    close(fd);
  }
  name[0] = 'a';
     8d2:	c6 05 60 b0 00 00 61 	movb   $0x61,0xb060
  name[2] = '\0';
     8d9:	c6 05 62 b0 00 00 00 	movb   $0x0,0xb062
  for(i = 0; i < 52; i++){
     8e0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     8e7:	eb 1b                	jmp    904 <createtest+0x9b>
    name[1] = '0' + i;
     8e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
     8ec:	83 c0 30             	add    $0x30,%eax
     8ef:	a2 61 b0 00 00       	mov    %al,0xb061
    unlink(name);
     8f4:	c7 04 24 60 b0 00 00 	movl   $0xb060,(%esp)
     8fb:	e8 ac 3b 00 00       	call   44ac <unlink>
    fd = open(name, O_CREATE|O_RDWR);
    close(fd);
  }
  name[0] = 'a';
  name[2] = '\0';
  for(i = 0; i < 52; i++){
     900:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
     904:	83 7d f4 33          	cmpl   $0x33,-0xc(%ebp)
     908:	7e df                	jle    8e9 <createtest+0x80>
    name[1] = '0' + i;
    unlink(name);
  }
  printf(stdout, "many creates, followed by unlink; ok\n");
     90a:	a1 68 68 00 00       	mov    0x6868,%eax
     90f:	c7 44 24 04 7c 4d 00 	movl   $0x4d7c,0x4(%esp)
     916:	00 
     917:	89 04 24             	mov    %eax,(%esp)
     91a:	e8 c4 3c 00 00       	call   45e3 <printf>
}
     91f:	c9                   	leave  
     920:	c3                   	ret    

00000921 <dirtest>:

void dirtest(void)
{
     921:	55                   	push   %ebp
     922:	89 e5                	mov    %esp,%ebp
     924:	83 ec 18             	sub    $0x18,%esp
  printf(stdout, "mkdir test\n");
     927:	a1 68 68 00 00       	mov    0x6868,%eax
     92c:	c7 44 24 04 a2 4d 00 	movl   $0x4da2,0x4(%esp)
     933:	00 
     934:	89 04 24             	mov    %eax,(%esp)
     937:	e8 a7 3c 00 00       	call   45e3 <printf>

  if(mkdir("dir0") < 0){
     93c:	c7 04 24 ae 4d 00 00 	movl   $0x4dae,(%esp)
     943:	e8 7c 3b 00 00       	call   44c4 <mkdir>
     948:	85 c0                	test   %eax,%eax
     94a:	79 21                	jns    96d <dirtest+0x4c>
    printf(stdout, "mkdir failed\n");
     94c:	a1 68 68 00 00       	mov    0x6868,%eax
     951:	c7 44 24 04 d1 49 00 	movl   $0x49d1,0x4(%esp)
     958:	00 
     959:	89 04 24             	mov    %eax,(%esp)
     95c:	e8 82 3c 00 00       	call   45e3 <printf>
    exit(EXIT_STATUS_DEFAULT);
     961:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     968:	e8 ef 3a 00 00       	call   445c <exit>
  }

  if(chdir("dir0") < 0){
     96d:	c7 04 24 ae 4d 00 00 	movl   $0x4dae,(%esp)
     974:	e8 53 3b 00 00       	call   44cc <chdir>
     979:	85 c0                	test   %eax,%eax
     97b:	79 21                	jns    99e <dirtest+0x7d>
    printf(stdout, "chdir dir0 failed\n");
     97d:	a1 68 68 00 00       	mov    0x6868,%eax
     982:	c7 44 24 04 b3 4d 00 	movl   $0x4db3,0x4(%esp)
     989:	00 
     98a:	89 04 24             	mov    %eax,(%esp)
     98d:	e8 51 3c 00 00       	call   45e3 <printf>
    exit(EXIT_STATUS_DEFAULT);
     992:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     999:	e8 be 3a 00 00       	call   445c <exit>
  }

  if(chdir("..") < 0){
     99e:	c7 04 24 c6 4d 00 00 	movl   $0x4dc6,(%esp)
     9a5:	e8 22 3b 00 00       	call   44cc <chdir>
     9aa:	85 c0                	test   %eax,%eax
     9ac:	79 21                	jns    9cf <dirtest+0xae>
    printf(stdout, "chdir .. failed\n");
     9ae:	a1 68 68 00 00       	mov    0x6868,%eax
     9b3:	c7 44 24 04 c9 4d 00 	movl   $0x4dc9,0x4(%esp)
     9ba:	00 
     9bb:	89 04 24             	mov    %eax,(%esp)
     9be:	e8 20 3c 00 00       	call   45e3 <printf>
    exit(EXIT_STATUS_DEFAULT);
     9c3:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     9ca:	e8 8d 3a 00 00       	call   445c <exit>
  }

  if(unlink("dir0") < 0){
     9cf:	c7 04 24 ae 4d 00 00 	movl   $0x4dae,(%esp)
     9d6:	e8 d1 3a 00 00       	call   44ac <unlink>
     9db:	85 c0                	test   %eax,%eax
     9dd:	79 21                	jns    a00 <dirtest+0xdf>
    printf(stdout, "unlink dir0 failed\n");
     9df:	a1 68 68 00 00       	mov    0x6868,%eax
     9e4:	c7 44 24 04 da 4d 00 	movl   $0x4dda,0x4(%esp)
     9eb:	00 
     9ec:	89 04 24             	mov    %eax,(%esp)
     9ef:	e8 ef 3b 00 00       	call   45e3 <printf>
    exit(EXIT_STATUS_DEFAULT);
     9f4:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     9fb:	e8 5c 3a 00 00       	call   445c <exit>
  }
  printf(stdout, "mkdir test ok\n");
     a00:	a1 68 68 00 00       	mov    0x6868,%eax
     a05:	c7 44 24 04 ee 4d 00 	movl   $0x4dee,0x4(%esp)
     a0c:	00 
     a0d:	89 04 24             	mov    %eax,(%esp)
     a10:	e8 ce 3b 00 00       	call   45e3 <printf>
}
     a15:	c9                   	leave  
     a16:	c3                   	ret    

00000a17 <exectest>:

void
exectest(void)
{
     a17:	55                   	push   %ebp
     a18:	89 e5                	mov    %esp,%ebp
     a1a:	83 ec 18             	sub    $0x18,%esp
  printf(stdout, "exec test\n");
     a1d:	a1 68 68 00 00       	mov    0x6868,%eax
     a22:	c7 44 24 04 fd 4d 00 	movl   $0x4dfd,0x4(%esp)
     a29:	00 
     a2a:	89 04 24             	mov    %eax,(%esp)
     a2d:	e8 b1 3b 00 00       	call   45e3 <printf>
  if(exec("echo", echoargv) < 0){
     a32:	c7 44 24 04 54 68 00 	movl   $0x6854,0x4(%esp)
     a39:	00 
     a3a:	c7 04 24 a8 49 00 00 	movl   $0x49a8,(%esp)
     a41:	e8 4e 3a 00 00       	call   4494 <exec>
     a46:	85 c0                	test   %eax,%eax
     a48:	79 21                	jns    a6b <exectest+0x54>
    printf(stdout, "exec echo failed\n");
     a4a:	a1 68 68 00 00       	mov    0x6868,%eax
     a4f:	c7 44 24 04 08 4e 00 	movl   $0x4e08,0x4(%esp)
     a56:	00 
     a57:	89 04 24             	mov    %eax,(%esp)
     a5a:	e8 84 3b 00 00       	call   45e3 <printf>
    exit(EXIT_STATUS_DEFAULT);
     a5f:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     a66:	e8 f1 39 00 00       	call   445c <exit>
  }
}
     a6b:	c9                   	leave  
     a6c:	c3                   	ret    

00000a6d <pipe1>:

// simple fork and pipe read/write

void
pipe1(void)
{
     a6d:	55                   	push   %ebp
     a6e:	89 e5                	mov    %esp,%ebp
     a70:	83 ec 38             	sub    $0x38,%esp
  int fds[2], pid;
  int seq, i, n, cc, total;

  if(pipe(fds) != 0){
     a73:	8d 45 d8             	lea    -0x28(%ebp),%eax
     a76:	89 04 24             	mov    %eax,(%esp)
     a79:	e8 ee 39 00 00       	call   446c <pipe>
     a7e:	85 c0                	test   %eax,%eax
     a80:	74 20                	je     aa2 <pipe1+0x35>
    printf(1, "pipe() failed\n");
     a82:	c7 44 24 04 1a 4e 00 	movl   $0x4e1a,0x4(%esp)
     a89:	00 
     a8a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     a91:	e8 4d 3b 00 00       	call   45e3 <printf>
    exit(EXIT_STATUS_DEFAULT);
     a96:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     a9d:	e8 ba 39 00 00       	call   445c <exit>
  }
  pid = fork();
     aa2:	e8 ad 39 00 00       	call   4454 <fork>
     aa7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  seq = 0;
     aaa:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  if(pid == 0){
     ab1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
     ab5:	0f 85 94 00 00 00    	jne    b4f <pipe1+0xe2>
    close(fds[0]);
     abb:	8b 45 d8             	mov    -0x28(%ebp),%eax
     abe:	89 04 24             	mov    %eax,(%esp)
     ac1:	e8 be 39 00 00       	call   4484 <close>
    for(n = 0; n < 5; n++){
     ac6:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
     acd:	eb 6e                	jmp    b3d <pipe1+0xd0>
      for(i = 0; i < 1033; i++)
     acf:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
     ad6:	eb 16                	jmp    aee <pipe1+0x81>
        buf[i] = seq++;
     ad8:	8b 45 f4             	mov    -0xc(%ebp),%eax
     adb:	8b 55 f0             	mov    -0x10(%ebp),%edx
     ade:	81 c2 60 90 00 00    	add    $0x9060,%edx
     ae4:	88 02                	mov    %al,(%edx)
     ae6:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  pid = fork();
  seq = 0;
  if(pid == 0){
    close(fds[0]);
    for(n = 0; n < 5; n++){
      for(i = 0; i < 1033; i++)
     aea:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
     aee:	81 7d f0 08 04 00 00 	cmpl   $0x408,-0x10(%ebp)
     af5:	7e e1                	jle    ad8 <pipe1+0x6b>
        buf[i] = seq++;
      if(write(fds[1], buf, 1033) != 1033){
     af7:	8b 45 dc             	mov    -0x24(%ebp),%eax
     afa:	c7 44 24 08 09 04 00 	movl   $0x409,0x8(%esp)
     b01:	00 
     b02:	c7 44 24 04 60 90 00 	movl   $0x9060,0x4(%esp)
     b09:	00 
     b0a:	89 04 24             	mov    %eax,(%esp)
     b0d:	e8 6a 39 00 00       	call   447c <write>
     b12:	3d 09 04 00 00       	cmp    $0x409,%eax
     b17:	74 20                	je     b39 <pipe1+0xcc>
        printf(1, "pipe1 oops 1\n");
     b19:	c7 44 24 04 29 4e 00 	movl   $0x4e29,0x4(%esp)
     b20:	00 
     b21:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     b28:	e8 b6 3a 00 00       	call   45e3 <printf>
        exit(EXIT_STATUS_DEFAULT);
     b2d:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     b34:	e8 23 39 00 00       	call   445c <exit>
  }
  pid = fork();
  seq = 0;
  if(pid == 0){
    close(fds[0]);
    for(n = 0; n < 5; n++){
     b39:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
     b3d:	83 7d ec 04          	cmpl   $0x4,-0x14(%ebp)
     b41:	7e 8c                	jle    acf <pipe1+0x62>
      if(write(fds[1], buf, 1033) != 1033){
        printf(1, "pipe1 oops 1\n");
        exit(EXIT_STATUS_DEFAULT);
      }
    }
    exit(EXIT_STATUS_DEFAULT);
     b43:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     b4a:	e8 0d 39 00 00       	call   445c <exit>
  } else if(pid > 0){
     b4f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
     b53:	0f 8e 0a 01 00 00    	jle    c63 <pipe1+0x1f6>
    close(fds[1]);
     b59:	8b 45 dc             	mov    -0x24(%ebp),%eax
     b5c:	89 04 24             	mov    %eax,(%esp)
     b5f:	e8 20 39 00 00       	call   4484 <close>
    total = 0;
     b64:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    cc = 1;
     b6b:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
    while((n = read(fds[0], buf, cc)) > 0){
     b72:	eb 6b                	jmp    bdf <pipe1+0x172>
      for(i = 0; i < n; i++){
     b74:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
     b7b:	eb 40                	jmp    bbd <pipe1+0x150>
        if((buf[i] & 0xff) != (seq++ & 0xff)){
     b7d:	8b 45 f0             	mov    -0x10(%ebp),%eax
     b80:	05 60 90 00 00       	add    $0x9060,%eax
     b85:	0f b6 00             	movzbl (%eax),%eax
     b88:	0f be c0             	movsbl %al,%eax
     b8b:	33 45 f4             	xor    -0xc(%ebp),%eax
     b8e:	25 ff 00 00 00       	and    $0xff,%eax
     b93:	85 c0                	test   %eax,%eax
     b95:	0f 95 c0             	setne  %al
     b98:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
     b9c:	84 c0                	test   %al,%al
     b9e:	74 19                	je     bb9 <pipe1+0x14c>
          printf(1, "pipe1 oops 2\n");
     ba0:	c7 44 24 04 37 4e 00 	movl   $0x4e37,0x4(%esp)
     ba7:	00 
     ba8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     baf:	e8 2f 3a 00 00       	call   45e3 <printf>
          return;
     bb4:	e9 ca 00 00 00       	jmp    c83 <pipe1+0x216>
  } else if(pid > 0){
    close(fds[1]);
    total = 0;
    cc = 1;
    while((n = read(fds[0], buf, cc)) > 0){
      for(i = 0; i < n; i++){
     bb9:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
     bbd:	8b 45 f0             	mov    -0x10(%ebp),%eax
     bc0:	3b 45 ec             	cmp    -0x14(%ebp),%eax
     bc3:	7c b8                	jl     b7d <pipe1+0x110>
        if((buf[i] & 0xff) != (seq++ & 0xff)){
          printf(1, "pipe1 oops 2\n");
          return;
        }
      }
      total += n;
     bc5:	8b 45 ec             	mov    -0x14(%ebp),%eax
     bc8:	01 45 e4             	add    %eax,-0x1c(%ebp)
      cc = cc * 2;
     bcb:	d1 65 e8             	shll   -0x18(%ebp)
      if(cc > sizeof(buf))
     bce:	8b 45 e8             	mov    -0x18(%ebp),%eax
     bd1:	3d 00 20 00 00       	cmp    $0x2000,%eax
     bd6:	76 07                	jbe    bdf <pipe1+0x172>
        cc = sizeof(buf);
     bd8:	c7 45 e8 00 20 00 00 	movl   $0x2000,-0x18(%ebp)
    exit(EXIT_STATUS_DEFAULT);
  } else if(pid > 0){
    close(fds[1]);
    total = 0;
    cc = 1;
    while((n = read(fds[0], buf, cc)) > 0){
     bdf:	8b 45 d8             	mov    -0x28(%ebp),%eax
     be2:	8b 55 e8             	mov    -0x18(%ebp),%edx
     be5:	89 54 24 08          	mov    %edx,0x8(%esp)
     be9:	c7 44 24 04 60 90 00 	movl   $0x9060,0x4(%esp)
     bf0:	00 
     bf1:	89 04 24             	mov    %eax,(%esp)
     bf4:	e8 7b 38 00 00       	call   4474 <read>
     bf9:	89 45 ec             	mov    %eax,-0x14(%ebp)
     bfc:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
     c00:	0f 8f 6e ff ff ff    	jg     b74 <pipe1+0x107>
      total += n;
      cc = cc * 2;
      if(cc > sizeof(buf))
        cc = sizeof(buf);
    }
    if(total != 5 * 1033){
     c06:	81 7d e4 2d 14 00 00 	cmpl   $0x142d,-0x1c(%ebp)
     c0d:	74 27                	je     c36 <pipe1+0x1c9>
      printf(1, "pipe1 oops 3 total %d\n", total);
     c0f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     c12:	89 44 24 08          	mov    %eax,0x8(%esp)
     c16:	c7 44 24 04 45 4e 00 	movl   $0x4e45,0x4(%esp)
     c1d:	00 
     c1e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     c25:	e8 b9 39 00 00       	call   45e3 <printf>
      exit(EXIT_STATUS_DEFAULT);
     c2a:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     c31:	e8 26 38 00 00       	call   445c <exit>
    }
    close(fds[0]);
     c36:	8b 45 d8             	mov    -0x28(%ebp),%eax
     c39:	89 04 24             	mov    %eax,(%esp)
     c3c:	e8 43 38 00 00       	call   4484 <close>
    wait(0);
     c41:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
     c48:	e8 17 38 00 00       	call   4464 <wait>
  } else {
    printf(1, "fork() failed\n");
    exit(EXIT_STATUS_DEFAULT);
  }
  printf(1, "pipe1 ok\n");
     c4d:	c7 44 24 04 5c 4e 00 	movl   $0x4e5c,0x4(%esp)
     c54:	00 
     c55:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     c5c:	e8 82 39 00 00       	call   45e3 <printf>
     c61:	eb 20                	jmp    c83 <pipe1+0x216>
      exit(EXIT_STATUS_DEFAULT);
    }
    close(fds[0]);
    wait(0);
  } else {
    printf(1, "fork() failed\n");
     c63:	c7 44 24 04 66 4e 00 	movl   $0x4e66,0x4(%esp)
     c6a:	00 
     c6b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     c72:	e8 6c 39 00 00       	call   45e3 <printf>
    exit(EXIT_STATUS_DEFAULT);
     c77:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     c7e:	e8 d9 37 00 00       	call   445c <exit>
  }
  printf(1, "pipe1 ok\n");
}
     c83:	c9                   	leave  
     c84:	c3                   	ret    

00000c85 <preempt>:

// meant to be run w/ at most two CPUs
void
preempt(void)
{
     c85:	55                   	push   %ebp
     c86:	89 e5                	mov    %esp,%ebp
     c88:	83 ec 38             	sub    $0x38,%esp
  int pid1, pid2, pid3;
  int pfds[2];

  printf(1, "preempt: ");
     c8b:	c7 44 24 04 75 4e 00 	movl   $0x4e75,0x4(%esp)
     c92:	00 
     c93:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     c9a:	e8 44 39 00 00       	call   45e3 <printf>
  pid1 = fork();
     c9f:	e8 b0 37 00 00       	call   4454 <fork>
     ca4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pid1 == 0)
     ca7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
     cab:	75 02                	jne    caf <preempt+0x2a>
    for(;;)
      ;
     cad:	eb fe                	jmp    cad <preempt+0x28>

  pid2 = fork();
     caf:	e8 a0 37 00 00       	call   4454 <fork>
     cb4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(pid2 == 0)
     cb7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
     cbb:	75 02                	jne    cbf <preempt+0x3a>
    for(;;)
      ;
     cbd:	eb fe                	jmp    cbd <preempt+0x38>

  pipe(pfds);
     cbf:	8d 45 e4             	lea    -0x1c(%ebp),%eax
     cc2:	89 04 24             	mov    %eax,(%esp)
     cc5:	e8 a2 37 00 00       	call   446c <pipe>
  pid3 = fork();
     cca:	e8 85 37 00 00       	call   4454 <fork>
     ccf:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(pid3 == 0){
     cd2:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
     cd6:	75 4c                	jne    d24 <preempt+0x9f>
    close(pfds[0]);
     cd8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     cdb:	89 04 24             	mov    %eax,(%esp)
     cde:	e8 a1 37 00 00       	call   4484 <close>
    if(write(pfds[1], "x", 1) != 1)
     ce3:	8b 45 e8             	mov    -0x18(%ebp),%eax
     ce6:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
     ced:	00 
     cee:	c7 44 24 04 7f 4e 00 	movl   $0x4e7f,0x4(%esp)
     cf5:	00 
     cf6:	89 04 24             	mov    %eax,(%esp)
     cf9:	e8 7e 37 00 00       	call   447c <write>
     cfe:	83 f8 01             	cmp    $0x1,%eax
     d01:	74 14                	je     d17 <preempt+0x92>
      printf(1, "preempt write error");
     d03:	c7 44 24 04 81 4e 00 	movl   $0x4e81,0x4(%esp)
     d0a:	00 
     d0b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     d12:	e8 cc 38 00 00       	call   45e3 <printf>
    close(pfds[1]);
     d17:	8b 45 e8             	mov    -0x18(%ebp),%eax
     d1a:	89 04 24             	mov    %eax,(%esp)
     d1d:	e8 62 37 00 00       	call   4484 <close>
    for(;;)
      ;
     d22:	eb fe                	jmp    d22 <preempt+0x9d>
  }

  close(pfds[1]);
     d24:	8b 45 e8             	mov    -0x18(%ebp),%eax
     d27:	89 04 24             	mov    %eax,(%esp)
     d2a:	e8 55 37 00 00       	call   4484 <close>
  if(read(pfds[0], buf, sizeof(buf)) != 1){
     d2f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     d32:	c7 44 24 08 00 20 00 	movl   $0x2000,0x8(%esp)
     d39:	00 
     d3a:	c7 44 24 04 60 90 00 	movl   $0x9060,0x4(%esp)
     d41:	00 
     d42:	89 04 24             	mov    %eax,(%esp)
     d45:	e8 2a 37 00 00       	call   4474 <read>
     d4a:	83 f8 01             	cmp    $0x1,%eax
     d4d:	74 19                	je     d68 <preempt+0xe3>
    printf(1, "preempt read error");
     d4f:	c7 44 24 04 95 4e 00 	movl   $0x4e95,0x4(%esp)
     d56:	00 
     d57:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     d5e:	e8 80 38 00 00       	call   45e3 <printf>
    return;
     d63:	e9 8c 00 00 00       	jmp    df4 <preempt+0x16f>
  }
  close(pfds[0]);
     d68:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     d6b:	89 04 24             	mov    %eax,(%esp)
     d6e:	e8 11 37 00 00       	call   4484 <close>
  printf(1, "kill... ");
     d73:	c7 44 24 04 a8 4e 00 	movl   $0x4ea8,0x4(%esp)
     d7a:	00 
     d7b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     d82:	e8 5c 38 00 00       	call   45e3 <printf>
  kill(pid1);
     d87:	8b 45 f4             	mov    -0xc(%ebp),%eax
     d8a:	89 04 24             	mov    %eax,(%esp)
     d8d:	e8 fa 36 00 00       	call   448c <kill>
  kill(pid2);
     d92:	8b 45 f0             	mov    -0x10(%ebp),%eax
     d95:	89 04 24             	mov    %eax,(%esp)
     d98:	e8 ef 36 00 00       	call   448c <kill>
  kill(pid3);
     d9d:	8b 45 ec             	mov    -0x14(%ebp),%eax
     da0:	89 04 24             	mov    %eax,(%esp)
     da3:	e8 e4 36 00 00       	call   448c <kill>
  printf(1, "wait... ");
     da8:	c7 44 24 04 b1 4e 00 	movl   $0x4eb1,0x4(%esp)
     daf:	00 
     db0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     db7:	e8 27 38 00 00       	call   45e3 <printf>
  wait(0);
     dbc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
     dc3:	e8 9c 36 00 00       	call   4464 <wait>
  wait(0);
     dc8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
     dcf:	e8 90 36 00 00       	call   4464 <wait>
  wait(0);
     dd4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
     ddb:	e8 84 36 00 00       	call   4464 <wait>
  printf(1, "preempt ok\n");
     de0:	c7 44 24 04 ba 4e 00 	movl   $0x4eba,0x4(%esp)
     de7:	00 
     de8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     def:	e8 ef 37 00 00       	call   45e3 <printf>
}
     df4:	c9                   	leave  
     df5:	c3                   	ret    

00000df6 <exitwait>:

// try to find any races between exit and wait
void
exitwait(void)
{
     df6:	55                   	push   %ebp
     df7:	89 e5                	mov    %esp,%ebp
     df9:	83 ec 28             	sub    $0x28,%esp
  int i, pid;

  for(i = 0; i < 100; i++){
     dfc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     e03:	eb 61                	jmp    e66 <exitwait+0x70>
    pid = fork();
     e05:	e8 4a 36 00 00       	call   4454 <fork>
     e0a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(pid < 0){
     e0d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
     e11:	79 16                	jns    e29 <exitwait+0x33>
      printf(1, "fork failed\n");
     e13:	c7 44 24 04 49 4a 00 	movl   $0x4a49,0x4(%esp)
     e1a:	00 
     e1b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     e22:	e8 bc 37 00 00       	call   45e3 <printf>
      return;
     e27:	eb 57                	jmp    e80 <exitwait+0x8a>
    }
    if(pid){
     e29:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
     e2d:	74 27                	je     e56 <exitwait+0x60>
      if(wait(0) != pid){
     e2f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
     e36:	e8 29 36 00 00       	call   4464 <wait>
     e3b:	3b 45 f0             	cmp    -0x10(%ebp),%eax
     e3e:	74 22                	je     e62 <exitwait+0x6c>
        printf(1, "wait wrong pid\n");
     e40:	c7 44 24 04 c6 4e 00 	movl   $0x4ec6,0x4(%esp)
     e47:	00 
     e48:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     e4f:	e8 8f 37 00 00       	call   45e3 <printf>
        return;
     e54:	eb 2a                	jmp    e80 <exitwait+0x8a>
      }
    } else {
      exit(EXIT_STATUS_DEFAULT);
     e56:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     e5d:	e8 fa 35 00 00       	call   445c <exit>
void
exitwait(void)
{
  int i, pid;

  for(i = 0; i < 100; i++){
     e62:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
     e66:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
     e6a:	7e 99                	jle    e05 <exitwait+0xf>
      }
    } else {
      exit(EXIT_STATUS_DEFAULT);
    }
  }
  printf(1, "exitwait ok\n");
     e6c:	c7 44 24 04 d6 4e 00 	movl   $0x4ed6,0x4(%esp)
     e73:	00 
     e74:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     e7b:	e8 63 37 00 00       	call   45e3 <printf>
}
     e80:	c9                   	leave  
     e81:	c3                   	ret    

00000e82 <mem>:

void
mem(void)
{
     e82:	55                   	push   %ebp
     e83:	89 e5                	mov    %esp,%ebp
     e85:	83 ec 28             	sub    $0x28,%esp
  void *m1, *m2;
  int pid, ppid;

  printf(1, "mem test\n");
     e88:	c7 44 24 04 e3 4e 00 	movl   $0x4ee3,0x4(%esp)
     e8f:	00 
     e90:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     e97:	e8 47 37 00 00       	call   45e3 <printf>
  ppid = getpid();
     e9c:	e8 3b 36 00 00       	call   44dc <getpid>
     ea1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if((pid = fork()) == 0){
     ea4:	e8 ab 35 00 00       	call   4454 <fork>
     ea9:	89 45 ec             	mov    %eax,-0x14(%ebp)
     eac:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
     eb0:	0f 85 b8 00 00 00    	jne    f6e <mem+0xec>
    m1 = 0;
     eb6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while((m2 = malloc(10001)) != 0){
     ebd:	eb 0e                	jmp    ecd <mem+0x4b>
      *(char**)m2 = m1;
     ebf:	8b 45 e8             	mov    -0x18(%ebp),%eax
     ec2:	8b 55 f4             	mov    -0xc(%ebp),%edx
     ec5:	89 10                	mov    %edx,(%eax)
      m1 = m2;
     ec7:	8b 45 e8             	mov    -0x18(%ebp),%eax
     eca:	89 45 f4             	mov    %eax,-0xc(%ebp)

  printf(1, "mem test\n");
  ppid = getpid();
  if((pid = fork()) == 0){
    m1 = 0;
    while((m2 = malloc(10001)) != 0){
     ecd:	c7 04 24 11 27 00 00 	movl   $0x2711,(%esp)
     ed4:	e8 ee 39 00 00       	call   48c7 <malloc>
     ed9:	89 45 e8             	mov    %eax,-0x18(%ebp)
     edc:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
     ee0:	75 dd                	jne    ebf <mem+0x3d>
      *(char**)m2 = m1;
      m1 = m2;
    }
    while(m1){
     ee2:	eb 19                	jmp    efd <mem+0x7b>
      m2 = *(char**)m1;
     ee4:	8b 45 f4             	mov    -0xc(%ebp),%eax
     ee7:	8b 00                	mov    (%eax),%eax
     ee9:	89 45 e8             	mov    %eax,-0x18(%ebp)
      free(m1);
     eec:	8b 45 f4             	mov    -0xc(%ebp),%eax
     eef:	89 04 24             	mov    %eax,(%esp)
     ef2:	e8 a1 38 00 00       	call   4798 <free>
      m1 = m2;
     ef7:	8b 45 e8             	mov    -0x18(%ebp),%eax
     efa:	89 45 f4             	mov    %eax,-0xc(%ebp)
    m1 = 0;
    while((m2 = malloc(10001)) != 0){
      *(char**)m2 = m1;
      m1 = m2;
    }
    while(m1){
     efd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
     f01:	75 e1                	jne    ee4 <mem+0x62>
      m2 = *(char**)m1;
      free(m1);
      m1 = m2;
    }
    m1 = malloc(1024*20);
     f03:	c7 04 24 00 50 00 00 	movl   $0x5000,(%esp)
     f0a:	e8 b8 39 00 00       	call   48c7 <malloc>
     f0f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(m1 == 0){
     f12:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
     f16:	75 2b                	jne    f43 <mem+0xc1>
      printf(1, "couldn't allocate mem?!!\n");
     f18:	c7 44 24 04 ed 4e 00 	movl   $0x4eed,0x4(%esp)
     f1f:	00 
     f20:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     f27:	e8 b7 36 00 00       	call   45e3 <printf>
      kill(ppid);
     f2c:	8b 45 f0             	mov    -0x10(%ebp),%eax
     f2f:	89 04 24             	mov    %eax,(%esp)
     f32:	e8 55 35 00 00       	call   448c <kill>
      exit(EXIT_STATUS_DEFAULT);
     f37:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     f3e:	e8 19 35 00 00       	call   445c <exit>
    }
    free(m1);
     f43:	8b 45 f4             	mov    -0xc(%ebp),%eax
     f46:	89 04 24             	mov    %eax,(%esp)
     f49:	e8 4a 38 00 00       	call   4798 <free>
    printf(1, "mem ok\n");
     f4e:	c7 44 24 04 07 4f 00 	movl   $0x4f07,0x4(%esp)
     f55:	00 
     f56:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     f5d:	e8 81 36 00 00       	call   45e3 <printf>
    exit(EXIT_STATUS_DEFAULT);
     f62:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     f69:	e8 ee 34 00 00       	call   445c <exit>
  } else {
    wait(0);
     f6e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
     f75:	e8 ea 34 00 00       	call   4464 <wait>
  }
}
     f7a:	c9                   	leave  
     f7b:	c3                   	ret    

00000f7c <sharedfd>:

// two processes write to the same file descriptor
// is the offset shared? does inode locking work?
void
sharedfd(void)
{
     f7c:	55                   	push   %ebp
     f7d:	89 e5                	mov    %esp,%ebp
     f7f:	83 ec 48             	sub    $0x48,%esp
  int fd, pid, i, n, nc, np;
  char buf[10];

  printf(1, "sharedfd test\n");
     f82:	c7 44 24 04 0f 4f 00 	movl   $0x4f0f,0x4(%esp)
     f89:	00 
     f8a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     f91:	e8 4d 36 00 00       	call   45e3 <printf>

  unlink("sharedfd");
     f96:	c7 04 24 1e 4f 00 00 	movl   $0x4f1e,(%esp)
     f9d:	e8 0a 35 00 00       	call   44ac <unlink>
  fd = open("sharedfd", O_CREATE|O_RDWR);
     fa2:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
     fa9:	00 
     faa:	c7 04 24 1e 4f 00 00 	movl   $0x4f1e,(%esp)
     fb1:	e8 e6 34 00 00       	call   449c <open>
     fb6:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(fd < 0){
     fb9:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
     fbd:	79 19                	jns    fd8 <sharedfd+0x5c>
    printf(1, "fstests: cannot open sharedfd for writing");
     fbf:	c7 44 24 04 28 4f 00 	movl   $0x4f28,0x4(%esp)
     fc6:	00 
     fc7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     fce:	e8 10 36 00 00       	call   45e3 <printf>
    return;
     fd3:	e9 b1 01 00 00       	jmp    1189 <sharedfd+0x20d>
  }
  pid = fork();
     fd8:	e8 77 34 00 00       	call   4454 <fork>
     fdd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  memset(buf, pid==0?'c':'p', sizeof(buf));
     fe0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
     fe4:	75 07                	jne    fed <sharedfd+0x71>
     fe6:	b8 63 00 00 00       	mov    $0x63,%eax
     feb:	eb 05                	jmp    ff2 <sharedfd+0x76>
     fed:	b8 70 00 00 00       	mov    $0x70,%eax
     ff2:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
     ff9:	00 
     ffa:	89 44 24 04          	mov    %eax,0x4(%esp)
     ffe:	8d 45 d6             	lea    -0x2a(%ebp),%eax
    1001:	89 04 24             	mov    %eax,(%esp)
    1004:	e8 ae 32 00 00       	call   42b7 <memset>
  for(i = 0; i < 1000; i++){
    1009:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    1010:	eb 39                	jmp    104b <sharedfd+0xcf>
    if(write(fd, buf, sizeof(buf)) != sizeof(buf)){
    1012:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
    1019:	00 
    101a:	8d 45 d6             	lea    -0x2a(%ebp),%eax
    101d:	89 44 24 04          	mov    %eax,0x4(%esp)
    1021:	8b 45 e8             	mov    -0x18(%ebp),%eax
    1024:	89 04 24             	mov    %eax,(%esp)
    1027:	e8 50 34 00 00       	call   447c <write>
    102c:	83 f8 0a             	cmp    $0xa,%eax
    102f:	74 16                	je     1047 <sharedfd+0xcb>
      printf(1, "fstests: write sharedfd failed\n");
    1031:	c7 44 24 04 54 4f 00 	movl   $0x4f54,0x4(%esp)
    1038:	00 
    1039:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1040:	e8 9e 35 00 00       	call   45e3 <printf>
      break;
    1045:	eb 0d                	jmp    1054 <sharedfd+0xd8>
    printf(1, "fstests: cannot open sharedfd for writing");
    return;
  }
  pid = fork();
  memset(buf, pid==0?'c':'p', sizeof(buf));
  for(i = 0; i < 1000; i++){
    1047:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    104b:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
    1052:	7e be                	jle    1012 <sharedfd+0x96>
    if(write(fd, buf, sizeof(buf)) != sizeof(buf)){
      printf(1, "fstests: write sharedfd failed\n");
      break;
    }
  }
  if(pid == 0)
    1054:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
    1058:	75 0c                	jne    1066 <sharedfd+0xea>
    exit(EXIT_STATUS_DEFAULT);
    105a:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    1061:	e8 f6 33 00 00       	call   445c <exit>
  else
    wait(0);
    1066:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    106d:	e8 f2 33 00 00       	call   4464 <wait>
  close(fd);
    1072:	8b 45 e8             	mov    -0x18(%ebp),%eax
    1075:	89 04 24             	mov    %eax,(%esp)
    1078:	e8 07 34 00 00       	call   4484 <close>
  fd = open("sharedfd", 0);
    107d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    1084:	00 
    1085:	c7 04 24 1e 4f 00 00 	movl   $0x4f1e,(%esp)
    108c:	e8 0b 34 00 00       	call   449c <open>
    1091:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(fd < 0){
    1094:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
    1098:	79 19                	jns    10b3 <sharedfd+0x137>
    printf(1, "fstests: cannot open sharedfd for reading\n");
    109a:	c7 44 24 04 74 4f 00 	movl   $0x4f74,0x4(%esp)
    10a1:	00 
    10a2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    10a9:	e8 35 35 00 00       	call   45e3 <printf>
    return;
    10ae:	e9 d6 00 00 00       	jmp    1189 <sharedfd+0x20d>
  }
  nc = np = 0;
    10b3:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
    10ba:	8b 45 ec             	mov    -0x14(%ebp),%eax
    10bd:	89 45 f0             	mov    %eax,-0x10(%ebp)
  while((n = read(fd, buf, sizeof(buf))) > 0){
    10c0:	eb 37                	jmp    10f9 <sharedfd+0x17d>
    for(i = 0; i < sizeof(buf); i++){
    10c2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    10c9:	eb 26                	jmp    10f1 <sharedfd+0x175>
      if(buf[i] == 'c')
    10cb:	8d 45 d6             	lea    -0x2a(%ebp),%eax
    10ce:	03 45 f4             	add    -0xc(%ebp),%eax
    10d1:	0f b6 00             	movzbl (%eax),%eax
    10d4:	3c 63                	cmp    $0x63,%al
    10d6:	75 04                	jne    10dc <sharedfd+0x160>
        nc++;
    10d8:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
      if(buf[i] == 'p')
    10dc:	8d 45 d6             	lea    -0x2a(%ebp),%eax
    10df:	03 45 f4             	add    -0xc(%ebp),%eax
    10e2:	0f b6 00             	movzbl (%eax),%eax
    10e5:	3c 70                	cmp    $0x70,%al
    10e7:	75 04                	jne    10ed <sharedfd+0x171>
        np++;
    10e9:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
    printf(1, "fstests: cannot open sharedfd for reading\n");
    return;
  }
  nc = np = 0;
  while((n = read(fd, buf, sizeof(buf))) > 0){
    for(i = 0; i < sizeof(buf); i++){
    10ed:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    10f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
    10f4:	83 f8 09             	cmp    $0x9,%eax
    10f7:	76 d2                	jbe    10cb <sharedfd+0x14f>
  if(fd < 0){
    printf(1, "fstests: cannot open sharedfd for reading\n");
    return;
  }
  nc = np = 0;
  while((n = read(fd, buf, sizeof(buf))) > 0){
    10f9:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
    1100:	00 
    1101:	8d 45 d6             	lea    -0x2a(%ebp),%eax
    1104:	89 44 24 04          	mov    %eax,0x4(%esp)
    1108:	8b 45 e8             	mov    -0x18(%ebp),%eax
    110b:	89 04 24             	mov    %eax,(%esp)
    110e:	e8 61 33 00 00       	call   4474 <read>
    1113:	89 45 e0             	mov    %eax,-0x20(%ebp)
    1116:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
    111a:	7f a6                	jg     10c2 <sharedfd+0x146>
        nc++;
      if(buf[i] == 'p')
        np++;
    }
  }
  close(fd);
    111c:	8b 45 e8             	mov    -0x18(%ebp),%eax
    111f:	89 04 24             	mov    %eax,(%esp)
    1122:	e8 5d 33 00 00       	call   4484 <close>
  unlink("sharedfd");
    1127:	c7 04 24 1e 4f 00 00 	movl   $0x4f1e,(%esp)
    112e:	e8 79 33 00 00       	call   44ac <unlink>
  if(nc == 10000 && np == 10000){
    1133:	81 7d f0 10 27 00 00 	cmpl   $0x2710,-0x10(%ebp)
    113a:	75 1f                	jne    115b <sharedfd+0x1df>
    113c:	81 7d ec 10 27 00 00 	cmpl   $0x2710,-0x14(%ebp)
    1143:	75 16                	jne    115b <sharedfd+0x1df>
    printf(1, "sharedfd ok\n");
    1145:	c7 44 24 04 9f 4f 00 	movl   $0x4f9f,0x4(%esp)
    114c:	00 
    114d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1154:	e8 8a 34 00 00       	call   45e3 <printf>
    1159:	eb 2e                	jmp    1189 <sharedfd+0x20d>
  } else {
    printf(1, "sharedfd oops %d %d\n", nc, np);
    115b:	8b 45 ec             	mov    -0x14(%ebp),%eax
    115e:	89 44 24 0c          	mov    %eax,0xc(%esp)
    1162:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1165:	89 44 24 08          	mov    %eax,0x8(%esp)
    1169:	c7 44 24 04 ac 4f 00 	movl   $0x4fac,0x4(%esp)
    1170:	00 
    1171:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1178:	e8 66 34 00 00       	call   45e3 <printf>
    exit(EXIT_STATUS_DEFAULT);
    117d:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    1184:	e8 d3 32 00 00       	call   445c <exit>
  }
}
    1189:	c9                   	leave  
    118a:	c3                   	ret    

0000118b <fourfiles>:

// four processes write different files at the same
// time, to test block allocation.
void
fourfiles(void)
{
    118b:	55                   	push   %ebp
    118c:	89 e5                	mov    %esp,%ebp
    118e:	83 ec 48             	sub    $0x48,%esp
  int fd, pid, i, j, n, total, pi;
  char *names[] = { "f0", "f1", "f2", "f3" };
    1191:	c7 45 c8 c1 4f 00 00 	movl   $0x4fc1,-0x38(%ebp)
    1198:	c7 45 cc c4 4f 00 00 	movl   $0x4fc4,-0x34(%ebp)
    119f:	c7 45 d0 c7 4f 00 00 	movl   $0x4fc7,-0x30(%ebp)
    11a6:	c7 45 d4 ca 4f 00 00 	movl   $0x4fca,-0x2c(%ebp)
  char *fname;

  printf(1, "fourfiles test\n");
    11ad:	c7 44 24 04 cd 4f 00 	movl   $0x4fcd,0x4(%esp)
    11b4:	00 
    11b5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    11bc:	e8 22 34 00 00       	call   45e3 <printf>

  for(pi = 0; pi < 4; pi++){
    11c1:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
    11c8:	e9 18 01 00 00       	jmp    12e5 <fourfiles+0x15a>
    fname = names[pi];
    11cd:	8b 45 e8             	mov    -0x18(%ebp),%eax
    11d0:	8b 44 85 c8          	mov    -0x38(%ebp,%eax,4),%eax
    11d4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    unlink(fname);
    11d7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    11da:	89 04 24             	mov    %eax,(%esp)
    11dd:	e8 ca 32 00 00       	call   44ac <unlink>

    pid = fork();
    11e2:	e8 6d 32 00 00       	call   4454 <fork>
    11e7:	89 45 e0             	mov    %eax,-0x20(%ebp)
    if(pid < 0){
    11ea:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
    11ee:	79 20                	jns    1210 <fourfiles+0x85>
      printf(1, "fork failed\n");
    11f0:	c7 44 24 04 49 4a 00 	movl   $0x4a49,0x4(%esp)
    11f7:	00 
    11f8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    11ff:	e8 df 33 00 00       	call   45e3 <printf>
      exit(EXIT_STATUS_DEFAULT);
    1204:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    120b:	e8 4c 32 00 00       	call   445c <exit>
    }

    if(pid == 0){
    1210:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
    1214:	0f 85 c7 00 00 00    	jne    12e1 <fourfiles+0x156>
      fd = open(fname, O_CREATE | O_RDWR);
    121a:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
    1221:	00 
    1222:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    1225:	89 04 24             	mov    %eax,(%esp)
    1228:	e8 6f 32 00 00       	call   449c <open>
    122d:	89 45 dc             	mov    %eax,-0x24(%ebp)
      if(fd < 0){
    1230:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
    1234:	79 20                	jns    1256 <fourfiles+0xcb>
        printf(1, "create failed\n");
    1236:	c7 44 24 04 dd 4f 00 	movl   $0x4fdd,0x4(%esp)
    123d:	00 
    123e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1245:	e8 99 33 00 00       	call   45e3 <printf>
        exit(EXIT_STATUS_DEFAULT);
    124a:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    1251:	e8 06 32 00 00       	call   445c <exit>
      }
      
      memset(buf, '0'+pi, 512);
    1256:	8b 45 e8             	mov    -0x18(%ebp),%eax
    1259:	83 c0 30             	add    $0x30,%eax
    125c:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
    1263:	00 
    1264:	89 44 24 04          	mov    %eax,0x4(%esp)
    1268:	c7 04 24 60 90 00 00 	movl   $0x9060,(%esp)
    126f:	e8 43 30 00 00       	call   42b7 <memset>
      for(i = 0; i < 12; i++){
    1274:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    127b:	eb 52                	jmp    12cf <fourfiles+0x144>
        if((n = write(fd, buf, 500)) != 500){
    127d:	c7 44 24 08 f4 01 00 	movl   $0x1f4,0x8(%esp)
    1284:	00 
    1285:	c7 44 24 04 60 90 00 	movl   $0x9060,0x4(%esp)
    128c:	00 
    128d:	8b 45 dc             	mov    -0x24(%ebp),%eax
    1290:	89 04 24             	mov    %eax,(%esp)
    1293:	e8 e4 31 00 00       	call   447c <write>
    1298:	89 45 d8             	mov    %eax,-0x28(%ebp)
    129b:	81 7d d8 f4 01 00 00 	cmpl   $0x1f4,-0x28(%ebp)
    12a2:	74 27                	je     12cb <fourfiles+0x140>
          printf(1, "write failed %d\n", n);
    12a4:	8b 45 d8             	mov    -0x28(%ebp),%eax
    12a7:	89 44 24 08          	mov    %eax,0x8(%esp)
    12ab:	c7 44 24 04 ec 4f 00 	movl   $0x4fec,0x4(%esp)
    12b2:	00 
    12b3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    12ba:	e8 24 33 00 00       	call   45e3 <printf>
          exit(EXIT_STATUS_DEFAULT);
    12bf:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    12c6:	e8 91 31 00 00       	call   445c <exit>
        printf(1, "create failed\n");
        exit(EXIT_STATUS_DEFAULT);
      }
      
      memset(buf, '0'+pi, 512);
      for(i = 0; i < 12; i++){
    12cb:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    12cf:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
    12d3:	7e a8                	jle    127d <fourfiles+0xf2>
        if((n = write(fd, buf, 500)) != 500){
          printf(1, "write failed %d\n", n);
          exit(EXIT_STATUS_DEFAULT);
        }
      }
      exit(EXIT_STATUS_DEFAULT);
    12d5:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    12dc:	e8 7b 31 00 00       	call   445c <exit>
  char *names[] = { "f0", "f1", "f2", "f3" };
  char *fname;

  printf(1, "fourfiles test\n");

  for(pi = 0; pi < 4; pi++){
    12e1:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
    12e5:	83 7d e8 03          	cmpl   $0x3,-0x18(%ebp)
    12e9:	0f 8e de fe ff ff    	jle    11cd <fourfiles+0x42>
      }
      exit(EXIT_STATUS_DEFAULT);
    }
  }

  for(pi = 0; pi < 4; pi++){
    12ef:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
    12f6:	eb 10                	jmp    1308 <fourfiles+0x17d>
    wait(0);
    12f8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    12ff:	e8 60 31 00 00       	call   4464 <wait>
      }
      exit(EXIT_STATUS_DEFAULT);
    }
  }

  for(pi = 0; pi < 4; pi++){
    1304:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
    1308:	83 7d e8 03          	cmpl   $0x3,-0x18(%ebp)
    130c:	7e ea                	jle    12f8 <fourfiles+0x16d>
    wait(0);
  }

  for(i = 0; i < 2; i++){
    130e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    1315:	e9 ea 00 00 00       	jmp    1404 <fourfiles+0x279>
    fname = names[i];
    131a:	8b 45 f4             	mov    -0xc(%ebp),%eax
    131d:	8b 44 85 c8          	mov    -0x38(%ebp,%eax,4),%eax
    1321:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    fd = open(fname, 0);
    1324:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    132b:	00 
    132c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    132f:	89 04 24             	mov    %eax,(%esp)
    1332:	e8 65 31 00 00       	call   449c <open>
    1337:	89 45 dc             	mov    %eax,-0x24(%ebp)
    total = 0;
    133a:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
    while((n = read(fd, buf, sizeof(buf))) > 0){
    1341:	eb 53                	jmp    1396 <fourfiles+0x20b>
      for(j = 0; j < n; j++){
    1343:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    134a:	eb 3c                	jmp    1388 <fourfiles+0x1fd>
        if(buf[j] != '0'+i){
    134c:	8b 45 f0             	mov    -0x10(%ebp),%eax
    134f:	05 60 90 00 00       	add    $0x9060,%eax
    1354:	0f b6 00             	movzbl (%eax),%eax
    1357:	0f be c0             	movsbl %al,%eax
    135a:	8b 55 f4             	mov    -0xc(%ebp),%edx
    135d:	83 c2 30             	add    $0x30,%edx
    1360:	39 d0                	cmp    %edx,%eax
    1362:	74 20                	je     1384 <fourfiles+0x1f9>
          printf(1, "wrong char\n");
    1364:	c7 44 24 04 fd 4f 00 	movl   $0x4ffd,0x4(%esp)
    136b:	00 
    136c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1373:	e8 6b 32 00 00       	call   45e3 <printf>
          exit(EXIT_STATUS_DEFAULT);
    1378:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    137f:	e8 d8 30 00 00       	call   445c <exit>
  for(i = 0; i < 2; i++){
    fname = names[i];
    fd = open(fname, 0);
    total = 0;
    while((n = read(fd, buf, sizeof(buf))) > 0){
      for(j = 0; j < n; j++){
    1384:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
    1388:	8b 45 f0             	mov    -0x10(%ebp),%eax
    138b:	3b 45 d8             	cmp    -0x28(%ebp),%eax
    138e:	7c bc                	jl     134c <fourfiles+0x1c1>
        if(buf[j] != '0'+i){
          printf(1, "wrong char\n");
          exit(EXIT_STATUS_DEFAULT);
        }
      }
      total += n;
    1390:	8b 45 d8             	mov    -0x28(%ebp),%eax
    1393:	01 45 ec             	add    %eax,-0x14(%ebp)

  for(i = 0; i < 2; i++){
    fname = names[i];
    fd = open(fname, 0);
    total = 0;
    while((n = read(fd, buf, sizeof(buf))) > 0){
    1396:	c7 44 24 08 00 20 00 	movl   $0x2000,0x8(%esp)
    139d:	00 
    139e:	c7 44 24 04 60 90 00 	movl   $0x9060,0x4(%esp)
    13a5:	00 
    13a6:	8b 45 dc             	mov    -0x24(%ebp),%eax
    13a9:	89 04 24             	mov    %eax,(%esp)
    13ac:	e8 c3 30 00 00       	call   4474 <read>
    13b1:	89 45 d8             	mov    %eax,-0x28(%ebp)
    13b4:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
    13b8:	7f 89                	jg     1343 <fourfiles+0x1b8>
          exit(EXIT_STATUS_DEFAULT);
        }
      }
      total += n;
    }
    close(fd);
    13ba:	8b 45 dc             	mov    -0x24(%ebp),%eax
    13bd:	89 04 24             	mov    %eax,(%esp)
    13c0:	e8 bf 30 00 00       	call   4484 <close>
    if(total != 12*500){
    13c5:	81 7d ec 70 17 00 00 	cmpl   $0x1770,-0x14(%ebp)
    13cc:	74 27                	je     13f5 <fourfiles+0x26a>
      printf(1, "wrong length %d\n", total);
    13ce:	8b 45 ec             	mov    -0x14(%ebp),%eax
    13d1:	89 44 24 08          	mov    %eax,0x8(%esp)
    13d5:	c7 44 24 04 09 50 00 	movl   $0x5009,0x4(%esp)
    13dc:	00 
    13dd:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    13e4:	e8 fa 31 00 00       	call   45e3 <printf>
      exit(EXIT_STATUS_DEFAULT);
    13e9:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    13f0:	e8 67 30 00 00       	call   445c <exit>
    }
    unlink(fname);
    13f5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    13f8:	89 04 24             	mov    %eax,(%esp)
    13fb:	e8 ac 30 00 00       	call   44ac <unlink>

  for(pi = 0; pi < 4; pi++){
    wait(0);
  }

  for(i = 0; i < 2; i++){
    1400:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    1404:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
    1408:	0f 8e 0c ff ff ff    	jle    131a <fourfiles+0x18f>
      exit(EXIT_STATUS_DEFAULT);
    }
    unlink(fname);
  }

  printf(1, "fourfiles ok\n");
    140e:	c7 44 24 04 1a 50 00 	movl   $0x501a,0x4(%esp)
    1415:	00 
    1416:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    141d:	e8 c1 31 00 00       	call   45e3 <printf>
}
    1422:	c9                   	leave  
    1423:	c3                   	ret    

00001424 <createdelete>:

// four processes create and delete different files in same directory
void
createdelete(void)
{
    1424:	55                   	push   %ebp
    1425:	89 e5                	mov    %esp,%ebp
    1427:	83 ec 48             	sub    $0x48,%esp
  enum { N = 20 };
  int pid, i, fd, pi;
  char name[32];

  printf(1, "createdelete test\n");
    142a:	c7 44 24 04 28 50 00 	movl   $0x5028,0x4(%esp)
    1431:	00 
    1432:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1439:	e8 a5 31 00 00       	call   45e3 <printf>

  for(pi = 0; pi < 4; pi++){
    143e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    1445:	e9 10 01 00 00       	jmp    155a <createdelete+0x136>
    pid = fork();
    144a:	e8 05 30 00 00       	call   4454 <fork>
    144f:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(pid < 0){
    1452:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    1456:	79 20                	jns    1478 <createdelete+0x54>
      printf(1, "fork failed\n");
    1458:	c7 44 24 04 49 4a 00 	movl   $0x4a49,0x4(%esp)
    145f:	00 
    1460:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1467:	e8 77 31 00 00       	call   45e3 <printf>
      exit(EXIT_STATUS_DEFAULT);
    146c:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    1473:	e8 e4 2f 00 00       	call   445c <exit>
    }

    if(pid == 0){
    1478:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    147c:	0f 85 d4 00 00 00    	jne    1556 <createdelete+0x132>
      name[0] = 'p' + pi;
    1482:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1485:	83 c0 70             	add    $0x70,%eax
    1488:	88 45 c8             	mov    %al,-0x38(%ebp)
      name[2] = '\0';
    148b:	c6 45 ca 00          	movb   $0x0,-0x36(%ebp)
      for(i = 0; i < N; i++){
    148f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    1496:	e9 a5 00 00 00       	jmp    1540 <createdelete+0x11c>
        name[1] = '0' + i;
    149b:	8b 45 f4             	mov    -0xc(%ebp),%eax
    149e:	83 c0 30             	add    $0x30,%eax
    14a1:	88 45 c9             	mov    %al,-0x37(%ebp)
        fd = open(name, O_CREATE | O_RDWR);
    14a4:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
    14ab:	00 
    14ac:	8d 45 c8             	lea    -0x38(%ebp),%eax
    14af:	89 04 24             	mov    %eax,(%esp)
    14b2:	e8 e5 2f 00 00       	call   449c <open>
    14b7:	89 45 e8             	mov    %eax,-0x18(%ebp)
        if(fd < 0){
    14ba:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
    14be:	79 20                	jns    14e0 <createdelete+0xbc>
          printf(1, "create failed\n");
    14c0:	c7 44 24 04 dd 4f 00 	movl   $0x4fdd,0x4(%esp)
    14c7:	00 
    14c8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    14cf:	e8 0f 31 00 00       	call   45e3 <printf>
          exit(EXIT_STATUS_DEFAULT);
    14d4:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    14db:	e8 7c 2f 00 00       	call   445c <exit>
        }
        close(fd);
    14e0:	8b 45 e8             	mov    -0x18(%ebp),%eax
    14e3:	89 04 24             	mov    %eax,(%esp)
    14e6:	e8 99 2f 00 00       	call   4484 <close>
        if(i > 0 && (i % 2 ) == 0){
    14eb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    14ef:	7e 4b                	jle    153c <createdelete+0x118>
    14f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
    14f4:	83 e0 01             	and    $0x1,%eax
    14f7:	85 c0                	test   %eax,%eax
    14f9:	75 41                	jne    153c <createdelete+0x118>
          name[1] = '0' + (i / 2);
    14fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
    14fe:	89 c2                	mov    %eax,%edx
    1500:	c1 ea 1f             	shr    $0x1f,%edx
    1503:	01 d0                	add    %edx,%eax
    1505:	d1 f8                	sar    %eax
    1507:	83 c0 30             	add    $0x30,%eax
    150a:	88 45 c9             	mov    %al,-0x37(%ebp)
          if(unlink(name) < 0){
    150d:	8d 45 c8             	lea    -0x38(%ebp),%eax
    1510:	89 04 24             	mov    %eax,(%esp)
    1513:	e8 94 2f 00 00       	call   44ac <unlink>
    1518:	85 c0                	test   %eax,%eax
    151a:	79 20                	jns    153c <createdelete+0x118>
            printf(1, "unlink failed\n");
    151c:	c7 44 24 04 cc 4a 00 	movl   $0x4acc,0x4(%esp)
    1523:	00 
    1524:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    152b:	e8 b3 30 00 00       	call   45e3 <printf>
            exit(EXIT_STATUS_DEFAULT);
    1530:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    1537:	e8 20 2f 00 00       	call   445c <exit>
    }

    if(pid == 0){
      name[0] = 'p' + pi;
      name[2] = '\0';
      for(i = 0; i < N; i++){
    153c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    1540:	83 7d f4 13          	cmpl   $0x13,-0xc(%ebp)
    1544:	0f 8e 51 ff ff ff    	jle    149b <createdelete+0x77>
            printf(1, "unlink failed\n");
            exit(EXIT_STATUS_DEFAULT);
          }
        }
      }
      exit(EXIT_STATUS_DEFAULT);
    154a:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    1551:	e8 06 2f 00 00       	call   445c <exit>
  int pid, i, fd, pi;
  char name[32];

  printf(1, "createdelete test\n");

  for(pi = 0; pi < 4; pi++){
    1556:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
    155a:	83 7d f0 03          	cmpl   $0x3,-0x10(%ebp)
    155e:	0f 8e e6 fe ff ff    	jle    144a <createdelete+0x26>
      }
      exit(EXIT_STATUS_DEFAULT);
    }
  }

  for(pi = 0; pi < 4; pi++){
    1564:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    156b:	eb 10                	jmp    157d <createdelete+0x159>
    wait(0);
    156d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    1574:	e8 eb 2e 00 00       	call   4464 <wait>
      }
      exit(EXIT_STATUS_DEFAULT);
    }
  }

  for(pi = 0; pi < 4; pi++){
    1579:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
    157d:	83 7d f0 03          	cmpl   $0x3,-0x10(%ebp)
    1581:	7e ea                	jle    156d <createdelete+0x149>
    wait(0);
  }

  name[0] = name[1] = name[2] = 0;
    1583:	c6 45 ca 00          	movb   $0x0,-0x36(%ebp)
    1587:	0f b6 45 ca          	movzbl -0x36(%ebp),%eax
    158b:	88 45 c9             	mov    %al,-0x37(%ebp)
    158e:	0f b6 45 c9          	movzbl -0x37(%ebp),%eax
    1592:	88 45 c8             	mov    %al,-0x38(%ebp)
  for(i = 0; i < N; i++){
    1595:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    159c:	e9 c9 00 00 00       	jmp    166a <createdelete+0x246>
    for(pi = 0; pi < 4; pi++){
    15a1:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    15a8:	e9 af 00 00 00       	jmp    165c <createdelete+0x238>
      name[0] = 'p' + pi;
    15ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
    15b0:	83 c0 70             	add    $0x70,%eax
    15b3:	88 45 c8             	mov    %al,-0x38(%ebp)
      name[1] = '0' + i;
    15b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
    15b9:	83 c0 30             	add    $0x30,%eax
    15bc:	88 45 c9             	mov    %al,-0x37(%ebp)
      fd = open(name, 0);
    15bf:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    15c6:	00 
    15c7:	8d 45 c8             	lea    -0x38(%ebp),%eax
    15ca:	89 04 24             	mov    %eax,(%esp)
    15cd:	e8 ca 2e 00 00       	call   449c <open>
    15d2:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((i == 0 || i >= N/2) && fd < 0){
    15d5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    15d9:	74 06                	je     15e1 <createdelete+0x1bd>
    15db:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
    15df:	7e 2d                	jle    160e <createdelete+0x1ea>
    15e1:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
    15e5:	79 27                	jns    160e <createdelete+0x1ea>
        printf(1, "oops createdelete %s didn't exist\n", name);
    15e7:	8d 45 c8             	lea    -0x38(%ebp),%eax
    15ea:	89 44 24 08          	mov    %eax,0x8(%esp)
    15ee:	c7 44 24 04 3c 50 00 	movl   $0x503c,0x4(%esp)
    15f5:	00 
    15f6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    15fd:	e8 e1 2f 00 00       	call   45e3 <printf>
        exit(EXIT_STATUS_DEFAULT);
    1602:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    1609:	e8 4e 2e 00 00       	call   445c <exit>
      } else if((i >= 1 && i < N/2) && fd >= 0){
    160e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    1612:	7e 33                	jle    1647 <createdelete+0x223>
    1614:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
    1618:	7f 2d                	jg     1647 <createdelete+0x223>
    161a:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
    161e:	78 27                	js     1647 <createdelete+0x223>
        printf(1, "oops createdelete %s did exist\n", name);
    1620:	8d 45 c8             	lea    -0x38(%ebp),%eax
    1623:	89 44 24 08          	mov    %eax,0x8(%esp)
    1627:	c7 44 24 04 60 50 00 	movl   $0x5060,0x4(%esp)
    162e:	00 
    162f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1636:	e8 a8 2f 00 00       	call   45e3 <printf>
        exit(EXIT_STATUS_DEFAULT);
    163b:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    1642:	e8 15 2e 00 00       	call   445c <exit>
      }
      if(fd >= 0)
    1647:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
    164b:	78 0b                	js     1658 <createdelete+0x234>
        close(fd);
    164d:	8b 45 e8             	mov    -0x18(%ebp),%eax
    1650:	89 04 24             	mov    %eax,(%esp)
    1653:	e8 2c 2e 00 00       	call   4484 <close>
    wait(0);
  }

  name[0] = name[1] = name[2] = 0;
  for(i = 0; i < N; i++){
    for(pi = 0; pi < 4; pi++){
    1658:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
    165c:	83 7d f0 03          	cmpl   $0x3,-0x10(%ebp)
    1660:	0f 8e 47 ff ff ff    	jle    15ad <createdelete+0x189>
  for(pi = 0; pi < 4; pi++){
    wait(0);
  }

  name[0] = name[1] = name[2] = 0;
  for(i = 0; i < N; i++){
    1666:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    166a:	83 7d f4 13          	cmpl   $0x13,-0xc(%ebp)
    166e:	0f 8e 2d ff ff ff    	jle    15a1 <createdelete+0x17d>
      if(fd >= 0)
        close(fd);
    }
  }

  for(i = 0; i < N; i++){
    1674:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    167b:	eb 34                	jmp    16b1 <createdelete+0x28d>
    for(pi = 0; pi < 4; pi++){
    167d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    1684:	eb 21                	jmp    16a7 <createdelete+0x283>
      name[0] = 'p' + i;
    1686:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1689:	83 c0 70             	add    $0x70,%eax
    168c:	88 45 c8             	mov    %al,-0x38(%ebp)
      name[1] = '0' + i;
    168f:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1692:	83 c0 30             	add    $0x30,%eax
    1695:	88 45 c9             	mov    %al,-0x37(%ebp)
      unlink(name);
    1698:	8d 45 c8             	lea    -0x38(%ebp),%eax
    169b:	89 04 24             	mov    %eax,(%esp)
    169e:	e8 09 2e 00 00       	call   44ac <unlink>
        close(fd);
    }
  }

  for(i = 0; i < N; i++){
    for(pi = 0; pi < 4; pi++){
    16a3:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
    16a7:	83 7d f0 03          	cmpl   $0x3,-0x10(%ebp)
    16ab:	7e d9                	jle    1686 <createdelete+0x262>
      if(fd >= 0)
        close(fd);
    }
  }

  for(i = 0; i < N; i++){
    16ad:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    16b1:	83 7d f4 13          	cmpl   $0x13,-0xc(%ebp)
    16b5:	7e c6                	jle    167d <createdelete+0x259>
      name[1] = '0' + i;
      unlink(name);
    }
  }

  printf(1, "createdelete ok\n");
    16b7:	c7 44 24 04 80 50 00 	movl   $0x5080,0x4(%esp)
    16be:	00 
    16bf:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    16c6:	e8 18 2f 00 00       	call   45e3 <printf>
}
    16cb:	c9                   	leave  
    16cc:	c3                   	ret    

000016cd <unlinkread>:

// can I unlink a file and still read it?
void
unlinkread(void)
{
    16cd:	55                   	push   %ebp
    16ce:	89 e5                	mov    %esp,%ebp
    16d0:	83 ec 28             	sub    $0x28,%esp
  int fd, fd1;

  printf(1, "unlinkread test\n");
    16d3:	c7 44 24 04 91 50 00 	movl   $0x5091,0x4(%esp)
    16da:	00 
    16db:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    16e2:	e8 fc 2e 00 00       	call   45e3 <printf>
  fd = open("unlinkread", O_CREATE | O_RDWR);
    16e7:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
    16ee:	00 
    16ef:	c7 04 24 a2 50 00 00 	movl   $0x50a2,(%esp)
    16f6:	e8 a1 2d 00 00       	call   449c <open>
    16fb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0){
    16fe:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    1702:	79 20                	jns    1724 <unlinkread+0x57>
    printf(1, "create unlinkread failed\n");
    1704:	c7 44 24 04 ad 50 00 	movl   $0x50ad,0x4(%esp)
    170b:	00 
    170c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1713:	e8 cb 2e 00 00       	call   45e3 <printf>
    exit(EXIT_STATUS_DEFAULT);
    1718:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    171f:	e8 38 2d 00 00       	call   445c <exit>
  }
  write(fd, "hello", 5);
    1724:	c7 44 24 08 05 00 00 	movl   $0x5,0x8(%esp)
    172b:	00 
    172c:	c7 44 24 04 c7 50 00 	movl   $0x50c7,0x4(%esp)
    1733:	00 
    1734:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1737:	89 04 24             	mov    %eax,(%esp)
    173a:	e8 3d 2d 00 00       	call   447c <write>
  close(fd);
    173f:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1742:	89 04 24             	mov    %eax,(%esp)
    1745:	e8 3a 2d 00 00       	call   4484 <close>

  fd = open("unlinkread", O_RDWR);
    174a:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
    1751:	00 
    1752:	c7 04 24 a2 50 00 00 	movl   $0x50a2,(%esp)
    1759:	e8 3e 2d 00 00       	call   449c <open>
    175e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0){
    1761:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    1765:	79 20                	jns    1787 <unlinkread+0xba>
    printf(1, "open unlinkread failed\n");
    1767:	c7 44 24 04 cd 50 00 	movl   $0x50cd,0x4(%esp)
    176e:	00 
    176f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1776:	e8 68 2e 00 00       	call   45e3 <printf>
    exit(EXIT_STATUS_DEFAULT);
    177b:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    1782:	e8 d5 2c 00 00       	call   445c <exit>
  }
  if(unlink("unlinkread") != 0){
    1787:	c7 04 24 a2 50 00 00 	movl   $0x50a2,(%esp)
    178e:	e8 19 2d 00 00       	call   44ac <unlink>
    1793:	85 c0                	test   %eax,%eax
    1795:	74 20                	je     17b7 <unlinkread+0xea>
    printf(1, "unlink unlinkread failed\n");
    1797:	c7 44 24 04 e5 50 00 	movl   $0x50e5,0x4(%esp)
    179e:	00 
    179f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    17a6:	e8 38 2e 00 00       	call   45e3 <printf>
    exit(EXIT_STATUS_DEFAULT);
    17ab:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    17b2:	e8 a5 2c 00 00       	call   445c <exit>
  }

  fd1 = open("unlinkread", O_CREATE | O_RDWR);
    17b7:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
    17be:	00 
    17bf:	c7 04 24 a2 50 00 00 	movl   $0x50a2,(%esp)
    17c6:	e8 d1 2c 00 00       	call   449c <open>
    17cb:	89 45 f0             	mov    %eax,-0x10(%ebp)
  write(fd1, "yyy", 3);
    17ce:	c7 44 24 08 03 00 00 	movl   $0x3,0x8(%esp)
    17d5:	00 
    17d6:	c7 44 24 04 ff 50 00 	movl   $0x50ff,0x4(%esp)
    17dd:	00 
    17de:	8b 45 f0             	mov    -0x10(%ebp),%eax
    17e1:	89 04 24             	mov    %eax,(%esp)
    17e4:	e8 93 2c 00 00       	call   447c <write>
  close(fd1);
    17e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
    17ec:	89 04 24             	mov    %eax,(%esp)
    17ef:	e8 90 2c 00 00       	call   4484 <close>

  if(read(fd, buf, sizeof(buf)) != 5){
    17f4:	c7 44 24 08 00 20 00 	movl   $0x2000,0x8(%esp)
    17fb:	00 
    17fc:	c7 44 24 04 60 90 00 	movl   $0x9060,0x4(%esp)
    1803:	00 
    1804:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1807:	89 04 24             	mov    %eax,(%esp)
    180a:	e8 65 2c 00 00       	call   4474 <read>
    180f:	83 f8 05             	cmp    $0x5,%eax
    1812:	74 20                	je     1834 <unlinkread+0x167>
    printf(1, "unlinkread read failed");
    1814:	c7 44 24 04 03 51 00 	movl   $0x5103,0x4(%esp)
    181b:	00 
    181c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1823:	e8 bb 2d 00 00       	call   45e3 <printf>
    exit(EXIT_STATUS_DEFAULT);
    1828:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    182f:	e8 28 2c 00 00       	call   445c <exit>
  }
  if(buf[0] != 'h'){
    1834:	0f b6 05 60 90 00 00 	movzbl 0x9060,%eax
    183b:	3c 68                	cmp    $0x68,%al
    183d:	74 20                	je     185f <unlinkread+0x192>
    printf(1, "unlinkread wrong data\n");
    183f:	c7 44 24 04 1a 51 00 	movl   $0x511a,0x4(%esp)
    1846:	00 
    1847:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    184e:	e8 90 2d 00 00       	call   45e3 <printf>
    exit(EXIT_STATUS_DEFAULT);
    1853:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    185a:	e8 fd 2b 00 00       	call   445c <exit>
  }
  if(write(fd, buf, 10) != 10){
    185f:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
    1866:	00 
    1867:	c7 44 24 04 60 90 00 	movl   $0x9060,0x4(%esp)
    186e:	00 
    186f:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1872:	89 04 24             	mov    %eax,(%esp)
    1875:	e8 02 2c 00 00       	call   447c <write>
    187a:	83 f8 0a             	cmp    $0xa,%eax
    187d:	74 20                	je     189f <unlinkread+0x1d2>
    printf(1, "unlinkread write failed\n");
    187f:	c7 44 24 04 31 51 00 	movl   $0x5131,0x4(%esp)
    1886:	00 
    1887:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    188e:	e8 50 2d 00 00       	call   45e3 <printf>
    exit(EXIT_STATUS_DEFAULT);
    1893:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    189a:	e8 bd 2b 00 00       	call   445c <exit>
  }
  close(fd);
    189f:	8b 45 f4             	mov    -0xc(%ebp),%eax
    18a2:	89 04 24             	mov    %eax,(%esp)
    18a5:	e8 da 2b 00 00       	call   4484 <close>
  unlink("unlinkread");
    18aa:	c7 04 24 a2 50 00 00 	movl   $0x50a2,(%esp)
    18b1:	e8 f6 2b 00 00       	call   44ac <unlink>
  printf(1, "unlinkread ok\n");
    18b6:	c7 44 24 04 4a 51 00 	movl   $0x514a,0x4(%esp)
    18bd:	00 
    18be:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    18c5:	e8 19 2d 00 00       	call   45e3 <printf>
}
    18ca:	c9                   	leave  
    18cb:	c3                   	ret    

000018cc <linktest>:

void
linktest(void)
{
    18cc:	55                   	push   %ebp
    18cd:	89 e5                	mov    %esp,%ebp
    18cf:	83 ec 28             	sub    $0x28,%esp
  int fd;

  printf(1, "linktest\n");
    18d2:	c7 44 24 04 59 51 00 	movl   $0x5159,0x4(%esp)
    18d9:	00 
    18da:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    18e1:	e8 fd 2c 00 00       	call   45e3 <printf>

  unlink("lf1");
    18e6:	c7 04 24 63 51 00 00 	movl   $0x5163,(%esp)
    18ed:	e8 ba 2b 00 00       	call   44ac <unlink>
  unlink("lf2");
    18f2:	c7 04 24 67 51 00 00 	movl   $0x5167,(%esp)
    18f9:	e8 ae 2b 00 00       	call   44ac <unlink>

  fd = open("lf1", O_CREATE|O_RDWR);
    18fe:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
    1905:	00 
    1906:	c7 04 24 63 51 00 00 	movl   $0x5163,(%esp)
    190d:	e8 8a 2b 00 00       	call   449c <open>
    1912:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0){
    1915:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    1919:	79 20                	jns    193b <linktest+0x6f>
    printf(1, "create lf1 failed\n");
    191b:	c7 44 24 04 6b 51 00 	movl   $0x516b,0x4(%esp)
    1922:	00 
    1923:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    192a:	e8 b4 2c 00 00       	call   45e3 <printf>
    exit(EXIT_STATUS_DEFAULT);
    192f:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    1936:	e8 21 2b 00 00       	call   445c <exit>
  }
  if(write(fd, "hello", 5) != 5){
    193b:	c7 44 24 08 05 00 00 	movl   $0x5,0x8(%esp)
    1942:	00 
    1943:	c7 44 24 04 c7 50 00 	movl   $0x50c7,0x4(%esp)
    194a:	00 
    194b:	8b 45 f4             	mov    -0xc(%ebp),%eax
    194e:	89 04 24             	mov    %eax,(%esp)
    1951:	e8 26 2b 00 00       	call   447c <write>
    1956:	83 f8 05             	cmp    $0x5,%eax
    1959:	74 20                	je     197b <linktest+0xaf>
    printf(1, "write lf1 failed\n");
    195b:	c7 44 24 04 7e 51 00 	movl   $0x517e,0x4(%esp)
    1962:	00 
    1963:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    196a:	e8 74 2c 00 00       	call   45e3 <printf>
    exit(EXIT_STATUS_DEFAULT);
    196f:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    1976:	e8 e1 2a 00 00       	call   445c <exit>
  }
  close(fd);
    197b:	8b 45 f4             	mov    -0xc(%ebp),%eax
    197e:	89 04 24             	mov    %eax,(%esp)
    1981:	e8 fe 2a 00 00       	call   4484 <close>

  if(link("lf1", "lf2") < 0){
    1986:	c7 44 24 04 67 51 00 	movl   $0x5167,0x4(%esp)
    198d:	00 
    198e:	c7 04 24 63 51 00 00 	movl   $0x5163,(%esp)
    1995:	e8 22 2b 00 00       	call   44bc <link>
    199a:	85 c0                	test   %eax,%eax
    199c:	79 20                	jns    19be <linktest+0xf2>
    printf(1, "link lf1 lf2 failed\n");
    199e:	c7 44 24 04 90 51 00 	movl   $0x5190,0x4(%esp)
    19a5:	00 
    19a6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    19ad:	e8 31 2c 00 00       	call   45e3 <printf>
    exit(EXIT_STATUS_DEFAULT);
    19b2:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    19b9:	e8 9e 2a 00 00       	call   445c <exit>
  }
  unlink("lf1");
    19be:	c7 04 24 63 51 00 00 	movl   $0x5163,(%esp)
    19c5:	e8 e2 2a 00 00       	call   44ac <unlink>

  if(open("lf1", 0) >= 0){
    19ca:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    19d1:	00 
    19d2:	c7 04 24 63 51 00 00 	movl   $0x5163,(%esp)
    19d9:	e8 be 2a 00 00       	call   449c <open>
    19de:	85 c0                	test   %eax,%eax
    19e0:	78 20                	js     1a02 <linktest+0x136>
    printf(1, "unlinked lf1 but it is still there!\n");
    19e2:	c7 44 24 04 a8 51 00 	movl   $0x51a8,0x4(%esp)
    19e9:	00 
    19ea:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    19f1:	e8 ed 2b 00 00       	call   45e3 <printf>
    exit(EXIT_STATUS_DEFAULT);
    19f6:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    19fd:	e8 5a 2a 00 00       	call   445c <exit>
  }

  fd = open("lf2", 0);
    1a02:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    1a09:	00 
    1a0a:	c7 04 24 67 51 00 00 	movl   $0x5167,(%esp)
    1a11:	e8 86 2a 00 00       	call   449c <open>
    1a16:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0){
    1a19:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    1a1d:	79 20                	jns    1a3f <linktest+0x173>
    printf(1, "open lf2 failed\n");
    1a1f:	c7 44 24 04 cd 51 00 	movl   $0x51cd,0x4(%esp)
    1a26:	00 
    1a27:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1a2e:	e8 b0 2b 00 00       	call   45e3 <printf>
    exit(EXIT_STATUS_DEFAULT);
    1a33:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    1a3a:	e8 1d 2a 00 00       	call   445c <exit>
  }
  if(read(fd, buf, sizeof(buf)) != 5){
    1a3f:	c7 44 24 08 00 20 00 	movl   $0x2000,0x8(%esp)
    1a46:	00 
    1a47:	c7 44 24 04 60 90 00 	movl   $0x9060,0x4(%esp)
    1a4e:	00 
    1a4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1a52:	89 04 24             	mov    %eax,(%esp)
    1a55:	e8 1a 2a 00 00       	call   4474 <read>
    1a5a:	83 f8 05             	cmp    $0x5,%eax
    1a5d:	74 20                	je     1a7f <linktest+0x1b3>
    printf(1, "read lf2 failed\n");
    1a5f:	c7 44 24 04 de 51 00 	movl   $0x51de,0x4(%esp)
    1a66:	00 
    1a67:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1a6e:	e8 70 2b 00 00       	call   45e3 <printf>
    exit(EXIT_STATUS_DEFAULT);
    1a73:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    1a7a:	e8 dd 29 00 00       	call   445c <exit>
  }
  close(fd);
    1a7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1a82:	89 04 24             	mov    %eax,(%esp)
    1a85:	e8 fa 29 00 00       	call   4484 <close>

  if(link("lf2", "lf2") >= 0){
    1a8a:	c7 44 24 04 67 51 00 	movl   $0x5167,0x4(%esp)
    1a91:	00 
    1a92:	c7 04 24 67 51 00 00 	movl   $0x5167,(%esp)
    1a99:	e8 1e 2a 00 00       	call   44bc <link>
    1a9e:	85 c0                	test   %eax,%eax
    1aa0:	78 20                	js     1ac2 <linktest+0x1f6>
    printf(1, "link lf2 lf2 succeeded! oops\n");
    1aa2:	c7 44 24 04 ef 51 00 	movl   $0x51ef,0x4(%esp)
    1aa9:	00 
    1aaa:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1ab1:	e8 2d 2b 00 00       	call   45e3 <printf>
    exit(EXIT_STATUS_DEFAULT);
    1ab6:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    1abd:	e8 9a 29 00 00       	call   445c <exit>
  }

  unlink("lf2");
    1ac2:	c7 04 24 67 51 00 00 	movl   $0x5167,(%esp)
    1ac9:	e8 de 29 00 00       	call   44ac <unlink>
  if(link("lf2", "lf1") >= 0){
    1ace:	c7 44 24 04 63 51 00 	movl   $0x5163,0x4(%esp)
    1ad5:	00 
    1ad6:	c7 04 24 67 51 00 00 	movl   $0x5167,(%esp)
    1add:	e8 da 29 00 00       	call   44bc <link>
    1ae2:	85 c0                	test   %eax,%eax
    1ae4:	78 20                	js     1b06 <linktest+0x23a>
    printf(1, "link non-existant succeeded! oops\n");
    1ae6:	c7 44 24 04 10 52 00 	movl   $0x5210,0x4(%esp)
    1aed:	00 
    1aee:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1af5:	e8 e9 2a 00 00       	call   45e3 <printf>
    exit(EXIT_STATUS_DEFAULT);
    1afa:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    1b01:	e8 56 29 00 00       	call   445c <exit>
  }

  if(link(".", "lf1") >= 0){
    1b06:	c7 44 24 04 63 51 00 	movl   $0x5163,0x4(%esp)
    1b0d:	00 
    1b0e:	c7 04 24 33 52 00 00 	movl   $0x5233,(%esp)
    1b15:	e8 a2 29 00 00       	call   44bc <link>
    1b1a:	85 c0                	test   %eax,%eax
    1b1c:	78 20                	js     1b3e <linktest+0x272>
    printf(1, "link . lf1 succeeded! oops\n");
    1b1e:	c7 44 24 04 35 52 00 	movl   $0x5235,0x4(%esp)
    1b25:	00 
    1b26:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1b2d:	e8 b1 2a 00 00       	call   45e3 <printf>
    exit(EXIT_STATUS_DEFAULT);
    1b32:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    1b39:	e8 1e 29 00 00       	call   445c <exit>
  }

  printf(1, "linktest ok\n");
    1b3e:	c7 44 24 04 51 52 00 	movl   $0x5251,0x4(%esp)
    1b45:	00 
    1b46:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1b4d:	e8 91 2a 00 00       	call   45e3 <printf>
}
    1b52:	c9                   	leave  
    1b53:	c3                   	ret    

00001b54 <concreate>:

// test concurrent create/link/unlink of the same file
void
concreate(void)
{
    1b54:	55                   	push   %ebp
    1b55:	89 e5                	mov    %esp,%ebp
    1b57:	83 ec 68             	sub    $0x68,%esp
  struct {
    ushort inum;
    char name[14];
  } de;

  printf(1, "concreate test\n");
    1b5a:	c7 44 24 04 5e 52 00 	movl   $0x525e,0x4(%esp)
    1b61:	00 
    1b62:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1b69:	e8 75 2a 00 00       	call   45e3 <printf>
  file[0] = 'C';
    1b6e:	c6 45 e5 43          	movb   $0x43,-0x1b(%ebp)
  file[2] = '\0';
    1b72:	c6 45 e7 00          	movb   $0x0,-0x19(%ebp)
  for(i = 0; i < 40; i++){
    1b76:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    1b7d:	e9 0c 01 00 00       	jmp    1c8e <concreate+0x13a>
    file[1] = '0' + i;
    1b82:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1b85:	83 c0 30             	add    $0x30,%eax
    1b88:	88 45 e6             	mov    %al,-0x1a(%ebp)
    unlink(file);
    1b8b:	8d 45 e5             	lea    -0x1b(%ebp),%eax
    1b8e:	89 04 24             	mov    %eax,(%esp)
    1b91:	e8 16 29 00 00       	call   44ac <unlink>
    pid = fork();
    1b96:	e8 b9 28 00 00       	call   4454 <fork>
    1b9b:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(pid && (i % 3) == 1){
    1b9e:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    1ba2:	74 3a                	je     1bde <concreate+0x8a>
    1ba4:	8b 4d f4             	mov    -0xc(%ebp),%ecx
    1ba7:	ba 56 55 55 55       	mov    $0x55555556,%edx
    1bac:	89 c8                	mov    %ecx,%eax
    1bae:	f7 ea                	imul   %edx
    1bb0:	89 c8                	mov    %ecx,%eax
    1bb2:	c1 f8 1f             	sar    $0x1f,%eax
    1bb5:	29 c2                	sub    %eax,%edx
    1bb7:	89 d0                	mov    %edx,%eax
    1bb9:	01 c0                	add    %eax,%eax
    1bbb:	01 d0                	add    %edx,%eax
    1bbd:	89 ca                	mov    %ecx,%edx
    1bbf:	29 c2                	sub    %eax,%edx
    1bc1:	83 fa 01             	cmp    $0x1,%edx
    1bc4:	75 18                	jne    1bde <concreate+0x8a>
      link("C0", file);
    1bc6:	8d 45 e5             	lea    -0x1b(%ebp),%eax
    1bc9:	89 44 24 04          	mov    %eax,0x4(%esp)
    1bcd:	c7 04 24 6e 52 00 00 	movl   $0x526e,(%esp)
    1bd4:	e8 e3 28 00 00       	call   44bc <link>
    1bd9:	e9 8e 00 00 00       	jmp    1c6c <concreate+0x118>
    } else if(pid == 0 && (i % 5) == 1){
    1bde:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    1be2:	75 3a                	jne    1c1e <concreate+0xca>
    1be4:	8b 4d f4             	mov    -0xc(%ebp),%ecx
    1be7:	ba 67 66 66 66       	mov    $0x66666667,%edx
    1bec:	89 c8                	mov    %ecx,%eax
    1bee:	f7 ea                	imul   %edx
    1bf0:	d1 fa                	sar    %edx
    1bf2:	89 c8                	mov    %ecx,%eax
    1bf4:	c1 f8 1f             	sar    $0x1f,%eax
    1bf7:	29 c2                	sub    %eax,%edx
    1bf9:	89 d0                	mov    %edx,%eax
    1bfb:	c1 e0 02             	shl    $0x2,%eax
    1bfe:	01 d0                	add    %edx,%eax
    1c00:	89 ca                	mov    %ecx,%edx
    1c02:	29 c2                	sub    %eax,%edx
    1c04:	83 fa 01             	cmp    $0x1,%edx
    1c07:	75 15                	jne    1c1e <concreate+0xca>
      link("C0", file);
    1c09:	8d 45 e5             	lea    -0x1b(%ebp),%eax
    1c0c:	89 44 24 04          	mov    %eax,0x4(%esp)
    1c10:	c7 04 24 6e 52 00 00 	movl   $0x526e,(%esp)
    1c17:	e8 a0 28 00 00       	call   44bc <link>
    1c1c:	eb 4e                	jmp    1c6c <concreate+0x118>
    } else {
      fd = open(file, O_CREATE | O_RDWR);
    1c1e:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
    1c25:	00 
    1c26:	8d 45 e5             	lea    -0x1b(%ebp),%eax
    1c29:	89 04 24             	mov    %eax,(%esp)
    1c2c:	e8 6b 28 00 00       	call   449c <open>
    1c31:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if(fd < 0){
    1c34:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
    1c38:	79 27                	jns    1c61 <concreate+0x10d>
        printf(1, "concreate create %s failed\n", file);
    1c3a:	8d 45 e5             	lea    -0x1b(%ebp),%eax
    1c3d:	89 44 24 08          	mov    %eax,0x8(%esp)
    1c41:	c7 44 24 04 71 52 00 	movl   $0x5271,0x4(%esp)
    1c48:	00 
    1c49:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1c50:	e8 8e 29 00 00       	call   45e3 <printf>
        exit(EXIT_STATUS_DEFAULT);
    1c55:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    1c5c:	e8 fb 27 00 00       	call   445c <exit>
      }
      close(fd);
    1c61:	8b 45 e8             	mov    -0x18(%ebp),%eax
    1c64:	89 04 24             	mov    %eax,(%esp)
    1c67:	e8 18 28 00 00       	call   4484 <close>
    }
    if(pid == 0)
    1c6c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    1c70:	75 0c                	jne    1c7e <concreate+0x12a>
      exit(EXIT_STATUS_DEFAULT);
    1c72:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    1c79:	e8 de 27 00 00       	call   445c <exit>
    else
      wait(0);
    1c7e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    1c85:	e8 da 27 00 00       	call   4464 <wait>
  } de;

  printf(1, "concreate test\n");
  file[0] = 'C';
  file[2] = '\0';
  for(i = 0; i < 40; i++){
    1c8a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    1c8e:	83 7d f4 27          	cmpl   $0x27,-0xc(%ebp)
    1c92:	0f 8e ea fe ff ff    	jle    1b82 <concreate+0x2e>
      exit(EXIT_STATUS_DEFAULT);
    else
      wait(0);
  }

  memset(fa, 0, sizeof(fa));
    1c98:	c7 44 24 08 28 00 00 	movl   $0x28,0x8(%esp)
    1c9f:	00 
    1ca0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    1ca7:	00 
    1ca8:	8d 45 bd             	lea    -0x43(%ebp),%eax
    1cab:	89 04 24             	mov    %eax,(%esp)
    1cae:	e8 04 26 00 00       	call   42b7 <memset>
  fd = open(".", 0);
    1cb3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    1cba:	00 
    1cbb:	c7 04 24 33 52 00 00 	movl   $0x5233,(%esp)
    1cc2:	e8 d5 27 00 00       	call   449c <open>
    1cc7:	89 45 e8             	mov    %eax,-0x18(%ebp)
  n = 0;
    1cca:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  while(read(fd, &de, sizeof(de)) > 0){
    1cd1:	e9 b1 00 00 00       	jmp    1d87 <concreate+0x233>
    if(de.inum == 0)
    1cd6:	0f b7 45 ac          	movzwl -0x54(%ebp),%eax
    1cda:	66 85 c0             	test   %ax,%ax
    1cdd:	0f 84 a3 00 00 00    	je     1d86 <concreate+0x232>
      continue;
    if(de.name[0] == 'C' && de.name[2] == '\0'){
    1ce3:	0f b6 45 ae          	movzbl -0x52(%ebp),%eax
    1ce7:	3c 43                	cmp    $0x43,%al
    1ce9:	0f 85 98 00 00 00    	jne    1d87 <concreate+0x233>
    1cef:	0f b6 45 b0          	movzbl -0x50(%ebp),%eax
    1cf3:	84 c0                	test   %al,%al
    1cf5:	0f 85 8c 00 00 00    	jne    1d87 <concreate+0x233>
      i = de.name[1] - '0';
    1cfb:	0f b6 45 af          	movzbl -0x51(%ebp),%eax
    1cff:	0f be c0             	movsbl %al,%eax
    1d02:	83 e8 30             	sub    $0x30,%eax
    1d05:	89 45 f4             	mov    %eax,-0xc(%ebp)
      if(i < 0 || i >= sizeof(fa)){
    1d08:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    1d0c:	78 08                	js     1d16 <concreate+0x1c2>
    1d0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1d11:	83 f8 27             	cmp    $0x27,%eax
    1d14:	76 2a                	jbe    1d40 <concreate+0x1ec>
        printf(1, "concreate weird file %s\n", de.name);
    1d16:	8d 45 ac             	lea    -0x54(%ebp),%eax
    1d19:	83 c0 02             	add    $0x2,%eax
    1d1c:	89 44 24 08          	mov    %eax,0x8(%esp)
    1d20:	c7 44 24 04 8d 52 00 	movl   $0x528d,0x4(%esp)
    1d27:	00 
    1d28:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1d2f:	e8 af 28 00 00       	call   45e3 <printf>
        exit(EXIT_STATUS_DEFAULT);
    1d34:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    1d3b:	e8 1c 27 00 00       	call   445c <exit>
      }
      if(fa[i]){
    1d40:	8d 45 bd             	lea    -0x43(%ebp),%eax
    1d43:	03 45 f4             	add    -0xc(%ebp),%eax
    1d46:	0f b6 00             	movzbl (%eax),%eax
    1d49:	84 c0                	test   %al,%al
    1d4b:	74 2a                	je     1d77 <concreate+0x223>
        printf(1, "concreate duplicate file %s\n", de.name);
    1d4d:	8d 45 ac             	lea    -0x54(%ebp),%eax
    1d50:	83 c0 02             	add    $0x2,%eax
    1d53:	89 44 24 08          	mov    %eax,0x8(%esp)
    1d57:	c7 44 24 04 a6 52 00 	movl   $0x52a6,0x4(%esp)
    1d5e:	00 
    1d5f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1d66:	e8 78 28 00 00       	call   45e3 <printf>
        exit(EXIT_STATUS_DEFAULT);
    1d6b:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    1d72:	e8 e5 26 00 00       	call   445c <exit>
      }
      fa[i] = 1;
    1d77:	8d 45 bd             	lea    -0x43(%ebp),%eax
    1d7a:	03 45 f4             	add    -0xc(%ebp),%eax
    1d7d:	c6 00 01             	movb   $0x1,(%eax)
      n++;
    1d80:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
    1d84:	eb 01                	jmp    1d87 <concreate+0x233>
  memset(fa, 0, sizeof(fa));
  fd = open(".", 0);
  n = 0;
  while(read(fd, &de, sizeof(de)) > 0){
    if(de.inum == 0)
      continue;
    1d86:	90                   	nop
  }

  memset(fa, 0, sizeof(fa));
  fd = open(".", 0);
  n = 0;
  while(read(fd, &de, sizeof(de)) > 0){
    1d87:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
    1d8e:	00 
    1d8f:	8d 45 ac             	lea    -0x54(%ebp),%eax
    1d92:	89 44 24 04          	mov    %eax,0x4(%esp)
    1d96:	8b 45 e8             	mov    -0x18(%ebp),%eax
    1d99:	89 04 24             	mov    %eax,(%esp)
    1d9c:	e8 d3 26 00 00       	call   4474 <read>
    1da1:	85 c0                	test   %eax,%eax
    1da3:	0f 8f 2d ff ff ff    	jg     1cd6 <concreate+0x182>
      }
      fa[i] = 1;
      n++;
    }
  }
  close(fd);
    1da9:	8b 45 e8             	mov    -0x18(%ebp),%eax
    1dac:	89 04 24             	mov    %eax,(%esp)
    1daf:	e8 d0 26 00 00       	call   4484 <close>

  if(n != 40){
    1db4:	83 7d f0 28          	cmpl   $0x28,-0x10(%ebp)
    1db8:	74 20                	je     1dda <concreate+0x286>
    printf(1, "concreate not enough files in directory listing\n");
    1dba:	c7 44 24 04 c4 52 00 	movl   $0x52c4,0x4(%esp)
    1dc1:	00 
    1dc2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1dc9:	e8 15 28 00 00       	call   45e3 <printf>
    exit(EXIT_STATUS_DEFAULT);
    1dce:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    1dd5:	e8 82 26 00 00       	call   445c <exit>
  }

  for(i = 0; i < 40; i++){
    1dda:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    1de1:	e9 42 01 00 00       	jmp    1f28 <concreate+0x3d4>
    file[1] = '0' + i;
    1de6:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1de9:	83 c0 30             	add    $0x30,%eax
    1dec:	88 45 e6             	mov    %al,-0x1a(%ebp)
    pid = fork();
    1def:	e8 60 26 00 00       	call   4454 <fork>
    1df4:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(pid < 0){
    1df7:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    1dfb:	79 20                	jns    1e1d <concreate+0x2c9>
      printf(1, "fork failed\n");
    1dfd:	c7 44 24 04 49 4a 00 	movl   $0x4a49,0x4(%esp)
    1e04:	00 
    1e05:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1e0c:	e8 d2 27 00 00       	call   45e3 <printf>
      exit(EXIT_STATUS_DEFAULT);
    1e11:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    1e18:	e8 3f 26 00 00       	call   445c <exit>
    }
    if(((i % 3) == 0 && pid == 0) ||
    1e1d:	8b 4d f4             	mov    -0xc(%ebp),%ecx
    1e20:	ba 56 55 55 55       	mov    $0x55555556,%edx
    1e25:	89 c8                	mov    %ecx,%eax
    1e27:	f7 ea                	imul   %edx
    1e29:	89 c8                	mov    %ecx,%eax
    1e2b:	c1 f8 1f             	sar    $0x1f,%eax
    1e2e:	29 c2                	sub    %eax,%edx
    1e30:	89 d0                	mov    %edx,%eax
    1e32:	01 c0                	add    %eax,%eax
    1e34:	01 d0                	add    %edx,%eax
    1e36:	89 ca                	mov    %ecx,%edx
    1e38:	29 c2                	sub    %eax,%edx
    1e3a:	85 d2                	test   %edx,%edx
    1e3c:	75 06                	jne    1e44 <concreate+0x2f0>
    1e3e:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    1e42:	74 28                	je     1e6c <concreate+0x318>
       ((i % 3) == 1 && pid != 0)){
    1e44:	8b 4d f4             	mov    -0xc(%ebp),%ecx
    1e47:	ba 56 55 55 55       	mov    $0x55555556,%edx
    1e4c:	89 c8                	mov    %ecx,%eax
    1e4e:	f7 ea                	imul   %edx
    1e50:	89 c8                	mov    %ecx,%eax
    1e52:	c1 f8 1f             	sar    $0x1f,%eax
    1e55:	29 c2                	sub    %eax,%edx
    1e57:	89 d0                	mov    %edx,%eax
    1e59:	01 c0                	add    %eax,%eax
    1e5b:	01 d0                	add    %edx,%eax
    1e5d:	89 ca                	mov    %ecx,%edx
    1e5f:	29 c2                	sub    %eax,%edx
    pid = fork();
    if(pid < 0){
      printf(1, "fork failed\n");
      exit(EXIT_STATUS_DEFAULT);
    }
    if(((i % 3) == 0 && pid == 0) ||
    1e61:	83 fa 01             	cmp    $0x1,%edx
    1e64:	75 74                	jne    1eda <concreate+0x386>
       ((i % 3) == 1 && pid != 0)){
    1e66:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    1e6a:	74 6e                	je     1eda <concreate+0x386>
      close(open(file, 0));
    1e6c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    1e73:	00 
    1e74:	8d 45 e5             	lea    -0x1b(%ebp),%eax
    1e77:	89 04 24             	mov    %eax,(%esp)
    1e7a:	e8 1d 26 00 00       	call   449c <open>
    1e7f:	89 04 24             	mov    %eax,(%esp)
    1e82:	e8 fd 25 00 00       	call   4484 <close>
      close(open(file, 0));
    1e87:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    1e8e:	00 
    1e8f:	8d 45 e5             	lea    -0x1b(%ebp),%eax
    1e92:	89 04 24             	mov    %eax,(%esp)
    1e95:	e8 02 26 00 00       	call   449c <open>
    1e9a:	89 04 24             	mov    %eax,(%esp)
    1e9d:	e8 e2 25 00 00       	call   4484 <close>
      close(open(file, 0));
    1ea2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    1ea9:	00 
    1eaa:	8d 45 e5             	lea    -0x1b(%ebp),%eax
    1ead:	89 04 24             	mov    %eax,(%esp)
    1eb0:	e8 e7 25 00 00       	call   449c <open>
    1eb5:	89 04 24             	mov    %eax,(%esp)
    1eb8:	e8 c7 25 00 00       	call   4484 <close>
      close(open(file, 0));
    1ebd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    1ec4:	00 
    1ec5:	8d 45 e5             	lea    -0x1b(%ebp),%eax
    1ec8:	89 04 24             	mov    %eax,(%esp)
    1ecb:	e8 cc 25 00 00       	call   449c <open>
    1ed0:	89 04 24             	mov    %eax,(%esp)
    1ed3:	e8 ac 25 00 00       	call   4484 <close>
    1ed8:	eb 2c                	jmp    1f06 <concreate+0x3b2>
    } else {
      unlink(file);
    1eda:	8d 45 e5             	lea    -0x1b(%ebp),%eax
    1edd:	89 04 24             	mov    %eax,(%esp)
    1ee0:	e8 c7 25 00 00       	call   44ac <unlink>
      unlink(file);
    1ee5:	8d 45 e5             	lea    -0x1b(%ebp),%eax
    1ee8:	89 04 24             	mov    %eax,(%esp)
    1eeb:	e8 bc 25 00 00       	call   44ac <unlink>
      unlink(file);
    1ef0:	8d 45 e5             	lea    -0x1b(%ebp),%eax
    1ef3:	89 04 24             	mov    %eax,(%esp)
    1ef6:	e8 b1 25 00 00       	call   44ac <unlink>
      unlink(file);
    1efb:	8d 45 e5             	lea    -0x1b(%ebp),%eax
    1efe:	89 04 24             	mov    %eax,(%esp)
    1f01:	e8 a6 25 00 00       	call   44ac <unlink>
    }
    if(pid == 0)
    1f06:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    1f0a:	75 0c                	jne    1f18 <concreate+0x3c4>
      exit(EXIT_STATUS_DEFAULT);
    1f0c:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    1f13:	e8 44 25 00 00       	call   445c <exit>
    else
      wait(0);
    1f18:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    1f1f:	e8 40 25 00 00       	call   4464 <wait>
  if(n != 40){
    printf(1, "concreate not enough files in directory listing\n");
    exit(EXIT_STATUS_DEFAULT);
  }

  for(i = 0; i < 40; i++){
    1f24:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    1f28:	83 7d f4 27          	cmpl   $0x27,-0xc(%ebp)
    1f2c:	0f 8e b4 fe ff ff    	jle    1de6 <concreate+0x292>
      exit(EXIT_STATUS_DEFAULT);
    else
      wait(0);
  }

  printf(1, "concreate ok\n");
    1f32:	c7 44 24 04 f5 52 00 	movl   $0x52f5,0x4(%esp)
    1f39:	00 
    1f3a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1f41:	e8 9d 26 00 00       	call   45e3 <printf>
}
    1f46:	c9                   	leave  
    1f47:	c3                   	ret    

00001f48 <linkunlink>:

// another concurrent link/unlink/create test,
// to look for deadlocks.
void
linkunlink()
{
    1f48:	55                   	push   %ebp
    1f49:	89 e5                	mov    %esp,%ebp
    1f4b:	83 ec 28             	sub    $0x28,%esp
  int pid, i;

  printf(1, "linkunlink test\n");
    1f4e:	c7 44 24 04 03 53 00 	movl   $0x5303,0x4(%esp)
    1f55:	00 
    1f56:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1f5d:	e8 81 26 00 00       	call   45e3 <printf>

  unlink("x");
    1f62:	c7 04 24 7f 4e 00 00 	movl   $0x4e7f,(%esp)
    1f69:	e8 3e 25 00 00       	call   44ac <unlink>
  pid = fork();
    1f6e:	e8 e1 24 00 00       	call   4454 <fork>
    1f73:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(pid < 0){
    1f76:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    1f7a:	79 20                	jns    1f9c <linkunlink+0x54>
    printf(1, "fork failed\n");
    1f7c:	c7 44 24 04 49 4a 00 	movl   $0x4a49,0x4(%esp)
    1f83:	00 
    1f84:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1f8b:	e8 53 26 00 00       	call   45e3 <printf>
    exit(EXIT_STATUS_DEFAULT);
    1f90:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    1f97:	e8 c0 24 00 00       	call   445c <exit>
  }

  unsigned int x = (pid ? 1 : 97);
    1f9c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    1fa0:	74 07                	je     1fa9 <linkunlink+0x61>
    1fa2:	b8 01 00 00 00       	mov    $0x1,%eax
    1fa7:	eb 05                	jmp    1fae <linkunlink+0x66>
    1fa9:	b8 61 00 00 00       	mov    $0x61,%eax
    1fae:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(i = 0; i < 100; i++){
    1fb1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    1fb8:	e9 8e 00 00 00       	jmp    204b <linkunlink+0x103>
    x = x * 1103515245 + 12345;
    1fbd:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1fc0:	69 c0 6d 4e c6 41    	imul   $0x41c64e6d,%eax,%eax
    1fc6:	05 39 30 00 00       	add    $0x3039,%eax
    1fcb:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((x % 3) == 0){
    1fce:	8b 4d f0             	mov    -0x10(%ebp),%ecx
    1fd1:	ba ab aa aa aa       	mov    $0xaaaaaaab,%edx
    1fd6:	89 c8                	mov    %ecx,%eax
    1fd8:	f7 e2                	mul    %edx
    1fda:	d1 ea                	shr    %edx
    1fdc:	89 d0                	mov    %edx,%eax
    1fde:	01 c0                	add    %eax,%eax
    1fe0:	01 d0                	add    %edx,%eax
    1fe2:	89 ca                	mov    %ecx,%edx
    1fe4:	29 c2                	sub    %eax,%edx
    1fe6:	85 d2                	test   %edx,%edx
    1fe8:	75 1e                	jne    2008 <linkunlink+0xc0>
      close(open("x", O_RDWR | O_CREATE));
    1fea:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
    1ff1:	00 
    1ff2:	c7 04 24 7f 4e 00 00 	movl   $0x4e7f,(%esp)
    1ff9:	e8 9e 24 00 00       	call   449c <open>
    1ffe:	89 04 24             	mov    %eax,(%esp)
    2001:	e8 7e 24 00 00       	call   4484 <close>
    2006:	eb 3f                	jmp    2047 <linkunlink+0xff>
    } else if((x % 3) == 1){
    2008:	8b 4d f0             	mov    -0x10(%ebp),%ecx
    200b:	ba ab aa aa aa       	mov    $0xaaaaaaab,%edx
    2010:	89 c8                	mov    %ecx,%eax
    2012:	f7 e2                	mul    %edx
    2014:	d1 ea                	shr    %edx
    2016:	89 d0                	mov    %edx,%eax
    2018:	01 c0                	add    %eax,%eax
    201a:	01 d0                	add    %edx,%eax
    201c:	89 ca                	mov    %ecx,%edx
    201e:	29 c2                	sub    %eax,%edx
    2020:	83 fa 01             	cmp    $0x1,%edx
    2023:	75 16                	jne    203b <linkunlink+0xf3>
      link("cat", "x");
    2025:	c7 44 24 04 7f 4e 00 	movl   $0x4e7f,0x4(%esp)
    202c:	00 
    202d:	c7 04 24 14 53 00 00 	movl   $0x5314,(%esp)
    2034:	e8 83 24 00 00       	call   44bc <link>
    2039:	eb 0c                	jmp    2047 <linkunlink+0xff>
    } else {
      unlink("x");
    203b:	c7 04 24 7f 4e 00 00 	movl   $0x4e7f,(%esp)
    2042:	e8 65 24 00 00       	call   44ac <unlink>
    printf(1, "fork failed\n");
    exit(EXIT_STATUS_DEFAULT);
  }

  unsigned int x = (pid ? 1 : 97);
  for(i = 0; i < 100; i++){
    2047:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    204b:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
    204f:	0f 8e 68 ff ff ff    	jle    1fbd <linkunlink+0x75>
    } else {
      unlink("x");
    }
  }

  if(pid)
    2055:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    2059:	74 22                	je     207d <linkunlink+0x135>
    wait(0);
    205b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    2062:	e8 fd 23 00 00       	call   4464 <wait>
  else 
    exit(EXIT_STATUS_DEFAULT);

  printf(1, "linkunlink ok\n");
    2067:	c7 44 24 04 18 53 00 	movl   $0x5318,0x4(%esp)
    206e:	00 
    206f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2076:	e8 68 25 00 00       	call   45e3 <printf>
}
    207b:	c9                   	leave  
    207c:	c3                   	ret    
  }

  if(pid)
    wait(0);
  else 
    exit(EXIT_STATUS_DEFAULT);
    207d:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    2084:	e8 d3 23 00 00       	call   445c <exit>

00002089 <bigdir>:
}

// directory that uses indirect blocks
void
bigdir(void)
{
    2089:	55                   	push   %ebp
    208a:	89 e5                	mov    %esp,%ebp
    208c:	83 ec 38             	sub    $0x38,%esp
  int i, fd;
  char name[10];

  printf(1, "bigdir test\n");
    208f:	c7 44 24 04 27 53 00 	movl   $0x5327,0x4(%esp)
    2096:	00 
    2097:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    209e:	e8 40 25 00 00       	call   45e3 <printf>
  unlink("bd");
    20a3:	c7 04 24 34 53 00 00 	movl   $0x5334,(%esp)
    20aa:	e8 fd 23 00 00       	call   44ac <unlink>

  fd = open("bd", O_CREATE);
    20af:	c7 44 24 04 00 02 00 	movl   $0x200,0x4(%esp)
    20b6:	00 
    20b7:	c7 04 24 34 53 00 00 	movl   $0x5334,(%esp)
    20be:	e8 d9 23 00 00       	call   449c <open>
    20c3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(fd < 0){
    20c6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    20ca:	79 20                	jns    20ec <bigdir+0x63>
    printf(1, "bigdir create failed\n");
    20cc:	c7 44 24 04 37 53 00 	movl   $0x5337,0x4(%esp)
    20d3:	00 
    20d4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    20db:	e8 03 25 00 00       	call   45e3 <printf>
    exit(EXIT_STATUS_DEFAULT);
    20e0:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    20e7:	e8 70 23 00 00       	call   445c <exit>
  }
  close(fd);
    20ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
    20ef:	89 04 24             	mov    %eax,(%esp)
    20f2:	e8 8d 23 00 00       	call   4484 <close>

  for(i = 0; i < 500; i++){
    20f7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    20fe:	eb 6f                	jmp    216f <bigdir+0xe6>
    name[0] = 'x';
    2100:	c6 45 e6 78          	movb   $0x78,-0x1a(%ebp)
    name[1] = '0' + (i / 64);
    2104:	8b 45 f4             	mov    -0xc(%ebp),%eax
    2107:	8d 50 3f             	lea    0x3f(%eax),%edx
    210a:	85 c0                	test   %eax,%eax
    210c:	0f 48 c2             	cmovs  %edx,%eax
    210f:	c1 f8 06             	sar    $0x6,%eax
    2112:	83 c0 30             	add    $0x30,%eax
    2115:	88 45 e7             	mov    %al,-0x19(%ebp)
    name[2] = '0' + (i % 64);
    2118:	8b 45 f4             	mov    -0xc(%ebp),%eax
    211b:	89 c2                	mov    %eax,%edx
    211d:	c1 fa 1f             	sar    $0x1f,%edx
    2120:	c1 ea 1a             	shr    $0x1a,%edx
    2123:	01 d0                	add    %edx,%eax
    2125:	83 e0 3f             	and    $0x3f,%eax
    2128:	29 d0                	sub    %edx,%eax
    212a:	83 c0 30             	add    $0x30,%eax
    212d:	88 45 e8             	mov    %al,-0x18(%ebp)
    name[3] = '\0';
    2130:	c6 45 e9 00          	movb   $0x0,-0x17(%ebp)
    if(link("bd", name) != 0){
    2134:	8d 45 e6             	lea    -0x1a(%ebp),%eax
    2137:	89 44 24 04          	mov    %eax,0x4(%esp)
    213b:	c7 04 24 34 53 00 00 	movl   $0x5334,(%esp)
    2142:	e8 75 23 00 00       	call   44bc <link>
    2147:	85 c0                	test   %eax,%eax
    2149:	74 20                	je     216b <bigdir+0xe2>
      printf(1, "bigdir link failed\n");
    214b:	c7 44 24 04 4d 53 00 	movl   $0x534d,0x4(%esp)
    2152:	00 
    2153:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    215a:	e8 84 24 00 00       	call   45e3 <printf>
      exit(EXIT_STATUS_DEFAULT);
    215f:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    2166:	e8 f1 22 00 00       	call   445c <exit>
    printf(1, "bigdir create failed\n");
    exit(EXIT_STATUS_DEFAULT);
  }
  close(fd);

  for(i = 0; i < 500; i++){
    216b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    216f:	81 7d f4 f3 01 00 00 	cmpl   $0x1f3,-0xc(%ebp)
    2176:	7e 88                	jle    2100 <bigdir+0x77>
      printf(1, "bigdir link failed\n");
      exit(EXIT_STATUS_DEFAULT);
    }
  }

  unlink("bd");
    2178:	c7 04 24 34 53 00 00 	movl   $0x5334,(%esp)
    217f:	e8 28 23 00 00       	call   44ac <unlink>
  for(i = 0; i < 500; i++){
    2184:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    218b:	eb 67                	jmp    21f4 <bigdir+0x16b>
    name[0] = 'x';
    218d:	c6 45 e6 78          	movb   $0x78,-0x1a(%ebp)
    name[1] = '0' + (i / 64);
    2191:	8b 45 f4             	mov    -0xc(%ebp),%eax
    2194:	8d 50 3f             	lea    0x3f(%eax),%edx
    2197:	85 c0                	test   %eax,%eax
    2199:	0f 48 c2             	cmovs  %edx,%eax
    219c:	c1 f8 06             	sar    $0x6,%eax
    219f:	83 c0 30             	add    $0x30,%eax
    21a2:	88 45 e7             	mov    %al,-0x19(%ebp)
    name[2] = '0' + (i % 64);
    21a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
    21a8:	89 c2                	mov    %eax,%edx
    21aa:	c1 fa 1f             	sar    $0x1f,%edx
    21ad:	c1 ea 1a             	shr    $0x1a,%edx
    21b0:	01 d0                	add    %edx,%eax
    21b2:	83 e0 3f             	and    $0x3f,%eax
    21b5:	29 d0                	sub    %edx,%eax
    21b7:	83 c0 30             	add    $0x30,%eax
    21ba:	88 45 e8             	mov    %al,-0x18(%ebp)
    name[3] = '\0';
    21bd:	c6 45 e9 00          	movb   $0x0,-0x17(%ebp)
    if(unlink(name) != 0){
    21c1:	8d 45 e6             	lea    -0x1a(%ebp),%eax
    21c4:	89 04 24             	mov    %eax,(%esp)
    21c7:	e8 e0 22 00 00       	call   44ac <unlink>
    21cc:	85 c0                	test   %eax,%eax
    21ce:	74 20                	je     21f0 <bigdir+0x167>
      printf(1, "bigdir unlink failed");
    21d0:	c7 44 24 04 61 53 00 	movl   $0x5361,0x4(%esp)
    21d7:	00 
    21d8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    21df:	e8 ff 23 00 00       	call   45e3 <printf>
      exit(EXIT_STATUS_DEFAULT);
    21e4:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    21eb:	e8 6c 22 00 00       	call   445c <exit>
      exit(EXIT_STATUS_DEFAULT);
    }
  }

  unlink("bd");
  for(i = 0; i < 500; i++){
    21f0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    21f4:	81 7d f4 f3 01 00 00 	cmpl   $0x1f3,-0xc(%ebp)
    21fb:	7e 90                	jle    218d <bigdir+0x104>
      printf(1, "bigdir unlink failed");
      exit(EXIT_STATUS_DEFAULT);
    }
  }

  printf(1, "bigdir ok\n");
    21fd:	c7 44 24 04 76 53 00 	movl   $0x5376,0x4(%esp)
    2204:	00 
    2205:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    220c:	e8 d2 23 00 00       	call   45e3 <printf>
}
    2211:	c9                   	leave  
    2212:	c3                   	ret    

00002213 <subdir>:

void
subdir(void)
{
    2213:	55                   	push   %ebp
    2214:	89 e5                	mov    %esp,%ebp
    2216:	83 ec 28             	sub    $0x28,%esp
  int fd, cc;

  printf(1, "subdir test\n");
    2219:	c7 44 24 04 81 53 00 	movl   $0x5381,0x4(%esp)
    2220:	00 
    2221:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2228:	e8 b6 23 00 00       	call   45e3 <printf>

  unlink("ff");
    222d:	c7 04 24 8e 53 00 00 	movl   $0x538e,(%esp)
    2234:	e8 73 22 00 00       	call   44ac <unlink>
  if(mkdir("dd") != 0){
    2239:	c7 04 24 91 53 00 00 	movl   $0x5391,(%esp)
    2240:	e8 7f 22 00 00       	call   44c4 <mkdir>
    2245:	85 c0                	test   %eax,%eax
    2247:	74 20                	je     2269 <subdir+0x56>
    printf(1, "subdir mkdir dd failed\n");
    2249:	c7 44 24 04 94 53 00 	movl   $0x5394,0x4(%esp)
    2250:	00 
    2251:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2258:	e8 86 23 00 00       	call   45e3 <printf>
    exit(EXIT_STATUS_DEFAULT);
    225d:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    2264:	e8 f3 21 00 00       	call   445c <exit>
  }

  fd = open("dd/ff", O_CREATE | O_RDWR);
    2269:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
    2270:	00 
    2271:	c7 04 24 ac 53 00 00 	movl   $0x53ac,(%esp)
    2278:	e8 1f 22 00 00       	call   449c <open>
    227d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0){
    2280:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    2284:	79 20                	jns    22a6 <subdir+0x93>
    printf(1, "create dd/ff failed\n");
    2286:	c7 44 24 04 b2 53 00 	movl   $0x53b2,0x4(%esp)
    228d:	00 
    228e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2295:	e8 49 23 00 00       	call   45e3 <printf>
    exit(EXIT_STATUS_DEFAULT);
    229a:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    22a1:	e8 b6 21 00 00       	call   445c <exit>
  }
  write(fd, "ff", 2);
    22a6:	c7 44 24 08 02 00 00 	movl   $0x2,0x8(%esp)
    22ad:	00 
    22ae:	c7 44 24 04 8e 53 00 	movl   $0x538e,0x4(%esp)
    22b5:	00 
    22b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
    22b9:	89 04 24             	mov    %eax,(%esp)
    22bc:	e8 bb 21 00 00       	call   447c <write>
  close(fd);
    22c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
    22c4:	89 04 24             	mov    %eax,(%esp)
    22c7:	e8 b8 21 00 00       	call   4484 <close>
  
  if(unlink("dd") >= 0){
    22cc:	c7 04 24 91 53 00 00 	movl   $0x5391,(%esp)
    22d3:	e8 d4 21 00 00       	call   44ac <unlink>
    22d8:	85 c0                	test   %eax,%eax
    22da:	78 20                	js     22fc <subdir+0xe9>
    printf(1, "unlink dd (non-empty dir) succeeded!\n");
    22dc:	c7 44 24 04 c8 53 00 	movl   $0x53c8,0x4(%esp)
    22e3:	00 
    22e4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    22eb:	e8 f3 22 00 00       	call   45e3 <printf>
    exit(EXIT_STATUS_DEFAULT);
    22f0:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    22f7:	e8 60 21 00 00       	call   445c <exit>
  }

  if(mkdir("/dd/dd") != 0){
    22fc:	c7 04 24 ee 53 00 00 	movl   $0x53ee,(%esp)
    2303:	e8 bc 21 00 00       	call   44c4 <mkdir>
    2308:	85 c0                	test   %eax,%eax
    230a:	74 20                	je     232c <subdir+0x119>
    printf(1, "subdir mkdir dd/dd failed\n");
    230c:	c7 44 24 04 f5 53 00 	movl   $0x53f5,0x4(%esp)
    2313:	00 
    2314:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    231b:	e8 c3 22 00 00       	call   45e3 <printf>
    exit(EXIT_STATUS_DEFAULT);
    2320:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    2327:	e8 30 21 00 00       	call   445c <exit>
  }

  fd = open("dd/dd/ff", O_CREATE | O_RDWR);
    232c:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
    2333:	00 
    2334:	c7 04 24 10 54 00 00 	movl   $0x5410,(%esp)
    233b:	e8 5c 21 00 00       	call   449c <open>
    2340:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0){
    2343:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    2347:	79 20                	jns    2369 <subdir+0x156>
    printf(1, "create dd/dd/ff failed\n");
    2349:	c7 44 24 04 19 54 00 	movl   $0x5419,0x4(%esp)
    2350:	00 
    2351:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2358:	e8 86 22 00 00       	call   45e3 <printf>
    exit(EXIT_STATUS_DEFAULT);
    235d:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    2364:	e8 f3 20 00 00       	call   445c <exit>
  }
  write(fd, "FF", 2);
    2369:	c7 44 24 08 02 00 00 	movl   $0x2,0x8(%esp)
    2370:	00 
    2371:	c7 44 24 04 31 54 00 	movl   $0x5431,0x4(%esp)
    2378:	00 
    2379:	8b 45 f4             	mov    -0xc(%ebp),%eax
    237c:	89 04 24             	mov    %eax,(%esp)
    237f:	e8 f8 20 00 00       	call   447c <write>
  close(fd);
    2384:	8b 45 f4             	mov    -0xc(%ebp),%eax
    2387:	89 04 24             	mov    %eax,(%esp)
    238a:	e8 f5 20 00 00       	call   4484 <close>

  fd = open("dd/dd/../ff", 0);
    238f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    2396:	00 
    2397:	c7 04 24 34 54 00 00 	movl   $0x5434,(%esp)
    239e:	e8 f9 20 00 00       	call   449c <open>
    23a3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0){
    23a6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    23aa:	79 20                	jns    23cc <subdir+0x1b9>
    printf(1, "open dd/dd/../ff failed\n");
    23ac:	c7 44 24 04 40 54 00 	movl   $0x5440,0x4(%esp)
    23b3:	00 
    23b4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    23bb:	e8 23 22 00 00       	call   45e3 <printf>
    exit(EXIT_STATUS_DEFAULT);
    23c0:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    23c7:	e8 90 20 00 00       	call   445c <exit>
  }
  cc = read(fd, buf, sizeof(buf));
    23cc:	c7 44 24 08 00 20 00 	movl   $0x2000,0x8(%esp)
    23d3:	00 
    23d4:	c7 44 24 04 60 90 00 	movl   $0x9060,0x4(%esp)
    23db:	00 
    23dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
    23df:	89 04 24             	mov    %eax,(%esp)
    23e2:	e8 8d 20 00 00       	call   4474 <read>
    23e7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(cc != 2 || buf[0] != 'f'){
    23ea:	83 7d f0 02          	cmpl   $0x2,-0x10(%ebp)
    23ee:	75 0b                	jne    23fb <subdir+0x1e8>
    23f0:	0f b6 05 60 90 00 00 	movzbl 0x9060,%eax
    23f7:	3c 66                	cmp    $0x66,%al
    23f9:	74 20                	je     241b <subdir+0x208>
    printf(1, "dd/dd/../ff wrong content\n");
    23fb:	c7 44 24 04 59 54 00 	movl   $0x5459,0x4(%esp)
    2402:	00 
    2403:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    240a:	e8 d4 21 00 00       	call   45e3 <printf>
    exit(EXIT_STATUS_DEFAULT);
    240f:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    2416:	e8 41 20 00 00       	call   445c <exit>
  }
  close(fd);
    241b:	8b 45 f4             	mov    -0xc(%ebp),%eax
    241e:	89 04 24             	mov    %eax,(%esp)
    2421:	e8 5e 20 00 00       	call   4484 <close>

  if(link("dd/dd/ff", "dd/dd/ffff") != 0){
    2426:	c7 44 24 04 74 54 00 	movl   $0x5474,0x4(%esp)
    242d:	00 
    242e:	c7 04 24 10 54 00 00 	movl   $0x5410,(%esp)
    2435:	e8 82 20 00 00       	call   44bc <link>
    243a:	85 c0                	test   %eax,%eax
    243c:	74 20                	je     245e <subdir+0x24b>
    printf(1, "link dd/dd/ff dd/dd/ffff failed\n");
    243e:	c7 44 24 04 80 54 00 	movl   $0x5480,0x4(%esp)
    2445:	00 
    2446:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    244d:	e8 91 21 00 00       	call   45e3 <printf>
    exit(EXIT_STATUS_DEFAULT);
    2452:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    2459:	e8 fe 1f 00 00       	call   445c <exit>
  }

  if(unlink("dd/dd/ff") != 0){
    245e:	c7 04 24 10 54 00 00 	movl   $0x5410,(%esp)
    2465:	e8 42 20 00 00       	call   44ac <unlink>
    246a:	85 c0                	test   %eax,%eax
    246c:	74 20                	je     248e <subdir+0x27b>
    printf(1, "unlink dd/dd/ff failed\n");
    246e:	c7 44 24 04 a1 54 00 	movl   $0x54a1,0x4(%esp)
    2475:	00 
    2476:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    247d:	e8 61 21 00 00       	call   45e3 <printf>
    exit(EXIT_STATUS_DEFAULT);
    2482:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    2489:	e8 ce 1f 00 00       	call   445c <exit>
  }
  if(open("dd/dd/ff", O_RDONLY) >= 0){
    248e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    2495:	00 
    2496:	c7 04 24 10 54 00 00 	movl   $0x5410,(%esp)
    249d:	e8 fa 1f 00 00       	call   449c <open>
    24a2:	85 c0                	test   %eax,%eax
    24a4:	78 20                	js     24c6 <subdir+0x2b3>
    printf(1, "open (unlinked) dd/dd/ff succeeded\n");
    24a6:	c7 44 24 04 bc 54 00 	movl   $0x54bc,0x4(%esp)
    24ad:	00 
    24ae:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    24b5:	e8 29 21 00 00       	call   45e3 <printf>
    exit(EXIT_STATUS_DEFAULT);
    24ba:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    24c1:	e8 96 1f 00 00       	call   445c <exit>
  }

  if(chdir("dd") != 0){
    24c6:	c7 04 24 91 53 00 00 	movl   $0x5391,(%esp)
    24cd:	e8 fa 1f 00 00       	call   44cc <chdir>
    24d2:	85 c0                	test   %eax,%eax
    24d4:	74 20                	je     24f6 <subdir+0x2e3>
    printf(1, "chdir dd failed\n");
    24d6:	c7 44 24 04 e0 54 00 	movl   $0x54e0,0x4(%esp)
    24dd:	00 
    24de:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    24e5:	e8 f9 20 00 00       	call   45e3 <printf>
    exit(EXIT_STATUS_DEFAULT);
    24ea:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    24f1:	e8 66 1f 00 00       	call   445c <exit>
  }
  if(chdir("dd/../../dd") != 0){
    24f6:	c7 04 24 f1 54 00 00 	movl   $0x54f1,(%esp)
    24fd:	e8 ca 1f 00 00       	call   44cc <chdir>
    2502:	85 c0                	test   %eax,%eax
    2504:	74 20                	je     2526 <subdir+0x313>
    printf(1, "chdir dd/../../dd failed\n");
    2506:	c7 44 24 04 fd 54 00 	movl   $0x54fd,0x4(%esp)
    250d:	00 
    250e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2515:	e8 c9 20 00 00       	call   45e3 <printf>
    exit(EXIT_STATUS_DEFAULT);
    251a:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    2521:	e8 36 1f 00 00       	call   445c <exit>
  }
  if(chdir("dd/../../../dd") != 0){
    2526:	c7 04 24 17 55 00 00 	movl   $0x5517,(%esp)
    252d:	e8 9a 1f 00 00       	call   44cc <chdir>
    2532:	85 c0                	test   %eax,%eax
    2534:	74 20                	je     2556 <subdir+0x343>
    printf(1, "chdir dd/../../dd failed\n");
    2536:	c7 44 24 04 fd 54 00 	movl   $0x54fd,0x4(%esp)
    253d:	00 
    253e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2545:	e8 99 20 00 00       	call   45e3 <printf>
    exit(EXIT_STATUS_DEFAULT);
    254a:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    2551:	e8 06 1f 00 00       	call   445c <exit>
  }
  if(chdir("./..") != 0){
    2556:	c7 04 24 26 55 00 00 	movl   $0x5526,(%esp)
    255d:	e8 6a 1f 00 00       	call   44cc <chdir>
    2562:	85 c0                	test   %eax,%eax
    2564:	74 20                	je     2586 <subdir+0x373>
    printf(1, "chdir ./.. failed\n");
    2566:	c7 44 24 04 2b 55 00 	movl   $0x552b,0x4(%esp)
    256d:	00 
    256e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2575:	e8 69 20 00 00       	call   45e3 <printf>
    exit(EXIT_STATUS_DEFAULT);
    257a:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    2581:	e8 d6 1e 00 00       	call   445c <exit>
  }

  fd = open("dd/dd/ffff", 0);
    2586:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    258d:	00 
    258e:	c7 04 24 74 54 00 00 	movl   $0x5474,(%esp)
    2595:	e8 02 1f 00 00       	call   449c <open>
    259a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0){
    259d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    25a1:	79 20                	jns    25c3 <subdir+0x3b0>
    printf(1, "open dd/dd/ffff failed\n");
    25a3:	c7 44 24 04 3e 55 00 	movl   $0x553e,0x4(%esp)
    25aa:	00 
    25ab:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    25b2:	e8 2c 20 00 00       	call   45e3 <printf>
    exit(EXIT_STATUS_DEFAULT);
    25b7:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    25be:	e8 99 1e 00 00       	call   445c <exit>
  }
  if(read(fd, buf, sizeof(buf)) != 2){
    25c3:	c7 44 24 08 00 20 00 	movl   $0x2000,0x8(%esp)
    25ca:	00 
    25cb:	c7 44 24 04 60 90 00 	movl   $0x9060,0x4(%esp)
    25d2:	00 
    25d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
    25d6:	89 04 24             	mov    %eax,(%esp)
    25d9:	e8 96 1e 00 00       	call   4474 <read>
    25de:	83 f8 02             	cmp    $0x2,%eax
    25e1:	74 20                	je     2603 <subdir+0x3f0>
    printf(1, "read dd/dd/ffff wrong len\n");
    25e3:	c7 44 24 04 56 55 00 	movl   $0x5556,0x4(%esp)
    25ea:	00 
    25eb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    25f2:	e8 ec 1f 00 00       	call   45e3 <printf>
    exit(EXIT_STATUS_DEFAULT);
    25f7:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    25fe:	e8 59 1e 00 00       	call   445c <exit>
  }
  close(fd);
    2603:	8b 45 f4             	mov    -0xc(%ebp),%eax
    2606:	89 04 24             	mov    %eax,(%esp)
    2609:	e8 76 1e 00 00       	call   4484 <close>

  if(open("dd/dd/ff", O_RDONLY) >= 0){
    260e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    2615:	00 
    2616:	c7 04 24 10 54 00 00 	movl   $0x5410,(%esp)
    261d:	e8 7a 1e 00 00       	call   449c <open>
    2622:	85 c0                	test   %eax,%eax
    2624:	78 20                	js     2646 <subdir+0x433>
    printf(1, "open (unlinked) dd/dd/ff succeeded!\n");
    2626:	c7 44 24 04 74 55 00 	movl   $0x5574,0x4(%esp)
    262d:	00 
    262e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2635:	e8 a9 1f 00 00       	call   45e3 <printf>
    exit(EXIT_STATUS_DEFAULT);
    263a:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    2641:	e8 16 1e 00 00       	call   445c <exit>
  }

  if(open("dd/ff/ff", O_CREATE|O_RDWR) >= 0){
    2646:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
    264d:	00 
    264e:	c7 04 24 99 55 00 00 	movl   $0x5599,(%esp)
    2655:	e8 42 1e 00 00       	call   449c <open>
    265a:	85 c0                	test   %eax,%eax
    265c:	78 20                	js     267e <subdir+0x46b>
    printf(1, "create dd/ff/ff succeeded!\n");
    265e:	c7 44 24 04 a2 55 00 	movl   $0x55a2,0x4(%esp)
    2665:	00 
    2666:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    266d:	e8 71 1f 00 00       	call   45e3 <printf>
    exit(EXIT_STATUS_DEFAULT);
    2672:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    2679:	e8 de 1d 00 00       	call   445c <exit>
  }
  if(open("dd/xx/ff", O_CREATE|O_RDWR) >= 0){
    267e:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
    2685:	00 
    2686:	c7 04 24 be 55 00 00 	movl   $0x55be,(%esp)
    268d:	e8 0a 1e 00 00       	call   449c <open>
    2692:	85 c0                	test   %eax,%eax
    2694:	78 20                	js     26b6 <subdir+0x4a3>
    printf(1, "create dd/xx/ff succeeded!\n");
    2696:	c7 44 24 04 c7 55 00 	movl   $0x55c7,0x4(%esp)
    269d:	00 
    269e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    26a5:	e8 39 1f 00 00       	call   45e3 <printf>
    exit(EXIT_STATUS_DEFAULT);
    26aa:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    26b1:	e8 a6 1d 00 00       	call   445c <exit>
  }
  if(open("dd", O_CREATE) >= 0){
    26b6:	c7 44 24 04 00 02 00 	movl   $0x200,0x4(%esp)
    26bd:	00 
    26be:	c7 04 24 91 53 00 00 	movl   $0x5391,(%esp)
    26c5:	e8 d2 1d 00 00       	call   449c <open>
    26ca:	85 c0                	test   %eax,%eax
    26cc:	78 20                	js     26ee <subdir+0x4db>
    printf(1, "create dd succeeded!\n");
    26ce:	c7 44 24 04 e3 55 00 	movl   $0x55e3,0x4(%esp)
    26d5:	00 
    26d6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    26dd:	e8 01 1f 00 00       	call   45e3 <printf>
    exit(EXIT_STATUS_DEFAULT);
    26e2:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    26e9:	e8 6e 1d 00 00       	call   445c <exit>
  }
  if(open("dd", O_RDWR) >= 0){
    26ee:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
    26f5:	00 
    26f6:	c7 04 24 91 53 00 00 	movl   $0x5391,(%esp)
    26fd:	e8 9a 1d 00 00       	call   449c <open>
    2702:	85 c0                	test   %eax,%eax
    2704:	78 20                	js     2726 <subdir+0x513>
    printf(1, "open dd rdwr succeeded!\n");
    2706:	c7 44 24 04 f9 55 00 	movl   $0x55f9,0x4(%esp)
    270d:	00 
    270e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2715:	e8 c9 1e 00 00       	call   45e3 <printf>
    exit(EXIT_STATUS_DEFAULT);
    271a:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    2721:	e8 36 1d 00 00       	call   445c <exit>
  }
  if(open("dd", O_WRONLY) >= 0){
    2726:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
    272d:	00 
    272e:	c7 04 24 91 53 00 00 	movl   $0x5391,(%esp)
    2735:	e8 62 1d 00 00       	call   449c <open>
    273a:	85 c0                	test   %eax,%eax
    273c:	78 20                	js     275e <subdir+0x54b>
    printf(1, "open dd wronly succeeded!\n");
    273e:	c7 44 24 04 12 56 00 	movl   $0x5612,0x4(%esp)
    2745:	00 
    2746:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    274d:	e8 91 1e 00 00       	call   45e3 <printf>
    exit(EXIT_STATUS_DEFAULT);
    2752:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    2759:	e8 fe 1c 00 00       	call   445c <exit>
  }
  if(link("dd/ff/ff", "dd/dd/xx") == 0){
    275e:	c7 44 24 04 2d 56 00 	movl   $0x562d,0x4(%esp)
    2765:	00 
    2766:	c7 04 24 99 55 00 00 	movl   $0x5599,(%esp)
    276d:	e8 4a 1d 00 00       	call   44bc <link>
    2772:	85 c0                	test   %eax,%eax
    2774:	75 20                	jne    2796 <subdir+0x583>
    printf(1, "link dd/ff/ff dd/dd/xx succeeded!\n");
    2776:	c7 44 24 04 38 56 00 	movl   $0x5638,0x4(%esp)
    277d:	00 
    277e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2785:	e8 59 1e 00 00       	call   45e3 <printf>
    exit(EXIT_STATUS_DEFAULT);
    278a:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    2791:	e8 c6 1c 00 00       	call   445c <exit>
  }
  if(link("dd/xx/ff", "dd/dd/xx") == 0){
    2796:	c7 44 24 04 2d 56 00 	movl   $0x562d,0x4(%esp)
    279d:	00 
    279e:	c7 04 24 be 55 00 00 	movl   $0x55be,(%esp)
    27a5:	e8 12 1d 00 00       	call   44bc <link>
    27aa:	85 c0                	test   %eax,%eax
    27ac:	75 20                	jne    27ce <subdir+0x5bb>
    printf(1, "link dd/xx/ff dd/dd/xx succeeded!\n");
    27ae:	c7 44 24 04 5c 56 00 	movl   $0x565c,0x4(%esp)
    27b5:	00 
    27b6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    27bd:	e8 21 1e 00 00       	call   45e3 <printf>
    exit(EXIT_STATUS_DEFAULT);
    27c2:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    27c9:	e8 8e 1c 00 00       	call   445c <exit>
  }
  if(link("dd/ff", "dd/dd/ffff") == 0){
    27ce:	c7 44 24 04 74 54 00 	movl   $0x5474,0x4(%esp)
    27d5:	00 
    27d6:	c7 04 24 ac 53 00 00 	movl   $0x53ac,(%esp)
    27dd:	e8 da 1c 00 00       	call   44bc <link>
    27e2:	85 c0                	test   %eax,%eax
    27e4:	75 20                	jne    2806 <subdir+0x5f3>
    printf(1, "link dd/ff dd/dd/ffff succeeded!\n");
    27e6:	c7 44 24 04 80 56 00 	movl   $0x5680,0x4(%esp)
    27ed:	00 
    27ee:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    27f5:	e8 e9 1d 00 00       	call   45e3 <printf>
    exit(EXIT_STATUS_DEFAULT);
    27fa:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    2801:	e8 56 1c 00 00       	call   445c <exit>
  }
  if(mkdir("dd/ff/ff") == 0){
    2806:	c7 04 24 99 55 00 00 	movl   $0x5599,(%esp)
    280d:	e8 b2 1c 00 00       	call   44c4 <mkdir>
    2812:	85 c0                	test   %eax,%eax
    2814:	75 20                	jne    2836 <subdir+0x623>
    printf(1, "mkdir dd/ff/ff succeeded!\n");
    2816:	c7 44 24 04 a2 56 00 	movl   $0x56a2,0x4(%esp)
    281d:	00 
    281e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2825:	e8 b9 1d 00 00       	call   45e3 <printf>
    exit(EXIT_STATUS_DEFAULT);
    282a:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    2831:	e8 26 1c 00 00       	call   445c <exit>
  }
  if(mkdir("dd/xx/ff") == 0){
    2836:	c7 04 24 be 55 00 00 	movl   $0x55be,(%esp)
    283d:	e8 82 1c 00 00       	call   44c4 <mkdir>
    2842:	85 c0                	test   %eax,%eax
    2844:	75 20                	jne    2866 <subdir+0x653>
    printf(1, "mkdir dd/xx/ff succeeded!\n");
    2846:	c7 44 24 04 bd 56 00 	movl   $0x56bd,0x4(%esp)
    284d:	00 
    284e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2855:	e8 89 1d 00 00       	call   45e3 <printf>
    exit(EXIT_STATUS_DEFAULT);
    285a:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    2861:	e8 f6 1b 00 00       	call   445c <exit>
  }
  if(mkdir("dd/dd/ffff") == 0){
    2866:	c7 04 24 74 54 00 00 	movl   $0x5474,(%esp)
    286d:	e8 52 1c 00 00       	call   44c4 <mkdir>
    2872:	85 c0                	test   %eax,%eax
    2874:	75 20                	jne    2896 <subdir+0x683>
    printf(1, "mkdir dd/dd/ffff succeeded!\n");
    2876:	c7 44 24 04 d8 56 00 	movl   $0x56d8,0x4(%esp)
    287d:	00 
    287e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2885:	e8 59 1d 00 00       	call   45e3 <printf>
    exit(EXIT_STATUS_DEFAULT);
    288a:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    2891:	e8 c6 1b 00 00       	call   445c <exit>
  }
  if(unlink("dd/xx/ff") == 0){
    2896:	c7 04 24 be 55 00 00 	movl   $0x55be,(%esp)
    289d:	e8 0a 1c 00 00       	call   44ac <unlink>
    28a2:	85 c0                	test   %eax,%eax
    28a4:	75 20                	jne    28c6 <subdir+0x6b3>
    printf(1, "unlink dd/xx/ff succeeded!\n");
    28a6:	c7 44 24 04 f5 56 00 	movl   $0x56f5,0x4(%esp)
    28ad:	00 
    28ae:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    28b5:	e8 29 1d 00 00       	call   45e3 <printf>
    exit(EXIT_STATUS_DEFAULT);
    28ba:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    28c1:	e8 96 1b 00 00       	call   445c <exit>
  }
  if(unlink("dd/ff/ff") == 0){
    28c6:	c7 04 24 99 55 00 00 	movl   $0x5599,(%esp)
    28cd:	e8 da 1b 00 00       	call   44ac <unlink>
    28d2:	85 c0                	test   %eax,%eax
    28d4:	75 20                	jne    28f6 <subdir+0x6e3>
    printf(1, "unlink dd/ff/ff succeeded!\n");
    28d6:	c7 44 24 04 11 57 00 	movl   $0x5711,0x4(%esp)
    28dd:	00 
    28de:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    28e5:	e8 f9 1c 00 00       	call   45e3 <printf>
    exit(EXIT_STATUS_DEFAULT);
    28ea:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    28f1:	e8 66 1b 00 00       	call   445c <exit>
  }
  if(chdir("dd/ff") == 0){
    28f6:	c7 04 24 ac 53 00 00 	movl   $0x53ac,(%esp)
    28fd:	e8 ca 1b 00 00       	call   44cc <chdir>
    2902:	85 c0                	test   %eax,%eax
    2904:	75 20                	jne    2926 <subdir+0x713>
    printf(1, "chdir dd/ff succeeded!\n");
    2906:	c7 44 24 04 2d 57 00 	movl   $0x572d,0x4(%esp)
    290d:	00 
    290e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2915:	e8 c9 1c 00 00       	call   45e3 <printf>
    exit(EXIT_STATUS_DEFAULT);
    291a:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    2921:	e8 36 1b 00 00       	call   445c <exit>
  }
  if(chdir("dd/xx") == 0){
    2926:	c7 04 24 45 57 00 00 	movl   $0x5745,(%esp)
    292d:	e8 9a 1b 00 00       	call   44cc <chdir>
    2932:	85 c0                	test   %eax,%eax
    2934:	75 20                	jne    2956 <subdir+0x743>
    printf(1, "chdir dd/xx succeeded!\n");
    2936:	c7 44 24 04 4b 57 00 	movl   $0x574b,0x4(%esp)
    293d:	00 
    293e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2945:	e8 99 1c 00 00       	call   45e3 <printf>
    exit(EXIT_STATUS_DEFAULT);
    294a:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    2951:	e8 06 1b 00 00       	call   445c <exit>
  }

  if(unlink("dd/dd/ffff") != 0){
    2956:	c7 04 24 74 54 00 00 	movl   $0x5474,(%esp)
    295d:	e8 4a 1b 00 00       	call   44ac <unlink>
    2962:	85 c0                	test   %eax,%eax
    2964:	74 20                	je     2986 <subdir+0x773>
    printf(1, "unlink dd/dd/ff failed\n");
    2966:	c7 44 24 04 a1 54 00 	movl   $0x54a1,0x4(%esp)
    296d:	00 
    296e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2975:	e8 69 1c 00 00       	call   45e3 <printf>
    exit(EXIT_STATUS_DEFAULT);
    297a:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    2981:	e8 d6 1a 00 00       	call   445c <exit>
  }
  if(unlink("dd/ff") != 0){
    2986:	c7 04 24 ac 53 00 00 	movl   $0x53ac,(%esp)
    298d:	e8 1a 1b 00 00       	call   44ac <unlink>
    2992:	85 c0                	test   %eax,%eax
    2994:	74 20                	je     29b6 <subdir+0x7a3>
    printf(1, "unlink dd/ff failed\n");
    2996:	c7 44 24 04 63 57 00 	movl   $0x5763,0x4(%esp)
    299d:	00 
    299e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    29a5:	e8 39 1c 00 00       	call   45e3 <printf>
    exit(EXIT_STATUS_DEFAULT);
    29aa:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    29b1:	e8 a6 1a 00 00       	call   445c <exit>
  }
  if(unlink("dd") == 0){
    29b6:	c7 04 24 91 53 00 00 	movl   $0x5391,(%esp)
    29bd:	e8 ea 1a 00 00       	call   44ac <unlink>
    29c2:	85 c0                	test   %eax,%eax
    29c4:	75 20                	jne    29e6 <subdir+0x7d3>
    printf(1, "unlink non-empty dd succeeded!\n");
    29c6:	c7 44 24 04 78 57 00 	movl   $0x5778,0x4(%esp)
    29cd:	00 
    29ce:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    29d5:	e8 09 1c 00 00       	call   45e3 <printf>
    exit(EXIT_STATUS_DEFAULT);
    29da:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    29e1:	e8 76 1a 00 00       	call   445c <exit>
  }
  if(unlink("dd/dd") < 0){
    29e6:	c7 04 24 98 57 00 00 	movl   $0x5798,(%esp)
    29ed:	e8 ba 1a 00 00       	call   44ac <unlink>
    29f2:	85 c0                	test   %eax,%eax
    29f4:	79 20                	jns    2a16 <subdir+0x803>
    printf(1, "unlink dd/dd failed\n");
    29f6:	c7 44 24 04 9e 57 00 	movl   $0x579e,0x4(%esp)
    29fd:	00 
    29fe:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2a05:	e8 d9 1b 00 00       	call   45e3 <printf>
    exit(EXIT_STATUS_DEFAULT);
    2a0a:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    2a11:	e8 46 1a 00 00       	call   445c <exit>
  }
  if(unlink("dd") < 0){
    2a16:	c7 04 24 91 53 00 00 	movl   $0x5391,(%esp)
    2a1d:	e8 8a 1a 00 00       	call   44ac <unlink>
    2a22:	85 c0                	test   %eax,%eax
    2a24:	79 20                	jns    2a46 <subdir+0x833>
    printf(1, "unlink dd failed\n");
    2a26:	c7 44 24 04 b3 57 00 	movl   $0x57b3,0x4(%esp)
    2a2d:	00 
    2a2e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2a35:	e8 a9 1b 00 00       	call   45e3 <printf>
    exit(EXIT_STATUS_DEFAULT);
    2a3a:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    2a41:	e8 16 1a 00 00       	call   445c <exit>
  }

  printf(1, "subdir ok\n");
    2a46:	c7 44 24 04 c5 57 00 	movl   $0x57c5,0x4(%esp)
    2a4d:	00 
    2a4e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2a55:	e8 89 1b 00 00       	call   45e3 <printf>
}
    2a5a:	c9                   	leave  
    2a5b:	c3                   	ret    

00002a5c <bigwrite>:

// test writes that are larger than the log.
void
bigwrite(void)
{
    2a5c:	55                   	push   %ebp
    2a5d:	89 e5                	mov    %esp,%ebp
    2a5f:	83 ec 28             	sub    $0x28,%esp
  int fd, sz;

  printf(1, "bigwrite test\n");
    2a62:	c7 44 24 04 d0 57 00 	movl   $0x57d0,0x4(%esp)
    2a69:	00 
    2a6a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2a71:	e8 6d 1b 00 00       	call   45e3 <printf>

  unlink("bigwrite");
    2a76:	c7 04 24 df 57 00 00 	movl   $0x57df,(%esp)
    2a7d:	e8 2a 1a 00 00       	call   44ac <unlink>
  for(sz = 499; sz < 12*512; sz += 471){
    2a82:	c7 45 f4 f3 01 00 00 	movl   $0x1f3,-0xc(%ebp)
    2a89:	e9 c1 00 00 00       	jmp    2b4f <bigwrite+0xf3>
    fd = open("bigwrite", O_CREATE | O_RDWR);
    2a8e:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
    2a95:	00 
    2a96:	c7 04 24 df 57 00 00 	movl   $0x57df,(%esp)
    2a9d:	e8 fa 19 00 00       	call   449c <open>
    2aa2:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(fd < 0){
    2aa5:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    2aa9:	79 20                	jns    2acb <bigwrite+0x6f>
      printf(1, "cannot create bigwrite\n");
    2aab:	c7 44 24 04 e8 57 00 	movl   $0x57e8,0x4(%esp)
    2ab2:	00 
    2ab3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2aba:	e8 24 1b 00 00       	call   45e3 <printf>
      exit(EXIT_STATUS_DEFAULT);
    2abf:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    2ac6:	e8 91 19 00 00       	call   445c <exit>
    }
    int i;
    for(i = 0; i < 2; i++){
    2acb:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    2ad2:	eb 57                	jmp    2b2b <bigwrite+0xcf>
      int cc = write(fd, buf, sz);
    2ad4:	8b 45 f4             	mov    -0xc(%ebp),%eax
    2ad7:	89 44 24 08          	mov    %eax,0x8(%esp)
    2adb:	c7 44 24 04 60 90 00 	movl   $0x9060,0x4(%esp)
    2ae2:	00 
    2ae3:	8b 45 ec             	mov    -0x14(%ebp),%eax
    2ae6:	89 04 24             	mov    %eax,(%esp)
    2ae9:	e8 8e 19 00 00       	call   447c <write>
    2aee:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if(cc != sz){
    2af1:	8b 45 e8             	mov    -0x18(%ebp),%eax
    2af4:	3b 45 f4             	cmp    -0xc(%ebp),%eax
    2af7:	74 2e                	je     2b27 <bigwrite+0xcb>
        printf(1, "write(%d) ret %d\n", sz, cc);
    2af9:	8b 45 e8             	mov    -0x18(%ebp),%eax
    2afc:	89 44 24 0c          	mov    %eax,0xc(%esp)
    2b00:	8b 45 f4             	mov    -0xc(%ebp),%eax
    2b03:	89 44 24 08          	mov    %eax,0x8(%esp)
    2b07:	c7 44 24 04 00 58 00 	movl   $0x5800,0x4(%esp)
    2b0e:	00 
    2b0f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2b16:	e8 c8 1a 00 00       	call   45e3 <printf>
        exit(EXIT_STATUS_DEFAULT);
    2b1b:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    2b22:	e8 35 19 00 00       	call   445c <exit>
    if(fd < 0){
      printf(1, "cannot create bigwrite\n");
      exit(EXIT_STATUS_DEFAULT);
    }
    int i;
    for(i = 0; i < 2; i++){
    2b27:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
    2b2b:	83 7d f0 01          	cmpl   $0x1,-0x10(%ebp)
    2b2f:	7e a3                	jle    2ad4 <bigwrite+0x78>
      if(cc != sz){
        printf(1, "write(%d) ret %d\n", sz, cc);
        exit(EXIT_STATUS_DEFAULT);
      }
    }
    close(fd);
    2b31:	8b 45 ec             	mov    -0x14(%ebp),%eax
    2b34:	89 04 24             	mov    %eax,(%esp)
    2b37:	e8 48 19 00 00       	call   4484 <close>
    unlink("bigwrite");
    2b3c:	c7 04 24 df 57 00 00 	movl   $0x57df,(%esp)
    2b43:	e8 64 19 00 00       	call   44ac <unlink>
  int fd, sz;

  printf(1, "bigwrite test\n");

  unlink("bigwrite");
  for(sz = 499; sz < 12*512; sz += 471){
    2b48:	81 45 f4 d7 01 00 00 	addl   $0x1d7,-0xc(%ebp)
    2b4f:	81 7d f4 ff 17 00 00 	cmpl   $0x17ff,-0xc(%ebp)
    2b56:	0f 8e 32 ff ff ff    	jle    2a8e <bigwrite+0x32>
    }
    close(fd);
    unlink("bigwrite");
  }

  printf(1, "bigwrite ok\n");
    2b5c:	c7 44 24 04 12 58 00 	movl   $0x5812,0x4(%esp)
    2b63:	00 
    2b64:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2b6b:	e8 73 1a 00 00       	call   45e3 <printf>
}
    2b70:	c9                   	leave  
    2b71:	c3                   	ret    

00002b72 <bigfile>:

void
bigfile(void)
{
    2b72:	55                   	push   %ebp
    2b73:	89 e5                	mov    %esp,%ebp
    2b75:	83 ec 28             	sub    $0x28,%esp
  int fd, i, total, cc;

  printf(1, "bigfile test\n");
    2b78:	c7 44 24 04 1f 58 00 	movl   $0x581f,0x4(%esp)
    2b7f:	00 
    2b80:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2b87:	e8 57 1a 00 00       	call   45e3 <printf>

  unlink("bigfile");
    2b8c:	c7 04 24 2d 58 00 00 	movl   $0x582d,(%esp)
    2b93:	e8 14 19 00 00       	call   44ac <unlink>
  fd = open("bigfile", O_CREATE | O_RDWR);
    2b98:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
    2b9f:	00 
    2ba0:	c7 04 24 2d 58 00 00 	movl   $0x582d,(%esp)
    2ba7:	e8 f0 18 00 00       	call   449c <open>
    2bac:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(fd < 0){
    2baf:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    2bb3:	79 20                	jns    2bd5 <bigfile+0x63>
    printf(1, "cannot create bigfile");
    2bb5:	c7 44 24 04 35 58 00 	movl   $0x5835,0x4(%esp)
    2bbc:	00 
    2bbd:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2bc4:	e8 1a 1a 00 00       	call   45e3 <printf>
    exit(EXIT_STATUS_DEFAULT);
    2bc9:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    2bd0:	e8 87 18 00 00       	call   445c <exit>
  }
  for(i = 0; i < 20; i++){
    2bd5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    2bdc:	eb 61                	jmp    2c3f <bigfile+0xcd>
    memset(buf, i, 600);
    2bde:	c7 44 24 08 58 02 00 	movl   $0x258,0x8(%esp)
    2be5:	00 
    2be6:	8b 45 f4             	mov    -0xc(%ebp),%eax
    2be9:	89 44 24 04          	mov    %eax,0x4(%esp)
    2bed:	c7 04 24 60 90 00 00 	movl   $0x9060,(%esp)
    2bf4:	e8 be 16 00 00       	call   42b7 <memset>
    if(write(fd, buf, 600) != 600){
    2bf9:	c7 44 24 08 58 02 00 	movl   $0x258,0x8(%esp)
    2c00:	00 
    2c01:	c7 44 24 04 60 90 00 	movl   $0x9060,0x4(%esp)
    2c08:	00 
    2c09:	8b 45 ec             	mov    -0x14(%ebp),%eax
    2c0c:	89 04 24             	mov    %eax,(%esp)
    2c0f:	e8 68 18 00 00       	call   447c <write>
    2c14:	3d 58 02 00 00       	cmp    $0x258,%eax
    2c19:	74 20                	je     2c3b <bigfile+0xc9>
      printf(1, "write bigfile failed\n");
    2c1b:	c7 44 24 04 4b 58 00 	movl   $0x584b,0x4(%esp)
    2c22:	00 
    2c23:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2c2a:	e8 b4 19 00 00       	call   45e3 <printf>
      exit(EXIT_STATUS_DEFAULT);
    2c2f:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    2c36:	e8 21 18 00 00       	call   445c <exit>
  fd = open("bigfile", O_CREATE | O_RDWR);
  if(fd < 0){
    printf(1, "cannot create bigfile");
    exit(EXIT_STATUS_DEFAULT);
  }
  for(i = 0; i < 20; i++){
    2c3b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    2c3f:	83 7d f4 13          	cmpl   $0x13,-0xc(%ebp)
    2c43:	7e 99                	jle    2bde <bigfile+0x6c>
    if(write(fd, buf, 600) != 600){
      printf(1, "write bigfile failed\n");
      exit(EXIT_STATUS_DEFAULT);
    }
  }
  close(fd);
    2c45:	8b 45 ec             	mov    -0x14(%ebp),%eax
    2c48:	89 04 24             	mov    %eax,(%esp)
    2c4b:	e8 34 18 00 00       	call   4484 <close>

  fd = open("bigfile", 0);
    2c50:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    2c57:	00 
    2c58:	c7 04 24 2d 58 00 00 	movl   $0x582d,(%esp)
    2c5f:	e8 38 18 00 00       	call   449c <open>
    2c64:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(fd < 0){
    2c67:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    2c6b:	79 20                	jns    2c8d <bigfile+0x11b>
    printf(1, "cannot open bigfile\n");
    2c6d:	c7 44 24 04 61 58 00 	movl   $0x5861,0x4(%esp)
    2c74:	00 
    2c75:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2c7c:	e8 62 19 00 00       	call   45e3 <printf>
    exit(EXIT_STATUS_DEFAULT);
    2c81:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    2c88:	e8 cf 17 00 00       	call   445c <exit>
  }
  total = 0;
    2c8d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(i = 0; ; i++){
    2c94:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    cc = read(fd, buf, 300);
    2c9b:	c7 44 24 08 2c 01 00 	movl   $0x12c,0x8(%esp)
    2ca2:	00 
    2ca3:	c7 44 24 04 60 90 00 	movl   $0x9060,0x4(%esp)
    2caa:	00 
    2cab:	8b 45 ec             	mov    -0x14(%ebp),%eax
    2cae:	89 04 24             	mov    %eax,(%esp)
    2cb1:	e8 be 17 00 00       	call   4474 <read>
    2cb6:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(cc < 0){
    2cb9:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
    2cbd:	79 20                	jns    2cdf <bigfile+0x16d>
      printf(1, "read bigfile failed\n");
    2cbf:	c7 44 24 04 76 58 00 	movl   $0x5876,0x4(%esp)
    2cc6:	00 
    2cc7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2cce:	e8 10 19 00 00       	call   45e3 <printf>
      exit(EXIT_STATUS_DEFAULT);
    2cd3:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    2cda:	e8 7d 17 00 00       	call   445c <exit>
    }
    if(cc == 0)
    2cdf:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
    2ce3:	0f 84 8c 00 00 00    	je     2d75 <bigfile+0x203>
      break;
    if(cc != 300){
    2ce9:	81 7d e8 2c 01 00 00 	cmpl   $0x12c,-0x18(%ebp)
    2cf0:	74 20                	je     2d12 <bigfile+0x1a0>
      printf(1, "short read bigfile\n");
    2cf2:	c7 44 24 04 8b 58 00 	movl   $0x588b,0x4(%esp)
    2cf9:	00 
    2cfa:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2d01:	e8 dd 18 00 00       	call   45e3 <printf>
      exit(EXIT_STATUS_DEFAULT);
    2d06:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    2d0d:	e8 4a 17 00 00       	call   445c <exit>
    }
    if(buf[0] != i/2 || buf[299] != i/2){
    2d12:	0f b6 05 60 90 00 00 	movzbl 0x9060,%eax
    2d19:	0f be d0             	movsbl %al,%edx
    2d1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
    2d1f:	89 c1                	mov    %eax,%ecx
    2d21:	c1 e9 1f             	shr    $0x1f,%ecx
    2d24:	01 c8                	add    %ecx,%eax
    2d26:	d1 f8                	sar    %eax
    2d28:	39 c2                	cmp    %eax,%edx
    2d2a:	75 1a                	jne    2d46 <bigfile+0x1d4>
    2d2c:	0f b6 05 8b 91 00 00 	movzbl 0x918b,%eax
    2d33:	0f be d0             	movsbl %al,%edx
    2d36:	8b 45 f4             	mov    -0xc(%ebp),%eax
    2d39:	89 c1                	mov    %eax,%ecx
    2d3b:	c1 e9 1f             	shr    $0x1f,%ecx
    2d3e:	01 c8                	add    %ecx,%eax
    2d40:	d1 f8                	sar    %eax
    2d42:	39 c2                	cmp    %eax,%edx
    2d44:	74 20                	je     2d66 <bigfile+0x1f4>
      printf(1, "read bigfile wrong data\n");
    2d46:	c7 44 24 04 9f 58 00 	movl   $0x589f,0x4(%esp)
    2d4d:	00 
    2d4e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2d55:	e8 89 18 00 00       	call   45e3 <printf>
      exit(EXIT_STATUS_DEFAULT);
    2d5a:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    2d61:	e8 f6 16 00 00       	call   445c <exit>
    }
    total += cc;
    2d66:	8b 45 e8             	mov    -0x18(%ebp),%eax
    2d69:	01 45 f0             	add    %eax,-0x10(%ebp)
  if(fd < 0){
    printf(1, "cannot open bigfile\n");
    exit(EXIT_STATUS_DEFAULT);
  }
  total = 0;
  for(i = 0; ; i++){
    2d6c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(buf[0] != i/2 || buf[299] != i/2){
      printf(1, "read bigfile wrong data\n");
      exit(EXIT_STATUS_DEFAULT);
    }
    total += cc;
  }
    2d70:	e9 26 ff ff ff       	jmp    2c9b <bigfile+0x129>
    if(cc < 0){
      printf(1, "read bigfile failed\n");
      exit(EXIT_STATUS_DEFAULT);
    }
    if(cc == 0)
      break;
    2d75:	90                   	nop
      printf(1, "read bigfile wrong data\n");
      exit(EXIT_STATUS_DEFAULT);
    }
    total += cc;
  }
  close(fd);
    2d76:	8b 45 ec             	mov    -0x14(%ebp),%eax
    2d79:	89 04 24             	mov    %eax,(%esp)
    2d7c:	e8 03 17 00 00       	call   4484 <close>
  if(total != 20*600){
    2d81:	81 7d f0 e0 2e 00 00 	cmpl   $0x2ee0,-0x10(%ebp)
    2d88:	74 20                	je     2daa <bigfile+0x238>
    printf(1, "read bigfile wrong total\n");
    2d8a:	c7 44 24 04 b8 58 00 	movl   $0x58b8,0x4(%esp)
    2d91:	00 
    2d92:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2d99:	e8 45 18 00 00       	call   45e3 <printf>
    exit(EXIT_STATUS_DEFAULT);
    2d9e:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    2da5:	e8 b2 16 00 00       	call   445c <exit>
  }
  unlink("bigfile");
    2daa:	c7 04 24 2d 58 00 00 	movl   $0x582d,(%esp)
    2db1:	e8 f6 16 00 00       	call   44ac <unlink>

  printf(1, "bigfile test ok\n");
    2db6:	c7 44 24 04 d2 58 00 	movl   $0x58d2,0x4(%esp)
    2dbd:	00 
    2dbe:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2dc5:	e8 19 18 00 00       	call   45e3 <printf>
}
    2dca:	c9                   	leave  
    2dcb:	c3                   	ret    

00002dcc <fourteen>:

void
fourteen(void)
{
    2dcc:	55                   	push   %ebp
    2dcd:	89 e5                	mov    %esp,%ebp
    2dcf:	83 ec 28             	sub    $0x28,%esp
  int fd;

  // DIRSIZ is 14.
  printf(1, "fourteen test\n");
    2dd2:	c7 44 24 04 e3 58 00 	movl   $0x58e3,0x4(%esp)
    2dd9:	00 
    2dda:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2de1:	e8 fd 17 00 00       	call   45e3 <printf>

  if(mkdir("12345678901234") != 0){
    2de6:	c7 04 24 f2 58 00 00 	movl   $0x58f2,(%esp)
    2ded:	e8 d2 16 00 00       	call   44c4 <mkdir>
    2df2:	85 c0                	test   %eax,%eax
    2df4:	74 20                	je     2e16 <fourteen+0x4a>
    printf(1, "mkdir 12345678901234 failed\n");
    2df6:	c7 44 24 04 01 59 00 	movl   $0x5901,0x4(%esp)
    2dfd:	00 
    2dfe:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2e05:	e8 d9 17 00 00       	call   45e3 <printf>
    exit(EXIT_STATUS_DEFAULT);
    2e0a:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    2e11:	e8 46 16 00 00       	call   445c <exit>
  }
  if(mkdir("12345678901234/123456789012345") != 0){
    2e16:	c7 04 24 20 59 00 00 	movl   $0x5920,(%esp)
    2e1d:	e8 a2 16 00 00       	call   44c4 <mkdir>
    2e22:	85 c0                	test   %eax,%eax
    2e24:	74 20                	je     2e46 <fourteen+0x7a>
    printf(1, "mkdir 12345678901234/123456789012345 failed\n");
    2e26:	c7 44 24 04 40 59 00 	movl   $0x5940,0x4(%esp)
    2e2d:	00 
    2e2e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2e35:	e8 a9 17 00 00       	call   45e3 <printf>
    exit(EXIT_STATUS_DEFAULT);
    2e3a:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    2e41:	e8 16 16 00 00       	call   445c <exit>
  }
  fd = open("123456789012345/123456789012345/123456789012345", O_CREATE);
    2e46:	c7 44 24 04 00 02 00 	movl   $0x200,0x4(%esp)
    2e4d:	00 
    2e4e:	c7 04 24 70 59 00 00 	movl   $0x5970,(%esp)
    2e55:	e8 42 16 00 00       	call   449c <open>
    2e5a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0){
    2e5d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    2e61:	79 20                	jns    2e83 <fourteen+0xb7>
    printf(1, "create 123456789012345/123456789012345/123456789012345 failed\n");
    2e63:	c7 44 24 04 a0 59 00 	movl   $0x59a0,0x4(%esp)
    2e6a:	00 
    2e6b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2e72:	e8 6c 17 00 00       	call   45e3 <printf>
    exit(EXIT_STATUS_DEFAULT);
    2e77:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    2e7e:	e8 d9 15 00 00       	call   445c <exit>
  }
  close(fd);
    2e83:	8b 45 f4             	mov    -0xc(%ebp),%eax
    2e86:	89 04 24             	mov    %eax,(%esp)
    2e89:	e8 f6 15 00 00       	call   4484 <close>
  fd = open("12345678901234/12345678901234/12345678901234", 0);
    2e8e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    2e95:	00 
    2e96:	c7 04 24 e0 59 00 00 	movl   $0x59e0,(%esp)
    2e9d:	e8 fa 15 00 00       	call   449c <open>
    2ea2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0){
    2ea5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    2ea9:	79 20                	jns    2ecb <fourteen+0xff>
    printf(1, "open 12345678901234/12345678901234/12345678901234 failed\n");
    2eab:	c7 44 24 04 10 5a 00 	movl   $0x5a10,0x4(%esp)
    2eb2:	00 
    2eb3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2eba:	e8 24 17 00 00       	call   45e3 <printf>
    exit(EXIT_STATUS_DEFAULT);
    2ebf:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    2ec6:	e8 91 15 00 00       	call   445c <exit>
  }
  close(fd);
    2ecb:	8b 45 f4             	mov    -0xc(%ebp),%eax
    2ece:	89 04 24             	mov    %eax,(%esp)
    2ed1:	e8 ae 15 00 00       	call   4484 <close>

  if(mkdir("12345678901234/12345678901234") == 0){
    2ed6:	c7 04 24 4a 5a 00 00 	movl   $0x5a4a,(%esp)
    2edd:	e8 e2 15 00 00       	call   44c4 <mkdir>
    2ee2:	85 c0                	test   %eax,%eax
    2ee4:	75 20                	jne    2f06 <fourteen+0x13a>
    printf(1, "mkdir 12345678901234/12345678901234 succeeded!\n");
    2ee6:	c7 44 24 04 68 5a 00 	movl   $0x5a68,0x4(%esp)
    2eed:	00 
    2eee:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2ef5:	e8 e9 16 00 00       	call   45e3 <printf>
    exit(EXIT_STATUS_DEFAULT);
    2efa:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    2f01:	e8 56 15 00 00       	call   445c <exit>
  }
  if(mkdir("123456789012345/12345678901234") == 0){
    2f06:	c7 04 24 98 5a 00 00 	movl   $0x5a98,(%esp)
    2f0d:	e8 b2 15 00 00       	call   44c4 <mkdir>
    2f12:	85 c0                	test   %eax,%eax
    2f14:	75 20                	jne    2f36 <fourteen+0x16a>
    printf(1, "mkdir 12345678901234/123456789012345 succeeded!\n");
    2f16:	c7 44 24 04 b8 5a 00 	movl   $0x5ab8,0x4(%esp)
    2f1d:	00 
    2f1e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2f25:	e8 b9 16 00 00       	call   45e3 <printf>
    exit(EXIT_STATUS_DEFAULT);
    2f2a:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    2f31:	e8 26 15 00 00       	call   445c <exit>
  }

  printf(1, "fourteen ok\n");
    2f36:	c7 44 24 04 e9 5a 00 	movl   $0x5ae9,0x4(%esp)
    2f3d:	00 
    2f3e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2f45:	e8 99 16 00 00       	call   45e3 <printf>
}
    2f4a:	c9                   	leave  
    2f4b:	c3                   	ret    

00002f4c <rmdot>:

void
rmdot(void)
{
    2f4c:	55                   	push   %ebp
    2f4d:	89 e5                	mov    %esp,%ebp
    2f4f:	83 ec 18             	sub    $0x18,%esp
  printf(1, "rmdot test\n");
    2f52:	c7 44 24 04 f6 5a 00 	movl   $0x5af6,0x4(%esp)
    2f59:	00 
    2f5a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2f61:	e8 7d 16 00 00       	call   45e3 <printf>
  if(mkdir("dots") != 0){
    2f66:	c7 04 24 02 5b 00 00 	movl   $0x5b02,(%esp)
    2f6d:	e8 52 15 00 00       	call   44c4 <mkdir>
    2f72:	85 c0                	test   %eax,%eax
    2f74:	74 20                	je     2f96 <rmdot+0x4a>
    printf(1, "mkdir dots failed\n");
    2f76:	c7 44 24 04 07 5b 00 	movl   $0x5b07,0x4(%esp)
    2f7d:	00 
    2f7e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2f85:	e8 59 16 00 00       	call   45e3 <printf>
    exit(EXIT_STATUS_DEFAULT);
    2f8a:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    2f91:	e8 c6 14 00 00       	call   445c <exit>
  }
  if(chdir("dots") != 0){
    2f96:	c7 04 24 02 5b 00 00 	movl   $0x5b02,(%esp)
    2f9d:	e8 2a 15 00 00       	call   44cc <chdir>
    2fa2:	85 c0                	test   %eax,%eax
    2fa4:	74 20                	je     2fc6 <rmdot+0x7a>
    printf(1, "chdir dots failed\n");
    2fa6:	c7 44 24 04 1a 5b 00 	movl   $0x5b1a,0x4(%esp)
    2fad:	00 
    2fae:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2fb5:	e8 29 16 00 00       	call   45e3 <printf>
    exit(EXIT_STATUS_DEFAULT);
    2fba:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    2fc1:	e8 96 14 00 00       	call   445c <exit>
  }
  if(unlink(".") == 0){
    2fc6:	c7 04 24 33 52 00 00 	movl   $0x5233,(%esp)
    2fcd:	e8 da 14 00 00       	call   44ac <unlink>
    2fd2:	85 c0                	test   %eax,%eax
    2fd4:	75 20                	jne    2ff6 <rmdot+0xaa>
    printf(1, "rm . worked!\n");
    2fd6:	c7 44 24 04 2d 5b 00 	movl   $0x5b2d,0x4(%esp)
    2fdd:	00 
    2fde:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2fe5:	e8 f9 15 00 00       	call   45e3 <printf>
    exit(EXIT_STATUS_DEFAULT);
    2fea:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    2ff1:	e8 66 14 00 00       	call   445c <exit>
  }
  if(unlink("..") == 0){
    2ff6:	c7 04 24 c6 4d 00 00 	movl   $0x4dc6,(%esp)
    2ffd:	e8 aa 14 00 00       	call   44ac <unlink>
    3002:	85 c0                	test   %eax,%eax
    3004:	75 20                	jne    3026 <rmdot+0xda>
    printf(1, "rm .. worked!\n");
    3006:	c7 44 24 04 3b 5b 00 	movl   $0x5b3b,0x4(%esp)
    300d:	00 
    300e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    3015:	e8 c9 15 00 00       	call   45e3 <printf>
    exit(EXIT_STATUS_DEFAULT);
    301a:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    3021:	e8 36 14 00 00       	call   445c <exit>
  }
  if(chdir("/") != 0){
    3026:	c7 04 24 1a 4a 00 00 	movl   $0x4a1a,(%esp)
    302d:	e8 9a 14 00 00       	call   44cc <chdir>
    3032:	85 c0                	test   %eax,%eax
    3034:	74 20                	je     3056 <rmdot+0x10a>
    printf(1, "chdir / failed\n");
    3036:	c7 44 24 04 1c 4a 00 	movl   $0x4a1c,0x4(%esp)
    303d:	00 
    303e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    3045:	e8 99 15 00 00       	call   45e3 <printf>
    exit(EXIT_STATUS_DEFAULT);
    304a:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    3051:	e8 06 14 00 00       	call   445c <exit>
  }
  if(unlink("dots/.") == 0){
    3056:	c7 04 24 4a 5b 00 00 	movl   $0x5b4a,(%esp)
    305d:	e8 4a 14 00 00       	call   44ac <unlink>
    3062:	85 c0                	test   %eax,%eax
    3064:	75 20                	jne    3086 <rmdot+0x13a>
    printf(1, "unlink dots/. worked!\n");
    3066:	c7 44 24 04 51 5b 00 	movl   $0x5b51,0x4(%esp)
    306d:	00 
    306e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    3075:	e8 69 15 00 00       	call   45e3 <printf>
    exit(EXIT_STATUS_DEFAULT);
    307a:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    3081:	e8 d6 13 00 00       	call   445c <exit>
  }
  if(unlink("dots/..") == 0){
    3086:	c7 04 24 68 5b 00 00 	movl   $0x5b68,(%esp)
    308d:	e8 1a 14 00 00       	call   44ac <unlink>
    3092:	85 c0                	test   %eax,%eax
    3094:	75 20                	jne    30b6 <rmdot+0x16a>
    printf(1, "unlink dots/.. worked!\n");
    3096:	c7 44 24 04 70 5b 00 	movl   $0x5b70,0x4(%esp)
    309d:	00 
    309e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    30a5:	e8 39 15 00 00       	call   45e3 <printf>
    exit(EXIT_STATUS_DEFAULT);
    30aa:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    30b1:	e8 a6 13 00 00       	call   445c <exit>
  }
  if(unlink("dots") != 0){
    30b6:	c7 04 24 02 5b 00 00 	movl   $0x5b02,(%esp)
    30bd:	e8 ea 13 00 00       	call   44ac <unlink>
    30c2:	85 c0                	test   %eax,%eax
    30c4:	74 20                	je     30e6 <rmdot+0x19a>
    printf(1, "unlink dots failed!\n");
    30c6:	c7 44 24 04 88 5b 00 	movl   $0x5b88,0x4(%esp)
    30cd:	00 
    30ce:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    30d5:	e8 09 15 00 00       	call   45e3 <printf>
    exit(EXIT_STATUS_DEFAULT);
    30da:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    30e1:	e8 76 13 00 00       	call   445c <exit>
  }
  printf(1, "rmdot ok\n");
    30e6:	c7 44 24 04 9d 5b 00 	movl   $0x5b9d,0x4(%esp)
    30ed:	00 
    30ee:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    30f5:	e8 e9 14 00 00       	call   45e3 <printf>
}
    30fa:	c9                   	leave  
    30fb:	c3                   	ret    

000030fc <dirfile>:

void
dirfile(void)
{
    30fc:	55                   	push   %ebp
    30fd:	89 e5                	mov    %esp,%ebp
    30ff:	83 ec 28             	sub    $0x28,%esp
  int fd;

  printf(1, "dir vs file\n");
    3102:	c7 44 24 04 a7 5b 00 	movl   $0x5ba7,0x4(%esp)
    3109:	00 
    310a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    3111:	e8 cd 14 00 00       	call   45e3 <printf>

  fd = open("dirfile", O_CREATE);
    3116:	c7 44 24 04 00 02 00 	movl   $0x200,0x4(%esp)
    311d:	00 
    311e:	c7 04 24 b4 5b 00 00 	movl   $0x5bb4,(%esp)
    3125:	e8 72 13 00 00       	call   449c <open>
    312a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0){
    312d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    3131:	79 20                	jns    3153 <dirfile+0x57>
    printf(1, "create dirfile failed\n");
    3133:	c7 44 24 04 bc 5b 00 	movl   $0x5bbc,0x4(%esp)
    313a:	00 
    313b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    3142:	e8 9c 14 00 00       	call   45e3 <printf>
    exit(EXIT_STATUS_DEFAULT);
    3147:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    314e:	e8 09 13 00 00       	call   445c <exit>
  }
  close(fd);
    3153:	8b 45 f4             	mov    -0xc(%ebp),%eax
    3156:	89 04 24             	mov    %eax,(%esp)
    3159:	e8 26 13 00 00       	call   4484 <close>
  if(chdir("dirfile") == 0){
    315e:	c7 04 24 b4 5b 00 00 	movl   $0x5bb4,(%esp)
    3165:	e8 62 13 00 00       	call   44cc <chdir>
    316a:	85 c0                	test   %eax,%eax
    316c:	75 20                	jne    318e <dirfile+0x92>
    printf(1, "chdir dirfile succeeded!\n");
    316e:	c7 44 24 04 d3 5b 00 	movl   $0x5bd3,0x4(%esp)
    3175:	00 
    3176:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    317d:	e8 61 14 00 00       	call   45e3 <printf>
    exit(EXIT_STATUS_DEFAULT);
    3182:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    3189:	e8 ce 12 00 00       	call   445c <exit>
  }
  fd = open("dirfile/xx", 0);
    318e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    3195:	00 
    3196:	c7 04 24 ed 5b 00 00 	movl   $0x5bed,(%esp)
    319d:	e8 fa 12 00 00       	call   449c <open>
    31a2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd >= 0){
    31a5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    31a9:	78 20                	js     31cb <dirfile+0xcf>
    printf(1, "create dirfile/xx succeeded!\n");
    31ab:	c7 44 24 04 f8 5b 00 	movl   $0x5bf8,0x4(%esp)
    31b2:	00 
    31b3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    31ba:	e8 24 14 00 00       	call   45e3 <printf>
    exit(EXIT_STATUS_DEFAULT);
    31bf:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    31c6:	e8 91 12 00 00       	call   445c <exit>
  }
  fd = open("dirfile/xx", O_CREATE);
    31cb:	c7 44 24 04 00 02 00 	movl   $0x200,0x4(%esp)
    31d2:	00 
    31d3:	c7 04 24 ed 5b 00 00 	movl   $0x5bed,(%esp)
    31da:	e8 bd 12 00 00       	call   449c <open>
    31df:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd >= 0){
    31e2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    31e6:	78 20                	js     3208 <dirfile+0x10c>
    printf(1, "create dirfile/xx succeeded!\n");
    31e8:	c7 44 24 04 f8 5b 00 	movl   $0x5bf8,0x4(%esp)
    31ef:	00 
    31f0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    31f7:	e8 e7 13 00 00       	call   45e3 <printf>
    exit(EXIT_STATUS_DEFAULT);
    31fc:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    3203:	e8 54 12 00 00       	call   445c <exit>
  }
  if(mkdir("dirfile/xx") == 0){
    3208:	c7 04 24 ed 5b 00 00 	movl   $0x5bed,(%esp)
    320f:	e8 b0 12 00 00       	call   44c4 <mkdir>
    3214:	85 c0                	test   %eax,%eax
    3216:	75 20                	jne    3238 <dirfile+0x13c>
    printf(1, "mkdir dirfile/xx succeeded!\n");
    3218:	c7 44 24 04 16 5c 00 	movl   $0x5c16,0x4(%esp)
    321f:	00 
    3220:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    3227:	e8 b7 13 00 00       	call   45e3 <printf>
    exit(EXIT_STATUS_DEFAULT);
    322c:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    3233:	e8 24 12 00 00       	call   445c <exit>
  }
  if(unlink("dirfile/xx") == 0){
    3238:	c7 04 24 ed 5b 00 00 	movl   $0x5bed,(%esp)
    323f:	e8 68 12 00 00       	call   44ac <unlink>
    3244:	85 c0                	test   %eax,%eax
    3246:	75 20                	jne    3268 <dirfile+0x16c>
    printf(1, "unlink dirfile/xx succeeded!\n");
    3248:	c7 44 24 04 33 5c 00 	movl   $0x5c33,0x4(%esp)
    324f:	00 
    3250:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    3257:	e8 87 13 00 00       	call   45e3 <printf>
    exit(EXIT_STATUS_DEFAULT);
    325c:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    3263:	e8 f4 11 00 00       	call   445c <exit>
  }
  if(link("README", "dirfile/xx") == 0){
    3268:	c7 44 24 04 ed 5b 00 	movl   $0x5bed,0x4(%esp)
    326f:	00 
    3270:	c7 04 24 51 5c 00 00 	movl   $0x5c51,(%esp)
    3277:	e8 40 12 00 00       	call   44bc <link>
    327c:	85 c0                	test   %eax,%eax
    327e:	75 20                	jne    32a0 <dirfile+0x1a4>
    printf(1, "link to dirfile/xx succeeded!\n");
    3280:	c7 44 24 04 58 5c 00 	movl   $0x5c58,0x4(%esp)
    3287:	00 
    3288:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    328f:	e8 4f 13 00 00       	call   45e3 <printf>
    exit(EXIT_STATUS_DEFAULT);
    3294:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    329b:	e8 bc 11 00 00       	call   445c <exit>
  }
  if(unlink("dirfile") != 0){
    32a0:	c7 04 24 b4 5b 00 00 	movl   $0x5bb4,(%esp)
    32a7:	e8 00 12 00 00       	call   44ac <unlink>
    32ac:	85 c0                	test   %eax,%eax
    32ae:	74 20                	je     32d0 <dirfile+0x1d4>
    printf(1, "unlink dirfile failed!\n");
    32b0:	c7 44 24 04 77 5c 00 	movl   $0x5c77,0x4(%esp)
    32b7:	00 
    32b8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    32bf:	e8 1f 13 00 00       	call   45e3 <printf>
    exit(EXIT_STATUS_DEFAULT);
    32c4:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    32cb:	e8 8c 11 00 00       	call   445c <exit>
  }

  fd = open(".", O_RDWR);
    32d0:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
    32d7:	00 
    32d8:	c7 04 24 33 52 00 00 	movl   $0x5233,(%esp)
    32df:	e8 b8 11 00 00       	call   449c <open>
    32e4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd >= 0){
    32e7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    32eb:	78 20                	js     330d <dirfile+0x211>
    printf(1, "open . for writing succeeded!\n");
    32ed:	c7 44 24 04 90 5c 00 	movl   $0x5c90,0x4(%esp)
    32f4:	00 
    32f5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    32fc:	e8 e2 12 00 00       	call   45e3 <printf>
    exit(EXIT_STATUS_DEFAULT);
    3301:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    3308:	e8 4f 11 00 00       	call   445c <exit>
  }
  fd = open(".", 0);
    330d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    3314:	00 
    3315:	c7 04 24 33 52 00 00 	movl   $0x5233,(%esp)
    331c:	e8 7b 11 00 00       	call   449c <open>
    3321:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(write(fd, "x", 1) > 0){
    3324:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
    332b:	00 
    332c:	c7 44 24 04 7f 4e 00 	movl   $0x4e7f,0x4(%esp)
    3333:	00 
    3334:	8b 45 f4             	mov    -0xc(%ebp),%eax
    3337:	89 04 24             	mov    %eax,(%esp)
    333a:	e8 3d 11 00 00       	call   447c <write>
    333f:	85 c0                	test   %eax,%eax
    3341:	7e 20                	jle    3363 <dirfile+0x267>
    printf(1, "write . succeeded!\n");
    3343:	c7 44 24 04 af 5c 00 	movl   $0x5caf,0x4(%esp)
    334a:	00 
    334b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    3352:	e8 8c 12 00 00       	call   45e3 <printf>
    exit(EXIT_STATUS_DEFAULT);
    3357:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    335e:	e8 f9 10 00 00       	call   445c <exit>
  }
  close(fd);
    3363:	8b 45 f4             	mov    -0xc(%ebp),%eax
    3366:	89 04 24             	mov    %eax,(%esp)
    3369:	e8 16 11 00 00       	call   4484 <close>

  printf(1, "dir vs file OK\n");
    336e:	c7 44 24 04 c3 5c 00 	movl   $0x5cc3,0x4(%esp)
    3375:	00 
    3376:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    337d:	e8 61 12 00 00       	call   45e3 <printf>
}
    3382:	c9                   	leave  
    3383:	c3                   	ret    

00003384 <iref>:

// test that iput() is called at the end of _namei()
void
iref(void)
{
    3384:	55                   	push   %ebp
    3385:	89 e5                	mov    %esp,%ebp
    3387:	83 ec 28             	sub    $0x28,%esp
  int i, fd;

  printf(1, "empty file name\n");
    338a:	c7 44 24 04 d3 5c 00 	movl   $0x5cd3,0x4(%esp)
    3391:	00 
    3392:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    3399:	e8 45 12 00 00       	call   45e3 <printf>

  // the 50 is NINODE
  for(i = 0; i < 50 + 1; i++){
    339e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    33a5:	e9 e0 00 00 00       	jmp    348a <iref+0x106>
    if(mkdir("irefd") != 0){
    33aa:	c7 04 24 e4 5c 00 00 	movl   $0x5ce4,(%esp)
    33b1:	e8 0e 11 00 00       	call   44c4 <mkdir>
    33b6:	85 c0                	test   %eax,%eax
    33b8:	74 20                	je     33da <iref+0x56>
      printf(1, "mkdir irefd failed\n");
    33ba:	c7 44 24 04 ea 5c 00 	movl   $0x5cea,0x4(%esp)
    33c1:	00 
    33c2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    33c9:	e8 15 12 00 00       	call   45e3 <printf>
      exit(EXIT_STATUS_DEFAULT);
    33ce:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    33d5:	e8 82 10 00 00       	call   445c <exit>
    }
    if(chdir("irefd") != 0){
    33da:	c7 04 24 e4 5c 00 00 	movl   $0x5ce4,(%esp)
    33e1:	e8 e6 10 00 00       	call   44cc <chdir>
    33e6:	85 c0                	test   %eax,%eax
    33e8:	74 20                	je     340a <iref+0x86>
      printf(1, "chdir irefd failed\n");
    33ea:	c7 44 24 04 fe 5c 00 	movl   $0x5cfe,0x4(%esp)
    33f1:	00 
    33f2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    33f9:	e8 e5 11 00 00       	call   45e3 <printf>
      exit(EXIT_STATUS_DEFAULT);
    33fe:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    3405:	e8 52 10 00 00       	call   445c <exit>
    }

    mkdir("");
    340a:	c7 04 24 12 5d 00 00 	movl   $0x5d12,(%esp)
    3411:	e8 ae 10 00 00       	call   44c4 <mkdir>
    link("README", "");
    3416:	c7 44 24 04 12 5d 00 	movl   $0x5d12,0x4(%esp)
    341d:	00 
    341e:	c7 04 24 51 5c 00 00 	movl   $0x5c51,(%esp)
    3425:	e8 92 10 00 00       	call   44bc <link>
    fd = open("", O_CREATE);
    342a:	c7 44 24 04 00 02 00 	movl   $0x200,0x4(%esp)
    3431:	00 
    3432:	c7 04 24 12 5d 00 00 	movl   $0x5d12,(%esp)
    3439:	e8 5e 10 00 00       	call   449c <open>
    343e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(fd >= 0)
    3441:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    3445:	78 0b                	js     3452 <iref+0xce>
      close(fd);
    3447:	8b 45 f0             	mov    -0x10(%ebp),%eax
    344a:	89 04 24             	mov    %eax,(%esp)
    344d:	e8 32 10 00 00       	call   4484 <close>
    fd = open("xx", O_CREATE);
    3452:	c7 44 24 04 00 02 00 	movl   $0x200,0x4(%esp)
    3459:	00 
    345a:	c7 04 24 13 5d 00 00 	movl   $0x5d13,(%esp)
    3461:	e8 36 10 00 00       	call   449c <open>
    3466:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(fd >= 0)
    3469:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    346d:	78 0b                	js     347a <iref+0xf6>
      close(fd);
    346f:	8b 45 f0             	mov    -0x10(%ebp),%eax
    3472:	89 04 24             	mov    %eax,(%esp)
    3475:	e8 0a 10 00 00       	call   4484 <close>
    unlink("xx");
    347a:	c7 04 24 13 5d 00 00 	movl   $0x5d13,(%esp)
    3481:	e8 26 10 00 00       	call   44ac <unlink>
  int i, fd;

  printf(1, "empty file name\n");

  // the 50 is NINODE
  for(i = 0; i < 50 + 1; i++){
    3486:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    348a:	83 7d f4 32          	cmpl   $0x32,-0xc(%ebp)
    348e:	0f 8e 16 ff ff ff    	jle    33aa <iref+0x26>
    if(fd >= 0)
      close(fd);
    unlink("xx");
  }

  chdir("/");
    3494:	c7 04 24 1a 4a 00 00 	movl   $0x4a1a,(%esp)
    349b:	e8 2c 10 00 00       	call   44cc <chdir>
  printf(1, "empty file name OK\n");
    34a0:	c7 44 24 04 16 5d 00 	movl   $0x5d16,0x4(%esp)
    34a7:	00 
    34a8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    34af:	e8 2f 11 00 00       	call   45e3 <printf>
}
    34b4:	c9                   	leave  
    34b5:	c3                   	ret    

000034b6 <forktest>:
// test that fork fails gracefully
// the forktest binary also does this, but it runs out of proc entries first.
// inside the bigger usertests binary, we run out of memory first.
void
forktest(void)
{
    34b6:	55                   	push   %ebp
    34b7:	89 e5                	mov    %esp,%ebp
    34b9:	83 ec 28             	sub    $0x28,%esp
  int n, pid;

  printf(1, "fork test\n");
    34bc:	c7 44 24 04 2a 5d 00 	movl   $0x5d2a,0x4(%esp)
    34c3:	00 
    34c4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    34cb:	e8 13 11 00 00       	call   45e3 <printf>

  for(n=0; n<1000; n++){
    34d0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    34d7:	eb 24                	jmp    34fd <forktest+0x47>
    pid = fork();
    34d9:	e8 76 0f 00 00       	call   4454 <fork>
    34de:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(pid < 0)
    34e1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    34e5:	78 21                	js     3508 <forktest+0x52>
      break;
    if(pid == 0)
    34e7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    34eb:	75 0c                	jne    34f9 <forktest+0x43>
      exit(EXIT_STATUS_DEFAULT);
    34ed:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    34f4:	e8 63 0f 00 00       	call   445c <exit>
{
  int n, pid;

  printf(1, "fork test\n");

  for(n=0; n<1000; n++){
    34f9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    34fd:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
    3504:	7e d3                	jle    34d9 <forktest+0x23>
    3506:	eb 01                	jmp    3509 <forktest+0x53>
    pid = fork();
    if(pid < 0)
      break;
    3508:	90                   	nop
    if(pid == 0)
      exit(EXIT_STATUS_DEFAULT);
  }
  
  if(n == 1000){
    3509:	81 7d f4 e8 03 00 00 	cmpl   $0x3e8,-0xc(%ebp)
    3510:	75 54                	jne    3566 <forktest+0xb0>
    printf(1, "fork claimed to work 1000 times!\n");
    3512:	c7 44 24 04 38 5d 00 	movl   $0x5d38,0x4(%esp)
    3519:	00 
    351a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    3521:	e8 bd 10 00 00       	call   45e3 <printf>
    exit(EXIT_STATUS_DEFAULT);
    3526:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    352d:	e8 2a 0f 00 00       	call   445c <exit>
  }
  
  for(; n > 0; n--){
    if(wait(0) < 0){
    3532:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    3539:	e8 26 0f 00 00       	call   4464 <wait>
    353e:	85 c0                	test   %eax,%eax
    3540:	79 20                	jns    3562 <forktest+0xac>
      printf(1, "wait stopped early\n");
    3542:	c7 44 24 04 5a 5d 00 	movl   $0x5d5a,0x4(%esp)
    3549:	00 
    354a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    3551:	e8 8d 10 00 00       	call   45e3 <printf>
      exit(EXIT_STATUS_DEFAULT);
    3556:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    355d:	e8 fa 0e 00 00       	call   445c <exit>
  if(n == 1000){
    printf(1, "fork claimed to work 1000 times!\n");
    exit(EXIT_STATUS_DEFAULT);
  }
  
  for(; n > 0; n--){
    3562:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
    3566:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    356a:	7f c6                	jg     3532 <forktest+0x7c>
      printf(1, "wait stopped early\n");
      exit(EXIT_STATUS_DEFAULT);
    }
  }
  
  if(wait(0) != -1){
    356c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    3573:	e8 ec 0e 00 00       	call   4464 <wait>
    3578:	83 f8 ff             	cmp    $0xffffffff,%eax
    357b:	74 20                	je     359d <forktest+0xe7>
    printf(1, "wait got too many\n");
    357d:	c7 44 24 04 6e 5d 00 	movl   $0x5d6e,0x4(%esp)
    3584:	00 
    3585:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    358c:	e8 52 10 00 00       	call   45e3 <printf>
    exit(EXIT_STATUS_DEFAULT);
    3591:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    3598:	e8 bf 0e 00 00       	call   445c <exit>
  }
  
  printf(1, "fork test OK\n");
    359d:	c7 44 24 04 81 5d 00 	movl   $0x5d81,0x4(%esp)
    35a4:	00 
    35a5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    35ac:	e8 32 10 00 00       	call   45e3 <printf>
}
    35b1:	c9                   	leave  
    35b2:	c3                   	ret    

000035b3 <sbrktest>:

void
sbrktest(void)
{
    35b3:	55                   	push   %ebp
    35b4:	89 e5                	mov    %esp,%ebp
    35b6:	53                   	push   %ebx
    35b7:	81 ec 84 00 00 00    	sub    $0x84,%esp
  int fds[2], pid, pids[10], ppid;
  char *a, *b, *c, *lastaddr, *oldbrk, *p, scratch;
  uint amt;

  printf(stdout, "sbrk test\n");
    35bd:	a1 68 68 00 00       	mov    0x6868,%eax
    35c2:	c7 44 24 04 8f 5d 00 	movl   $0x5d8f,0x4(%esp)
    35c9:	00 
    35ca:	89 04 24             	mov    %eax,(%esp)
    35cd:	e8 11 10 00 00       	call   45e3 <printf>
  oldbrk = sbrk(0);
    35d2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    35d9:	e8 06 0f 00 00       	call   44e4 <sbrk>
    35de:	89 45 ec             	mov    %eax,-0x14(%ebp)

  // can one sbrk() less than a page?
  a = sbrk(0);
    35e1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    35e8:	e8 f7 0e 00 00       	call   44e4 <sbrk>
    35ed:	89 45 f4             	mov    %eax,-0xc(%ebp)
  int i;
  for(i = 0; i < 5000; i++){ 
    35f0:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    35f7:	eb 60                	jmp    3659 <sbrktest+0xa6>
    b = sbrk(1);
    35f9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    3600:	e8 df 0e 00 00       	call   44e4 <sbrk>
    3605:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(b != a){
    3608:	8b 45 e8             	mov    -0x18(%ebp),%eax
    360b:	3b 45 f4             	cmp    -0xc(%ebp),%eax
    360e:	74 36                	je     3646 <sbrktest+0x93>
      printf(stdout, "sbrk test failed %d %x %x\n", i, a, b);
    3610:	a1 68 68 00 00       	mov    0x6868,%eax
    3615:	8b 55 e8             	mov    -0x18(%ebp),%edx
    3618:	89 54 24 10          	mov    %edx,0x10(%esp)
    361c:	8b 55 f4             	mov    -0xc(%ebp),%edx
    361f:	89 54 24 0c          	mov    %edx,0xc(%esp)
    3623:	8b 55 f0             	mov    -0x10(%ebp),%edx
    3626:	89 54 24 08          	mov    %edx,0x8(%esp)
    362a:	c7 44 24 04 9a 5d 00 	movl   $0x5d9a,0x4(%esp)
    3631:	00 
    3632:	89 04 24             	mov    %eax,(%esp)
    3635:	e8 a9 0f 00 00       	call   45e3 <printf>
      exit(EXIT_STATUS_DEFAULT);
    363a:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    3641:	e8 16 0e 00 00       	call   445c <exit>
    }
    *b = 1;
    3646:	8b 45 e8             	mov    -0x18(%ebp),%eax
    3649:	c6 00 01             	movb   $0x1,(%eax)
    a = b + 1;
    364c:	8b 45 e8             	mov    -0x18(%ebp),%eax
    364f:	83 c0 01             	add    $0x1,%eax
    3652:	89 45 f4             	mov    %eax,-0xc(%ebp)
  oldbrk = sbrk(0);

  // can one sbrk() less than a page?
  a = sbrk(0);
  int i;
  for(i = 0; i < 5000; i++){ 
    3655:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
    3659:	81 7d f0 87 13 00 00 	cmpl   $0x1387,-0x10(%ebp)
    3660:	7e 97                	jle    35f9 <sbrktest+0x46>
      exit(EXIT_STATUS_DEFAULT);
    }
    *b = 1;
    a = b + 1;
  }
  pid = fork();
    3662:	e8 ed 0d 00 00       	call   4454 <fork>
    3667:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  if(pid < 0){
    366a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
    366e:	79 21                	jns    3691 <sbrktest+0xde>
    printf(stdout, "sbrk test fork failed\n");
    3670:	a1 68 68 00 00       	mov    0x6868,%eax
    3675:	c7 44 24 04 b5 5d 00 	movl   $0x5db5,0x4(%esp)
    367c:	00 
    367d:	89 04 24             	mov    %eax,(%esp)
    3680:	e8 5e 0f 00 00       	call   45e3 <printf>
    exit(EXIT_STATUS_DEFAULT);
    3685:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    368c:	e8 cb 0d 00 00       	call   445c <exit>
  }
  c = sbrk(1);
    3691:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    3698:	e8 47 0e 00 00       	call   44e4 <sbrk>
    369d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  c = sbrk(1);
    36a0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    36a7:	e8 38 0e 00 00       	call   44e4 <sbrk>
    36ac:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if(c != a + 1){
    36af:	8b 45 f4             	mov    -0xc(%ebp),%eax
    36b2:	83 c0 01             	add    $0x1,%eax
    36b5:	3b 45 e0             	cmp    -0x20(%ebp),%eax
    36b8:	74 21                	je     36db <sbrktest+0x128>
    printf(stdout, "sbrk test failed post-fork\n");
    36ba:	a1 68 68 00 00       	mov    0x6868,%eax
    36bf:	c7 44 24 04 cc 5d 00 	movl   $0x5dcc,0x4(%esp)
    36c6:	00 
    36c7:	89 04 24             	mov    %eax,(%esp)
    36ca:	e8 14 0f 00 00       	call   45e3 <printf>
    exit(EXIT_STATUS_DEFAULT);
    36cf:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    36d6:	e8 81 0d 00 00       	call   445c <exit>
  }
  if(pid == 0)
    36db:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
    36df:	75 0c                	jne    36ed <sbrktest+0x13a>
    exit(EXIT_STATUS_DEFAULT);
    36e1:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    36e8:	e8 6f 0d 00 00       	call   445c <exit>
  wait(0);
    36ed:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    36f4:	e8 6b 0d 00 00       	call   4464 <wait>

  // can one grow address space to something big?
#define BIG (100*1024*1024)
  a = sbrk(0);
    36f9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    3700:	e8 df 0d 00 00       	call   44e4 <sbrk>
    3705:	89 45 f4             	mov    %eax,-0xc(%ebp)
  amt = (BIG) - (uint)a;
    3708:	8b 45 f4             	mov    -0xc(%ebp),%eax
    370b:	ba 00 00 40 06       	mov    $0x6400000,%edx
    3710:	89 d1                	mov    %edx,%ecx
    3712:	29 c1                	sub    %eax,%ecx
    3714:	89 c8                	mov    %ecx,%eax
    3716:	89 45 dc             	mov    %eax,-0x24(%ebp)
  p = sbrk(amt);
    3719:	8b 45 dc             	mov    -0x24(%ebp),%eax
    371c:	89 04 24             	mov    %eax,(%esp)
    371f:	e8 c0 0d 00 00       	call   44e4 <sbrk>
    3724:	89 45 d8             	mov    %eax,-0x28(%ebp)
  if (p != a) { 
    3727:	8b 45 d8             	mov    -0x28(%ebp),%eax
    372a:	3b 45 f4             	cmp    -0xc(%ebp),%eax
    372d:	74 21                	je     3750 <sbrktest+0x19d>
    printf(stdout, "sbrk test failed to grow big address space; enough phys mem?\n");
    372f:	a1 68 68 00 00       	mov    0x6868,%eax
    3734:	c7 44 24 04 e8 5d 00 	movl   $0x5de8,0x4(%esp)
    373b:	00 
    373c:	89 04 24             	mov    %eax,(%esp)
    373f:	e8 9f 0e 00 00       	call   45e3 <printf>
    exit(EXIT_STATUS_DEFAULT);
    3744:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    374b:	e8 0c 0d 00 00       	call   445c <exit>
  }
  lastaddr = (char*) (BIG-1);
    3750:	c7 45 d4 ff ff 3f 06 	movl   $0x63fffff,-0x2c(%ebp)
  *lastaddr = 99;
    3757:	8b 45 d4             	mov    -0x2c(%ebp),%eax
    375a:	c6 00 63             	movb   $0x63,(%eax)

  // can one de-allocate?
  a = sbrk(0);
    375d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    3764:	e8 7b 0d 00 00       	call   44e4 <sbrk>
    3769:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c = sbrk(-4096);
    376c:	c7 04 24 00 f0 ff ff 	movl   $0xfffff000,(%esp)
    3773:	e8 6c 0d 00 00       	call   44e4 <sbrk>
    3778:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if(c == (char*)0xffffffff){
    377b:	83 7d e0 ff          	cmpl   $0xffffffff,-0x20(%ebp)
    377f:	75 21                	jne    37a2 <sbrktest+0x1ef>
    printf(stdout, "sbrk could not deallocate\n");
    3781:	a1 68 68 00 00       	mov    0x6868,%eax
    3786:	c7 44 24 04 26 5e 00 	movl   $0x5e26,0x4(%esp)
    378d:	00 
    378e:	89 04 24             	mov    %eax,(%esp)
    3791:	e8 4d 0e 00 00       	call   45e3 <printf>
    exit(EXIT_STATUS_DEFAULT);
    3796:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    379d:	e8 ba 0c 00 00       	call   445c <exit>
  }
  c = sbrk(0);
    37a2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    37a9:	e8 36 0d 00 00       	call   44e4 <sbrk>
    37ae:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if(c != a - 4096){
    37b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
    37b4:	2d 00 10 00 00       	sub    $0x1000,%eax
    37b9:	3b 45 e0             	cmp    -0x20(%ebp),%eax
    37bc:	74 2f                	je     37ed <sbrktest+0x23a>
    printf(stdout, "sbrk deallocation produced wrong address, a %x c %x\n", a, c);
    37be:	a1 68 68 00 00       	mov    0x6868,%eax
    37c3:	8b 55 e0             	mov    -0x20(%ebp),%edx
    37c6:	89 54 24 0c          	mov    %edx,0xc(%esp)
    37ca:	8b 55 f4             	mov    -0xc(%ebp),%edx
    37cd:	89 54 24 08          	mov    %edx,0x8(%esp)
    37d1:	c7 44 24 04 44 5e 00 	movl   $0x5e44,0x4(%esp)
    37d8:	00 
    37d9:	89 04 24             	mov    %eax,(%esp)
    37dc:	e8 02 0e 00 00       	call   45e3 <printf>
    exit(EXIT_STATUS_DEFAULT);
    37e1:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    37e8:	e8 6f 0c 00 00       	call   445c <exit>
  }

  // can one re-allocate that page?
  a = sbrk(0);
    37ed:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    37f4:	e8 eb 0c 00 00       	call   44e4 <sbrk>
    37f9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c = sbrk(4096);
    37fc:	c7 04 24 00 10 00 00 	movl   $0x1000,(%esp)
    3803:	e8 dc 0c 00 00       	call   44e4 <sbrk>
    3808:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if(c != a || sbrk(0) != a + 4096){
    380b:	8b 45 e0             	mov    -0x20(%ebp),%eax
    380e:	3b 45 f4             	cmp    -0xc(%ebp),%eax
    3811:	75 19                	jne    382c <sbrktest+0x279>
    3813:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    381a:	e8 c5 0c 00 00       	call   44e4 <sbrk>
    381f:	8b 55 f4             	mov    -0xc(%ebp),%edx
    3822:	81 c2 00 10 00 00    	add    $0x1000,%edx
    3828:	39 d0                	cmp    %edx,%eax
    382a:	74 2f                	je     385b <sbrktest+0x2a8>
    printf(stdout, "sbrk re-allocation failed, a %x c %x\n", a, c);
    382c:	a1 68 68 00 00       	mov    0x6868,%eax
    3831:	8b 55 e0             	mov    -0x20(%ebp),%edx
    3834:	89 54 24 0c          	mov    %edx,0xc(%esp)
    3838:	8b 55 f4             	mov    -0xc(%ebp),%edx
    383b:	89 54 24 08          	mov    %edx,0x8(%esp)
    383f:	c7 44 24 04 7c 5e 00 	movl   $0x5e7c,0x4(%esp)
    3846:	00 
    3847:	89 04 24             	mov    %eax,(%esp)
    384a:	e8 94 0d 00 00       	call   45e3 <printf>
    exit(EXIT_STATUS_DEFAULT);
    384f:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    3856:	e8 01 0c 00 00       	call   445c <exit>
  }
  if(*lastaddr == 99){
    385b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
    385e:	0f b6 00             	movzbl (%eax),%eax
    3861:	3c 63                	cmp    $0x63,%al
    3863:	75 21                	jne    3886 <sbrktest+0x2d3>
    // should be zero
    printf(stdout, "sbrk de-allocation didn't really deallocate\n");
    3865:	a1 68 68 00 00       	mov    0x6868,%eax
    386a:	c7 44 24 04 a4 5e 00 	movl   $0x5ea4,0x4(%esp)
    3871:	00 
    3872:	89 04 24             	mov    %eax,(%esp)
    3875:	e8 69 0d 00 00       	call   45e3 <printf>
    exit(EXIT_STATUS_DEFAULT);
    387a:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    3881:	e8 d6 0b 00 00       	call   445c <exit>
  }

  a = sbrk(0);
    3886:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    388d:	e8 52 0c 00 00       	call   44e4 <sbrk>
    3892:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c = sbrk(-(sbrk(0) - oldbrk));
    3895:	8b 5d ec             	mov    -0x14(%ebp),%ebx
    3898:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    389f:	e8 40 0c 00 00       	call   44e4 <sbrk>
    38a4:	89 da                	mov    %ebx,%edx
    38a6:	29 c2                	sub    %eax,%edx
    38a8:	89 d0                	mov    %edx,%eax
    38aa:	89 04 24             	mov    %eax,(%esp)
    38ad:	e8 32 0c 00 00       	call   44e4 <sbrk>
    38b2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if(c != a){
    38b5:	8b 45 e0             	mov    -0x20(%ebp),%eax
    38b8:	3b 45 f4             	cmp    -0xc(%ebp),%eax
    38bb:	74 2f                	je     38ec <sbrktest+0x339>
    printf(stdout, "sbrk downsize failed, a %x c %x\n", a, c);
    38bd:	a1 68 68 00 00       	mov    0x6868,%eax
    38c2:	8b 55 e0             	mov    -0x20(%ebp),%edx
    38c5:	89 54 24 0c          	mov    %edx,0xc(%esp)
    38c9:	8b 55 f4             	mov    -0xc(%ebp),%edx
    38cc:	89 54 24 08          	mov    %edx,0x8(%esp)
    38d0:	c7 44 24 04 d4 5e 00 	movl   $0x5ed4,0x4(%esp)
    38d7:	00 
    38d8:	89 04 24             	mov    %eax,(%esp)
    38db:	e8 03 0d 00 00       	call   45e3 <printf>
    exit(EXIT_STATUS_DEFAULT);
    38e0:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    38e7:	e8 70 0b 00 00       	call   445c <exit>
  }
  
  // can we read the kernel's memory?
  for(a = (char*)(KERNBASE); a < (char*) (KERNBASE+2000000); a += 50000){
    38ec:	c7 45 f4 00 00 00 80 	movl   $0x80000000,-0xc(%ebp)
    38f3:	e9 90 00 00 00       	jmp    3988 <sbrktest+0x3d5>
    ppid = getpid();
    38f8:	e8 df 0b 00 00       	call   44dc <getpid>
    38fd:	89 45 d0             	mov    %eax,-0x30(%ebp)
    pid = fork();
    3900:	e8 4f 0b 00 00       	call   4454 <fork>
    3905:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(pid < 0){
    3908:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
    390c:	79 21                	jns    392f <sbrktest+0x37c>
      printf(stdout, "fork failed\n");
    390e:	a1 68 68 00 00       	mov    0x6868,%eax
    3913:	c7 44 24 04 49 4a 00 	movl   $0x4a49,0x4(%esp)
    391a:	00 
    391b:	89 04 24             	mov    %eax,(%esp)
    391e:	e8 c0 0c 00 00       	call   45e3 <printf>
      exit(EXIT_STATUS_DEFAULT);
    3923:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    392a:	e8 2d 0b 00 00       	call   445c <exit>
    }
    if(pid == 0){
    392f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
    3933:	75 40                	jne    3975 <sbrktest+0x3c2>
      printf(stdout, "oops could read %x = %x\n", a, *a);
    3935:	8b 45 f4             	mov    -0xc(%ebp),%eax
    3938:	0f b6 00             	movzbl (%eax),%eax
    393b:	0f be d0             	movsbl %al,%edx
    393e:	a1 68 68 00 00       	mov    0x6868,%eax
    3943:	89 54 24 0c          	mov    %edx,0xc(%esp)
    3947:	8b 55 f4             	mov    -0xc(%ebp),%edx
    394a:	89 54 24 08          	mov    %edx,0x8(%esp)
    394e:	c7 44 24 04 f5 5e 00 	movl   $0x5ef5,0x4(%esp)
    3955:	00 
    3956:	89 04 24             	mov    %eax,(%esp)
    3959:	e8 85 0c 00 00       	call   45e3 <printf>
      kill(ppid);
    395e:	8b 45 d0             	mov    -0x30(%ebp),%eax
    3961:	89 04 24             	mov    %eax,(%esp)
    3964:	e8 23 0b 00 00       	call   448c <kill>
      exit(EXIT_STATUS_DEFAULT);
    3969:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    3970:	e8 e7 0a 00 00       	call   445c <exit>
    }
    wait(0);
    3975:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    397c:	e8 e3 0a 00 00       	call   4464 <wait>
    printf(stdout, "sbrk downsize failed, a %x c %x\n", a, c);
    exit(EXIT_STATUS_DEFAULT);
  }
  
  // can we read the kernel's memory?
  for(a = (char*)(KERNBASE); a < (char*) (KERNBASE+2000000); a += 50000){
    3981:	81 45 f4 50 c3 00 00 	addl   $0xc350,-0xc(%ebp)
    3988:	81 7d f4 7f 84 1e 80 	cmpl   $0x801e847f,-0xc(%ebp)
    398f:	0f 86 63 ff ff ff    	jbe    38f8 <sbrktest+0x345>
    wait(0);
  }

  // if we run the system out of memory, does it clean up the last
  // failed allocation?
  if(pipe(fds) != 0){
    3995:	8d 45 c8             	lea    -0x38(%ebp),%eax
    3998:	89 04 24             	mov    %eax,(%esp)
    399b:	e8 cc 0a 00 00       	call   446c <pipe>
    39a0:	85 c0                	test   %eax,%eax
    39a2:	74 20                	je     39c4 <sbrktest+0x411>
    printf(1, "pipe() failed\n");
    39a4:	c7 44 24 04 1a 4e 00 	movl   $0x4e1a,0x4(%esp)
    39ab:	00 
    39ac:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    39b3:	e8 2b 0c 00 00       	call   45e3 <printf>
    exit(EXIT_STATUS_DEFAULT);
    39b8:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    39bf:	e8 98 0a 00 00       	call   445c <exit>
  }
  for(i = 0; i < sizeof(pids)/sizeof(pids[0]); i++){
    39c4:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    39cb:	e9 89 00 00 00       	jmp    3a59 <sbrktest+0x4a6>
    if((pids[i] = fork()) == 0){
    39d0:	e8 7f 0a 00 00       	call   4454 <fork>
    39d5:	8b 55 f0             	mov    -0x10(%ebp),%edx
    39d8:	89 44 95 a0          	mov    %eax,-0x60(%ebp,%edx,4)
    39dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
    39df:	8b 44 85 a0          	mov    -0x60(%ebp,%eax,4),%eax
    39e3:	85 c0                	test   %eax,%eax
    39e5:	75 48                	jne    3a2f <sbrktest+0x47c>
      // allocate a lot of memory
      sbrk(BIG - (uint)sbrk(0));
    39e7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    39ee:	e8 f1 0a 00 00       	call   44e4 <sbrk>
    39f3:	ba 00 00 40 06       	mov    $0x6400000,%edx
    39f8:	89 d1                	mov    %edx,%ecx
    39fa:	29 c1                	sub    %eax,%ecx
    39fc:	89 c8                	mov    %ecx,%eax
    39fe:	89 04 24             	mov    %eax,(%esp)
    3a01:	e8 de 0a 00 00       	call   44e4 <sbrk>
      write(fds[1], "x", 1);
    3a06:	8b 45 cc             	mov    -0x34(%ebp),%eax
    3a09:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
    3a10:	00 
    3a11:	c7 44 24 04 7f 4e 00 	movl   $0x4e7f,0x4(%esp)
    3a18:	00 
    3a19:	89 04 24             	mov    %eax,(%esp)
    3a1c:	e8 5b 0a 00 00       	call   447c <write>
      // sit around until killed
      for(;;) sleep(1000);
    3a21:	c7 04 24 e8 03 00 00 	movl   $0x3e8,(%esp)
    3a28:	e8 bf 0a 00 00       	call   44ec <sleep>
    3a2d:	eb f2                	jmp    3a21 <sbrktest+0x46e>
    }
    if(pids[i] != -1)
    3a2f:	8b 45 f0             	mov    -0x10(%ebp),%eax
    3a32:	8b 44 85 a0          	mov    -0x60(%ebp,%eax,4),%eax
    3a36:	83 f8 ff             	cmp    $0xffffffff,%eax
    3a39:	74 1a                	je     3a55 <sbrktest+0x4a2>
      read(fds[0], &scratch, 1);
    3a3b:	8b 45 c8             	mov    -0x38(%ebp),%eax
    3a3e:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
    3a45:	00 
    3a46:	8d 55 9f             	lea    -0x61(%ebp),%edx
    3a49:	89 54 24 04          	mov    %edx,0x4(%esp)
    3a4d:	89 04 24             	mov    %eax,(%esp)
    3a50:	e8 1f 0a 00 00       	call   4474 <read>
  // failed allocation?
  if(pipe(fds) != 0){
    printf(1, "pipe() failed\n");
    exit(EXIT_STATUS_DEFAULT);
  }
  for(i = 0; i < sizeof(pids)/sizeof(pids[0]); i++){
    3a55:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
    3a59:	8b 45 f0             	mov    -0x10(%ebp),%eax
    3a5c:	83 f8 09             	cmp    $0x9,%eax
    3a5f:	0f 86 6b ff ff ff    	jbe    39d0 <sbrktest+0x41d>
    if(pids[i] != -1)
      read(fds[0], &scratch, 1);
  }
  // if those failed allocations freed up the pages they did allocate,
  // we'll be able to allocate here
  c = sbrk(4096);
    3a65:	c7 04 24 00 10 00 00 	movl   $0x1000,(%esp)
    3a6c:	e8 73 0a 00 00       	call   44e4 <sbrk>
    3a71:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(i = 0; i < sizeof(pids)/sizeof(pids[0]); i++){
    3a74:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    3a7b:	eb 2e                	jmp    3aab <sbrktest+0x4f8>
    if(pids[i] == -1)
    3a7d:	8b 45 f0             	mov    -0x10(%ebp),%eax
    3a80:	8b 44 85 a0          	mov    -0x60(%ebp,%eax,4),%eax
    3a84:	83 f8 ff             	cmp    $0xffffffff,%eax
    3a87:	74 1d                	je     3aa6 <sbrktest+0x4f3>
      continue;
    kill(pids[i]);
    3a89:	8b 45 f0             	mov    -0x10(%ebp),%eax
    3a8c:	8b 44 85 a0          	mov    -0x60(%ebp,%eax,4),%eax
    3a90:	89 04 24             	mov    %eax,(%esp)
    3a93:	e8 f4 09 00 00       	call   448c <kill>
    wait(0);
    3a98:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    3a9f:	e8 c0 09 00 00       	call   4464 <wait>
    3aa4:	eb 01                	jmp    3aa7 <sbrktest+0x4f4>
  // if those failed allocations freed up the pages they did allocate,
  // we'll be able to allocate here
  c = sbrk(4096);
  for(i = 0; i < sizeof(pids)/sizeof(pids[0]); i++){
    if(pids[i] == -1)
      continue;
    3aa6:	90                   	nop
      read(fds[0], &scratch, 1);
  }
  // if those failed allocations freed up the pages they did allocate,
  // we'll be able to allocate here
  c = sbrk(4096);
  for(i = 0; i < sizeof(pids)/sizeof(pids[0]); i++){
    3aa7:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
    3aab:	8b 45 f0             	mov    -0x10(%ebp),%eax
    3aae:	83 f8 09             	cmp    $0x9,%eax
    3ab1:	76 ca                	jbe    3a7d <sbrktest+0x4ca>
    if(pids[i] == -1)
      continue;
    kill(pids[i]);
    wait(0);
  }
  if(c == (char*)0xffffffff){
    3ab3:	83 7d e0 ff          	cmpl   $0xffffffff,-0x20(%ebp)
    3ab7:	75 21                	jne    3ada <sbrktest+0x527>
    printf(stdout, "failed sbrk leaked memory\n");
    3ab9:	a1 68 68 00 00       	mov    0x6868,%eax
    3abe:	c7 44 24 04 0e 5f 00 	movl   $0x5f0e,0x4(%esp)
    3ac5:	00 
    3ac6:	89 04 24             	mov    %eax,(%esp)
    3ac9:	e8 15 0b 00 00       	call   45e3 <printf>
    exit(EXIT_STATUS_DEFAULT);
    3ace:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    3ad5:	e8 82 09 00 00       	call   445c <exit>
  }

  if(sbrk(0) > oldbrk)
    3ada:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    3ae1:	e8 fe 09 00 00       	call   44e4 <sbrk>
    3ae6:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    3ae9:	76 1d                	jbe    3b08 <sbrktest+0x555>
    sbrk(-(sbrk(0) - oldbrk));
    3aeb:	8b 5d ec             	mov    -0x14(%ebp),%ebx
    3aee:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    3af5:	e8 ea 09 00 00       	call   44e4 <sbrk>
    3afa:	89 da                	mov    %ebx,%edx
    3afc:	29 c2                	sub    %eax,%edx
    3afe:	89 d0                	mov    %edx,%eax
    3b00:	89 04 24             	mov    %eax,(%esp)
    3b03:	e8 dc 09 00 00       	call   44e4 <sbrk>

  printf(stdout, "sbrk test OK\n");
    3b08:	a1 68 68 00 00       	mov    0x6868,%eax
    3b0d:	c7 44 24 04 29 5f 00 	movl   $0x5f29,0x4(%esp)
    3b14:	00 
    3b15:	89 04 24             	mov    %eax,(%esp)
    3b18:	e8 c6 0a 00 00       	call   45e3 <printf>
}
    3b1d:	81 c4 84 00 00 00    	add    $0x84,%esp
    3b23:	5b                   	pop    %ebx
    3b24:	5d                   	pop    %ebp
    3b25:	c3                   	ret    

00003b26 <validateint>:

void
validateint(int *p)
{
    3b26:	55                   	push   %ebp
    3b27:	89 e5                	mov    %esp,%ebp
    3b29:	56                   	push   %esi
    3b2a:	53                   	push   %ebx
    3b2b:	83 ec 14             	sub    $0x14,%esp
  int res;
  asm("mov %%esp, %%ebx\n\t"
    3b2e:	c7 45 e4 0d 00 00 00 	movl   $0xd,-0x1c(%ebp)
    3b35:	8b 55 08             	mov    0x8(%ebp),%edx
    3b38:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    3b3b:	89 d1                	mov    %edx,%ecx
    3b3d:	89 e3                	mov    %esp,%ebx
    3b3f:	89 cc                	mov    %ecx,%esp
    3b41:	cd 40                	int    $0x40
    3b43:	89 dc                	mov    %ebx,%esp
    3b45:	89 c6                	mov    %eax,%esi
    3b47:	89 75 f4             	mov    %esi,-0xc(%ebp)
      "int %2\n\t"
      "mov %%ebx, %%esp" :
      "=a" (res) :
      "a" (SYS_sleep), "n" (T_SYSCALL), "c" (p) :
      "ebx");
}
    3b4a:	83 c4 14             	add    $0x14,%esp
    3b4d:	5b                   	pop    %ebx
    3b4e:	5e                   	pop    %esi
    3b4f:	5d                   	pop    %ebp
    3b50:	c3                   	ret    

00003b51 <validatetest>:

void
validatetest(void)
{
    3b51:	55                   	push   %ebp
    3b52:	89 e5                	mov    %esp,%ebp
    3b54:	83 ec 28             	sub    $0x28,%esp
  int hi, pid;
  uint p;

  printf(stdout, "validate test\n");
    3b57:	a1 68 68 00 00       	mov    0x6868,%eax
    3b5c:	c7 44 24 04 37 5f 00 	movl   $0x5f37,0x4(%esp)
    3b63:	00 
    3b64:	89 04 24             	mov    %eax,(%esp)
    3b67:	e8 77 0a 00 00       	call   45e3 <printf>
  hi = 1100*1024;
    3b6c:	c7 45 f0 00 30 11 00 	movl   $0x113000,-0x10(%ebp)

  for(p = 0; p <= (uint)hi; p += 4096){
    3b73:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    3b7a:	e9 94 00 00 00       	jmp    3c13 <validatetest+0xc2>
    if((pid = fork()) == 0){
    3b7f:	e8 d0 08 00 00       	call   4454 <fork>
    3b84:	89 45 ec             	mov    %eax,-0x14(%ebp)
    3b87:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    3b8b:	75 17                	jne    3ba4 <validatetest+0x53>
      // try to crash the kernel by passing in a badly placed integer
      validateint((int*)p);
    3b8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
    3b90:	89 04 24             	mov    %eax,(%esp)
    3b93:	e8 8e ff ff ff       	call   3b26 <validateint>
      exit(EXIT_STATUS_DEFAULT);
    3b98:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    3b9f:	e8 b8 08 00 00       	call   445c <exit>
    }
    sleep(0);
    3ba4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    3bab:	e8 3c 09 00 00       	call   44ec <sleep>
    sleep(0);
    3bb0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    3bb7:	e8 30 09 00 00       	call   44ec <sleep>
    kill(pid);
    3bbc:	8b 45 ec             	mov    -0x14(%ebp),%eax
    3bbf:	89 04 24             	mov    %eax,(%esp)
    3bc2:	e8 c5 08 00 00       	call   448c <kill>
    wait(0);
    3bc7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    3bce:	e8 91 08 00 00       	call   4464 <wait>

    // try to crash the kernel by passing in a bad string pointer
    if(link("nosuchfile", (char*)p) != -1){
    3bd3:	8b 45 f4             	mov    -0xc(%ebp),%eax
    3bd6:	89 44 24 04          	mov    %eax,0x4(%esp)
    3bda:	c7 04 24 46 5f 00 00 	movl   $0x5f46,(%esp)
    3be1:	e8 d6 08 00 00       	call   44bc <link>
    3be6:	83 f8 ff             	cmp    $0xffffffff,%eax
    3be9:	74 21                	je     3c0c <validatetest+0xbb>
      printf(stdout, "link should not succeed\n");
    3beb:	a1 68 68 00 00       	mov    0x6868,%eax
    3bf0:	c7 44 24 04 51 5f 00 	movl   $0x5f51,0x4(%esp)
    3bf7:	00 
    3bf8:	89 04 24             	mov    %eax,(%esp)
    3bfb:	e8 e3 09 00 00       	call   45e3 <printf>
      exit(EXIT_STATUS_DEFAULT);
    3c00:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    3c07:	e8 50 08 00 00       	call   445c <exit>
  uint p;

  printf(stdout, "validate test\n");
  hi = 1100*1024;

  for(p = 0; p <= (uint)hi; p += 4096){
    3c0c:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    3c13:	8b 45 f0             	mov    -0x10(%ebp),%eax
    3c16:	3b 45 f4             	cmp    -0xc(%ebp),%eax
    3c19:	0f 83 60 ff ff ff    	jae    3b7f <validatetest+0x2e>
      printf(stdout, "link should not succeed\n");
      exit(EXIT_STATUS_DEFAULT);
    }
  }

  printf(stdout, "validate ok\n");
    3c1f:	a1 68 68 00 00       	mov    0x6868,%eax
    3c24:	c7 44 24 04 6a 5f 00 	movl   $0x5f6a,0x4(%esp)
    3c2b:	00 
    3c2c:	89 04 24             	mov    %eax,(%esp)
    3c2f:	e8 af 09 00 00       	call   45e3 <printf>
}
    3c34:	c9                   	leave  
    3c35:	c3                   	ret    

00003c36 <bsstest>:

// does unintialized data start out zero?
char uninit[10000];
void
bsstest(void)
{
    3c36:	55                   	push   %ebp
    3c37:	89 e5                	mov    %esp,%ebp
    3c39:	83 ec 28             	sub    $0x28,%esp
  int i;

  printf(stdout, "bss test\n");
    3c3c:	a1 68 68 00 00       	mov    0x6868,%eax
    3c41:	c7 44 24 04 77 5f 00 	movl   $0x5f77,0x4(%esp)
    3c48:	00 
    3c49:	89 04 24             	mov    %eax,(%esp)
    3c4c:	e8 92 09 00 00       	call   45e3 <printf>
  for(i = 0; i < sizeof(uninit); i++){
    3c51:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    3c58:	eb 34                	jmp    3c8e <bsstest+0x58>
    if(uninit[i] != '\0'){
    3c5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
    3c5d:	05 40 69 00 00       	add    $0x6940,%eax
    3c62:	0f b6 00             	movzbl (%eax),%eax
    3c65:	84 c0                	test   %al,%al
    3c67:	74 21                	je     3c8a <bsstest+0x54>
      printf(stdout, "bss test failed\n");
    3c69:	a1 68 68 00 00       	mov    0x6868,%eax
    3c6e:	c7 44 24 04 81 5f 00 	movl   $0x5f81,0x4(%esp)
    3c75:	00 
    3c76:	89 04 24             	mov    %eax,(%esp)
    3c79:	e8 65 09 00 00       	call   45e3 <printf>
      exit(EXIT_STATUS_DEFAULT);
    3c7e:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    3c85:	e8 d2 07 00 00       	call   445c <exit>
bsstest(void)
{
  int i;

  printf(stdout, "bss test\n");
  for(i = 0; i < sizeof(uninit); i++){
    3c8a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    3c8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
    3c91:	3d 0f 27 00 00       	cmp    $0x270f,%eax
    3c96:	76 c2                	jbe    3c5a <bsstest+0x24>
    if(uninit[i] != '\0'){
      printf(stdout, "bss test failed\n");
      exit(EXIT_STATUS_DEFAULT);
    }
  }
  printf(stdout, "bss test ok\n");
    3c98:	a1 68 68 00 00       	mov    0x6868,%eax
    3c9d:	c7 44 24 04 92 5f 00 	movl   $0x5f92,0x4(%esp)
    3ca4:	00 
    3ca5:	89 04 24             	mov    %eax,(%esp)
    3ca8:	e8 36 09 00 00       	call   45e3 <printf>
}
    3cad:	c9                   	leave  
    3cae:	c3                   	ret    

00003caf <bigargtest>:
// does exec return an error if the arguments
// are larger than a page? or does it write
// below the stack and wreck the instructions/data?
void
bigargtest(void)
{
    3caf:	55                   	push   %ebp
    3cb0:	89 e5                	mov    %esp,%ebp
    3cb2:	83 ec 28             	sub    $0x28,%esp
  int pid, fd;

  unlink("bigarg-ok");
    3cb5:	c7 04 24 9f 5f 00 00 	movl   $0x5f9f,(%esp)
    3cbc:	e8 eb 07 00 00       	call   44ac <unlink>
  pid = fork();
    3cc1:	e8 8e 07 00 00       	call   4454 <fork>
    3cc6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(pid == 0){
    3cc9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    3ccd:	0f 85 97 00 00 00    	jne    3d6a <bigargtest+0xbb>
    static char *args[MAXARG];
    int i;
    for(i = 0; i < MAXARG-1; i++)
    3cd3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    3cda:	eb 12                	jmp    3cee <bigargtest+0x3f>
      args[i] = "bigargs test: failed\n                                                                                                                                                                                                       ";
    3cdc:	8b 45 f4             	mov    -0xc(%ebp),%eax
    3cdf:	c7 04 85 a0 68 00 00 	movl   $0x5fac,0x68a0(,%eax,4)
    3ce6:	ac 5f 00 00 
  unlink("bigarg-ok");
  pid = fork();
  if(pid == 0){
    static char *args[MAXARG];
    int i;
    for(i = 0; i < MAXARG-1; i++)
    3cea:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    3cee:	83 7d f4 1e          	cmpl   $0x1e,-0xc(%ebp)
    3cf2:	7e e8                	jle    3cdc <bigargtest+0x2d>
      args[i] = "bigargs test: failed\n                                                                                                                                                                                                       ";
    args[MAXARG-1] = 0;
    3cf4:	c7 05 1c 69 00 00 00 	movl   $0x0,0x691c
    3cfb:	00 00 00 
    printf(stdout, "bigarg test\n");
    3cfe:	a1 68 68 00 00       	mov    0x6868,%eax
    3d03:	c7 44 24 04 89 60 00 	movl   $0x6089,0x4(%esp)
    3d0a:	00 
    3d0b:	89 04 24             	mov    %eax,(%esp)
    3d0e:	e8 d0 08 00 00       	call   45e3 <printf>
    exec("echo", args);
    3d13:	c7 44 24 04 a0 68 00 	movl   $0x68a0,0x4(%esp)
    3d1a:	00 
    3d1b:	c7 04 24 a8 49 00 00 	movl   $0x49a8,(%esp)
    3d22:	e8 6d 07 00 00       	call   4494 <exec>
    printf(stdout, "bigarg test ok\n");
    3d27:	a1 68 68 00 00       	mov    0x6868,%eax
    3d2c:	c7 44 24 04 96 60 00 	movl   $0x6096,0x4(%esp)
    3d33:	00 
    3d34:	89 04 24             	mov    %eax,(%esp)
    3d37:	e8 a7 08 00 00       	call   45e3 <printf>
    fd = open("bigarg-ok", O_CREATE);
    3d3c:	c7 44 24 04 00 02 00 	movl   $0x200,0x4(%esp)
    3d43:	00 
    3d44:	c7 04 24 9f 5f 00 00 	movl   $0x5f9f,(%esp)
    3d4b:	e8 4c 07 00 00       	call   449c <open>
    3d50:	89 45 ec             	mov    %eax,-0x14(%ebp)
    close(fd);
    3d53:	8b 45 ec             	mov    -0x14(%ebp),%eax
    3d56:	89 04 24             	mov    %eax,(%esp)
    3d59:	e8 26 07 00 00       	call   4484 <close>
    exit(EXIT_STATUS_DEFAULT);
    3d5e:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    3d65:	e8 f2 06 00 00       	call   445c <exit>
  } else if(pid < 0){
    3d6a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    3d6e:	79 21                	jns    3d91 <bigargtest+0xe2>
    printf(stdout, "bigargtest: fork failed\n");
    3d70:	a1 68 68 00 00       	mov    0x6868,%eax
    3d75:	c7 44 24 04 a6 60 00 	movl   $0x60a6,0x4(%esp)
    3d7c:	00 
    3d7d:	89 04 24             	mov    %eax,(%esp)
    3d80:	e8 5e 08 00 00       	call   45e3 <printf>
    exit(EXIT_STATUS_DEFAULT);
    3d85:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    3d8c:	e8 cb 06 00 00       	call   445c <exit>
  }
  wait(0);
    3d91:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    3d98:	e8 c7 06 00 00       	call   4464 <wait>
  fd = open("bigarg-ok", 0);
    3d9d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    3da4:	00 
    3da5:	c7 04 24 9f 5f 00 00 	movl   $0x5f9f,(%esp)
    3dac:	e8 eb 06 00 00       	call   449c <open>
    3db1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(fd < 0){
    3db4:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    3db8:	79 21                	jns    3ddb <bigargtest+0x12c>
    printf(stdout, "bigarg test failed!\n");
    3dba:	a1 68 68 00 00       	mov    0x6868,%eax
    3dbf:	c7 44 24 04 bf 60 00 	movl   $0x60bf,0x4(%esp)
    3dc6:	00 
    3dc7:	89 04 24             	mov    %eax,(%esp)
    3dca:	e8 14 08 00 00       	call   45e3 <printf>
    exit(EXIT_STATUS_DEFAULT);
    3dcf:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    3dd6:	e8 81 06 00 00       	call   445c <exit>
  }
  close(fd);
    3ddb:	8b 45 ec             	mov    -0x14(%ebp),%eax
    3dde:	89 04 24             	mov    %eax,(%esp)
    3de1:	e8 9e 06 00 00       	call   4484 <close>
  unlink("bigarg-ok");
    3de6:	c7 04 24 9f 5f 00 00 	movl   $0x5f9f,(%esp)
    3ded:	e8 ba 06 00 00       	call   44ac <unlink>
}
    3df2:	c9                   	leave  
    3df3:	c3                   	ret    

00003df4 <fsfull>:

// what happens when the file system runs out of blocks?
// answer: balloc panics, so this test is not useful.
void
fsfull()
{
    3df4:	55                   	push   %ebp
    3df5:	89 e5                	mov    %esp,%ebp
    3df7:	53                   	push   %ebx
    3df8:	83 ec 74             	sub    $0x74,%esp
  int nfiles;
  int fsblocks = 0;
    3dfb:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)

  printf(1, "fsfull test\n");
    3e02:	c7 44 24 04 d4 60 00 	movl   $0x60d4,0x4(%esp)
    3e09:	00 
    3e0a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    3e11:	e8 cd 07 00 00       	call   45e3 <printf>

  for(nfiles = 0; ; nfiles++){
    3e16:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    char name[64];
    name[0] = 'f';
    3e1d:	c6 45 a4 66          	movb   $0x66,-0x5c(%ebp)
    name[1] = '0' + nfiles / 1000;
    3e21:	8b 4d f4             	mov    -0xc(%ebp),%ecx
    3e24:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
    3e29:	89 c8                	mov    %ecx,%eax
    3e2b:	f7 ea                	imul   %edx
    3e2d:	c1 fa 06             	sar    $0x6,%edx
    3e30:	89 c8                	mov    %ecx,%eax
    3e32:	c1 f8 1f             	sar    $0x1f,%eax
    3e35:	89 d1                	mov    %edx,%ecx
    3e37:	29 c1                	sub    %eax,%ecx
    3e39:	89 c8                	mov    %ecx,%eax
    3e3b:	83 c0 30             	add    $0x30,%eax
    3e3e:	88 45 a5             	mov    %al,-0x5b(%ebp)
    name[2] = '0' + (nfiles % 1000) / 100;
    3e41:	8b 5d f4             	mov    -0xc(%ebp),%ebx
    3e44:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
    3e49:	89 d8                	mov    %ebx,%eax
    3e4b:	f7 ea                	imul   %edx
    3e4d:	c1 fa 06             	sar    $0x6,%edx
    3e50:	89 d8                	mov    %ebx,%eax
    3e52:	c1 f8 1f             	sar    $0x1f,%eax
    3e55:	89 d1                	mov    %edx,%ecx
    3e57:	29 c1                	sub    %eax,%ecx
    3e59:	69 c1 e8 03 00 00    	imul   $0x3e8,%ecx,%eax
    3e5f:	89 d9                	mov    %ebx,%ecx
    3e61:	29 c1                	sub    %eax,%ecx
    3e63:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
    3e68:	89 c8                	mov    %ecx,%eax
    3e6a:	f7 ea                	imul   %edx
    3e6c:	c1 fa 05             	sar    $0x5,%edx
    3e6f:	89 c8                	mov    %ecx,%eax
    3e71:	c1 f8 1f             	sar    $0x1f,%eax
    3e74:	89 d1                	mov    %edx,%ecx
    3e76:	29 c1                	sub    %eax,%ecx
    3e78:	89 c8                	mov    %ecx,%eax
    3e7a:	83 c0 30             	add    $0x30,%eax
    3e7d:	88 45 a6             	mov    %al,-0x5a(%ebp)
    name[3] = '0' + (nfiles % 100) / 10;
    3e80:	8b 5d f4             	mov    -0xc(%ebp),%ebx
    3e83:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
    3e88:	89 d8                	mov    %ebx,%eax
    3e8a:	f7 ea                	imul   %edx
    3e8c:	c1 fa 05             	sar    $0x5,%edx
    3e8f:	89 d8                	mov    %ebx,%eax
    3e91:	c1 f8 1f             	sar    $0x1f,%eax
    3e94:	89 d1                	mov    %edx,%ecx
    3e96:	29 c1                	sub    %eax,%ecx
    3e98:	6b c1 64             	imul   $0x64,%ecx,%eax
    3e9b:	89 d9                	mov    %ebx,%ecx
    3e9d:	29 c1                	sub    %eax,%ecx
    3e9f:	ba 67 66 66 66       	mov    $0x66666667,%edx
    3ea4:	89 c8                	mov    %ecx,%eax
    3ea6:	f7 ea                	imul   %edx
    3ea8:	c1 fa 02             	sar    $0x2,%edx
    3eab:	89 c8                	mov    %ecx,%eax
    3ead:	c1 f8 1f             	sar    $0x1f,%eax
    3eb0:	89 d1                	mov    %edx,%ecx
    3eb2:	29 c1                	sub    %eax,%ecx
    3eb4:	89 c8                	mov    %ecx,%eax
    3eb6:	83 c0 30             	add    $0x30,%eax
    3eb9:	88 45 a7             	mov    %al,-0x59(%ebp)
    name[4] = '0' + (nfiles % 10);
    3ebc:	8b 4d f4             	mov    -0xc(%ebp),%ecx
    3ebf:	ba 67 66 66 66       	mov    $0x66666667,%edx
    3ec4:	89 c8                	mov    %ecx,%eax
    3ec6:	f7 ea                	imul   %edx
    3ec8:	c1 fa 02             	sar    $0x2,%edx
    3ecb:	89 c8                	mov    %ecx,%eax
    3ecd:	c1 f8 1f             	sar    $0x1f,%eax
    3ed0:	29 c2                	sub    %eax,%edx
    3ed2:	89 d0                	mov    %edx,%eax
    3ed4:	c1 e0 02             	shl    $0x2,%eax
    3ed7:	01 d0                	add    %edx,%eax
    3ed9:	01 c0                	add    %eax,%eax
    3edb:	89 ca                	mov    %ecx,%edx
    3edd:	29 c2                	sub    %eax,%edx
    3edf:	89 d0                	mov    %edx,%eax
    3ee1:	83 c0 30             	add    $0x30,%eax
    3ee4:	88 45 a8             	mov    %al,-0x58(%ebp)
    name[5] = '\0';
    3ee7:	c6 45 a9 00          	movb   $0x0,-0x57(%ebp)
    printf(1, "writing %s\n", name);
    3eeb:	8d 45 a4             	lea    -0x5c(%ebp),%eax
    3eee:	89 44 24 08          	mov    %eax,0x8(%esp)
    3ef2:	c7 44 24 04 e1 60 00 	movl   $0x60e1,0x4(%esp)
    3ef9:	00 
    3efa:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    3f01:	e8 dd 06 00 00       	call   45e3 <printf>
    int fd = open(name, O_CREATE|O_RDWR);
    3f06:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
    3f0d:	00 
    3f0e:	8d 45 a4             	lea    -0x5c(%ebp),%eax
    3f11:	89 04 24             	mov    %eax,(%esp)
    3f14:	e8 83 05 00 00       	call   449c <open>
    3f19:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(fd < 0){
    3f1c:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
    3f20:	79 1d                	jns    3f3f <fsfull+0x14b>
      printf(1, "open %s failed\n", name);
    3f22:	8d 45 a4             	lea    -0x5c(%ebp),%eax
    3f25:	89 44 24 08          	mov    %eax,0x8(%esp)
    3f29:	c7 44 24 04 ed 60 00 	movl   $0x60ed,0x4(%esp)
    3f30:	00 
    3f31:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    3f38:	e8 a6 06 00 00       	call   45e3 <printf>
      break;
    3f3d:	eb 71                	jmp    3fb0 <fsfull+0x1bc>
    }
    int total = 0;
    3f3f:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
    while(1){
      int cc = write(fd, buf, 512);
    3f46:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
    3f4d:	00 
    3f4e:	c7 44 24 04 60 90 00 	movl   $0x9060,0x4(%esp)
    3f55:	00 
    3f56:	8b 45 e8             	mov    -0x18(%ebp),%eax
    3f59:	89 04 24             	mov    %eax,(%esp)
    3f5c:	e8 1b 05 00 00       	call   447c <write>
    3f61:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      if(cc < 512)
    3f64:	81 7d e4 ff 01 00 00 	cmpl   $0x1ff,-0x1c(%ebp)
    3f6b:	7e 0c                	jle    3f79 <fsfull+0x185>
        break;
      total += cc;
    3f6d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    3f70:	01 45 ec             	add    %eax,-0x14(%ebp)
      fsblocks++;
    3f73:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
    }
    3f77:	eb cd                	jmp    3f46 <fsfull+0x152>
    }
    int total = 0;
    while(1){
      int cc = write(fd, buf, 512);
      if(cc < 512)
        break;
    3f79:	90                   	nop
      total += cc;
      fsblocks++;
    }
    printf(1, "wrote %d bytes\n", total);
    3f7a:	8b 45 ec             	mov    -0x14(%ebp),%eax
    3f7d:	89 44 24 08          	mov    %eax,0x8(%esp)
    3f81:	c7 44 24 04 fd 60 00 	movl   $0x60fd,0x4(%esp)
    3f88:	00 
    3f89:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    3f90:	e8 4e 06 00 00       	call   45e3 <printf>
    close(fd);
    3f95:	8b 45 e8             	mov    -0x18(%ebp),%eax
    3f98:	89 04 24             	mov    %eax,(%esp)
    3f9b:	e8 e4 04 00 00       	call   4484 <close>
    if(total == 0)
    3fa0:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    3fa4:	74 09                	je     3faf <fsfull+0x1bb>
  int nfiles;
  int fsblocks = 0;

  printf(1, "fsfull test\n");

  for(nfiles = 0; ; nfiles++){
    3fa6:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    }
    printf(1, "wrote %d bytes\n", total);
    close(fd);
    if(total == 0)
      break;
  }
    3faa:	e9 6e fe ff ff       	jmp    3e1d <fsfull+0x29>
      fsblocks++;
    }
    printf(1, "wrote %d bytes\n", total);
    close(fd);
    if(total == 0)
      break;
    3faf:	90                   	nop
  }

  while(nfiles >= 0){
    3fb0:	e9 dd 00 00 00       	jmp    4092 <fsfull+0x29e>
    char name[64];
    name[0] = 'f';
    3fb5:	c6 45 a4 66          	movb   $0x66,-0x5c(%ebp)
    name[1] = '0' + nfiles / 1000;
    3fb9:	8b 4d f4             	mov    -0xc(%ebp),%ecx
    3fbc:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
    3fc1:	89 c8                	mov    %ecx,%eax
    3fc3:	f7 ea                	imul   %edx
    3fc5:	c1 fa 06             	sar    $0x6,%edx
    3fc8:	89 c8                	mov    %ecx,%eax
    3fca:	c1 f8 1f             	sar    $0x1f,%eax
    3fcd:	89 d1                	mov    %edx,%ecx
    3fcf:	29 c1                	sub    %eax,%ecx
    3fd1:	89 c8                	mov    %ecx,%eax
    3fd3:	83 c0 30             	add    $0x30,%eax
    3fd6:	88 45 a5             	mov    %al,-0x5b(%ebp)
    name[2] = '0' + (nfiles % 1000) / 100;
    3fd9:	8b 5d f4             	mov    -0xc(%ebp),%ebx
    3fdc:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
    3fe1:	89 d8                	mov    %ebx,%eax
    3fe3:	f7 ea                	imul   %edx
    3fe5:	c1 fa 06             	sar    $0x6,%edx
    3fe8:	89 d8                	mov    %ebx,%eax
    3fea:	c1 f8 1f             	sar    $0x1f,%eax
    3fed:	89 d1                	mov    %edx,%ecx
    3fef:	29 c1                	sub    %eax,%ecx
    3ff1:	69 c1 e8 03 00 00    	imul   $0x3e8,%ecx,%eax
    3ff7:	89 d9                	mov    %ebx,%ecx
    3ff9:	29 c1                	sub    %eax,%ecx
    3ffb:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
    4000:	89 c8                	mov    %ecx,%eax
    4002:	f7 ea                	imul   %edx
    4004:	c1 fa 05             	sar    $0x5,%edx
    4007:	89 c8                	mov    %ecx,%eax
    4009:	c1 f8 1f             	sar    $0x1f,%eax
    400c:	89 d1                	mov    %edx,%ecx
    400e:	29 c1                	sub    %eax,%ecx
    4010:	89 c8                	mov    %ecx,%eax
    4012:	83 c0 30             	add    $0x30,%eax
    4015:	88 45 a6             	mov    %al,-0x5a(%ebp)
    name[3] = '0' + (nfiles % 100) / 10;
    4018:	8b 5d f4             	mov    -0xc(%ebp),%ebx
    401b:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
    4020:	89 d8                	mov    %ebx,%eax
    4022:	f7 ea                	imul   %edx
    4024:	c1 fa 05             	sar    $0x5,%edx
    4027:	89 d8                	mov    %ebx,%eax
    4029:	c1 f8 1f             	sar    $0x1f,%eax
    402c:	89 d1                	mov    %edx,%ecx
    402e:	29 c1                	sub    %eax,%ecx
    4030:	6b c1 64             	imul   $0x64,%ecx,%eax
    4033:	89 d9                	mov    %ebx,%ecx
    4035:	29 c1                	sub    %eax,%ecx
    4037:	ba 67 66 66 66       	mov    $0x66666667,%edx
    403c:	89 c8                	mov    %ecx,%eax
    403e:	f7 ea                	imul   %edx
    4040:	c1 fa 02             	sar    $0x2,%edx
    4043:	89 c8                	mov    %ecx,%eax
    4045:	c1 f8 1f             	sar    $0x1f,%eax
    4048:	89 d1                	mov    %edx,%ecx
    404a:	29 c1                	sub    %eax,%ecx
    404c:	89 c8                	mov    %ecx,%eax
    404e:	83 c0 30             	add    $0x30,%eax
    4051:	88 45 a7             	mov    %al,-0x59(%ebp)
    name[4] = '0' + (nfiles % 10);
    4054:	8b 4d f4             	mov    -0xc(%ebp),%ecx
    4057:	ba 67 66 66 66       	mov    $0x66666667,%edx
    405c:	89 c8                	mov    %ecx,%eax
    405e:	f7 ea                	imul   %edx
    4060:	c1 fa 02             	sar    $0x2,%edx
    4063:	89 c8                	mov    %ecx,%eax
    4065:	c1 f8 1f             	sar    $0x1f,%eax
    4068:	29 c2                	sub    %eax,%edx
    406a:	89 d0                	mov    %edx,%eax
    406c:	c1 e0 02             	shl    $0x2,%eax
    406f:	01 d0                	add    %edx,%eax
    4071:	01 c0                	add    %eax,%eax
    4073:	89 ca                	mov    %ecx,%edx
    4075:	29 c2                	sub    %eax,%edx
    4077:	89 d0                	mov    %edx,%eax
    4079:	83 c0 30             	add    $0x30,%eax
    407c:	88 45 a8             	mov    %al,-0x58(%ebp)
    name[5] = '\0';
    407f:	c6 45 a9 00          	movb   $0x0,-0x57(%ebp)
    unlink(name);
    4083:	8d 45 a4             	lea    -0x5c(%ebp),%eax
    4086:	89 04 24             	mov    %eax,(%esp)
    4089:	e8 1e 04 00 00       	call   44ac <unlink>
    nfiles--;
    408e:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
    close(fd);
    if(total == 0)
      break;
  }

  while(nfiles >= 0){
    4092:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    4096:	0f 89 19 ff ff ff    	jns    3fb5 <fsfull+0x1c1>
    name[5] = '\0';
    unlink(name);
    nfiles--;
  }

  printf(1, "fsfull test finished\n");
    409c:	c7 44 24 04 0d 61 00 	movl   $0x610d,0x4(%esp)
    40a3:	00 
    40a4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    40ab:	e8 33 05 00 00       	call   45e3 <printf>
}
    40b0:	83 c4 74             	add    $0x74,%esp
    40b3:	5b                   	pop    %ebx
    40b4:	5d                   	pop    %ebp
    40b5:	c3                   	ret    

000040b6 <rand>:

unsigned long randstate = 1;
unsigned int
rand()
{
    40b6:	55                   	push   %ebp
    40b7:	89 e5                	mov    %esp,%ebp
  randstate = randstate * 1664525 + 1013904223;
    40b9:	a1 6c 68 00 00       	mov    0x686c,%eax
    40be:	69 c0 0d 66 19 00    	imul   $0x19660d,%eax,%eax
    40c4:	05 5f f3 6e 3c       	add    $0x3c6ef35f,%eax
    40c9:	a3 6c 68 00 00       	mov    %eax,0x686c
  return randstate;
    40ce:	a1 6c 68 00 00       	mov    0x686c,%eax
}
    40d3:	5d                   	pop    %ebp
    40d4:	c3                   	ret    

000040d5 <main>:

int
main(int argc, char *argv[])
{
    40d5:	55                   	push   %ebp
    40d6:	89 e5                	mov    %esp,%ebp
    40d8:	83 e4 f0             	and    $0xfffffff0,%esp
    40db:	83 ec 10             	sub    $0x10,%esp
  printf(1, "usertests starting\n");
    40de:	c7 44 24 04 23 61 00 	movl   $0x6123,0x4(%esp)
    40e5:	00 
    40e6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    40ed:	e8 f1 04 00 00       	call   45e3 <printf>

  if(open("usertests.ran", 0) >= 0){
    40f2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    40f9:	00 
    40fa:	c7 04 24 37 61 00 00 	movl   $0x6137,(%esp)
    4101:	e8 96 03 00 00       	call   449c <open>
    4106:	85 c0                	test   %eax,%eax
    4108:	78 20                	js     412a <main+0x55>
    printf(1, "already ran user tests -- rebuild fs.img\n");
    410a:	c7 44 24 04 48 61 00 	movl   $0x6148,0x4(%esp)
    4111:	00 
    4112:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    4119:	e8 c5 04 00 00       	call   45e3 <printf>
    exit(EXIT_STATUS_DEFAULT);
    411e:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    4125:	e8 32 03 00 00       	call   445c <exit>
  }
  close(open("usertests.ran", O_CREATE));
    412a:	c7 44 24 04 00 02 00 	movl   $0x200,0x4(%esp)
    4131:	00 
    4132:	c7 04 24 37 61 00 00 	movl   $0x6137,(%esp)
    4139:	e8 5e 03 00 00       	call   449c <open>
    413e:	89 04 24             	mov    %eax,(%esp)
    4141:	e8 3e 03 00 00       	call   4484 <close>

  createdelete();
    4146:	e8 d9 d2 ff ff       	call   1424 <createdelete>
  linkunlink();
    414b:	e8 f8 dd ff ff       	call   1f48 <linkunlink>
  concreate();
    4150:	e8 ff d9 ff ff       	call   1b54 <concreate>
  fourfiles();
    4155:	e8 31 d0 ff ff       	call   118b <fourfiles>
  sharedfd();
    415a:	e8 1d ce ff ff       	call   f7c <sharedfd>

  bigargtest();
    415f:	e8 4b fb ff ff       	call   3caf <bigargtest>
  bigwrite();
    4164:	e8 f3 e8 ff ff       	call   2a5c <bigwrite>
  bigargtest();
    4169:	e8 41 fb ff ff       	call   3caf <bigargtest>
  bsstest();
    416e:	e8 c3 fa ff ff       	call   3c36 <bsstest>
  sbrktest();
    4173:	e8 3b f4 ff ff       	call   35b3 <sbrktest>
  validatetest();
    4178:	e8 d4 f9 ff ff       	call   3b51 <validatetest>

  opentest();
    417d:	e8 b5 c1 ff ff       	call   337 <opentest>
  writetest();
    4182:	e8 69 c2 ff ff       	call   3f0 <writetest>
  writetest1();
    4187:	e8 a3 c4 ff ff       	call   62f <writetest1>
  createtest();
    418c:	e8 d8 c6 ff ff       	call   869 <createtest>

  openiputtest();
    4191:	e8 76 c0 ff ff       	call   20c <openiputtest>
  exitiputtest();
    4196:	e8 5b bf ff ff       	call   f6 <exitiputtest>
  iputtest();
    419b:	e8 60 be ff ff       	call   0 <iputtest>

  mem();
    41a0:	e8 dd cc ff ff       	call   e82 <mem>
  pipe1();
    41a5:	e8 c3 c8 ff ff       	call   a6d <pipe1>
  preempt();
    41aa:	e8 d6 ca ff ff       	call   c85 <preempt>
  exitwait();
    41af:	e8 42 cc ff ff       	call   df6 <exitwait>

  rmdot();
    41b4:	e8 93 ed ff ff       	call   2f4c <rmdot>
  fourteen();
    41b9:	e8 0e ec ff ff       	call   2dcc <fourteen>
  bigfile();
    41be:	e8 af e9 ff ff       	call   2b72 <bigfile>
  subdir();
    41c3:	e8 4b e0 ff ff       	call   2213 <subdir>
  linktest();
    41c8:	e8 ff d6 ff ff       	call   18cc <linktest>
  unlinkread();
    41cd:	e8 fb d4 ff ff       	call   16cd <unlinkread>
  dirfile();
    41d2:	e8 25 ef ff ff       	call   30fc <dirfile>
  iref();
    41d7:	e8 a8 f1 ff ff       	call   3384 <iref>
  forktest();
    41dc:	e8 d5 f2 ff ff       	call   34b6 <forktest>
  bigdir(); // slow
    41e1:	e8 a3 de ff ff       	call   2089 <bigdir>
  exectest();
    41e6:	e8 2c c8 ff ff       	call   a17 <exectest>

  exit(EXIT_STATUS_DEFAULT);
    41eb:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    41f2:	e8 65 02 00 00       	call   445c <exit>
    41f7:	90                   	nop

000041f8 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
    41f8:	55                   	push   %ebp
    41f9:	89 e5                	mov    %esp,%ebp
    41fb:	57                   	push   %edi
    41fc:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
    41fd:	8b 4d 08             	mov    0x8(%ebp),%ecx
    4200:	8b 55 10             	mov    0x10(%ebp),%edx
    4203:	8b 45 0c             	mov    0xc(%ebp),%eax
    4206:	89 cb                	mov    %ecx,%ebx
    4208:	89 df                	mov    %ebx,%edi
    420a:	89 d1                	mov    %edx,%ecx
    420c:	fc                   	cld    
    420d:	f3 aa                	rep stos %al,%es:(%edi)
    420f:	89 ca                	mov    %ecx,%edx
    4211:	89 fb                	mov    %edi,%ebx
    4213:	89 5d 08             	mov    %ebx,0x8(%ebp)
    4216:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
    4219:	5b                   	pop    %ebx
    421a:	5f                   	pop    %edi
    421b:	5d                   	pop    %ebp
    421c:	c3                   	ret    

0000421d <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
    421d:	55                   	push   %ebp
    421e:	89 e5                	mov    %esp,%ebp
    4220:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
    4223:	8b 45 08             	mov    0x8(%ebp),%eax
    4226:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
    4229:	90                   	nop
    422a:	8b 45 0c             	mov    0xc(%ebp),%eax
    422d:	0f b6 10             	movzbl (%eax),%edx
    4230:	8b 45 08             	mov    0x8(%ebp),%eax
    4233:	88 10                	mov    %dl,(%eax)
    4235:	8b 45 08             	mov    0x8(%ebp),%eax
    4238:	0f b6 00             	movzbl (%eax),%eax
    423b:	84 c0                	test   %al,%al
    423d:	0f 95 c0             	setne  %al
    4240:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    4244:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
    4248:	84 c0                	test   %al,%al
    424a:	75 de                	jne    422a <strcpy+0xd>
    ;
  return os;
    424c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
    424f:	c9                   	leave  
    4250:	c3                   	ret    

00004251 <strcmp>:

int
strcmp(const char *p, const char *q)
{
    4251:	55                   	push   %ebp
    4252:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
    4254:	eb 08                	jmp    425e <strcmp+0xd>
    p++, q++;
    4256:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    425a:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
    425e:	8b 45 08             	mov    0x8(%ebp),%eax
    4261:	0f b6 00             	movzbl (%eax),%eax
    4264:	84 c0                	test   %al,%al
    4266:	74 10                	je     4278 <strcmp+0x27>
    4268:	8b 45 08             	mov    0x8(%ebp),%eax
    426b:	0f b6 10             	movzbl (%eax),%edx
    426e:	8b 45 0c             	mov    0xc(%ebp),%eax
    4271:	0f b6 00             	movzbl (%eax),%eax
    4274:	38 c2                	cmp    %al,%dl
    4276:	74 de                	je     4256 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
    4278:	8b 45 08             	mov    0x8(%ebp),%eax
    427b:	0f b6 00             	movzbl (%eax),%eax
    427e:	0f b6 d0             	movzbl %al,%edx
    4281:	8b 45 0c             	mov    0xc(%ebp),%eax
    4284:	0f b6 00             	movzbl (%eax),%eax
    4287:	0f b6 c0             	movzbl %al,%eax
    428a:	89 d1                	mov    %edx,%ecx
    428c:	29 c1                	sub    %eax,%ecx
    428e:	89 c8                	mov    %ecx,%eax
}
    4290:	5d                   	pop    %ebp
    4291:	c3                   	ret    

00004292 <strlen>:

uint
strlen(char *s)
{
    4292:	55                   	push   %ebp
    4293:	89 e5                	mov    %esp,%ebp
    4295:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
    4298:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    429f:	eb 04                	jmp    42a5 <strlen+0x13>
    42a1:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
    42a5:	8b 45 fc             	mov    -0x4(%ebp),%eax
    42a8:	03 45 08             	add    0x8(%ebp),%eax
    42ab:	0f b6 00             	movzbl (%eax),%eax
    42ae:	84 c0                	test   %al,%al
    42b0:	75 ef                	jne    42a1 <strlen+0xf>
    ;
  return n;
    42b2:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
    42b5:	c9                   	leave  
    42b6:	c3                   	ret    

000042b7 <memset>:

void*
memset(void *dst, int c, uint n)
{
    42b7:	55                   	push   %ebp
    42b8:	89 e5                	mov    %esp,%ebp
    42ba:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
    42bd:	8b 45 10             	mov    0x10(%ebp),%eax
    42c0:	89 44 24 08          	mov    %eax,0x8(%esp)
    42c4:	8b 45 0c             	mov    0xc(%ebp),%eax
    42c7:	89 44 24 04          	mov    %eax,0x4(%esp)
    42cb:	8b 45 08             	mov    0x8(%ebp),%eax
    42ce:	89 04 24             	mov    %eax,(%esp)
    42d1:	e8 22 ff ff ff       	call   41f8 <stosb>
  return dst;
    42d6:	8b 45 08             	mov    0x8(%ebp),%eax
}
    42d9:	c9                   	leave  
    42da:	c3                   	ret    

000042db <strchr>:

char*
strchr(const char *s, char c)
{
    42db:	55                   	push   %ebp
    42dc:	89 e5                	mov    %esp,%ebp
    42de:	83 ec 04             	sub    $0x4,%esp
    42e1:	8b 45 0c             	mov    0xc(%ebp),%eax
    42e4:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
    42e7:	eb 14                	jmp    42fd <strchr+0x22>
    if(*s == c)
    42e9:	8b 45 08             	mov    0x8(%ebp),%eax
    42ec:	0f b6 00             	movzbl (%eax),%eax
    42ef:	3a 45 fc             	cmp    -0x4(%ebp),%al
    42f2:	75 05                	jne    42f9 <strchr+0x1e>
      return (char*)s;
    42f4:	8b 45 08             	mov    0x8(%ebp),%eax
    42f7:	eb 13                	jmp    430c <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
    42f9:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    42fd:	8b 45 08             	mov    0x8(%ebp),%eax
    4300:	0f b6 00             	movzbl (%eax),%eax
    4303:	84 c0                	test   %al,%al
    4305:	75 e2                	jne    42e9 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
    4307:	b8 00 00 00 00       	mov    $0x0,%eax
}
    430c:	c9                   	leave  
    430d:	c3                   	ret    

0000430e <gets>:

char*
gets(char *buf, int max)
{
    430e:	55                   	push   %ebp
    430f:	89 e5                	mov    %esp,%ebp
    4311:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    4314:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    431b:	eb 44                	jmp    4361 <gets+0x53>
    cc = read(0, &c, 1);
    431d:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
    4324:	00 
    4325:	8d 45 ef             	lea    -0x11(%ebp),%eax
    4328:	89 44 24 04          	mov    %eax,0x4(%esp)
    432c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    4333:	e8 3c 01 00 00       	call   4474 <read>
    4338:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
    433b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    433f:	7e 2d                	jle    436e <gets+0x60>
      break;
    buf[i++] = c;
    4341:	8b 45 f4             	mov    -0xc(%ebp),%eax
    4344:	03 45 08             	add    0x8(%ebp),%eax
    4347:	0f b6 55 ef          	movzbl -0x11(%ebp),%edx
    434b:	88 10                	mov    %dl,(%eax)
    434d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(c == '\n' || c == '\r')
    4351:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    4355:	3c 0a                	cmp    $0xa,%al
    4357:	74 16                	je     436f <gets+0x61>
    4359:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    435d:	3c 0d                	cmp    $0xd,%al
    435f:	74 0e                	je     436f <gets+0x61>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    4361:	8b 45 f4             	mov    -0xc(%ebp),%eax
    4364:	83 c0 01             	add    $0x1,%eax
    4367:	3b 45 0c             	cmp    0xc(%ebp),%eax
    436a:	7c b1                	jl     431d <gets+0xf>
    436c:	eb 01                	jmp    436f <gets+0x61>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    436e:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
    436f:	8b 45 f4             	mov    -0xc(%ebp),%eax
    4372:	03 45 08             	add    0x8(%ebp),%eax
    4375:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
    4378:	8b 45 08             	mov    0x8(%ebp),%eax
}
    437b:	c9                   	leave  
    437c:	c3                   	ret    

0000437d <stat>:

int
stat(char *n, struct stat *st)
{
    437d:	55                   	push   %ebp
    437e:	89 e5                	mov    %esp,%ebp
    4380:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
    4383:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    438a:	00 
    438b:	8b 45 08             	mov    0x8(%ebp),%eax
    438e:	89 04 24             	mov    %eax,(%esp)
    4391:	e8 06 01 00 00       	call   449c <open>
    4396:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
    4399:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    439d:	79 07                	jns    43a6 <stat+0x29>
    return -1;
    439f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    43a4:	eb 23                	jmp    43c9 <stat+0x4c>
  r = fstat(fd, st);
    43a6:	8b 45 0c             	mov    0xc(%ebp),%eax
    43a9:	89 44 24 04          	mov    %eax,0x4(%esp)
    43ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
    43b0:	89 04 24             	mov    %eax,(%esp)
    43b3:	e8 fc 00 00 00       	call   44b4 <fstat>
    43b8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
    43bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
    43be:	89 04 24             	mov    %eax,(%esp)
    43c1:	e8 be 00 00 00       	call   4484 <close>
  return r;
    43c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
    43c9:	c9                   	leave  
    43ca:	c3                   	ret    

000043cb <atoi>:

int
atoi(const char *s)
{
    43cb:	55                   	push   %ebp
    43cc:	89 e5                	mov    %esp,%ebp
    43ce:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
    43d1:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
    43d8:	eb 23                	jmp    43fd <atoi+0x32>
    n = n*10 + *s++ - '0';
    43da:	8b 55 fc             	mov    -0x4(%ebp),%edx
    43dd:	89 d0                	mov    %edx,%eax
    43df:	c1 e0 02             	shl    $0x2,%eax
    43e2:	01 d0                	add    %edx,%eax
    43e4:	01 c0                	add    %eax,%eax
    43e6:	89 c2                	mov    %eax,%edx
    43e8:	8b 45 08             	mov    0x8(%ebp),%eax
    43eb:	0f b6 00             	movzbl (%eax),%eax
    43ee:	0f be c0             	movsbl %al,%eax
    43f1:	01 d0                	add    %edx,%eax
    43f3:	83 e8 30             	sub    $0x30,%eax
    43f6:	89 45 fc             	mov    %eax,-0x4(%ebp)
    43f9:	83 45 08 01          	addl   $0x1,0x8(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
    43fd:	8b 45 08             	mov    0x8(%ebp),%eax
    4400:	0f b6 00             	movzbl (%eax),%eax
    4403:	3c 2f                	cmp    $0x2f,%al
    4405:	7e 0a                	jle    4411 <atoi+0x46>
    4407:	8b 45 08             	mov    0x8(%ebp),%eax
    440a:	0f b6 00             	movzbl (%eax),%eax
    440d:	3c 39                	cmp    $0x39,%al
    440f:	7e c9                	jle    43da <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
    4411:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
    4414:	c9                   	leave  
    4415:	c3                   	ret    

00004416 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
    4416:	55                   	push   %ebp
    4417:	89 e5                	mov    %esp,%ebp
    4419:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
    441c:	8b 45 08             	mov    0x8(%ebp),%eax
    441f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
    4422:	8b 45 0c             	mov    0xc(%ebp),%eax
    4425:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
    4428:	eb 13                	jmp    443d <memmove+0x27>
    *dst++ = *src++;
    442a:	8b 45 f8             	mov    -0x8(%ebp),%eax
    442d:	0f b6 10             	movzbl (%eax),%edx
    4430:	8b 45 fc             	mov    -0x4(%ebp),%eax
    4433:	88 10                	mov    %dl,(%eax)
    4435:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
    4439:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
    443d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
    4441:	0f 9f c0             	setg   %al
    4444:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    4448:	84 c0                	test   %al,%al
    444a:	75 de                	jne    442a <memmove+0x14>
    *dst++ = *src++;
  return vdst;
    444c:	8b 45 08             	mov    0x8(%ebp),%eax
}
    444f:	c9                   	leave  
    4450:	c3                   	ret    
    4451:	90                   	nop
    4452:	90                   	nop
    4453:	90                   	nop

00004454 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
    4454:	b8 01 00 00 00       	mov    $0x1,%eax
    4459:	cd 40                	int    $0x40
    445b:	c3                   	ret    

0000445c <exit>:
SYSCALL(exit)
    445c:	b8 02 00 00 00       	mov    $0x2,%eax
    4461:	cd 40                	int    $0x40
    4463:	c3                   	ret    

00004464 <wait>:
SYSCALL(wait)
    4464:	b8 03 00 00 00       	mov    $0x3,%eax
    4469:	cd 40                	int    $0x40
    446b:	c3                   	ret    

0000446c <pipe>:
SYSCALL(pipe)
    446c:	b8 04 00 00 00       	mov    $0x4,%eax
    4471:	cd 40                	int    $0x40
    4473:	c3                   	ret    

00004474 <read>:
SYSCALL(read)
    4474:	b8 05 00 00 00       	mov    $0x5,%eax
    4479:	cd 40                	int    $0x40
    447b:	c3                   	ret    

0000447c <write>:
SYSCALL(write)
    447c:	b8 10 00 00 00       	mov    $0x10,%eax
    4481:	cd 40                	int    $0x40
    4483:	c3                   	ret    

00004484 <close>:
SYSCALL(close)
    4484:	b8 15 00 00 00       	mov    $0x15,%eax
    4489:	cd 40                	int    $0x40
    448b:	c3                   	ret    

0000448c <kill>:
SYSCALL(kill)
    448c:	b8 06 00 00 00       	mov    $0x6,%eax
    4491:	cd 40                	int    $0x40
    4493:	c3                   	ret    

00004494 <exec>:
SYSCALL(exec)
    4494:	b8 07 00 00 00       	mov    $0x7,%eax
    4499:	cd 40                	int    $0x40
    449b:	c3                   	ret    

0000449c <open>:
SYSCALL(open)
    449c:	b8 0f 00 00 00       	mov    $0xf,%eax
    44a1:	cd 40                	int    $0x40
    44a3:	c3                   	ret    

000044a4 <mknod>:
SYSCALL(mknod)
    44a4:	b8 11 00 00 00       	mov    $0x11,%eax
    44a9:	cd 40                	int    $0x40
    44ab:	c3                   	ret    

000044ac <unlink>:
SYSCALL(unlink)
    44ac:	b8 12 00 00 00       	mov    $0x12,%eax
    44b1:	cd 40                	int    $0x40
    44b3:	c3                   	ret    

000044b4 <fstat>:
SYSCALL(fstat)
    44b4:	b8 08 00 00 00       	mov    $0x8,%eax
    44b9:	cd 40                	int    $0x40
    44bb:	c3                   	ret    

000044bc <link>:
SYSCALL(link)
    44bc:	b8 13 00 00 00       	mov    $0x13,%eax
    44c1:	cd 40                	int    $0x40
    44c3:	c3                   	ret    

000044c4 <mkdir>:
SYSCALL(mkdir)
    44c4:	b8 14 00 00 00       	mov    $0x14,%eax
    44c9:	cd 40                	int    $0x40
    44cb:	c3                   	ret    

000044cc <chdir>:
SYSCALL(chdir)
    44cc:	b8 09 00 00 00       	mov    $0x9,%eax
    44d1:	cd 40                	int    $0x40
    44d3:	c3                   	ret    

000044d4 <dup>:
SYSCALL(dup)
    44d4:	b8 0a 00 00 00       	mov    $0xa,%eax
    44d9:	cd 40                	int    $0x40
    44db:	c3                   	ret    

000044dc <getpid>:
SYSCALL(getpid)
    44dc:	b8 0b 00 00 00       	mov    $0xb,%eax
    44e1:	cd 40                	int    $0x40
    44e3:	c3                   	ret    

000044e4 <sbrk>:
SYSCALL(sbrk)
    44e4:	b8 0c 00 00 00       	mov    $0xc,%eax
    44e9:	cd 40                	int    $0x40
    44eb:	c3                   	ret    

000044ec <sleep>:
SYSCALL(sleep)
    44ec:	b8 0d 00 00 00       	mov    $0xd,%eax
    44f1:	cd 40                	int    $0x40
    44f3:	c3                   	ret    

000044f4 <uptime>:
SYSCALL(uptime)
    44f4:	b8 0e 00 00 00       	mov    $0xe,%eax
    44f9:	cd 40                	int    $0x40
    44fb:	c3                   	ret    

000044fc <waitpid>:
SYSCALL(waitpid)
    44fc:	b8 16 00 00 00       	mov    $0x16,%eax
    4501:	cd 40                	int    $0x40
    4503:	c3                   	ret    

00004504 <wait_stat>:
SYSCALL(wait_stat)
    4504:	b8 17 00 00 00       	mov    $0x17,%eax
    4509:	cd 40                	int    $0x40
    450b:	c3                   	ret    

0000450c <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
    450c:	55                   	push   %ebp
    450d:	89 e5                	mov    %esp,%ebp
    450f:	83 ec 28             	sub    $0x28,%esp
    4512:	8b 45 0c             	mov    0xc(%ebp),%eax
    4515:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
    4518:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
    451f:	00 
    4520:	8d 45 f4             	lea    -0xc(%ebp),%eax
    4523:	89 44 24 04          	mov    %eax,0x4(%esp)
    4527:	8b 45 08             	mov    0x8(%ebp),%eax
    452a:	89 04 24             	mov    %eax,(%esp)
    452d:	e8 4a ff ff ff       	call   447c <write>
}
    4532:	c9                   	leave  
    4533:	c3                   	ret    

00004534 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
    4534:	55                   	push   %ebp
    4535:	89 e5                	mov    %esp,%ebp
    4537:	83 ec 48             	sub    $0x48,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
    453a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
    4541:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
    4545:	74 17                	je     455e <printint+0x2a>
    4547:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
    454b:	79 11                	jns    455e <printint+0x2a>
    neg = 1;
    454d:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
    4554:	8b 45 0c             	mov    0xc(%ebp),%eax
    4557:	f7 d8                	neg    %eax
    4559:	89 45 ec             	mov    %eax,-0x14(%ebp)
    455c:	eb 06                	jmp    4564 <printint+0x30>
  } else {
    x = xx;
    455e:	8b 45 0c             	mov    0xc(%ebp),%eax
    4561:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
    4564:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
    456b:	8b 4d 10             	mov    0x10(%ebp),%ecx
    456e:	8b 45 ec             	mov    -0x14(%ebp),%eax
    4571:	ba 00 00 00 00       	mov    $0x0,%edx
    4576:	f7 f1                	div    %ecx
    4578:	89 d0                	mov    %edx,%eax
    457a:	0f b6 90 70 68 00 00 	movzbl 0x6870(%eax),%edx
    4581:	8d 45 dc             	lea    -0x24(%ebp),%eax
    4584:	03 45 f4             	add    -0xc(%ebp),%eax
    4587:	88 10                	mov    %dl,(%eax)
    4589:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  }while((x /= base) != 0);
    458d:	8b 55 10             	mov    0x10(%ebp),%edx
    4590:	89 55 d4             	mov    %edx,-0x2c(%ebp)
    4593:	8b 45 ec             	mov    -0x14(%ebp),%eax
    4596:	ba 00 00 00 00       	mov    $0x0,%edx
    459b:	f7 75 d4             	divl   -0x2c(%ebp)
    459e:	89 45 ec             	mov    %eax,-0x14(%ebp)
    45a1:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    45a5:	75 c4                	jne    456b <printint+0x37>
  if(neg)
    45a7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    45ab:	74 2a                	je     45d7 <printint+0xa3>
    buf[i++] = '-';
    45ad:	8d 45 dc             	lea    -0x24(%ebp),%eax
    45b0:	03 45 f4             	add    -0xc(%ebp),%eax
    45b3:	c6 00 2d             	movb   $0x2d,(%eax)
    45b6:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

  while(--i >= 0)
    45ba:	eb 1b                	jmp    45d7 <printint+0xa3>
    putc(fd, buf[i]);
    45bc:	8d 45 dc             	lea    -0x24(%ebp),%eax
    45bf:	03 45 f4             	add    -0xc(%ebp),%eax
    45c2:	0f b6 00             	movzbl (%eax),%eax
    45c5:	0f be c0             	movsbl %al,%eax
    45c8:	89 44 24 04          	mov    %eax,0x4(%esp)
    45cc:	8b 45 08             	mov    0x8(%ebp),%eax
    45cf:	89 04 24             	mov    %eax,(%esp)
    45d2:	e8 35 ff ff ff       	call   450c <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
    45d7:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
    45db:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    45df:	79 db                	jns    45bc <printint+0x88>
    putc(fd, buf[i]);
}
    45e1:	c9                   	leave  
    45e2:	c3                   	ret    

000045e3 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
    45e3:	55                   	push   %ebp
    45e4:	89 e5                	mov    %esp,%ebp
    45e6:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
    45e9:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
    45f0:	8d 45 0c             	lea    0xc(%ebp),%eax
    45f3:	83 c0 04             	add    $0x4,%eax
    45f6:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
    45f9:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    4600:	e9 7d 01 00 00       	jmp    4782 <printf+0x19f>
    c = fmt[i] & 0xff;
    4605:	8b 55 0c             	mov    0xc(%ebp),%edx
    4608:	8b 45 f0             	mov    -0x10(%ebp),%eax
    460b:	01 d0                	add    %edx,%eax
    460d:	0f b6 00             	movzbl (%eax),%eax
    4610:	0f be c0             	movsbl %al,%eax
    4613:	25 ff 00 00 00       	and    $0xff,%eax
    4618:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
    461b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    461f:	75 2c                	jne    464d <printf+0x6a>
      if(c == '%'){
    4621:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
    4625:	75 0c                	jne    4633 <printf+0x50>
        state = '%';
    4627:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
    462e:	e9 4b 01 00 00       	jmp    477e <printf+0x19b>
      } else {
        putc(fd, c);
    4633:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    4636:	0f be c0             	movsbl %al,%eax
    4639:	89 44 24 04          	mov    %eax,0x4(%esp)
    463d:	8b 45 08             	mov    0x8(%ebp),%eax
    4640:	89 04 24             	mov    %eax,(%esp)
    4643:	e8 c4 fe ff ff       	call   450c <putc>
    4648:	e9 31 01 00 00       	jmp    477e <printf+0x19b>
      }
    } else if(state == '%'){
    464d:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
    4651:	0f 85 27 01 00 00    	jne    477e <printf+0x19b>
      if(c == 'd'){
    4657:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
    465b:	75 2d                	jne    468a <printf+0xa7>
        printint(fd, *ap, 10, 1);
    465d:	8b 45 e8             	mov    -0x18(%ebp),%eax
    4660:	8b 00                	mov    (%eax),%eax
    4662:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
    4669:	00 
    466a:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
    4671:	00 
    4672:	89 44 24 04          	mov    %eax,0x4(%esp)
    4676:	8b 45 08             	mov    0x8(%ebp),%eax
    4679:	89 04 24             	mov    %eax,(%esp)
    467c:	e8 b3 fe ff ff       	call   4534 <printint>
        ap++;
    4681:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    4685:	e9 ed 00 00 00       	jmp    4777 <printf+0x194>
      } else if(c == 'x' || c == 'p'){
    468a:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
    468e:	74 06                	je     4696 <printf+0xb3>
    4690:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
    4694:	75 2d                	jne    46c3 <printf+0xe0>
        printint(fd, *ap, 16, 0);
    4696:	8b 45 e8             	mov    -0x18(%ebp),%eax
    4699:	8b 00                	mov    (%eax),%eax
    469b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
    46a2:	00 
    46a3:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
    46aa:	00 
    46ab:	89 44 24 04          	mov    %eax,0x4(%esp)
    46af:	8b 45 08             	mov    0x8(%ebp),%eax
    46b2:	89 04 24             	mov    %eax,(%esp)
    46b5:	e8 7a fe ff ff       	call   4534 <printint>
        ap++;
    46ba:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    46be:	e9 b4 00 00 00       	jmp    4777 <printf+0x194>
      } else if(c == 's'){
    46c3:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
    46c7:	75 46                	jne    470f <printf+0x12c>
        s = (char*)*ap;
    46c9:	8b 45 e8             	mov    -0x18(%ebp),%eax
    46cc:	8b 00                	mov    (%eax),%eax
    46ce:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
    46d1:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
    46d5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    46d9:	75 27                	jne    4702 <printf+0x11f>
          s = "(null)";
    46db:	c7 45 f4 72 61 00 00 	movl   $0x6172,-0xc(%ebp)
        while(*s != 0){
    46e2:	eb 1e                	jmp    4702 <printf+0x11f>
          putc(fd, *s);
    46e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
    46e7:	0f b6 00             	movzbl (%eax),%eax
    46ea:	0f be c0             	movsbl %al,%eax
    46ed:	89 44 24 04          	mov    %eax,0x4(%esp)
    46f1:	8b 45 08             	mov    0x8(%ebp),%eax
    46f4:	89 04 24             	mov    %eax,(%esp)
    46f7:	e8 10 fe ff ff       	call   450c <putc>
          s++;
    46fc:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    4700:	eb 01                	jmp    4703 <printf+0x120>
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
    4702:	90                   	nop
    4703:	8b 45 f4             	mov    -0xc(%ebp),%eax
    4706:	0f b6 00             	movzbl (%eax),%eax
    4709:	84 c0                	test   %al,%al
    470b:	75 d7                	jne    46e4 <printf+0x101>
    470d:	eb 68                	jmp    4777 <printf+0x194>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
    470f:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
    4713:	75 1d                	jne    4732 <printf+0x14f>
        putc(fd, *ap);
    4715:	8b 45 e8             	mov    -0x18(%ebp),%eax
    4718:	8b 00                	mov    (%eax),%eax
    471a:	0f be c0             	movsbl %al,%eax
    471d:	89 44 24 04          	mov    %eax,0x4(%esp)
    4721:	8b 45 08             	mov    0x8(%ebp),%eax
    4724:	89 04 24             	mov    %eax,(%esp)
    4727:	e8 e0 fd ff ff       	call   450c <putc>
        ap++;
    472c:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    4730:	eb 45                	jmp    4777 <printf+0x194>
      } else if(c == '%'){
    4732:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
    4736:	75 17                	jne    474f <printf+0x16c>
        putc(fd, c);
    4738:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    473b:	0f be c0             	movsbl %al,%eax
    473e:	89 44 24 04          	mov    %eax,0x4(%esp)
    4742:	8b 45 08             	mov    0x8(%ebp),%eax
    4745:	89 04 24             	mov    %eax,(%esp)
    4748:	e8 bf fd ff ff       	call   450c <putc>
    474d:	eb 28                	jmp    4777 <printf+0x194>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
    474f:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
    4756:	00 
    4757:	8b 45 08             	mov    0x8(%ebp),%eax
    475a:	89 04 24             	mov    %eax,(%esp)
    475d:	e8 aa fd ff ff       	call   450c <putc>
        putc(fd, c);
    4762:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    4765:	0f be c0             	movsbl %al,%eax
    4768:	89 44 24 04          	mov    %eax,0x4(%esp)
    476c:	8b 45 08             	mov    0x8(%ebp),%eax
    476f:	89 04 24             	mov    %eax,(%esp)
    4772:	e8 95 fd ff ff       	call   450c <putc>
      }
      state = 0;
    4777:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    477e:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
    4782:	8b 55 0c             	mov    0xc(%ebp),%edx
    4785:	8b 45 f0             	mov    -0x10(%ebp),%eax
    4788:	01 d0                	add    %edx,%eax
    478a:	0f b6 00             	movzbl (%eax),%eax
    478d:	84 c0                	test   %al,%al
    478f:	0f 85 70 fe ff ff    	jne    4605 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
    4795:	c9                   	leave  
    4796:	c3                   	ret    
    4797:	90                   	nop

00004798 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    4798:	55                   	push   %ebp
    4799:	89 e5                	mov    %esp,%ebp
    479b:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
    479e:	8b 45 08             	mov    0x8(%ebp),%eax
    47a1:	83 e8 08             	sub    $0x8,%eax
    47a4:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    47a7:	a1 28 69 00 00       	mov    0x6928,%eax
    47ac:	89 45 fc             	mov    %eax,-0x4(%ebp)
    47af:	eb 24                	jmp    47d5 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    47b1:	8b 45 fc             	mov    -0x4(%ebp),%eax
    47b4:	8b 00                	mov    (%eax),%eax
    47b6:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    47b9:	77 12                	ja     47cd <free+0x35>
    47bb:	8b 45 f8             	mov    -0x8(%ebp),%eax
    47be:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    47c1:	77 24                	ja     47e7 <free+0x4f>
    47c3:	8b 45 fc             	mov    -0x4(%ebp),%eax
    47c6:	8b 00                	mov    (%eax),%eax
    47c8:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    47cb:	77 1a                	ja     47e7 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    47cd:	8b 45 fc             	mov    -0x4(%ebp),%eax
    47d0:	8b 00                	mov    (%eax),%eax
    47d2:	89 45 fc             	mov    %eax,-0x4(%ebp)
    47d5:	8b 45 f8             	mov    -0x8(%ebp),%eax
    47d8:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    47db:	76 d4                	jbe    47b1 <free+0x19>
    47dd:	8b 45 fc             	mov    -0x4(%ebp),%eax
    47e0:	8b 00                	mov    (%eax),%eax
    47e2:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    47e5:	76 ca                	jbe    47b1 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    47e7:	8b 45 f8             	mov    -0x8(%ebp),%eax
    47ea:	8b 40 04             	mov    0x4(%eax),%eax
    47ed:	c1 e0 03             	shl    $0x3,%eax
    47f0:	89 c2                	mov    %eax,%edx
    47f2:	03 55 f8             	add    -0x8(%ebp),%edx
    47f5:	8b 45 fc             	mov    -0x4(%ebp),%eax
    47f8:	8b 00                	mov    (%eax),%eax
    47fa:	39 c2                	cmp    %eax,%edx
    47fc:	75 24                	jne    4822 <free+0x8a>
    bp->s.size += p->s.ptr->s.size;
    47fe:	8b 45 f8             	mov    -0x8(%ebp),%eax
    4801:	8b 50 04             	mov    0x4(%eax),%edx
    4804:	8b 45 fc             	mov    -0x4(%ebp),%eax
    4807:	8b 00                	mov    (%eax),%eax
    4809:	8b 40 04             	mov    0x4(%eax),%eax
    480c:	01 c2                	add    %eax,%edx
    480e:	8b 45 f8             	mov    -0x8(%ebp),%eax
    4811:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
    4814:	8b 45 fc             	mov    -0x4(%ebp),%eax
    4817:	8b 00                	mov    (%eax),%eax
    4819:	8b 10                	mov    (%eax),%edx
    481b:	8b 45 f8             	mov    -0x8(%ebp),%eax
    481e:	89 10                	mov    %edx,(%eax)
    4820:	eb 0a                	jmp    482c <free+0x94>
  } else
    bp->s.ptr = p->s.ptr;
    4822:	8b 45 fc             	mov    -0x4(%ebp),%eax
    4825:	8b 10                	mov    (%eax),%edx
    4827:	8b 45 f8             	mov    -0x8(%ebp),%eax
    482a:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
    482c:	8b 45 fc             	mov    -0x4(%ebp),%eax
    482f:	8b 40 04             	mov    0x4(%eax),%eax
    4832:	c1 e0 03             	shl    $0x3,%eax
    4835:	03 45 fc             	add    -0x4(%ebp),%eax
    4838:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    483b:	75 20                	jne    485d <free+0xc5>
    p->s.size += bp->s.size;
    483d:	8b 45 fc             	mov    -0x4(%ebp),%eax
    4840:	8b 50 04             	mov    0x4(%eax),%edx
    4843:	8b 45 f8             	mov    -0x8(%ebp),%eax
    4846:	8b 40 04             	mov    0x4(%eax),%eax
    4849:	01 c2                	add    %eax,%edx
    484b:	8b 45 fc             	mov    -0x4(%ebp),%eax
    484e:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
    4851:	8b 45 f8             	mov    -0x8(%ebp),%eax
    4854:	8b 10                	mov    (%eax),%edx
    4856:	8b 45 fc             	mov    -0x4(%ebp),%eax
    4859:	89 10                	mov    %edx,(%eax)
    485b:	eb 08                	jmp    4865 <free+0xcd>
  } else
    p->s.ptr = bp;
    485d:	8b 45 fc             	mov    -0x4(%ebp),%eax
    4860:	8b 55 f8             	mov    -0x8(%ebp),%edx
    4863:	89 10                	mov    %edx,(%eax)
  freep = p;
    4865:	8b 45 fc             	mov    -0x4(%ebp),%eax
    4868:	a3 28 69 00 00       	mov    %eax,0x6928
}
    486d:	c9                   	leave  
    486e:	c3                   	ret    

0000486f <morecore>:

static Header*
morecore(uint nu)
{
    486f:	55                   	push   %ebp
    4870:	89 e5                	mov    %esp,%ebp
    4872:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
    4875:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
    487c:	77 07                	ja     4885 <morecore+0x16>
    nu = 4096;
    487e:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
    4885:	8b 45 08             	mov    0x8(%ebp),%eax
    4888:	c1 e0 03             	shl    $0x3,%eax
    488b:	89 04 24             	mov    %eax,(%esp)
    488e:	e8 51 fc ff ff       	call   44e4 <sbrk>
    4893:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
    4896:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
    489a:	75 07                	jne    48a3 <morecore+0x34>
    return 0;
    489c:	b8 00 00 00 00       	mov    $0x0,%eax
    48a1:	eb 22                	jmp    48c5 <morecore+0x56>
  hp = (Header*)p;
    48a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
    48a6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
    48a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
    48ac:	8b 55 08             	mov    0x8(%ebp),%edx
    48af:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
    48b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
    48b5:	83 c0 08             	add    $0x8,%eax
    48b8:	89 04 24             	mov    %eax,(%esp)
    48bb:	e8 d8 fe ff ff       	call   4798 <free>
  return freep;
    48c0:	a1 28 69 00 00       	mov    0x6928,%eax
}
    48c5:	c9                   	leave  
    48c6:	c3                   	ret    

000048c7 <malloc>:

void*
malloc(uint nbytes)
{
    48c7:	55                   	push   %ebp
    48c8:	89 e5                	mov    %esp,%ebp
    48ca:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    48cd:	8b 45 08             	mov    0x8(%ebp),%eax
    48d0:	83 c0 07             	add    $0x7,%eax
    48d3:	c1 e8 03             	shr    $0x3,%eax
    48d6:	83 c0 01             	add    $0x1,%eax
    48d9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
    48dc:	a1 28 69 00 00       	mov    0x6928,%eax
    48e1:	89 45 f0             	mov    %eax,-0x10(%ebp)
    48e4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    48e8:	75 23                	jne    490d <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
    48ea:	c7 45 f0 20 69 00 00 	movl   $0x6920,-0x10(%ebp)
    48f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
    48f4:	a3 28 69 00 00       	mov    %eax,0x6928
    48f9:	a1 28 69 00 00       	mov    0x6928,%eax
    48fe:	a3 20 69 00 00       	mov    %eax,0x6920
    base.s.size = 0;
    4903:	c7 05 24 69 00 00 00 	movl   $0x0,0x6924
    490a:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    490d:	8b 45 f0             	mov    -0x10(%ebp),%eax
    4910:	8b 00                	mov    (%eax),%eax
    4912:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
    4915:	8b 45 f4             	mov    -0xc(%ebp),%eax
    4918:	8b 40 04             	mov    0x4(%eax),%eax
    491b:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    491e:	72 4d                	jb     496d <malloc+0xa6>
      if(p->s.size == nunits)
    4920:	8b 45 f4             	mov    -0xc(%ebp),%eax
    4923:	8b 40 04             	mov    0x4(%eax),%eax
    4926:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    4929:	75 0c                	jne    4937 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
    492b:	8b 45 f4             	mov    -0xc(%ebp),%eax
    492e:	8b 10                	mov    (%eax),%edx
    4930:	8b 45 f0             	mov    -0x10(%ebp),%eax
    4933:	89 10                	mov    %edx,(%eax)
    4935:	eb 26                	jmp    495d <malloc+0x96>
      else {
        p->s.size -= nunits;
    4937:	8b 45 f4             	mov    -0xc(%ebp),%eax
    493a:	8b 40 04             	mov    0x4(%eax),%eax
    493d:	89 c2                	mov    %eax,%edx
    493f:	2b 55 ec             	sub    -0x14(%ebp),%edx
    4942:	8b 45 f4             	mov    -0xc(%ebp),%eax
    4945:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
    4948:	8b 45 f4             	mov    -0xc(%ebp),%eax
    494b:	8b 40 04             	mov    0x4(%eax),%eax
    494e:	c1 e0 03             	shl    $0x3,%eax
    4951:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
    4954:	8b 45 f4             	mov    -0xc(%ebp),%eax
    4957:	8b 55 ec             	mov    -0x14(%ebp),%edx
    495a:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
    495d:	8b 45 f0             	mov    -0x10(%ebp),%eax
    4960:	a3 28 69 00 00       	mov    %eax,0x6928
      return (void*)(p + 1);
    4965:	8b 45 f4             	mov    -0xc(%ebp),%eax
    4968:	83 c0 08             	add    $0x8,%eax
    496b:	eb 38                	jmp    49a5 <malloc+0xde>
    }
    if(p == freep)
    496d:	a1 28 69 00 00       	mov    0x6928,%eax
    4972:	39 45 f4             	cmp    %eax,-0xc(%ebp)
    4975:	75 1b                	jne    4992 <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
    4977:	8b 45 ec             	mov    -0x14(%ebp),%eax
    497a:	89 04 24             	mov    %eax,(%esp)
    497d:	e8 ed fe ff ff       	call   486f <morecore>
    4982:	89 45 f4             	mov    %eax,-0xc(%ebp)
    4985:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    4989:	75 07                	jne    4992 <malloc+0xcb>
        return 0;
    498b:	b8 00 00 00 00       	mov    $0x0,%eax
    4990:	eb 13                	jmp    49a5 <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    4992:	8b 45 f4             	mov    -0xc(%ebp),%eax
    4995:	89 45 f0             	mov    %eax,-0x10(%ebp)
    4998:	8b 45 f4             	mov    -0xc(%ebp),%eax
    499b:	8b 00                	mov    (%eax),%eax
    499d:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
    49a0:	e9 70 ff ff ff       	jmp    4915 <malloc+0x4e>
}
    49a5:	c9                   	leave  
    49a6:	c3                   	ret    
