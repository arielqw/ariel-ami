
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
       6:	a1 c4 67 00 00       	mov    0x67c4,%eax
       b:	c7 44 24 04 1a 49 00 	movl   $0x491a,0x4(%esp)
      12:	00 
      13:	89 04 24             	mov    %eax,(%esp)
      16:	e8 24 45 00 00       	call   453f <printf>

  if(mkdir("iputdir") < 0){
      1b:	c7 04 24 25 49 00 00 	movl   $0x4925,(%esp)
      22:	e8 09 44 00 00       	call   4430 <mkdir>
      27:	85 c0                	test   %eax,%eax
      29:	79 21                	jns    4c <iputtest+0x4c>
    printf(stdout, "mkdir failed\n");
      2b:	a1 c4 67 00 00       	mov    0x67c4,%eax
      30:	c7 44 24 04 2d 49 00 	movl   $0x492d,0x4(%esp)
      37:	00 
      38:	89 04 24             	mov    %eax,(%esp)
      3b:	e8 ff 44 00 00       	call   453f <printf>
    exit(EXIT_STATUS_DEFAULT);
      40:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
      47:	e8 7c 43 00 00       	call   43c8 <exit>
  }
  if(chdir("iputdir") < 0){
      4c:	c7 04 24 25 49 00 00 	movl   $0x4925,(%esp)
      53:	e8 e0 43 00 00       	call   4438 <chdir>
      58:	85 c0                	test   %eax,%eax
      5a:	79 21                	jns    7d <iputtest+0x7d>
    printf(stdout, "chdir iputdir failed\n");
      5c:	a1 c4 67 00 00       	mov    0x67c4,%eax
      61:	c7 44 24 04 3b 49 00 	movl   $0x493b,0x4(%esp)
      68:	00 
      69:	89 04 24             	mov    %eax,(%esp)
      6c:	e8 ce 44 00 00       	call   453f <printf>
    exit(EXIT_STATUS_DEFAULT);
      71:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
      78:	e8 4b 43 00 00       	call   43c8 <exit>
  }
  if(unlink("../iputdir") < 0){
      7d:	c7 04 24 51 49 00 00 	movl   $0x4951,(%esp)
      84:	e8 8f 43 00 00       	call   4418 <unlink>
      89:	85 c0                	test   %eax,%eax
      8b:	79 21                	jns    ae <iputtest+0xae>
    printf(stdout, "unlink ../iputdir failed\n");
      8d:	a1 c4 67 00 00       	mov    0x67c4,%eax
      92:	c7 44 24 04 5c 49 00 	movl   $0x495c,0x4(%esp)
      99:	00 
      9a:	89 04 24             	mov    %eax,(%esp)
      9d:	e8 9d 44 00 00       	call   453f <printf>
    exit(EXIT_STATUS_DEFAULT);
      a2:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
      a9:	e8 1a 43 00 00       	call   43c8 <exit>
  }
  if(chdir("/") < 0){
      ae:	c7 04 24 76 49 00 00 	movl   $0x4976,(%esp)
      b5:	e8 7e 43 00 00       	call   4438 <chdir>
      ba:	85 c0                	test   %eax,%eax
      bc:	79 21                	jns    df <iputtest+0xdf>
    printf(stdout, "chdir / failed\n");
      be:	a1 c4 67 00 00       	mov    0x67c4,%eax
      c3:	c7 44 24 04 78 49 00 	movl   $0x4978,0x4(%esp)
      ca:	00 
      cb:	89 04 24             	mov    %eax,(%esp)
      ce:	e8 6c 44 00 00       	call   453f <printf>
    exit(EXIT_STATUS_DEFAULT);
      d3:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
      da:	e8 e9 42 00 00       	call   43c8 <exit>
  }
  printf(stdout, "iput test ok\n");
      df:	a1 c4 67 00 00       	mov    0x67c4,%eax
      e4:	c7 44 24 04 88 49 00 	movl   $0x4988,0x4(%esp)
      eb:	00 
      ec:	89 04 24             	mov    %eax,(%esp)
      ef:	e8 4b 44 00 00       	call   453f <printf>
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
      fc:	a1 c4 67 00 00       	mov    0x67c4,%eax
     101:	c7 44 24 04 96 49 00 	movl   $0x4996,0x4(%esp)
     108:	00 
     109:	89 04 24             	mov    %eax,(%esp)
     10c:	e8 2e 44 00 00       	call   453f <printf>

  pid = fork();
     111:	e8 aa 42 00 00       	call   43c0 <fork>
     116:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pid < 0){
     119:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
     11d:	79 21                	jns    140 <exitiputtest+0x4a>
    printf(stdout, "fork failed\n");
     11f:	a1 c4 67 00 00       	mov    0x67c4,%eax
     124:	c7 44 24 04 a5 49 00 	movl   $0x49a5,0x4(%esp)
     12b:	00 
     12c:	89 04 24             	mov    %eax,(%esp)
     12f:	e8 0b 44 00 00       	call   453f <printf>
    exit(EXIT_STATUS_DEFAULT);
     134:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     13b:	e8 88 42 00 00       	call   43c8 <exit>
  }
  if(pid == 0){
     140:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
     144:	0f 85 9f 00 00 00    	jne    1e9 <exitiputtest+0xf3>
    if(mkdir("iputdir") < 0){
     14a:	c7 04 24 25 49 00 00 	movl   $0x4925,(%esp)
     151:	e8 da 42 00 00       	call   4430 <mkdir>
     156:	85 c0                	test   %eax,%eax
     158:	79 21                	jns    17b <exitiputtest+0x85>
      printf(stdout, "mkdir failed\n");
     15a:	a1 c4 67 00 00       	mov    0x67c4,%eax
     15f:	c7 44 24 04 2d 49 00 	movl   $0x492d,0x4(%esp)
     166:	00 
     167:	89 04 24             	mov    %eax,(%esp)
     16a:	e8 d0 43 00 00       	call   453f <printf>
      exit(EXIT_STATUS_DEFAULT);
     16f:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     176:	e8 4d 42 00 00       	call   43c8 <exit>
    }
    if(chdir("iputdir") < 0){
     17b:	c7 04 24 25 49 00 00 	movl   $0x4925,(%esp)
     182:	e8 b1 42 00 00       	call   4438 <chdir>
     187:	85 c0                	test   %eax,%eax
     189:	79 21                	jns    1ac <exitiputtest+0xb6>
      printf(stdout, "child chdir failed\n");
     18b:	a1 c4 67 00 00       	mov    0x67c4,%eax
     190:	c7 44 24 04 b2 49 00 	movl   $0x49b2,0x4(%esp)
     197:	00 
     198:	89 04 24             	mov    %eax,(%esp)
     19b:	e8 9f 43 00 00       	call   453f <printf>
      exit(EXIT_STATUS_DEFAULT);
     1a0:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     1a7:	e8 1c 42 00 00       	call   43c8 <exit>
    }
    if(unlink("../iputdir") < 0){
     1ac:	c7 04 24 51 49 00 00 	movl   $0x4951,(%esp)
     1b3:	e8 60 42 00 00       	call   4418 <unlink>
     1b8:	85 c0                	test   %eax,%eax
     1ba:	79 21                	jns    1dd <exitiputtest+0xe7>
      printf(stdout, "unlink ../iputdir failed\n");
     1bc:	a1 c4 67 00 00       	mov    0x67c4,%eax
     1c1:	c7 44 24 04 5c 49 00 	movl   $0x495c,0x4(%esp)
     1c8:	00 
     1c9:	89 04 24             	mov    %eax,(%esp)
     1cc:	e8 6e 43 00 00       	call   453f <printf>
      exit(EXIT_STATUS_DEFAULT);
     1d1:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     1d8:	e8 eb 41 00 00       	call   43c8 <exit>
    }
    exit(EXIT_STATUS_DEFAULT);
     1dd:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     1e4:	e8 df 41 00 00       	call   43c8 <exit>
  }
  wait();
     1e9:	e8 e2 41 00 00       	call   43d0 <wait>
  printf(stdout, "exitiput test ok\n");
     1ee:	a1 c4 67 00 00       	mov    0x67c4,%eax
     1f3:	c7 44 24 04 c6 49 00 	movl   $0x49c6,0x4(%esp)
     1fa:	00 
     1fb:	89 04 24             	mov    %eax,(%esp)
     1fe:	e8 3c 43 00 00       	call   453f <printf>
}
     203:	c9                   	leave  
     204:	c3                   	ret    

00000205 <openiputtest>:
//      for(i = 0; i < 10000; i++)
//        yield();
//    }
void
openiputtest(void)
{
     205:	55                   	push   %ebp
     206:	89 e5                	mov    %esp,%ebp
     208:	83 ec 28             	sub    $0x28,%esp
  int pid;

  printf(stdout, "openiput test\n");
     20b:	a1 c4 67 00 00       	mov    0x67c4,%eax
     210:	c7 44 24 04 d8 49 00 	movl   $0x49d8,0x4(%esp)
     217:	00 
     218:	89 04 24             	mov    %eax,(%esp)
     21b:	e8 1f 43 00 00       	call   453f <printf>
  if(mkdir("oidir") < 0){
     220:	c7 04 24 e7 49 00 00 	movl   $0x49e7,(%esp)
     227:	e8 04 42 00 00       	call   4430 <mkdir>
     22c:	85 c0                	test   %eax,%eax
     22e:	79 21                	jns    251 <openiputtest+0x4c>
    printf(stdout, "mkdir oidir failed\n");
     230:	a1 c4 67 00 00       	mov    0x67c4,%eax
     235:	c7 44 24 04 ed 49 00 	movl   $0x49ed,0x4(%esp)
     23c:	00 
     23d:	89 04 24             	mov    %eax,(%esp)
     240:	e8 fa 42 00 00       	call   453f <printf>
    exit(EXIT_STATUS_DEFAULT);
     245:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     24c:	e8 77 41 00 00       	call   43c8 <exit>
  }
  pid = fork();
     251:	e8 6a 41 00 00       	call   43c0 <fork>
     256:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pid < 0){
     259:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
     25d:	79 21                	jns    280 <openiputtest+0x7b>
    printf(stdout, "fork failed\n");
     25f:	a1 c4 67 00 00       	mov    0x67c4,%eax
     264:	c7 44 24 04 a5 49 00 	movl   $0x49a5,0x4(%esp)
     26b:	00 
     26c:	89 04 24             	mov    %eax,(%esp)
     26f:	e8 cb 42 00 00       	call   453f <printf>
    exit(EXIT_STATUS_DEFAULT);
     274:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     27b:	e8 48 41 00 00       	call   43c8 <exit>
  }
  if(pid == 0){
     280:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
     284:	75 4a                	jne    2d0 <openiputtest+0xcb>
    int fd = open("oidir", O_RDWR);
     286:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
     28d:	00 
     28e:	c7 04 24 e7 49 00 00 	movl   $0x49e7,(%esp)
     295:	e8 6e 41 00 00       	call   4408 <open>
     29a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(fd >= 0){
     29d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
     2a1:	78 21                	js     2c4 <openiputtest+0xbf>
      printf(stdout, "open directory for write succeeded\n");
     2a3:	a1 c4 67 00 00       	mov    0x67c4,%eax
     2a8:	c7 44 24 04 04 4a 00 	movl   $0x4a04,0x4(%esp)
     2af:	00 
     2b0:	89 04 24             	mov    %eax,(%esp)
     2b3:	e8 87 42 00 00       	call   453f <printf>
      exit(EXIT_STATUS_DEFAULT);
     2b8:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     2bf:	e8 04 41 00 00       	call   43c8 <exit>
    }
    exit(EXIT_STATUS_DEFAULT);
     2c4:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     2cb:	e8 f8 40 00 00       	call   43c8 <exit>
  }
  sleep(1);
     2d0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     2d7:	e8 7c 41 00 00       	call   4458 <sleep>
  if(unlink("oidir") != 0){
     2dc:	c7 04 24 e7 49 00 00 	movl   $0x49e7,(%esp)
     2e3:	e8 30 41 00 00       	call   4418 <unlink>
     2e8:	85 c0                	test   %eax,%eax
     2ea:	74 21                	je     30d <openiputtest+0x108>
    printf(stdout, "unlink failed\n");
     2ec:	a1 c4 67 00 00       	mov    0x67c4,%eax
     2f1:	c7 44 24 04 28 4a 00 	movl   $0x4a28,0x4(%esp)
     2f8:	00 
     2f9:	89 04 24             	mov    %eax,(%esp)
     2fc:	e8 3e 42 00 00       	call   453f <printf>
    exit(EXIT_STATUS_DEFAULT);
     301:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     308:	e8 bb 40 00 00       	call   43c8 <exit>
  }
  wait();
     30d:	e8 be 40 00 00       	call   43d0 <wait>
  printf(stdout, "openiput test ok\n");
     312:	a1 c4 67 00 00       	mov    0x67c4,%eax
     317:	c7 44 24 04 37 4a 00 	movl   $0x4a37,0x4(%esp)
     31e:	00 
     31f:	89 04 24             	mov    %eax,(%esp)
     322:	e8 18 42 00 00       	call   453f <printf>
}
     327:	c9                   	leave  
     328:	c3                   	ret    

00000329 <opentest>:

// simple file system tests

void
opentest(void)
{
     329:	55                   	push   %ebp
     32a:	89 e5                	mov    %esp,%ebp
     32c:	83 ec 28             	sub    $0x28,%esp
  int fd;

  printf(stdout, "open test\n");
     32f:	a1 c4 67 00 00       	mov    0x67c4,%eax
     334:	c7 44 24 04 49 4a 00 	movl   $0x4a49,0x4(%esp)
     33b:	00 
     33c:	89 04 24             	mov    %eax,(%esp)
     33f:	e8 fb 41 00 00       	call   453f <printf>
  fd = open("echo", 0);
     344:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     34b:	00 
     34c:	c7 04 24 04 49 00 00 	movl   $0x4904,(%esp)
     353:	e8 b0 40 00 00       	call   4408 <open>
     358:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0){
     35b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
     35f:	79 21                	jns    382 <opentest+0x59>
    printf(stdout, "open echo failed!\n");
     361:	a1 c4 67 00 00       	mov    0x67c4,%eax
     366:	c7 44 24 04 54 4a 00 	movl   $0x4a54,0x4(%esp)
     36d:	00 
     36e:	89 04 24             	mov    %eax,(%esp)
     371:	e8 c9 41 00 00       	call   453f <printf>
    exit(EXIT_STATUS_DEFAULT);
     376:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     37d:	e8 46 40 00 00       	call   43c8 <exit>
  }
  close(fd);
     382:	8b 45 f4             	mov    -0xc(%ebp),%eax
     385:	89 04 24             	mov    %eax,(%esp)
     388:	e8 63 40 00 00       	call   43f0 <close>
  fd = open("doesnotexist", 0);
     38d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     394:	00 
     395:	c7 04 24 67 4a 00 00 	movl   $0x4a67,(%esp)
     39c:	e8 67 40 00 00       	call   4408 <open>
     3a1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd >= 0){
     3a4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
     3a8:	78 21                	js     3cb <opentest+0xa2>
    printf(stdout, "open doesnotexist succeeded!\n");
     3aa:	a1 c4 67 00 00       	mov    0x67c4,%eax
     3af:	c7 44 24 04 74 4a 00 	movl   $0x4a74,0x4(%esp)
     3b6:	00 
     3b7:	89 04 24             	mov    %eax,(%esp)
     3ba:	e8 80 41 00 00       	call   453f <printf>
    exit(EXIT_STATUS_DEFAULT);
     3bf:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     3c6:	e8 fd 3f 00 00       	call   43c8 <exit>
  }
  printf(stdout, "open test ok\n");
     3cb:	a1 c4 67 00 00       	mov    0x67c4,%eax
     3d0:	c7 44 24 04 92 4a 00 	movl   $0x4a92,0x4(%esp)
     3d7:	00 
     3d8:	89 04 24             	mov    %eax,(%esp)
     3db:	e8 5f 41 00 00       	call   453f <printf>
}
     3e0:	c9                   	leave  
     3e1:	c3                   	ret    

000003e2 <writetest>:

void
writetest(void)
{
     3e2:	55                   	push   %ebp
     3e3:	89 e5                	mov    %esp,%ebp
     3e5:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int i;

  printf(stdout, "small file test\n");
     3e8:	a1 c4 67 00 00       	mov    0x67c4,%eax
     3ed:	c7 44 24 04 a0 4a 00 	movl   $0x4aa0,0x4(%esp)
     3f4:	00 
     3f5:	89 04 24             	mov    %eax,(%esp)
     3f8:	e8 42 41 00 00       	call   453f <printf>
  fd = open("small", O_CREATE|O_RDWR);
     3fd:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
     404:	00 
     405:	c7 04 24 b1 4a 00 00 	movl   $0x4ab1,(%esp)
     40c:	e8 f7 3f 00 00       	call   4408 <open>
     411:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(fd >= 0){
     414:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
     418:	78 21                	js     43b <writetest+0x59>
    printf(stdout, "creat small succeeded; ok\n");
     41a:	a1 c4 67 00 00       	mov    0x67c4,%eax
     41f:	c7 44 24 04 b7 4a 00 	movl   $0x4ab7,0x4(%esp)
     426:	00 
     427:	89 04 24             	mov    %eax,(%esp)
     42a:	e8 10 41 00 00       	call   453f <printf>
  } else {
    printf(stdout, "error: creat small failed!\n");
    exit(EXIT_STATUS_DEFAULT);
  }
  for(i = 0; i < 100; i++){
     42f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     436:	e9 b5 00 00 00       	jmp    4f0 <writetest+0x10e>
  printf(stdout, "small file test\n");
  fd = open("small", O_CREATE|O_RDWR);
  if(fd >= 0){
    printf(stdout, "creat small succeeded; ok\n");
  } else {
    printf(stdout, "error: creat small failed!\n");
     43b:	a1 c4 67 00 00       	mov    0x67c4,%eax
     440:	c7 44 24 04 d2 4a 00 	movl   $0x4ad2,0x4(%esp)
     447:	00 
     448:	89 04 24             	mov    %eax,(%esp)
     44b:	e8 ef 40 00 00       	call   453f <printf>
    exit(EXIT_STATUS_DEFAULT);
     450:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     457:	e8 6c 3f 00 00       	call   43c8 <exit>
  }
  for(i = 0; i < 100; i++){
    if(write(fd, "aaaaaaaaaa", 10) != 10){
     45c:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
     463:	00 
     464:	c7 44 24 04 ee 4a 00 	movl   $0x4aee,0x4(%esp)
     46b:	00 
     46c:	8b 45 f0             	mov    -0x10(%ebp),%eax
     46f:	89 04 24             	mov    %eax,(%esp)
     472:	e8 71 3f 00 00       	call   43e8 <write>
     477:	83 f8 0a             	cmp    $0xa,%eax
     47a:	74 28                	je     4a4 <writetest+0xc2>
      printf(stdout, "error: write aa %d new file failed\n", i);
     47c:	a1 c4 67 00 00       	mov    0x67c4,%eax
     481:	8b 55 f4             	mov    -0xc(%ebp),%edx
     484:	89 54 24 08          	mov    %edx,0x8(%esp)
     488:	c7 44 24 04 fc 4a 00 	movl   $0x4afc,0x4(%esp)
     48f:	00 
     490:	89 04 24             	mov    %eax,(%esp)
     493:	e8 a7 40 00 00       	call   453f <printf>
      exit(EXIT_STATUS_DEFAULT);
     498:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     49f:	e8 24 3f 00 00       	call   43c8 <exit>
    }
    if(write(fd, "bbbbbbbbbb", 10) != 10){
     4a4:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
     4ab:	00 
     4ac:	c7 44 24 04 20 4b 00 	movl   $0x4b20,0x4(%esp)
     4b3:	00 
     4b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
     4b7:	89 04 24             	mov    %eax,(%esp)
     4ba:	e8 29 3f 00 00       	call   43e8 <write>
     4bf:	83 f8 0a             	cmp    $0xa,%eax
     4c2:	74 28                	je     4ec <writetest+0x10a>
      printf(stdout, "error: write bb %d new file failed\n", i);
     4c4:	a1 c4 67 00 00       	mov    0x67c4,%eax
     4c9:	8b 55 f4             	mov    -0xc(%ebp),%edx
     4cc:	89 54 24 08          	mov    %edx,0x8(%esp)
     4d0:	c7 44 24 04 2c 4b 00 	movl   $0x4b2c,0x4(%esp)
     4d7:	00 
     4d8:	89 04 24             	mov    %eax,(%esp)
     4db:	e8 5f 40 00 00       	call   453f <printf>
      exit(EXIT_STATUS_DEFAULT);
     4e0:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     4e7:	e8 dc 3e 00 00       	call   43c8 <exit>
    printf(stdout, "creat small succeeded; ok\n");
  } else {
    printf(stdout, "error: creat small failed!\n");
    exit(EXIT_STATUS_DEFAULT);
  }
  for(i = 0; i < 100; i++){
     4ec:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
     4f0:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
     4f4:	0f 8e 62 ff ff ff    	jle    45c <writetest+0x7a>
    if(write(fd, "bbbbbbbbbb", 10) != 10){
      printf(stdout, "error: write bb %d new file failed\n", i);
      exit(EXIT_STATUS_DEFAULT);
    }
  }
  printf(stdout, "writes ok\n");
     4fa:	a1 c4 67 00 00       	mov    0x67c4,%eax
     4ff:	c7 44 24 04 50 4b 00 	movl   $0x4b50,0x4(%esp)
     506:	00 
     507:	89 04 24             	mov    %eax,(%esp)
     50a:	e8 30 40 00 00       	call   453f <printf>
  close(fd);
     50f:	8b 45 f0             	mov    -0x10(%ebp),%eax
     512:	89 04 24             	mov    %eax,(%esp)
     515:	e8 d6 3e 00 00       	call   43f0 <close>
  fd = open("small", O_RDONLY);
     51a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     521:	00 
     522:	c7 04 24 b1 4a 00 00 	movl   $0x4ab1,(%esp)
     529:	e8 da 3e 00 00       	call   4408 <open>
     52e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(fd >= 0){
     531:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
     535:	78 3e                	js     575 <writetest+0x193>
    printf(stdout, "open small succeeded ok\n");
     537:	a1 c4 67 00 00       	mov    0x67c4,%eax
     53c:	c7 44 24 04 5b 4b 00 	movl   $0x4b5b,0x4(%esp)
     543:	00 
     544:	89 04 24             	mov    %eax,(%esp)
     547:	e8 f3 3f 00 00       	call   453f <printf>
  } else {
    printf(stdout, "error: open small failed!\n");
    exit(EXIT_STATUS_DEFAULT);
  }
  i = read(fd, buf, 2000);
     54c:	c7 44 24 08 d0 07 00 	movl   $0x7d0,0x8(%esp)
     553:	00 
     554:	c7 44 24 04 a0 8f 00 	movl   $0x8fa0,0x4(%esp)
     55b:	00 
     55c:	8b 45 f0             	mov    -0x10(%ebp),%eax
     55f:	89 04 24             	mov    %eax,(%esp)
     562:	e8 79 3e 00 00       	call   43e0 <read>
     567:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(i == 2000){
     56a:	81 7d f4 d0 07 00 00 	cmpl   $0x7d0,-0xc(%ebp)
     571:	74 23                	je     596 <writetest+0x1b4>
     573:	eb 53                	jmp    5c8 <writetest+0x1e6>
  close(fd);
  fd = open("small", O_RDONLY);
  if(fd >= 0){
    printf(stdout, "open small succeeded ok\n");
  } else {
    printf(stdout, "error: open small failed!\n");
     575:	a1 c4 67 00 00       	mov    0x67c4,%eax
     57a:	c7 44 24 04 74 4b 00 	movl   $0x4b74,0x4(%esp)
     581:	00 
     582:	89 04 24             	mov    %eax,(%esp)
     585:	e8 b5 3f 00 00       	call   453f <printf>
    exit(EXIT_STATUS_DEFAULT);
     58a:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     591:	e8 32 3e 00 00       	call   43c8 <exit>
  }
  i = read(fd, buf, 2000);
  if(i == 2000){
    printf(stdout, "read succeeded ok\n");
     596:	a1 c4 67 00 00       	mov    0x67c4,%eax
     59b:	c7 44 24 04 8f 4b 00 	movl   $0x4b8f,0x4(%esp)
     5a2:	00 
     5a3:	89 04 24             	mov    %eax,(%esp)
     5a6:	e8 94 3f 00 00       	call   453f <printf>
  } else {
    printf(stdout, "read failed\n");
    exit(EXIT_STATUS_DEFAULT);
  }
  close(fd);
     5ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
     5ae:	89 04 24             	mov    %eax,(%esp)
     5b1:	e8 3a 3e 00 00       	call   43f0 <close>

  if(unlink("small") < 0){
     5b6:	c7 04 24 b1 4a 00 00 	movl   $0x4ab1,(%esp)
     5bd:	e8 56 3e 00 00       	call   4418 <unlink>
     5c2:	85 c0                	test   %eax,%eax
     5c4:	78 23                	js     5e9 <writetest+0x207>
     5c6:	eb 42                	jmp    60a <writetest+0x228>
  }
  i = read(fd, buf, 2000);
  if(i == 2000){
    printf(stdout, "read succeeded ok\n");
  } else {
    printf(stdout, "read failed\n");
     5c8:	a1 c4 67 00 00       	mov    0x67c4,%eax
     5cd:	c7 44 24 04 a2 4b 00 	movl   $0x4ba2,0x4(%esp)
     5d4:	00 
     5d5:	89 04 24             	mov    %eax,(%esp)
     5d8:	e8 62 3f 00 00       	call   453f <printf>
    exit(EXIT_STATUS_DEFAULT);
     5dd:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     5e4:	e8 df 3d 00 00       	call   43c8 <exit>
  }
  close(fd);

  if(unlink("small") < 0){
    printf(stdout, "unlink small failed\n");
     5e9:	a1 c4 67 00 00       	mov    0x67c4,%eax
     5ee:	c7 44 24 04 af 4b 00 	movl   $0x4baf,0x4(%esp)
     5f5:	00 
     5f6:	89 04 24             	mov    %eax,(%esp)
     5f9:	e8 41 3f 00 00       	call   453f <printf>
    exit(EXIT_STATUS_DEFAULT);
     5fe:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     605:	e8 be 3d 00 00       	call   43c8 <exit>
  }
  printf(stdout, "small file test ok\n");
     60a:	a1 c4 67 00 00       	mov    0x67c4,%eax
     60f:	c7 44 24 04 c4 4b 00 	movl   $0x4bc4,0x4(%esp)
     616:	00 
     617:	89 04 24             	mov    %eax,(%esp)
     61a:	e8 20 3f 00 00       	call   453f <printf>
}
     61f:	c9                   	leave  
     620:	c3                   	ret    

00000621 <writetest1>:

void
writetest1(void)
{
     621:	55                   	push   %ebp
     622:	89 e5                	mov    %esp,%ebp
     624:	83 ec 28             	sub    $0x28,%esp
  int i, fd, n;

  printf(stdout, "big files test\n");
     627:	a1 c4 67 00 00       	mov    0x67c4,%eax
     62c:	c7 44 24 04 d8 4b 00 	movl   $0x4bd8,0x4(%esp)
     633:	00 
     634:	89 04 24             	mov    %eax,(%esp)
     637:	e8 03 3f 00 00       	call   453f <printf>

  fd = open("big", O_CREATE|O_RDWR);
     63c:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
     643:	00 
     644:	c7 04 24 e8 4b 00 00 	movl   $0x4be8,(%esp)
     64b:	e8 b8 3d 00 00       	call   4408 <open>
     650:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(fd < 0){
     653:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
     657:	79 21                	jns    67a <writetest1+0x59>
    printf(stdout, "error: creat big failed!\n");
     659:	a1 c4 67 00 00       	mov    0x67c4,%eax
     65e:	c7 44 24 04 ec 4b 00 	movl   $0x4bec,0x4(%esp)
     665:	00 
     666:	89 04 24             	mov    %eax,(%esp)
     669:	e8 d1 3e 00 00       	call   453f <printf>
    exit(EXIT_STATUS_DEFAULT);
     66e:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     675:	e8 4e 3d 00 00       	call   43c8 <exit>
  }

  for(i = 0; i < MAXFILE; i++){
     67a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     681:	eb 58                	jmp    6db <writetest1+0xba>
    ((int*)buf)[0] = i;
     683:	b8 a0 8f 00 00       	mov    $0x8fa0,%eax
     688:	8b 55 f4             	mov    -0xc(%ebp),%edx
     68b:	89 10                	mov    %edx,(%eax)
    if(write(fd, buf, 512) != 512){
     68d:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
     694:	00 
     695:	c7 44 24 04 a0 8f 00 	movl   $0x8fa0,0x4(%esp)
     69c:	00 
     69d:	8b 45 ec             	mov    -0x14(%ebp),%eax
     6a0:	89 04 24             	mov    %eax,(%esp)
     6a3:	e8 40 3d 00 00       	call   43e8 <write>
     6a8:	3d 00 02 00 00       	cmp    $0x200,%eax
     6ad:	74 28                	je     6d7 <writetest1+0xb6>
      printf(stdout, "error: write big file failed\n", i);
     6af:	a1 c4 67 00 00       	mov    0x67c4,%eax
     6b4:	8b 55 f4             	mov    -0xc(%ebp),%edx
     6b7:	89 54 24 08          	mov    %edx,0x8(%esp)
     6bb:	c7 44 24 04 06 4c 00 	movl   $0x4c06,0x4(%esp)
     6c2:	00 
     6c3:	89 04 24             	mov    %eax,(%esp)
     6c6:	e8 74 3e 00 00       	call   453f <printf>
      exit(EXIT_STATUS_DEFAULT);
     6cb:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     6d2:	e8 f1 3c 00 00       	call   43c8 <exit>
  if(fd < 0){
    printf(stdout, "error: creat big failed!\n");
    exit(EXIT_STATUS_DEFAULT);
  }

  for(i = 0; i < MAXFILE; i++){
     6d7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
     6db:	8b 45 f4             	mov    -0xc(%ebp),%eax
     6de:	3d 8b 00 00 00       	cmp    $0x8b,%eax
     6e3:	76 9e                	jbe    683 <writetest1+0x62>
      printf(stdout, "error: write big file failed\n", i);
      exit(EXIT_STATUS_DEFAULT);
    }
  }

  close(fd);
     6e5:	8b 45 ec             	mov    -0x14(%ebp),%eax
     6e8:	89 04 24             	mov    %eax,(%esp)
     6eb:	e8 00 3d 00 00       	call   43f0 <close>

  fd = open("big", O_RDONLY);
     6f0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     6f7:	00 
     6f8:	c7 04 24 e8 4b 00 00 	movl   $0x4be8,(%esp)
     6ff:	e8 04 3d 00 00       	call   4408 <open>
     704:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(fd < 0){
     707:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
     70b:	79 21                	jns    72e <writetest1+0x10d>
    printf(stdout, "error: open big failed!\n");
     70d:	a1 c4 67 00 00       	mov    0x67c4,%eax
     712:	c7 44 24 04 24 4c 00 	movl   $0x4c24,0x4(%esp)
     719:	00 
     71a:	89 04 24             	mov    %eax,(%esp)
     71d:	e8 1d 3e 00 00       	call   453f <printf>
    exit(EXIT_STATUS_DEFAULT);
     722:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     729:	e8 9a 3c 00 00       	call   43c8 <exit>
  }

  n = 0;
     72e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(;;){
    i = read(fd, buf, 512);
     735:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
     73c:	00 
     73d:	c7 44 24 04 a0 8f 00 	movl   $0x8fa0,0x4(%esp)
     744:	00 
     745:	8b 45 ec             	mov    -0x14(%ebp),%eax
     748:	89 04 24             	mov    %eax,(%esp)
     74b:	e8 90 3c 00 00       	call   43e0 <read>
     750:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(i == 0){
     753:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
     757:	75 35                	jne    78e <writetest1+0x16d>
      if(n == MAXFILE - 1){
     759:	81 7d f0 8b 00 00 00 	cmpl   $0x8b,-0x10(%ebp)
     760:	0f 85 a1 00 00 00    	jne    807 <writetest1+0x1e6>
        printf(stdout, "read only %d blocks from big", n);
     766:	a1 c4 67 00 00       	mov    0x67c4,%eax
     76b:	8b 55 f0             	mov    -0x10(%ebp),%edx
     76e:	89 54 24 08          	mov    %edx,0x8(%esp)
     772:	c7 44 24 04 3d 4c 00 	movl   $0x4c3d,0x4(%esp)
     779:	00 
     77a:	89 04 24             	mov    %eax,(%esp)
     77d:	e8 bd 3d 00 00       	call   453f <printf>
        exit(EXIT_STATUS_DEFAULT);
     782:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     789:	e8 3a 3c 00 00       	call   43c8 <exit>
      }
      break;
    } else if(i != 512){
     78e:	81 7d f4 00 02 00 00 	cmpl   $0x200,-0xc(%ebp)
     795:	74 28                	je     7bf <writetest1+0x19e>
      printf(stdout, "read failed %d\n", i);
     797:	a1 c4 67 00 00       	mov    0x67c4,%eax
     79c:	8b 55 f4             	mov    -0xc(%ebp),%edx
     79f:	89 54 24 08          	mov    %edx,0x8(%esp)
     7a3:	c7 44 24 04 5a 4c 00 	movl   $0x4c5a,0x4(%esp)
     7aa:	00 
     7ab:	89 04 24             	mov    %eax,(%esp)
     7ae:	e8 8c 3d 00 00       	call   453f <printf>
      exit(EXIT_STATUS_DEFAULT);
     7b3:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     7ba:	e8 09 3c 00 00       	call   43c8 <exit>
    }
    if(((int*)buf)[0] != n){
     7bf:	b8 a0 8f 00 00       	mov    $0x8fa0,%eax
     7c4:	8b 00                	mov    (%eax),%eax
     7c6:	3b 45 f0             	cmp    -0x10(%ebp),%eax
     7c9:	74 33                	je     7fe <writetest1+0x1dd>
      printf(stdout, "read content of block %d is %d\n",
             n, ((int*)buf)[0]);
     7cb:	b8 a0 8f 00 00       	mov    $0x8fa0,%eax
    } else if(i != 512){
      printf(stdout, "read failed %d\n", i);
      exit(EXIT_STATUS_DEFAULT);
    }
    if(((int*)buf)[0] != n){
      printf(stdout, "read content of block %d is %d\n",
     7d0:	8b 10                	mov    (%eax),%edx
     7d2:	a1 c4 67 00 00       	mov    0x67c4,%eax
     7d7:	89 54 24 0c          	mov    %edx,0xc(%esp)
     7db:	8b 55 f0             	mov    -0x10(%ebp),%edx
     7de:	89 54 24 08          	mov    %edx,0x8(%esp)
     7e2:	c7 44 24 04 6c 4c 00 	movl   $0x4c6c,0x4(%esp)
     7e9:	00 
     7ea:	89 04 24             	mov    %eax,(%esp)
     7ed:	e8 4d 3d 00 00       	call   453f <printf>
             n, ((int*)buf)[0]);
      exit(EXIT_STATUS_DEFAULT);
     7f2:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     7f9:	e8 ca 3b 00 00       	call   43c8 <exit>
    }
    n++;
     7fe:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
  }
     802:	e9 2e ff ff ff       	jmp    735 <writetest1+0x114>
    if(i == 0){
      if(n == MAXFILE - 1){
        printf(stdout, "read only %d blocks from big", n);
        exit(EXIT_STATUS_DEFAULT);
      }
      break;
     807:	90                   	nop
             n, ((int*)buf)[0]);
      exit(EXIT_STATUS_DEFAULT);
    }
    n++;
  }
  close(fd);
     808:	8b 45 ec             	mov    -0x14(%ebp),%eax
     80b:	89 04 24             	mov    %eax,(%esp)
     80e:	e8 dd 3b 00 00       	call   43f0 <close>
  if(unlink("big") < 0){
     813:	c7 04 24 e8 4b 00 00 	movl   $0x4be8,(%esp)
     81a:	e8 f9 3b 00 00       	call   4418 <unlink>
     81f:	85 c0                	test   %eax,%eax
     821:	79 21                	jns    844 <writetest1+0x223>
    printf(stdout, "unlink big failed\n");
     823:	a1 c4 67 00 00       	mov    0x67c4,%eax
     828:	c7 44 24 04 8c 4c 00 	movl   $0x4c8c,0x4(%esp)
     82f:	00 
     830:	89 04 24             	mov    %eax,(%esp)
     833:	e8 07 3d 00 00       	call   453f <printf>
    exit(EXIT_STATUS_DEFAULT);
     838:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     83f:	e8 84 3b 00 00       	call   43c8 <exit>
  }
  printf(stdout, "big files ok\n");
     844:	a1 c4 67 00 00       	mov    0x67c4,%eax
     849:	c7 44 24 04 9f 4c 00 	movl   $0x4c9f,0x4(%esp)
     850:	00 
     851:	89 04 24             	mov    %eax,(%esp)
     854:	e8 e6 3c 00 00       	call   453f <printf>
}
     859:	c9                   	leave  
     85a:	c3                   	ret    

0000085b <createtest>:

void
createtest(void)
{
     85b:	55                   	push   %ebp
     85c:	89 e5                	mov    %esp,%ebp
     85e:	83 ec 28             	sub    $0x28,%esp
  int i, fd;

  printf(stdout, "many creates, followed by unlink test\n");
     861:	a1 c4 67 00 00       	mov    0x67c4,%eax
     866:	c7 44 24 04 b0 4c 00 	movl   $0x4cb0,0x4(%esp)
     86d:	00 
     86e:	89 04 24             	mov    %eax,(%esp)
     871:	e8 c9 3c 00 00       	call   453f <printf>

  name[0] = 'a';
     876:	c6 05 a0 af 00 00 61 	movb   $0x61,0xafa0
  name[2] = '\0';
     87d:	c6 05 a2 af 00 00 00 	movb   $0x0,0xafa2
  for(i = 0; i < 52; i++){
     884:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     88b:	eb 31                	jmp    8be <createtest+0x63>
    name[1] = '0' + i;
     88d:	8b 45 f4             	mov    -0xc(%ebp),%eax
     890:	83 c0 30             	add    $0x30,%eax
     893:	a2 a1 af 00 00       	mov    %al,0xafa1
    fd = open(name, O_CREATE|O_RDWR);
     898:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
     89f:	00 
     8a0:	c7 04 24 a0 af 00 00 	movl   $0xafa0,(%esp)
     8a7:	e8 5c 3b 00 00       	call   4408 <open>
     8ac:	89 45 f0             	mov    %eax,-0x10(%ebp)
    close(fd);
     8af:	8b 45 f0             	mov    -0x10(%ebp),%eax
     8b2:	89 04 24             	mov    %eax,(%esp)
     8b5:	e8 36 3b 00 00       	call   43f0 <close>

  printf(stdout, "many creates, followed by unlink test\n");

  name[0] = 'a';
  name[2] = '\0';
  for(i = 0; i < 52; i++){
     8ba:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
     8be:	83 7d f4 33          	cmpl   $0x33,-0xc(%ebp)
     8c2:	7e c9                	jle    88d <createtest+0x32>
    name[1] = '0' + i;
    fd = open(name, O_CREATE|O_RDWR);
    close(fd);
  }
  name[0] = 'a';
     8c4:	c6 05 a0 af 00 00 61 	movb   $0x61,0xafa0
  name[2] = '\0';
     8cb:	c6 05 a2 af 00 00 00 	movb   $0x0,0xafa2
  for(i = 0; i < 52; i++){
     8d2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     8d9:	eb 1b                	jmp    8f6 <createtest+0x9b>
    name[1] = '0' + i;
     8db:	8b 45 f4             	mov    -0xc(%ebp),%eax
     8de:	83 c0 30             	add    $0x30,%eax
     8e1:	a2 a1 af 00 00       	mov    %al,0xafa1
    unlink(name);
     8e6:	c7 04 24 a0 af 00 00 	movl   $0xafa0,(%esp)
     8ed:	e8 26 3b 00 00       	call   4418 <unlink>
    fd = open(name, O_CREATE|O_RDWR);
    close(fd);
  }
  name[0] = 'a';
  name[2] = '\0';
  for(i = 0; i < 52; i++){
     8f2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
     8f6:	83 7d f4 33          	cmpl   $0x33,-0xc(%ebp)
     8fa:	7e df                	jle    8db <createtest+0x80>
    name[1] = '0' + i;
    unlink(name);
  }
  printf(stdout, "many creates, followed by unlink; ok\n");
     8fc:	a1 c4 67 00 00       	mov    0x67c4,%eax
     901:	c7 44 24 04 d8 4c 00 	movl   $0x4cd8,0x4(%esp)
     908:	00 
     909:	89 04 24             	mov    %eax,(%esp)
     90c:	e8 2e 3c 00 00       	call   453f <printf>
}
     911:	c9                   	leave  
     912:	c3                   	ret    

00000913 <dirtest>:

void dirtest(void)
{
     913:	55                   	push   %ebp
     914:	89 e5                	mov    %esp,%ebp
     916:	83 ec 18             	sub    $0x18,%esp
  printf(stdout, "mkdir test\n");
     919:	a1 c4 67 00 00       	mov    0x67c4,%eax
     91e:	c7 44 24 04 fe 4c 00 	movl   $0x4cfe,0x4(%esp)
     925:	00 
     926:	89 04 24             	mov    %eax,(%esp)
     929:	e8 11 3c 00 00       	call   453f <printf>

  if(mkdir("dir0") < 0){
     92e:	c7 04 24 0a 4d 00 00 	movl   $0x4d0a,(%esp)
     935:	e8 f6 3a 00 00       	call   4430 <mkdir>
     93a:	85 c0                	test   %eax,%eax
     93c:	79 21                	jns    95f <dirtest+0x4c>
    printf(stdout, "mkdir failed\n");
     93e:	a1 c4 67 00 00       	mov    0x67c4,%eax
     943:	c7 44 24 04 2d 49 00 	movl   $0x492d,0x4(%esp)
     94a:	00 
     94b:	89 04 24             	mov    %eax,(%esp)
     94e:	e8 ec 3b 00 00       	call   453f <printf>
    exit(EXIT_STATUS_DEFAULT);
     953:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     95a:	e8 69 3a 00 00       	call   43c8 <exit>
  }

  if(chdir("dir0") < 0){
     95f:	c7 04 24 0a 4d 00 00 	movl   $0x4d0a,(%esp)
     966:	e8 cd 3a 00 00       	call   4438 <chdir>
     96b:	85 c0                	test   %eax,%eax
     96d:	79 21                	jns    990 <dirtest+0x7d>
    printf(stdout, "chdir dir0 failed\n");
     96f:	a1 c4 67 00 00       	mov    0x67c4,%eax
     974:	c7 44 24 04 0f 4d 00 	movl   $0x4d0f,0x4(%esp)
     97b:	00 
     97c:	89 04 24             	mov    %eax,(%esp)
     97f:	e8 bb 3b 00 00       	call   453f <printf>
    exit(EXIT_STATUS_DEFAULT);
     984:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     98b:	e8 38 3a 00 00       	call   43c8 <exit>
  }

  if(chdir("..") < 0){
     990:	c7 04 24 22 4d 00 00 	movl   $0x4d22,(%esp)
     997:	e8 9c 3a 00 00       	call   4438 <chdir>
     99c:	85 c0                	test   %eax,%eax
     99e:	79 21                	jns    9c1 <dirtest+0xae>
    printf(stdout, "chdir .. failed\n");
     9a0:	a1 c4 67 00 00       	mov    0x67c4,%eax
     9a5:	c7 44 24 04 25 4d 00 	movl   $0x4d25,0x4(%esp)
     9ac:	00 
     9ad:	89 04 24             	mov    %eax,(%esp)
     9b0:	e8 8a 3b 00 00       	call   453f <printf>
    exit(EXIT_STATUS_DEFAULT);
     9b5:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     9bc:	e8 07 3a 00 00       	call   43c8 <exit>
  }

  if(unlink("dir0") < 0){
     9c1:	c7 04 24 0a 4d 00 00 	movl   $0x4d0a,(%esp)
     9c8:	e8 4b 3a 00 00       	call   4418 <unlink>
     9cd:	85 c0                	test   %eax,%eax
     9cf:	79 21                	jns    9f2 <dirtest+0xdf>
    printf(stdout, "unlink dir0 failed\n");
     9d1:	a1 c4 67 00 00       	mov    0x67c4,%eax
     9d6:	c7 44 24 04 36 4d 00 	movl   $0x4d36,0x4(%esp)
     9dd:	00 
     9de:	89 04 24             	mov    %eax,(%esp)
     9e1:	e8 59 3b 00 00       	call   453f <printf>
    exit(EXIT_STATUS_DEFAULT);
     9e6:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     9ed:	e8 d6 39 00 00       	call   43c8 <exit>
  }
  printf(stdout, "mkdir test ok\n");
     9f2:	a1 c4 67 00 00       	mov    0x67c4,%eax
     9f7:	c7 44 24 04 4a 4d 00 	movl   $0x4d4a,0x4(%esp)
     9fe:	00 
     9ff:	89 04 24             	mov    %eax,(%esp)
     a02:	e8 38 3b 00 00       	call   453f <printf>
}
     a07:	c9                   	leave  
     a08:	c3                   	ret    

00000a09 <exectest>:

void
exectest(void)
{
     a09:	55                   	push   %ebp
     a0a:	89 e5                	mov    %esp,%ebp
     a0c:	83 ec 18             	sub    $0x18,%esp
  printf(stdout, "exec test\n");
     a0f:	a1 c4 67 00 00       	mov    0x67c4,%eax
     a14:	c7 44 24 04 59 4d 00 	movl   $0x4d59,0x4(%esp)
     a1b:	00 
     a1c:	89 04 24             	mov    %eax,(%esp)
     a1f:	e8 1b 3b 00 00       	call   453f <printf>
  if(exec("echo", echoargv) < 0){
     a24:	c7 44 24 04 b0 67 00 	movl   $0x67b0,0x4(%esp)
     a2b:	00 
     a2c:	c7 04 24 04 49 00 00 	movl   $0x4904,(%esp)
     a33:	e8 c8 39 00 00       	call   4400 <exec>
     a38:	85 c0                	test   %eax,%eax
     a3a:	79 21                	jns    a5d <exectest+0x54>
    printf(stdout, "exec echo failed\n");
     a3c:	a1 c4 67 00 00       	mov    0x67c4,%eax
     a41:	c7 44 24 04 64 4d 00 	movl   $0x4d64,0x4(%esp)
     a48:	00 
     a49:	89 04 24             	mov    %eax,(%esp)
     a4c:	e8 ee 3a 00 00       	call   453f <printf>
    exit(EXIT_STATUS_DEFAULT);
     a51:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     a58:	e8 6b 39 00 00       	call   43c8 <exit>
  }
}
     a5d:	c9                   	leave  
     a5e:	c3                   	ret    

00000a5f <pipe1>:

// simple fork and pipe read/write

void
pipe1(void)
{
     a5f:	55                   	push   %ebp
     a60:	89 e5                	mov    %esp,%ebp
     a62:	83 ec 38             	sub    $0x38,%esp
  int fds[2], pid;
  int seq, i, n, cc, total;

  if(pipe(fds) != 0){
     a65:	8d 45 d8             	lea    -0x28(%ebp),%eax
     a68:	89 04 24             	mov    %eax,(%esp)
     a6b:	e8 68 39 00 00       	call   43d8 <pipe>
     a70:	85 c0                	test   %eax,%eax
     a72:	74 20                	je     a94 <pipe1+0x35>
    printf(1, "pipe() failed\n");
     a74:	c7 44 24 04 76 4d 00 	movl   $0x4d76,0x4(%esp)
     a7b:	00 
     a7c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     a83:	e8 b7 3a 00 00       	call   453f <printf>
    exit(EXIT_STATUS_DEFAULT);
     a88:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     a8f:	e8 34 39 00 00       	call   43c8 <exit>
  }
  pid = fork();
     a94:	e8 27 39 00 00       	call   43c0 <fork>
     a99:	89 45 e0             	mov    %eax,-0x20(%ebp)
  seq = 0;
     a9c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  if(pid == 0){
     aa3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
     aa7:	0f 85 94 00 00 00    	jne    b41 <pipe1+0xe2>
    close(fds[0]);
     aad:	8b 45 d8             	mov    -0x28(%ebp),%eax
     ab0:	89 04 24             	mov    %eax,(%esp)
     ab3:	e8 38 39 00 00       	call   43f0 <close>
    for(n = 0; n < 5; n++){
     ab8:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
     abf:	eb 6e                	jmp    b2f <pipe1+0xd0>
      for(i = 0; i < 1033; i++)
     ac1:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
     ac8:	eb 16                	jmp    ae0 <pipe1+0x81>
        buf[i] = seq++;
     aca:	8b 45 f4             	mov    -0xc(%ebp),%eax
     acd:	8b 55 f0             	mov    -0x10(%ebp),%edx
     ad0:	81 c2 a0 8f 00 00    	add    $0x8fa0,%edx
     ad6:	88 02                	mov    %al,(%edx)
     ad8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  pid = fork();
  seq = 0;
  if(pid == 0){
    close(fds[0]);
    for(n = 0; n < 5; n++){
      for(i = 0; i < 1033; i++)
     adc:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
     ae0:	81 7d f0 08 04 00 00 	cmpl   $0x408,-0x10(%ebp)
     ae7:	7e e1                	jle    aca <pipe1+0x6b>
        buf[i] = seq++;
      if(write(fds[1], buf, 1033) != 1033){
     ae9:	8b 45 dc             	mov    -0x24(%ebp),%eax
     aec:	c7 44 24 08 09 04 00 	movl   $0x409,0x8(%esp)
     af3:	00 
     af4:	c7 44 24 04 a0 8f 00 	movl   $0x8fa0,0x4(%esp)
     afb:	00 
     afc:	89 04 24             	mov    %eax,(%esp)
     aff:	e8 e4 38 00 00       	call   43e8 <write>
     b04:	3d 09 04 00 00       	cmp    $0x409,%eax
     b09:	74 20                	je     b2b <pipe1+0xcc>
        printf(1, "pipe1 oops 1\n");
     b0b:	c7 44 24 04 85 4d 00 	movl   $0x4d85,0x4(%esp)
     b12:	00 
     b13:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     b1a:	e8 20 3a 00 00       	call   453f <printf>
        exit(EXIT_STATUS_DEFAULT);
     b1f:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     b26:	e8 9d 38 00 00       	call   43c8 <exit>
  }
  pid = fork();
  seq = 0;
  if(pid == 0){
    close(fds[0]);
    for(n = 0; n < 5; n++){
     b2b:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
     b2f:	83 7d ec 04          	cmpl   $0x4,-0x14(%ebp)
     b33:	7e 8c                	jle    ac1 <pipe1+0x62>
      if(write(fds[1], buf, 1033) != 1033){
        printf(1, "pipe1 oops 1\n");
        exit(EXIT_STATUS_DEFAULT);
      }
    }
    exit(EXIT_STATUS_DEFAULT);
     b35:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     b3c:	e8 87 38 00 00       	call   43c8 <exit>
  } else if(pid > 0){
     b41:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
     b45:	0f 8e 03 01 00 00    	jle    c4e <pipe1+0x1ef>
    close(fds[1]);
     b4b:	8b 45 dc             	mov    -0x24(%ebp),%eax
     b4e:	89 04 24             	mov    %eax,(%esp)
     b51:	e8 9a 38 00 00       	call   43f0 <close>
    total = 0;
     b56:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    cc = 1;
     b5d:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
    while((n = read(fds[0], buf, cc)) > 0){
     b64:	eb 6b                	jmp    bd1 <pipe1+0x172>
      for(i = 0; i < n; i++){
     b66:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
     b6d:	eb 40                	jmp    baf <pipe1+0x150>
        if((buf[i] & 0xff) != (seq++ & 0xff)){
     b6f:	8b 45 f0             	mov    -0x10(%ebp),%eax
     b72:	05 a0 8f 00 00       	add    $0x8fa0,%eax
     b77:	0f b6 00             	movzbl (%eax),%eax
     b7a:	0f be c0             	movsbl %al,%eax
     b7d:	33 45 f4             	xor    -0xc(%ebp),%eax
     b80:	25 ff 00 00 00       	and    $0xff,%eax
     b85:	85 c0                	test   %eax,%eax
     b87:	0f 95 c0             	setne  %al
     b8a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
     b8e:	84 c0                	test   %al,%al
     b90:	74 19                	je     bab <pipe1+0x14c>
          printf(1, "pipe1 oops 2\n");
     b92:	c7 44 24 04 93 4d 00 	movl   $0x4d93,0x4(%esp)
     b99:	00 
     b9a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     ba1:	e8 99 39 00 00       	call   453f <printf>
          return;
     ba6:	e9 c3 00 00 00       	jmp    c6e <pipe1+0x20f>
  } else if(pid > 0){
    close(fds[1]);
    total = 0;
    cc = 1;
    while((n = read(fds[0], buf, cc)) > 0){
      for(i = 0; i < n; i++){
     bab:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
     baf:	8b 45 f0             	mov    -0x10(%ebp),%eax
     bb2:	3b 45 ec             	cmp    -0x14(%ebp),%eax
     bb5:	7c b8                	jl     b6f <pipe1+0x110>
        if((buf[i] & 0xff) != (seq++ & 0xff)){
          printf(1, "pipe1 oops 2\n");
          return;
        }
      }
      total += n;
     bb7:	8b 45 ec             	mov    -0x14(%ebp),%eax
     bba:	01 45 e4             	add    %eax,-0x1c(%ebp)
      cc = cc * 2;
     bbd:	d1 65 e8             	shll   -0x18(%ebp)
      if(cc > sizeof(buf))
     bc0:	8b 45 e8             	mov    -0x18(%ebp),%eax
     bc3:	3d 00 20 00 00       	cmp    $0x2000,%eax
     bc8:	76 07                	jbe    bd1 <pipe1+0x172>
        cc = sizeof(buf);
     bca:	c7 45 e8 00 20 00 00 	movl   $0x2000,-0x18(%ebp)
    exit(EXIT_STATUS_DEFAULT);
  } else if(pid > 0){
    close(fds[1]);
    total = 0;
    cc = 1;
    while((n = read(fds[0], buf, cc)) > 0){
     bd1:	8b 45 d8             	mov    -0x28(%ebp),%eax
     bd4:	8b 55 e8             	mov    -0x18(%ebp),%edx
     bd7:	89 54 24 08          	mov    %edx,0x8(%esp)
     bdb:	c7 44 24 04 a0 8f 00 	movl   $0x8fa0,0x4(%esp)
     be2:	00 
     be3:	89 04 24             	mov    %eax,(%esp)
     be6:	e8 f5 37 00 00       	call   43e0 <read>
     beb:	89 45 ec             	mov    %eax,-0x14(%ebp)
     bee:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
     bf2:	0f 8f 6e ff ff ff    	jg     b66 <pipe1+0x107>
      total += n;
      cc = cc * 2;
      if(cc > sizeof(buf))
        cc = sizeof(buf);
    }
    if(total != 5 * 1033){
     bf8:	81 7d e4 2d 14 00 00 	cmpl   $0x142d,-0x1c(%ebp)
     bff:	74 27                	je     c28 <pipe1+0x1c9>
      printf(1, "pipe1 oops 3 total %d\n", total);
     c01:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     c04:	89 44 24 08          	mov    %eax,0x8(%esp)
     c08:	c7 44 24 04 a1 4d 00 	movl   $0x4da1,0x4(%esp)
     c0f:	00 
     c10:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     c17:	e8 23 39 00 00       	call   453f <printf>
      exit(EXIT_STATUS_DEFAULT);
     c1c:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     c23:	e8 a0 37 00 00       	call   43c8 <exit>
    }
    close(fds[0]);
     c28:	8b 45 d8             	mov    -0x28(%ebp),%eax
     c2b:	89 04 24             	mov    %eax,(%esp)
     c2e:	e8 bd 37 00 00       	call   43f0 <close>
    wait();
     c33:	e8 98 37 00 00       	call   43d0 <wait>
  } else {
    printf(1, "fork() failed\n");
    exit(EXIT_STATUS_DEFAULT);
  }
  printf(1, "pipe1 ok\n");
     c38:	c7 44 24 04 b8 4d 00 	movl   $0x4db8,0x4(%esp)
     c3f:	00 
     c40:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     c47:	e8 f3 38 00 00       	call   453f <printf>
     c4c:	eb 20                	jmp    c6e <pipe1+0x20f>
      exit(EXIT_STATUS_DEFAULT);
    }
    close(fds[0]);
    wait();
  } else {
    printf(1, "fork() failed\n");
     c4e:	c7 44 24 04 c2 4d 00 	movl   $0x4dc2,0x4(%esp)
     c55:	00 
     c56:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     c5d:	e8 dd 38 00 00       	call   453f <printf>
    exit(EXIT_STATUS_DEFAULT);
     c62:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     c69:	e8 5a 37 00 00       	call   43c8 <exit>
  }
  printf(1, "pipe1 ok\n");
}
     c6e:	c9                   	leave  
     c6f:	c3                   	ret    

00000c70 <preempt>:

// meant to be run w/ at most two CPUs
void
preempt(void)
{
     c70:	55                   	push   %ebp
     c71:	89 e5                	mov    %esp,%ebp
     c73:	83 ec 38             	sub    $0x38,%esp
  int pid1, pid2, pid3;
  int pfds[2];

  printf(1, "preempt: ");
     c76:	c7 44 24 04 d1 4d 00 	movl   $0x4dd1,0x4(%esp)
     c7d:	00 
     c7e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     c85:	e8 b5 38 00 00       	call   453f <printf>
  pid1 = fork();
     c8a:	e8 31 37 00 00       	call   43c0 <fork>
     c8f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pid1 == 0)
     c92:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
     c96:	75 02                	jne    c9a <preempt+0x2a>
    for(;;)
      ;
     c98:	eb fe                	jmp    c98 <preempt+0x28>

  pid2 = fork();
     c9a:	e8 21 37 00 00       	call   43c0 <fork>
     c9f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(pid2 == 0)
     ca2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
     ca6:	75 02                	jne    caa <preempt+0x3a>
    for(;;)
      ;
     ca8:	eb fe                	jmp    ca8 <preempt+0x38>

  pipe(pfds);
     caa:	8d 45 e4             	lea    -0x1c(%ebp),%eax
     cad:	89 04 24             	mov    %eax,(%esp)
     cb0:	e8 23 37 00 00       	call   43d8 <pipe>
  pid3 = fork();
     cb5:	e8 06 37 00 00       	call   43c0 <fork>
     cba:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(pid3 == 0){
     cbd:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
     cc1:	75 4c                	jne    d0f <preempt+0x9f>
    close(pfds[0]);
     cc3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     cc6:	89 04 24             	mov    %eax,(%esp)
     cc9:	e8 22 37 00 00       	call   43f0 <close>
    if(write(pfds[1], "x", 1) != 1)
     cce:	8b 45 e8             	mov    -0x18(%ebp),%eax
     cd1:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
     cd8:	00 
     cd9:	c7 44 24 04 db 4d 00 	movl   $0x4ddb,0x4(%esp)
     ce0:	00 
     ce1:	89 04 24             	mov    %eax,(%esp)
     ce4:	e8 ff 36 00 00       	call   43e8 <write>
     ce9:	83 f8 01             	cmp    $0x1,%eax
     cec:	74 14                	je     d02 <preempt+0x92>
      printf(1, "preempt write error");
     cee:	c7 44 24 04 dd 4d 00 	movl   $0x4ddd,0x4(%esp)
     cf5:	00 
     cf6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     cfd:	e8 3d 38 00 00       	call   453f <printf>
    close(pfds[1]);
     d02:	8b 45 e8             	mov    -0x18(%ebp),%eax
     d05:	89 04 24             	mov    %eax,(%esp)
     d08:	e8 e3 36 00 00       	call   43f0 <close>
    for(;;)
      ;
     d0d:	eb fe                	jmp    d0d <preempt+0x9d>
  }

  close(pfds[1]);
     d0f:	8b 45 e8             	mov    -0x18(%ebp),%eax
     d12:	89 04 24             	mov    %eax,(%esp)
     d15:	e8 d6 36 00 00       	call   43f0 <close>
  if(read(pfds[0], buf, sizeof(buf)) != 1){
     d1a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     d1d:	c7 44 24 08 00 20 00 	movl   $0x2000,0x8(%esp)
     d24:	00 
     d25:	c7 44 24 04 a0 8f 00 	movl   $0x8fa0,0x4(%esp)
     d2c:	00 
     d2d:	89 04 24             	mov    %eax,(%esp)
     d30:	e8 ab 36 00 00       	call   43e0 <read>
     d35:	83 f8 01             	cmp    $0x1,%eax
     d38:	74 16                	je     d50 <preempt+0xe0>
    printf(1, "preempt read error");
     d3a:	c7 44 24 04 f1 4d 00 	movl   $0x4df1,0x4(%esp)
     d41:	00 
     d42:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     d49:	e8 f1 37 00 00       	call   453f <printf>
    return;
     d4e:	eb 77                	jmp    dc7 <preempt+0x157>
  }
  close(pfds[0]);
     d50:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     d53:	89 04 24             	mov    %eax,(%esp)
     d56:	e8 95 36 00 00       	call   43f0 <close>
  printf(1, "kill... ");
     d5b:	c7 44 24 04 04 4e 00 	movl   $0x4e04,0x4(%esp)
     d62:	00 
     d63:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     d6a:	e8 d0 37 00 00       	call   453f <printf>
  kill(pid1);
     d6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
     d72:	89 04 24             	mov    %eax,(%esp)
     d75:	e8 7e 36 00 00       	call   43f8 <kill>
  kill(pid2);
     d7a:	8b 45 f0             	mov    -0x10(%ebp),%eax
     d7d:	89 04 24             	mov    %eax,(%esp)
     d80:	e8 73 36 00 00       	call   43f8 <kill>
  kill(pid3);
     d85:	8b 45 ec             	mov    -0x14(%ebp),%eax
     d88:	89 04 24             	mov    %eax,(%esp)
     d8b:	e8 68 36 00 00       	call   43f8 <kill>
  printf(1, "wait... ");
     d90:	c7 44 24 04 0d 4e 00 	movl   $0x4e0d,0x4(%esp)
     d97:	00 
     d98:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     d9f:	e8 9b 37 00 00       	call   453f <printf>
  wait();
     da4:	e8 27 36 00 00       	call   43d0 <wait>
  wait();
     da9:	e8 22 36 00 00       	call   43d0 <wait>
  wait();
     dae:	e8 1d 36 00 00       	call   43d0 <wait>
  printf(1, "preempt ok\n");
     db3:	c7 44 24 04 16 4e 00 	movl   $0x4e16,0x4(%esp)
     dba:	00 
     dbb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     dc2:	e8 78 37 00 00       	call   453f <printf>
}
     dc7:	c9                   	leave  
     dc8:	c3                   	ret    

00000dc9 <exitwait>:

// try to find any races between exit and wait
void
exitwait(void)
{
     dc9:	55                   	push   %ebp
     dca:	89 e5                	mov    %esp,%ebp
     dcc:	83 ec 28             	sub    $0x28,%esp
  int i, pid;

  for(i = 0; i < 100; i++){
     dcf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     dd6:	eb 5a                	jmp    e32 <exitwait+0x69>
    pid = fork();
     dd8:	e8 e3 35 00 00       	call   43c0 <fork>
     ddd:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(pid < 0){
     de0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
     de4:	79 16                	jns    dfc <exitwait+0x33>
      printf(1, "fork failed\n");
     de6:	c7 44 24 04 a5 49 00 	movl   $0x49a5,0x4(%esp)
     ded:	00 
     dee:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     df5:	e8 45 37 00 00       	call   453f <printf>
      return;
     dfa:	eb 50                	jmp    e4c <exitwait+0x83>
    }
    if(pid){
     dfc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
     e00:	74 20                	je     e22 <exitwait+0x59>
      if(wait() != pid){
     e02:	e8 c9 35 00 00       	call   43d0 <wait>
     e07:	3b 45 f0             	cmp    -0x10(%ebp),%eax
     e0a:	74 22                	je     e2e <exitwait+0x65>
        printf(1, "wait wrong pid\n");
     e0c:	c7 44 24 04 22 4e 00 	movl   $0x4e22,0x4(%esp)
     e13:	00 
     e14:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     e1b:	e8 1f 37 00 00       	call   453f <printf>
        return;
     e20:	eb 2a                	jmp    e4c <exitwait+0x83>
      }
    } else {
      exit(EXIT_STATUS_DEFAULT);
     e22:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     e29:	e8 9a 35 00 00       	call   43c8 <exit>
void
exitwait(void)
{
  int i, pid;

  for(i = 0; i < 100; i++){
     e2e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
     e32:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
     e36:	7e a0                	jle    dd8 <exitwait+0xf>
      }
    } else {
      exit(EXIT_STATUS_DEFAULT);
    }
  }
  printf(1, "exitwait ok\n");
     e38:	c7 44 24 04 32 4e 00 	movl   $0x4e32,0x4(%esp)
     e3f:	00 
     e40:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     e47:	e8 f3 36 00 00       	call   453f <printf>
}
     e4c:	c9                   	leave  
     e4d:	c3                   	ret    

00000e4e <mem>:

void
mem(void)
{
     e4e:	55                   	push   %ebp
     e4f:	89 e5                	mov    %esp,%ebp
     e51:	83 ec 28             	sub    $0x28,%esp
  void *m1, *m2;
  int pid, ppid;

  printf(1, "mem test\n");
     e54:	c7 44 24 04 3f 4e 00 	movl   $0x4e3f,0x4(%esp)
     e5b:	00 
     e5c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     e63:	e8 d7 36 00 00       	call   453f <printf>
  ppid = getpid();
     e68:	e8 db 35 00 00       	call   4448 <getpid>
     e6d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if((pid = fork()) == 0){
     e70:	e8 4b 35 00 00       	call   43c0 <fork>
     e75:	89 45 ec             	mov    %eax,-0x14(%ebp)
     e78:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
     e7c:	0f 85 b8 00 00 00    	jne    f3a <mem+0xec>
    m1 = 0;
     e82:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while((m2 = malloc(10001)) != 0){
     e89:	eb 0e                	jmp    e99 <mem+0x4b>
      *(char**)m2 = m1;
     e8b:	8b 45 e8             	mov    -0x18(%ebp),%eax
     e8e:	8b 55 f4             	mov    -0xc(%ebp),%edx
     e91:	89 10                	mov    %edx,(%eax)
      m1 = m2;
     e93:	8b 45 e8             	mov    -0x18(%ebp),%eax
     e96:	89 45 f4             	mov    %eax,-0xc(%ebp)

  printf(1, "mem test\n");
  ppid = getpid();
  if((pid = fork()) == 0){
    m1 = 0;
    while((m2 = malloc(10001)) != 0){
     e99:	c7 04 24 11 27 00 00 	movl   $0x2711,(%esp)
     ea0:	e8 7e 39 00 00       	call   4823 <malloc>
     ea5:	89 45 e8             	mov    %eax,-0x18(%ebp)
     ea8:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
     eac:	75 dd                	jne    e8b <mem+0x3d>
      *(char**)m2 = m1;
      m1 = m2;
    }
    while(m1){
     eae:	eb 19                	jmp    ec9 <mem+0x7b>
      m2 = *(char**)m1;
     eb0:	8b 45 f4             	mov    -0xc(%ebp),%eax
     eb3:	8b 00                	mov    (%eax),%eax
     eb5:	89 45 e8             	mov    %eax,-0x18(%ebp)
      free(m1);
     eb8:	8b 45 f4             	mov    -0xc(%ebp),%eax
     ebb:	89 04 24             	mov    %eax,(%esp)
     ebe:	e8 31 38 00 00       	call   46f4 <free>
      m1 = m2;
     ec3:	8b 45 e8             	mov    -0x18(%ebp),%eax
     ec6:	89 45 f4             	mov    %eax,-0xc(%ebp)
    m1 = 0;
    while((m2 = malloc(10001)) != 0){
      *(char**)m2 = m1;
      m1 = m2;
    }
    while(m1){
     ec9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
     ecd:	75 e1                	jne    eb0 <mem+0x62>
      m2 = *(char**)m1;
      free(m1);
      m1 = m2;
    }
    m1 = malloc(1024*20);
     ecf:	c7 04 24 00 50 00 00 	movl   $0x5000,(%esp)
     ed6:	e8 48 39 00 00       	call   4823 <malloc>
     edb:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(m1 == 0){
     ede:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
     ee2:	75 2b                	jne    f0f <mem+0xc1>
      printf(1, "couldn't allocate mem?!!\n");
     ee4:	c7 44 24 04 49 4e 00 	movl   $0x4e49,0x4(%esp)
     eeb:	00 
     eec:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     ef3:	e8 47 36 00 00       	call   453f <printf>
      kill(ppid);
     ef8:	8b 45 f0             	mov    -0x10(%ebp),%eax
     efb:	89 04 24             	mov    %eax,(%esp)
     efe:	e8 f5 34 00 00       	call   43f8 <kill>
      exit(EXIT_STATUS_DEFAULT);
     f03:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     f0a:	e8 b9 34 00 00       	call   43c8 <exit>
    }
    free(m1);
     f0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
     f12:	89 04 24             	mov    %eax,(%esp)
     f15:	e8 da 37 00 00       	call   46f4 <free>
    printf(1, "mem ok\n");
     f1a:	c7 44 24 04 63 4e 00 	movl   $0x4e63,0x4(%esp)
     f21:	00 
     f22:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     f29:	e8 11 36 00 00       	call   453f <printf>
    exit(EXIT_STATUS_DEFAULT);
     f2e:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     f35:	e8 8e 34 00 00       	call   43c8 <exit>
  } else {
    wait();
     f3a:	e8 91 34 00 00       	call   43d0 <wait>
  }
}
     f3f:	c9                   	leave  
     f40:	c3                   	ret    

00000f41 <sharedfd>:

// two processes write to the same file descriptor
// is the offset shared? does inode locking work?
void
sharedfd(void)
{
     f41:	55                   	push   %ebp
     f42:	89 e5                	mov    %esp,%ebp
     f44:	83 ec 48             	sub    $0x48,%esp
  int fd, pid, i, n, nc, np;
  char buf[10];

  printf(1, "sharedfd test\n");
     f47:	c7 44 24 04 6b 4e 00 	movl   $0x4e6b,0x4(%esp)
     f4e:	00 
     f4f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     f56:	e8 e4 35 00 00       	call   453f <printf>

  unlink("sharedfd");
     f5b:	c7 04 24 7a 4e 00 00 	movl   $0x4e7a,(%esp)
     f62:	e8 b1 34 00 00       	call   4418 <unlink>
  fd = open("sharedfd", O_CREATE|O_RDWR);
     f67:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
     f6e:	00 
     f6f:	c7 04 24 7a 4e 00 00 	movl   $0x4e7a,(%esp)
     f76:	e8 8d 34 00 00       	call   4408 <open>
     f7b:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(fd < 0){
     f7e:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
     f82:	79 19                	jns    f9d <sharedfd+0x5c>
    printf(1, "fstests: cannot open sharedfd for writing");
     f84:	c7 44 24 04 84 4e 00 	movl   $0x4e84,0x4(%esp)
     f8b:	00 
     f8c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     f93:	e8 a7 35 00 00       	call   453f <printf>
    return;
     f98:	e9 aa 01 00 00       	jmp    1147 <sharedfd+0x206>
  }
  pid = fork();
     f9d:	e8 1e 34 00 00       	call   43c0 <fork>
     fa2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  memset(buf, pid==0?'c':'p', sizeof(buf));
     fa5:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
     fa9:	75 07                	jne    fb2 <sharedfd+0x71>
     fab:	b8 63 00 00 00       	mov    $0x63,%eax
     fb0:	eb 05                	jmp    fb7 <sharedfd+0x76>
     fb2:	b8 70 00 00 00       	mov    $0x70,%eax
     fb7:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
     fbe:	00 
     fbf:	89 44 24 04          	mov    %eax,0x4(%esp)
     fc3:	8d 45 d6             	lea    -0x2a(%ebp),%eax
     fc6:	89 04 24             	mov    %eax,(%esp)
     fc9:	e8 55 32 00 00       	call   4223 <memset>
  for(i = 0; i < 1000; i++){
     fce:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     fd5:	eb 39                	jmp    1010 <sharedfd+0xcf>
    if(write(fd, buf, sizeof(buf)) != sizeof(buf)){
     fd7:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
     fde:	00 
     fdf:	8d 45 d6             	lea    -0x2a(%ebp),%eax
     fe2:	89 44 24 04          	mov    %eax,0x4(%esp)
     fe6:	8b 45 e8             	mov    -0x18(%ebp),%eax
     fe9:	89 04 24             	mov    %eax,(%esp)
     fec:	e8 f7 33 00 00       	call   43e8 <write>
     ff1:	83 f8 0a             	cmp    $0xa,%eax
     ff4:	74 16                	je     100c <sharedfd+0xcb>
      printf(1, "fstests: write sharedfd failed\n");
     ff6:	c7 44 24 04 b0 4e 00 	movl   $0x4eb0,0x4(%esp)
     ffd:	00 
     ffe:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1005:	e8 35 35 00 00       	call   453f <printf>
      break;
    100a:	eb 0d                	jmp    1019 <sharedfd+0xd8>
    printf(1, "fstests: cannot open sharedfd for writing");
    return;
  }
  pid = fork();
  memset(buf, pid==0?'c':'p', sizeof(buf));
  for(i = 0; i < 1000; i++){
    100c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    1010:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
    1017:	7e be                	jle    fd7 <sharedfd+0x96>
    if(write(fd, buf, sizeof(buf)) != sizeof(buf)){
      printf(1, "fstests: write sharedfd failed\n");
      break;
    }
  }
  if(pid == 0)
    1019:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
    101d:	75 0c                	jne    102b <sharedfd+0xea>
    exit(EXIT_STATUS_DEFAULT);
    101f:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    1026:	e8 9d 33 00 00       	call   43c8 <exit>
  else
    wait();
    102b:	e8 a0 33 00 00       	call   43d0 <wait>
  close(fd);
    1030:	8b 45 e8             	mov    -0x18(%ebp),%eax
    1033:	89 04 24             	mov    %eax,(%esp)
    1036:	e8 b5 33 00 00       	call   43f0 <close>
  fd = open("sharedfd", 0);
    103b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    1042:	00 
    1043:	c7 04 24 7a 4e 00 00 	movl   $0x4e7a,(%esp)
    104a:	e8 b9 33 00 00       	call   4408 <open>
    104f:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(fd < 0){
    1052:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
    1056:	79 19                	jns    1071 <sharedfd+0x130>
    printf(1, "fstests: cannot open sharedfd for reading\n");
    1058:	c7 44 24 04 d0 4e 00 	movl   $0x4ed0,0x4(%esp)
    105f:	00 
    1060:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1067:	e8 d3 34 00 00       	call   453f <printf>
    return;
    106c:	e9 d6 00 00 00       	jmp    1147 <sharedfd+0x206>
  }
  nc = np = 0;
    1071:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
    1078:	8b 45 ec             	mov    -0x14(%ebp),%eax
    107b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  while((n = read(fd, buf, sizeof(buf))) > 0){
    107e:	eb 37                	jmp    10b7 <sharedfd+0x176>
    for(i = 0; i < sizeof(buf); i++){
    1080:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    1087:	eb 26                	jmp    10af <sharedfd+0x16e>
      if(buf[i] == 'c')
    1089:	8d 45 d6             	lea    -0x2a(%ebp),%eax
    108c:	03 45 f4             	add    -0xc(%ebp),%eax
    108f:	0f b6 00             	movzbl (%eax),%eax
    1092:	3c 63                	cmp    $0x63,%al
    1094:	75 04                	jne    109a <sharedfd+0x159>
        nc++;
    1096:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
      if(buf[i] == 'p')
    109a:	8d 45 d6             	lea    -0x2a(%ebp),%eax
    109d:	03 45 f4             	add    -0xc(%ebp),%eax
    10a0:	0f b6 00             	movzbl (%eax),%eax
    10a3:	3c 70                	cmp    $0x70,%al
    10a5:	75 04                	jne    10ab <sharedfd+0x16a>
        np++;
    10a7:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
    printf(1, "fstests: cannot open sharedfd for reading\n");
    return;
  }
  nc = np = 0;
  while((n = read(fd, buf, sizeof(buf))) > 0){
    for(i = 0; i < sizeof(buf); i++){
    10ab:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    10af:	8b 45 f4             	mov    -0xc(%ebp),%eax
    10b2:	83 f8 09             	cmp    $0x9,%eax
    10b5:	76 d2                	jbe    1089 <sharedfd+0x148>
  if(fd < 0){
    printf(1, "fstests: cannot open sharedfd for reading\n");
    return;
  }
  nc = np = 0;
  while((n = read(fd, buf, sizeof(buf))) > 0){
    10b7:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
    10be:	00 
    10bf:	8d 45 d6             	lea    -0x2a(%ebp),%eax
    10c2:	89 44 24 04          	mov    %eax,0x4(%esp)
    10c6:	8b 45 e8             	mov    -0x18(%ebp),%eax
    10c9:	89 04 24             	mov    %eax,(%esp)
    10cc:	e8 0f 33 00 00       	call   43e0 <read>
    10d1:	89 45 e0             	mov    %eax,-0x20(%ebp)
    10d4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
    10d8:	7f a6                	jg     1080 <sharedfd+0x13f>
        nc++;
      if(buf[i] == 'p')
        np++;
    }
  }
  close(fd);
    10da:	8b 45 e8             	mov    -0x18(%ebp),%eax
    10dd:	89 04 24             	mov    %eax,(%esp)
    10e0:	e8 0b 33 00 00       	call   43f0 <close>
  unlink("sharedfd");
    10e5:	c7 04 24 7a 4e 00 00 	movl   $0x4e7a,(%esp)
    10ec:	e8 27 33 00 00       	call   4418 <unlink>
  if(nc == 10000 && np == 10000){
    10f1:	81 7d f0 10 27 00 00 	cmpl   $0x2710,-0x10(%ebp)
    10f8:	75 1f                	jne    1119 <sharedfd+0x1d8>
    10fa:	81 7d ec 10 27 00 00 	cmpl   $0x2710,-0x14(%ebp)
    1101:	75 16                	jne    1119 <sharedfd+0x1d8>
    printf(1, "sharedfd ok\n");
    1103:	c7 44 24 04 fb 4e 00 	movl   $0x4efb,0x4(%esp)
    110a:	00 
    110b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1112:	e8 28 34 00 00       	call   453f <printf>
    1117:	eb 2e                	jmp    1147 <sharedfd+0x206>
  } else {
    printf(1, "sharedfd oops %d %d\n", nc, np);
    1119:	8b 45 ec             	mov    -0x14(%ebp),%eax
    111c:	89 44 24 0c          	mov    %eax,0xc(%esp)
    1120:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1123:	89 44 24 08          	mov    %eax,0x8(%esp)
    1127:	c7 44 24 04 08 4f 00 	movl   $0x4f08,0x4(%esp)
    112e:	00 
    112f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1136:	e8 04 34 00 00       	call   453f <printf>
    exit(EXIT_STATUS_DEFAULT);
    113b:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    1142:	e8 81 32 00 00       	call   43c8 <exit>
  }
}
    1147:	c9                   	leave  
    1148:	c3                   	ret    

00001149 <fourfiles>:

// four processes write different files at the same
// time, to test block allocation.
void
fourfiles(void)
{
    1149:	55                   	push   %ebp
    114a:	89 e5                	mov    %esp,%ebp
    114c:	83 ec 48             	sub    $0x48,%esp
  int fd, pid, i, j, n, total, pi;
  char *names[] = { "f0", "f1", "f2", "f3" };
    114f:	c7 45 c8 1d 4f 00 00 	movl   $0x4f1d,-0x38(%ebp)
    1156:	c7 45 cc 20 4f 00 00 	movl   $0x4f20,-0x34(%ebp)
    115d:	c7 45 d0 23 4f 00 00 	movl   $0x4f23,-0x30(%ebp)
    1164:	c7 45 d4 26 4f 00 00 	movl   $0x4f26,-0x2c(%ebp)
  char *fname;

  printf(1, "fourfiles test\n");
    116b:	c7 44 24 04 29 4f 00 	movl   $0x4f29,0x4(%esp)
    1172:	00 
    1173:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    117a:	e8 c0 33 00 00       	call   453f <printf>

  for(pi = 0; pi < 4; pi++){
    117f:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
    1186:	e9 18 01 00 00       	jmp    12a3 <fourfiles+0x15a>
    fname = names[pi];
    118b:	8b 45 e8             	mov    -0x18(%ebp),%eax
    118e:	8b 44 85 c8          	mov    -0x38(%ebp,%eax,4),%eax
    1192:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    unlink(fname);
    1195:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    1198:	89 04 24             	mov    %eax,(%esp)
    119b:	e8 78 32 00 00       	call   4418 <unlink>

    pid = fork();
    11a0:	e8 1b 32 00 00       	call   43c0 <fork>
    11a5:	89 45 e0             	mov    %eax,-0x20(%ebp)
    if(pid < 0){
    11a8:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
    11ac:	79 20                	jns    11ce <fourfiles+0x85>
      printf(1, "fork failed\n");
    11ae:	c7 44 24 04 a5 49 00 	movl   $0x49a5,0x4(%esp)
    11b5:	00 
    11b6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    11bd:	e8 7d 33 00 00       	call   453f <printf>
      exit(EXIT_STATUS_DEFAULT);
    11c2:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    11c9:	e8 fa 31 00 00       	call   43c8 <exit>
    }

    if(pid == 0){
    11ce:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
    11d2:	0f 85 c7 00 00 00    	jne    129f <fourfiles+0x156>
      fd = open(fname, O_CREATE | O_RDWR);
    11d8:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
    11df:	00 
    11e0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    11e3:	89 04 24             	mov    %eax,(%esp)
    11e6:	e8 1d 32 00 00       	call   4408 <open>
    11eb:	89 45 dc             	mov    %eax,-0x24(%ebp)
      if(fd < 0){
    11ee:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
    11f2:	79 20                	jns    1214 <fourfiles+0xcb>
        printf(1, "create failed\n");
    11f4:	c7 44 24 04 39 4f 00 	movl   $0x4f39,0x4(%esp)
    11fb:	00 
    11fc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1203:	e8 37 33 00 00       	call   453f <printf>
        exit(EXIT_STATUS_DEFAULT);
    1208:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    120f:	e8 b4 31 00 00       	call   43c8 <exit>
      }
      
      memset(buf, '0'+pi, 512);
    1214:	8b 45 e8             	mov    -0x18(%ebp),%eax
    1217:	83 c0 30             	add    $0x30,%eax
    121a:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
    1221:	00 
    1222:	89 44 24 04          	mov    %eax,0x4(%esp)
    1226:	c7 04 24 a0 8f 00 00 	movl   $0x8fa0,(%esp)
    122d:	e8 f1 2f 00 00       	call   4223 <memset>
      for(i = 0; i < 12; i++){
    1232:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    1239:	eb 52                	jmp    128d <fourfiles+0x144>
        if((n = write(fd, buf, 500)) != 500){
    123b:	c7 44 24 08 f4 01 00 	movl   $0x1f4,0x8(%esp)
    1242:	00 
    1243:	c7 44 24 04 a0 8f 00 	movl   $0x8fa0,0x4(%esp)
    124a:	00 
    124b:	8b 45 dc             	mov    -0x24(%ebp),%eax
    124e:	89 04 24             	mov    %eax,(%esp)
    1251:	e8 92 31 00 00       	call   43e8 <write>
    1256:	89 45 d8             	mov    %eax,-0x28(%ebp)
    1259:	81 7d d8 f4 01 00 00 	cmpl   $0x1f4,-0x28(%ebp)
    1260:	74 27                	je     1289 <fourfiles+0x140>
          printf(1, "write failed %d\n", n);
    1262:	8b 45 d8             	mov    -0x28(%ebp),%eax
    1265:	89 44 24 08          	mov    %eax,0x8(%esp)
    1269:	c7 44 24 04 48 4f 00 	movl   $0x4f48,0x4(%esp)
    1270:	00 
    1271:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1278:	e8 c2 32 00 00       	call   453f <printf>
          exit(EXIT_STATUS_DEFAULT);
    127d:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    1284:	e8 3f 31 00 00       	call   43c8 <exit>
        printf(1, "create failed\n");
        exit(EXIT_STATUS_DEFAULT);
      }
      
      memset(buf, '0'+pi, 512);
      for(i = 0; i < 12; i++){
    1289:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    128d:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
    1291:	7e a8                	jle    123b <fourfiles+0xf2>
        if((n = write(fd, buf, 500)) != 500){
          printf(1, "write failed %d\n", n);
          exit(EXIT_STATUS_DEFAULT);
        }
      }
      exit(EXIT_STATUS_DEFAULT);
    1293:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    129a:	e8 29 31 00 00       	call   43c8 <exit>
  char *names[] = { "f0", "f1", "f2", "f3" };
  char *fname;

  printf(1, "fourfiles test\n");

  for(pi = 0; pi < 4; pi++){
    129f:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
    12a3:	83 7d e8 03          	cmpl   $0x3,-0x18(%ebp)
    12a7:	0f 8e de fe ff ff    	jle    118b <fourfiles+0x42>
      }
      exit(EXIT_STATUS_DEFAULT);
    }
  }

  for(pi = 0; pi < 4; pi++){
    12ad:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
    12b4:	eb 09                	jmp    12bf <fourfiles+0x176>
    wait();
    12b6:	e8 15 31 00 00       	call   43d0 <wait>
      }
      exit(EXIT_STATUS_DEFAULT);
    }
  }

  for(pi = 0; pi < 4; pi++){
    12bb:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
    12bf:	83 7d e8 03          	cmpl   $0x3,-0x18(%ebp)
    12c3:	7e f1                	jle    12b6 <fourfiles+0x16d>
    wait();
  }

  for(i = 0; i < 2; i++){
    12c5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    12cc:	e9 ea 00 00 00       	jmp    13bb <fourfiles+0x272>
    fname = names[i];
    12d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
    12d4:	8b 44 85 c8          	mov    -0x38(%ebp,%eax,4),%eax
    12d8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    fd = open(fname, 0);
    12db:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    12e2:	00 
    12e3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    12e6:	89 04 24             	mov    %eax,(%esp)
    12e9:	e8 1a 31 00 00       	call   4408 <open>
    12ee:	89 45 dc             	mov    %eax,-0x24(%ebp)
    total = 0;
    12f1:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
    while((n = read(fd, buf, sizeof(buf))) > 0){
    12f8:	eb 53                	jmp    134d <fourfiles+0x204>
      for(j = 0; j < n; j++){
    12fa:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    1301:	eb 3c                	jmp    133f <fourfiles+0x1f6>
        if(buf[j] != '0'+i){
    1303:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1306:	05 a0 8f 00 00       	add    $0x8fa0,%eax
    130b:	0f b6 00             	movzbl (%eax),%eax
    130e:	0f be c0             	movsbl %al,%eax
    1311:	8b 55 f4             	mov    -0xc(%ebp),%edx
    1314:	83 c2 30             	add    $0x30,%edx
    1317:	39 d0                	cmp    %edx,%eax
    1319:	74 20                	je     133b <fourfiles+0x1f2>
          printf(1, "wrong char\n");
    131b:	c7 44 24 04 59 4f 00 	movl   $0x4f59,0x4(%esp)
    1322:	00 
    1323:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    132a:	e8 10 32 00 00       	call   453f <printf>
          exit(EXIT_STATUS_DEFAULT);
    132f:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    1336:	e8 8d 30 00 00       	call   43c8 <exit>
  for(i = 0; i < 2; i++){
    fname = names[i];
    fd = open(fname, 0);
    total = 0;
    while((n = read(fd, buf, sizeof(buf))) > 0){
      for(j = 0; j < n; j++){
    133b:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
    133f:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1342:	3b 45 d8             	cmp    -0x28(%ebp),%eax
    1345:	7c bc                	jl     1303 <fourfiles+0x1ba>
        if(buf[j] != '0'+i){
          printf(1, "wrong char\n");
          exit(EXIT_STATUS_DEFAULT);
        }
      }
      total += n;
    1347:	8b 45 d8             	mov    -0x28(%ebp),%eax
    134a:	01 45 ec             	add    %eax,-0x14(%ebp)

  for(i = 0; i < 2; i++){
    fname = names[i];
    fd = open(fname, 0);
    total = 0;
    while((n = read(fd, buf, sizeof(buf))) > 0){
    134d:	c7 44 24 08 00 20 00 	movl   $0x2000,0x8(%esp)
    1354:	00 
    1355:	c7 44 24 04 a0 8f 00 	movl   $0x8fa0,0x4(%esp)
    135c:	00 
    135d:	8b 45 dc             	mov    -0x24(%ebp),%eax
    1360:	89 04 24             	mov    %eax,(%esp)
    1363:	e8 78 30 00 00       	call   43e0 <read>
    1368:	89 45 d8             	mov    %eax,-0x28(%ebp)
    136b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
    136f:	7f 89                	jg     12fa <fourfiles+0x1b1>
          exit(EXIT_STATUS_DEFAULT);
        }
      }
      total += n;
    }
    close(fd);
    1371:	8b 45 dc             	mov    -0x24(%ebp),%eax
    1374:	89 04 24             	mov    %eax,(%esp)
    1377:	e8 74 30 00 00       	call   43f0 <close>
    if(total != 12*500){
    137c:	81 7d ec 70 17 00 00 	cmpl   $0x1770,-0x14(%ebp)
    1383:	74 27                	je     13ac <fourfiles+0x263>
      printf(1, "wrong length %d\n", total);
    1385:	8b 45 ec             	mov    -0x14(%ebp),%eax
    1388:	89 44 24 08          	mov    %eax,0x8(%esp)
    138c:	c7 44 24 04 65 4f 00 	movl   $0x4f65,0x4(%esp)
    1393:	00 
    1394:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    139b:	e8 9f 31 00 00       	call   453f <printf>
      exit(EXIT_STATUS_DEFAULT);
    13a0:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    13a7:	e8 1c 30 00 00       	call   43c8 <exit>
    }
    unlink(fname);
    13ac:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    13af:	89 04 24             	mov    %eax,(%esp)
    13b2:	e8 61 30 00 00       	call   4418 <unlink>

  for(pi = 0; pi < 4; pi++){
    wait();
  }

  for(i = 0; i < 2; i++){
    13b7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    13bb:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
    13bf:	0f 8e 0c ff ff ff    	jle    12d1 <fourfiles+0x188>
      exit(EXIT_STATUS_DEFAULT);
    }
    unlink(fname);
  }

  printf(1, "fourfiles ok\n");
    13c5:	c7 44 24 04 76 4f 00 	movl   $0x4f76,0x4(%esp)
    13cc:	00 
    13cd:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    13d4:	e8 66 31 00 00       	call   453f <printf>
}
    13d9:	c9                   	leave  
    13da:	c3                   	ret    

000013db <createdelete>:

// four processes create and delete different files in same directory
void
createdelete(void)
{
    13db:	55                   	push   %ebp
    13dc:	89 e5                	mov    %esp,%ebp
    13de:	83 ec 48             	sub    $0x48,%esp
  enum { N = 20 };
  int pid, i, fd, pi;
  char name[32];

  printf(1, "createdelete test\n");
    13e1:	c7 44 24 04 84 4f 00 	movl   $0x4f84,0x4(%esp)
    13e8:	00 
    13e9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    13f0:	e8 4a 31 00 00       	call   453f <printf>

  for(pi = 0; pi < 4; pi++){
    13f5:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    13fc:	e9 10 01 00 00       	jmp    1511 <createdelete+0x136>
    pid = fork();
    1401:	e8 ba 2f 00 00       	call   43c0 <fork>
    1406:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(pid < 0){
    1409:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    140d:	79 20                	jns    142f <createdelete+0x54>
      printf(1, "fork failed\n");
    140f:	c7 44 24 04 a5 49 00 	movl   $0x49a5,0x4(%esp)
    1416:	00 
    1417:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    141e:	e8 1c 31 00 00       	call   453f <printf>
      exit(EXIT_STATUS_DEFAULT);
    1423:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    142a:	e8 99 2f 00 00       	call   43c8 <exit>
    }

    if(pid == 0){
    142f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    1433:	0f 85 d4 00 00 00    	jne    150d <createdelete+0x132>
      name[0] = 'p' + pi;
    1439:	8b 45 f0             	mov    -0x10(%ebp),%eax
    143c:	83 c0 70             	add    $0x70,%eax
    143f:	88 45 c8             	mov    %al,-0x38(%ebp)
      name[2] = '\0';
    1442:	c6 45 ca 00          	movb   $0x0,-0x36(%ebp)
      for(i = 0; i < N; i++){
    1446:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    144d:	e9 a5 00 00 00       	jmp    14f7 <createdelete+0x11c>
        name[1] = '0' + i;
    1452:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1455:	83 c0 30             	add    $0x30,%eax
    1458:	88 45 c9             	mov    %al,-0x37(%ebp)
        fd = open(name, O_CREATE | O_RDWR);
    145b:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
    1462:	00 
    1463:	8d 45 c8             	lea    -0x38(%ebp),%eax
    1466:	89 04 24             	mov    %eax,(%esp)
    1469:	e8 9a 2f 00 00       	call   4408 <open>
    146e:	89 45 e8             	mov    %eax,-0x18(%ebp)
        if(fd < 0){
    1471:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
    1475:	79 20                	jns    1497 <createdelete+0xbc>
          printf(1, "create failed\n");
    1477:	c7 44 24 04 39 4f 00 	movl   $0x4f39,0x4(%esp)
    147e:	00 
    147f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1486:	e8 b4 30 00 00       	call   453f <printf>
          exit(EXIT_STATUS_DEFAULT);
    148b:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    1492:	e8 31 2f 00 00       	call   43c8 <exit>
        }
        close(fd);
    1497:	8b 45 e8             	mov    -0x18(%ebp),%eax
    149a:	89 04 24             	mov    %eax,(%esp)
    149d:	e8 4e 2f 00 00       	call   43f0 <close>
        if(i > 0 && (i % 2 ) == 0){
    14a2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    14a6:	7e 4b                	jle    14f3 <createdelete+0x118>
    14a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
    14ab:	83 e0 01             	and    $0x1,%eax
    14ae:	85 c0                	test   %eax,%eax
    14b0:	75 41                	jne    14f3 <createdelete+0x118>
          name[1] = '0' + (i / 2);
    14b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
    14b5:	89 c2                	mov    %eax,%edx
    14b7:	c1 ea 1f             	shr    $0x1f,%edx
    14ba:	01 d0                	add    %edx,%eax
    14bc:	d1 f8                	sar    %eax
    14be:	83 c0 30             	add    $0x30,%eax
    14c1:	88 45 c9             	mov    %al,-0x37(%ebp)
          if(unlink(name) < 0){
    14c4:	8d 45 c8             	lea    -0x38(%ebp),%eax
    14c7:	89 04 24             	mov    %eax,(%esp)
    14ca:	e8 49 2f 00 00       	call   4418 <unlink>
    14cf:	85 c0                	test   %eax,%eax
    14d1:	79 20                	jns    14f3 <createdelete+0x118>
            printf(1, "unlink failed\n");
    14d3:	c7 44 24 04 28 4a 00 	movl   $0x4a28,0x4(%esp)
    14da:	00 
    14db:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    14e2:	e8 58 30 00 00       	call   453f <printf>
            exit(EXIT_STATUS_DEFAULT);
    14e7:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    14ee:	e8 d5 2e 00 00       	call   43c8 <exit>
    }

    if(pid == 0){
      name[0] = 'p' + pi;
      name[2] = '\0';
      for(i = 0; i < N; i++){
    14f3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    14f7:	83 7d f4 13          	cmpl   $0x13,-0xc(%ebp)
    14fb:	0f 8e 51 ff ff ff    	jle    1452 <createdelete+0x77>
            printf(1, "unlink failed\n");
            exit(EXIT_STATUS_DEFAULT);
          }
        }
      }
      exit(EXIT_STATUS_DEFAULT);
    1501:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    1508:	e8 bb 2e 00 00       	call   43c8 <exit>
  int pid, i, fd, pi;
  char name[32];

  printf(1, "createdelete test\n");

  for(pi = 0; pi < 4; pi++){
    150d:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
    1511:	83 7d f0 03          	cmpl   $0x3,-0x10(%ebp)
    1515:	0f 8e e6 fe ff ff    	jle    1401 <createdelete+0x26>
      }
      exit(EXIT_STATUS_DEFAULT);
    }
  }

  for(pi = 0; pi < 4; pi++){
    151b:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    1522:	eb 09                	jmp    152d <createdelete+0x152>
    wait();
    1524:	e8 a7 2e 00 00       	call   43d0 <wait>
      }
      exit(EXIT_STATUS_DEFAULT);
    }
  }

  for(pi = 0; pi < 4; pi++){
    1529:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
    152d:	83 7d f0 03          	cmpl   $0x3,-0x10(%ebp)
    1531:	7e f1                	jle    1524 <createdelete+0x149>
    wait();
  }

  name[0] = name[1] = name[2] = 0;
    1533:	c6 45 ca 00          	movb   $0x0,-0x36(%ebp)
    1537:	0f b6 45 ca          	movzbl -0x36(%ebp),%eax
    153b:	88 45 c9             	mov    %al,-0x37(%ebp)
    153e:	0f b6 45 c9          	movzbl -0x37(%ebp),%eax
    1542:	88 45 c8             	mov    %al,-0x38(%ebp)
  for(i = 0; i < N; i++){
    1545:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    154c:	e9 c9 00 00 00       	jmp    161a <createdelete+0x23f>
    for(pi = 0; pi < 4; pi++){
    1551:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    1558:	e9 af 00 00 00       	jmp    160c <createdelete+0x231>
      name[0] = 'p' + pi;
    155d:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1560:	83 c0 70             	add    $0x70,%eax
    1563:	88 45 c8             	mov    %al,-0x38(%ebp)
      name[1] = '0' + i;
    1566:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1569:	83 c0 30             	add    $0x30,%eax
    156c:	88 45 c9             	mov    %al,-0x37(%ebp)
      fd = open(name, 0);
    156f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    1576:	00 
    1577:	8d 45 c8             	lea    -0x38(%ebp),%eax
    157a:	89 04 24             	mov    %eax,(%esp)
    157d:	e8 86 2e 00 00       	call   4408 <open>
    1582:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((i == 0 || i >= N/2) && fd < 0){
    1585:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    1589:	74 06                	je     1591 <createdelete+0x1b6>
    158b:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
    158f:	7e 2d                	jle    15be <createdelete+0x1e3>
    1591:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
    1595:	79 27                	jns    15be <createdelete+0x1e3>
        printf(1, "oops createdelete %s didn't exist\n", name);
    1597:	8d 45 c8             	lea    -0x38(%ebp),%eax
    159a:	89 44 24 08          	mov    %eax,0x8(%esp)
    159e:	c7 44 24 04 98 4f 00 	movl   $0x4f98,0x4(%esp)
    15a5:	00 
    15a6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    15ad:	e8 8d 2f 00 00       	call   453f <printf>
        exit(EXIT_STATUS_DEFAULT);
    15b2:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    15b9:	e8 0a 2e 00 00       	call   43c8 <exit>
      } else if((i >= 1 && i < N/2) && fd >= 0){
    15be:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    15c2:	7e 33                	jle    15f7 <createdelete+0x21c>
    15c4:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
    15c8:	7f 2d                	jg     15f7 <createdelete+0x21c>
    15ca:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
    15ce:	78 27                	js     15f7 <createdelete+0x21c>
        printf(1, "oops createdelete %s did exist\n", name);
    15d0:	8d 45 c8             	lea    -0x38(%ebp),%eax
    15d3:	89 44 24 08          	mov    %eax,0x8(%esp)
    15d7:	c7 44 24 04 bc 4f 00 	movl   $0x4fbc,0x4(%esp)
    15de:	00 
    15df:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    15e6:	e8 54 2f 00 00       	call   453f <printf>
        exit(EXIT_STATUS_DEFAULT);
    15eb:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    15f2:	e8 d1 2d 00 00       	call   43c8 <exit>
      }
      if(fd >= 0)
    15f7:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
    15fb:	78 0b                	js     1608 <createdelete+0x22d>
        close(fd);
    15fd:	8b 45 e8             	mov    -0x18(%ebp),%eax
    1600:	89 04 24             	mov    %eax,(%esp)
    1603:	e8 e8 2d 00 00       	call   43f0 <close>
    wait();
  }

  name[0] = name[1] = name[2] = 0;
  for(i = 0; i < N; i++){
    for(pi = 0; pi < 4; pi++){
    1608:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
    160c:	83 7d f0 03          	cmpl   $0x3,-0x10(%ebp)
    1610:	0f 8e 47 ff ff ff    	jle    155d <createdelete+0x182>
  for(pi = 0; pi < 4; pi++){
    wait();
  }

  name[0] = name[1] = name[2] = 0;
  for(i = 0; i < N; i++){
    1616:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    161a:	83 7d f4 13          	cmpl   $0x13,-0xc(%ebp)
    161e:	0f 8e 2d ff ff ff    	jle    1551 <createdelete+0x176>
      if(fd >= 0)
        close(fd);
    }
  }

  for(i = 0; i < N; i++){
    1624:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    162b:	eb 34                	jmp    1661 <createdelete+0x286>
    for(pi = 0; pi < 4; pi++){
    162d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    1634:	eb 21                	jmp    1657 <createdelete+0x27c>
      name[0] = 'p' + i;
    1636:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1639:	83 c0 70             	add    $0x70,%eax
    163c:	88 45 c8             	mov    %al,-0x38(%ebp)
      name[1] = '0' + i;
    163f:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1642:	83 c0 30             	add    $0x30,%eax
    1645:	88 45 c9             	mov    %al,-0x37(%ebp)
      unlink(name);
    1648:	8d 45 c8             	lea    -0x38(%ebp),%eax
    164b:	89 04 24             	mov    %eax,(%esp)
    164e:	e8 c5 2d 00 00       	call   4418 <unlink>
        close(fd);
    }
  }

  for(i = 0; i < N; i++){
    for(pi = 0; pi < 4; pi++){
    1653:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
    1657:	83 7d f0 03          	cmpl   $0x3,-0x10(%ebp)
    165b:	7e d9                	jle    1636 <createdelete+0x25b>
      if(fd >= 0)
        close(fd);
    }
  }

  for(i = 0; i < N; i++){
    165d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    1661:	83 7d f4 13          	cmpl   $0x13,-0xc(%ebp)
    1665:	7e c6                	jle    162d <createdelete+0x252>
      name[1] = '0' + i;
      unlink(name);
    }
  }

  printf(1, "createdelete ok\n");
    1667:	c7 44 24 04 dc 4f 00 	movl   $0x4fdc,0x4(%esp)
    166e:	00 
    166f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1676:	e8 c4 2e 00 00       	call   453f <printf>
}
    167b:	c9                   	leave  
    167c:	c3                   	ret    

0000167d <unlinkread>:

// can I unlink a file and still read it?
void
unlinkread(void)
{
    167d:	55                   	push   %ebp
    167e:	89 e5                	mov    %esp,%ebp
    1680:	83 ec 28             	sub    $0x28,%esp
  int fd, fd1;

  printf(1, "unlinkread test\n");
    1683:	c7 44 24 04 ed 4f 00 	movl   $0x4fed,0x4(%esp)
    168a:	00 
    168b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1692:	e8 a8 2e 00 00       	call   453f <printf>
  fd = open("unlinkread", O_CREATE | O_RDWR);
    1697:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
    169e:	00 
    169f:	c7 04 24 fe 4f 00 00 	movl   $0x4ffe,(%esp)
    16a6:	e8 5d 2d 00 00       	call   4408 <open>
    16ab:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0){
    16ae:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    16b2:	79 20                	jns    16d4 <unlinkread+0x57>
    printf(1, "create unlinkread failed\n");
    16b4:	c7 44 24 04 09 50 00 	movl   $0x5009,0x4(%esp)
    16bb:	00 
    16bc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    16c3:	e8 77 2e 00 00       	call   453f <printf>
    exit(EXIT_STATUS_DEFAULT);
    16c8:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    16cf:	e8 f4 2c 00 00       	call   43c8 <exit>
  }
  write(fd, "hello", 5);
    16d4:	c7 44 24 08 05 00 00 	movl   $0x5,0x8(%esp)
    16db:	00 
    16dc:	c7 44 24 04 23 50 00 	movl   $0x5023,0x4(%esp)
    16e3:	00 
    16e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
    16e7:	89 04 24             	mov    %eax,(%esp)
    16ea:	e8 f9 2c 00 00       	call   43e8 <write>
  close(fd);
    16ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
    16f2:	89 04 24             	mov    %eax,(%esp)
    16f5:	e8 f6 2c 00 00       	call   43f0 <close>

  fd = open("unlinkread", O_RDWR);
    16fa:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
    1701:	00 
    1702:	c7 04 24 fe 4f 00 00 	movl   $0x4ffe,(%esp)
    1709:	e8 fa 2c 00 00       	call   4408 <open>
    170e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0){
    1711:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    1715:	79 20                	jns    1737 <unlinkread+0xba>
    printf(1, "open unlinkread failed\n");
    1717:	c7 44 24 04 29 50 00 	movl   $0x5029,0x4(%esp)
    171e:	00 
    171f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1726:	e8 14 2e 00 00       	call   453f <printf>
    exit(EXIT_STATUS_DEFAULT);
    172b:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    1732:	e8 91 2c 00 00       	call   43c8 <exit>
  }
  if(unlink("unlinkread") != 0){
    1737:	c7 04 24 fe 4f 00 00 	movl   $0x4ffe,(%esp)
    173e:	e8 d5 2c 00 00       	call   4418 <unlink>
    1743:	85 c0                	test   %eax,%eax
    1745:	74 20                	je     1767 <unlinkread+0xea>
    printf(1, "unlink unlinkread failed\n");
    1747:	c7 44 24 04 41 50 00 	movl   $0x5041,0x4(%esp)
    174e:	00 
    174f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1756:	e8 e4 2d 00 00       	call   453f <printf>
    exit(EXIT_STATUS_DEFAULT);
    175b:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    1762:	e8 61 2c 00 00       	call   43c8 <exit>
  }

  fd1 = open("unlinkread", O_CREATE | O_RDWR);
    1767:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
    176e:	00 
    176f:	c7 04 24 fe 4f 00 00 	movl   $0x4ffe,(%esp)
    1776:	e8 8d 2c 00 00       	call   4408 <open>
    177b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  write(fd1, "yyy", 3);
    177e:	c7 44 24 08 03 00 00 	movl   $0x3,0x8(%esp)
    1785:	00 
    1786:	c7 44 24 04 5b 50 00 	movl   $0x505b,0x4(%esp)
    178d:	00 
    178e:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1791:	89 04 24             	mov    %eax,(%esp)
    1794:	e8 4f 2c 00 00       	call   43e8 <write>
  close(fd1);
    1799:	8b 45 f0             	mov    -0x10(%ebp),%eax
    179c:	89 04 24             	mov    %eax,(%esp)
    179f:	e8 4c 2c 00 00       	call   43f0 <close>

  if(read(fd, buf, sizeof(buf)) != 5){
    17a4:	c7 44 24 08 00 20 00 	movl   $0x2000,0x8(%esp)
    17ab:	00 
    17ac:	c7 44 24 04 a0 8f 00 	movl   $0x8fa0,0x4(%esp)
    17b3:	00 
    17b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
    17b7:	89 04 24             	mov    %eax,(%esp)
    17ba:	e8 21 2c 00 00       	call   43e0 <read>
    17bf:	83 f8 05             	cmp    $0x5,%eax
    17c2:	74 20                	je     17e4 <unlinkread+0x167>
    printf(1, "unlinkread read failed");
    17c4:	c7 44 24 04 5f 50 00 	movl   $0x505f,0x4(%esp)
    17cb:	00 
    17cc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    17d3:	e8 67 2d 00 00       	call   453f <printf>
    exit(EXIT_STATUS_DEFAULT);
    17d8:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    17df:	e8 e4 2b 00 00       	call   43c8 <exit>
  }
  if(buf[0] != 'h'){
    17e4:	0f b6 05 a0 8f 00 00 	movzbl 0x8fa0,%eax
    17eb:	3c 68                	cmp    $0x68,%al
    17ed:	74 20                	je     180f <unlinkread+0x192>
    printf(1, "unlinkread wrong data\n");
    17ef:	c7 44 24 04 76 50 00 	movl   $0x5076,0x4(%esp)
    17f6:	00 
    17f7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    17fe:	e8 3c 2d 00 00       	call   453f <printf>
    exit(EXIT_STATUS_DEFAULT);
    1803:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    180a:	e8 b9 2b 00 00       	call   43c8 <exit>
  }
  if(write(fd, buf, 10) != 10){
    180f:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
    1816:	00 
    1817:	c7 44 24 04 a0 8f 00 	movl   $0x8fa0,0x4(%esp)
    181e:	00 
    181f:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1822:	89 04 24             	mov    %eax,(%esp)
    1825:	e8 be 2b 00 00       	call   43e8 <write>
    182a:	83 f8 0a             	cmp    $0xa,%eax
    182d:	74 20                	je     184f <unlinkread+0x1d2>
    printf(1, "unlinkread write failed\n");
    182f:	c7 44 24 04 8d 50 00 	movl   $0x508d,0x4(%esp)
    1836:	00 
    1837:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    183e:	e8 fc 2c 00 00       	call   453f <printf>
    exit(EXIT_STATUS_DEFAULT);
    1843:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    184a:	e8 79 2b 00 00       	call   43c8 <exit>
  }
  close(fd);
    184f:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1852:	89 04 24             	mov    %eax,(%esp)
    1855:	e8 96 2b 00 00       	call   43f0 <close>
  unlink("unlinkread");
    185a:	c7 04 24 fe 4f 00 00 	movl   $0x4ffe,(%esp)
    1861:	e8 b2 2b 00 00       	call   4418 <unlink>
  printf(1, "unlinkread ok\n");
    1866:	c7 44 24 04 a6 50 00 	movl   $0x50a6,0x4(%esp)
    186d:	00 
    186e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1875:	e8 c5 2c 00 00       	call   453f <printf>
}
    187a:	c9                   	leave  
    187b:	c3                   	ret    

0000187c <linktest>:

void
linktest(void)
{
    187c:	55                   	push   %ebp
    187d:	89 e5                	mov    %esp,%ebp
    187f:	83 ec 28             	sub    $0x28,%esp
  int fd;

  printf(1, "linktest\n");
    1882:	c7 44 24 04 b5 50 00 	movl   $0x50b5,0x4(%esp)
    1889:	00 
    188a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1891:	e8 a9 2c 00 00       	call   453f <printf>

  unlink("lf1");
    1896:	c7 04 24 bf 50 00 00 	movl   $0x50bf,(%esp)
    189d:	e8 76 2b 00 00       	call   4418 <unlink>
  unlink("lf2");
    18a2:	c7 04 24 c3 50 00 00 	movl   $0x50c3,(%esp)
    18a9:	e8 6a 2b 00 00       	call   4418 <unlink>

  fd = open("lf1", O_CREATE|O_RDWR);
    18ae:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
    18b5:	00 
    18b6:	c7 04 24 bf 50 00 00 	movl   $0x50bf,(%esp)
    18bd:	e8 46 2b 00 00       	call   4408 <open>
    18c2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0){
    18c5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    18c9:	79 20                	jns    18eb <linktest+0x6f>
    printf(1, "create lf1 failed\n");
    18cb:	c7 44 24 04 c7 50 00 	movl   $0x50c7,0x4(%esp)
    18d2:	00 
    18d3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    18da:	e8 60 2c 00 00       	call   453f <printf>
    exit(EXIT_STATUS_DEFAULT);
    18df:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    18e6:	e8 dd 2a 00 00       	call   43c8 <exit>
  }
  if(write(fd, "hello", 5) != 5){
    18eb:	c7 44 24 08 05 00 00 	movl   $0x5,0x8(%esp)
    18f2:	00 
    18f3:	c7 44 24 04 23 50 00 	movl   $0x5023,0x4(%esp)
    18fa:	00 
    18fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
    18fe:	89 04 24             	mov    %eax,(%esp)
    1901:	e8 e2 2a 00 00       	call   43e8 <write>
    1906:	83 f8 05             	cmp    $0x5,%eax
    1909:	74 20                	je     192b <linktest+0xaf>
    printf(1, "write lf1 failed\n");
    190b:	c7 44 24 04 da 50 00 	movl   $0x50da,0x4(%esp)
    1912:	00 
    1913:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    191a:	e8 20 2c 00 00       	call   453f <printf>
    exit(EXIT_STATUS_DEFAULT);
    191f:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    1926:	e8 9d 2a 00 00       	call   43c8 <exit>
  }
  close(fd);
    192b:	8b 45 f4             	mov    -0xc(%ebp),%eax
    192e:	89 04 24             	mov    %eax,(%esp)
    1931:	e8 ba 2a 00 00       	call   43f0 <close>

  if(link("lf1", "lf2") < 0){
    1936:	c7 44 24 04 c3 50 00 	movl   $0x50c3,0x4(%esp)
    193d:	00 
    193e:	c7 04 24 bf 50 00 00 	movl   $0x50bf,(%esp)
    1945:	e8 de 2a 00 00       	call   4428 <link>
    194a:	85 c0                	test   %eax,%eax
    194c:	79 20                	jns    196e <linktest+0xf2>
    printf(1, "link lf1 lf2 failed\n");
    194e:	c7 44 24 04 ec 50 00 	movl   $0x50ec,0x4(%esp)
    1955:	00 
    1956:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    195d:	e8 dd 2b 00 00       	call   453f <printf>
    exit(EXIT_STATUS_DEFAULT);
    1962:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    1969:	e8 5a 2a 00 00       	call   43c8 <exit>
  }
  unlink("lf1");
    196e:	c7 04 24 bf 50 00 00 	movl   $0x50bf,(%esp)
    1975:	e8 9e 2a 00 00       	call   4418 <unlink>

  if(open("lf1", 0) >= 0){
    197a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    1981:	00 
    1982:	c7 04 24 bf 50 00 00 	movl   $0x50bf,(%esp)
    1989:	e8 7a 2a 00 00       	call   4408 <open>
    198e:	85 c0                	test   %eax,%eax
    1990:	78 20                	js     19b2 <linktest+0x136>
    printf(1, "unlinked lf1 but it is still there!\n");
    1992:	c7 44 24 04 04 51 00 	movl   $0x5104,0x4(%esp)
    1999:	00 
    199a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    19a1:	e8 99 2b 00 00       	call   453f <printf>
    exit(EXIT_STATUS_DEFAULT);
    19a6:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    19ad:	e8 16 2a 00 00       	call   43c8 <exit>
  }

  fd = open("lf2", 0);
    19b2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    19b9:	00 
    19ba:	c7 04 24 c3 50 00 00 	movl   $0x50c3,(%esp)
    19c1:	e8 42 2a 00 00       	call   4408 <open>
    19c6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0){
    19c9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    19cd:	79 20                	jns    19ef <linktest+0x173>
    printf(1, "open lf2 failed\n");
    19cf:	c7 44 24 04 29 51 00 	movl   $0x5129,0x4(%esp)
    19d6:	00 
    19d7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    19de:	e8 5c 2b 00 00       	call   453f <printf>
    exit(EXIT_STATUS_DEFAULT);
    19e3:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    19ea:	e8 d9 29 00 00       	call   43c8 <exit>
  }
  if(read(fd, buf, sizeof(buf)) != 5){
    19ef:	c7 44 24 08 00 20 00 	movl   $0x2000,0x8(%esp)
    19f6:	00 
    19f7:	c7 44 24 04 a0 8f 00 	movl   $0x8fa0,0x4(%esp)
    19fe:	00 
    19ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1a02:	89 04 24             	mov    %eax,(%esp)
    1a05:	e8 d6 29 00 00       	call   43e0 <read>
    1a0a:	83 f8 05             	cmp    $0x5,%eax
    1a0d:	74 20                	je     1a2f <linktest+0x1b3>
    printf(1, "read lf2 failed\n");
    1a0f:	c7 44 24 04 3a 51 00 	movl   $0x513a,0x4(%esp)
    1a16:	00 
    1a17:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1a1e:	e8 1c 2b 00 00       	call   453f <printf>
    exit(EXIT_STATUS_DEFAULT);
    1a23:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    1a2a:	e8 99 29 00 00       	call   43c8 <exit>
  }
  close(fd);
    1a2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1a32:	89 04 24             	mov    %eax,(%esp)
    1a35:	e8 b6 29 00 00       	call   43f0 <close>

  if(link("lf2", "lf2") >= 0){
    1a3a:	c7 44 24 04 c3 50 00 	movl   $0x50c3,0x4(%esp)
    1a41:	00 
    1a42:	c7 04 24 c3 50 00 00 	movl   $0x50c3,(%esp)
    1a49:	e8 da 29 00 00       	call   4428 <link>
    1a4e:	85 c0                	test   %eax,%eax
    1a50:	78 20                	js     1a72 <linktest+0x1f6>
    printf(1, "link lf2 lf2 succeeded! oops\n");
    1a52:	c7 44 24 04 4b 51 00 	movl   $0x514b,0x4(%esp)
    1a59:	00 
    1a5a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1a61:	e8 d9 2a 00 00       	call   453f <printf>
    exit(EXIT_STATUS_DEFAULT);
    1a66:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    1a6d:	e8 56 29 00 00       	call   43c8 <exit>
  }

  unlink("lf2");
    1a72:	c7 04 24 c3 50 00 00 	movl   $0x50c3,(%esp)
    1a79:	e8 9a 29 00 00       	call   4418 <unlink>
  if(link("lf2", "lf1") >= 0){
    1a7e:	c7 44 24 04 bf 50 00 	movl   $0x50bf,0x4(%esp)
    1a85:	00 
    1a86:	c7 04 24 c3 50 00 00 	movl   $0x50c3,(%esp)
    1a8d:	e8 96 29 00 00       	call   4428 <link>
    1a92:	85 c0                	test   %eax,%eax
    1a94:	78 20                	js     1ab6 <linktest+0x23a>
    printf(1, "link non-existant succeeded! oops\n");
    1a96:	c7 44 24 04 6c 51 00 	movl   $0x516c,0x4(%esp)
    1a9d:	00 
    1a9e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1aa5:	e8 95 2a 00 00       	call   453f <printf>
    exit(EXIT_STATUS_DEFAULT);
    1aaa:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    1ab1:	e8 12 29 00 00       	call   43c8 <exit>
  }

  if(link(".", "lf1") >= 0){
    1ab6:	c7 44 24 04 bf 50 00 	movl   $0x50bf,0x4(%esp)
    1abd:	00 
    1abe:	c7 04 24 8f 51 00 00 	movl   $0x518f,(%esp)
    1ac5:	e8 5e 29 00 00       	call   4428 <link>
    1aca:	85 c0                	test   %eax,%eax
    1acc:	78 20                	js     1aee <linktest+0x272>
    printf(1, "link . lf1 succeeded! oops\n");
    1ace:	c7 44 24 04 91 51 00 	movl   $0x5191,0x4(%esp)
    1ad5:	00 
    1ad6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1add:	e8 5d 2a 00 00       	call   453f <printf>
    exit(EXIT_STATUS_DEFAULT);
    1ae2:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    1ae9:	e8 da 28 00 00       	call   43c8 <exit>
  }

  printf(1, "linktest ok\n");
    1aee:	c7 44 24 04 ad 51 00 	movl   $0x51ad,0x4(%esp)
    1af5:	00 
    1af6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1afd:	e8 3d 2a 00 00       	call   453f <printf>
}
    1b02:	c9                   	leave  
    1b03:	c3                   	ret    

00001b04 <concreate>:

// test concurrent create/link/unlink of the same file
void
concreate(void)
{
    1b04:	55                   	push   %ebp
    1b05:	89 e5                	mov    %esp,%ebp
    1b07:	83 ec 68             	sub    $0x68,%esp
  struct {
    ushort inum;
    char name[14];
  } de;

  printf(1, "concreate test\n");
    1b0a:	c7 44 24 04 ba 51 00 	movl   $0x51ba,0x4(%esp)
    1b11:	00 
    1b12:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1b19:	e8 21 2a 00 00       	call   453f <printf>
  file[0] = 'C';
    1b1e:	c6 45 e5 43          	movb   $0x43,-0x1b(%ebp)
  file[2] = '\0';
    1b22:	c6 45 e7 00          	movb   $0x0,-0x19(%ebp)
  for(i = 0; i < 40; i++){
    1b26:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    1b2d:	e9 05 01 00 00       	jmp    1c37 <concreate+0x133>
    file[1] = '0' + i;
    1b32:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1b35:	83 c0 30             	add    $0x30,%eax
    1b38:	88 45 e6             	mov    %al,-0x1a(%ebp)
    unlink(file);
    1b3b:	8d 45 e5             	lea    -0x1b(%ebp),%eax
    1b3e:	89 04 24             	mov    %eax,(%esp)
    1b41:	e8 d2 28 00 00       	call   4418 <unlink>
    pid = fork();
    1b46:	e8 75 28 00 00       	call   43c0 <fork>
    1b4b:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(pid && (i % 3) == 1){
    1b4e:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    1b52:	74 3a                	je     1b8e <concreate+0x8a>
    1b54:	8b 4d f4             	mov    -0xc(%ebp),%ecx
    1b57:	ba 56 55 55 55       	mov    $0x55555556,%edx
    1b5c:	89 c8                	mov    %ecx,%eax
    1b5e:	f7 ea                	imul   %edx
    1b60:	89 c8                	mov    %ecx,%eax
    1b62:	c1 f8 1f             	sar    $0x1f,%eax
    1b65:	29 c2                	sub    %eax,%edx
    1b67:	89 d0                	mov    %edx,%eax
    1b69:	01 c0                	add    %eax,%eax
    1b6b:	01 d0                	add    %edx,%eax
    1b6d:	89 ca                	mov    %ecx,%edx
    1b6f:	29 c2                	sub    %eax,%edx
    1b71:	83 fa 01             	cmp    $0x1,%edx
    1b74:	75 18                	jne    1b8e <concreate+0x8a>
      link("C0", file);
    1b76:	8d 45 e5             	lea    -0x1b(%ebp),%eax
    1b79:	89 44 24 04          	mov    %eax,0x4(%esp)
    1b7d:	c7 04 24 ca 51 00 00 	movl   $0x51ca,(%esp)
    1b84:	e8 9f 28 00 00       	call   4428 <link>
    1b89:	e9 8e 00 00 00       	jmp    1c1c <concreate+0x118>
    } else if(pid == 0 && (i % 5) == 1){
    1b8e:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    1b92:	75 3a                	jne    1bce <concreate+0xca>
    1b94:	8b 4d f4             	mov    -0xc(%ebp),%ecx
    1b97:	ba 67 66 66 66       	mov    $0x66666667,%edx
    1b9c:	89 c8                	mov    %ecx,%eax
    1b9e:	f7 ea                	imul   %edx
    1ba0:	d1 fa                	sar    %edx
    1ba2:	89 c8                	mov    %ecx,%eax
    1ba4:	c1 f8 1f             	sar    $0x1f,%eax
    1ba7:	29 c2                	sub    %eax,%edx
    1ba9:	89 d0                	mov    %edx,%eax
    1bab:	c1 e0 02             	shl    $0x2,%eax
    1bae:	01 d0                	add    %edx,%eax
    1bb0:	89 ca                	mov    %ecx,%edx
    1bb2:	29 c2                	sub    %eax,%edx
    1bb4:	83 fa 01             	cmp    $0x1,%edx
    1bb7:	75 15                	jne    1bce <concreate+0xca>
      link("C0", file);
    1bb9:	8d 45 e5             	lea    -0x1b(%ebp),%eax
    1bbc:	89 44 24 04          	mov    %eax,0x4(%esp)
    1bc0:	c7 04 24 ca 51 00 00 	movl   $0x51ca,(%esp)
    1bc7:	e8 5c 28 00 00       	call   4428 <link>
    1bcc:	eb 4e                	jmp    1c1c <concreate+0x118>
    } else {
      fd = open(file, O_CREATE | O_RDWR);
    1bce:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
    1bd5:	00 
    1bd6:	8d 45 e5             	lea    -0x1b(%ebp),%eax
    1bd9:	89 04 24             	mov    %eax,(%esp)
    1bdc:	e8 27 28 00 00       	call   4408 <open>
    1be1:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if(fd < 0){
    1be4:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
    1be8:	79 27                	jns    1c11 <concreate+0x10d>
        printf(1, "concreate create %s failed\n", file);
    1bea:	8d 45 e5             	lea    -0x1b(%ebp),%eax
    1bed:	89 44 24 08          	mov    %eax,0x8(%esp)
    1bf1:	c7 44 24 04 cd 51 00 	movl   $0x51cd,0x4(%esp)
    1bf8:	00 
    1bf9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1c00:	e8 3a 29 00 00       	call   453f <printf>
        exit(EXIT_STATUS_DEFAULT);
    1c05:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    1c0c:	e8 b7 27 00 00       	call   43c8 <exit>
      }
      close(fd);
    1c11:	8b 45 e8             	mov    -0x18(%ebp),%eax
    1c14:	89 04 24             	mov    %eax,(%esp)
    1c17:	e8 d4 27 00 00       	call   43f0 <close>
    }
    if(pid == 0)
    1c1c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    1c20:	75 0c                	jne    1c2e <concreate+0x12a>
      exit(EXIT_STATUS_DEFAULT);
    1c22:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    1c29:	e8 9a 27 00 00       	call   43c8 <exit>
    else
      wait();
    1c2e:	e8 9d 27 00 00       	call   43d0 <wait>
  } de;

  printf(1, "concreate test\n");
  file[0] = 'C';
  file[2] = '\0';
  for(i = 0; i < 40; i++){
    1c33:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    1c37:	83 7d f4 27          	cmpl   $0x27,-0xc(%ebp)
    1c3b:	0f 8e f1 fe ff ff    	jle    1b32 <concreate+0x2e>
      exit(EXIT_STATUS_DEFAULT);
    else
      wait();
  }

  memset(fa, 0, sizeof(fa));
    1c41:	c7 44 24 08 28 00 00 	movl   $0x28,0x8(%esp)
    1c48:	00 
    1c49:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    1c50:	00 
    1c51:	8d 45 bd             	lea    -0x43(%ebp),%eax
    1c54:	89 04 24             	mov    %eax,(%esp)
    1c57:	e8 c7 25 00 00       	call   4223 <memset>
  fd = open(".", 0);
    1c5c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    1c63:	00 
    1c64:	c7 04 24 8f 51 00 00 	movl   $0x518f,(%esp)
    1c6b:	e8 98 27 00 00       	call   4408 <open>
    1c70:	89 45 e8             	mov    %eax,-0x18(%ebp)
  n = 0;
    1c73:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  while(read(fd, &de, sizeof(de)) > 0){
    1c7a:	e9 b1 00 00 00       	jmp    1d30 <concreate+0x22c>
    if(de.inum == 0)
    1c7f:	0f b7 45 ac          	movzwl -0x54(%ebp),%eax
    1c83:	66 85 c0             	test   %ax,%ax
    1c86:	0f 84 a3 00 00 00    	je     1d2f <concreate+0x22b>
      continue;
    if(de.name[0] == 'C' && de.name[2] == '\0'){
    1c8c:	0f b6 45 ae          	movzbl -0x52(%ebp),%eax
    1c90:	3c 43                	cmp    $0x43,%al
    1c92:	0f 85 98 00 00 00    	jne    1d30 <concreate+0x22c>
    1c98:	0f b6 45 b0          	movzbl -0x50(%ebp),%eax
    1c9c:	84 c0                	test   %al,%al
    1c9e:	0f 85 8c 00 00 00    	jne    1d30 <concreate+0x22c>
      i = de.name[1] - '0';
    1ca4:	0f b6 45 af          	movzbl -0x51(%ebp),%eax
    1ca8:	0f be c0             	movsbl %al,%eax
    1cab:	83 e8 30             	sub    $0x30,%eax
    1cae:	89 45 f4             	mov    %eax,-0xc(%ebp)
      if(i < 0 || i >= sizeof(fa)){
    1cb1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    1cb5:	78 08                	js     1cbf <concreate+0x1bb>
    1cb7:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1cba:	83 f8 27             	cmp    $0x27,%eax
    1cbd:	76 2a                	jbe    1ce9 <concreate+0x1e5>
        printf(1, "concreate weird file %s\n", de.name);
    1cbf:	8d 45 ac             	lea    -0x54(%ebp),%eax
    1cc2:	83 c0 02             	add    $0x2,%eax
    1cc5:	89 44 24 08          	mov    %eax,0x8(%esp)
    1cc9:	c7 44 24 04 e9 51 00 	movl   $0x51e9,0x4(%esp)
    1cd0:	00 
    1cd1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1cd8:	e8 62 28 00 00       	call   453f <printf>
        exit(EXIT_STATUS_DEFAULT);
    1cdd:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    1ce4:	e8 df 26 00 00       	call   43c8 <exit>
      }
      if(fa[i]){
    1ce9:	8d 45 bd             	lea    -0x43(%ebp),%eax
    1cec:	03 45 f4             	add    -0xc(%ebp),%eax
    1cef:	0f b6 00             	movzbl (%eax),%eax
    1cf2:	84 c0                	test   %al,%al
    1cf4:	74 2a                	je     1d20 <concreate+0x21c>
        printf(1, "concreate duplicate file %s\n", de.name);
    1cf6:	8d 45 ac             	lea    -0x54(%ebp),%eax
    1cf9:	83 c0 02             	add    $0x2,%eax
    1cfc:	89 44 24 08          	mov    %eax,0x8(%esp)
    1d00:	c7 44 24 04 02 52 00 	movl   $0x5202,0x4(%esp)
    1d07:	00 
    1d08:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1d0f:	e8 2b 28 00 00       	call   453f <printf>
        exit(EXIT_STATUS_DEFAULT);
    1d14:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    1d1b:	e8 a8 26 00 00       	call   43c8 <exit>
      }
      fa[i] = 1;
    1d20:	8d 45 bd             	lea    -0x43(%ebp),%eax
    1d23:	03 45 f4             	add    -0xc(%ebp),%eax
    1d26:	c6 00 01             	movb   $0x1,(%eax)
      n++;
    1d29:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
    1d2d:	eb 01                	jmp    1d30 <concreate+0x22c>
  memset(fa, 0, sizeof(fa));
  fd = open(".", 0);
  n = 0;
  while(read(fd, &de, sizeof(de)) > 0){
    if(de.inum == 0)
      continue;
    1d2f:	90                   	nop
  }

  memset(fa, 0, sizeof(fa));
  fd = open(".", 0);
  n = 0;
  while(read(fd, &de, sizeof(de)) > 0){
    1d30:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
    1d37:	00 
    1d38:	8d 45 ac             	lea    -0x54(%ebp),%eax
    1d3b:	89 44 24 04          	mov    %eax,0x4(%esp)
    1d3f:	8b 45 e8             	mov    -0x18(%ebp),%eax
    1d42:	89 04 24             	mov    %eax,(%esp)
    1d45:	e8 96 26 00 00       	call   43e0 <read>
    1d4a:	85 c0                	test   %eax,%eax
    1d4c:	0f 8f 2d ff ff ff    	jg     1c7f <concreate+0x17b>
      }
      fa[i] = 1;
      n++;
    }
  }
  close(fd);
    1d52:	8b 45 e8             	mov    -0x18(%ebp),%eax
    1d55:	89 04 24             	mov    %eax,(%esp)
    1d58:	e8 93 26 00 00       	call   43f0 <close>

  if(n != 40){
    1d5d:	83 7d f0 28          	cmpl   $0x28,-0x10(%ebp)
    1d61:	74 20                	je     1d83 <concreate+0x27f>
    printf(1, "concreate not enough files in directory listing\n");
    1d63:	c7 44 24 04 20 52 00 	movl   $0x5220,0x4(%esp)
    1d6a:	00 
    1d6b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1d72:	e8 c8 27 00 00       	call   453f <printf>
    exit(EXIT_STATUS_DEFAULT);
    1d77:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    1d7e:	e8 45 26 00 00       	call   43c8 <exit>
  }

  for(i = 0; i < 40; i++){
    1d83:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    1d8a:	e9 3b 01 00 00       	jmp    1eca <concreate+0x3c6>
    file[1] = '0' + i;
    1d8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1d92:	83 c0 30             	add    $0x30,%eax
    1d95:	88 45 e6             	mov    %al,-0x1a(%ebp)
    pid = fork();
    1d98:	e8 23 26 00 00       	call   43c0 <fork>
    1d9d:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(pid < 0){
    1da0:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    1da4:	79 20                	jns    1dc6 <concreate+0x2c2>
      printf(1, "fork failed\n");
    1da6:	c7 44 24 04 a5 49 00 	movl   $0x49a5,0x4(%esp)
    1dad:	00 
    1dae:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1db5:	e8 85 27 00 00       	call   453f <printf>
      exit(EXIT_STATUS_DEFAULT);
    1dba:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    1dc1:	e8 02 26 00 00       	call   43c8 <exit>
    }
    if(((i % 3) == 0 && pid == 0) ||
    1dc6:	8b 4d f4             	mov    -0xc(%ebp),%ecx
    1dc9:	ba 56 55 55 55       	mov    $0x55555556,%edx
    1dce:	89 c8                	mov    %ecx,%eax
    1dd0:	f7 ea                	imul   %edx
    1dd2:	89 c8                	mov    %ecx,%eax
    1dd4:	c1 f8 1f             	sar    $0x1f,%eax
    1dd7:	29 c2                	sub    %eax,%edx
    1dd9:	89 d0                	mov    %edx,%eax
    1ddb:	01 c0                	add    %eax,%eax
    1ddd:	01 d0                	add    %edx,%eax
    1ddf:	89 ca                	mov    %ecx,%edx
    1de1:	29 c2                	sub    %eax,%edx
    1de3:	85 d2                	test   %edx,%edx
    1de5:	75 06                	jne    1ded <concreate+0x2e9>
    1de7:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    1deb:	74 28                	je     1e15 <concreate+0x311>
       ((i % 3) == 1 && pid != 0)){
    1ded:	8b 4d f4             	mov    -0xc(%ebp),%ecx
    1df0:	ba 56 55 55 55       	mov    $0x55555556,%edx
    1df5:	89 c8                	mov    %ecx,%eax
    1df7:	f7 ea                	imul   %edx
    1df9:	89 c8                	mov    %ecx,%eax
    1dfb:	c1 f8 1f             	sar    $0x1f,%eax
    1dfe:	29 c2                	sub    %eax,%edx
    1e00:	89 d0                	mov    %edx,%eax
    1e02:	01 c0                	add    %eax,%eax
    1e04:	01 d0                	add    %edx,%eax
    1e06:	89 ca                	mov    %ecx,%edx
    1e08:	29 c2                	sub    %eax,%edx
    pid = fork();
    if(pid < 0){
      printf(1, "fork failed\n");
      exit(EXIT_STATUS_DEFAULT);
    }
    if(((i % 3) == 0 && pid == 0) ||
    1e0a:	83 fa 01             	cmp    $0x1,%edx
    1e0d:	75 74                	jne    1e83 <concreate+0x37f>
       ((i % 3) == 1 && pid != 0)){
    1e0f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    1e13:	74 6e                	je     1e83 <concreate+0x37f>
      close(open(file, 0));
    1e15:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    1e1c:	00 
    1e1d:	8d 45 e5             	lea    -0x1b(%ebp),%eax
    1e20:	89 04 24             	mov    %eax,(%esp)
    1e23:	e8 e0 25 00 00       	call   4408 <open>
    1e28:	89 04 24             	mov    %eax,(%esp)
    1e2b:	e8 c0 25 00 00       	call   43f0 <close>
      close(open(file, 0));
    1e30:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    1e37:	00 
    1e38:	8d 45 e5             	lea    -0x1b(%ebp),%eax
    1e3b:	89 04 24             	mov    %eax,(%esp)
    1e3e:	e8 c5 25 00 00       	call   4408 <open>
    1e43:	89 04 24             	mov    %eax,(%esp)
    1e46:	e8 a5 25 00 00       	call   43f0 <close>
      close(open(file, 0));
    1e4b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    1e52:	00 
    1e53:	8d 45 e5             	lea    -0x1b(%ebp),%eax
    1e56:	89 04 24             	mov    %eax,(%esp)
    1e59:	e8 aa 25 00 00       	call   4408 <open>
    1e5e:	89 04 24             	mov    %eax,(%esp)
    1e61:	e8 8a 25 00 00       	call   43f0 <close>
      close(open(file, 0));
    1e66:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    1e6d:	00 
    1e6e:	8d 45 e5             	lea    -0x1b(%ebp),%eax
    1e71:	89 04 24             	mov    %eax,(%esp)
    1e74:	e8 8f 25 00 00       	call   4408 <open>
    1e79:	89 04 24             	mov    %eax,(%esp)
    1e7c:	e8 6f 25 00 00       	call   43f0 <close>
    1e81:	eb 2c                	jmp    1eaf <concreate+0x3ab>
    } else {
      unlink(file);
    1e83:	8d 45 e5             	lea    -0x1b(%ebp),%eax
    1e86:	89 04 24             	mov    %eax,(%esp)
    1e89:	e8 8a 25 00 00       	call   4418 <unlink>
      unlink(file);
    1e8e:	8d 45 e5             	lea    -0x1b(%ebp),%eax
    1e91:	89 04 24             	mov    %eax,(%esp)
    1e94:	e8 7f 25 00 00       	call   4418 <unlink>
      unlink(file);
    1e99:	8d 45 e5             	lea    -0x1b(%ebp),%eax
    1e9c:	89 04 24             	mov    %eax,(%esp)
    1e9f:	e8 74 25 00 00       	call   4418 <unlink>
      unlink(file);
    1ea4:	8d 45 e5             	lea    -0x1b(%ebp),%eax
    1ea7:	89 04 24             	mov    %eax,(%esp)
    1eaa:	e8 69 25 00 00       	call   4418 <unlink>
    }
    if(pid == 0)
    1eaf:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    1eb3:	75 0c                	jne    1ec1 <concreate+0x3bd>
      exit(EXIT_STATUS_DEFAULT);
    1eb5:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    1ebc:	e8 07 25 00 00       	call   43c8 <exit>
    else
      wait();
    1ec1:	e8 0a 25 00 00       	call   43d0 <wait>
  if(n != 40){
    printf(1, "concreate not enough files in directory listing\n");
    exit(EXIT_STATUS_DEFAULT);
  }

  for(i = 0; i < 40; i++){
    1ec6:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    1eca:	83 7d f4 27          	cmpl   $0x27,-0xc(%ebp)
    1ece:	0f 8e bb fe ff ff    	jle    1d8f <concreate+0x28b>
      exit(EXIT_STATUS_DEFAULT);
    else
      wait();
  }

  printf(1, "concreate ok\n");
    1ed4:	c7 44 24 04 51 52 00 	movl   $0x5251,0x4(%esp)
    1edb:	00 
    1edc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1ee3:	e8 57 26 00 00       	call   453f <printf>
}
    1ee8:	c9                   	leave  
    1ee9:	c3                   	ret    

00001eea <linkunlink>:

// another concurrent link/unlink/create test,
// to look for deadlocks.
void
linkunlink()
{
    1eea:	55                   	push   %ebp
    1eeb:	89 e5                	mov    %esp,%ebp
    1eed:	83 ec 28             	sub    $0x28,%esp
  int pid, i;

  printf(1, "linkunlink test\n");
    1ef0:	c7 44 24 04 5f 52 00 	movl   $0x525f,0x4(%esp)
    1ef7:	00 
    1ef8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1eff:	e8 3b 26 00 00       	call   453f <printf>

  unlink("x");
    1f04:	c7 04 24 db 4d 00 00 	movl   $0x4ddb,(%esp)
    1f0b:	e8 08 25 00 00       	call   4418 <unlink>
  pid = fork();
    1f10:	e8 ab 24 00 00       	call   43c0 <fork>
    1f15:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(pid < 0){
    1f18:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    1f1c:	79 20                	jns    1f3e <linkunlink+0x54>
    printf(1, "fork failed\n");
    1f1e:	c7 44 24 04 a5 49 00 	movl   $0x49a5,0x4(%esp)
    1f25:	00 
    1f26:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1f2d:	e8 0d 26 00 00       	call   453f <printf>
    exit(EXIT_STATUS_DEFAULT);
    1f32:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    1f39:	e8 8a 24 00 00       	call   43c8 <exit>
  }

  unsigned int x = (pid ? 1 : 97);
    1f3e:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    1f42:	74 07                	je     1f4b <linkunlink+0x61>
    1f44:	b8 01 00 00 00       	mov    $0x1,%eax
    1f49:	eb 05                	jmp    1f50 <linkunlink+0x66>
    1f4b:	b8 61 00 00 00       	mov    $0x61,%eax
    1f50:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(i = 0; i < 100; i++){
    1f53:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    1f5a:	e9 8e 00 00 00       	jmp    1fed <linkunlink+0x103>
    x = x * 1103515245 + 12345;
    1f5f:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1f62:	69 c0 6d 4e c6 41    	imul   $0x41c64e6d,%eax,%eax
    1f68:	05 39 30 00 00       	add    $0x3039,%eax
    1f6d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((x % 3) == 0){
    1f70:	8b 4d f0             	mov    -0x10(%ebp),%ecx
    1f73:	ba ab aa aa aa       	mov    $0xaaaaaaab,%edx
    1f78:	89 c8                	mov    %ecx,%eax
    1f7a:	f7 e2                	mul    %edx
    1f7c:	d1 ea                	shr    %edx
    1f7e:	89 d0                	mov    %edx,%eax
    1f80:	01 c0                	add    %eax,%eax
    1f82:	01 d0                	add    %edx,%eax
    1f84:	89 ca                	mov    %ecx,%edx
    1f86:	29 c2                	sub    %eax,%edx
    1f88:	85 d2                	test   %edx,%edx
    1f8a:	75 1e                	jne    1faa <linkunlink+0xc0>
      close(open("x", O_RDWR | O_CREATE));
    1f8c:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
    1f93:	00 
    1f94:	c7 04 24 db 4d 00 00 	movl   $0x4ddb,(%esp)
    1f9b:	e8 68 24 00 00       	call   4408 <open>
    1fa0:	89 04 24             	mov    %eax,(%esp)
    1fa3:	e8 48 24 00 00       	call   43f0 <close>
    1fa8:	eb 3f                	jmp    1fe9 <linkunlink+0xff>
    } else if((x % 3) == 1){
    1faa:	8b 4d f0             	mov    -0x10(%ebp),%ecx
    1fad:	ba ab aa aa aa       	mov    $0xaaaaaaab,%edx
    1fb2:	89 c8                	mov    %ecx,%eax
    1fb4:	f7 e2                	mul    %edx
    1fb6:	d1 ea                	shr    %edx
    1fb8:	89 d0                	mov    %edx,%eax
    1fba:	01 c0                	add    %eax,%eax
    1fbc:	01 d0                	add    %edx,%eax
    1fbe:	89 ca                	mov    %ecx,%edx
    1fc0:	29 c2                	sub    %eax,%edx
    1fc2:	83 fa 01             	cmp    $0x1,%edx
    1fc5:	75 16                	jne    1fdd <linkunlink+0xf3>
      link("cat", "x");
    1fc7:	c7 44 24 04 db 4d 00 	movl   $0x4ddb,0x4(%esp)
    1fce:	00 
    1fcf:	c7 04 24 70 52 00 00 	movl   $0x5270,(%esp)
    1fd6:	e8 4d 24 00 00       	call   4428 <link>
    1fdb:	eb 0c                	jmp    1fe9 <linkunlink+0xff>
    } else {
      unlink("x");
    1fdd:	c7 04 24 db 4d 00 00 	movl   $0x4ddb,(%esp)
    1fe4:	e8 2f 24 00 00       	call   4418 <unlink>
    printf(1, "fork failed\n");
    exit(EXIT_STATUS_DEFAULT);
  }

  unsigned int x = (pid ? 1 : 97);
  for(i = 0; i < 100; i++){
    1fe9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    1fed:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
    1ff1:	0f 8e 68 ff ff ff    	jle    1f5f <linkunlink+0x75>
    } else {
      unlink("x");
    }
  }

  if(pid)
    1ff7:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    1ffb:	74 1b                	je     2018 <linkunlink+0x12e>
    wait();
    1ffd:	e8 ce 23 00 00       	call   43d0 <wait>
  else 
    exit(EXIT_STATUS_DEFAULT);

  printf(1, "linkunlink ok\n");
    2002:	c7 44 24 04 74 52 00 	movl   $0x5274,0x4(%esp)
    2009:	00 
    200a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2011:	e8 29 25 00 00       	call   453f <printf>
}
    2016:	c9                   	leave  
    2017:	c3                   	ret    
  }

  if(pid)
    wait();
  else 
    exit(EXIT_STATUS_DEFAULT);
    2018:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    201f:	e8 a4 23 00 00       	call   43c8 <exit>

00002024 <bigdir>:
}

// directory that uses indirect blocks
void
bigdir(void)
{
    2024:	55                   	push   %ebp
    2025:	89 e5                	mov    %esp,%ebp
    2027:	83 ec 38             	sub    $0x38,%esp
  int i, fd;
  char name[10];

  printf(1, "bigdir test\n");
    202a:	c7 44 24 04 83 52 00 	movl   $0x5283,0x4(%esp)
    2031:	00 
    2032:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2039:	e8 01 25 00 00       	call   453f <printf>
  unlink("bd");
    203e:	c7 04 24 90 52 00 00 	movl   $0x5290,(%esp)
    2045:	e8 ce 23 00 00       	call   4418 <unlink>

  fd = open("bd", O_CREATE);
    204a:	c7 44 24 04 00 02 00 	movl   $0x200,0x4(%esp)
    2051:	00 
    2052:	c7 04 24 90 52 00 00 	movl   $0x5290,(%esp)
    2059:	e8 aa 23 00 00       	call   4408 <open>
    205e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(fd < 0){
    2061:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    2065:	79 20                	jns    2087 <bigdir+0x63>
    printf(1, "bigdir create failed\n");
    2067:	c7 44 24 04 93 52 00 	movl   $0x5293,0x4(%esp)
    206e:	00 
    206f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2076:	e8 c4 24 00 00       	call   453f <printf>
    exit(EXIT_STATUS_DEFAULT);
    207b:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    2082:	e8 41 23 00 00       	call   43c8 <exit>
  }
  close(fd);
    2087:	8b 45 f0             	mov    -0x10(%ebp),%eax
    208a:	89 04 24             	mov    %eax,(%esp)
    208d:	e8 5e 23 00 00       	call   43f0 <close>

  for(i = 0; i < 500; i++){
    2092:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    2099:	eb 6f                	jmp    210a <bigdir+0xe6>
    name[0] = 'x';
    209b:	c6 45 e6 78          	movb   $0x78,-0x1a(%ebp)
    name[1] = '0' + (i / 64);
    209f:	8b 45 f4             	mov    -0xc(%ebp),%eax
    20a2:	8d 50 3f             	lea    0x3f(%eax),%edx
    20a5:	85 c0                	test   %eax,%eax
    20a7:	0f 48 c2             	cmovs  %edx,%eax
    20aa:	c1 f8 06             	sar    $0x6,%eax
    20ad:	83 c0 30             	add    $0x30,%eax
    20b0:	88 45 e7             	mov    %al,-0x19(%ebp)
    name[2] = '0' + (i % 64);
    20b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
    20b6:	89 c2                	mov    %eax,%edx
    20b8:	c1 fa 1f             	sar    $0x1f,%edx
    20bb:	c1 ea 1a             	shr    $0x1a,%edx
    20be:	01 d0                	add    %edx,%eax
    20c0:	83 e0 3f             	and    $0x3f,%eax
    20c3:	29 d0                	sub    %edx,%eax
    20c5:	83 c0 30             	add    $0x30,%eax
    20c8:	88 45 e8             	mov    %al,-0x18(%ebp)
    name[3] = '\0';
    20cb:	c6 45 e9 00          	movb   $0x0,-0x17(%ebp)
    if(link("bd", name) != 0){
    20cf:	8d 45 e6             	lea    -0x1a(%ebp),%eax
    20d2:	89 44 24 04          	mov    %eax,0x4(%esp)
    20d6:	c7 04 24 90 52 00 00 	movl   $0x5290,(%esp)
    20dd:	e8 46 23 00 00       	call   4428 <link>
    20e2:	85 c0                	test   %eax,%eax
    20e4:	74 20                	je     2106 <bigdir+0xe2>
      printf(1, "bigdir link failed\n");
    20e6:	c7 44 24 04 a9 52 00 	movl   $0x52a9,0x4(%esp)
    20ed:	00 
    20ee:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    20f5:	e8 45 24 00 00       	call   453f <printf>
      exit(EXIT_STATUS_DEFAULT);
    20fa:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    2101:	e8 c2 22 00 00       	call   43c8 <exit>
    printf(1, "bigdir create failed\n");
    exit(EXIT_STATUS_DEFAULT);
  }
  close(fd);

  for(i = 0; i < 500; i++){
    2106:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    210a:	81 7d f4 f3 01 00 00 	cmpl   $0x1f3,-0xc(%ebp)
    2111:	7e 88                	jle    209b <bigdir+0x77>
      printf(1, "bigdir link failed\n");
      exit(EXIT_STATUS_DEFAULT);
    }
  }

  unlink("bd");
    2113:	c7 04 24 90 52 00 00 	movl   $0x5290,(%esp)
    211a:	e8 f9 22 00 00       	call   4418 <unlink>
  for(i = 0; i < 500; i++){
    211f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    2126:	eb 67                	jmp    218f <bigdir+0x16b>
    name[0] = 'x';
    2128:	c6 45 e6 78          	movb   $0x78,-0x1a(%ebp)
    name[1] = '0' + (i / 64);
    212c:	8b 45 f4             	mov    -0xc(%ebp),%eax
    212f:	8d 50 3f             	lea    0x3f(%eax),%edx
    2132:	85 c0                	test   %eax,%eax
    2134:	0f 48 c2             	cmovs  %edx,%eax
    2137:	c1 f8 06             	sar    $0x6,%eax
    213a:	83 c0 30             	add    $0x30,%eax
    213d:	88 45 e7             	mov    %al,-0x19(%ebp)
    name[2] = '0' + (i % 64);
    2140:	8b 45 f4             	mov    -0xc(%ebp),%eax
    2143:	89 c2                	mov    %eax,%edx
    2145:	c1 fa 1f             	sar    $0x1f,%edx
    2148:	c1 ea 1a             	shr    $0x1a,%edx
    214b:	01 d0                	add    %edx,%eax
    214d:	83 e0 3f             	and    $0x3f,%eax
    2150:	29 d0                	sub    %edx,%eax
    2152:	83 c0 30             	add    $0x30,%eax
    2155:	88 45 e8             	mov    %al,-0x18(%ebp)
    name[3] = '\0';
    2158:	c6 45 e9 00          	movb   $0x0,-0x17(%ebp)
    if(unlink(name) != 0){
    215c:	8d 45 e6             	lea    -0x1a(%ebp),%eax
    215f:	89 04 24             	mov    %eax,(%esp)
    2162:	e8 b1 22 00 00       	call   4418 <unlink>
    2167:	85 c0                	test   %eax,%eax
    2169:	74 20                	je     218b <bigdir+0x167>
      printf(1, "bigdir unlink failed");
    216b:	c7 44 24 04 bd 52 00 	movl   $0x52bd,0x4(%esp)
    2172:	00 
    2173:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    217a:	e8 c0 23 00 00       	call   453f <printf>
      exit(EXIT_STATUS_DEFAULT);
    217f:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    2186:	e8 3d 22 00 00       	call   43c8 <exit>
      exit(EXIT_STATUS_DEFAULT);
    }
  }

  unlink("bd");
  for(i = 0; i < 500; i++){
    218b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    218f:	81 7d f4 f3 01 00 00 	cmpl   $0x1f3,-0xc(%ebp)
    2196:	7e 90                	jle    2128 <bigdir+0x104>
      printf(1, "bigdir unlink failed");
      exit(EXIT_STATUS_DEFAULT);
    }
  }

  printf(1, "bigdir ok\n");
    2198:	c7 44 24 04 d2 52 00 	movl   $0x52d2,0x4(%esp)
    219f:	00 
    21a0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    21a7:	e8 93 23 00 00       	call   453f <printf>
}
    21ac:	c9                   	leave  
    21ad:	c3                   	ret    

000021ae <subdir>:

void
subdir(void)
{
    21ae:	55                   	push   %ebp
    21af:	89 e5                	mov    %esp,%ebp
    21b1:	83 ec 28             	sub    $0x28,%esp
  int fd, cc;

  printf(1, "subdir test\n");
    21b4:	c7 44 24 04 dd 52 00 	movl   $0x52dd,0x4(%esp)
    21bb:	00 
    21bc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    21c3:	e8 77 23 00 00       	call   453f <printf>

  unlink("ff");
    21c8:	c7 04 24 ea 52 00 00 	movl   $0x52ea,(%esp)
    21cf:	e8 44 22 00 00       	call   4418 <unlink>
  if(mkdir("dd") != 0){
    21d4:	c7 04 24 ed 52 00 00 	movl   $0x52ed,(%esp)
    21db:	e8 50 22 00 00       	call   4430 <mkdir>
    21e0:	85 c0                	test   %eax,%eax
    21e2:	74 20                	je     2204 <subdir+0x56>
    printf(1, "subdir mkdir dd failed\n");
    21e4:	c7 44 24 04 f0 52 00 	movl   $0x52f0,0x4(%esp)
    21eb:	00 
    21ec:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    21f3:	e8 47 23 00 00       	call   453f <printf>
    exit(EXIT_STATUS_DEFAULT);
    21f8:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    21ff:	e8 c4 21 00 00       	call   43c8 <exit>
  }

  fd = open("dd/ff", O_CREATE | O_RDWR);
    2204:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
    220b:	00 
    220c:	c7 04 24 08 53 00 00 	movl   $0x5308,(%esp)
    2213:	e8 f0 21 00 00       	call   4408 <open>
    2218:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0){
    221b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    221f:	79 20                	jns    2241 <subdir+0x93>
    printf(1, "create dd/ff failed\n");
    2221:	c7 44 24 04 0e 53 00 	movl   $0x530e,0x4(%esp)
    2228:	00 
    2229:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2230:	e8 0a 23 00 00       	call   453f <printf>
    exit(EXIT_STATUS_DEFAULT);
    2235:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    223c:	e8 87 21 00 00       	call   43c8 <exit>
  }
  write(fd, "ff", 2);
    2241:	c7 44 24 08 02 00 00 	movl   $0x2,0x8(%esp)
    2248:	00 
    2249:	c7 44 24 04 ea 52 00 	movl   $0x52ea,0x4(%esp)
    2250:	00 
    2251:	8b 45 f4             	mov    -0xc(%ebp),%eax
    2254:	89 04 24             	mov    %eax,(%esp)
    2257:	e8 8c 21 00 00       	call   43e8 <write>
  close(fd);
    225c:	8b 45 f4             	mov    -0xc(%ebp),%eax
    225f:	89 04 24             	mov    %eax,(%esp)
    2262:	e8 89 21 00 00       	call   43f0 <close>
  
  if(unlink("dd") >= 0){
    2267:	c7 04 24 ed 52 00 00 	movl   $0x52ed,(%esp)
    226e:	e8 a5 21 00 00       	call   4418 <unlink>
    2273:	85 c0                	test   %eax,%eax
    2275:	78 20                	js     2297 <subdir+0xe9>
    printf(1, "unlink dd (non-empty dir) succeeded!\n");
    2277:	c7 44 24 04 24 53 00 	movl   $0x5324,0x4(%esp)
    227e:	00 
    227f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2286:	e8 b4 22 00 00       	call   453f <printf>
    exit(EXIT_STATUS_DEFAULT);
    228b:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    2292:	e8 31 21 00 00       	call   43c8 <exit>
  }

  if(mkdir("/dd/dd") != 0){
    2297:	c7 04 24 4a 53 00 00 	movl   $0x534a,(%esp)
    229e:	e8 8d 21 00 00       	call   4430 <mkdir>
    22a3:	85 c0                	test   %eax,%eax
    22a5:	74 20                	je     22c7 <subdir+0x119>
    printf(1, "subdir mkdir dd/dd failed\n");
    22a7:	c7 44 24 04 51 53 00 	movl   $0x5351,0x4(%esp)
    22ae:	00 
    22af:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    22b6:	e8 84 22 00 00       	call   453f <printf>
    exit(EXIT_STATUS_DEFAULT);
    22bb:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    22c2:	e8 01 21 00 00       	call   43c8 <exit>
  }

  fd = open("dd/dd/ff", O_CREATE | O_RDWR);
    22c7:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
    22ce:	00 
    22cf:	c7 04 24 6c 53 00 00 	movl   $0x536c,(%esp)
    22d6:	e8 2d 21 00 00       	call   4408 <open>
    22db:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0){
    22de:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    22e2:	79 20                	jns    2304 <subdir+0x156>
    printf(1, "create dd/dd/ff failed\n");
    22e4:	c7 44 24 04 75 53 00 	movl   $0x5375,0x4(%esp)
    22eb:	00 
    22ec:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    22f3:	e8 47 22 00 00       	call   453f <printf>
    exit(EXIT_STATUS_DEFAULT);
    22f8:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    22ff:	e8 c4 20 00 00       	call   43c8 <exit>
  }
  write(fd, "FF", 2);
    2304:	c7 44 24 08 02 00 00 	movl   $0x2,0x8(%esp)
    230b:	00 
    230c:	c7 44 24 04 8d 53 00 	movl   $0x538d,0x4(%esp)
    2313:	00 
    2314:	8b 45 f4             	mov    -0xc(%ebp),%eax
    2317:	89 04 24             	mov    %eax,(%esp)
    231a:	e8 c9 20 00 00       	call   43e8 <write>
  close(fd);
    231f:	8b 45 f4             	mov    -0xc(%ebp),%eax
    2322:	89 04 24             	mov    %eax,(%esp)
    2325:	e8 c6 20 00 00       	call   43f0 <close>

  fd = open("dd/dd/../ff", 0);
    232a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    2331:	00 
    2332:	c7 04 24 90 53 00 00 	movl   $0x5390,(%esp)
    2339:	e8 ca 20 00 00       	call   4408 <open>
    233e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0){
    2341:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    2345:	79 20                	jns    2367 <subdir+0x1b9>
    printf(1, "open dd/dd/../ff failed\n");
    2347:	c7 44 24 04 9c 53 00 	movl   $0x539c,0x4(%esp)
    234e:	00 
    234f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2356:	e8 e4 21 00 00       	call   453f <printf>
    exit(EXIT_STATUS_DEFAULT);
    235b:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    2362:	e8 61 20 00 00       	call   43c8 <exit>
  }
  cc = read(fd, buf, sizeof(buf));
    2367:	c7 44 24 08 00 20 00 	movl   $0x2000,0x8(%esp)
    236e:	00 
    236f:	c7 44 24 04 a0 8f 00 	movl   $0x8fa0,0x4(%esp)
    2376:	00 
    2377:	8b 45 f4             	mov    -0xc(%ebp),%eax
    237a:	89 04 24             	mov    %eax,(%esp)
    237d:	e8 5e 20 00 00       	call   43e0 <read>
    2382:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(cc != 2 || buf[0] != 'f'){
    2385:	83 7d f0 02          	cmpl   $0x2,-0x10(%ebp)
    2389:	75 0b                	jne    2396 <subdir+0x1e8>
    238b:	0f b6 05 a0 8f 00 00 	movzbl 0x8fa0,%eax
    2392:	3c 66                	cmp    $0x66,%al
    2394:	74 20                	je     23b6 <subdir+0x208>
    printf(1, "dd/dd/../ff wrong content\n");
    2396:	c7 44 24 04 b5 53 00 	movl   $0x53b5,0x4(%esp)
    239d:	00 
    239e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    23a5:	e8 95 21 00 00       	call   453f <printf>
    exit(EXIT_STATUS_DEFAULT);
    23aa:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    23b1:	e8 12 20 00 00       	call   43c8 <exit>
  }
  close(fd);
    23b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
    23b9:	89 04 24             	mov    %eax,(%esp)
    23bc:	e8 2f 20 00 00       	call   43f0 <close>

  if(link("dd/dd/ff", "dd/dd/ffff") != 0){
    23c1:	c7 44 24 04 d0 53 00 	movl   $0x53d0,0x4(%esp)
    23c8:	00 
    23c9:	c7 04 24 6c 53 00 00 	movl   $0x536c,(%esp)
    23d0:	e8 53 20 00 00       	call   4428 <link>
    23d5:	85 c0                	test   %eax,%eax
    23d7:	74 20                	je     23f9 <subdir+0x24b>
    printf(1, "link dd/dd/ff dd/dd/ffff failed\n");
    23d9:	c7 44 24 04 dc 53 00 	movl   $0x53dc,0x4(%esp)
    23e0:	00 
    23e1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    23e8:	e8 52 21 00 00       	call   453f <printf>
    exit(EXIT_STATUS_DEFAULT);
    23ed:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    23f4:	e8 cf 1f 00 00       	call   43c8 <exit>
  }

  if(unlink("dd/dd/ff") != 0){
    23f9:	c7 04 24 6c 53 00 00 	movl   $0x536c,(%esp)
    2400:	e8 13 20 00 00       	call   4418 <unlink>
    2405:	85 c0                	test   %eax,%eax
    2407:	74 20                	je     2429 <subdir+0x27b>
    printf(1, "unlink dd/dd/ff failed\n");
    2409:	c7 44 24 04 fd 53 00 	movl   $0x53fd,0x4(%esp)
    2410:	00 
    2411:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2418:	e8 22 21 00 00       	call   453f <printf>
    exit(EXIT_STATUS_DEFAULT);
    241d:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    2424:	e8 9f 1f 00 00       	call   43c8 <exit>
  }
  if(open("dd/dd/ff", O_RDONLY) >= 0){
    2429:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    2430:	00 
    2431:	c7 04 24 6c 53 00 00 	movl   $0x536c,(%esp)
    2438:	e8 cb 1f 00 00       	call   4408 <open>
    243d:	85 c0                	test   %eax,%eax
    243f:	78 20                	js     2461 <subdir+0x2b3>
    printf(1, "open (unlinked) dd/dd/ff succeeded\n");
    2441:	c7 44 24 04 18 54 00 	movl   $0x5418,0x4(%esp)
    2448:	00 
    2449:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2450:	e8 ea 20 00 00       	call   453f <printf>
    exit(EXIT_STATUS_DEFAULT);
    2455:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    245c:	e8 67 1f 00 00       	call   43c8 <exit>
  }

  if(chdir("dd") != 0){
    2461:	c7 04 24 ed 52 00 00 	movl   $0x52ed,(%esp)
    2468:	e8 cb 1f 00 00       	call   4438 <chdir>
    246d:	85 c0                	test   %eax,%eax
    246f:	74 20                	je     2491 <subdir+0x2e3>
    printf(1, "chdir dd failed\n");
    2471:	c7 44 24 04 3c 54 00 	movl   $0x543c,0x4(%esp)
    2478:	00 
    2479:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2480:	e8 ba 20 00 00       	call   453f <printf>
    exit(EXIT_STATUS_DEFAULT);
    2485:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    248c:	e8 37 1f 00 00       	call   43c8 <exit>
  }
  if(chdir("dd/../../dd") != 0){
    2491:	c7 04 24 4d 54 00 00 	movl   $0x544d,(%esp)
    2498:	e8 9b 1f 00 00       	call   4438 <chdir>
    249d:	85 c0                	test   %eax,%eax
    249f:	74 20                	je     24c1 <subdir+0x313>
    printf(1, "chdir dd/../../dd failed\n");
    24a1:	c7 44 24 04 59 54 00 	movl   $0x5459,0x4(%esp)
    24a8:	00 
    24a9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    24b0:	e8 8a 20 00 00       	call   453f <printf>
    exit(EXIT_STATUS_DEFAULT);
    24b5:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    24bc:	e8 07 1f 00 00       	call   43c8 <exit>
  }
  if(chdir("dd/../../../dd") != 0){
    24c1:	c7 04 24 73 54 00 00 	movl   $0x5473,(%esp)
    24c8:	e8 6b 1f 00 00       	call   4438 <chdir>
    24cd:	85 c0                	test   %eax,%eax
    24cf:	74 20                	je     24f1 <subdir+0x343>
    printf(1, "chdir dd/../../dd failed\n");
    24d1:	c7 44 24 04 59 54 00 	movl   $0x5459,0x4(%esp)
    24d8:	00 
    24d9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    24e0:	e8 5a 20 00 00       	call   453f <printf>
    exit(EXIT_STATUS_DEFAULT);
    24e5:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    24ec:	e8 d7 1e 00 00       	call   43c8 <exit>
  }
  if(chdir("./..") != 0){
    24f1:	c7 04 24 82 54 00 00 	movl   $0x5482,(%esp)
    24f8:	e8 3b 1f 00 00       	call   4438 <chdir>
    24fd:	85 c0                	test   %eax,%eax
    24ff:	74 20                	je     2521 <subdir+0x373>
    printf(1, "chdir ./.. failed\n");
    2501:	c7 44 24 04 87 54 00 	movl   $0x5487,0x4(%esp)
    2508:	00 
    2509:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2510:	e8 2a 20 00 00       	call   453f <printf>
    exit(EXIT_STATUS_DEFAULT);
    2515:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    251c:	e8 a7 1e 00 00       	call   43c8 <exit>
  }

  fd = open("dd/dd/ffff", 0);
    2521:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    2528:	00 
    2529:	c7 04 24 d0 53 00 00 	movl   $0x53d0,(%esp)
    2530:	e8 d3 1e 00 00       	call   4408 <open>
    2535:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0){
    2538:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    253c:	79 20                	jns    255e <subdir+0x3b0>
    printf(1, "open dd/dd/ffff failed\n");
    253e:	c7 44 24 04 9a 54 00 	movl   $0x549a,0x4(%esp)
    2545:	00 
    2546:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    254d:	e8 ed 1f 00 00       	call   453f <printf>
    exit(EXIT_STATUS_DEFAULT);
    2552:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    2559:	e8 6a 1e 00 00       	call   43c8 <exit>
  }
  if(read(fd, buf, sizeof(buf)) != 2){
    255e:	c7 44 24 08 00 20 00 	movl   $0x2000,0x8(%esp)
    2565:	00 
    2566:	c7 44 24 04 a0 8f 00 	movl   $0x8fa0,0x4(%esp)
    256d:	00 
    256e:	8b 45 f4             	mov    -0xc(%ebp),%eax
    2571:	89 04 24             	mov    %eax,(%esp)
    2574:	e8 67 1e 00 00       	call   43e0 <read>
    2579:	83 f8 02             	cmp    $0x2,%eax
    257c:	74 20                	je     259e <subdir+0x3f0>
    printf(1, "read dd/dd/ffff wrong len\n");
    257e:	c7 44 24 04 b2 54 00 	movl   $0x54b2,0x4(%esp)
    2585:	00 
    2586:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    258d:	e8 ad 1f 00 00       	call   453f <printf>
    exit(EXIT_STATUS_DEFAULT);
    2592:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    2599:	e8 2a 1e 00 00       	call   43c8 <exit>
  }
  close(fd);
    259e:	8b 45 f4             	mov    -0xc(%ebp),%eax
    25a1:	89 04 24             	mov    %eax,(%esp)
    25a4:	e8 47 1e 00 00       	call   43f0 <close>

  if(open("dd/dd/ff", O_RDONLY) >= 0){
    25a9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    25b0:	00 
    25b1:	c7 04 24 6c 53 00 00 	movl   $0x536c,(%esp)
    25b8:	e8 4b 1e 00 00       	call   4408 <open>
    25bd:	85 c0                	test   %eax,%eax
    25bf:	78 20                	js     25e1 <subdir+0x433>
    printf(1, "open (unlinked) dd/dd/ff succeeded!\n");
    25c1:	c7 44 24 04 d0 54 00 	movl   $0x54d0,0x4(%esp)
    25c8:	00 
    25c9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    25d0:	e8 6a 1f 00 00       	call   453f <printf>
    exit(EXIT_STATUS_DEFAULT);
    25d5:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    25dc:	e8 e7 1d 00 00       	call   43c8 <exit>
  }

  if(open("dd/ff/ff", O_CREATE|O_RDWR) >= 0){
    25e1:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
    25e8:	00 
    25e9:	c7 04 24 f5 54 00 00 	movl   $0x54f5,(%esp)
    25f0:	e8 13 1e 00 00       	call   4408 <open>
    25f5:	85 c0                	test   %eax,%eax
    25f7:	78 20                	js     2619 <subdir+0x46b>
    printf(1, "create dd/ff/ff succeeded!\n");
    25f9:	c7 44 24 04 fe 54 00 	movl   $0x54fe,0x4(%esp)
    2600:	00 
    2601:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2608:	e8 32 1f 00 00       	call   453f <printf>
    exit(EXIT_STATUS_DEFAULT);
    260d:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    2614:	e8 af 1d 00 00       	call   43c8 <exit>
  }
  if(open("dd/xx/ff", O_CREATE|O_RDWR) >= 0){
    2619:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
    2620:	00 
    2621:	c7 04 24 1a 55 00 00 	movl   $0x551a,(%esp)
    2628:	e8 db 1d 00 00       	call   4408 <open>
    262d:	85 c0                	test   %eax,%eax
    262f:	78 20                	js     2651 <subdir+0x4a3>
    printf(1, "create dd/xx/ff succeeded!\n");
    2631:	c7 44 24 04 23 55 00 	movl   $0x5523,0x4(%esp)
    2638:	00 
    2639:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2640:	e8 fa 1e 00 00       	call   453f <printf>
    exit(EXIT_STATUS_DEFAULT);
    2645:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    264c:	e8 77 1d 00 00       	call   43c8 <exit>
  }
  if(open("dd", O_CREATE) >= 0){
    2651:	c7 44 24 04 00 02 00 	movl   $0x200,0x4(%esp)
    2658:	00 
    2659:	c7 04 24 ed 52 00 00 	movl   $0x52ed,(%esp)
    2660:	e8 a3 1d 00 00       	call   4408 <open>
    2665:	85 c0                	test   %eax,%eax
    2667:	78 20                	js     2689 <subdir+0x4db>
    printf(1, "create dd succeeded!\n");
    2669:	c7 44 24 04 3f 55 00 	movl   $0x553f,0x4(%esp)
    2670:	00 
    2671:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2678:	e8 c2 1e 00 00       	call   453f <printf>
    exit(EXIT_STATUS_DEFAULT);
    267d:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    2684:	e8 3f 1d 00 00       	call   43c8 <exit>
  }
  if(open("dd", O_RDWR) >= 0){
    2689:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
    2690:	00 
    2691:	c7 04 24 ed 52 00 00 	movl   $0x52ed,(%esp)
    2698:	e8 6b 1d 00 00       	call   4408 <open>
    269d:	85 c0                	test   %eax,%eax
    269f:	78 20                	js     26c1 <subdir+0x513>
    printf(1, "open dd rdwr succeeded!\n");
    26a1:	c7 44 24 04 55 55 00 	movl   $0x5555,0x4(%esp)
    26a8:	00 
    26a9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    26b0:	e8 8a 1e 00 00       	call   453f <printf>
    exit(EXIT_STATUS_DEFAULT);
    26b5:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    26bc:	e8 07 1d 00 00       	call   43c8 <exit>
  }
  if(open("dd", O_WRONLY) >= 0){
    26c1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
    26c8:	00 
    26c9:	c7 04 24 ed 52 00 00 	movl   $0x52ed,(%esp)
    26d0:	e8 33 1d 00 00       	call   4408 <open>
    26d5:	85 c0                	test   %eax,%eax
    26d7:	78 20                	js     26f9 <subdir+0x54b>
    printf(1, "open dd wronly succeeded!\n");
    26d9:	c7 44 24 04 6e 55 00 	movl   $0x556e,0x4(%esp)
    26e0:	00 
    26e1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    26e8:	e8 52 1e 00 00       	call   453f <printf>
    exit(EXIT_STATUS_DEFAULT);
    26ed:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    26f4:	e8 cf 1c 00 00       	call   43c8 <exit>
  }
  if(link("dd/ff/ff", "dd/dd/xx") == 0){
    26f9:	c7 44 24 04 89 55 00 	movl   $0x5589,0x4(%esp)
    2700:	00 
    2701:	c7 04 24 f5 54 00 00 	movl   $0x54f5,(%esp)
    2708:	e8 1b 1d 00 00       	call   4428 <link>
    270d:	85 c0                	test   %eax,%eax
    270f:	75 20                	jne    2731 <subdir+0x583>
    printf(1, "link dd/ff/ff dd/dd/xx succeeded!\n");
    2711:	c7 44 24 04 94 55 00 	movl   $0x5594,0x4(%esp)
    2718:	00 
    2719:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2720:	e8 1a 1e 00 00       	call   453f <printf>
    exit(EXIT_STATUS_DEFAULT);
    2725:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    272c:	e8 97 1c 00 00       	call   43c8 <exit>
  }
  if(link("dd/xx/ff", "dd/dd/xx") == 0){
    2731:	c7 44 24 04 89 55 00 	movl   $0x5589,0x4(%esp)
    2738:	00 
    2739:	c7 04 24 1a 55 00 00 	movl   $0x551a,(%esp)
    2740:	e8 e3 1c 00 00       	call   4428 <link>
    2745:	85 c0                	test   %eax,%eax
    2747:	75 20                	jne    2769 <subdir+0x5bb>
    printf(1, "link dd/xx/ff dd/dd/xx succeeded!\n");
    2749:	c7 44 24 04 b8 55 00 	movl   $0x55b8,0x4(%esp)
    2750:	00 
    2751:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2758:	e8 e2 1d 00 00       	call   453f <printf>
    exit(EXIT_STATUS_DEFAULT);
    275d:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    2764:	e8 5f 1c 00 00       	call   43c8 <exit>
  }
  if(link("dd/ff", "dd/dd/ffff") == 0){
    2769:	c7 44 24 04 d0 53 00 	movl   $0x53d0,0x4(%esp)
    2770:	00 
    2771:	c7 04 24 08 53 00 00 	movl   $0x5308,(%esp)
    2778:	e8 ab 1c 00 00       	call   4428 <link>
    277d:	85 c0                	test   %eax,%eax
    277f:	75 20                	jne    27a1 <subdir+0x5f3>
    printf(1, "link dd/ff dd/dd/ffff succeeded!\n");
    2781:	c7 44 24 04 dc 55 00 	movl   $0x55dc,0x4(%esp)
    2788:	00 
    2789:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2790:	e8 aa 1d 00 00       	call   453f <printf>
    exit(EXIT_STATUS_DEFAULT);
    2795:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    279c:	e8 27 1c 00 00       	call   43c8 <exit>
  }
  if(mkdir("dd/ff/ff") == 0){
    27a1:	c7 04 24 f5 54 00 00 	movl   $0x54f5,(%esp)
    27a8:	e8 83 1c 00 00       	call   4430 <mkdir>
    27ad:	85 c0                	test   %eax,%eax
    27af:	75 20                	jne    27d1 <subdir+0x623>
    printf(1, "mkdir dd/ff/ff succeeded!\n");
    27b1:	c7 44 24 04 fe 55 00 	movl   $0x55fe,0x4(%esp)
    27b8:	00 
    27b9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    27c0:	e8 7a 1d 00 00       	call   453f <printf>
    exit(EXIT_STATUS_DEFAULT);
    27c5:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    27cc:	e8 f7 1b 00 00       	call   43c8 <exit>
  }
  if(mkdir("dd/xx/ff") == 0){
    27d1:	c7 04 24 1a 55 00 00 	movl   $0x551a,(%esp)
    27d8:	e8 53 1c 00 00       	call   4430 <mkdir>
    27dd:	85 c0                	test   %eax,%eax
    27df:	75 20                	jne    2801 <subdir+0x653>
    printf(1, "mkdir dd/xx/ff succeeded!\n");
    27e1:	c7 44 24 04 19 56 00 	movl   $0x5619,0x4(%esp)
    27e8:	00 
    27e9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    27f0:	e8 4a 1d 00 00       	call   453f <printf>
    exit(EXIT_STATUS_DEFAULT);
    27f5:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    27fc:	e8 c7 1b 00 00       	call   43c8 <exit>
  }
  if(mkdir("dd/dd/ffff") == 0){
    2801:	c7 04 24 d0 53 00 00 	movl   $0x53d0,(%esp)
    2808:	e8 23 1c 00 00       	call   4430 <mkdir>
    280d:	85 c0                	test   %eax,%eax
    280f:	75 20                	jne    2831 <subdir+0x683>
    printf(1, "mkdir dd/dd/ffff succeeded!\n");
    2811:	c7 44 24 04 34 56 00 	movl   $0x5634,0x4(%esp)
    2818:	00 
    2819:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2820:	e8 1a 1d 00 00       	call   453f <printf>
    exit(EXIT_STATUS_DEFAULT);
    2825:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    282c:	e8 97 1b 00 00       	call   43c8 <exit>
  }
  if(unlink("dd/xx/ff") == 0){
    2831:	c7 04 24 1a 55 00 00 	movl   $0x551a,(%esp)
    2838:	e8 db 1b 00 00       	call   4418 <unlink>
    283d:	85 c0                	test   %eax,%eax
    283f:	75 20                	jne    2861 <subdir+0x6b3>
    printf(1, "unlink dd/xx/ff succeeded!\n");
    2841:	c7 44 24 04 51 56 00 	movl   $0x5651,0x4(%esp)
    2848:	00 
    2849:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2850:	e8 ea 1c 00 00       	call   453f <printf>
    exit(EXIT_STATUS_DEFAULT);
    2855:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    285c:	e8 67 1b 00 00       	call   43c8 <exit>
  }
  if(unlink("dd/ff/ff") == 0){
    2861:	c7 04 24 f5 54 00 00 	movl   $0x54f5,(%esp)
    2868:	e8 ab 1b 00 00       	call   4418 <unlink>
    286d:	85 c0                	test   %eax,%eax
    286f:	75 20                	jne    2891 <subdir+0x6e3>
    printf(1, "unlink dd/ff/ff succeeded!\n");
    2871:	c7 44 24 04 6d 56 00 	movl   $0x566d,0x4(%esp)
    2878:	00 
    2879:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2880:	e8 ba 1c 00 00       	call   453f <printf>
    exit(EXIT_STATUS_DEFAULT);
    2885:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    288c:	e8 37 1b 00 00       	call   43c8 <exit>
  }
  if(chdir("dd/ff") == 0){
    2891:	c7 04 24 08 53 00 00 	movl   $0x5308,(%esp)
    2898:	e8 9b 1b 00 00       	call   4438 <chdir>
    289d:	85 c0                	test   %eax,%eax
    289f:	75 20                	jne    28c1 <subdir+0x713>
    printf(1, "chdir dd/ff succeeded!\n");
    28a1:	c7 44 24 04 89 56 00 	movl   $0x5689,0x4(%esp)
    28a8:	00 
    28a9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    28b0:	e8 8a 1c 00 00       	call   453f <printf>
    exit(EXIT_STATUS_DEFAULT);
    28b5:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    28bc:	e8 07 1b 00 00       	call   43c8 <exit>
  }
  if(chdir("dd/xx") == 0){
    28c1:	c7 04 24 a1 56 00 00 	movl   $0x56a1,(%esp)
    28c8:	e8 6b 1b 00 00       	call   4438 <chdir>
    28cd:	85 c0                	test   %eax,%eax
    28cf:	75 20                	jne    28f1 <subdir+0x743>
    printf(1, "chdir dd/xx succeeded!\n");
    28d1:	c7 44 24 04 a7 56 00 	movl   $0x56a7,0x4(%esp)
    28d8:	00 
    28d9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    28e0:	e8 5a 1c 00 00       	call   453f <printf>
    exit(EXIT_STATUS_DEFAULT);
    28e5:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    28ec:	e8 d7 1a 00 00       	call   43c8 <exit>
  }

  if(unlink("dd/dd/ffff") != 0){
    28f1:	c7 04 24 d0 53 00 00 	movl   $0x53d0,(%esp)
    28f8:	e8 1b 1b 00 00       	call   4418 <unlink>
    28fd:	85 c0                	test   %eax,%eax
    28ff:	74 20                	je     2921 <subdir+0x773>
    printf(1, "unlink dd/dd/ff failed\n");
    2901:	c7 44 24 04 fd 53 00 	movl   $0x53fd,0x4(%esp)
    2908:	00 
    2909:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2910:	e8 2a 1c 00 00       	call   453f <printf>
    exit(EXIT_STATUS_DEFAULT);
    2915:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    291c:	e8 a7 1a 00 00       	call   43c8 <exit>
  }
  if(unlink("dd/ff") != 0){
    2921:	c7 04 24 08 53 00 00 	movl   $0x5308,(%esp)
    2928:	e8 eb 1a 00 00       	call   4418 <unlink>
    292d:	85 c0                	test   %eax,%eax
    292f:	74 20                	je     2951 <subdir+0x7a3>
    printf(1, "unlink dd/ff failed\n");
    2931:	c7 44 24 04 bf 56 00 	movl   $0x56bf,0x4(%esp)
    2938:	00 
    2939:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2940:	e8 fa 1b 00 00       	call   453f <printf>
    exit(EXIT_STATUS_DEFAULT);
    2945:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    294c:	e8 77 1a 00 00       	call   43c8 <exit>
  }
  if(unlink("dd") == 0){
    2951:	c7 04 24 ed 52 00 00 	movl   $0x52ed,(%esp)
    2958:	e8 bb 1a 00 00       	call   4418 <unlink>
    295d:	85 c0                	test   %eax,%eax
    295f:	75 20                	jne    2981 <subdir+0x7d3>
    printf(1, "unlink non-empty dd succeeded!\n");
    2961:	c7 44 24 04 d4 56 00 	movl   $0x56d4,0x4(%esp)
    2968:	00 
    2969:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2970:	e8 ca 1b 00 00       	call   453f <printf>
    exit(EXIT_STATUS_DEFAULT);
    2975:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    297c:	e8 47 1a 00 00       	call   43c8 <exit>
  }
  if(unlink("dd/dd") < 0){
    2981:	c7 04 24 f4 56 00 00 	movl   $0x56f4,(%esp)
    2988:	e8 8b 1a 00 00       	call   4418 <unlink>
    298d:	85 c0                	test   %eax,%eax
    298f:	79 20                	jns    29b1 <subdir+0x803>
    printf(1, "unlink dd/dd failed\n");
    2991:	c7 44 24 04 fa 56 00 	movl   $0x56fa,0x4(%esp)
    2998:	00 
    2999:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    29a0:	e8 9a 1b 00 00       	call   453f <printf>
    exit(EXIT_STATUS_DEFAULT);
    29a5:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    29ac:	e8 17 1a 00 00       	call   43c8 <exit>
  }
  if(unlink("dd") < 0){
    29b1:	c7 04 24 ed 52 00 00 	movl   $0x52ed,(%esp)
    29b8:	e8 5b 1a 00 00       	call   4418 <unlink>
    29bd:	85 c0                	test   %eax,%eax
    29bf:	79 20                	jns    29e1 <subdir+0x833>
    printf(1, "unlink dd failed\n");
    29c1:	c7 44 24 04 0f 57 00 	movl   $0x570f,0x4(%esp)
    29c8:	00 
    29c9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    29d0:	e8 6a 1b 00 00       	call   453f <printf>
    exit(EXIT_STATUS_DEFAULT);
    29d5:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    29dc:	e8 e7 19 00 00       	call   43c8 <exit>
  }

  printf(1, "subdir ok\n");
    29e1:	c7 44 24 04 21 57 00 	movl   $0x5721,0x4(%esp)
    29e8:	00 
    29e9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    29f0:	e8 4a 1b 00 00       	call   453f <printf>
}
    29f5:	c9                   	leave  
    29f6:	c3                   	ret    

000029f7 <bigwrite>:

// test writes that are larger than the log.
void
bigwrite(void)
{
    29f7:	55                   	push   %ebp
    29f8:	89 e5                	mov    %esp,%ebp
    29fa:	83 ec 28             	sub    $0x28,%esp
  int fd, sz;

  printf(1, "bigwrite test\n");
    29fd:	c7 44 24 04 2c 57 00 	movl   $0x572c,0x4(%esp)
    2a04:	00 
    2a05:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2a0c:	e8 2e 1b 00 00       	call   453f <printf>

  unlink("bigwrite");
    2a11:	c7 04 24 3b 57 00 00 	movl   $0x573b,(%esp)
    2a18:	e8 fb 19 00 00       	call   4418 <unlink>
  for(sz = 499; sz < 12*512; sz += 471){
    2a1d:	c7 45 f4 f3 01 00 00 	movl   $0x1f3,-0xc(%ebp)
    2a24:	e9 c1 00 00 00       	jmp    2aea <bigwrite+0xf3>
    fd = open("bigwrite", O_CREATE | O_RDWR);
    2a29:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
    2a30:	00 
    2a31:	c7 04 24 3b 57 00 00 	movl   $0x573b,(%esp)
    2a38:	e8 cb 19 00 00       	call   4408 <open>
    2a3d:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(fd < 0){
    2a40:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    2a44:	79 20                	jns    2a66 <bigwrite+0x6f>
      printf(1, "cannot create bigwrite\n");
    2a46:	c7 44 24 04 44 57 00 	movl   $0x5744,0x4(%esp)
    2a4d:	00 
    2a4e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2a55:	e8 e5 1a 00 00       	call   453f <printf>
      exit(EXIT_STATUS_DEFAULT);
    2a5a:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    2a61:	e8 62 19 00 00       	call   43c8 <exit>
    }
    int i;
    for(i = 0; i < 2; i++){
    2a66:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    2a6d:	eb 57                	jmp    2ac6 <bigwrite+0xcf>
      int cc = write(fd, buf, sz);
    2a6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
    2a72:	89 44 24 08          	mov    %eax,0x8(%esp)
    2a76:	c7 44 24 04 a0 8f 00 	movl   $0x8fa0,0x4(%esp)
    2a7d:	00 
    2a7e:	8b 45 ec             	mov    -0x14(%ebp),%eax
    2a81:	89 04 24             	mov    %eax,(%esp)
    2a84:	e8 5f 19 00 00       	call   43e8 <write>
    2a89:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if(cc != sz){
    2a8c:	8b 45 e8             	mov    -0x18(%ebp),%eax
    2a8f:	3b 45 f4             	cmp    -0xc(%ebp),%eax
    2a92:	74 2e                	je     2ac2 <bigwrite+0xcb>
        printf(1, "write(%d) ret %d\n", sz, cc);
    2a94:	8b 45 e8             	mov    -0x18(%ebp),%eax
    2a97:	89 44 24 0c          	mov    %eax,0xc(%esp)
    2a9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
    2a9e:	89 44 24 08          	mov    %eax,0x8(%esp)
    2aa2:	c7 44 24 04 5c 57 00 	movl   $0x575c,0x4(%esp)
    2aa9:	00 
    2aaa:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2ab1:	e8 89 1a 00 00       	call   453f <printf>
        exit(EXIT_STATUS_DEFAULT);
    2ab6:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    2abd:	e8 06 19 00 00       	call   43c8 <exit>
    if(fd < 0){
      printf(1, "cannot create bigwrite\n");
      exit(EXIT_STATUS_DEFAULT);
    }
    int i;
    for(i = 0; i < 2; i++){
    2ac2:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
    2ac6:	83 7d f0 01          	cmpl   $0x1,-0x10(%ebp)
    2aca:	7e a3                	jle    2a6f <bigwrite+0x78>
      if(cc != sz){
        printf(1, "write(%d) ret %d\n", sz, cc);
        exit(EXIT_STATUS_DEFAULT);
      }
    }
    close(fd);
    2acc:	8b 45 ec             	mov    -0x14(%ebp),%eax
    2acf:	89 04 24             	mov    %eax,(%esp)
    2ad2:	e8 19 19 00 00       	call   43f0 <close>
    unlink("bigwrite");
    2ad7:	c7 04 24 3b 57 00 00 	movl   $0x573b,(%esp)
    2ade:	e8 35 19 00 00       	call   4418 <unlink>
  int fd, sz;

  printf(1, "bigwrite test\n");

  unlink("bigwrite");
  for(sz = 499; sz < 12*512; sz += 471){
    2ae3:	81 45 f4 d7 01 00 00 	addl   $0x1d7,-0xc(%ebp)
    2aea:	81 7d f4 ff 17 00 00 	cmpl   $0x17ff,-0xc(%ebp)
    2af1:	0f 8e 32 ff ff ff    	jle    2a29 <bigwrite+0x32>
    }
    close(fd);
    unlink("bigwrite");
  }

  printf(1, "bigwrite ok\n");
    2af7:	c7 44 24 04 6e 57 00 	movl   $0x576e,0x4(%esp)
    2afe:	00 
    2aff:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2b06:	e8 34 1a 00 00       	call   453f <printf>
}
    2b0b:	c9                   	leave  
    2b0c:	c3                   	ret    

00002b0d <bigfile>:

void
bigfile(void)
{
    2b0d:	55                   	push   %ebp
    2b0e:	89 e5                	mov    %esp,%ebp
    2b10:	83 ec 28             	sub    $0x28,%esp
  int fd, i, total, cc;

  printf(1, "bigfile test\n");
    2b13:	c7 44 24 04 7b 57 00 	movl   $0x577b,0x4(%esp)
    2b1a:	00 
    2b1b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2b22:	e8 18 1a 00 00       	call   453f <printf>

  unlink("bigfile");
    2b27:	c7 04 24 89 57 00 00 	movl   $0x5789,(%esp)
    2b2e:	e8 e5 18 00 00       	call   4418 <unlink>
  fd = open("bigfile", O_CREATE | O_RDWR);
    2b33:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
    2b3a:	00 
    2b3b:	c7 04 24 89 57 00 00 	movl   $0x5789,(%esp)
    2b42:	e8 c1 18 00 00       	call   4408 <open>
    2b47:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(fd < 0){
    2b4a:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    2b4e:	79 20                	jns    2b70 <bigfile+0x63>
    printf(1, "cannot create bigfile");
    2b50:	c7 44 24 04 91 57 00 	movl   $0x5791,0x4(%esp)
    2b57:	00 
    2b58:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2b5f:	e8 db 19 00 00       	call   453f <printf>
    exit(EXIT_STATUS_DEFAULT);
    2b64:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    2b6b:	e8 58 18 00 00       	call   43c8 <exit>
  }
  for(i = 0; i < 20; i++){
    2b70:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    2b77:	eb 61                	jmp    2bda <bigfile+0xcd>
    memset(buf, i, 600);
    2b79:	c7 44 24 08 58 02 00 	movl   $0x258,0x8(%esp)
    2b80:	00 
    2b81:	8b 45 f4             	mov    -0xc(%ebp),%eax
    2b84:	89 44 24 04          	mov    %eax,0x4(%esp)
    2b88:	c7 04 24 a0 8f 00 00 	movl   $0x8fa0,(%esp)
    2b8f:	e8 8f 16 00 00       	call   4223 <memset>
    if(write(fd, buf, 600) != 600){
    2b94:	c7 44 24 08 58 02 00 	movl   $0x258,0x8(%esp)
    2b9b:	00 
    2b9c:	c7 44 24 04 a0 8f 00 	movl   $0x8fa0,0x4(%esp)
    2ba3:	00 
    2ba4:	8b 45 ec             	mov    -0x14(%ebp),%eax
    2ba7:	89 04 24             	mov    %eax,(%esp)
    2baa:	e8 39 18 00 00       	call   43e8 <write>
    2baf:	3d 58 02 00 00       	cmp    $0x258,%eax
    2bb4:	74 20                	je     2bd6 <bigfile+0xc9>
      printf(1, "write bigfile failed\n");
    2bb6:	c7 44 24 04 a7 57 00 	movl   $0x57a7,0x4(%esp)
    2bbd:	00 
    2bbe:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2bc5:	e8 75 19 00 00       	call   453f <printf>
      exit(EXIT_STATUS_DEFAULT);
    2bca:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    2bd1:	e8 f2 17 00 00       	call   43c8 <exit>
  fd = open("bigfile", O_CREATE | O_RDWR);
  if(fd < 0){
    printf(1, "cannot create bigfile");
    exit(EXIT_STATUS_DEFAULT);
  }
  for(i = 0; i < 20; i++){
    2bd6:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    2bda:	83 7d f4 13          	cmpl   $0x13,-0xc(%ebp)
    2bde:	7e 99                	jle    2b79 <bigfile+0x6c>
    if(write(fd, buf, 600) != 600){
      printf(1, "write bigfile failed\n");
      exit(EXIT_STATUS_DEFAULT);
    }
  }
  close(fd);
    2be0:	8b 45 ec             	mov    -0x14(%ebp),%eax
    2be3:	89 04 24             	mov    %eax,(%esp)
    2be6:	e8 05 18 00 00       	call   43f0 <close>

  fd = open("bigfile", 0);
    2beb:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    2bf2:	00 
    2bf3:	c7 04 24 89 57 00 00 	movl   $0x5789,(%esp)
    2bfa:	e8 09 18 00 00       	call   4408 <open>
    2bff:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(fd < 0){
    2c02:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    2c06:	79 20                	jns    2c28 <bigfile+0x11b>
    printf(1, "cannot open bigfile\n");
    2c08:	c7 44 24 04 bd 57 00 	movl   $0x57bd,0x4(%esp)
    2c0f:	00 
    2c10:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2c17:	e8 23 19 00 00       	call   453f <printf>
    exit(EXIT_STATUS_DEFAULT);
    2c1c:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    2c23:	e8 a0 17 00 00       	call   43c8 <exit>
  }
  total = 0;
    2c28:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(i = 0; ; i++){
    2c2f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    cc = read(fd, buf, 300);
    2c36:	c7 44 24 08 2c 01 00 	movl   $0x12c,0x8(%esp)
    2c3d:	00 
    2c3e:	c7 44 24 04 a0 8f 00 	movl   $0x8fa0,0x4(%esp)
    2c45:	00 
    2c46:	8b 45 ec             	mov    -0x14(%ebp),%eax
    2c49:	89 04 24             	mov    %eax,(%esp)
    2c4c:	e8 8f 17 00 00       	call   43e0 <read>
    2c51:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(cc < 0){
    2c54:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
    2c58:	79 20                	jns    2c7a <bigfile+0x16d>
      printf(1, "read bigfile failed\n");
    2c5a:	c7 44 24 04 d2 57 00 	movl   $0x57d2,0x4(%esp)
    2c61:	00 
    2c62:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2c69:	e8 d1 18 00 00       	call   453f <printf>
      exit(EXIT_STATUS_DEFAULT);
    2c6e:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    2c75:	e8 4e 17 00 00       	call   43c8 <exit>
    }
    if(cc == 0)
    2c7a:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
    2c7e:	0f 84 8c 00 00 00    	je     2d10 <bigfile+0x203>
      break;
    if(cc != 300){
    2c84:	81 7d e8 2c 01 00 00 	cmpl   $0x12c,-0x18(%ebp)
    2c8b:	74 20                	je     2cad <bigfile+0x1a0>
      printf(1, "short read bigfile\n");
    2c8d:	c7 44 24 04 e7 57 00 	movl   $0x57e7,0x4(%esp)
    2c94:	00 
    2c95:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2c9c:	e8 9e 18 00 00       	call   453f <printf>
      exit(EXIT_STATUS_DEFAULT);
    2ca1:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    2ca8:	e8 1b 17 00 00       	call   43c8 <exit>
    }
    if(buf[0] != i/2 || buf[299] != i/2){
    2cad:	0f b6 05 a0 8f 00 00 	movzbl 0x8fa0,%eax
    2cb4:	0f be d0             	movsbl %al,%edx
    2cb7:	8b 45 f4             	mov    -0xc(%ebp),%eax
    2cba:	89 c1                	mov    %eax,%ecx
    2cbc:	c1 e9 1f             	shr    $0x1f,%ecx
    2cbf:	01 c8                	add    %ecx,%eax
    2cc1:	d1 f8                	sar    %eax
    2cc3:	39 c2                	cmp    %eax,%edx
    2cc5:	75 1a                	jne    2ce1 <bigfile+0x1d4>
    2cc7:	0f b6 05 cb 90 00 00 	movzbl 0x90cb,%eax
    2cce:	0f be d0             	movsbl %al,%edx
    2cd1:	8b 45 f4             	mov    -0xc(%ebp),%eax
    2cd4:	89 c1                	mov    %eax,%ecx
    2cd6:	c1 e9 1f             	shr    $0x1f,%ecx
    2cd9:	01 c8                	add    %ecx,%eax
    2cdb:	d1 f8                	sar    %eax
    2cdd:	39 c2                	cmp    %eax,%edx
    2cdf:	74 20                	je     2d01 <bigfile+0x1f4>
      printf(1, "read bigfile wrong data\n");
    2ce1:	c7 44 24 04 fb 57 00 	movl   $0x57fb,0x4(%esp)
    2ce8:	00 
    2ce9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2cf0:	e8 4a 18 00 00       	call   453f <printf>
      exit(EXIT_STATUS_DEFAULT);
    2cf5:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    2cfc:	e8 c7 16 00 00       	call   43c8 <exit>
    }
    total += cc;
    2d01:	8b 45 e8             	mov    -0x18(%ebp),%eax
    2d04:	01 45 f0             	add    %eax,-0x10(%ebp)
  if(fd < 0){
    printf(1, "cannot open bigfile\n");
    exit(EXIT_STATUS_DEFAULT);
  }
  total = 0;
  for(i = 0; ; i++){
    2d07:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(buf[0] != i/2 || buf[299] != i/2){
      printf(1, "read bigfile wrong data\n");
      exit(EXIT_STATUS_DEFAULT);
    }
    total += cc;
  }
    2d0b:	e9 26 ff ff ff       	jmp    2c36 <bigfile+0x129>
    if(cc < 0){
      printf(1, "read bigfile failed\n");
      exit(EXIT_STATUS_DEFAULT);
    }
    if(cc == 0)
      break;
    2d10:	90                   	nop
      printf(1, "read bigfile wrong data\n");
      exit(EXIT_STATUS_DEFAULT);
    }
    total += cc;
  }
  close(fd);
    2d11:	8b 45 ec             	mov    -0x14(%ebp),%eax
    2d14:	89 04 24             	mov    %eax,(%esp)
    2d17:	e8 d4 16 00 00       	call   43f0 <close>
  if(total != 20*600){
    2d1c:	81 7d f0 e0 2e 00 00 	cmpl   $0x2ee0,-0x10(%ebp)
    2d23:	74 20                	je     2d45 <bigfile+0x238>
    printf(1, "read bigfile wrong total\n");
    2d25:	c7 44 24 04 14 58 00 	movl   $0x5814,0x4(%esp)
    2d2c:	00 
    2d2d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2d34:	e8 06 18 00 00       	call   453f <printf>
    exit(EXIT_STATUS_DEFAULT);
    2d39:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    2d40:	e8 83 16 00 00       	call   43c8 <exit>
  }
  unlink("bigfile");
    2d45:	c7 04 24 89 57 00 00 	movl   $0x5789,(%esp)
    2d4c:	e8 c7 16 00 00       	call   4418 <unlink>

  printf(1, "bigfile test ok\n");
    2d51:	c7 44 24 04 2e 58 00 	movl   $0x582e,0x4(%esp)
    2d58:	00 
    2d59:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2d60:	e8 da 17 00 00       	call   453f <printf>
}
    2d65:	c9                   	leave  
    2d66:	c3                   	ret    

00002d67 <fourteen>:

void
fourteen(void)
{
    2d67:	55                   	push   %ebp
    2d68:	89 e5                	mov    %esp,%ebp
    2d6a:	83 ec 28             	sub    $0x28,%esp
  int fd;

  // DIRSIZ is 14.
  printf(1, "fourteen test\n");
    2d6d:	c7 44 24 04 3f 58 00 	movl   $0x583f,0x4(%esp)
    2d74:	00 
    2d75:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2d7c:	e8 be 17 00 00       	call   453f <printf>

  if(mkdir("12345678901234") != 0){
    2d81:	c7 04 24 4e 58 00 00 	movl   $0x584e,(%esp)
    2d88:	e8 a3 16 00 00       	call   4430 <mkdir>
    2d8d:	85 c0                	test   %eax,%eax
    2d8f:	74 20                	je     2db1 <fourteen+0x4a>
    printf(1, "mkdir 12345678901234 failed\n");
    2d91:	c7 44 24 04 5d 58 00 	movl   $0x585d,0x4(%esp)
    2d98:	00 
    2d99:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2da0:	e8 9a 17 00 00       	call   453f <printf>
    exit(EXIT_STATUS_DEFAULT);
    2da5:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    2dac:	e8 17 16 00 00       	call   43c8 <exit>
  }
  if(mkdir("12345678901234/123456789012345") != 0){
    2db1:	c7 04 24 7c 58 00 00 	movl   $0x587c,(%esp)
    2db8:	e8 73 16 00 00       	call   4430 <mkdir>
    2dbd:	85 c0                	test   %eax,%eax
    2dbf:	74 20                	je     2de1 <fourteen+0x7a>
    printf(1, "mkdir 12345678901234/123456789012345 failed\n");
    2dc1:	c7 44 24 04 9c 58 00 	movl   $0x589c,0x4(%esp)
    2dc8:	00 
    2dc9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2dd0:	e8 6a 17 00 00       	call   453f <printf>
    exit(EXIT_STATUS_DEFAULT);
    2dd5:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    2ddc:	e8 e7 15 00 00       	call   43c8 <exit>
  }
  fd = open("123456789012345/123456789012345/123456789012345", O_CREATE);
    2de1:	c7 44 24 04 00 02 00 	movl   $0x200,0x4(%esp)
    2de8:	00 
    2de9:	c7 04 24 cc 58 00 00 	movl   $0x58cc,(%esp)
    2df0:	e8 13 16 00 00       	call   4408 <open>
    2df5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0){
    2df8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    2dfc:	79 20                	jns    2e1e <fourteen+0xb7>
    printf(1, "create 123456789012345/123456789012345/123456789012345 failed\n");
    2dfe:	c7 44 24 04 fc 58 00 	movl   $0x58fc,0x4(%esp)
    2e05:	00 
    2e06:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2e0d:	e8 2d 17 00 00       	call   453f <printf>
    exit(EXIT_STATUS_DEFAULT);
    2e12:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    2e19:	e8 aa 15 00 00       	call   43c8 <exit>
  }
  close(fd);
    2e1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
    2e21:	89 04 24             	mov    %eax,(%esp)
    2e24:	e8 c7 15 00 00       	call   43f0 <close>
  fd = open("12345678901234/12345678901234/12345678901234", 0);
    2e29:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    2e30:	00 
    2e31:	c7 04 24 3c 59 00 00 	movl   $0x593c,(%esp)
    2e38:	e8 cb 15 00 00       	call   4408 <open>
    2e3d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0){
    2e40:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    2e44:	79 20                	jns    2e66 <fourteen+0xff>
    printf(1, "open 12345678901234/12345678901234/12345678901234 failed\n");
    2e46:	c7 44 24 04 6c 59 00 	movl   $0x596c,0x4(%esp)
    2e4d:	00 
    2e4e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2e55:	e8 e5 16 00 00       	call   453f <printf>
    exit(EXIT_STATUS_DEFAULT);
    2e5a:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    2e61:	e8 62 15 00 00       	call   43c8 <exit>
  }
  close(fd);
    2e66:	8b 45 f4             	mov    -0xc(%ebp),%eax
    2e69:	89 04 24             	mov    %eax,(%esp)
    2e6c:	e8 7f 15 00 00       	call   43f0 <close>

  if(mkdir("12345678901234/12345678901234") == 0){
    2e71:	c7 04 24 a6 59 00 00 	movl   $0x59a6,(%esp)
    2e78:	e8 b3 15 00 00       	call   4430 <mkdir>
    2e7d:	85 c0                	test   %eax,%eax
    2e7f:	75 20                	jne    2ea1 <fourteen+0x13a>
    printf(1, "mkdir 12345678901234/12345678901234 succeeded!\n");
    2e81:	c7 44 24 04 c4 59 00 	movl   $0x59c4,0x4(%esp)
    2e88:	00 
    2e89:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2e90:	e8 aa 16 00 00       	call   453f <printf>
    exit(EXIT_STATUS_DEFAULT);
    2e95:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    2e9c:	e8 27 15 00 00       	call   43c8 <exit>
  }
  if(mkdir("123456789012345/12345678901234") == 0){
    2ea1:	c7 04 24 f4 59 00 00 	movl   $0x59f4,(%esp)
    2ea8:	e8 83 15 00 00       	call   4430 <mkdir>
    2ead:	85 c0                	test   %eax,%eax
    2eaf:	75 20                	jne    2ed1 <fourteen+0x16a>
    printf(1, "mkdir 12345678901234/123456789012345 succeeded!\n");
    2eb1:	c7 44 24 04 14 5a 00 	movl   $0x5a14,0x4(%esp)
    2eb8:	00 
    2eb9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2ec0:	e8 7a 16 00 00       	call   453f <printf>
    exit(EXIT_STATUS_DEFAULT);
    2ec5:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    2ecc:	e8 f7 14 00 00       	call   43c8 <exit>
  }

  printf(1, "fourteen ok\n");
    2ed1:	c7 44 24 04 45 5a 00 	movl   $0x5a45,0x4(%esp)
    2ed8:	00 
    2ed9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2ee0:	e8 5a 16 00 00       	call   453f <printf>
}
    2ee5:	c9                   	leave  
    2ee6:	c3                   	ret    

00002ee7 <rmdot>:

void
rmdot(void)
{
    2ee7:	55                   	push   %ebp
    2ee8:	89 e5                	mov    %esp,%ebp
    2eea:	83 ec 18             	sub    $0x18,%esp
  printf(1, "rmdot test\n");
    2eed:	c7 44 24 04 52 5a 00 	movl   $0x5a52,0x4(%esp)
    2ef4:	00 
    2ef5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2efc:	e8 3e 16 00 00       	call   453f <printf>
  if(mkdir("dots") != 0){
    2f01:	c7 04 24 5e 5a 00 00 	movl   $0x5a5e,(%esp)
    2f08:	e8 23 15 00 00       	call   4430 <mkdir>
    2f0d:	85 c0                	test   %eax,%eax
    2f0f:	74 20                	je     2f31 <rmdot+0x4a>
    printf(1, "mkdir dots failed\n");
    2f11:	c7 44 24 04 63 5a 00 	movl   $0x5a63,0x4(%esp)
    2f18:	00 
    2f19:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2f20:	e8 1a 16 00 00       	call   453f <printf>
    exit(EXIT_STATUS_DEFAULT);
    2f25:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    2f2c:	e8 97 14 00 00       	call   43c8 <exit>
  }
  if(chdir("dots") != 0){
    2f31:	c7 04 24 5e 5a 00 00 	movl   $0x5a5e,(%esp)
    2f38:	e8 fb 14 00 00       	call   4438 <chdir>
    2f3d:	85 c0                	test   %eax,%eax
    2f3f:	74 20                	je     2f61 <rmdot+0x7a>
    printf(1, "chdir dots failed\n");
    2f41:	c7 44 24 04 76 5a 00 	movl   $0x5a76,0x4(%esp)
    2f48:	00 
    2f49:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2f50:	e8 ea 15 00 00       	call   453f <printf>
    exit(EXIT_STATUS_DEFAULT);
    2f55:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    2f5c:	e8 67 14 00 00       	call   43c8 <exit>
  }
  if(unlink(".") == 0){
    2f61:	c7 04 24 8f 51 00 00 	movl   $0x518f,(%esp)
    2f68:	e8 ab 14 00 00       	call   4418 <unlink>
    2f6d:	85 c0                	test   %eax,%eax
    2f6f:	75 20                	jne    2f91 <rmdot+0xaa>
    printf(1, "rm . worked!\n");
    2f71:	c7 44 24 04 89 5a 00 	movl   $0x5a89,0x4(%esp)
    2f78:	00 
    2f79:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2f80:	e8 ba 15 00 00       	call   453f <printf>
    exit(EXIT_STATUS_DEFAULT);
    2f85:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    2f8c:	e8 37 14 00 00       	call   43c8 <exit>
  }
  if(unlink("..") == 0){
    2f91:	c7 04 24 22 4d 00 00 	movl   $0x4d22,(%esp)
    2f98:	e8 7b 14 00 00       	call   4418 <unlink>
    2f9d:	85 c0                	test   %eax,%eax
    2f9f:	75 20                	jne    2fc1 <rmdot+0xda>
    printf(1, "rm .. worked!\n");
    2fa1:	c7 44 24 04 97 5a 00 	movl   $0x5a97,0x4(%esp)
    2fa8:	00 
    2fa9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2fb0:	e8 8a 15 00 00       	call   453f <printf>
    exit(EXIT_STATUS_DEFAULT);
    2fb5:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    2fbc:	e8 07 14 00 00       	call   43c8 <exit>
  }
  if(chdir("/") != 0){
    2fc1:	c7 04 24 76 49 00 00 	movl   $0x4976,(%esp)
    2fc8:	e8 6b 14 00 00       	call   4438 <chdir>
    2fcd:	85 c0                	test   %eax,%eax
    2fcf:	74 20                	je     2ff1 <rmdot+0x10a>
    printf(1, "chdir / failed\n");
    2fd1:	c7 44 24 04 78 49 00 	movl   $0x4978,0x4(%esp)
    2fd8:	00 
    2fd9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2fe0:	e8 5a 15 00 00       	call   453f <printf>
    exit(EXIT_STATUS_DEFAULT);
    2fe5:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    2fec:	e8 d7 13 00 00       	call   43c8 <exit>
  }
  if(unlink("dots/.") == 0){
    2ff1:	c7 04 24 a6 5a 00 00 	movl   $0x5aa6,(%esp)
    2ff8:	e8 1b 14 00 00       	call   4418 <unlink>
    2ffd:	85 c0                	test   %eax,%eax
    2fff:	75 20                	jne    3021 <rmdot+0x13a>
    printf(1, "unlink dots/. worked!\n");
    3001:	c7 44 24 04 ad 5a 00 	movl   $0x5aad,0x4(%esp)
    3008:	00 
    3009:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    3010:	e8 2a 15 00 00       	call   453f <printf>
    exit(EXIT_STATUS_DEFAULT);
    3015:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    301c:	e8 a7 13 00 00       	call   43c8 <exit>
  }
  if(unlink("dots/..") == 0){
    3021:	c7 04 24 c4 5a 00 00 	movl   $0x5ac4,(%esp)
    3028:	e8 eb 13 00 00       	call   4418 <unlink>
    302d:	85 c0                	test   %eax,%eax
    302f:	75 20                	jne    3051 <rmdot+0x16a>
    printf(1, "unlink dots/.. worked!\n");
    3031:	c7 44 24 04 cc 5a 00 	movl   $0x5acc,0x4(%esp)
    3038:	00 
    3039:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    3040:	e8 fa 14 00 00       	call   453f <printf>
    exit(EXIT_STATUS_DEFAULT);
    3045:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    304c:	e8 77 13 00 00       	call   43c8 <exit>
  }
  if(unlink("dots") != 0){
    3051:	c7 04 24 5e 5a 00 00 	movl   $0x5a5e,(%esp)
    3058:	e8 bb 13 00 00       	call   4418 <unlink>
    305d:	85 c0                	test   %eax,%eax
    305f:	74 20                	je     3081 <rmdot+0x19a>
    printf(1, "unlink dots failed!\n");
    3061:	c7 44 24 04 e4 5a 00 	movl   $0x5ae4,0x4(%esp)
    3068:	00 
    3069:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    3070:	e8 ca 14 00 00       	call   453f <printf>
    exit(EXIT_STATUS_DEFAULT);
    3075:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    307c:	e8 47 13 00 00       	call   43c8 <exit>
  }
  printf(1, "rmdot ok\n");
    3081:	c7 44 24 04 f9 5a 00 	movl   $0x5af9,0x4(%esp)
    3088:	00 
    3089:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    3090:	e8 aa 14 00 00       	call   453f <printf>
}
    3095:	c9                   	leave  
    3096:	c3                   	ret    

00003097 <dirfile>:

void
dirfile(void)
{
    3097:	55                   	push   %ebp
    3098:	89 e5                	mov    %esp,%ebp
    309a:	83 ec 28             	sub    $0x28,%esp
  int fd;

  printf(1, "dir vs file\n");
    309d:	c7 44 24 04 03 5b 00 	movl   $0x5b03,0x4(%esp)
    30a4:	00 
    30a5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    30ac:	e8 8e 14 00 00       	call   453f <printf>

  fd = open("dirfile", O_CREATE);
    30b1:	c7 44 24 04 00 02 00 	movl   $0x200,0x4(%esp)
    30b8:	00 
    30b9:	c7 04 24 10 5b 00 00 	movl   $0x5b10,(%esp)
    30c0:	e8 43 13 00 00       	call   4408 <open>
    30c5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0){
    30c8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    30cc:	79 20                	jns    30ee <dirfile+0x57>
    printf(1, "create dirfile failed\n");
    30ce:	c7 44 24 04 18 5b 00 	movl   $0x5b18,0x4(%esp)
    30d5:	00 
    30d6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    30dd:	e8 5d 14 00 00       	call   453f <printf>
    exit(EXIT_STATUS_DEFAULT);
    30e2:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    30e9:	e8 da 12 00 00       	call   43c8 <exit>
  }
  close(fd);
    30ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
    30f1:	89 04 24             	mov    %eax,(%esp)
    30f4:	e8 f7 12 00 00       	call   43f0 <close>
  if(chdir("dirfile") == 0){
    30f9:	c7 04 24 10 5b 00 00 	movl   $0x5b10,(%esp)
    3100:	e8 33 13 00 00       	call   4438 <chdir>
    3105:	85 c0                	test   %eax,%eax
    3107:	75 20                	jne    3129 <dirfile+0x92>
    printf(1, "chdir dirfile succeeded!\n");
    3109:	c7 44 24 04 2f 5b 00 	movl   $0x5b2f,0x4(%esp)
    3110:	00 
    3111:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    3118:	e8 22 14 00 00       	call   453f <printf>
    exit(EXIT_STATUS_DEFAULT);
    311d:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    3124:	e8 9f 12 00 00       	call   43c8 <exit>
  }
  fd = open("dirfile/xx", 0);
    3129:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    3130:	00 
    3131:	c7 04 24 49 5b 00 00 	movl   $0x5b49,(%esp)
    3138:	e8 cb 12 00 00       	call   4408 <open>
    313d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd >= 0){
    3140:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    3144:	78 20                	js     3166 <dirfile+0xcf>
    printf(1, "create dirfile/xx succeeded!\n");
    3146:	c7 44 24 04 54 5b 00 	movl   $0x5b54,0x4(%esp)
    314d:	00 
    314e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    3155:	e8 e5 13 00 00       	call   453f <printf>
    exit(EXIT_STATUS_DEFAULT);
    315a:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    3161:	e8 62 12 00 00       	call   43c8 <exit>
  }
  fd = open("dirfile/xx", O_CREATE);
    3166:	c7 44 24 04 00 02 00 	movl   $0x200,0x4(%esp)
    316d:	00 
    316e:	c7 04 24 49 5b 00 00 	movl   $0x5b49,(%esp)
    3175:	e8 8e 12 00 00       	call   4408 <open>
    317a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd >= 0){
    317d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    3181:	78 20                	js     31a3 <dirfile+0x10c>
    printf(1, "create dirfile/xx succeeded!\n");
    3183:	c7 44 24 04 54 5b 00 	movl   $0x5b54,0x4(%esp)
    318a:	00 
    318b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    3192:	e8 a8 13 00 00       	call   453f <printf>
    exit(EXIT_STATUS_DEFAULT);
    3197:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    319e:	e8 25 12 00 00       	call   43c8 <exit>
  }
  if(mkdir("dirfile/xx") == 0){
    31a3:	c7 04 24 49 5b 00 00 	movl   $0x5b49,(%esp)
    31aa:	e8 81 12 00 00       	call   4430 <mkdir>
    31af:	85 c0                	test   %eax,%eax
    31b1:	75 20                	jne    31d3 <dirfile+0x13c>
    printf(1, "mkdir dirfile/xx succeeded!\n");
    31b3:	c7 44 24 04 72 5b 00 	movl   $0x5b72,0x4(%esp)
    31ba:	00 
    31bb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    31c2:	e8 78 13 00 00       	call   453f <printf>
    exit(EXIT_STATUS_DEFAULT);
    31c7:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    31ce:	e8 f5 11 00 00       	call   43c8 <exit>
  }
  if(unlink("dirfile/xx") == 0){
    31d3:	c7 04 24 49 5b 00 00 	movl   $0x5b49,(%esp)
    31da:	e8 39 12 00 00       	call   4418 <unlink>
    31df:	85 c0                	test   %eax,%eax
    31e1:	75 20                	jne    3203 <dirfile+0x16c>
    printf(1, "unlink dirfile/xx succeeded!\n");
    31e3:	c7 44 24 04 8f 5b 00 	movl   $0x5b8f,0x4(%esp)
    31ea:	00 
    31eb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    31f2:	e8 48 13 00 00       	call   453f <printf>
    exit(EXIT_STATUS_DEFAULT);
    31f7:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    31fe:	e8 c5 11 00 00       	call   43c8 <exit>
  }
  if(link("README", "dirfile/xx") == 0){
    3203:	c7 44 24 04 49 5b 00 	movl   $0x5b49,0x4(%esp)
    320a:	00 
    320b:	c7 04 24 ad 5b 00 00 	movl   $0x5bad,(%esp)
    3212:	e8 11 12 00 00       	call   4428 <link>
    3217:	85 c0                	test   %eax,%eax
    3219:	75 20                	jne    323b <dirfile+0x1a4>
    printf(1, "link to dirfile/xx succeeded!\n");
    321b:	c7 44 24 04 b4 5b 00 	movl   $0x5bb4,0x4(%esp)
    3222:	00 
    3223:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    322a:	e8 10 13 00 00       	call   453f <printf>
    exit(EXIT_STATUS_DEFAULT);
    322f:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    3236:	e8 8d 11 00 00       	call   43c8 <exit>
  }
  if(unlink("dirfile") != 0){
    323b:	c7 04 24 10 5b 00 00 	movl   $0x5b10,(%esp)
    3242:	e8 d1 11 00 00       	call   4418 <unlink>
    3247:	85 c0                	test   %eax,%eax
    3249:	74 20                	je     326b <dirfile+0x1d4>
    printf(1, "unlink dirfile failed!\n");
    324b:	c7 44 24 04 d3 5b 00 	movl   $0x5bd3,0x4(%esp)
    3252:	00 
    3253:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    325a:	e8 e0 12 00 00       	call   453f <printf>
    exit(EXIT_STATUS_DEFAULT);
    325f:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    3266:	e8 5d 11 00 00       	call   43c8 <exit>
  }

  fd = open(".", O_RDWR);
    326b:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
    3272:	00 
    3273:	c7 04 24 8f 51 00 00 	movl   $0x518f,(%esp)
    327a:	e8 89 11 00 00       	call   4408 <open>
    327f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd >= 0){
    3282:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    3286:	78 20                	js     32a8 <dirfile+0x211>
    printf(1, "open . for writing succeeded!\n");
    3288:	c7 44 24 04 ec 5b 00 	movl   $0x5bec,0x4(%esp)
    328f:	00 
    3290:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    3297:	e8 a3 12 00 00       	call   453f <printf>
    exit(EXIT_STATUS_DEFAULT);
    329c:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    32a3:	e8 20 11 00 00       	call   43c8 <exit>
  }
  fd = open(".", 0);
    32a8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    32af:	00 
    32b0:	c7 04 24 8f 51 00 00 	movl   $0x518f,(%esp)
    32b7:	e8 4c 11 00 00       	call   4408 <open>
    32bc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(write(fd, "x", 1) > 0){
    32bf:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
    32c6:	00 
    32c7:	c7 44 24 04 db 4d 00 	movl   $0x4ddb,0x4(%esp)
    32ce:	00 
    32cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
    32d2:	89 04 24             	mov    %eax,(%esp)
    32d5:	e8 0e 11 00 00       	call   43e8 <write>
    32da:	85 c0                	test   %eax,%eax
    32dc:	7e 20                	jle    32fe <dirfile+0x267>
    printf(1, "write . succeeded!\n");
    32de:	c7 44 24 04 0b 5c 00 	movl   $0x5c0b,0x4(%esp)
    32e5:	00 
    32e6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    32ed:	e8 4d 12 00 00       	call   453f <printf>
    exit(EXIT_STATUS_DEFAULT);
    32f2:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    32f9:	e8 ca 10 00 00       	call   43c8 <exit>
  }
  close(fd);
    32fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
    3301:	89 04 24             	mov    %eax,(%esp)
    3304:	e8 e7 10 00 00       	call   43f0 <close>

  printf(1, "dir vs file OK\n");
    3309:	c7 44 24 04 1f 5c 00 	movl   $0x5c1f,0x4(%esp)
    3310:	00 
    3311:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    3318:	e8 22 12 00 00       	call   453f <printf>
}
    331d:	c9                   	leave  
    331e:	c3                   	ret    

0000331f <iref>:

// test that iput() is called at the end of _namei()
void
iref(void)
{
    331f:	55                   	push   %ebp
    3320:	89 e5                	mov    %esp,%ebp
    3322:	83 ec 28             	sub    $0x28,%esp
  int i, fd;

  printf(1, "empty file name\n");
    3325:	c7 44 24 04 2f 5c 00 	movl   $0x5c2f,0x4(%esp)
    332c:	00 
    332d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    3334:	e8 06 12 00 00       	call   453f <printf>

  // the 50 is NINODE
  for(i = 0; i < 50 + 1; i++){
    3339:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    3340:	e9 e0 00 00 00       	jmp    3425 <iref+0x106>
    if(mkdir("irefd") != 0){
    3345:	c7 04 24 40 5c 00 00 	movl   $0x5c40,(%esp)
    334c:	e8 df 10 00 00       	call   4430 <mkdir>
    3351:	85 c0                	test   %eax,%eax
    3353:	74 20                	je     3375 <iref+0x56>
      printf(1, "mkdir irefd failed\n");
    3355:	c7 44 24 04 46 5c 00 	movl   $0x5c46,0x4(%esp)
    335c:	00 
    335d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    3364:	e8 d6 11 00 00       	call   453f <printf>
      exit(EXIT_STATUS_DEFAULT);
    3369:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    3370:	e8 53 10 00 00       	call   43c8 <exit>
    }
    if(chdir("irefd") != 0){
    3375:	c7 04 24 40 5c 00 00 	movl   $0x5c40,(%esp)
    337c:	e8 b7 10 00 00       	call   4438 <chdir>
    3381:	85 c0                	test   %eax,%eax
    3383:	74 20                	je     33a5 <iref+0x86>
      printf(1, "chdir irefd failed\n");
    3385:	c7 44 24 04 5a 5c 00 	movl   $0x5c5a,0x4(%esp)
    338c:	00 
    338d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    3394:	e8 a6 11 00 00       	call   453f <printf>
      exit(EXIT_STATUS_DEFAULT);
    3399:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    33a0:	e8 23 10 00 00       	call   43c8 <exit>
    }

    mkdir("");
    33a5:	c7 04 24 6e 5c 00 00 	movl   $0x5c6e,(%esp)
    33ac:	e8 7f 10 00 00       	call   4430 <mkdir>
    link("README", "");
    33b1:	c7 44 24 04 6e 5c 00 	movl   $0x5c6e,0x4(%esp)
    33b8:	00 
    33b9:	c7 04 24 ad 5b 00 00 	movl   $0x5bad,(%esp)
    33c0:	e8 63 10 00 00       	call   4428 <link>
    fd = open("", O_CREATE);
    33c5:	c7 44 24 04 00 02 00 	movl   $0x200,0x4(%esp)
    33cc:	00 
    33cd:	c7 04 24 6e 5c 00 00 	movl   $0x5c6e,(%esp)
    33d4:	e8 2f 10 00 00       	call   4408 <open>
    33d9:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(fd >= 0)
    33dc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    33e0:	78 0b                	js     33ed <iref+0xce>
      close(fd);
    33e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
    33e5:	89 04 24             	mov    %eax,(%esp)
    33e8:	e8 03 10 00 00       	call   43f0 <close>
    fd = open("xx", O_CREATE);
    33ed:	c7 44 24 04 00 02 00 	movl   $0x200,0x4(%esp)
    33f4:	00 
    33f5:	c7 04 24 6f 5c 00 00 	movl   $0x5c6f,(%esp)
    33fc:	e8 07 10 00 00       	call   4408 <open>
    3401:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(fd >= 0)
    3404:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    3408:	78 0b                	js     3415 <iref+0xf6>
      close(fd);
    340a:	8b 45 f0             	mov    -0x10(%ebp),%eax
    340d:	89 04 24             	mov    %eax,(%esp)
    3410:	e8 db 0f 00 00       	call   43f0 <close>
    unlink("xx");
    3415:	c7 04 24 6f 5c 00 00 	movl   $0x5c6f,(%esp)
    341c:	e8 f7 0f 00 00       	call   4418 <unlink>
  int i, fd;

  printf(1, "empty file name\n");

  // the 50 is NINODE
  for(i = 0; i < 50 + 1; i++){
    3421:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    3425:	83 7d f4 32          	cmpl   $0x32,-0xc(%ebp)
    3429:	0f 8e 16 ff ff ff    	jle    3345 <iref+0x26>
    if(fd >= 0)
      close(fd);
    unlink("xx");
  }

  chdir("/");
    342f:	c7 04 24 76 49 00 00 	movl   $0x4976,(%esp)
    3436:	e8 fd 0f 00 00       	call   4438 <chdir>
  printf(1, "empty file name OK\n");
    343b:	c7 44 24 04 72 5c 00 	movl   $0x5c72,0x4(%esp)
    3442:	00 
    3443:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    344a:	e8 f0 10 00 00       	call   453f <printf>
}
    344f:	c9                   	leave  
    3450:	c3                   	ret    

00003451 <forktest>:
// test that fork fails gracefully
// the forktest binary also does this, but it runs out of proc entries first.
// inside the bigger usertests binary, we run out of memory first.
void
forktest(void)
{
    3451:	55                   	push   %ebp
    3452:	89 e5                	mov    %esp,%ebp
    3454:	83 ec 28             	sub    $0x28,%esp
  int n, pid;

  printf(1, "fork test\n");
    3457:	c7 44 24 04 86 5c 00 	movl   $0x5c86,0x4(%esp)
    345e:	00 
    345f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    3466:	e8 d4 10 00 00       	call   453f <printf>

  for(n=0; n<1000; n++){
    346b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    3472:	eb 24                	jmp    3498 <forktest+0x47>
    pid = fork();
    3474:	e8 47 0f 00 00       	call   43c0 <fork>
    3479:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(pid < 0)
    347c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    3480:	78 21                	js     34a3 <forktest+0x52>
      break;
    if(pid == 0)
    3482:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    3486:	75 0c                	jne    3494 <forktest+0x43>
      exit(EXIT_STATUS_DEFAULT);
    3488:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    348f:	e8 34 0f 00 00       	call   43c8 <exit>
{
  int n, pid;

  printf(1, "fork test\n");

  for(n=0; n<1000; n++){
    3494:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    3498:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
    349f:	7e d3                	jle    3474 <forktest+0x23>
    34a1:	eb 01                	jmp    34a4 <forktest+0x53>
    pid = fork();
    if(pid < 0)
      break;
    34a3:	90                   	nop
    if(pid == 0)
      exit(EXIT_STATUS_DEFAULT);
  }
  
  if(n == 1000){
    34a4:	81 7d f4 e8 03 00 00 	cmpl   $0x3e8,-0xc(%ebp)
    34ab:	75 4d                	jne    34fa <forktest+0xa9>
    printf(1, "fork claimed to work 1000 times!\n");
    34ad:	c7 44 24 04 94 5c 00 	movl   $0x5c94,0x4(%esp)
    34b4:	00 
    34b5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    34bc:	e8 7e 10 00 00       	call   453f <printf>
    exit(EXIT_STATUS_DEFAULT);
    34c1:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    34c8:	e8 fb 0e 00 00       	call   43c8 <exit>
  }
  
  for(; n > 0; n--){
    if(wait() < 0){
    34cd:	e8 fe 0e 00 00       	call   43d0 <wait>
    34d2:	85 c0                	test   %eax,%eax
    34d4:	79 20                	jns    34f6 <forktest+0xa5>
      printf(1, "wait stopped early\n");
    34d6:	c7 44 24 04 b6 5c 00 	movl   $0x5cb6,0x4(%esp)
    34dd:	00 
    34de:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    34e5:	e8 55 10 00 00       	call   453f <printf>
      exit(EXIT_STATUS_DEFAULT);
    34ea:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    34f1:	e8 d2 0e 00 00       	call   43c8 <exit>
  if(n == 1000){
    printf(1, "fork claimed to work 1000 times!\n");
    exit(EXIT_STATUS_DEFAULT);
  }
  
  for(; n > 0; n--){
    34f6:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
    34fa:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    34fe:	7f cd                	jg     34cd <forktest+0x7c>
      printf(1, "wait stopped early\n");
      exit(EXIT_STATUS_DEFAULT);
    }
  }
  
  if(wait() != -1){
    3500:	e8 cb 0e 00 00       	call   43d0 <wait>
    3505:	83 f8 ff             	cmp    $0xffffffff,%eax
    3508:	74 20                	je     352a <forktest+0xd9>
    printf(1, "wait got too many\n");
    350a:	c7 44 24 04 ca 5c 00 	movl   $0x5cca,0x4(%esp)
    3511:	00 
    3512:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    3519:	e8 21 10 00 00       	call   453f <printf>
    exit(EXIT_STATUS_DEFAULT);
    351e:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    3525:	e8 9e 0e 00 00       	call   43c8 <exit>
  }
  
  printf(1, "fork test OK\n");
    352a:	c7 44 24 04 dd 5c 00 	movl   $0x5cdd,0x4(%esp)
    3531:	00 
    3532:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    3539:	e8 01 10 00 00       	call   453f <printf>
}
    353e:	c9                   	leave  
    353f:	c3                   	ret    

00003540 <sbrktest>:

void
sbrktest(void)
{
    3540:	55                   	push   %ebp
    3541:	89 e5                	mov    %esp,%ebp
    3543:	53                   	push   %ebx
    3544:	81 ec 84 00 00 00    	sub    $0x84,%esp
  int fds[2], pid, pids[10], ppid;
  char *a, *b, *c, *lastaddr, *oldbrk, *p, scratch;
  uint amt;

  printf(stdout, "sbrk test\n");
    354a:	a1 c4 67 00 00       	mov    0x67c4,%eax
    354f:	c7 44 24 04 eb 5c 00 	movl   $0x5ceb,0x4(%esp)
    3556:	00 
    3557:	89 04 24             	mov    %eax,(%esp)
    355a:	e8 e0 0f 00 00       	call   453f <printf>
  oldbrk = sbrk(0);
    355f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    3566:	e8 e5 0e 00 00       	call   4450 <sbrk>
    356b:	89 45 ec             	mov    %eax,-0x14(%ebp)

  // can one sbrk() less than a page?
  a = sbrk(0);
    356e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    3575:	e8 d6 0e 00 00       	call   4450 <sbrk>
    357a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  int i;
  for(i = 0; i < 5000; i++){ 
    357d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    3584:	eb 60                	jmp    35e6 <sbrktest+0xa6>
    b = sbrk(1);
    3586:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    358d:	e8 be 0e 00 00       	call   4450 <sbrk>
    3592:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(b != a){
    3595:	8b 45 e8             	mov    -0x18(%ebp),%eax
    3598:	3b 45 f4             	cmp    -0xc(%ebp),%eax
    359b:	74 36                	je     35d3 <sbrktest+0x93>
      printf(stdout, "sbrk test failed %d %x %x\n", i, a, b);
    359d:	a1 c4 67 00 00       	mov    0x67c4,%eax
    35a2:	8b 55 e8             	mov    -0x18(%ebp),%edx
    35a5:	89 54 24 10          	mov    %edx,0x10(%esp)
    35a9:	8b 55 f4             	mov    -0xc(%ebp),%edx
    35ac:	89 54 24 0c          	mov    %edx,0xc(%esp)
    35b0:	8b 55 f0             	mov    -0x10(%ebp),%edx
    35b3:	89 54 24 08          	mov    %edx,0x8(%esp)
    35b7:	c7 44 24 04 f6 5c 00 	movl   $0x5cf6,0x4(%esp)
    35be:	00 
    35bf:	89 04 24             	mov    %eax,(%esp)
    35c2:	e8 78 0f 00 00       	call   453f <printf>
      exit(EXIT_STATUS_DEFAULT);
    35c7:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    35ce:	e8 f5 0d 00 00       	call   43c8 <exit>
    }
    *b = 1;
    35d3:	8b 45 e8             	mov    -0x18(%ebp),%eax
    35d6:	c6 00 01             	movb   $0x1,(%eax)
    a = b + 1;
    35d9:	8b 45 e8             	mov    -0x18(%ebp),%eax
    35dc:	83 c0 01             	add    $0x1,%eax
    35df:	89 45 f4             	mov    %eax,-0xc(%ebp)
  oldbrk = sbrk(0);

  // can one sbrk() less than a page?
  a = sbrk(0);
  int i;
  for(i = 0; i < 5000; i++){ 
    35e2:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
    35e6:	81 7d f0 87 13 00 00 	cmpl   $0x1387,-0x10(%ebp)
    35ed:	7e 97                	jle    3586 <sbrktest+0x46>
      exit(EXIT_STATUS_DEFAULT);
    }
    *b = 1;
    a = b + 1;
  }
  pid = fork();
    35ef:	e8 cc 0d 00 00       	call   43c0 <fork>
    35f4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  if(pid < 0){
    35f7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
    35fb:	79 21                	jns    361e <sbrktest+0xde>
    printf(stdout, "sbrk test fork failed\n");
    35fd:	a1 c4 67 00 00       	mov    0x67c4,%eax
    3602:	c7 44 24 04 11 5d 00 	movl   $0x5d11,0x4(%esp)
    3609:	00 
    360a:	89 04 24             	mov    %eax,(%esp)
    360d:	e8 2d 0f 00 00       	call   453f <printf>
    exit(EXIT_STATUS_DEFAULT);
    3612:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    3619:	e8 aa 0d 00 00       	call   43c8 <exit>
  }
  c = sbrk(1);
    361e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    3625:	e8 26 0e 00 00       	call   4450 <sbrk>
    362a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  c = sbrk(1);
    362d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    3634:	e8 17 0e 00 00       	call   4450 <sbrk>
    3639:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if(c != a + 1){
    363c:	8b 45 f4             	mov    -0xc(%ebp),%eax
    363f:	83 c0 01             	add    $0x1,%eax
    3642:	3b 45 e0             	cmp    -0x20(%ebp),%eax
    3645:	74 21                	je     3668 <sbrktest+0x128>
    printf(stdout, "sbrk test failed post-fork\n");
    3647:	a1 c4 67 00 00       	mov    0x67c4,%eax
    364c:	c7 44 24 04 28 5d 00 	movl   $0x5d28,0x4(%esp)
    3653:	00 
    3654:	89 04 24             	mov    %eax,(%esp)
    3657:	e8 e3 0e 00 00       	call   453f <printf>
    exit(EXIT_STATUS_DEFAULT);
    365c:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    3663:	e8 60 0d 00 00       	call   43c8 <exit>
  }
  if(pid == 0)
    3668:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
    366c:	75 0c                	jne    367a <sbrktest+0x13a>
    exit(EXIT_STATUS_DEFAULT);
    366e:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    3675:	e8 4e 0d 00 00       	call   43c8 <exit>
  wait();
    367a:	e8 51 0d 00 00       	call   43d0 <wait>

  // can one grow address space to something big?
#define BIG (100*1024*1024)
  a = sbrk(0);
    367f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    3686:	e8 c5 0d 00 00       	call   4450 <sbrk>
    368b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  amt = (BIG) - (uint)a;
    368e:	8b 45 f4             	mov    -0xc(%ebp),%eax
    3691:	ba 00 00 40 06       	mov    $0x6400000,%edx
    3696:	89 d1                	mov    %edx,%ecx
    3698:	29 c1                	sub    %eax,%ecx
    369a:	89 c8                	mov    %ecx,%eax
    369c:	89 45 dc             	mov    %eax,-0x24(%ebp)
  p = sbrk(amt);
    369f:	8b 45 dc             	mov    -0x24(%ebp),%eax
    36a2:	89 04 24             	mov    %eax,(%esp)
    36a5:	e8 a6 0d 00 00       	call   4450 <sbrk>
    36aa:	89 45 d8             	mov    %eax,-0x28(%ebp)
  if (p != a) { 
    36ad:	8b 45 d8             	mov    -0x28(%ebp),%eax
    36b0:	3b 45 f4             	cmp    -0xc(%ebp),%eax
    36b3:	74 21                	je     36d6 <sbrktest+0x196>
    printf(stdout, "sbrk test failed to grow big address space; enough phys mem?\n");
    36b5:	a1 c4 67 00 00       	mov    0x67c4,%eax
    36ba:	c7 44 24 04 44 5d 00 	movl   $0x5d44,0x4(%esp)
    36c1:	00 
    36c2:	89 04 24             	mov    %eax,(%esp)
    36c5:	e8 75 0e 00 00       	call   453f <printf>
    exit(EXIT_STATUS_DEFAULT);
    36ca:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    36d1:	e8 f2 0c 00 00       	call   43c8 <exit>
  }
  lastaddr = (char*) (BIG-1);
    36d6:	c7 45 d4 ff ff 3f 06 	movl   $0x63fffff,-0x2c(%ebp)
  *lastaddr = 99;
    36dd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
    36e0:	c6 00 63             	movb   $0x63,(%eax)

  // can one de-allocate?
  a = sbrk(0);
    36e3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    36ea:	e8 61 0d 00 00       	call   4450 <sbrk>
    36ef:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c = sbrk(-4096);
    36f2:	c7 04 24 00 f0 ff ff 	movl   $0xfffff000,(%esp)
    36f9:	e8 52 0d 00 00       	call   4450 <sbrk>
    36fe:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if(c == (char*)0xffffffff){
    3701:	83 7d e0 ff          	cmpl   $0xffffffff,-0x20(%ebp)
    3705:	75 21                	jne    3728 <sbrktest+0x1e8>
    printf(stdout, "sbrk could not deallocate\n");
    3707:	a1 c4 67 00 00       	mov    0x67c4,%eax
    370c:	c7 44 24 04 82 5d 00 	movl   $0x5d82,0x4(%esp)
    3713:	00 
    3714:	89 04 24             	mov    %eax,(%esp)
    3717:	e8 23 0e 00 00       	call   453f <printf>
    exit(EXIT_STATUS_DEFAULT);
    371c:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    3723:	e8 a0 0c 00 00       	call   43c8 <exit>
  }
  c = sbrk(0);
    3728:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    372f:	e8 1c 0d 00 00       	call   4450 <sbrk>
    3734:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if(c != a - 4096){
    3737:	8b 45 f4             	mov    -0xc(%ebp),%eax
    373a:	2d 00 10 00 00       	sub    $0x1000,%eax
    373f:	3b 45 e0             	cmp    -0x20(%ebp),%eax
    3742:	74 2f                	je     3773 <sbrktest+0x233>
    printf(stdout, "sbrk deallocation produced wrong address, a %x c %x\n", a, c);
    3744:	a1 c4 67 00 00       	mov    0x67c4,%eax
    3749:	8b 55 e0             	mov    -0x20(%ebp),%edx
    374c:	89 54 24 0c          	mov    %edx,0xc(%esp)
    3750:	8b 55 f4             	mov    -0xc(%ebp),%edx
    3753:	89 54 24 08          	mov    %edx,0x8(%esp)
    3757:	c7 44 24 04 a0 5d 00 	movl   $0x5da0,0x4(%esp)
    375e:	00 
    375f:	89 04 24             	mov    %eax,(%esp)
    3762:	e8 d8 0d 00 00       	call   453f <printf>
    exit(EXIT_STATUS_DEFAULT);
    3767:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    376e:	e8 55 0c 00 00       	call   43c8 <exit>
  }

  // can one re-allocate that page?
  a = sbrk(0);
    3773:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    377a:	e8 d1 0c 00 00       	call   4450 <sbrk>
    377f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c = sbrk(4096);
    3782:	c7 04 24 00 10 00 00 	movl   $0x1000,(%esp)
    3789:	e8 c2 0c 00 00       	call   4450 <sbrk>
    378e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if(c != a || sbrk(0) != a + 4096){
    3791:	8b 45 e0             	mov    -0x20(%ebp),%eax
    3794:	3b 45 f4             	cmp    -0xc(%ebp),%eax
    3797:	75 19                	jne    37b2 <sbrktest+0x272>
    3799:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    37a0:	e8 ab 0c 00 00       	call   4450 <sbrk>
    37a5:	8b 55 f4             	mov    -0xc(%ebp),%edx
    37a8:	81 c2 00 10 00 00    	add    $0x1000,%edx
    37ae:	39 d0                	cmp    %edx,%eax
    37b0:	74 2f                	je     37e1 <sbrktest+0x2a1>
    printf(stdout, "sbrk re-allocation failed, a %x c %x\n", a, c);
    37b2:	a1 c4 67 00 00       	mov    0x67c4,%eax
    37b7:	8b 55 e0             	mov    -0x20(%ebp),%edx
    37ba:	89 54 24 0c          	mov    %edx,0xc(%esp)
    37be:	8b 55 f4             	mov    -0xc(%ebp),%edx
    37c1:	89 54 24 08          	mov    %edx,0x8(%esp)
    37c5:	c7 44 24 04 d8 5d 00 	movl   $0x5dd8,0x4(%esp)
    37cc:	00 
    37cd:	89 04 24             	mov    %eax,(%esp)
    37d0:	e8 6a 0d 00 00       	call   453f <printf>
    exit(EXIT_STATUS_DEFAULT);
    37d5:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    37dc:	e8 e7 0b 00 00       	call   43c8 <exit>
  }
  if(*lastaddr == 99){
    37e1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
    37e4:	0f b6 00             	movzbl (%eax),%eax
    37e7:	3c 63                	cmp    $0x63,%al
    37e9:	75 21                	jne    380c <sbrktest+0x2cc>
    // should be zero
    printf(stdout, "sbrk de-allocation didn't really deallocate\n");
    37eb:	a1 c4 67 00 00       	mov    0x67c4,%eax
    37f0:	c7 44 24 04 00 5e 00 	movl   $0x5e00,0x4(%esp)
    37f7:	00 
    37f8:	89 04 24             	mov    %eax,(%esp)
    37fb:	e8 3f 0d 00 00       	call   453f <printf>
    exit(EXIT_STATUS_DEFAULT);
    3800:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    3807:	e8 bc 0b 00 00       	call   43c8 <exit>
  }

  a = sbrk(0);
    380c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    3813:	e8 38 0c 00 00       	call   4450 <sbrk>
    3818:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c = sbrk(-(sbrk(0) - oldbrk));
    381b:	8b 5d ec             	mov    -0x14(%ebp),%ebx
    381e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    3825:	e8 26 0c 00 00       	call   4450 <sbrk>
    382a:	89 da                	mov    %ebx,%edx
    382c:	29 c2                	sub    %eax,%edx
    382e:	89 d0                	mov    %edx,%eax
    3830:	89 04 24             	mov    %eax,(%esp)
    3833:	e8 18 0c 00 00       	call   4450 <sbrk>
    3838:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if(c != a){
    383b:	8b 45 e0             	mov    -0x20(%ebp),%eax
    383e:	3b 45 f4             	cmp    -0xc(%ebp),%eax
    3841:	74 2f                	je     3872 <sbrktest+0x332>
    printf(stdout, "sbrk downsize failed, a %x c %x\n", a, c);
    3843:	a1 c4 67 00 00       	mov    0x67c4,%eax
    3848:	8b 55 e0             	mov    -0x20(%ebp),%edx
    384b:	89 54 24 0c          	mov    %edx,0xc(%esp)
    384f:	8b 55 f4             	mov    -0xc(%ebp),%edx
    3852:	89 54 24 08          	mov    %edx,0x8(%esp)
    3856:	c7 44 24 04 30 5e 00 	movl   $0x5e30,0x4(%esp)
    385d:	00 
    385e:	89 04 24             	mov    %eax,(%esp)
    3861:	e8 d9 0c 00 00       	call   453f <printf>
    exit(EXIT_STATUS_DEFAULT);
    3866:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    386d:	e8 56 0b 00 00       	call   43c8 <exit>
  }
  
  // can we read the kernel's memory?
  for(a = (char*)(KERNBASE); a < (char*) (KERNBASE+2000000); a += 50000){
    3872:	c7 45 f4 00 00 00 80 	movl   $0x80000000,-0xc(%ebp)
    3879:	e9 89 00 00 00       	jmp    3907 <sbrktest+0x3c7>
    ppid = getpid();
    387e:	e8 c5 0b 00 00       	call   4448 <getpid>
    3883:	89 45 d0             	mov    %eax,-0x30(%ebp)
    pid = fork();
    3886:	e8 35 0b 00 00       	call   43c0 <fork>
    388b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(pid < 0){
    388e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
    3892:	79 21                	jns    38b5 <sbrktest+0x375>
      printf(stdout, "fork failed\n");
    3894:	a1 c4 67 00 00       	mov    0x67c4,%eax
    3899:	c7 44 24 04 a5 49 00 	movl   $0x49a5,0x4(%esp)
    38a0:	00 
    38a1:	89 04 24             	mov    %eax,(%esp)
    38a4:	e8 96 0c 00 00       	call   453f <printf>
      exit(EXIT_STATUS_DEFAULT);
    38a9:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    38b0:	e8 13 0b 00 00       	call   43c8 <exit>
    }
    if(pid == 0){
    38b5:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
    38b9:	75 40                	jne    38fb <sbrktest+0x3bb>
      printf(stdout, "oops could read %x = %x\n", a, *a);
    38bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
    38be:	0f b6 00             	movzbl (%eax),%eax
    38c1:	0f be d0             	movsbl %al,%edx
    38c4:	a1 c4 67 00 00       	mov    0x67c4,%eax
    38c9:	89 54 24 0c          	mov    %edx,0xc(%esp)
    38cd:	8b 55 f4             	mov    -0xc(%ebp),%edx
    38d0:	89 54 24 08          	mov    %edx,0x8(%esp)
    38d4:	c7 44 24 04 51 5e 00 	movl   $0x5e51,0x4(%esp)
    38db:	00 
    38dc:	89 04 24             	mov    %eax,(%esp)
    38df:	e8 5b 0c 00 00       	call   453f <printf>
      kill(ppid);
    38e4:	8b 45 d0             	mov    -0x30(%ebp),%eax
    38e7:	89 04 24             	mov    %eax,(%esp)
    38ea:	e8 09 0b 00 00       	call   43f8 <kill>
      exit(EXIT_STATUS_DEFAULT);
    38ef:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    38f6:	e8 cd 0a 00 00       	call   43c8 <exit>
    }
    wait();
    38fb:	e8 d0 0a 00 00       	call   43d0 <wait>
    printf(stdout, "sbrk downsize failed, a %x c %x\n", a, c);
    exit(EXIT_STATUS_DEFAULT);
  }
  
  // can we read the kernel's memory?
  for(a = (char*)(KERNBASE); a < (char*) (KERNBASE+2000000); a += 50000){
    3900:	81 45 f4 50 c3 00 00 	addl   $0xc350,-0xc(%ebp)
    3907:	81 7d f4 7f 84 1e 80 	cmpl   $0x801e847f,-0xc(%ebp)
    390e:	0f 86 6a ff ff ff    	jbe    387e <sbrktest+0x33e>
    wait();
  }

  // if we run the system out of memory, does it clean up the last
  // failed allocation?
  if(pipe(fds) != 0){
    3914:	8d 45 c8             	lea    -0x38(%ebp),%eax
    3917:	89 04 24             	mov    %eax,(%esp)
    391a:	e8 b9 0a 00 00       	call   43d8 <pipe>
    391f:	85 c0                	test   %eax,%eax
    3921:	74 20                	je     3943 <sbrktest+0x403>
    printf(1, "pipe() failed\n");
    3923:	c7 44 24 04 76 4d 00 	movl   $0x4d76,0x4(%esp)
    392a:	00 
    392b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    3932:	e8 08 0c 00 00       	call   453f <printf>
    exit(EXIT_STATUS_DEFAULT);
    3937:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    393e:	e8 85 0a 00 00       	call   43c8 <exit>
  }
  for(i = 0; i < sizeof(pids)/sizeof(pids[0]); i++){
    3943:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    394a:	e9 89 00 00 00       	jmp    39d8 <sbrktest+0x498>
    if((pids[i] = fork()) == 0){
    394f:	e8 6c 0a 00 00       	call   43c0 <fork>
    3954:	8b 55 f0             	mov    -0x10(%ebp),%edx
    3957:	89 44 95 a0          	mov    %eax,-0x60(%ebp,%edx,4)
    395b:	8b 45 f0             	mov    -0x10(%ebp),%eax
    395e:	8b 44 85 a0          	mov    -0x60(%ebp,%eax,4),%eax
    3962:	85 c0                	test   %eax,%eax
    3964:	75 48                	jne    39ae <sbrktest+0x46e>
      // allocate a lot of memory
      sbrk(BIG - (uint)sbrk(0));
    3966:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    396d:	e8 de 0a 00 00       	call   4450 <sbrk>
    3972:	ba 00 00 40 06       	mov    $0x6400000,%edx
    3977:	89 d1                	mov    %edx,%ecx
    3979:	29 c1                	sub    %eax,%ecx
    397b:	89 c8                	mov    %ecx,%eax
    397d:	89 04 24             	mov    %eax,(%esp)
    3980:	e8 cb 0a 00 00       	call   4450 <sbrk>
      write(fds[1], "x", 1);
    3985:	8b 45 cc             	mov    -0x34(%ebp),%eax
    3988:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
    398f:	00 
    3990:	c7 44 24 04 db 4d 00 	movl   $0x4ddb,0x4(%esp)
    3997:	00 
    3998:	89 04 24             	mov    %eax,(%esp)
    399b:	e8 48 0a 00 00       	call   43e8 <write>
      // sit around until killed
      for(;;) sleep(1000);
    39a0:	c7 04 24 e8 03 00 00 	movl   $0x3e8,(%esp)
    39a7:	e8 ac 0a 00 00       	call   4458 <sleep>
    39ac:	eb f2                	jmp    39a0 <sbrktest+0x460>
    }
    if(pids[i] != -1)
    39ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
    39b1:	8b 44 85 a0          	mov    -0x60(%ebp,%eax,4),%eax
    39b5:	83 f8 ff             	cmp    $0xffffffff,%eax
    39b8:	74 1a                	je     39d4 <sbrktest+0x494>
      read(fds[0], &scratch, 1);
    39ba:	8b 45 c8             	mov    -0x38(%ebp),%eax
    39bd:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
    39c4:	00 
    39c5:	8d 55 9f             	lea    -0x61(%ebp),%edx
    39c8:	89 54 24 04          	mov    %edx,0x4(%esp)
    39cc:	89 04 24             	mov    %eax,(%esp)
    39cf:	e8 0c 0a 00 00       	call   43e0 <read>
  // failed allocation?
  if(pipe(fds) != 0){
    printf(1, "pipe() failed\n");
    exit(EXIT_STATUS_DEFAULT);
  }
  for(i = 0; i < sizeof(pids)/sizeof(pids[0]); i++){
    39d4:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
    39d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
    39db:	83 f8 09             	cmp    $0x9,%eax
    39de:	0f 86 6b ff ff ff    	jbe    394f <sbrktest+0x40f>
    if(pids[i] != -1)
      read(fds[0], &scratch, 1);
  }
  // if those failed allocations freed up the pages they did allocate,
  // we'll be able to allocate here
  c = sbrk(4096);
    39e4:	c7 04 24 00 10 00 00 	movl   $0x1000,(%esp)
    39eb:	e8 60 0a 00 00       	call   4450 <sbrk>
    39f0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(i = 0; i < sizeof(pids)/sizeof(pids[0]); i++){
    39f3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    39fa:	eb 27                	jmp    3a23 <sbrktest+0x4e3>
    if(pids[i] == -1)
    39fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
    39ff:	8b 44 85 a0          	mov    -0x60(%ebp,%eax,4),%eax
    3a03:	83 f8 ff             	cmp    $0xffffffff,%eax
    3a06:	74 16                	je     3a1e <sbrktest+0x4de>
      continue;
    kill(pids[i]);
    3a08:	8b 45 f0             	mov    -0x10(%ebp),%eax
    3a0b:	8b 44 85 a0          	mov    -0x60(%ebp,%eax,4),%eax
    3a0f:	89 04 24             	mov    %eax,(%esp)
    3a12:	e8 e1 09 00 00       	call   43f8 <kill>
    wait();
    3a17:	e8 b4 09 00 00       	call   43d0 <wait>
    3a1c:	eb 01                	jmp    3a1f <sbrktest+0x4df>
  // if those failed allocations freed up the pages they did allocate,
  // we'll be able to allocate here
  c = sbrk(4096);
  for(i = 0; i < sizeof(pids)/sizeof(pids[0]); i++){
    if(pids[i] == -1)
      continue;
    3a1e:	90                   	nop
      read(fds[0], &scratch, 1);
  }
  // if those failed allocations freed up the pages they did allocate,
  // we'll be able to allocate here
  c = sbrk(4096);
  for(i = 0; i < sizeof(pids)/sizeof(pids[0]); i++){
    3a1f:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
    3a23:	8b 45 f0             	mov    -0x10(%ebp),%eax
    3a26:	83 f8 09             	cmp    $0x9,%eax
    3a29:	76 d1                	jbe    39fc <sbrktest+0x4bc>
    if(pids[i] == -1)
      continue;
    kill(pids[i]);
    wait();
  }
  if(c == (char*)0xffffffff){
    3a2b:	83 7d e0 ff          	cmpl   $0xffffffff,-0x20(%ebp)
    3a2f:	75 21                	jne    3a52 <sbrktest+0x512>
    printf(stdout, "failed sbrk leaked memory\n");
    3a31:	a1 c4 67 00 00       	mov    0x67c4,%eax
    3a36:	c7 44 24 04 6a 5e 00 	movl   $0x5e6a,0x4(%esp)
    3a3d:	00 
    3a3e:	89 04 24             	mov    %eax,(%esp)
    3a41:	e8 f9 0a 00 00       	call   453f <printf>
    exit(EXIT_STATUS_DEFAULT);
    3a46:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    3a4d:	e8 76 09 00 00       	call   43c8 <exit>
  }

  if(sbrk(0) > oldbrk)
    3a52:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    3a59:	e8 f2 09 00 00       	call   4450 <sbrk>
    3a5e:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    3a61:	76 1d                	jbe    3a80 <sbrktest+0x540>
    sbrk(-(sbrk(0) - oldbrk));
    3a63:	8b 5d ec             	mov    -0x14(%ebp),%ebx
    3a66:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    3a6d:	e8 de 09 00 00       	call   4450 <sbrk>
    3a72:	89 da                	mov    %ebx,%edx
    3a74:	29 c2                	sub    %eax,%edx
    3a76:	89 d0                	mov    %edx,%eax
    3a78:	89 04 24             	mov    %eax,(%esp)
    3a7b:	e8 d0 09 00 00       	call   4450 <sbrk>

  printf(stdout, "sbrk test OK\n");
    3a80:	a1 c4 67 00 00       	mov    0x67c4,%eax
    3a85:	c7 44 24 04 85 5e 00 	movl   $0x5e85,0x4(%esp)
    3a8c:	00 
    3a8d:	89 04 24             	mov    %eax,(%esp)
    3a90:	e8 aa 0a 00 00       	call   453f <printf>
}
    3a95:	81 c4 84 00 00 00    	add    $0x84,%esp
    3a9b:	5b                   	pop    %ebx
    3a9c:	5d                   	pop    %ebp
    3a9d:	c3                   	ret    

00003a9e <validateint>:

void
validateint(int *p)
{
    3a9e:	55                   	push   %ebp
    3a9f:	89 e5                	mov    %esp,%ebp
    3aa1:	56                   	push   %esi
    3aa2:	53                   	push   %ebx
    3aa3:	83 ec 14             	sub    $0x14,%esp
  int res;
  asm("mov %%esp, %%ebx\n\t"
    3aa6:	c7 45 e4 0d 00 00 00 	movl   $0xd,-0x1c(%ebp)
    3aad:	8b 55 08             	mov    0x8(%ebp),%edx
    3ab0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    3ab3:	89 d1                	mov    %edx,%ecx
    3ab5:	89 e3                	mov    %esp,%ebx
    3ab7:	89 cc                	mov    %ecx,%esp
    3ab9:	cd 40                	int    $0x40
    3abb:	89 dc                	mov    %ebx,%esp
    3abd:	89 c6                	mov    %eax,%esi
    3abf:	89 75 f4             	mov    %esi,-0xc(%ebp)
      "int %2\n\t"
      "mov %%ebx, %%esp" :
      "=a" (res) :
      "a" (SYS_sleep), "n" (T_SYSCALL), "c" (p) :
      "ebx");
}
    3ac2:	83 c4 14             	add    $0x14,%esp
    3ac5:	5b                   	pop    %ebx
    3ac6:	5e                   	pop    %esi
    3ac7:	5d                   	pop    %ebp
    3ac8:	c3                   	ret    

00003ac9 <validatetest>:

void
validatetest(void)
{
    3ac9:	55                   	push   %ebp
    3aca:	89 e5                	mov    %esp,%ebp
    3acc:	83 ec 28             	sub    $0x28,%esp
  int hi, pid;
  uint p;

  printf(stdout, "validate test\n");
    3acf:	a1 c4 67 00 00       	mov    0x67c4,%eax
    3ad4:	c7 44 24 04 93 5e 00 	movl   $0x5e93,0x4(%esp)
    3adb:	00 
    3adc:	89 04 24             	mov    %eax,(%esp)
    3adf:	e8 5b 0a 00 00       	call   453f <printf>
  hi = 1100*1024;
    3ae4:	c7 45 f0 00 30 11 00 	movl   $0x113000,-0x10(%ebp)

  for(p = 0; p <= (uint)hi; p += 4096){
    3aeb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    3af2:	e9 8d 00 00 00       	jmp    3b84 <validatetest+0xbb>
    if((pid = fork()) == 0){
    3af7:	e8 c4 08 00 00       	call   43c0 <fork>
    3afc:	89 45 ec             	mov    %eax,-0x14(%ebp)
    3aff:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    3b03:	75 17                	jne    3b1c <validatetest+0x53>
      // try to crash the kernel by passing in a badly placed integer
      validateint((int*)p);
    3b05:	8b 45 f4             	mov    -0xc(%ebp),%eax
    3b08:	89 04 24             	mov    %eax,(%esp)
    3b0b:	e8 8e ff ff ff       	call   3a9e <validateint>
      exit(EXIT_STATUS_DEFAULT);
    3b10:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    3b17:	e8 ac 08 00 00       	call   43c8 <exit>
    }
    sleep(0);
    3b1c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    3b23:	e8 30 09 00 00       	call   4458 <sleep>
    sleep(0);
    3b28:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    3b2f:	e8 24 09 00 00       	call   4458 <sleep>
    kill(pid);
    3b34:	8b 45 ec             	mov    -0x14(%ebp),%eax
    3b37:	89 04 24             	mov    %eax,(%esp)
    3b3a:	e8 b9 08 00 00       	call   43f8 <kill>
    wait();
    3b3f:	e8 8c 08 00 00       	call   43d0 <wait>

    // try to crash the kernel by passing in a bad string pointer
    if(link("nosuchfile", (char*)p) != -1){
    3b44:	8b 45 f4             	mov    -0xc(%ebp),%eax
    3b47:	89 44 24 04          	mov    %eax,0x4(%esp)
    3b4b:	c7 04 24 a2 5e 00 00 	movl   $0x5ea2,(%esp)
    3b52:	e8 d1 08 00 00       	call   4428 <link>
    3b57:	83 f8 ff             	cmp    $0xffffffff,%eax
    3b5a:	74 21                	je     3b7d <validatetest+0xb4>
      printf(stdout, "link should not succeed\n");
    3b5c:	a1 c4 67 00 00       	mov    0x67c4,%eax
    3b61:	c7 44 24 04 ad 5e 00 	movl   $0x5ead,0x4(%esp)
    3b68:	00 
    3b69:	89 04 24             	mov    %eax,(%esp)
    3b6c:	e8 ce 09 00 00       	call   453f <printf>
      exit(EXIT_STATUS_DEFAULT);
    3b71:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    3b78:	e8 4b 08 00 00       	call   43c8 <exit>
  uint p;

  printf(stdout, "validate test\n");
  hi = 1100*1024;

  for(p = 0; p <= (uint)hi; p += 4096){
    3b7d:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    3b84:	8b 45 f0             	mov    -0x10(%ebp),%eax
    3b87:	3b 45 f4             	cmp    -0xc(%ebp),%eax
    3b8a:	0f 83 67 ff ff ff    	jae    3af7 <validatetest+0x2e>
      printf(stdout, "link should not succeed\n");
      exit(EXIT_STATUS_DEFAULT);
    }
  }

  printf(stdout, "validate ok\n");
    3b90:	a1 c4 67 00 00       	mov    0x67c4,%eax
    3b95:	c7 44 24 04 c6 5e 00 	movl   $0x5ec6,0x4(%esp)
    3b9c:	00 
    3b9d:	89 04 24             	mov    %eax,(%esp)
    3ba0:	e8 9a 09 00 00       	call   453f <printf>
}
    3ba5:	c9                   	leave  
    3ba6:	c3                   	ret    

00003ba7 <bsstest>:

// does unintialized data start out zero?
char uninit[10000];
void
bsstest(void)
{
    3ba7:	55                   	push   %ebp
    3ba8:	89 e5                	mov    %esp,%ebp
    3baa:	83 ec 28             	sub    $0x28,%esp
  int i;

  printf(stdout, "bss test\n");
    3bad:	a1 c4 67 00 00       	mov    0x67c4,%eax
    3bb2:	c7 44 24 04 d3 5e 00 	movl   $0x5ed3,0x4(%esp)
    3bb9:	00 
    3bba:	89 04 24             	mov    %eax,(%esp)
    3bbd:	e8 7d 09 00 00       	call   453f <printf>
  for(i = 0; i < sizeof(uninit); i++){
    3bc2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    3bc9:	eb 34                	jmp    3bff <bsstest+0x58>
    if(uninit[i] != '\0'){
    3bcb:	8b 45 f4             	mov    -0xc(%ebp),%eax
    3bce:	05 80 68 00 00       	add    $0x6880,%eax
    3bd3:	0f b6 00             	movzbl (%eax),%eax
    3bd6:	84 c0                	test   %al,%al
    3bd8:	74 21                	je     3bfb <bsstest+0x54>
      printf(stdout, "bss test failed\n");
    3bda:	a1 c4 67 00 00       	mov    0x67c4,%eax
    3bdf:	c7 44 24 04 dd 5e 00 	movl   $0x5edd,0x4(%esp)
    3be6:	00 
    3be7:	89 04 24             	mov    %eax,(%esp)
    3bea:	e8 50 09 00 00       	call   453f <printf>
      exit(EXIT_STATUS_DEFAULT);
    3bef:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    3bf6:	e8 cd 07 00 00       	call   43c8 <exit>
bsstest(void)
{
  int i;

  printf(stdout, "bss test\n");
  for(i = 0; i < sizeof(uninit); i++){
    3bfb:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    3bff:	8b 45 f4             	mov    -0xc(%ebp),%eax
    3c02:	3d 0f 27 00 00       	cmp    $0x270f,%eax
    3c07:	76 c2                	jbe    3bcb <bsstest+0x24>
    if(uninit[i] != '\0'){
      printf(stdout, "bss test failed\n");
      exit(EXIT_STATUS_DEFAULT);
    }
  }
  printf(stdout, "bss test ok\n");
    3c09:	a1 c4 67 00 00       	mov    0x67c4,%eax
    3c0e:	c7 44 24 04 ee 5e 00 	movl   $0x5eee,0x4(%esp)
    3c15:	00 
    3c16:	89 04 24             	mov    %eax,(%esp)
    3c19:	e8 21 09 00 00       	call   453f <printf>
}
    3c1e:	c9                   	leave  
    3c1f:	c3                   	ret    

00003c20 <bigargtest>:
// does exec return an error if the arguments
// are larger than a page? or does it write
// below the stack and wreck the instructions/data?
void
bigargtest(void)
{
    3c20:	55                   	push   %ebp
    3c21:	89 e5                	mov    %esp,%ebp
    3c23:	83 ec 28             	sub    $0x28,%esp
  int pid, fd;

  unlink("bigarg-ok");
    3c26:	c7 04 24 fb 5e 00 00 	movl   $0x5efb,(%esp)
    3c2d:	e8 e6 07 00 00       	call   4418 <unlink>
  pid = fork();
    3c32:	e8 89 07 00 00       	call   43c0 <fork>
    3c37:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(pid == 0){
    3c3a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    3c3e:	0f 85 97 00 00 00    	jne    3cdb <bigargtest+0xbb>
    static char *args[MAXARG];
    int i;
    for(i = 0; i < MAXARG-1; i++)
    3c44:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    3c4b:	eb 12                	jmp    3c5f <bigargtest+0x3f>
      args[i] = "bigargs test: failed\n                                                                                                                                                                                                       ";
    3c4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
    3c50:	c7 04 85 e0 67 00 00 	movl   $0x5f08,0x67e0(,%eax,4)
    3c57:	08 5f 00 00 
  unlink("bigarg-ok");
  pid = fork();
  if(pid == 0){
    static char *args[MAXARG];
    int i;
    for(i = 0; i < MAXARG-1; i++)
    3c5b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    3c5f:	83 7d f4 1e          	cmpl   $0x1e,-0xc(%ebp)
    3c63:	7e e8                	jle    3c4d <bigargtest+0x2d>
      args[i] = "bigargs test: failed\n                                                                                                                                                                                                       ";
    args[MAXARG-1] = 0;
    3c65:	c7 05 5c 68 00 00 00 	movl   $0x0,0x685c
    3c6c:	00 00 00 
    printf(stdout, "bigarg test\n");
    3c6f:	a1 c4 67 00 00       	mov    0x67c4,%eax
    3c74:	c7 44 24 04 e5 5f 00 	movl   $0x5fe5,0x4(%esp)
    3c7b:	00 
    3c7c:	89 04 24             	mov    %eax,(%esp)
    3c7f:	e8 bb 08 00 00       	call   453f <printf>
    exec("echo", args);
    3c84:	c7 44 24 04 e0 67 00 	movl   $0x67e0,0x4(%esp)
    3c8b:	00 
    3c8c:	c7 04 24 04 49 00 00 	movl   $0x4904,(%esp)
    3c93:	e8 68 07 00 00       	call   4400 <exec>
    printf(stdout, "bigarg test ok\n");
    3c98:	a1 c4 67 00 00       	mov    0x67c4,%eax
    3c9d:	c7 44 24 04 f2 5f 00 	movl   $0x5ff2,0x4(%esp)
    3ca4:	00 
    3ca5:	89 04 24             	mov    %eax,(%esp)
    3ca8:	e8 92 08 00 00       	call   453f <printf>
    fd = open("bigarg-ok", O_CREATE);
    3cad:	c7 44 24 04 00 02 00 	movl   $0x200,0x4(%esp)
    3cb4:	00 
    3cb5:	c7 04 24 fb 5e 00 00 	movl   $0x5efb,(%esp)
    3cbc:	e8 47 07 00 00       	call   4408 <open>
    3cc1:	89 45 ec             	mov    %eax,-0x14(%ebp)
    close(fd);
    3cc4:	8b 45 ec             	mov    -0x14(%ebp),%eax
    3cc7:	89 04 24             	mov    %eax,(%esp)
    3cca:	e8 21 07 00 00       	call   43f0 <close>
    exit(EXIT_STATUS_DEFAULT);
    3ccf:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    3cd6:	e8 ed 06 00 00       	call   43c8 <exit>
  } else if(pid < 0){
    3cdb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    3cdf:	79 21                	jns    3d02 <bigargtest+0xe2>
    printf(stdout, "bigargtest: fork failed\n");
    3ce1:	a1 c4 67 00 00       	mov    0x67c4,%eax
    3ce6:	c7 44 24 04 02 60 00 	movl   $0x6002,0x4(%esp)
    3ced:	00 
    3cee:	89 04 24             	mov    %eax,(%esp)
    3cf1:	e8 49 08 00 00       	call   453f <printf>
    exit(EXIT_STATUS_DEFAULT);
    3cf6:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    3cfd:	e8 c6 06 00 00       	call   43c8 <exit>
  }
  wait();
    3d02:	e8 c9 06 00 00       	call   43d0 <wait>
  fd = open("bigarg-ok", 0);
    3d07:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    3d0e:	00 
    3d0f:	c7 04 24 fb 5e 00 00 	movl   $0x5efb,(%esp)
    3d16:	e8 ed 06 00 00       	call   4408 <open>
    3d1b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(fd < 0){
    3d1e:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    3d22:	79 21                	jns    3d45 <bigargtest+0x125>
    printf(stdout, "bigarg test failed!\n");
    3d24:	a1 c4 67 00 00       	mov    0x67c4,%eax
    3d29:	c7 44 24 04 1b 60 00 	movl   $0x601b,0x4(%esp)
    3d30:	00 
    3d31:	89 04 24             	mov    %eax,(%esp)
    3d34:	e8 06 08 00 00       	call   453f <printf>
    exit(EXIT_STATUS_DEFAULT);
    3d39:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    3d40:	e8 83 06 00 00       	call   43c8 <exit>
  }
  close(fd);
    3d45:	8b 45 ec             	mov    -0x14(%ebp),%eax
    3d48:	89 04 24             	mov    %eax,(%esp)
    3d4b:	e8 a0 06 00 00       	call   43f0 <close>
  unlink("bigarg-ok");
    3d50:	c7 04 24 fb 5e 00 00 	movl   $0x5efb,(%esp)
    3d57:	e8 bc 06 00 00       	call   4418 <unlink>
}
    3d5c:	c9                   	leave  
    3d5d:	c3                   	ret    

00003d5e <fsfull>:

// what happens when the file system runs out of blocks?
// answer: balloc panics, so this test is not useful.
void
fsfull()
{
    3d5e:	55                   	push   %ebp
    3d5f:	89 e5                	mov    %esp,%ebp
    3d61:	53                   	push   %ebx
    3d62:	83 ec 74             	sub    $0x74,%esp
  int nfiles;
  int fsblocks = 0;
    3d65:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)

  printf(1, "fsfull test\n");
    3d6c:	c7 44 24 04 30 60 00 	movl   $0x6030,0x4(%esp)
    3d73:	00 
    3d74:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    3d7b:	e8 bf 07 00 00       	call   453f <printf>

  for(nfiles = 0; ; nfiles++){
    3d80:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    char name[64];
    name[0] = 'f';
    3d87:	c6 45 a4 66          	movb   $0x66,-0x5c(%ebp)
    name[1] = '0' + nfiles / 1000;
    3d8b:	8b 4d f4             	mov    -0xc(%ebp),%ecx
    3d8e:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
    3d93:	89 c8                	mov    %ecx,%eax
    3d95:	f7 ea                	imul   %edx
    3d97:	c1 fa 06             	sar    $0x6,%edx
    3d9a:	89 c8                	mov    %ecx,%eax
    3d9c:	c1 f8 1f             	sar    $0x1f,%eax
    3d9f:	89 d1                	mov    %edx,%ecx
    3da1:	29 c1                	sub    %eax,%ecx
    3da3:	89 c8                	mov    %ecx,%eax
    3da5:	83 c0 30             	add    $0x30,%eax
    3da8:	88 45 a5             	mov    %al,-0x5b(%ebp)
    name[2] = '0' + (nfiles % 1000) / 100;
    3dab:	8b 5d f4             	mov    -0xc(%ebp),%ebx
    3dae:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
    3db3:	89 d8                	mov    %ebx,%eax
    3db5:	f7 ea                	imul   %edx
    3db7:	c1 fa 06             	sar    $0x6,%edx
    3dba:	89 d8                	mov    %ebx,%eax
    3dbc:	c1 f8 1f             	sar    $0x1f,%eax
    3dbf:	89 d1                	mov    %edx,%ecx
    3dc1:	29 c1                	sub    %eax,%ecx
    3dc3:	69 c1 e8 03 00 00    	imul   $0x3e8,%ecx,%eax
    3dc9:	89 d9                	mov    %ebx,%ecx
    3dcb:	29 c1                	sub    %eax,%ecx
    3dcd:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
    3dd2:	89 c8                	mov    %ecx,%eax
    3dd4:	f7 ea                	imul   %edx
    3dd6:	c1 fa 05             	sar    $0x5,%edx
    3dd9:	89 c8                	mov    %ecx,%eax
    3ddb:	c1 f8 1f             	sar    $0x1f,%eax
    3dde:	89 d1                	mov    %edx,%ecx
    3de0:	29 c1                	sub    %eax,%ecx
    3de2:	89 c8                	mov    %ecx,%eax
    3de4:	83 c0 30             	add    $0x30,%eax
    3de7:	88 45 a6             	mov    %al,-0x5a(%ebp)
    name[3] = '0' + (nfiles % 100) / 10;
    3dea:	8b 5d f4             	mov    -0xc(%ebp),%ebx
    3ded:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
    3df2:	89 d8                	mov    %ebx,%eax
    3df4:	f7 ea                	imul   %edx
    3df6:	c1 fa 05             	sar    $0x5,%edx
    3df9:	89 d8                	mov    %ebx,%eax
    3dfb:	c1 f8 1f             	sar    $0x1f,%eax
    3dfe:	89 d1                	mov    %edx,%ecx
    3e00:	29 c1                	sub    %eax,%ecx
    3e02:	6b c1 64             	imul   $0x64,%ecx,%eax
    3e05:	89 d9                	mov    %ebx,%ecx
    3e07:	29 c1                	sub    %eax,%ecx
    3e09:	ba 67 66 66 66       	mov    $0x66666667,%edx
    3e0e:	89 c8                	mov    %ecx,%eax
    3e10:	f7 ea                	imul   %edx
    3e12:	c1 fa 02             	sar    $0x2,%edx
    3e15:	89 c8                	mov    %ecx,%eax
    3e17:	c1 f8 1f             	sar    $0x1f,%eax
    3e1a:	89 d1                	mov    %edx,%ecx
    3e1c:	29 c1                	sub    %eax,%ecx
    3e1e:	89 c8                	mov    %ecx,%eax
    3e20:	83 c0 30             	add    $0x30,%eax
    3e23:	88 45 a7             	mov    %al,-0x59(%ebp)
    name[4] = '0' + (nfiles % 10);
    3e26:	8b 4d f4             	mov    -0xc(%ebp),%ecx
    3e29:	ba 67 66 66 66       	mov    $0x66666667,%edx
    3e2e:	89 c8                	mov    %ecx,%eax
    3e30:	f7 ea                	imul   %edx
    3e32:	c1 fa 02             	sar    $0x2,%edx
    3e35:	89 c8                	mov    %ecx,%eax
    3e37:	c1 f8 1f             	sar    $0x1f,%eax
    3e3a:	29 c2                	sub    %eax,%edx
    3e3c:	89 d0                	mov    %edx,%eax
    3e3e:	c1 e0 02             	shl    $0x2,%eax
    3e41:	01 d0                	add    %edx,%eax
    3e43:	01 c0                	add    %eax,%eax
    3e45:	89 ca                	mov    %ecx,%edx
    3e47:	29 c2                	sub    %eax,%edx
    3e49:	89 d0                	mov    %edx,%eax
    3e4b:	83 c0 30             	add    $0x30,%eax
    3e4e:	88 45 a8             	mov    %al,-0x58(%ebp)
    name[5] = '\0';
    3e51:	c6 45 a9 00          	movb   $0x0,-0x57(%ebp)
    printf(1, "writing %s\n", name);
    3e55:	8d 45 a4             	lea    -0x5c(%ebp),%eax
    3e58:	89 44 24 08          	mov    %eax,0x8(%esp)
    3e5c:	c7 44 24 04 3d 60 00 	movl   $0x603d,0x4(%esp)
    3e63:	00 
    3e64:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    3e6b:	e8 cf 06 00 00       	call   453f <printf>
    int fd = open(name, O_CREATE|O_RDWR);
    3e70:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
    3e77:	00 
    3e78:	8d 45 a4             	lea    -0x5c(%ebp),%eax
    3e7b:	89 04 24             	mov    %eax,(%esp)
    3e7e:	e8 85 05 00 00       	call   4408 <open>
    3e83:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(fd < 0){
    3e86:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
    3e8a:	79 1d                	jns    3ea9 <fsfull+0x14b>
      printf(1, "open %s failed\n", name);
    3e8c:	8d 45 a4             	lea    -0x5c(%ebp),%eax
    3e8f:	89 44 24 08          	mov    %eax,0x8(%esp)
    3e93:	c7 44 24 04 49 60 00 	movl   $0x6049,0x4(%esp)
    3e9a:	00 
    3e9b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    3ea2:	e8 98 06 00 00       	call   453f <printf>
      break;
    3ea7:	eb 71                	jmp    3f1a <fsfull+0x1bc>
    }
    int total = 0;
    3ea9:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
    while(1){
      int cc = write(fd, buf, 512);
    3eb0:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
    3eb7:	00 
    3eb8:	c7 44 24 04 a0 8f 00 	movl   $0x8fa0,0x4(%esp)
    3ebf:	00 
    3ec0:	8b 45 e8             	mov    -0x18(%ebp),%eax
    3ec3:	89 04 24             	mov    %eax,(%esp)
    3ec6:	e8 1d 05 00 00       	call   43e8 <write>
    3ecb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      if(cc < 512)
    3ece:	81 7d e4 ff 01 00 00 	cmpl   $0x1ff,-0x1c(%ebp)
    3ed5:	7e 0c                	jle    3ee3 <fsfull+0x185>
        break;
      total += cc;
    3ed7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    3eda:	01 45 ec             	add    %eax,-0x14(%ebp)
      fsblocks++;
    3edd:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
    }
    3ee1:	eb cd                	jmp    3eb0 <fsfull+0x152>
    }
    int total = 0;
    while(1){
      int cc = write(fd, buf, 512);
      if(cc < 512)
        break;
    3ee3:	90                   	nop
      total += cc;
      fsblocks++;
    }
    printf(1, "wrote %d bytes\n", total);
    3ee4:	8b 45 ec             	mov    -0x14(%ebp),%eax
    3ee7:	89 44 24 08          	mov    %eax,0x8(%esp)
    3eeb:	c7 44 24 04 59 60 00 	movl   $0x6059,0x4(%esp)
    3ef2:	00 
    3ef3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    3efa:	e8 40 06 00 00       	call   453f <printf>
    close(fd);
    3eff:	8b 45 e8             	mov    -0x18(%ebp),%eax
    3f02:	89 04 24             	mov    %eax,(%esp)
    3f05:	e8 e6 04 00 00       	call   43f0 <close>
    if(total == 0)
    3f0a:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    3f0e:	74 09                	je     3f19 <fsfull+0x1bb>
  int nfiles;
  int fsblocks = 0;

  printf(1, "fsfull test\n");

  for(nfiles = 0; ; nfiles++){
    3f10:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    }
    printf(1, "wrote %d bytes\n", total);
    close(fd);
    if(total == 0)
      break;
  }
    3f14:	e9 6e fe ff ff       	jmp    3d87 <fsfull+0x29>
      fsblocks++;
    }
    printf(1, "wrote %d bytes\n", total);
    close(fd);
    if(total == 0)
      break;
    3f19:	90                   	nop
  }

  while(nfiles >= 0){
    3f1a:	e9 dd 00 00 00       	jmp    3ffc <fsfull+0x29e>
    char name[64];
    name[0] = 'f';
    3f1f:	c6 45 a4 66          	movb   $0x66,-0x5c(%ebp)
    name[1] = '0' + nfiles / 1000;
    3f23:	8b 4d f4             	mov    -0xc(%ebp),%ecx
    3f26:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
    3f2b:	89 c8                	mov    %ecx,%eax
    3f2d:	f7 ea                	imul   %edx
    3f2f:	c1 fa 06             	sar    $0x6,%edx
    3f32:	89 c8                	mov    %ecx,%eax
    3f34:	c1 f8 1f             	sar    $0x1f,%eax
    3f37:	89 d1                	mov    %edx,%ecx
    3f39:	29 c1                	sub    %eax,%ecx
    3f3b:	89 c8                	mov    %ecx,%eax
    3f3d:	83 c0 30             	add    $0x30,%eax
    3f40:	88 45 a5             	mov    %al,-0x5b(%ebp)
    name[2] = '0' + (nfiles % 1000) / 100;
    3f43:	8b 5d f4             	mov    -0xc(%ebp),%ebx
    3f46:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
    3f4b:	89 d8                	mov    %ebx,%eax
    3f4d:	f7 ea                	imul   %edx
    3f4f:	c1 fa 06             	sar    $0x6,%edx
    3f52:	89 d8                	mov    %ebx,%eax
    3f54:	c1 f8 1f             	sar    $0x1f,%eax
    3f57:	89 d1                	mov    %edx,%ecx
    3f59:	29 c1                	sub    %eax,%ecx
    3f5b:	69 c1 e8 03 00 00    	imul   $0x3e8,%ecx,%eax
    3f61:	89 d9                	mov    %ebx,%ecx
    3f63:	29 c1                	sub    %eax,%ecx
    3f65:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
    3f6a:	89 c8                	mov    %ecx,%eax
    3f6c:	f7 ea                	imul   %edx
    3f6e:	c1 fa 05             	sar    $0x5,%edx
    3f71:	89 c8                	mov    %ecx,%eax
    3f73:	c1 f8 1f             	sar    $0x1f,%eax
    3f76:	89 d1                	mov    %edx,%ecx
    3f78:	29 c1                	sub    %eax,%ecx
    3f7a:	89 c8                	mov    %ecx,%eax
    3f7c:	83 c0 30             	add    $0x30,%eax
    3f7f:	88 45 a6             	mov    %al,-0x5a(%ebp)
    name[3] = '0' + (nfiles % 100) / 10;
    3f82:	8b 5d f4             	mov    -0xc(%ebp),%ebx
    3f85:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
    3f8a:	89 d8                	mov    %ebx,%eax
    3f8c:	f7 ea                	imul   %edx
    3f8e:	c1 fa 05             	sar    $0x5,%edx
    3f91:	89 d8                	mov    %ebx,%eax
    3f93:	c1 f8 1f             	sar    $0x1f,%eax
    3f96:	89 d1                	mov    %edx,%ecx
    3f98:	29 c1                	sub    %eax,%ecx
    3f9a:	6b c1 64             	imul   $0x64,%ecx,%eax
    3f9d:	89 d9                	mov    %ebx,%ecx
    3f9f:	29 c1                	sub    %eax,%ecx
    3fa1:	ba 67 66 66 66       	mov    $0x66666667,%edx
    3fa6:	89 c8                	mov    %ecx,%eax
    3fa8:	f7 ea                	imul   %edx
    3faa:	c1 fa 02             	sar    $0x2,%edx
    3fad:	89 c8                	mov    %ecx,%eax
    3faf:	c1 f8 1f             	sar    $0x1f,%eax
    3fb2:	89 d1                	mov    %edx,%ecx
    3fb4:	29 c1                	sub    %eax,%ecx
    3fb6:	89 c8                	mov    %ecx,%eax
    3fb8:	83 c0 30             	add    $0x30,%eax
    3fbb:	88 45 a7             	mov    %al,-0x59(%ebp)
    name[4] = '0' + (nfiles % 10);
    3fbe:	8b 4d f4             	mov    -0xc(%ebp),%ecx
    3fc1:	ba 67 66 66 66       	mov    $0x66666667,%edx
    3fc6:	89 c8                	mov    %ecx,%eax
    3fc8:	f7 ea                	imul   %edx
    3fca:	c1 fa 02             	sar    $0x2,%edx
    3fcd:	89 c8                	mov    %ecx,%eax
    3fcf:	c1 f8 1f             	sar    $0x1f,%eax
    3fd2:	29 c2                	sub    %eax,%edx
    3fd4:	89 d0                	mov    %edx,%eax
    3fd6:	c1 e0 02             	shl    $0x2,%eax
    3fd9:	01 d0                	add    %edx,%eax
    3fdb:	01 c0                	add    %eax,%eax
    3fdd:	89 ca                	mov    %ecx,%edx
    3fdf:	29 c2                	sub    %eax,%edx
    3fe1:	89 d0                	mov    %edx,%eax
    3fe3:	83 c0 30             	add    $0x30,%eax
    3fe6:	88 45 a8             	mov    %al,-0x58(%ebp)
    name[5] = '\0';
    3fe9:	c6 45 a9 00          	movb   $0x0,-0x57(%ebp)
    unlink(name);
    3fed:	8d 45 a4             	lea    -0x5c(%ebp),%eax
    3ff0:	89 04 24             	mov    %eax,(%esp)
    3ff3:	e8 20 04 00 00       	call   4418 <unlink>
    nfiles--;
    3ff8:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
    close(fd);
    if(total == 0)
      break;
  }

  while(nfiles >= 0){
    3ffc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    4000:	0f 89 19 ff ff ff    	jns    3f1f <fsfull+0x1c1>
    name[5] = '\0';
    unlink(name);
    nfiles--;
  }

  printf(1, "fsfull test finished\n");
    4006:	c7 44 24 04 69 60 00 	movl   $0x6069,0x4(%esp)
    400d:	00 
    400e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    4015:	e8 25 05 00 00       	call   453f <printf>
}
    401a:	83 c4 74             	add    $0x74,%esp
    401d:	5b                   	pop    %ebx
    401e:	5d                   	pop    %ebp
    401f:	c3                   	ret    

00004020 <rand>:

unsigned long randstate = 1;
unsigned int
rand()
{
    4020:	55                   	push   %ebp
    4021:	89 e5                	mov    %esp,%ebp
  randstate = randstate * 1664525 + 1013904223;
    4023:	a1 c8 67 00 00       	mov    0x67c8,%eax
    4028:	69 c0 0d 66 19 00    	imul   $0x19660d,%eax,%eax
    402e:	05 5f f3 6e 3c       	add    $0x3c6ef35f,%eax
    4033:	a3 c8 67 00 00       	mov    %eax,0x67c8
  return randstate;
    4038:	a1 c8 67 00 00       	mov    0x67c8,%eax
}
    403d:	5d                   	pop    %ebp
    403e:	c3                   	ret    

0000403f <main>:

int
main(int argc, char *argv[])
{
    403f:	55                   	push   %ebp
    4040:	89 e5                	mov    %esp,%ebp
    4042:	83 e4 f0             	and    $0xfffffff0,%esp
    4045:	83 ec 10             	sub    $0x10,%esp
  printf(1, "usertests starting\n");
    4048:	c7 44 24 04 7f 60 00 	movl   $0x607f,0x4(%esp)
    404f:	00 
    4050:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    4057:	e8 e3 04 00 00       	call   453f <printf>

  if(open("usertests.ran", 0) >= 0){
    405c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    4063:	00 
    4064:	c7 04 24 93 60 00 00 	movl   $0x6093,(%esp)
    406b:	e8 98 03 00 00       	call   4408 <open>
    4070:	85 c0                	test   %eax,%eax
    4072:	78 20                	js     4094 <main+0x55>
    printf(1, "already ran user tests -- rebuild fs.img\n");
    4074:	c7 44 24 04 a4 60 00 	movl   $0x60a4,0x4(%esp)
    407b:	00 
    407c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    4083:	e8 b7 04 00 00       	call   453f <printf>
    exit(EXIT_STATUS_DEFAULT);
    4088:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    408f:	e8 34 03 00 00       	call   43c8 <exit>
  }
  close(open("usertests.ran", O_CREATE));
    4094:	c7 44 24 04 00 02 00 	movl   $0x200,0x4(%esp)
    409b:	00 
    409c:	c7 04 24 93 60 00 00 	movl   $0x6093,(%esp)
    40a3:	e8 60 03 00 00       	call   4408 <open>
    40a8:	89 04 24             	mov    %eax,(%esp)
    40ab:	e8 40 03 00 00       	call   43f0 <close>

  createdelete();
    40b0:	e8 26 d3 ff ff       	call   13db <createdelete>
  linkunlink();
    40b5:	e8 30 de ff ff       	call   1eea <linkunlink>
  concreate();
    40ba:	e8 45 da ff ff       	call   1b04 <concreate>
  fourfiles();
    40bf:	e8 85 d0 ff ff       	call   1149 <fourfiles>
  sharedfd();
    40c4:	e8 78 ce ff ff       	call   f41 <sharedfd>

  bigargtest();
    40c9:	e8 52 fb ff ff       	call   3c20 <bigargtest>
  bigwrite();
    40ce:	e8 24 e9 ff ff       	call   29f7 <bigwrite>
  bigargtest();
    40d3:	e8 48 fb ff ff       	call   3c20 <bigargtest>
  bsstest();
    40d8:	e8 ca fa ff ff       	call   3ba7 <bsstest>
  sbrktest();
    40dd:	e8 5e f4 ff ff       	call   3540 <sbrktest>
  validatetest();
    40e2:	e8 e2 f9 ff ff       	call   3ac9 <validatetest>

  opentest();
    40e7:	e8 3d c2 ff ff       	call   329 <opentest>
  writetest();
    40ec:	e8 f1 c2 ff ff       	call   3e2 <writetest>
  writetest1();
    40f1:	e8 2b c5 ff ff       	call   621 <writetest1>
  createtest();
    40f6:	e8 60 c7 ff ff       	call   85b <createtest>

  openiputtest();
    40fb:	e8 05 c1 ff ff       	call   205 <openiputtest>
  exitiputtest();
    4100:	e8 f1 bf ff ff       	call   f6 <exitiputtest>
  iputtest();
    4105:	e8 f6 be ff ff       	call   0 <iputtest>

  mem();
    410a:	e8 3f cd ff ff       	call   e4e <mem>
  pipe1();
    410f:	e8 4b c9 ff ff       	call   a5f <pipe1>
  preempt();
    4114:	e8 57 cb ff ff       	call   c70 <preempt>
  exitwait();
    4119:	e8 ab cc ff ff       	call   dc9 <exitwait>

  rmdot();
    411e:	e8 c4 ed ff ff       	call   2ee7 <rmdot>
  fourteen();
    4123:	e8 3f ec ff ff       	call   2d67 <fourteen>
  bigfile();
    4128:	e8 e0 e9 ff ff       	call   2b0d <bigfile>
  subdir();
    412d:	e8 7c e0 ff ff       	call   21ae <subdir>
  linktest();
    4132:	e8 45 d7 ff ff       	call   187c <linktest>
  unlinkread();
    4137:	e8 41 d5 ff ff       	call   167d <unlinkread>
  dirfile();
    413c:	e8 56 ef ff ff       	call   3097 <dirfile>
  iref();
    4141:	e8 d9 f1 ff ff       	call   331f <iref>
  forktest();
    4146:	e8 06 f3 ff ff       	call   3451 <forktest>
  bigdir(); // slow
    414b:	e8 d4 de ff ff       	call   2024 <bigdir>
  exectest();
    4150:	e8 b4 c8 ff ff       	call   a09 <exectest>

  exit(EXIT_STATUS_DEFAULT);
    4155:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    415c:	e8 67 02 00 00       	call   43c8 <exit>
    4161:	90                   	nop
    4162:	90                   	nop
    4163:	90                   	nop

00004164 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
    4164:	55                   	push   %ebp
    4165:	89 e5                	mov    %esp,%ebp
    4167:	57                   	push   %edi
    4168:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
    4169:	8b 4d 08             	mov    0x8(%ebp),%ecx
    416c:	8b 55 10             	mov    0x10(%ebp),%edx
    416f:	8b 45 0c             	mov    0xc(%ebp),%eax
    4172:	89 cb                	mov    %ecx,%ebx
    4174:	89 df                	mov    %ebx,%edi
    4176:	89 d1                	mov    %edx,%ecx
    4178:	fc                   	cld    
    4179:	f3 aa                	rep stos %al,%es:(%edi)
    417b:	89 ca                	mov    %ecx,%edx
    417d:	89 fb                	mov    %edi,%ebx
    417f:	89 5d 08             	mov    %ebx,0x8(%ebp)
    4182:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
    4185:	5b                   	pop    %ebx
    4186:	5f                   	pop    %edi
    4187:	5d                   	pop    %ebp
    4188:	c3                   	ret    

00004189 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
    4189:	55                   	push   %ebp
    418a:	89 e5                	mov    %esp,%ebp
    418c:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
    418f:	8b 45 08             	mov    0x8(%ebp),%eax
    4192:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
    4195:	90                   	nop
    4196:	8b 45 0c             	mov    0xc(%ebp),%eax
    4199:	0f b6 10             	movzbl (%eax),%edx
    419c:	8b 45 08             	mov    0x8(%ebp),%eax
    419f:	88 10                	mov    %dl,(%eax)
    41a1:	8b 45 08             	mov    0x8(%ebp),%eax
    41a4:	0f b6 00             	movzbl (%eax),%eax
    41a7:	84 c0                	test   %al,%al
    41a9:	0f 95 c0             	setne  %al
    41ac:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    41b0:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
    41b4:	84 c0                	test   %al,%al
    41b6:	75 de                	jne    4196 <strcpy+0xd>
    ;
  return os;
    41b8:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
    41bb:	c9                   	leave  
    41bc:	c3                   	ret    

000041bd <strcmp>:

int
strcmp(const char *p, const char *q)
{
    41bd:	55                   	push   %ebp
    41be:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
    41c0:	eb 08                	jmp    41ca <strcmp+0xd>
    p++, q++;
    41c2:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    41c6:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
    41ca:	8b 45 08             	mov    0x8(%ebp),%eax
    41cd:	0f b6 00             	movzbl (%eax),%eax
    41d0:	84 c0                	test   %al,%al
    41d2:	74 10                	je     41e4 <strcmp+0x27>
    41d4:	8b 45 08             	mov    0x8(%ebp),%eax
    41d7:	0f b6 10             	movzbl (%eax),%edx
    41da:	8b 45 0c             	mov    0xc(%ebp),%eax
    41dd:	0f b6 00             	movzbl (%eax),%eax
    41e0:	38 c2                	cmp    %al,%dl
    41e2:	74 de                	je     41c2 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
    41e4:	8b 45 08             	mov    0x8(%ebp),%eax
    41e7:	0f b6 00             	movzbl (%eax),%eax
    41ea:	0f b6 d0             	movzbl %al,%edx
    41ed:	8b 45 0c             	mov    0xc(%ebp),%eax
    41f0:	0f b6 00             	movzbl (%eax),%eax
    41f3:	0f b6 c0             	movzbl %al,%eax
    41f6:	89 d1                	mov    %edx,%ecx
    41f8:	29 c1                	sub    %eax,%ecx
    41fa:	89 c8                	mov    %ecx,%eax
}
    41fc:	5d                   	pop    %ebp
    41fd:	c3                   	ret    

000041fe <strlen>:

uint
strlen(char *s)
{
    41fe:	55                   	push   %ebp
    41ff:	89 e5                	mov    %esp,%ebp
    4201:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
    4204:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    420b:	eb 04                	jmp    4211 <strlen+0x13>
    420d:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
    4211:	8b 45 fc             	mov    -0x4(%ebp),%eax
    4214:	03 45 08             	add    0x8(%ebp),%eax
    4217:	0f b6 00             	movzbl (%eax),%eax
    421a:	84 c0                	test   %al,%al
    421c:	75 ef                	jne    420d <strlen+0xf>
    ;
  return n;
    421e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
    4221:	c9                   	leave  
    4222:	c3                   	ret    

00004223 <memset>:

void*
memset(void *dst, int c, uint n)
{
    4223:	55                   	push   %ebp
    4224:	89 e5                	mov    %esp,%ebp
    4226:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
    4229:	8b 45 10             	mov    0x10(%ebp),%eax
    422c:	89 44 24 08          	mov    %eax,0x8(%esp)
    4230:	8b 45 0c             	mov    0xc(%ebp),%eax
    4233:	89 44 24 04          	mov    %eax,0x4(%esp)
    4237:	8b 45 08             	mov    0x8(%ebp),%eax
    423a:	89 04 24             	mov    %eax,(%esp)
    423d:	e8 22 ff ff ff       	call   4164 <stosb>
  return dst;
    4242:	8b 45 08             	mov    0x8(%ebp),%eax
}
    4245:	c9                   	leave  
    4246:	c3                   	ret    

00004247 <strchr>:

char*
strchr(const char *s, char c)
{
    4247:	55                   	push   %ebp
    4248:	89 e5                	mov    %esp,%ebp
    424a:	83 ec 04             	sub    $0x4,%esp
    424d:	8b 45 0c             	mov    0xc(%ebp),%eax
    4250:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
    4253:	eb 14                	jmp    4269 <strchr+0x22>
    if(*s == c)
    4255:	8b 45 08             	mov    0x8(%ebp),%eax
    4258:	0f b6 00             	movzbl (%eax),%eax
    425b:	3a 45 fc             	cmp    -0x4(%ebp),%al
    425e:	75 05                	jne    4265 <strchr+0x1e>
      return (char*)s;
    4260:	8b 45 08             	mov    0x8(%ebp),%eax
    4263:	eb 13                	jmp    4278 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
    4265:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    4269:	8b 45 08             	mov    0x8(%ebp),%eax
    426c:	0f b6 00             	movzbl (%eax),%eax
    426f:	84 c0                	test   %al,%al
    4271:	75 e2                	jne    4255 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
    4273:	b8 00 00 00 00       	mov    $0x0,%eax
}
    4278:	c9                   	leave  
    4279:	c3                   	ret    

0000427a <gets>:

char*
gets(char *buf, int max)
{
    427a:	55                   	push   %ebp
    427b:	89 e5                	mov    %esp,%ebp
    427d:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    4280:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    4287:	eb 44                	jmp    42cd <gets+0x53>
    cc = read(0, &c, 1);
    4289:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
    4290:	00 
    4291:	8d 45 ef             	lea    -0x11(%ebp),%eax
    4294:	89 44 24 04          	mov    %eax,0x4(%esp)
    4298:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    429f:	e8 3c 01 00 00       	call   43e0 <read>
    42a4:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
    42a7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    42ab:	7e 2d                	jle    42da <gets+0x60>
      break;
    buf[i++] = c;
    42ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
    42b0:	03 45 08             	add    0x8(%ebp),%eax
    42b3:	0f b6 55 ef          	movzbl -0x11(%ebp),%edx
    42b7:	88 10                	mov    %dl,(%eax)
    42b9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(c == '\n' || c == '\r')
    42bd:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    42c1:	3c 0a                	cmp    $0xa,%al
    42c3:	74 16                	je     42db <gets+0x61>
    42c5:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    42c9:	3c 0d                	cmp    $0xd,%al
    42cb:	74 0e                	je     42db <gets+0x61>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    42cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
    42d0:	83 c0 01             	add    $0x1,%eax
    42d3:	3b 45 0c             	cmp    0xc(%ebp),%eax
    42d6:	7c b1                	jl     4289 <gets+0xf>
    42d8:	eb 01                	jmp    42db <gets+0x61>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    42da:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
    42db:	8b 45 f4             	mov    -0xc(%ebp),%eax
    42de:	03 45 08             	add    0x8(%ebp),%eax
    42e1:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
    42e4:	8b 45 08             	mov    0x8(%ebp),%eax
}
    42e7:	c9                   	leave  
    42e8:	c3                   	ret    

000042e9 <stat>:

int
stat(char *n, struct stat *st)
{
    42e9:	55                   	push   %ebp
    42ea:	89 e5                	mov    %esp,%ebp
    42ec:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
    42ef:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    42f6:	00 
    42f7:	8b 45 08             	mov    0x8(%ebp),%eax
    42fa:	89 04 24             	mov    %eax,(%esp)
    42fd:	e8 06 01 00 00       	call   4408 <open>
    4302:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
    4305:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    4309:	79 07                	jns    4312 <stat+0x29>
    return -1;
    430b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    4310:	eb 23                	jmp    4335 <stat+0x4c>
  r = fstat(fd, st);
    4312:	8b 45 0c             	mov    0xc(%ebp),%eax
    4315:	89 44 24 04          	mov    %eax,0x4(%esp)
    4319:	8b 45 f4             	mov    -0xc(%ebp),%eax
    431c:	89 04 24             	mov    %eax,(%esp)
    431f:	e8 fc 00 00 00       	call   4420 <fstat>
    4324:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
    4327:	8b 45 f4             	mov    -0xc(%ebp),%eax
    432a:	89 04 24             	mov    %eax,(%esp)
    432d:	e8 be 00 00 00       	call   43f0 <close>
  return r;
    4332:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
    4335:	c9                   	leave  
    4336:	c3                   	ret    

00004337 <atoi>:

int
atoi(const char *s)
{
    4337:	55                   	push   %ebp
    4338:	89 e5                	mov    %esp,%ebp
    433a:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
    433d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
    4344:	eb 23                	jmp    4369 <atoi+0x32>
    n = n*10 + *s++ - '0';
    4346:	8b 55 fc             	mov    -0x4(%ebp),%edx
    4349:	89 d0                	mov    %edx,%eax
    434b:	c1 e0 02             	shl    $0x2,%eax
    434e:	01 d0                	add    %edx,%eax
    4350:	01 c0                	add    %eax,%eax
    4352:	89 c2                	mov    %eax,%edx
    4354:	8b 45 08             	mov    0x8(%ebp),%eax
    4357:	0f b6 00             	movzbl (%eax),%eax
    435a:	0f be c0             	movsbl %al,%eax
    435d:	01 d0                	add    %edx,%eax
    435f:	83 e8 30             	sub    $0x30,%eax
    4362:	89 45 fc             	mov    %eax,-0x4(%ebp)
    4365:	83 45 08 01          	addl   $0x1,0x8(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
    4369:	8b 45 08             	mov    0x8(%ebp),%eax
    436c:	0f b6 00             	movzbl (%eax),%eax
    436f:	3c 2f                	cmp    $0x2f,%al
    4371:	7e 0a                	jle    437d <atoi+0x46>
    4373:	8b 45 08             	mov    0x8(%ebp),%eax
    4376:	0f b6 00             	movzbl (%eax),%eax
    4379:	3c 39                	cmp    $0x39,%al
    437b:	7e c9                	jle    4346 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
    437d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
    4380:	c9                   	leave  
    4381:	c3                   	ret    

00004382 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
    4382:	55                   	push   %ebp
    4383:	89 e5                	mov    %esp,%ebp
    4385:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
    4388:	8b 45 08             	mov    0x8(%ebp),%eax
    438b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
    438e:	8b 45 0c             	mov    0xc(%ebp),%eax
    4391:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
    4394:	eb 13                	jmp    43a9 <memmove+0x27>
    *dst++ = *src++;
    4396:	8b 45 f8             	mov    -0x8(%ebp),%eax
    4399:	0f b6 10             	movzbl (%eax),%edx
    439c:	8b 45 fc             	mov    -0x4(%ebp),%eax
    439f:	88 10                	mov    %dl,(%eax)
    43a1:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
    43a5:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
    43a9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
    43ad:	0f 9f c0             	setg   %al
    43b0:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    43b4:	84 c0                	test   %al,%al
    43b6:	75 de                	jne    4396 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
    43b8:	8b 45 08             	mov    0x8(%ebp),%eax
}
    43bb:	c9                   	leave  
    43bc:	c3                   	ret    
    43bd:	90                   	nop
    43be:	90                   	nop
    43bf:	90                   	nop

000043c0 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
    43c0:	b8 01 00 00 00       	mov    $0x1,%eax
    43c5:	cd 40                	int    $0x40
    43c7:	c3                   	ret    

000043c8 <exit>:
SYSCALL(exit)
    43c8:	b8 02 00 00 00       	mov    $0x2,%eax
    43cd:	cd 40                	int    $0x40
    43cf:	c3                   	ret    

000043d0 <wait>:
SYSCALL(wait)
    43d0:	b8 03 00 00 00       	mov    $0x3,%eax
    43d5:	cd 40                	int    $0x40
    43d7:	c3                   	ret    

000043d8 <pipe>:
SYSCALL(pipe)
    43d8:	b8 04 00 00 00       	mov    $0x4,%eax
    43dd:	cd 40                	int    $0x40
    43df:	c3                   	ret    

000043e0 <read>:
SYSCALL(read)
    43e0:	b8 05 00 00 00       	mov    $0x5,%eax
    43e5:	cd 40                	int    $0x40
    43e7:	c3                   	ret    

000043e8 <write>:
SYSCALL(write)
    43e8:	b8 10 00 00 00       	mov    $0x10,%eax
    43ed:	cd 40                	int    $0x40
    43ef:	c3                   	ret    

000043f0 <close>:
SYSCALL(close)
    43f0:	b8 15 00 00 00       	mov    $0x15,%eax
    43f5:	cd 40                	int    $0x40
    43f7:	c3                   	ret    

000043f8 <kill>:
SYSCALL(kill)
    43f8:	b8 06 00 00 00       	mov    $0x6,%eax
    43fd:	cd 40                	int    $0x40
    43ff:	c3                   	ret    

00004400 <exec>:
SYSCALL(exec)
    4400:	b8 07 00 00 00       	mov    $0x7,%eax
    4405:	cd 40                	int    $0x40
    4407:	c3                   	ret    

00004408 <open>:
SYSCALL(open)
    4408:	b8 0f 00 00 00       	mov    $0xf,%eax
    440d:	cd 40                	int    $0x40
    440f:	c3                   	ret    

00004410 <mknod>:
SYSCALL(mknod)
    4410:	b8 11 00 00 00       	mov    $0x11,%eax
    4415:	cd 40                	int    $0x40
    4417:	c3                   	ret    

00004418 <unlink>:
SYSCALL(unlink)
    4418:	b8 12 00 00 00       	mov    $0x12,%eax
    441d:	cd 40                	int    $0x40
    441f:	c3                   	ret    

00004420 <fstat>:
SYSCALL(fstat)
    4420:	b8 08 00 00 00       	mov    $0x8,%eax
    4425:	cd 40                	int    $0x40
    4427:	c3                   	ret    

00004428 <link>:
SYSCALL(link)
    4428:	b8 13 00 00 00       	mov    $0x13,%eax
    442d:	cd 40                	int    $0x40
    442f:	c3                   	ret    

00004430 <mkdir>:
SYSCALL(mkdir)
    4430:	b8 14 00 00 00       	mov    $0x14,%eax
    4435:	cd 40                	int    $0x40
    4437:	c3                   	ret    

00004438 <chdir>:
SYSCALL(chdir)
    4438:	b8 09 00 00 00       	mov    $0x9,%eax
    443d:	cd 40                	int    $0x40
    443f:	c3                   	ret    

00004440 <dup>:
SYSCALL(dup)
    4440:	b8 0a 00 00 00       	mov    $0xa,%eax
    4445:	cd 40                	int    $0x40
    4447:	c3                   	ret    

00004448 <getpid>:
SYSCALL(getpid)
    4448:	b8 0b 00 00 00       	mov    $0xb,%eax
    444d:	cd 40                	int    $0x40
    444f:	c3                   	ret    

00004450 <sbrk>:
SYSCALL(sbrk)
    4450:	b8 0c 00 00 00       	mov    $0xc,%eax
    4455:	cd 40                	int    $0x40
    4457:	c3                   	ret    

00004458 <sleep>:
SYSCALL(sleep)
    4458:	b8 0d 00 00 00       	mov    $0xd,%eax
    445d:	cd 40                	int    $0x40
    445f:	c3                   	ret    

00004460 <uptime>:
SYSCALL(uptime)
    4460:	b8 0e 00 00 00       	mov    $0xe,%eax
    4465:	cd 40                	int    $0x40
    4467:	c3                   	ret    

00004468 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
    4468:	55                   	push   %ebp
    4469:	89 e5                	mov    %esp,%ebp
    446b:	83 ec 28             	sub    $0x28,%esp
    446e:	8b 45 0c             	mov    0xc(%ebp),%eax
    4471:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
    4474:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
    447b:	00 
    447c:	8d 45 f4             	lea    -0xc(%ebp),%eax
    447f:	89 44 24 04          	mov    %eax,0x4(%esp)
    4483:	8b 45 08             	mov    0x8(%ebp),%eax
    4486:	89 04 24             	mov    %eax,(%esp)
    4489:	e8 5a ff ff ff       	call   43e8 <write>
}
    448e:	c9                   	leave  
    448f:	c3                   	ret    

00004490 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
    4490:	55                   	push   %ebp
    4491:	89 e5                	mov    %esp,%ebp
    4493:	83 ec 48             	sub    $0x48,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
    4496:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
    449d:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
    44a1:	74 17                	je     44ba <printint+0x2a>
    44a3:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
    44a7:	79 11                	jns    44ba <printint+0x2a>
    neg = 1;
    44a9:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
    44b0:	8b 45 0c             	mov    0xc(%ebp),%eax
    44b3:	f7 d8                	neg    %eax
    44b5:	89 45 ec             	mov    %eax,-0x14(%ebp)
    44b8:	eb 06                	jmp    44c0 <printint+0x30>
  } else {
    x = xx;
    44ba:	8b 45 0c             	mov    0xc(%ebp),%eax
    44bd:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
    44c0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
    44c7:	8b 4d 10             	mov    0x10(%ebp),%ecx
    44ca:	8b 45 ec             	mov    -0x14(%ebp),%eax
    44cd:	ba 00 00 00 00       	mov    $0x0,%edx
    44d2:	f7 f1                	div    %ecx
    44d4:	89 d0                	mov    %edx,%eax
    44d6:	0f b6 90 cc 67 00 00 	movzbl 0x67cc(%eax),%edx
    44dd:	8d 45 dc             	lea    -0x24(%ebp),%eax
    44e0:	03 45 f4             	add    -0xc(%ebp),%eax
    44e3:	88 10                	mov    %dl,(%eax)
    44e5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  }while((x /= base) != 0);
    44e9:	8b 55 10             	mov    0x10(%ebp),%edx
    44ec:	89 55 d4             	mov    %edx,-0x2c(%ebp)
    44ef:	8b 45 ec             	mov    -0x14(%ebp),%eax
    44f2:	ba 00 00 00 00       	mov    $0x0,%edx
    44f7:	f7 75 d4             	divl   -0x2c(%ebp)
    44fa:	89 45 ec             	mov    %eax,-0x14(%ebp)
    44fd:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    4501:	75 c4                	jne    44c7 <printint+0x37>
  if(neg)
    4503:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    4507:	74 2a                	je     4533 <printint+0xa3>
    buf[i++] = '-';
    4509:	8d 45 dc             	lea    -0x24(%ebp),%eax
    450c:	03 45 f4             	add    -0xc(%ebp),%eax
    450f:	c6 00 2d             	movb   $0x2d,(%eax)
    4512:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

  while(--i >= 0)
    4516:	eb 1b                	jmp    4533 <printint+0xa3>
    putc(fd, buf[i]);
    4518:	8d 45 dc             	lea    -0x24(%ebp),%eax
    451b:	03 45 f4             	add    -0xc(%ebp),%eax
    451e:	0f b6 00             	movzbl (%eax),%eax
    4521:	0f be c0             	movsbl %al,%eax
    4524:	89 44 24 04          	mov    %eax,0x4(%esp)
    4528:	8b 45 08             	mov    0x8(%ebp),%eax
    452b:	89 04 24             	mov    %eax,(%esp)
    452e:	e8 35 ff ff ff       	call   4468 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
    4533:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
    4537:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    453b:	79 db                	jns    4518 <printint+0x88>
    putc(fd, buf[i]);
}
    453d:	c9                   	leave  
    453e:	c3                   	ret    

0000453f <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
    453f:	55                   	push   %ebp
    4540:	89 e5                	mov    %esp,%ebp
    4542:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
    4545:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
    454c:	8d 45 0c             	lea    0xc(%ebp),%eax
    454f:	83 c0 04             	add    $0x4,%eax
    4552:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
    4555:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    455c:	e9 7d 01 00 00       	jmp    46de <printf+0x19f>
    c = fmt[i] & 0xff;
    4561:	8b 55 0c             	mov    0xc(%ebp),%edx
    4564:	8b 45 f0             	mov    -0x10(%ebp),%eax
    4567:	01 d0                	add    %edx,%eax
    4569:	0f b6 00             	movzbl (%eax),%eax
    456c:	0f be c0             	movsbl %al,%eax
    456f:	25 ff 00 00 00       	and    $0xff,%eax
    4574:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
    4577:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    457b:	75 2c                	jne    45a9 <printf+0x6a>
      if(c == '%'){
    457d:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
    4581:	75 0c                	jne    458f <printf+0x50>
        state = '%';
    4583:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
    458a:	e9 4b 01 00 00       	jmp    46da <printf+0x19b>
      } else {
        putc(fd, c);
    458f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    4592:	0f be c0             	movsbl %al,%eax
    4595:	89 44 24 04          	mov    %eax,0x4(%esp)
    4599:	8b 45 08             	mov    0x8(%ebp),%eax
    459c:	89 04 24             	mov    %eax,(%esp)
    459f:	e8 c4 fe ff ff       	call   4468 <putc>
    45a4:	e9 31 01 00 00       	jmp    46da <printf+0x19b>
      }
    } else if(state == '%'){
    45a9:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
    45ad:	0f 85 27 01 00 00    	jne    46da <printf+0x19b>
      if(c == 'd'){
    45b3:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
    45b7:	75 2d                	jne    45e6 <printf+0xa7>
        printint(fd, *ap, 10, 1);
    45b9:	8b 45 e8             	mov    -0x18(%ebp),%eax
    45bc:	8b 00                	mov    (%eax),%eax
    45be:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
    45c5:	00 
    45c6:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
    45cd:	00 
    45ce:	89 44 24 04          	mov    %eax,0x4(%esp)
    45d2:	8b 45 08             	mov    0x8(%ebp),%eax
    45d5:	89 04 24             	mov    %eax,(%esp)
    45d8:	e8 b3 fe ff ff       	call   4490 <printint>
        ap++;
    45dd:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    45e1:	e9 ed 00 00 00       	jmp    46d3 <printf+0x194>
      } else if(c == 'x' || c == 'p'){
    45e6:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
    45ea:	74 06                	je     45f2 <printf+0xb3>
    45ec:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
    45f0:	75 2d                	jne    461f <printf+0xe0>
        printint(fd, *ap, 16, 0);
    45f2:	8b 45 e8             	mov    -0x18(%ebp),%eax
    45f5:	8b 00                	mov    (%eax),%eax
    45f7:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
    45fe:	00 
    45ff:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
    4606:	00 
    4607:	89 44 24 04          	mov    %eax,0x4(%esp)
    460b:	8b 45 08             	mov    0x8(%ebp),%eax
    460e:	89 04 24             	mov    %eax,(%esp)
    4611:	e8 7a fe ff ff       	call   4490 <printint>
        ap++;
    4616:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    461a:	e9 b4 00 00 00       	jmp    46d3 <printf+0x194>
      } else if(c == 's'){
    461f:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
    4623:	75 46                	jne    466b <printf+0x12c>
        s = (char*)*ap;
    4625:	8b 45 e8             	mov    -0x18(%ebp),%eax
    4628:	8b 00                	mov    (%eax),%eax
    462a:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
    462d:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
    4631:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    4635:	75 27                	jne    465e <printf+0x11f>
          s = "(null)";
    4637:	c7 45 f4 ce 60 00 00 	movl   $0x60ce,-0xc(%ebp)
        while(*s != 0){
    463e:	eb 1e                	jmp    465e <printf+0x11f>
          putc(fd, *s);
    4640:	8b 45 f4             	mov    -0xc(%ebp),%eax
    4643:	0f b6 00             	movzbl (%eax),%eax
    4646:	0f be c0             	movsbl %al,%eax
    4649:	89 44 24 04          	mov    %eax,0x4(%esp)
    464d:	8b 45 08             	mov    0x8(%ebp),%eax
    4650:	89 04 24             	mov    %eax,(%esp)
    4653:	e8 10 fe ff ff       	call   4468 <putc>
          s++;
    4658:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    465c:	eb 01                	jmp    465f <printf+0x120>
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
    465e:	90                   	nop
    465f:	8b 45 f4             	mov    -0xc(%ebp),%eax
    4662:	0f b6 00             	movzbl (%eax),%eax
    4665:	84 c0                	test   %al,%al
    4667:	75 d7                	jne    4640 <printf+0x101>
    4669:	eb 68                	jmp    46d3 <printf+0x194>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
    466b:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
    466f:	75 1d                	jne    468e <printf+0x14f>
        putc(fd, *ap);
    4671:	8b 45 e8             	mov    -0x18(%ebp),%eax
    4674:	8b 00                	mov    (%eax),%eax
    4676:	0f be c0             	movsbl %al,%eax
    4679:	89 44 24 04          	mov    %eax,0x4(%esp)
    467d:	8b 45 08             	mov    0x8(%ebp),%eax
    4680:	89 04 24             	mov    %eax,(%esp)
    4683:	e8 e0 fd ff ff       	call   4468 <putc>
        ap++;
    4688:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    468c:	eb 45                	jmp    46d3 <printf+0x194>
      } else if(c == '%'){
    468e:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
    4692:	75 17                	jne    46ab <printf+0x16c>
        putc(fd, c);
    4694:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    4697:	0f be c0             	movsbl %al,%eax
    469a:	89 44 24 04          	mov    %eax,0x4(%esp)
    469e:	8b 45 08             	mov    0x8(%ebp),%eax
    46a1:	89 04 24             	mov    %eax,(%esp)
    46a4:	e8 bf fd ff ff       	call   4468 <putc>
    46a9:	eb 28                	jmp    46d3 <printf+0x194>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
    46ab:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
    46b2:	00 
    46b3:	8b 45 08             	mov    0x8(%ebp),%eax
    46b6:	89 04 24             	mov    %eax,(%esp)
    46b9:	e8 aa fd ff ff       	call   4468 <putc>
        putc(fd, c);
    46be:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    46c1:	0f be c0             	movsbl %al,%eax
    46c4:	89 44 24 04          	mov    %eax,0x4(%esp)
    46c8:	8b 45 08             	mov    0x8(%ebp),%eax
    46cb:	89 04 24             	mov    %eax,(%esp)
    46ce:	e8 95 fd ff ff       	call   4468 <putc>
      }
      state = 0;
    46d3:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    46da:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
    46de:	8b 55 0c             	mov    0xc(%ebp),%edx
    46e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
    46e4:	01 d0                	add    %edx,%eax
    46e6:	0f b6 00             	movzbl (%eax),%eax
    46e9:	84 c0                	test   %al,%al
    46eb:	0f 85 70 fe ff ff    	jne    4561 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
    46f1:	c9                   	leave  
    46f2:	c3                   	ret    
    46f3:	90                   	nop

000046f4 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    46f4:	55                   	push   %ebp
    46f5:	89 e5                	mov    %esp,%ebp
    46f7:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
    46fa:	8b 45 08             	mov    0x8(%ebp),%eax
    46fd:	83 e8 08             	sub    $0x8,%eax
    4700:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    4703:	a1 68 68 00 00       	mov    0x6868,%eax
    4708:	89 45 fc             	mov    %eax,-0x4(%ebp)
    470b:	eb 24                	jmp    4731 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    470d:	8b 45 fc             	mov    -0x4(%ebp),%eax
    4710:	8b 00                	mov    (%eax),%eax
    4712:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    4715:	77 12                	ja     4729 <free+0x35>
    4717:	8b 45 f8             	mov    -0x8(%ebp),%eax
    471a:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    471d:	77 24                	ja     4743 <free+0x4f>
    471f:	8b 45 fc             	mov    -0x4(%ebp),%eax
    4722:	8b 00                	mov    (%eax),%eax
    4724:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    4727:	77 1a                	ja     4743 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    4729:	8b 45 fc             	mov    -0x4(%ebp),%eax
    472c:	8b 00                	mov    (%eax),%eax
    472e:	89 45 fc             	mov    %eax,-0x4(%ebp)
    4731:	8b 45 f8             	mov    -0x8(%ebp),%eax
    4734:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    4737:	76 d4                	jbe    470d <free+0x19>
    4739:	8b 45 fc             	mov    -0x4(%ebp),%eax
    473c:	8b 00                	mov    (%eax),%eax
    473e:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    4741:	76 ca                	jbe    470d <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    4743:	8b 45 f8             	mov    -0x8(%ebp),%eax
    4746:	8b 40 04             	mov    0x4(%eax),%eax
    4749:	c1 e0 03             	shl    $0x3,%eax
    474c:	89 c2                	mov    %eax,%edx
    474e:	03 55 f8             	add    -0x8(%ebp),%edx
    4751:	8b 45 fc             	mov    -0x4(%ebp),%eax
    4754:	8b 00                	mov    (%eax),%eax
    4756:	39 c2                	cmp    %eax,%edx
    4758:	75 24                	jne    477e <free+0x8a>
    bp->s.size += p->s.ptr->s.size;
    475a:	8b 45 f8             	mov    -0x8(%ebp),%eax
    475d:	8b 50 04             	mov    0x4(%eax),%edx
    4760:	8b 45 fc             	mov    -0x4(%ebp),%eax
    4763:	8b 00                	mov    (%eax),%eax
    4765:	8b 40 04             	mov    0x4(%eax),%eax
    4768:	01 c2                	add    %eax,%edx
    476a:	8b 45 f8             	mov    -0x8(%ebp),%eax
    476d:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
    4770:	8b 45 fc             	mov    -0x4(%ebp),%eax
    4773:	8b 00                	mov    (%eax),%eax
    4775:	8b 10                	mov    (%eax),%edx
    4777:	8b 45 f8             	mov    -0x8(%ebp),%eax
    477a:	89 10                	mov    %edx,(%eax)
    477c:	eb 0a                	jmp    4788 <free+0x94>
  } else
    bp->s.ptr = p->s.ptr;
    477e:	8b 45 fc             	mov    -0x4(%ebp),%eax
    4781:	8b 10                	mov    (%eax),%edx
    4783:	8b 45 f8             	mov    -0x8(%ebp),%eax
    4786:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
    4788:	8b 45 fc             	mov    -0x4(%ebp),%eax
    478b:	8b 40 04             	mov    0x4(%eax),%eax
    478e:	c1 e0 03             	shl    $0x3,%eax
    4791:	03 45 fc             	add    -0x4(%ebp),%eax
    4794:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    4797:	75 20                	jne    47b9 <free+0xc5>
    p->s.size += bp->s.size;
    4799:	8b 45 fc             	mov    -0x4(%ebp),%eax
    479c:	8b 50 04             	mov    0x4(%eax),%edx
    479f:	8b 45 f8             	mov    -0x8(%ebp),%eax
    47a2:	8b 40 04             	mov    0x4(%eax),%eax
    47a5:	01 c2                	add    %eax,%edx
    47a7:	8b 45 fc             	mov    -0x4(%ebp),%eax
    47aa:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
    47ad:	8b 45 f8             	mov    -0x8(%ebp),%eax
    47b0:	8b 10                	mov    (%eax),%edx
    47b2:	8b 45 fc             	mov    -0x4(%ebp),%eax
    47b5:	89 10                	mov    %edx,(%eax)
    47b7:	eb 08                	jmp    47c1 <free+0xcd>
  } else
    p->s.ptr = bp;
    47b9:	8b 45 fc             	mov    -0x4(%ebp),%eax
    47bc:	8b 55 f8             	mov    -0x8(%ebp),%edx
    47bf:	89 10                	mov    %edx,(%eax)
  freep = p;
    47c1:	8b 45 fc             	mov    -0x4(%ebp),%eax
    47c4:	a3 68 68 00 00       	mov    %eax,0x6868
}
    47c9:	c9                   	leave  
    47ca:	c3                   	ret    

000047cb <morecore>:

static Header*
morecore(uint nu)
{
    47cb:	55                   	push   %ebp
    47cc:	89 e5                	mov    %esp,%ebp
    47ce:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
    47d1:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
    47d8:	77 07                	ja     47e1 <morecore+0x16>
    nu = 4096;
    47da:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
    47e1:	8b 45 08             	mov    0x8(%ebp),%eax
    47e4:	c1 e0 03             	shl    $0x3,%eax
    47e7:	89 04 24             	mov    %eax,(%esp)
    47ea:	e8 61 fc ff ff       	call   4450 <sbrk>
    47ef:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
    47f2:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
    47f6:	75 07                	jne    47ff <morecore+0x34>
    return 0;
    47f8:	b8 00 00 00 00       	mov    $0x0,%eax
    47fd:	eb 22                	jmp    4821 <morecore+0x56>
  hp = (Header*)p;
    47ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
    4802:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
    4805:	8b 45 f0             	mov    -0x10(%ebp),%eax
    4808:	8b 55 08             	mov    0x8(%ebp),%edx
    480b:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
    480e:	8b 45 f0             	mov    -0x10(%ebp),%eax
    4811:	83 c0 08             	add    $0x8,%eax
    4814:	89 04 24             	mov    %eax,(%esp)
    4817:	e8 d8 fe ff ff       	call   46f4 <free>
  return freep;
    481c:	a1 68 68 00 00       	mov    0x6868,%eax
}
    4821:	c9                   	leave  
    4822:	c3                   	ret    

00004823 <malloc>:

void*
malloc(uint nbytes)
{
    4823:	55                   	push   %ebp
    4824:	89 e5                	mov    %esp,%ebp
    4826:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    4829:	8b 45 08             	mov    0x8(%ebp),%eax
    482c:	83 c0 07             	add    $0x7,%eax
    482f:	c1 e8 03             	shr    $0x3,%eax
    4832:	83 c0 01             	add    $0x1,%eax
    4835:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
    4838:	a1 68 68 00 00       	mov    0x6868,%eax
    483d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    4840:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    4844:	75 23                	jne    4869 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
    4846:	c7 45 f0 60 68 00 00 	movl   $0x6860,-0x10(%ebp)
    484d:	8b 45 f0             	mov    -0x10(%ebp),%eax
    4850:	a3 68 68 00 00       	mov    %eax,0x6868
    4855:	a1 68 68 00 00       	mov    0x6868,%eax
    485a:	a3 60 68 00 00       	mov    %eax,0x6860
    base.s.size = 0;
    485f:	c7 05 64 68 00 00 00 	movl   $0x0,0x6864
    4866:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    4869:	8b 45 f0             	mov    -0x10(%ebp),%eax
    486c:	8b 00                	mov    (%eax),%eax
    486e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
    4871:	8b 45 f4             	mov    -0xc(%ebp),%eax
    4874:	8b 40 04             	mov    0x4(%eax),%eax
    4877:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    487a:	72 4d                	jb     48c9 <malloc+0xa6>
      if(p->s.size == nunits)
    487c:	8b 45 f4             	mov    -0xc(%ebp),%eax
    487f:	8b 40 04             	mov    0x4(%eax),%eax
    4882:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    4885:	75 0c                	jne    4893 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
    4887:	8b 45 f4             	mov    -0xc(%ebp),%eax
    488a:	8b 10                	mov    (%eax),%edx
    488c:	8b 45 f0             	mov    -0x10(%ebp),%eax
    488f:	89 10                	mov    %edx,(%eax)
    4891:	eb 26                	jmp    48b9 <malloc+0x96>
      else {
        p->s.size -= nunits;
    4893:	8b 45 f4             	mov    -0xc(%ebp),%eax
    4896:	8b 40 04             	mov    0x4(%eax),%eax
    4899:	89 c2                	mov    %eax,%edx
    489b:	2b 55 ec             	sub    -0x14(%ebp),%edx
    489e:	8b 45 f4             	mov    -0xc(%ebp),%eax
    48a1:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
    48a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
    48a7:	8b 40 04             	mov    0x4(%eax),%eax
    48aa:	c1 e0 03             	shl    $0x3,%eax
    48ad:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
    48b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
    48b3:	8b 55 ec             	mov    -0x14(%ebp),%edx
    48b6:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
    48b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
    48bc:	a3 68 68 00 00       	mov    %eax,0x6868
      return (void*)(p + 1);
    48c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
    48c4:	83 c0 08             	add    $0x8,%eax
    48c7:	eb 38                	jmp    4901 <malloc+0xde>
    }
    if(p == freep)
    48c9:	a1 68 68 00 00       	mov    0x6868,%eax
    48ce:	39 45 f4             	cmp    %eax,-0xc(%ebp)
    48d1:	75 1b                	jne    48ee <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
    48d3:	8b 45 ec             	mov    -0x14(%ebp),%eax
    48d6:	89 04 24             	mov    %eax,(%esp)
    48d9:	e8 ed fe ff ff       	call   47cb <morecore>
    48de:	89 45 f4             	mov    %eax,-0xc(%ebp)
    48e1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    48e5:	75 07                	jne    48ee <malloc+0xcb>
        return 0;
    48e7:	b8 00 00 00 00       	mov    $0x0,%eax
    48ec:	eb 13                	jmp    4901 <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    48ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
    48f1:	89 45 f0             	mov    %eax,-0x10(%ebp)
    48f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
    48f7:	8b 00                	mov    (%eax),%eax
    48f9:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
    48fc:	e9 70 ff ff ff       	jmp    4871 <malloc+0x4e>
}
    4901:	c9                   	leave  
    4902:	c3                   	ret    
