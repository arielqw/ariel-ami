
_sh:     file format elf32-i386


Disassembly of section .text:

00000000 <copyString>:
int fork1(void);  // Fork but panics on failure.
void panic(char*);
struct cmd *parsecmd(char*);

//copies string without \n
void copyString(char* dst, char* src){
       0:	55                   	push   %ebp
       1:	89 e5                	mov    %esp,%ebp
       3:	83 ec 10             	sub    $0x10,%esp
	int i = 0;
       6:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	while(src[i] != 0 && src[i] != '\n'){
       d:	eb 15                	jmp    24 <copyString+0x24>
		dst[i] = src[i];
       f:	8b 45 fc             	mov    -0x4(%ebp),%eax
      12:	03 45 08             	add    0x8(%ebp),%eax
      15:	8b 55 fc             	mov    -0x4(%ebp),%edx
      18:	03 55 0c             	add    0xc(%ebp),%edx
      1b:	0f b6 12             	movzbl (%edx),%edx
      1e:	88 10                	mov    %dl,(%eax)
		i++;
      20:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
struct cmd *parsecmd(char*);

//copies string without \n
void copyString(char* dst, char* src){
	int i = 0;
	while(src[i] != 0 && src[i] != '\n'){
      24:	8b 45 fc             	mov    -0x4(%ebp),%eax
      27:	03 45 0c             	add    0xc(%ebp),%eax
      2a:	0f b6 00             	movzbl (%eax),%eax
      2d:	84 c0                	test   %al,%al
      2f:	74 0d                	je     3e <copyString+0x3e>
      31:	8b 45 fc             	mov    -0x4(%ebp),%eax
      34:	03 45 0c             	add    0xc(%ebp),%eax
      37:	0f b6 00             	movzbl (%eax),%eax
      3a:	3c 0a                	cmp    $0xa,%al
      3c:	75 d1                	jne    f <copyString+0xf>
		dst[i] = src[i];
		i++;
	}
}
      3e:	c9                   	leave  
      3f:	c3                   	ret    

00000040 <runcmd>:
// Execute cmd.  Never returns.
void
runcmd(struct cmd *cmd)
{
      40:	55                   	push   %ebp
      41:	89 e5                	mov    %esp,%ebp
      43:	83 ec 48             	sub    $0x48,%esp
  struct execcmd *ecmd;
  struct listcmd *lcmd;
  struct pipecmd *pcmd;
  struct redircmd *rcmd;

  if(cmd == 0)
      46:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
      4a:	75 0c                	jne    58 <runcmd+0x18>
    exit(EXIT_STATUS_DEFAULT);
      4c:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
      53:	e8 20 12 00 00       	call   1278 <exit>
  
  switch(cmd->type){
      58:	8b 45 08             	mov    0x8(%ebp),%eax
      5b:	8b 00                	mov    (%eax),%eax
      5d:	83 f8 05             	cmp    $0x5,%eax
      60:	77 09                	ja     6b <runcmd+0x2b>
      62:	8b 04 85 f8 17 00 00 	mov    0x17f8(,%eax,4),%eax
      69:	ff e0                	jmp    *%eax
  default:
    panic("runcmd");
      6b:	c7 04 24 cc 17 00 00 	movl   $0x17cc,(%esp)
      72:	e8 f4 05 00 00       	call   66b <panic>

  case EXEC:
    ecmd = (struct execcmd*)cmd;
      77:	8b 45 08             	mov    0x8(%ebp),%eax
      7a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ecmd->argv[0] == 0)
      7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
      80:	8b 40 04             	mov    0x4(%eax),%eax
      83:	85 c0                	test   %eax,%eax
      85:	75 0c                	jne    93 <runcmd+0x53>
      exit(EXIT_STATUS_DEFAULT);
      87:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
      8e:	e8 e5 11 00 00       	call   1278 <exit>
    exec(ecmd->argv[0], ecmd->argv);
      93:	8b 45 f4             	mov    -0xc(%ebp),%eax
      96:	8d 50 04             	lea    0x4(%eax),%edx
      99:	8b 45 f4             	mov    -0xc(%ebp),%eax
      9c:	8b 40 04             	mov    0x4(%eax),%eax
      9f:	89 54 24 04          	mov    %edx,0x4(%esp)
      a3:	89 04 24             	mov    %eax,(%esp)
      a6:	e8 05 12 00 00       	call   12b0 <exec>
    printf(2, "exec %s failed\n", ecmd->argv[0]);
      ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
      ae:	8b 40 04             	mov    0x4(%eax),%eax
      b1:	89 44 24 08          	mov    %eax,0x8(%esp)
      b5:	c7 44 24 04 d3 17 00 	movl   $0x17d3,0x4(%esp)
      bc:	00 
      bd:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
      c4:	e8 3e 13 00 00       	call   1407 <printf>
    break;
      c9:	e9 aa 01 00 00       	jmp    278 <runcmd+0x238>

  case REDIR:
    rcmd = (struct redircmd*)cmd;
      ce:	8b 45 08             	mov    0x8(%ebp),%eax
      d1:	89 45 f0             	mov    %eax,-0x10(%ebp)
    close(rcmd->fd);
      d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
      d7:	8b 40 14             	mov    0x14(%eax),%eax
      da:	89 04 24             	mov    %eax,(%esp)
      dd:	e8 be 11 00 00       	call   12a0 <close>
    if(open(rcmd->file, rcmd->mode) < 0){
      e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
      e5:	8b 50 10             	mov    0x10(%eax),%edx
      e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
      eb:	8b 40 08             	mov    0x8(%eax),%eax
      ee:	89 54 24 04          	mov    %edx,0x4(%esp)
      f2:	89 04 24             	mov    %eax,(%esp)
      f5:	e8 be 11 00 00       	call   12b8 <open>
      fa:	85 c0                	test   %eax,%eax
      fc:	79 2a                	jns    128 <runcmd+0xe8>
      printf(2, "open %s failed\n", rcmd->file);
      fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
     101:	8b 40 08             	mov    0x8(%eax),%eax
     104:	89 44 24 08          	mov    %eax,0x8(%esp)
     108:	c7 44 24 04 e3 17 00 	movl   $0x17e3,0x4(%esp)
     10f:	00 
     110:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     117:	e8 eb 12 00 00       	call   1407 <printf>
      exit(EXIT_STATUS_DEFAULT);
     11c:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     123:	e8 50 11 00 00       	call   1278 <exit>
    }
    runcmd(rcmd->cmd);
     128:	8b 45 f0             	mov    -0x10(%ebp),%eax
     12b:	8b 40 04             	mov    0x4(%eax),%eax
     12e:	89 04 24             	mov    %eax,(%esp)
     131:	e8 0a ff ff ff       	call   40 <runcmd>
    break;
     136:	e9 3d 01 00 00       	jmp    278 <runcmd+0x238>

  case LIST:
    lcmd = (struct listcmd*)cmd;
     13b:	8b 45 08             	mov    0x8(%ebp),%eax
     13e:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(fork1() == 0)
     141:	e8 52 05 00 00       	call   698 <fork1>
     146:	85 c0                	test   %eax,%eax
     148:	75 0e                	jne    158 <runcmd+0x118>
      runcmd(lcmd->left);
     14a:	8b 45 ec             	mov    -0x14(%ebp),%eax
     14d:	8b 40 04             	mov    0x4(%eax),%eax
     150:	89 04 24             	mov    %eax,(%esp)
     153:	e8 e8 fe ff ff       	call   40 <runcmd>
    wait(0);
     158:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
     15f:	e8 1c 11 00 00       	call   1280 <wait>
    runcmd(lcmd->right);
     164:	8b 45 ec             	mov    -0x14(%ebp),%eax
     167:	8b 40 08             	mov    0x8(%eax),%eax
     16a:	89 04 24             	mov    %eax,(%esp)
     16d:	e8 ce fe ff ff       	call   40 <runcmd>
    break;
     172:	e9 01 01 00 00       	jmp    278 <runcmd+0x238>

  case PIPE:
    pcmd = (struct pipecmd*)cmd;
     177:	8b 45 08             	mov    0x8(%ebp),%eax
     17a:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pipe(p) < 0)
     17d:	8d 45 d4             	lea    -0x2c(%ebp),%eax
     180:	89 04 24             	mov    %eax,(%esp)
     183:	e8 00 11 00 00       	call   1288 <pipe>
     188:	85 c0                	test   %eax,%eax
     18a:	79 0c                	jns    198 <runcmd+0x158>
      panic("pipe");
     18c:	c7 04 24 f3 17 00 00 	movl   $0x17f3,(%esp)
     193:	e8 d3 04 00 00       	call   66b <panic>

    if( (left = fork1()) == 0){
     198:	e8 fb 04 00 00       	call   698 <fork1>
     19d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
     1a0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
     1a4:	75 3b                	jne    1e1 <runcmd+0x1a1>
      close(1);
     1a6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     1ad:	e8 ee 10 00 00       	call   12a0 <close>
      dup(p[1]);
     1b2:	8b 45 d8             	mov    -0x28(%ebp),%eax
     1b5:	89 04 24             	mov    %eax,(%esp)
     1b8:	e8 33 11 00 00       	call   12f0 <dup>
      close(p[0]);
     1bd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
     1c0:	89 04 24             	mov    %eax,(%esp)
     1c3:	e8 d8 10 00 00       	call   12a0 <close>
      close(p[1]);
     1c8:	8b 45 d8             	mov    -0x28(%ebp),%eax
     1cb:	89 04 24             	mov    %eax,(%esp)
     1ce:	e8 cd 10 00 00       	call   12a0 <close>
      runcmd(pcmd->left);
     1d3:	8b 45 e8             	mov    -0x18(%ebp),%eax
     1d6:	8b 40 04             	mov    0x4(%eax),%eax
     1d9:	89 04 24             	mov    %eax,(%esp)
     1dc:	e8 5f fe ff ff       	call   40 <runcmd>
    }

    if( (right = fork1() ) == 0){
     1e1:	e8 b2 04 00 00       	call   698 <fork1>
     1e6:	89 45 e0             	mov    %eax,-0x20(%ebp)
     1e9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
     1ed:	75 3b                	jne    22a <runcmd+0x1ea>
      close(0);
     1ef:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
     1f6:	e8 a5 10 00 00       	call   12a0 <close>
      dup(p[0]);
     1fb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
     1fe:	89 04 24             	mov    %eax,(%esp)
     201:	e8 ea 10 00 00       	call   12f0 <dup>
      close(p[0]);
     206:	8b 45 d4             	mov    -0x2c(%ebp),%eax
     209:	89 04 24             	mov    %eax,(%esp)
     20c:	e8 8f 10 00 00       	call   12a0 <close>
      close(p[1]);
     211:	8b 45 d8             	mov    -0x28(%ebp),%eax
     214:	89 04 24             	mov    %eax,(%esp)
     217:	e8 84 10 00 00       	call   12a0 <close>
      runcmd(pcmd->right);
     21c:	8b 45 e8             	mov    -0x18(%ebp),%eax
     21f:	8b 40 08             	mov    0x8(%eax),%eax
     222:	89 04 24             	mov    %eax,(%esp)
     225:	e8 16 fe ff ff       	call   40 <runcmd>
    }
    close(p[0]);
     22a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
     22d:	89 04 24             	mov    %eax,(%esp)
     230:	e8 6b 10 00 00       	call   12a0 <close>
    close(p[1]);
     235:	8b 45 d8             	mov    -0x28(%ebp),%eax
     238:	89 04 24             	mov    %eax,(%esp)
     23b:	e8 60 10 00 00       	call   12a0 <close>
    wait(0);
     240:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
     247:	e8 34 10 00 00       	call   1280 <wait>
    wait(0);
     24c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
     253:	e8 28 10 00 00       	call   1280 <wait>
    break;
     258:	eb 1e                	jmp    278 <runcmd+0x238>
    
  case BACK:
    bcmd = (struct backcmd*)cmd;
     25a:	8b 45 08             	mov    0x8(%ebp),%eax
     25d:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(fork1() == 0)
     260:	e8 33 04 00 00       	call   698 <fork1>
     265:	85 c0                	test   %eax,%eax
     267:	75 0e                	jne    277 <runcmd+0x237>
      runcmd(bcmd->cmd);
     269:	8b 45 dc             	mov    -0x24(%ebp),%eax
     26c:	8b 40 04             	mov    0x4(%eax),%eax
     26f:	89 04 24             	mov    %eax,(%esp)
     272:	e8 c9 fd ff ff       	call   40 <runcmd>
    break;
     277:	90                   	nop
  }
  exit(EXIT_STATUS_DEFAULT);
     278:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     27f:	e8 f4 0f 00 00       	call   1278 <exit>

00000284 <getcmd>:
}

int
getcmd(char *buf, int nbuf)
{
     284:	55                   	push   %ebp
     285:	89 e5                	mov    %esp,%ebp
     287:	83 ec 18             	sub    $0x18,%esp
  printf(2, "$ ");
     28a:	c7 44 24 04 10 18 00 	movl   $0x1810,0x4(%esp)
     291:	00 
     292:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     299:	e8 69 11 00 00       	call   1407 <printf>
  memset(buf, 0, nbuf);
     29e:	8b 45 0c             	mov    0xc(%ebp),%eax
     2a1:	89 44 24 08          	mov    %eax,0x8(%esp)
     2a5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     2ac:	00 
     2ad:	8b 45 08             	mov    0x8(%ebp),%eax
     2b0:	89 04 24             	mov    %eax,(%esp)
     2b3:	e8 1b 0e 00 00       	call   10d3 <memset>
  gets(buf, nbuf);
     2b8:	8b 45 0c             	mov    0xc(%ebp),%eax
     2bb:	89 44 24 04          	mov    %eax,0x4(%esp)
     2bf:	8b 45 08             	mov    0x8(%ebp),%eax
     2c2:	89 04 24             	mov    %eax,(%esp)
     2c5:	e8 60 0e 00 00       	call   112a <gets>
  if(buf[0] == 0) // EOF
     2ca:	8b 45 08             	mov    0x8(%ebp),%eax
     2cd:	0f b6 00             	movzbl (%eax),%eax
     2d0:	84 c0                	test   %al,%al
     2d2:	75 07                	jne    2db <getcmd+0x57>
    return -1;
     2d4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
     2d9:	eb 05                	jmp    2e0 <getcmd+0x5c>
  return 0;
     2db:	b8 00 00 00 00       	mov    $0x0,%eax
}
     2e0:	c9                   	leave  
     2e1:	c3                   	ret    

000002e2 <listJobs>:

void listJobs(){
     2e2:	55                   	push   %ebp
     2e3:	89 e5                	mov    %esp,%ebp
     2e5:	81 ec 38 05 00 00    	sub    $0x538,%esp
	int i,j;
	int size;
	int hasJobs = 0;
     2eb:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
	process_info_entry arr[64];

	for(i=0; i< jobs_counter; i++){
     2f2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     2f9:	e9 3a 01 00 00       	jmp    438 <listJobs+0x156>
		if(jobs_table[i].active){
     2fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
     301:	c1 e0 04             	shl    $0x4,%eax
     304:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
     30b:	29 c2                	sub    %eax,%edx
     30d:	8d 82 60 1e 00 00    	lea    0x1e60(%edx),%eax
     313:	8b 40 0c             	mov    0xc(%eax),%eax
     316:	85 c0                	test   %eax,%eax
     318:	0f 84 16 01 00 00    	je     434 <listJobs+0x152>
			list_pgroup(jobs_table[i].gid, arr, &size);
     31e:	8b 45 f4             	mov    -0xc(%ebp),%eax
     321:	c1 e0 04             	shl    $0x4,%eax
     324:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
     32b:	29 c2                	sub    %eax,%edx
     32d:	8d 82 60 1e 00 00    	lea    0x1e60(%edx),%eax
     333:	8b 40 08             	mov    0x8(%eax),%eax
     336:	8d 55 e8             	lea    -0x18(%ebp),%edx
     339:	89 54 24 08          	mov    %edx,0x8(%esp)
     33d:	8d 95 e8 fa ff ff    	lea    -0x518(%ebp),%edx
     343:	89 54 24 04          	mov    %edx,0x4(%esp)
     347:	89 04 24             	mov    %eax,(%esp)
     34a:	e8 d9 0f 00 00       	call   1328 <list_pgroup>
			if( size > 0){
     34f:	8b 45 e8             	mov    -0x18(%ebp),%eax
     352:	85 c0                	test   %eax,%eax
     354:	0f 8e be 00 00 00    	jle    418 <listJobs+0x136>
				hasJobs = 1;
     35a:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
				printf(1,"Job %d: %s\n", i, jobs_table[i].cmd, jobs_table[i].gid);
     361:	8b 45 f4             	mov    -0xc(%ebp),%eax
     364:	c1 e0 04             	shl    $0x4,%eax
     367:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
     36e:	29 c2                	sub    %eax,%edx
     370:	8d 82 60 1e 00 00    	lea    0x1e60(%edx),%eax
     376:	8b 48 08             	mov    0x8(%eax),%ecx
     379:	8b 45 f4             	mov    -0xc(%ebp),%eax
     37c:	c1 e0 04             	shl    $0x4,%eax
     37f:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
     386:	29 c2                	sub    %eax,%edx
     388:	8d 82 00 1e 00 00    	lea    0x1e00(%edx),%eax
     38e:	83 c0 04             	add    $0x4,%eax
     391:	89 4c 24 10          	mov    %ecx,0x10(%esp)
     395:	89 44 24 0c          	mov    %eax,0xc(%esp)
     399:	8b 45 f4             	mov    -0xc(%ebp),%eax
     39c:	89 44 24 08          	mov    %eax,0x8(%esp)
     3a0:	c7 44 24 04 13 18 00 	movl   $0x1813,0x4(%esp)
     3a7:	00 
     3a8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     3af:	e8 53 10 00 00       	call   1407 <printf>
				for(j=0; j< size; j++){
     3b4:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
     3bb:	eb 51                	jmp    40e <listJobs+0x12c>
					printf(1,"%d: %s \n", arr[j].pid, arr[j].name);
     3bd:	8d 8d e8 fa ff ff    	lea    -0x518(%ebp),%ecx
     3c3:	8b 55 f0             	mov    -0x10(%ebp),%edx
     3c6:	89 d0                	mov    %edx,%eax
     3c8:	c1 e0 02             	shl    $0x2,%eax
     3cb:	01 d0                	add    %edx,%eax
     3cd:	c1 e0 02             	shl    $0x2,%eax
     3d0:	01 c8                	add    %ecx,%eax
     3d2:	8d 48 04             	lea    0x4(%eax),%ecx
     3d5:	8b 55 f0             	mov    -0x10(%ebp),%edx
     3d8:	89 d0                	mov    %edx,%eax
     3da:	c1 e0 02             	shl    $0x2,%eax
     3dd:	01 d0                	add    %edx,%eax
     3df:	c1 e0 02             	shl    $0x2,%eax
     3e2:	8d 55 f8             	lea    -0x8(%ebp),%edx
     3e5:	01 d0                	add    %edx,%eax
     3e7:	2d 10 05 00 00       	sub    $0x510,%eax
     3ec:	8b 00                	mov    (%eax),%eax
     3ee:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
     3f2:	89 44 24 08          	mov    %eax,0x8(%esp)
     3f6:	c7 44 24 04 1f 18 00 	movl   $0x181f,0x4(%esp)
     3fd:	00 
     3fe:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     405:	e8 fd 0f 00 00       	call   1407 <printf>
		if(jobs_table[i].active){
			list_pgroup(jobs_table[i].gid, arr, &size);
			if( size > 0){
				hasJobs = 1;
				printf(1,"Job %d: %s\n", i, jobs_table[i].cmd, jobs_table[i].gid);
				for(j=0; j< size; j++){
     40a:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
     40e:	8b 45 e8             	mov    -0x18(%ebp),%eax
     411:	39 45 f0             	cmp    %eax,-0x10(%ebp)
     414:	7c a7                	jl     3bd <listJobs+0xdb>
     416:	eb 1c                	jmp    434 <listJobs+0x152>
					printf(1,"%d: %s \n", arr[j].pid, arr[j].name);
				}
			}
			else{
				jobs_table[i].active = 0;
     418:	8b 45 f4             	mov    -0xc(%ebp),%eax
     41b:	c1 e0 04             	shl    $0x4,%eax
     41e:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
     425:	29 c2                	sub    %eax,%edx
     427:	8d 82 60 1e 00 00    	lea    0x1e60(%edx),%eax
     42d:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
	int i,j;
	int size;
	int hasJobs = 0;
	process_info_entry arr[64];

	for(i=0; i< jobs_counter; i++){
     434:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
     438:	a1 00 de 01 00       	mov    0x1de00,%eax
     43d:	39 45 f4             	cmp    %eax,-0xc(%ebp)
     440:	0f 8c b8 fe ff ff    	jl     2fe <listJobs+0x1c>
			else{
				jobs_table[i].active = 0;
			}
		}
	}
	if(!hasJobs){
     446:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
     44a:	75 14                	jne    460 <listJobs+0x17e>
		printf(1, "There are no jobs\n");
     44c:	c7 44 24 04 28 18 00 	movl   $0x1828,0x4(%esp)
     453:	00 
     454:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     45b:	e8 a7 0f 00 00       	call   1407 <printf>
	}
}
     460:	c9                   	leave  
     461:	c3                   	ret    

00000462 <main>:

int
main(void)
{
     462:	55                   	push   %ebp
     463:	89 e5                	mov    %esp,%ebp
     465:	83 e4 f0             	and    $0xfffffff0,%esp
     468:	83 ec 20             	sub    $0x20,%esp
  static char buf[100];
  int fd;
  int child_pid;
  
  jobs_table[0].active = 0;
     46b:	c7 05 6c 1e 00 00 00 	movl   $0x0,0x1e6c
     472:	00 00 00 
  if(jobs_table[0].active) printf(1, " just so it wont cry on unused");
     475:	a1 6c 1e 00 00       	mov    0x1e6c,%eax
     47a:	85 c0                	test   %eax,%eax
     47c:	74 2f                	je     4ad <main+0x4b>
     47e:	c7 44 24 04 3c 18 00 	movl   $0x183c,0x4(%esp)
     485:	00 
     486:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     48d:	e8 75 0f 00 00       	call   1407 <printf>

  // Assumes three file descriptors open.
  while((fd = open("console", O_RDWR)) >= 0){
     492:	eb 19                	jmp    4ad <main+0x4b>
    if(fd >= 3){
     494:	83 7c 24 1c 02       	cmpl   $0x2,0x1c(%esp)
     499:	7e 12                	jle    4ad <main+0x4b>
      close(fd);
     49b:	8b 44 24 1c          	mov    0x1c(%esp),%eax
     49f:	89 04 24             	mov    %eax,(%esp)
     4a2:	e8 f9 0d 00 00       	call   12a0 <close>
      break;
     4a7:	90                   	nop
    }
  }
  
  // Read and run input commands.
  while(getcmd(buf, sizeof(buf)) >= 0){
     4a8:	e9 96 01 00 00       	jmp    643 <main+0x1e1>
  
  jobs_table[0].active = 0;
  if(jobs_table[0].active) printf(1, " just so it wont cry on unused");

  // Assumes three file descriptors open.
  while((fd = open("console", O_RDWR)) >= 0){
     4ad:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
     4b4:	00 
     4b5:	c7 04 24 5b 18 00 00 	movl   $0x185b,(%esp)
     4bc:	e8 f7 0d 00 00       	call   12b8 <open>
     4c1:	89 44 24 1c          	mov    %eax,0x1c(%esp)
     4c5:	83 7c 24 1c 00       	cmpl   $0x0,0x1c(%esp)
     4ca:	79 c8                	jns    494 <main+0x32>
      break;
    }
  }
  
  // Read and run input commands.
  while(getcmd(buf, sizeof(buf)) >= 0){
     4cc:	e9 72 01 00 00       	jmp    643 <main+0x1e1>
    if(buf[0] == 'c' && buf[1] == 'd' && buf[2] == ' '){
     4d1:	0f b6 05 20 de 01 00 	movzbl 0x1de20,%eax
     4d8:	3c 63                	cmp    $0x63,%al
     4da:	75 61                	jne    53d <main+0xdb>
     4dc:	0f b6 05 21 de 01 00 	movzbl 0x1de21,%eax
     4e3:	3c 64                	cmp    $0x64,%al
     4e5:	75 56                	jne    53d <main+0xdb>
     4e7:	0f b6 05 22 de 01 00 	movzbl 0x1de22,%eax
     4ee:	3c 20                	cmp    $0x20,%al
     4f0:	75 4b                	jne    53d <main+0xdb>
      // Clumsy but will have to do for now.
      // Chdir has no effect on the parent if run in the child.
      buf[strlen(buf)-1] = 0;  // chop \n
     4f2:	c7 04 24 20 de 01 00 	movl   $0x1de20,(%esp)
     4f9:	e8 b0 0b 00 00       	call   10ae <strlen>
     4fe:	83 e8 01             	sub    $0x1,%eax
     501:	c6 80 20 de 01 00 00 	movb   $0x0,0x1de20(%eax)
      if(chdir(buf+3) < 0)
     508:	c7 04 24 23 de 01 00 	movl   $0x1de23,(%esp)
     50f:	e8 d4 0d 00 00       	call   12e8 <chdir>
     514:	85 c0                	test   %eax,%eax
     516:	0f 89 26 01 00 00    	jns    642 <main+0x1e0>
        printf(2, "cannot cd %s\n", buf+3);
     51c:	c7 44 24 08 23 de 01 	movl   $0x1de23,0x8(%esp)
     523:	00 
     524:	c7 44 24 04 63 18 00 	movl   $0x1863,0x4(%esp)
     52b:	00 
     52c:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     533:	e8 cf 0e 00 00       	call   1407 <printf>
      continue;
     538:	e9 05 01 00 00       	jmp    642 <main+0x1e0>
    }

    if(buf[0] == 'j' && buf[1] == 'o' && buf[2] == 'b' && buf[3] == 's' && buf[4] == '\n'){
     53d:	0f b6 05 20 de 01 00 	movzbl 0x1de20,%eax
     544:	3c 6a                	cmp    $0x6a,%al
     546:	75 36                	jne    57e <main+0x11c>
     548:	0f b6 05 21 de 01 00 	movzbl 0x1de21,%eax
     54f:	3c 6f                	cmp    $0x6f,%al
     551:	75 2b                	jne    57e <main+0x11c>
     553:	0f b6 05 22 de 01 00 	movzbl 0x1de22,%eax
     55a:	3c 62                	cmp    $0x62,%al
     55c:	75 20                	jne    57e <main+0x11c>
     55e:	0f b6 05 23 de 01 00 	movzbl 0x1de23,%eax
     565:	3c 73                	cmp    $0x73,%al
     567:	75 15                	jne    57e <main+0x11c>
     569:	0f b6 05 24 de 01 00 	movzbl 0x1de24,%eax
     570:	3c 0a                	cmp    $0xa,%al
     572:	75 0a                	jne    57e <main+0x11c>
      listJobs();
     574:	e8 69 fd ff ff       	call   2e2 <listJobs>
	  continue;
     579:	e9 c5 00 00 00       	jmp    643 <main+0x1e1>
	}

    if((child_pid = fork1()) == 0){
     57e:	e8 15 01 00 00       	call   698 <fork1>
     583:	89 44 24 18          	mov    %eax,0x18(%esp)
     587:	83 7c 24 18 00       	cmpl   $0x0,0x18(%esp)
     58c:	75 14                	jne    5a2 <main+0x140>
        runcmd(parsecmd(buf));
     58e:	c7 04 24 20 de 01 00 	movl   $0x1de20,(%esp)
     595:	e8 70 04 00 00       	call   a0a <parsecmd>
     59a:	89 04 24             	mov    %eax,(%esp)
     59d:	e8 9e fa ff ff       	call   40 <runcmd>
    }
    //keep track on jobs
    jobs_table[jobs_counter].gid = child_pid;
     5a2:	a1 00 de 01 00       	mov    0x1de00,%eax
     5a7:	c1 e0 04             	shl    $0x4,%eax
     5aa:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
     5b1:	29 c2                	sub    %eax,%edx
     5b3:	81 c2 60 1e 00 00    	add    $0x1e60,%edx
     5b9:	8b 44 24 18          	mov    0x18(%esp),%eax
     5bd:	89 42 08             	mov    %eax,0x8(%edx)
    jobs_table[jobs_counter].num = jobs_counter;
     5c0:	a1 00 de 01 00       	mov    0x1de00,%eax
     5c5:	8b 0d 00 de 01 00    	mov    0x1de00,%ecx
     5cb:	c1 e0 04             	shl    $0x4,%eax
     5ce:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
     5d5:	29 c2                	sub    %eax,%edx
     5d7:	8d 82 00 1e 00 00    	lea    0x1e00(%edx),%eax
     5dd:	89 08                	mov    %ecx,(%eax)
    jobs_table[jobs_counter].active = 1;
     5df:	a1 00 de 01 00       	mov    0x1de00,%eax
     5e4:	c1 e0 04             	shl    $0x4,%eax
     5e7:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
     5ee:	29 c2                	sub    %eax,%edx
     5f0:	8d 82 60 1e 00 00    	lea    0x1e60(%edx),%eax
     5f6:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
    copyString(jobs_table[jobs_counter].cmd, buf);
     5fd:	a1 00 de 01 00       	mov    0x1de00,%eax
     602:	c1 e0 04             	shl    $0x4,%eax
     605:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
     60c:	29 c2                	sub    %eax,%edx
     60e:	8d 82 00 1e 00 00    	lea    0x1e00(%edx),%eax
     614:	83 c0 04             	add    $0x4,%eax
     617:	c7 44 24 04 20 de 01 	movl   $0x1de20,0x4(%esp)
     61e:	00 
     61f:	89 04 24             	mov    %eax,(%esp)
     622:	e8 d9 f9 ff ff       	call   0 <copyString>
	jobs_counter++;
     627:	a1 00 de 01 00       	mov    0x1de00,%eax
     62c:	83 c0 01             	add    $0x1,%eax
     62f:	a3 00 de 01 00       	mov    %eax,0x1de00

    wait(0);
     634:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
     63b:	e8 40 0c 00 00       	call   1280 <wait>
     640:	eb 01                	jmp    643 <main+0x1e1>
      // Clumsy but will have to do for now.
      // Chdir has no effect on the parent if run in the child.
      buf[strlen(buf)-1] = 0;  // chop \n
      if(chdir(buf+3) < 0)
        printf(2, "cannot cd %s\n", buf+3);
      continue;
     642:	90                   	nop
      break;
    }
  }
  
  // Read and run input commands.
  while(getcmd(buf, sizeof(buf)) >= 0){
     643:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
     64a:	00 
     64b:	c7 04 24 20 de 01 00 	movl   $0x1de20,(%esp)
     652:	e8 2d fc ff ff       	call   284 <getcmd>
     657:	85 c0                	test   %eax,%eax
     659:	0f 89 72 fe ff ff    	jns    4d1 <main+0x6f>
    copyString(jobs_table[jobs_counter].cmd, buf);
	jobs_counter++;

    wait(0);
  }
  exit(EXIT_STATUS_DEFAULT);
     65f:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     666:	e8 0d 0c 00 00       	call   1278 <exit>

0000066b <panic>:
}

void
panic(char *s)
{
     66b:	55                   	push   %ebp
     66c:	89 e5                	mov    %esp,%ebp
     66e:	83 ec 18             	sub    $0x18,%esp
  printf(2, "%s\n", s);
     671:	8b 45 08             	mov    0x8(%ebp),%eax
     674:	89 44 24 08          	mov    %eax,0x8(%esp)
     678:	c7 44 24 04 71 18 00 	movl   $0x1871,0x4(%esp)
     67f:	00 
     680:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     687:	e8 7b 0d 00 00       	call   1407 <printf>
  exit(EXIT_STATUS_DEFAULT);
     68c:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     693:	e8 e0 0b 00 00       	call   1278 <exit>

00000698 <fork1>:
}

int
fork1(void)
{
     698:	55                   	push   %ebp
     699:	89 e5                	mov    %esp,%ebp
     69b:	83 ec 28             	sub    $0x28,%esp
  int pid;
  
  pid = fork();
     69e:	e8 cd 0b 00 00       	call   1270 <fork>
     6a3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pid == -1)
     6a6:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
     6aa:	75 0c                	jne    6b8 <fork1+0x20>
    panic("fork");
     6ac:	c7 04 24 75 18 00 00 	movl   $0x1875,(%esp)
     6b3:	e8 b3 ff ff ff       	call   66b <panic>
  return pid;
     6b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     6bb:	c9                   	leave  
     6bc:	c3                   	ret    

000006bd <execcmd>:
//PAGEBREAK!
// Constructors

struct cmd*
execcmd(void)
{
     6bd:	55                   	push   %ebp
     6be:	89 e5                	mov    %esp,%ebp
     6c0:	83 ec 28             	sub    $0x28,%esp
  struct execcmd *cmd;

  cmd = malloc(sizeof(*cmd));
     6c3:	c7 04 24 54 00 00 00 	movl   $0x54,(%esp)
     6ca:	e8 1c 10 00 00       	call   16eb <malloc>
     6cf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(cmd, 0, sizeof(*cmd));
     6d2:	c7 44 24 08 54 00 00 	movl   $0x54,0x8(%esp)
     6d9:	00 
     6da:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     6e1:	00 
     6e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
     6e5:	89 04 24             	mov    %eax,(%esp)
     6e8:	e8 e6 09 00 00       	call   10d3 <memset>
  cmd->type = EXEC;
     6ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
     6f0:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  return (struct cmd*)cmd;
     6f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     6f9:	c9                   	leave  
     6fa:	c3                   	ret    

000006fb <redircmd>:

struct cmd*
redircmd(struct cmd *subcmd, char *file, char *efile, int mode, int fd)
{
     6fb:	55                   	push   %ebp
     6fc:	89 e5                	mov    %esp,%ebp
     6fe:	83 ec 28             	sub    $0x28,%esp
  struct redircmd *cmd;

  cmd = malloc(sizeof(*cmd));
     701:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
     708:	e8 de 0f 00 00       	call   16eb <malloc>
     70d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(cmd, 0, sizeof(*cmd));
     710:	c7 44 24 08 18 00 00 	movl   $0x18,0x8(%esp)
     717:	00 
     718:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     71f:	00 
     720:	8b 45 f4             	mov    -0xc(%ebp),%eax
     723:	89 04 24             	mov    %eax,(%esp)
     726:	e8 a8 09 00 00       	call   10d3 <memset>
  cmd->type = REDIR;
     72b:	8b 45 f4             	mov    -0xc(%ebp),%eax
     72e:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  cmd->cmd = subcmd;
     734:	8b 45 f4             	mov    -0xc(%ebp),%eax
     737:	8b 55 08             	mov    0x8(%ebp),%edx
     73a:	89 50 04             	mov    %edx,0x4(%eax)
  cmd->file = file;
     73d:	8b 45 f4             	mov    -0xc(%ebp),%eax
     740:	8b 55 0c             	mov    0xc(%ebp),%edx
     743:	89 50 08             	mov    %edx,0x8(%eax)
  cmd->efile = efile;
     746:	8b 45 f4             	mov    -0xc(%ebp),%eax
     749:	8b 55 10             	mov    0x10(%ebp),%edx
     74c:	89 50 0c             	mov    %edx,0xc(%eax)
  cmd->mode = mode;
     74f:	8b 45 f4             	mov    -0xc(%ebp),%eax
     752:	8b 55 14             	mov    0x14(%ebp),%edx
     755:	89 50 10             	mov    %edx,0x10(%eax)
  cmd->fd = fd;
     758:	8b 45 f4             	mov    -0xc(%ebp),%eax
     75b:	8b 55 18             	mov    0x18(%ebp),%edx
     75e:	89 50 14             	mov    %edx,0x14(%eax)
  return (struct cmd*)cmd;
     761:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     764:	c9                   	leave  
     765:	c3                   	ret    

00000766 <pipecmd>:

struct cmd*
pipecmd(struct cmd *left, struct cmd *right)
{
     766:	55                   	push   %ebp
     767:	89 e5                	mov    %esp,%ebp
     769:	83 ec 28             	sub    $0x28,%esp
  struct pipecmd *cmd;

  cmd = malloc(sizeof(*cmd));
     76c:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
     773:	e8 73 0f 00 00       	call   16eb <malloc>
     778:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(cmd, 0, sizeof(*cmd));
     77b:	c7 44 24 08 0c 00 00 	movl   $0xc,0x8(%esp)
     782:	00 
     783:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     78a:	00 
     78b:	8b 45 f4             	mov    -0xc(%ebp),%eax
     78e:	89 04 24             	mov    %eax,(%esp)
     791:	e8 3d 09 00 00       	call   10d3 <memset>
  cmd->type = PIPE;
     796:	8b 45 f4             	mov    -0xc(%ebp),%eax
     799:	c7 00 03 00 00 00    	movl   $0x3,(%eax)
  cmd->left = left;
     79f:	8b 45 f4             	mov    -0xc(%ebp),%eax
     7a2:	8b 55 08             	mov    0x8(%ebp),%edx
     7a5:	89 50 04             	mov    %edx,0x4(%eax)
  cmd->right = right;
     7a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
     7ab:	8b 55 0c             	mov    0xc(%ebp),%edx
     7ae:	89 50 08             	mov    %edx,0x8(%eax)
  return (struct cmd*)cmd;
     7b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     7b4:	c9                   	leave  
     7b5:	c3                   	ret    

000007b6 <listcmd>:

struct cmd*
listcmd(struct cmd *left, struct cmd *right)
{
     7b6:	55                   	push   %ebp
     7b7:	89 e5                	mov    %esp,%ebp
     7b9:	83 ec 28             	sub    $0x28,%esp
  struct listcmd *cmd;

  cmd = malloc(sizeof(*cmd));
     7bc:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
     7c3:	e8 23 0f 00 00       	call   16eb <malloc>
     7c8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(cmd, 0, sizeof(*cmd));
     7cb:	c7 44 24 08 0c 00 00 	movl   $0xc,0x8(%esp)
     7d2:	00 
     7d3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     7da:	00 
     7db:	8b 45 f4             	mov    -0xc(%ebp),%eax
     7de:	89 04 24             	mov    %eax,(%esp)
     7e1:	e8 ed 08 00 00       	call   10d3 <memset>
  cmd->type = LIST;
     7e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
     7e9:	c7 00 04 00 00 00    	movl   $0x4,(%eax)
  cmd->left = left;
     7ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
     7f2:	8b 55 08             	mov    0x8(%ebp),%edx
     7f5:	89 50 04             	mov    %edx,0x4(%eax)
  cmd->right = right;
     7f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
     7fb:	8b 55 0c             	mov    0xc(%ebp),%edx
     7fe:	89 50 08             	mov    %edx,0x8(%eax)
  return (struct cmd*)cmd;
     801:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     804:	c9                   	leave  
     805:	c3                   	ret    

00000806 <backcmd>:

struct cmd*
backcmd(struct cmd *subcmd)
{
     806:	55                   	push   %ebp
     807:	89 e5                	mov    %esp,%ebp
     809:	83 ec 28             	sub    $0x28,%esp
  struct backcmd *cmd;

  cmd = malloc(sizeof(*cmd));
     80c:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
     813:	e8 d3 0e 00 00       	call   16eb <malloc>
     818:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(cmd, 0, sizeof(*cmd));
     81b:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
     822:	00 
     823:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     82a:	00 
     82b:	8b 45 f4             	mov    -0xc(%ebp),%eax
     82e:	89 04 24             	mov    %eax,(%esp)
     831:	e8 9d 08 00 00       	call   10d3 <memset>
  cmd->type = BACK;
     836:	8b 45 f4             	mov    -0xc(%ebp),%eax
     839:	c7 00 05 00 00 00    	movl   $0x5,(%eax)
  cmd->cmd = subcmd;
     83f:	8b 45 f4             	mov    -0xc(%ebp),%eax
     842:	8b 55 08             	mov    0x8(%ebp),%edx
     845:	89 50 04             	mov    %edx,0x4(%eax)
  return (struct cmd*)cmd;
     848:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     84b:	c9                   	leave  
     84c:	c3                   	ret    

0000084d <gettoken>:
char whitespace[] = " \t\r\n\v";
char symbols[] = "<|>&;()";

int
gettoken(char **ps, char *es, char **q, char **eq)
{
     84d:	55                   	push   %ebp
     84e:	89 e5                	mov    %esp,%ebp
     850:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int ret;
  
  s = *ps;
     853:	8b 45 08             	mov    0x8(%ebp),%eax
     856:	8b 00                	mov    (%eax),%eax
     858:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(s < es && strchr(whitespace, *s))
     85b:	eb 04                	jmp    861 <gettoken+0x14>
    s++;
     85d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
{
  char *s;
  int ret;
  
  s = *ps;
  while(s < es && strchr(whitespace, *s))
     861:	8b 45 f4             	mov    -0xc(%ebp),%eax
     864:	3b 45 0c             	cmp    0xc(%ebp),%eax
     867:	73 1d                	jae    886 <gettoken+0x39>
     869:	8b 45 f4             	mov    -0xc(%ebp),%eax
     86c:	0f b6 00             	movzbl (%eax),%eax
     86f:	0f be c0             	movsbl %al,%eax
     872:	89 44 24 04          	mov    %eax,0x4(%esp)
     876:	c7 04 24 c4 1d 00 00 	movl   $0x1dc4,(%esp)
     87d:	e8 75 08 00 00       	call   10f7 <strchr>
     882:	85 c0                	test   %eax,%eax
     884:	75 d7                	jne    85d <gettoken+0x10>
    s++;
  if(q)
     886:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
     88a:	74 08                	je     894 <gettoken+0x47>
    *q = s;
     88c:	8b 45 10             	mov    0x10(%ebp),%eax
     88f:	8b 55 f4             	mov    -0xc(%ebp),%edx
     892:	89 10                	mov    %edx,(%eax)
  ret = *s;
     894:	8b 45 f4             	mov    -0xc(%ebp),%eax
     897:	0f b6 00             	movzbl (%eax),%eax
     89a:	0f be c0             	movsbl %al,%eax
     89d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  switch(*s){
     8a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
     8a3:	0f b6 00             	movzbl (%eax),%eax
     8a6:	0f be c0             	movsbl %al,%eax
     8a9:	83 f8 3c             	cmp    $0x3c,%eax
     8ac:	7f 1e                	jg     8cc <gettoken+0x7f>
     8ae:	83 f8 3b             	cmp    $0x3b,%eax
     8b1:	7d 23                	jge    8d6 <gettoken+0x89>
     8b3:	83 f8 29             	cmp    $0x29,%eax
     8b6:	7f 3f                	jg     8f7 <gettoken+0xaa>
     8b8:	83 f8 28             	cmp    $0x28,%eax
     8bb:	7d 19                	jge    8d6 <gettoken+0x89>
     8bd:	85 c0                	test   %eax,%eax
     8bf:	0f 84 83 00 00 00    	je     948 <gettoken+0xfb>
     8c5:	83 f8 26             	cmp    $0x26,%eax
     8c8:	74 0c                	je     8d6 <gettoken+0x89>
     8ca:	eb 2b                	jmp    8f7 <gettoken+0xaa>
     8cc:	83 f8 3e             	cmp    $0x3e,%eax
     8cf:	74 0b                	je     8dc <gettoken+0x8f>
     8d1:	83 f8 7c             	cmp    $0x7c,%eax
     8d4:	75 21                	jne    8f7 <gettoken+0xaa>
  case '(':
  case ')':
  case ';':
  case '&':
  case '<':
    s++;
     8d6:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    break;
     8da:	eb 73                	jmp    94f <gettoken+0x102>
  case '>':
    s++;
     8dc:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(*s == '>'){
     8e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
     8e3:	0f b6 00             	movzbl (%eax),%eax
     8e6:	3c 3e                	cmp    $0x3e,%al
     8e8:	75 61                	jne    94b <gettoken+0xfe>
      ret = '+';
     8ea:	c7 45 f0 2b 00 00 00 	movl   $0x2b,-0x10(%ebp)
      s++;
     8f1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    }
    break;
     8f5:	eb 54                	jmp    94b <gettoken+0xfe>
  default:
    ret = 'a';
     8f7:	c7 45 f0 61 00 00 00 	movl   $0x61,-0x10(%ebp)
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
     8fe:	eb 04                	jmp    904 <gettoken+0xb7>
      s++;
     900:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      s++;
    }
    break;
  default:
    ret = 'a';
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
     904:	8b 45 f4             	mov    -0xc(%ebp),%eax
     907:	3b 45 0c             	cmp    0xc(%ebp),%eax
     90a:	73 42                	jae    94e <gettoken+0x101>
     90c:	8b 45 f4             	mov    -0xc(%ebp),%eax
     90f:	0f b6 00             	movzbl (%eax),%eax
     912:	0f be c0             	movsbl %al,%eax
     915:	89 44 24 04          	mov    %eax,0x4(%esp)
     919:	c7 04 24 c4 1d 00 00 	movl   $0x1dc4,(%esp)
     920:	e8 d2 07 00 00       	call   10f7 <strchr>
     925:	85 c0                	test   %eax,%eax
     927:	75 25                	jne    94e <gettoken+0x101>
     929:	8b 45 f4             	mov    -0xc(%ebp),%eax
     92c:	0f b6 00             	movzbl (%eax),%eax
     92f:	0f be c0             	movsbl %al,%eax
     932:	89 44 24 04          	mov    %eax,0x4(%esp)
     936:	c7 04 24 ca 1d 00 00 	movl   $0x1dca,(%esp)
     93d:	e8 b5 07 00 00       	call   10f7 <strchr>
     942:	85 c0                	test   %eax,%eax
     944:	74 ba                	je     900 <gettoken+0xb3>
      s++;
    break;
     946:	eb 06                	jmp    94e <gettoken+0x101>
  if(q)
    *q = s;
  ret = *s;
  switch(*s){
  case 0:
    break;
     948:	90                   	nop
     949:	eb 04                	jmp    94f <gettoken+0x102>
    s++;
    if(*s == '>'){
      ret = '+';
      s++;
    }
    break;
     94b:	90                   	nop
     94c:	eb 01                	jmp    94f <gettoken+0x102>
  default:
    ret = 'a';
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
      s++;
    break;
     94e:	90                   	nop
  }
  if(eq)
     94f:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
     953:	74 0e                	je     963 <gettoken+0x116>
    *eq = s;
     955:	8b 45 14             	mov    0x14(%ebp),%eax
     958:	8b 55 f4             	mov    -0xc(%ebp),%edx
     95b:	89 10                	mov    %edx,(%eax)
  
  while(s < es && strchr(whitespace, *s))
     95d:	eb 04                	jmp    963 <gettoken+0x116>
    s++;
     95f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    break;
  }
  if(eq)
    *eq = s;
  
  while(s < es && strchr(whitespace, *s))
     963:	8b 45 f4             	mov    -0xc(%ebp),%eax
     966:	3b 45 0c             	cmp    0xc(%ebp),%eax
     969:	73 1d                	jae    988 <gettoken+0x13b>
     96b:	8b 45 f4             	mov    -0xc(%ebp),%eax
     96e:	0f b6 00             	movzbl (%eax),%eax
     971:	0f be c0             	movsbl %al,%eax
     974:	89 44 24 04          	mov    %eax,0x4(%esp)
     978:	c7 04 24 c4 1d 00 00 	movl   $0x1dc4,(%esp)
     97f:	e8 73 07 00 00       	call   10f7 <strchr>
     984:	85 c0                	test   %eax,%eax
     986:	75 d7                	jne    95f <gettoken+0x112>
    s++;
  *ps = s;
     988:	8b 45 08             	mov    0x8(%ebp),%eax
     98b:	8b 55 f4             	mov    -0xc(%ebp),%edx
     98e:	89 10                	mov    %edx,(%eax)
  return ret;
     990:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
     993:	c9                   	leave  
     994:	c3                   	ret    

00000995 <peek>:

int
peek(char **ps, char *es, char *toks)
{
     995:	55                   	push   %ebp
     996:	89 e5                	mov    %esp,%ebp
     998:	83 ec 28             	sub    $0x28,%esp
  char *s;
  
  s = *ps;
     99b:	8b 45 08             	mov    0x8(%ebp),%eax
     99e:	8b 00                	mov    (%eax),%eax
     9a0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(s < es && strchr(whitespace, *s))
     9a3:	eb 04                	jmp    9a9 <peek+0x14>
    s++;
     9a5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
peek(char **ps, char *es, char *toks)
{
  char *s;
  
  s = *ps;
  while(s < es && strchr(whitespace, *s))
     9a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
     9ac:	3b 45 0c             	cmp    0xc(%ebp),%eax
     9af:	73 1d                	jae    9ce <peek+0x39>
     9b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
     9b4:	0f b6 00             	movzbl (%eax),%eax
     9b7:	0f be c0             	movsbl %al,%eax
     9ba:	89 44 24 04          	mov    %eax,0x4(%esp)
     9be:	c7 04 24 c4 1d 00 00 	movl   $0x1dc4,(%esp)
     9c5:	e8 2d 07 00 00       	call   10f7 <strchr>
     9ca:	85 c0                	test   %eax,%eax
     9cc:	75 d7                	jne    9a5 <peek+0x10>
    s++;
  *ps = s;
     9ce:	8b 45 08             	mov    0x8(%ebp),%eax
     9d1:	8b 55 f4             	mov    -0xc(%ebp),%edx
     9d4:	89 10                	mov    %edx,(%eax)
  return *s && strchr(toks, *s);
     9d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
     9d9:	0f b6 00             	movzbl (%eax),%eax
     9dc:	84 c0                	test   %al,%al
     9de:	74 23                	je     a03 <peek+0x6e>
     9e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
     9e3:	0f b6 00             	movzbl (%eax),%eax
     9e6:	0f be c0             	movsbl %al,%eax
     9e9:	89 44 24 04          	mov    %eax,0x4(%esp)
     9ed:	8b 45 10             	mov    0x10(%ebp),%eax
     9f0:	89 04 24             	mov    %eax,(%esp)
     9f3:	e8 ff 06 00 00       	call   10f7 <strchr>
     9f8:	85 c0                	test   %eax,%eax
     9fa:	74 07                	je     a03 <peek+0x6e>
     9fc:	b8 01 00 00 00       	mov    $0x1,%eax
     a01:	eb 05                	jmp    a08 <peek+0x73>
     a03:	b8 00 00 00 00       	mov    $0x0,%eax
}
     a08:	c9                   	leave  
     a09:	c3                   	ret    

00000a0a <parsecmd>:
struct cmd *parseexec(char**, char*);
struct cmd *nulterminate(struct cmd*);

struct cmd*
parsecmd(char *s)
{
     a0a:	55                   	push   %ebp
     a0b:	89 e5                	mov    %esp,%ebp
     a0d:	53                   	push   %ebx
     a0e:	83 ec 24             	sub    $0x24,%esp
  char *es;
  struct cmd *cmd;

  es = s + strlen(s);
     a11:	8b 5d 08             	mov    0x8(%ebp),%ebx
     a14:	8b 45 08             	mov    0x8(%ebp),%eax
     a17:	89 04 24             	mov    %eax,(%esp)
     a1a:	e8 8f 06 00 00       	call   10ae <strlen>
     a1f:	01 d8                	add    %ebx,%eax
     a21:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cmd = parseline(&s, es);
     a24:	8b 45 f4             	mov    -0xc(%ebp),%eax
     a27:	89 44 24 04          	mov    %eax,0x4(%esp)
     a2b:	8d 45 08             	lea    0x8(%ebp),%eax
     a2e:	89 04 24             	mov    %eax,(%esp)
     a31:	e8 60 00 00 00       	call   a96 <parseline>
     a36:	89 45 f0             	mov    %eax,-0x10(%ebp)
  peek(&s, es, "");
     a39:	c7 44 24 08 7a 18 00 	movl   $0x187a,0x8(%esp)
     a40:	00 
     a41:	8b 45 f4             	mov    -0xc(%ebp),%eax
     a44:	89 44 24 04          	mov    %eax,0x4(%esp)
     a48:	8d 45 08             	lea    0x8(%ebp),%eax
     a4b:	89 04 24             	mov    %eax,(%esp)
     a4e:	e8 42 ff ff ff       	call   995 <peek>
  if(s != es){
     a53:	8b 45 08             	mov    0x8(%ebp),%eax
     a56:	3b 45 f4             	cmp    -0xc(%ebp),%eax
     a59:	74 27                	je     a82 <parsecmd+0x78>
    printf(2, "leftovers: %s\n", s);
     a5b:	8b 45 08             	mov    0x8(%ebp),%eax
     a5e:	89 44 24 08          	mov    %eax,0x8(%esp)
     a62:	c7 44 24 04 7b 18 00 	movl   $0x187b,0x4(%esp)
     a69:	00 
     a6a:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     a71:	e8 91 09 00 00       	call   1407 <printf>
    panic("syntax");
     a76:	c7 04 24 8a 18 00 00 	movl   $0x188a,(%esp)
     a7d:	e8 e9 fb ff ff       	call   66b <panic>
  }
  nulterminate(cmd);
     a82:	8b 45 f0             	mov    -0x10(%ebp),%eax
     a85:	89 04 24             	mov    %eax,(%esp)
     a88:	e8 a5 04 00 00       	call   f32 <nulterminate>
  return cmd;
     a8d:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
     a90:	83 c4 24             	add    $0x24,%esp
     a93:	5b                   	pop    %ebx
     a94:	5d                   	pop    %ebp
     a95:	c3                   	ret    

00000a96 <parseline>:

struct cmd*
parseline(char **ps, char *es)
{
     a96:	55                   	push   %ebp
     a97:	89 e5                	mov    %esp,%ebp
     a99:	83 ec 28             	sub    $0x28,%esp
  struct cmd *cmd;

  cmd = parsepipe(ps, es);
     a9c:	8b 45 0c             	mov    0xc(%ebp),%eax
     a9f:	89 44 24 04          	mov    %eax,0x4(%esp)
     aa3:	8b 45 08             	mov    0x8(%ebp),%eax
     aa6:	89 04 24             	mov    %eax,(%esp)
     aa9:	e8 bc 00 00 00       	call   b6a <parsepipe>
     aae:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(peek(ps, es, "&")){
     ab1:	eb 30                	jmp    ae3 <parseline+0x4d>
    gettoken(ps, es, 0, 0);
     ab3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
     aba:	00 
     abb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
     ac2:	00 
     ac3:	8b 45 0c             	mov    0xc(%ebp),%eax
     ac6:	89 44 24 04          	mov    %eax,0x4(%esp)
     aca:	8b 45 08             	mov    0x8(%ebp),%eax
     acd:	89 04 24             	mov    %eax,(%esp)
     ad0:	e8 78 fd ff ff       	call   84d <gettoken>
    cmd = backcmd(cmd);
     ad5:	8b 45 f4             	mov    -0xc(%ebp),%eax
     ad8:	89 04 24             	mov    %eax,(%esp)
     adb:	e8 26 fd ff ff       	call   806 <backcmd>
     ae0:	89 45 f4             	mov    %eax,-0xc(%ebp)
parseline(char **ps, char *es)
{
  struct cmd *cmd;

  cmd = parsepipe(ps, es);
  while(peek(ps, es, "&")){
     ae3:	c7 44 24 08 91 18 00 	movl   $0x1891,0x8(%esp)
     aea:	00 
     aeb:	8b 45 0c             	mov    0xc(%ebp),%eax
     aee:	89 44 24 04          	mov    %eax,0x4(%esp)
     af2:	8b 45 08             	mov    0x8(%ebp),%eax
     af5:	89 04 24             	mov    %eax,(%esp)
     af8:	e8 98 fe ff ff       	call   995 <peek>
     afd:	85 c0                	test   %eax,%eax
     aff:	75 b2                	jne    ab3 <parseline+0x1d>
    gettoken(ps, es, 0, 0);
    cmd = backcmd(cmd);
  }
  if(peek(ps, es, ";")){
     b01:	c7 44 24 08 93 18 00 	movl   $0x1893,0x8(%esp)
     b08:	00 
     b09:	8b 45 0c             	mov    0xc(%ebp),%eax
     b0c:	89 44 24 04          	mov    %eax,0x4(%esp)
     b10:	8b 45 08             	mov    0x8(%ebp),%eax
     b13:	89 04 24             	mov    %eax,(%esp)
     b16:	e8 7a fe ff ff       	call   995 <peek>
     b1b:	85 c0                	test   %eax,%eax
     b1d:	74 46                	je     b65 <parseline+0xcf>
    gettoken(ps, es, 0, 0);
     b1f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
     b26:	00 
     b27:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
     b2e:	00 
     b2f:	8b 45 0c             	mov    0xc(%ebp),%eax
     b32:	89 44 24 04          	mov    %eax,0x4(%esp)
     b36:	8b 45 08             	mov    0x8(%ebp),%eax
     b39:	89 04 24             	mov    %eax,(%esp)
     b3c:	e8 0c fd ff ff       	call   84d <gettoken>
    cmd = listcmd(cmd, parseline(ps, es));
     b41:	8b 45 0c             	mov    0xc(%ebp),%eax
     b44:	89 44 24 04          	mov    %eax,0x4(%esp)
     b48:	8b 45 08             	mov    0x8(%ebp),%eax
     b4b:	89 04 24             	mov    %eax,(%esp)
     b4e:	e8 43 ff ff ff       	call   a96 <parseline>
     b53:	89 44 24 04          	mov    %eax,0x4(%esp)
     b57:	8b 45 f4             	mov    -0xc(%ebp),%eax
     b5a:	89 04 24             	mov    %eax,(%esp)
     b5d:	e8 54 fc ff ff       	call   7b6 <listcmd>
     b62:	89 45 f4             	mov    %eax,-0xc(%ebp)
  }
  return cmd;
     b65:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     b68:	c9                   	leave  
     b69:	c3                   	ret    

00000b6a <parsepipe>:

struct cmd*
parsepipe(char **ps, char *es)
{
     b6a:	55                   	push   %ebp
     b6b:	89 e5                	mov    %esp,%ebp
     b6d:	83 ec 28             	sub    $0x28,%esp
  struct cmd *cmd;

  cmd = parseexec(ps, es);
     b70:	8b 45 0c             	mov    0xc(%ebp),%eax
     b73:	89 44 24 04          	mov    %eax,0x4(%esp)
     b77:	8b 45 08             	mov    0x8(%ebp),%eax
     b7a:	89 04 24             	mov    %eax,(%esp)
     b7d:	e8 68 02 00 00       	call   dea <parseexec>
     b82:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(peek(ps, es, "|")){
     b85:	c7 44 24 08 95 18 00 	movl   $0x1895,0x8(%esp)
     b8c:	00 
     b8d:	8b 45 0c             	mov    0xc(%ebp),%eax
     b90:	89 44 24 04          	mov    %eax,0x4(%esp)
     b94:	8b 45 08             	mov    0x8(%ebp),%eax
     b97:	89 04 24             	mov    %eax,(%esp)
     b9a:	e8 f6 fd ff ff       	call   995 <peek>
     b9f:	85 c0                	test   %eax,%eax
     ba1:	74 46                	je     be9 <parsepipe+0x7f>
    gettoken(ps, es, 0, 0);
     ba3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
     baa:	00 
     bab:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
     bb2:	00 
     bb3:	8b 45 0c             	mov    0xc(%ebp),%eax
     bb6:	89 44 24 04          	mov    %eax,0x4(%esp)
     bba:	8b 45 08             	mov    0x8(%ebp),%eax
     bbd:	89 04 24             	mov    %eax,(%esp)
     bc0:	e8 88 fc ff ff       	call   84d <gettoken>
    cmd = pipecmd(cmd, parsepipe(ps, es));
     bc5:	8b 45 0c             	mov    0xc(%ebp),%eax
     bc8:	89 44 24 04          	mov    %eax,0x4(%esp)
     bcc:	8b 45 08             	mov    0x8(%ebp),%eax
     bcf:	89 04 24             	mov    %eax,(%esp)
     bd2:	e8 93 ff ff ff       	call   b6a <parsepipe>
     bd7:	89 44 24 04          	mov    %eax,0x4(%esp)
     bdb:	8b 45 f4             	mov    -0xc(%ebp),%eax
     bde:	89 04 24             	mov    %eax,(%esp)
     be1:	e8 80 fb ff ff       	call   766 <pipecmd>
     be6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  }
  return cmd;
     be9:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     bec:	c9                   	leave  
     bed:	c3                   	ret    

00000bee <parseredirs>:

struct cmd*
parseredirs(struct cmd *cmd, char **ps, char *es)
{
     bee:	55                   	push   %ebp
     bef:	89 e5                	mov    %esp,%ebp
     bf1:	83 ec 38             	sub    $0x38,%esp
  int tok;
  char *q, *eq;

  while(peek(ps, es, "<>")){
     bf4:	e9 f6 00 00 00       	jmp    cef <parseredirs+0x101>
    tok = gettoken(ps, es, 0, 0);
     bf9:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
     c00:	00 
     c01:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
     c08:	00 
     c09:	8b 45 10             	mov    0x10(%ebp),%eax
     c0c:	89 44 24 04          	mov    %eax,0x4(%esp)
     c10:	8b 45 0c             	mov    0xc(%ebp),%eax
     c13:	89 04 24             	mov    %eax,(%esp)
     c16:	e8 32 fc ff ff       	call   84d <gettoken>
     c1b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(gettoken(ps, es, &q, &eq) != 'a')
     c1e:	8d 45 ec             	lea    -0x14(%ebp),%eax
     c21:	89 44 24 0c          	mov    %eax,0xc(%esp)
     c25:	8d 45 f0             	lea    -0x10(%ebp),%eax
     c28:	89 44 24 08          	mov    %eax,0x8(%esp)
     c2c:	8b 45 10             	mov    0x10(%ebp),%eax
     c2f:	89 44 24 04          	mov    %eax,0x4(%esp)
     c33:	8b 45 0c             	mov    0xc(%ebp),%eax
     c36:	89 04 24             	mov    %eax,(%esp)
     c39:	e8 0f fc ff ff       	call   84d <gettoken>
     c3e:	83 f8 61             	cmp    $0x61,%eax
     c41:	74 0c                	je     c4f <parseredirs+0x61>
      panic("missing file for redirection");
     c43:	c7 04 24 97 18 00 00 	movl   $0x1897,(%esp)
     c4a:	e8 1c fa ff ff       	call   66b <panic>
    switch(tok){
     c4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
     c52:	83 f8 3c             	cmp    $0x3c,%eax
     c55:	74 0f                	je     c66 <parseredirs+0x78>
     c57:	83 f8 3e             	cmp    $0x3e,%eax
     c5a:	74 38                	je     c94 <parseredirs+0xa6>
     c5c:	83 f8 2b             	cmp    $0x2b,%eax
     c5f:	74 61                	je     cc2 <parseredirs+0xd4>
     c61:	e9 89 00 00 00       	jmp    cef <parseredirs+0x101>
    case '<':
      cmd = redircmd(cmd, q, eq, O_RDONLY, 0);
     c66:	8b 55 ec             	mov    -0x14(%ebp),%edx
     c69:	8b 45 f0             	mov    -0x10(%ebp),%eax
     c6c:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
     c73:	00 
     c74:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
     c7b:	00 
     c7c:	89 54 24 08          	mov    %edx,0x8(%esp)
     c80:	89 44 24 04          	mov    %eax,0x4(%esp)
     c84:	8b 45 08             	mov    0x8(%ebp),%eax
     c87:	89 04 24             	mov    %eax,(%esp)
     c8a:	e8 6c fa ff ff       	call   6fb <redircmd>
     c8f:	89 45 08             	mov    %eax,0x8(%ebp)
      break;
     c92:	eb 5b                	jmp    cef <parseredirs+0x101>
    case '>':
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE, 1);
     c94:	8b 55 ec             	mov    -0x14(%ebp),%edx
     c97:	8b 45 f0             	mov    -0x10(%ebp),%eax
     c9a:	c7 44 24 10 01 00 00 	movl   $0x1,0x10(%esp)
     ca1:	00 
     ca2:	c7 44 24 0c 01 02 00 	movl   $0x201,0xc(%esp)
     ca9:	00 
     caa:	89 54 24 08          	mov    %edx,0x8(%esp)
     cae:	89 44 24 04          	mov    %eax,0x4(%esp)
     cb2:	8b 45 08             	mov    0x8(%ebp),%eax
     cb5:	89 04 24             	mov    %eax,(%esp)
     cb8:	e8 3e fa ff ff       	call   6fb <redircmd>
     cbd:	89 45 08             	mov    %eax,0x8(%ebp)
      break;
     cc0:	eb 2d                	jmp    cef <parseredirs+0x101>
    case '+':  // >>
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE, 1);
     cc2:	8b 55 ec             	mov    -0x14(%ebp),%edx
     cc5:	8b 45 f0             	mov    -0x10(%ebp),%eax
     cc8:	c7 44 24 10 01 00 00 	movl   $0x1,0x10(%esp)
     ccf:	00 
     cd0:	c7 44 24 0c 01 02 00 	movl   $0x201,0xc(%esp)
     cd7:	00 
     cd8:	89 54 24 08          	mov    %edx,0x8(%esp)
     cdc:	89 44 24 04          	mov    %eax,0x4(%esp)
     ce0:	8b 45 08             	mov    0x8(%ebp),%eax
     ce3:	89 04 24             	mov    %eax,(%esp)
     ce6:	e8 10 fa ff ff       	call   6fb <redircmd>
     ceb:	89 45 08             	mov    %eax,0x8(%ebp)
      break;
     cee:	90                   	nop
parseredirs(struct cmd *cmd, char **ps, char *es)
{
  int tok;
  char *q, *eq;

  while(peek(ps, es, "<>")){
     cef:	c7 44 24 08 b4 18 00 	movl   $0x18b4,0x8(%esp)
     cf6:	00 
     cf7:	8b 45 10             	mov    0x10(%ebp),%eax
     cfa:	89 44 24 04          	mov    %eax,0x4(%esp)
     cfe:	8b 45 0c             	mov    0xc(%ebp),%eax
     d01:	89 04 24             	mov    %eax,(%esp)
     d04:	e8 8c fc ff ff       	call   995 <peek>
     d09:	85 c0                	test   %eax,%eax
     d0b:	0f 85 e8 fe ff ff    	jne    bf9 <parseredirs+0xb>
    case '+':  // >>
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE, 1);
      break;
    }
  }
  return cmd;
     d11:	8b 45 08             	mov    0x8(%ebp),%eax
}
     d14:	c9                   	leave  
     d15:	c3                   	ret    

00000d16 <parseblock>:

struct cmd*
parseblock(char **ps, char *es)
{
     d16:	55                   	push   %ebp
     d17:	89 e5                	mov    %esp,%ebp
     d19:	83 ec 28             	sub    $0x28,%esp
  struct cmd *cmd;

  if(!peek(ps, es, "("))
     d1c:	c7 44 24 08 b7 18 00 	movl   $0x18b7,0x8(%esp)
     d23:	00 
     d24:	8b 45 0c             	mov    0xc(%ebp),%eax
     d27:	89 44 24 04          	mov    %eax,0x4(%esp)
     d2b:	8b 45 08             	mov    0x8(%ebp),%eax
     d2e:	89 04 24             	mov    %eax,(%esp)
     d31:	e8 5f fc ff ff       	call   995 <peek>
     d36:	85 c0                	test   %eax,%eax
     d38:	75 0c                	jne    d46 <parseblock+0x30>
    panic("parseblock");
     d3a:	c7 04 24 b9 18 00 00 	movl   $0x18b9,(%esp)
     d41:	e8 25 f9 ff ff       	call   66b <panic>
  gettoken(ps, es, 0, 0);
     d46:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
     d4d:	00 
     d4e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
     d55:	00 
     d56:	8b 45 0c             	mov    0xc(%ebp),%eax
     d59:	89 44 24 04          	mov    %eax,0x4(%esp)
     d5d:	8b 45 08             	mov    0x8(%ebp),%eax
     d60:	89 04 24             	mov    %eax,(%esp)
     d63:	e8 e5 fa ff ff       	call   84d <gettoken>
  cmd = parseline(ps, es);
     d68:	8b 45 0c             	mov    0xc(%ebp),%eax
     d6b:	89 44 24 04          	mov    %eax,0x4(%esp)
     d6f:	8b 45 08             	mov    0x8(%ebp),%eax
     d72:	89 04 24             	mov    %eax,(%esp)
     d75:	e8 1c fd ff ff       	call   a96 <parseline>
     d7a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(!peek(ps, es, ")"))
     d7d:	c7 44 24 08 c4 18 00 	movl   $0x18c4,0x8(%esp)
     d84:	00 
     d85:	8b 45 0c             	mov    0xc(%ebp),%eax
     d88:	89 44 24 04          	mov    %eax,0x4(%esp)
     d8c:	8b 45 08             	mov    0x8(%ebp),%eax
     d8f:	89 04 24             	mov    %eax,(%esp)
     d92:	e8 fe fb ff ff       	call   995 <peek>
     d97:	85 c0                	test   %eax,%eax
     d99:	75 0c                	jne    da7 <parseblock+0x91>
    panic("syntax - missing )");
     d9b:	c7 04 24 c6 18 00 00 	movl   $0x18c6,(%esp)
     da2:	e8 c4 f8 ff ff       	call   66b <panic>
  gettoken(ps, es, 0, 0);
     da7:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
     dae:	00 
     daf:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
     db6:	00 
     db7:	8b 45 0c             	mov    0xc(%ebp),%eax
     dba:	89 44 24 04          	mov    %eax,0x4(%esp)
     dbe:	8b 45 08             	mov    0x8(%ebp),%eax
     dc1:	89 04 24             	mov    %eax,(%esp)
     dc4:	e8 84 fa ff ff       	call   84d <gettoken>
  cmd = parseredirs(cmd, ps, es);
     dc9:	8b 45 0c             	mov    0xc(%ebp),%eax
     dcc:	89 44 24 08          	mov    %eax,0x8(%esp)
     dd0:	8b 45 08             	mov    0x8(%ebp),%eax
     dd3:	89 44 24 04          	mov    %eax,0x4(%esp)
     dd7:	8b 45 f4             	mov    -0xc(%ebp),%eax
     dda:	89 04 24             	mov    %eax,(%esp)
     ddd:	e8 0c fe ff ff       	call   bee <parseredirs>
     de2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  return cmd;
     de5:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     de8:	c9                   	leave  
     de9:	c3                   	ret    

00000dea <parseexec>:

struct cmd*
parseexec(char **ps, char *es)
{
     dea:	55                   	push   %ebp
     deb:	89 e5                	mov    %esp,%ebp
     ded:	83 ec 38             	sub    $0x38,%esp
  char *q, *eq;
  int tok, argc;
  struct execcmd *cmd;
  struct cmd *ret;
  
  if(peek(ps, es, "("))
     df0:	c7 44 24 08 b7 18 00 	movl   $0x18b7,0x8(%esp)
     df7:	00 
     df8:	8b 45 0c             	mov    0xc(%ebp),%eax
     dfb:	89 44 24 04          	mov    %eax,0x4(%esp)
     dff:	8b 45 08             	mov    0x8(%ebp),%eax
     e02:	89 04 24             	mov    %eax,(%esp)
     e05:	e8 8b fb ff ff       	call   995 <peek>
     e0a:	85 c0                	test   %eax,%eax
     e0c:	74 17                	je     e25 <parseexec+0x3b>
    return parseblock(ps, es);
     e0e:	8b 45 0c             	mov    0xc(%ebp),%eax
     e11:	89 44 24 04          	mov    %eax,0x4(%esp)
     e15:	8b 45 08             	mov    0x8(%ebp),%eax
     e18:	89 04 24             	mov    %eax,(%esp)
     e1b:	e8 f6 fe ff ff       	call   d16 <parseblock>
     e20:	e9 0b 01 00 00       	jmp    f30 <parseexec+0x146>

  ret = execcmd();
     e25:	e8 93 f8 ff ff       	call   6bd <execcmd>
     e2a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  cmd = (struct execcmd*)ret;
     e2d:	8b 45 f0             	mov    -0x10(%ebp),%eax
     e30:	89 45 ec             	mov    %eax,-0x14(%ebp)

  argc = 0;
     e33:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  ret = parseredirs(ret, ps, es);
     e3a:	8b 45 0c             	mov    0xc(%ebp),%eax
     e3d:	89 44 24 08          	mov    %eax,0x8(%esp)
     e41:	8b 45 08             	mov    0x8(%ebp),%eax
     e44:	89 44 24 04          	mov    %eax,0x4(%esp)
     e48:	8b 45 f0             	mov    -0x10(%ebp),%eax
     e4b:	89 04 24             	mov    %eax,(%esp)
     e4e:	e8 9b fd ff ff       	call   bee <parseredirs>
     e53:	89 45 f0             	mov    %eax,-0x10(%ebp)
  while(!peek(ps, es, "|)&;")){
     e56:	e9 8e 00 00 00       	jmp    ee9 <parseexec+0xff>
    if((tok=gettoken(ps, es, &q, &eq)) == 0)
     e5b:	8d 45 e0             	lea    -0x20(%ebp),%eax
     e5e:	89 44 24 0c          	mov    %eax,0xc(%esp)
     e62:	8d 45 e4             	lea    -0x1c(%ebp),%eax
     e65:	89 44 24 08          	mov    %eax,0x8(%esp)
     e69:	8b 45 0c             	mov    0xc(%ebp),%eax
     e6c:	89 44 24 04          	mov    %eax,0x4(%esp)
     e70:	8b 45 08             	mov    0x8(%ebp),%eax
     e73:	89 04 24             	mov    %eax,(%esp)
     e76:	e8 d2 f9 ff ff       	call   84d <gettoken>
     e7b:	89 45 e8             	mov    %eax,-0x18(%ebp)
     e7e:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
     e82:	0f 84 85 00 00 00    	je     f0d <parseexec+0x123>
      break;
    if(tok != 'a')
     e88:	83 7d e8 61          	cmpl   $0x61,-0x18(%ebp)
     e8c:	74 0c                	je     e9a <parseexec+0xb0>
      panic("syntax");
     e8e:	c7 04 24 8a 18 00 00 	movl   $0x188a,(%esp)
     e95:	e8 d1 f7 ff ff       	call   66b <panic>
    cmd->argv[argc] = q;
     e9a:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
     e9d:	8b 45 ec             	mov    -0x14(%ebp),%eax
     ea0:	8b 55 f4             	mov    -0xc(%ebp),%edx
     ea3:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
    cmd->eargv[argc] = eq;
     ea7:	8b 55 e0             	mov    -0x20(%ebp),%edx
     eaa:	8b 45 ec             	mov    -0x14(%ebp),%eax
     ead:	8b 4d f4             	mov    -0xc(%ebp),%ecx
     eb0:	83 c1 08             	add    $0x8,%ecx
     eb3:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    argc++;
     eb7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(argc >= MAXARGS)
     ebb:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
     ebf:	7e 0c                	jle    ecd <parseexec+0xe3>
      panic("too many args");
     ec1:	c7 04 24 d9 18 00 00 	movl   $0x18d9,(%esp)
     ec8:	e8 9e f7 ff ff       	call   66b <panic>
    ret = parseredirs(ret, ps, es);
     ecd:	8b 45 0c             	mov    0xc(%ebp),%eax
     ed0:	89 44 24 08          	mov    %eax,0x8(%esp)
     ed4:	8b 45 08             	mov    0x8(%ebp),%eax
     ed7:	89 44 24 04          	mov    %eax,0x4(%esp)
     edb:	8b 45 f0             	mov    -0x10(%ebp),%eax
     ede:	89 04 24             	mov    %eax,(%esp)
     ee1:	e8 08 fd ff ff       	call   bee <parseredirs>
     ee6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  ret = execcmd();
  cmd = (struct execcmd*)ret;

  argc = 0;
  ret = parseredirs(ret, ps, es);
  while(!peek(ps, es, "|)&;")){
     ee9:	c7 44 24 08 e7 18 00 	movl   $0x18e7,0x8(%esp)
     ef0:	00 
     ef1:	8b 45 0c             	mov    0xc(%ebp),%eax
     ef4:	89 44 24 04          	mov    %eax,0x4(%esp)
     ef8:	8b 45 08             	mov    0x8(%ebp),%eax
     efb:	89 04 24             	mov    %eax,(%esp)
     efe:	e8 92 fa ff ff       	call   995 <peek>
     f03:	85 c0                	test   %eax,%eax
     f05:	0f 84 50 ff ff ff    	je     e5b <parseexec+0x71>
     f0b:	eb 01                	jmp    f0e <parseexec+0x124>
    if((tok=gettoken(ps, es, &q, &eq)) == 0)
      break;
     f0d:	90                   	nop
    argc++;
    if(argc >= MAXARGS)
      panic("too many args");
    ret = parseredirs(ret, ps, es);
  }
  cmd->argv[argc] = 0;
     f0e:	8b 45 ec             	mov    -0x14(%ebp),%eax
     f11:	8b 55 f4             	mov    -0xc(%ebp),%edx
     f14:	c7 44 90 04 00 00 00 	movl   $0x0,0x4(%eax,%edx,4)
     f1b:	00 
  cmd->eargv[argc] = 0;
     f1c:	8b 45 ec             	mov    -0x14(%ebp),%eax
     f1f:	8b 55 f4             	mov    -0xc(%ebp),%edx
     f22:	83 c2 08             	add    $0x8,%edx
     f25:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
     f2c:	00 
  return ret;
     f2d:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
     f30:	c9                   	leave  
     f31:	c3                   	ret    

00000f32 <nulterminate>:

// NUL-terminate all the counted strings.
struct cmd*
nulterminate(struct cmd *cmd)
{
     f32:	55                   	push   %ebp
     f33:	89 e5                	mov    %esp,%ebp
     f35:	83 ec 38             	sub    $0x38,%esp
  struct execcmd *ecmd;
  struct listcmd *lcmd;
  struct pipecmd *pcmd;
  struct redircmd *rcmd;

  if(cmd == 0)
     f38:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
     f3c:	75 0a                	jne    f48 <nulterminate+0x16>
    return 0;
     f3e:	b8 00 00 00 00       	mov    $0x0,%eax
     f43:	e9 c9 00 00 00       	jmp    1011 <nulterminate+0xdf>
  
  switch(cmd->type){
     f48:	8b 45 08             	mov    0x8(%ebp),%eax
     f4b:	8b 00                	mov    (%eax),%eax
     f4d:	83 f8 05             	cmp    $0x5,%eax
     f50:	0f 87 b8 00 00 00    	ja     100e <nulterminate+0xdc>
     f56:	8b 04 85 ec 18 00 00 	mov    0x18ec(,%eax,4),%eax
     f5d:	ff e0                	jmp    *%eax
  case EXEC:
    ecmd = (struct execcmd*)cmd;
     f5f:	8b 45 08             	mov    0x8(%ebp),%eax
     f62:	89 45 f0             	mov    %eax,-0x10(%ebp)
    for(i=0; ecmd->argv[i]; i++)
     f65:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     f6c:	eb 14                	jmp    f82 <nulterminate+0x50>
      *ecmd->eargv[i] = 0;
     f6e:	8b 45 f0             	mov    -0x10(%ebp),%eax
     f71:	8b 55 f4             	mov    -0xc(%ebp),%edx
     f74:	83 c2 08             	add    $0x8,%edx
     f77:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
     f7b:	c6 00 00             	movb   $0x0,(%eax)
    return 0;
  
  switch(cmd->type){
  case EXEC:
    ecmd = (struct execcmd*)cmd;
    for(i=0; ecmd->argv[i]; i++)
     f7e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
     f82:	8b 45 f0             	mov    -0x10(%ebp),%eax
     f85:	8b 55 f4             	mov    -0xc(%ebp),%edx
     f88:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
     f8c:	85 c0                	test   %eax,%eax
     f8e:	75 de                	jne    f6e <nulterminate+0x3c>
      *ecmd->eargv[i] = 0;
    break;
     f90:	eb 7c                	jmp    100e <nulterminate+0xdc>

  case REDIR:
    rcmd = (struct redircmd*)cmd;
     f92:	8b 45 08             	mov    0x8(%ebp),%eax
     f95:	89 45 ec             	mov    %eax,-0x14(%ebp)
    nulterminate(rcmd->cmd);
     f98:	8b 45 ec             	mov    -0x14(%ebp),%eax
     f9b:	8b 40 04             	mov    0x4(%eax),%eax
     f9e:	89 04 24             	mov    %eax,(%esp)
     fa1:	e8 8c ff ff ff       	call   f32 <nulterminate>
    *rcmd->efile = 0;
     fa6:	8b 45 ec             	mov    -0x14(%ebp),%eax
     fa9:	8b 40 0c             	mov    0xc(%eax),%eax
     fac:	c6 00 00             	movb   $0x0,(%eax)
    break;
     faf:	eb 5d                	jmp    100e <nulterminate+0xdc>

  case PIPE:
    pcmd = (struct pipecmd*)cmd;
     fb1:	8b 45 08             	mov    0x8(%ebp),%eax
     fb4:	89 45 e8             	mov    %eax,-0x18(%ebp)
    nulterminate(pcmd->left);
     fb7:	8b 45 e8             	mov    -0x18(%ebp),%eax
     fba:	8b 40 04             	mov    0x4(%eax),%eax
     fbd:	89 04 24             	mov    %eax,(%esp)
     fc0:	e8 6d ff ff ff       	call   f32 <nulterminate>
    nulterminate(pcmd->right);
     fc5:	8b 45 e8             	mov    -0x18(%ebp),%eax
     fc8:	8b 40 08             	mov    0x8(%eax),%eax
     fcb:	89 04 24             	mov    %eax,(%esp)
     fce:	e8 5f ff ff ff       	call   f32 <nulterminate>
    break;
     fd3:	eb 39                	jmp    100e <nulterminate+0xdc>
    
  case LIST:
    lcmd = (struct listcmd*)cmd;
     fd5:	8b 45 08             	mov    0x8(%ebp),%eax
     fd8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    nulterminate(lcmd->left);
     fdb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     fde:	8b 40 04             	mov    0x4(%eax),%eax
     fe1:	89 04 24             	mov    %eax,(%esp)
     fe4:	e8 49 ff ff ff       	call   f32 <nulterminate>
    nulterminate(lcmd->right);
     fe9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     fec:	8b 40 08             	mov    0x8(%eax),%eax
     fef:	89 04 24             	mov    %eax,(%esp)
     ff2:	e8 3b ff ff ff       	call   f32 <nulterminate>
    break;
     ff7:	eb 15                	jmp    100e <nulterminate+0xdc>

  case BACK:
    bcmd = (struct backcmd*)cmd;
     ff9:	8b 45 08             	mov    0x8(%ebp),%eax
     ffc:	89 45 e0             	mov    %eax,-0x20(%ebp)
    nulterminate(bcmd->cmd);
     fff:	8b 45 e0             	mov    -0x20(%ebp),%eax
    1002:	8b 40 04             	mov    0x4(%eax),%eax
    1005:	89 04 24             	mov    %eax,(%esp)
    1008:	e8 25 ff ff ff       	call   f32 <nulterminate>
    break;
    100d:	90                   	nop
  }
  return cmd;
    100e:	8b 45 08             	mov    0x8(%ebp),%eax
}
    1011:	c9                   	leave  
    1012:	c3                   	ret    
    1013:	90                   	nop

00001014 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
    1014:	55                   	push   %ebp
    1015:	89 e5                	mov    %esp,%ebp
    1017:	57                   	push   %edi
    1018:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
    1019:	8b 4d 08             	mov    0x8(%ebp),%ecx
    101c:	8b 55 10             	mov    0x10(%ebp),%edx
    101f:	8b 45 0c             	mov    0xc(%ebp),%eax
    1022:	89 cb                	mov    %ecx,%ebx
    1024:	89 df                	mov    %ebx,%edi
    1026:	89 d1                	mov    %edx,%ecx
    1028:	fc                   	cld    
    1029:	f3 aa                	rep stos %al,%es:(%edi)
    102b:	89 ca                	mov    %ecx,%edx
    102d:	89 fb                	mov    %edi,%ebx
    102f:	89 5d 08             	mov    %ebx,0x8(%ebp)
    1032:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
    1035:	5b                   	pop    %ebx
    1036:	5f                   	pop    %edi
    1037:	5d                   	pop    %ebp
    1038:	c3                   	ret    

00001039 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
    1039:	55                   	push   %ebp
    103a:	89 e5                	mov    %esp,%ebp
    103c:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
    103f:	8b 45 08             	mov    0x8(%ebp),%eax
    1042:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
    1045:	90                   	nop
    1046:	8b 45 0c             	mov    0xc(%ebp),%eax
    1049:	0f b6 10             	movzbl (%eax),%edx
    104c:	8b 45 08             	mov    0x8(%ebp),%eax
    104f:	88 10                	mov    %dl,(%eax)
    1051:	8b 45 08             	mov    0x8(%ebp),%eax
    1054:	0f b6 00             	movzbl (%eax),%eax
    1057:	84 c0                	test   %al,%al
    1059:	0f 95 c0             	setne  %al
    105c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    1060:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
    1064:	84 c0                	test   %al,%al
    1066:	75 de                	jne    1046 <strcpy+0xd>
    ;
  return os;
    1068:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
    106b:	c9                   	leave  
    106c:	c3                   	ret    

0000106d <strcmp>:

int
strcmp(const char *p, const char *q)
{
    106d:	55                   	push   %ebp
    106e:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
    1070:	eb 08                	jmp    107a <strcmp+0xd>
    p++, q++;
    1072:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    1076:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
    107a:	8b 45 08             	mov    0x8(%ebp),%eax
    107d:	0f b6 00             	movzbl (%eax),%eax
    1080:	84 c0                	test   %al,%al
    1082:	74 10                	je     1094 <strcmp+0x27>
    1084:	8b 45 08             	mov    0x8(%ebp),%eax
    1087:	0f b6 10             	movzbl (%eax),%edx
    108a:	8b 45 0c             	mov    0xc(%ebp),%eax
    108d:	0f b6 00             	movzbl (%eax),%eax
    1090:	38 c2                	cmp    %al,%dl
    1092:	74 de                	je     1072 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
    1094:	8b 45 08             	mov    0x8(%ebp),%eax
    1097:	0f b6 00             	movzbl (%eax),%eax
    109a:	0f b6 d0             	movzbl %al,%edx
    109d:	8b 45 0c             	mov    0xc(%ebp),%eax
    10a0:	0f b6 00             	movzbl (%eax),%eax
    10a3:	0f b6 c0             	movzbl %al,%eax
    10a6:	89 d1                	mov    %edx,%ecx
    10a8:	29 c1                	sub    %eax,%ecx
    10aa:	89 c8                	mov    %ecx,%eax
}
    10ac:	5d                   	pop    %ebp
    10ad:	c3                   	ret    

000010ae <strlen>:

uint
strlen(char *s)
{
    10ae:	55                   	push   %ebp
    10af:	89 e5                	mov    %esp,%ebp
    10b1:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
    10b4:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    10bb:	eb 04                	jmp    10c1 <strlen+0x13>
    10bd:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
    10c1:	8b 45 fc             	mov    -0x4(%ebp),%eax
    10c4:	03 45 08             	add    0x8(%ebp),%eax
    10c7:	0f b6 00             	movzbl (%eax),%eax
    10ca:	84 c0                	test   %al,%al
    10cc:	75 ef                	jne    10bd <strlen+0xf>
    ;
  return n;
    10ce:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
    10d1:	c9                   	leave  
    10d2:	c3                   	ret    

000010d3 <memset>:

void*
memset(void *dst, int c, uint n)
{
    10d3:	55                   	push   %ebp
    10d4:	89 e5                	mov    %esp,%ebp
    10d6:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
    10d9:	8b 45 10             	mov    0x10(%ebp),%eax
    10dc:	89 44 24 08          	mov    %eax,0x8(%esp)
    10e0:	8b 45 0c             	mov    0xc(%ebp),%eax
    10e3:	89 44 24 04          	mov    %eax,0x4(%esp)
    10e7:	8b 45 08             	mov    0x8(%ebp),%eax
    10ea:	89 04 24             	mov    %eax,(%esp)
    10ed:	e8 22 ff ff ff       	call   1014 <stosb>
  return dst;
    10f2:	8b 45 08             	mov    0x8(%ebp),%eax
}
    10f5:	c9                   	leave  
    10f6:	c3                   	ret    

000010f7 <strchr>:

char*
strchr(const char *s, char c)
{
    10f7:	55                   	push   %ebp
    10f8:	89 e5                	mov    %esp,%ebp
    10fa:	83 ec 04             	sub    $0x4,%esp
    10fd:	8b 45 0c             	mov    0xc(%ebp),%eax
    1100:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
    1103:	eb 14                	jmp    1119 <strchr+0x22>
    if(*s == c)
    1105:	8b 45 08             	mov    0x8(%ebp),%eax
    1108:	0f b6 00             	movzbl (%eax),%eax
    110b:	3a 45 fc             	cmp    -0x4(%ebp),%al
    110e:	75 05                	jne    1115 <strchr+0x1e>
      return (char*)s;
    1110:	8b 45 08             	mov    0x8(%ebp),%eax
    1113:	eb 13                	jmp    1128 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
    1115:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    1119:	8b 45 08             	mov    0x8(%ebp),%eax
    111c:	0f b6 00             	movzbl (%eax),%eax
    111f:	84 c0                	test   %al,%al
    1121:	75 e2                	jne    1105 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
    1123:	b8 00 00 00 00       	mov    $0x0,%eax
}
    1128:	c9                   	leave  
    1129:	c3                   	ret    

0000112a <gets>:

char*
gets(char *buf, int max)
{
    112a:	55                   	push   %ebp
    112b:	89 e5                	mov    %esp,%ebp
    112d:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    1130:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    1137:	eb 44                	jmp    117d <gets+0x53>
    cc = read(0, &c, 1);
    1139:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
    1140:	00 
    1141:	8d 45 ef             	lea    -0x11(%ebp),%eax
    1144:	89 44 24 04          	mov    %eax,0x4(%esp)
    1148:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    114f:	e8 3c 01 00 00       	call   1290 <read>
    1154:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
    1157:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    115b:	7e 2d                	jle    118a <gets+0x60>
      break;
    buf[i++] = c;
    115d:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1160:	03 45 08             	add    0x8(%ebp),%eax
    1163:	0f b6 55 ef          	movzbl -0x11(%ebp),%edx
    1167:	88 10                	mov    %dl,(%eax)
    1169:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(c == '\n' || c == '\r')
    116d:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    1171:	3c 0a                	cmp    $0xa,%al
    1173:	74 16                	je     118b <gets+0x61>
    1175:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    1179:	3c 0d                	cmp    $0xd,%al
    117b:	74 0e                	je     118b <gets+0x61>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    117d:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1180:	83 c0 01             	add    $0x1,%eax
    1183:	3b 45 0c             	cmp    0xc(%ebp),%eax
    1186:	7c b1                	jl     1139 <gets+0xf>
    1188:	eb 01                	jmp    118b <gets+0x61>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    118a:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
    118b:	8b 45 f4             	mov    -0xc(%ebp),%eax
    118e:	03 45 08             	add    0x8(%ebp),%eax
    1191:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
    1194:	8b 45 08             	mov    0x8(%ebp),%eax
}
    1197:	c9                   	leave  
    1198:	c3                   	ret    

00001199 <stat>:

int
stat(char *n, struct stat *st)
{
    1199:	55                   	push   %ebp
    119a:	89 e5                	mov    %esp,%ebp
    119c:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
    119f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    11a6:	00 
    11a7:	8b 45 08             	mov    0x8(%ebp),%eax
    11aa:	89 04 24             	mov    %eax,(%esp)
    11ad:	e8 06 01 00 00       	call   12b8 <open>
    11b2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
    11b5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    11b9:	79 07                	jns    11c2 <stat+0x29>
    return -1;
    11bb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    11c0:	eb 23                	jmp    11e5 <stat+0x4c>
  r = fstat(fd, st);
    11c2:	8b 45 0c             	mov    0xc(%ebp),%eax
    11c5:	89 44 24 04          	mov    %eax,0x4(%esp)
    11c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
    11cc:	89 04 24             	mov    %eax,(%esp)
    11cf:	e8 fc 00 00 00       	call   12d0 <fstat>
    11d4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
    11d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
    11da:	89 04 24             	mov    %eax,(%esp)
    11dd:	e8 be 00 00 00       	call   12a0 <close>
  return r;
    11e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
    11e5:	c9                   	leave  
    11e6:	c3                   	ret    

000011e7 <atoi>:

int
atoi(const char *s)
{
    11e7:	55                   	push   %ebp
    11e8:	89 e5                	mov    %esp,%ebp
    11ea:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
    11ed:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
    11f4:	eb 23                	jmp    1219 <atoi+0x32>
    n = n*10 + *s++ - '0';
    11f6:	8b 55 fc             	mov    -0x4(%ebp),%edx
    11f9:	89 d0                	mov    %edx,%eax
    11fb:	c1 e0 02             	shl    $0x2,%eax
    11fe:	01 d0                	add    %edx,%eax
    1200:	01 c0                	add    %eax,%eax
    1202:	89 c2                	mov    %eax,%edx
    1204:	8b 45 08             	mov    0x8(%ebp),%eax
    1207:	0f b6 00             	movzbl (%eax),%eax
    120a:	0f be c0             	movsbl %al,%eax
    120d:	01 d0                	add    %edx,%eax
    120f:	83 e8 30             	sub    $0x30,%eax
    1212:	89 45 fc             	mov    %eax,-0x4(%ebp)
    1215:	83 45 08 01          	addl   $0x1,0x8(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
    1219:	8b 45 08             	mov    0x8(%ebp),%eax
    121c:	0f b6 00             	movzbl (%eax),%eax
    121f:	3c 2f                	cmp    $0x2f,%al
    1221:	7e 0a                	jle    122d <atoi+0x46>
    1223:	8b 45 08             	mov    0x8(%ebp),%eax
    1226:	0f b6 00             	movzbl (%eax),%eax
    1229:	3c 39                	cmp    $0x39,%al
    122b:	7e c9                	jle    11f6 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
    122d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
    1230:	c9                   	leave  
    1231:	c3                   	ret    

00001232 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
    1232:	55                   	push   %ebp
    1233:	89 e5                	mov    %esp,%ebp
    1235:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
    1238:	8b 45 08             	mov    0x8(%ebp),%eax
    123b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
    123e:	8b 45 0c             	mov    0xc(%ebp),%eax
    1241:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
    1244:	eb 13                	jmp    1259 <memmove+0x27>
    *dst++ = *src++;
    1246:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1249:	0f b6 10             	movzbl (%eax),%edx
    124c:	8b 45 fc             	mov    -0x4(%ebp),%eax
    124f:	88 10                	mov    %dl,(%eax)
    1251:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
    1255:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
    1259:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
    125d:	0f 9f c0             	setg   %al
    1260:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    1264:	84 c0                	test   %al,%al
    1266:	75 de                	jne    1246 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
    1268:	8b 45 08             	mov    0x8(%ebp),%eax
}
    126b:	c9                   	leave  
    126c:	c3                   	ret    
    126d:	90                   	nop
    126e:	90                   	nop
    126f:	90                   	nop

00001270 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
    1270:	b8 01 00 00 00       	mov    $0x1,%eax
    1275:	cd 40                	int    $0x40
    1277:	c3                   	ret    

00001278 <exit>:
SYSCALL(exit)
    1278:	b8 02 00 00 00       	mov    $0x2,%eax
    127d:	cd 40                	int    $0x40
    127f:	c3                   	ret    

00001280 <wait>:
SYSCALL(wait)
    1280:	b8 03 00 00 00       	mov    $0x3,%eax
    1285:	cd 40                	int    $0x40
    1287:	c3                   	ret    

00001288 <pipe>:
SYSCALL(pipe)
    1288:	b8 04 00 00 00       	mov    $0x4,%eax
    128d:	cd 40                	int    $0x40
    128f:	c3                   	ret    

00001290 <read>:
SYSCALL(read)
    1290:	b8 05 00 00 00       	mov    $0x5,%eax
    1295:	cd 40                	int    $0x40
    1297:	c3                   	ret    

00001298 <write>:
SYSCALL(write)
    1298:	b8 10 00 00 00       	mov    $0x10,%eax
    129d:	cd 40                	int    $0x40
    129f:	c3                   	ret    

000012a0 <close>:
SYSCALL(close)
    12a0:	b8 15 00 00 00       	mov    $0x15,%eax
    12a5:	cd 40                	int    $0x40
    12a7:	c3                   	ret    

000012a8 <kill>:
SYSCALL(kill)
    12a8:	b8 06 00 00 00       	mov    $0x6,%eax
    12ad:	cd 40                	int    $0x40
    12af:	c3                   	ret    

000012b0 <exec>:
SYSCALL(exec)
    12b0:	b8 07 00 00 00       	mov    $0x7,%eax
    12b5:	cd 40                	int    $0x40
    12b7:	c3                   	ret    

000012b8 <open>:
SYSCALL(open)
    12b8:	b8 0f 00 00 00       	mov    $0xf,%eax
    12bd:	cd 40                	int    $0x40
    12bf:	c3                   	ret    

000012c0 <mknod>:
SYSCALL(mknod)
    12c0:	b8 11 00 00 00       	mov    $0x11,%eax
    12c5:	cd 40                	int    $0x40
    12c7:	c3                   	ret    

000012c8 <unlink>:
SYSCALL(unlink)
    12c8:	b8 12 00 00 00       	mov    $0x12,%eax
    12cd:	cd 40                	int    $0x40
    12cf:	c3                   	ret    

000012d0 <fstat>:
SYSCALL(fstat)
    12d0:	b8 08 00 00 00       	mov    $0x8,%eax
    12d5:	cd 40                	int    $0x40
    12d7:	c3                   	ret    

000012d8 <link>:
SYSCALL(link)
    12d8:	b8 13 00 00 00       	mov    $0x13,%eax
    12dd:	cd 40                	int    $0x40
    12df:	c3                   	ret    

000012e0 <mkdir>:
SYSCALL(mkdir)
    12e0:	b8 14 00 00 00       	mov    $0x14,%eax
    12e5:	cd 40                	int    $0x40
    12e7:	c3                   	ret    

000012e8 <chdir>:
SYSCALL(chdir)
    12e8:	b8 09 00 00 00       	mov    $0x9,%eax
    12ed:	cd 40                	int    $0x40
    12ef:	c3                   	ret    

000012f0 <dup>:
SYSCALL(dup)
    12f0:	b8 0a 00 00 00       	mov    $0xa,%eax
    12f5:	cd 40                	int    $0x40
    12f7:	c3                   	ret    

000012f8 <getpid>:
SYSCALL(getpid)
    12f8:	b8 0b 00 00 00       	mov    $0xb,%eax
    12fd:	cd 40                	int    $0x40
    12ff:	c3                   	ret    

00001300 <sbrk>:
SYSCALL(sbrk)
    1300:	b8 0c 00 00 00       	mov    $0xc,%eax
    1305:	cd 40                	int    $0x40
    1307:	c3                   	ret    

00001308 <sleep>:
SYSCALL(sleep)
    1308:	b8 0d 00 00 00       	mov    $0xd,%eax
    130d:	cd 40                	int    $0x40
    130f:	c3                   	ret    

00001310 <uptime>:
SYSCALL(uptime)
    1310:	b8 0e 00 00 00       	mov    $0xe,%eax
    1315:	cd 40                	int    $0x40
    1317:	c3                   	ret    

00001318 <waitpid>:
SYSCALL(waitpid)
    1318:	b8 16 00 00 00       	mov    $0x16,%eax
    131d:	cd 40                	int    $0x40
    131f:	c3                   	ret    

00001320 <wait_stat>:
SYSCALL(wait_stat)
    1320:	b8 17 00 00 00       	mov    $0x17,%eax
    1325:	cd 40                	int    $0x40
    1327:	c3                   	ret    

00001328 <list_pgroup>:
SYSCALL(list_pgroup)
    1328:	b8 18 00 00 00       	mov    $0x18,%eax
    132d:	cd 40                	int    $0x40
    132f:	c3                   	ret    

00001330 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
    1330:	55                   	push   %ebp
    1331:	89 e5                	mov    %esp,%ebp
    1333:	83 ec 28             	sub    $0x28,%esp
    1336:	8b 45 0c             	mov    0xc(%ebp),%eax
    1339:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
    133c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
    1343:	00 
    1344:	8d 45 f4             	lea    -0xc(%ebp),%eax
    1347:	89 44 24 04          	mov    %eax,0x4(%esp)
    134b:	8b 45 08             	mov    0x8(%ebp),%eax
    134e:	89 04 24             	mov    %eax,(%esp)
    1351:	e8 42 ff ff ff       	call   1298 <write>
}
    1356:	c9                   	leave  
    1357:	c3                   	ret    

00001358 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
    1358:	55                   	push   %ebp
    1359:	89 e5                	mov    %esp,%ebp
    135b:	83 ec 48             	sub    $0x48,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
    135e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
    1365:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
    1369:	74 17                	je     1382 <printint+0x2a>
    136b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
    136f:	79 11                	jns    1382 <printint+0x2a>
    neg = 1;
    1371:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
    1378:	8b 45 0c             	mov    0xc(%ebp),%eax
    137b:	f7 d8                	neg    %eax
    137d:	89 45 ec             	mov    %eax,-0x14(%ebp)
    1380:	eb 06                	jmp    1388 <printint+0x30>
  } else {
    x = xx;
    1382:	8b 45 0c             	mov    0xc(%ebp),%eax
    1385:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
    1388:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
    138f:	8b 4d 10             	mov    0x10(%ebp),%ecx
    1392:	8b 45 ec             	mov    -0x14(%ebp),%eax
    1395:	ba 00 00 00 00       	mov    $0x0,%edx
    139a:	f7 f1                	div    %ecx
    139c:	89 d0                	mov    %edx,%eax
    139e:	0f b6 90 d4 1d 00 00 	movzbl 0x1dd4(%eax),%edx
    13a5:	8d 45 dc             	lea    -0x24(%ebp),%eax
    13a8:	03 45 f4             	add    -0xc(%ebp),%eax
    13ab:	88 10                	mov    %dl,(%eax)
    13ad:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  }while((x /= base) != 0);
    13b1:	8b 55 10             	mov    0x10(%ebp),%edx
    13b4:	89 55 d4             	mov    %edx,-0x2c(%ebp)
    13b7:	8b 45 ec             	mov    -0x14(%ebp),%eax
    13ba:	ba 00 00 00 00       	mov    $0x0,%edx
    13bf:	f7 75 d4             	divl   -0x2c(%ebp)
    13c2:	89 45 ec             	mov    %eax,-0x14(%ebp)
    13c5:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    13c9:	75 c4                	jne    138f <printint+0x37>
  if(neg)
    13cb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    13cf:	74 2a                	je     13fb <printint+0xa3>
    buf[i++] = '-';
    13d1:	8d 45 dc             	lea    -0x24(%ebp),%eax
    13d4:	03 45 f4             	add    -0xc(%ebp),%eax
    13d7:	c6 00 2d             	movb   $0x2d,(%eax)
    13da:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

  while(--i >= 0)
    13de:	eb 1b                	jmp    13fb <printint+0xa3>
    putc(fd, buf[i]);
    13e0:	8d 45 dc             	lea    -0x24(%ebp),%eax
    13e3:	03 45 f4             	add    -0xc(%ebp),%eax
    13e6:	0f b6 00             	movzbl (%eax),%eax
    13e9:	0f be c0             	movsbl %al,%eax
    13ec:	89 44 24 04          	mov    %eax,0x4(%esp)
    13f0:	8b 45 08             	mov    0x8(%ebp),%eax
    13f3:	89 04 24             	mov    %eax,(%esp)
    13f6:	e8 35 ff ff ff       	call   1330 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
    13fb:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
    13ff:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    1403:	79 db                	jns    13e0 <printint+0x88>
    putc(fd, buf[i]);
}
    1405:	c9                   	leave  
    1406:	c3                   	ret    

00001407 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
    1407:	55                   	push   %ebp
    1408:	89 e5                	mov    %esp,%ebp
    140a:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
    140d:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
    1414:	8d 45 0c             	lea    0xc(%ebp),%eax
    1417:	83 c0 04             	add    $0x4,%eax
    141a:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
    141d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    1424:	e9 7d 01 00 00       	jmp    15a6 <printf+0x19f>
    c = fmt[i] & 0xff;
    1429:	8b 55 0c             	mov    0xc(%ebp),%edx
    142c:	8b 45 f0             	mov    -0x10(%ebp),%eax
    142f:	01 d0                	add    %edx,%eax
    1431:	0f b6 00             	movzbl (%eax),%eax
    1434:	0f be c0             	movsbl %al,%eax
    1437:	25 ff 00 00 00       	and    $0xff,%eax
    143c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
    143f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    1443:	75 2c                	jne    1471 <printf+0x6a>
      if(c == '%'){
    1445:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
    1449:	75 0c                	jne    1457 <printf+0x50>
        state = '%';
    144b:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
    1452:	e9 4b 01 00 00       	jmp    15a2 <printf+0x19b>
      } else {
        putc(fd, c);
    1457:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    145a:	0f be c0             	movsbl %al,%eax
    145d:	89 44 24 04          	mov    %eax,0x4(%esp)
    1461:	8b 45 08             	mov    0x8(%ebp),%eax
    1464:	89 04 24             	mov    %eax,(%esp)
    1467:	e8 c4 fe ff ff       	call   1330 <putc>
    146c:	e9 31 01 00 00       	jmp    15a2 <printf+0x19b>
      }
    } else if(state == '%'){
    1471:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
    1475:	0f 85 27 01 00 00    	jne    15a2 <printf+0x19b>
      if(c == 'd'){
    147b:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
    147f:	75 2d                	jne    14ae <printf+0xa7>
        printint(fd, *ap, 10, 1);
    1481:	8b 45 e8             	mov    -0x18(%ebp),%eax
    1484:	8b 00                	mov    (%eax),%eax
    1486:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
    148d:	00 
    148e:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
    1495:	00 
    1496:	89 44 24 04          	mov    %eax,0x4(%esp)
    149a:	8b 45 08             	mov    0x8(%ebp),%eax
    149d:	89 04 24             	mov    %eax,(%esp)
    14a0:	e8 b3 fe ff ff       	call   1358 <printint>
        ap++;
    14a5:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    14a9:	e9 ed 00 00 00       	jmp    159b <printf+0x194>
      } else if(c == 'x' || c == 'p'){
    14ae:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
    14b2:	74 06                	je     14ba <printf+0xb3>
    14b4:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
    14b8:	75 2d                	jne    14e7 <printf+0xe0>
        printint(fd, *ap, 16, 0);
    14ba:	8b 45 e8             	mov    -0x18(%ebp),%eax
    14bd:	8b 00                	mov    (%eax),%eax
    14bf:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
    14c6:	00 
    14c7:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
    14ce:	00 
    14cf:	89 44 24 04          	mov    %eax,0x4(%esp)
    14d3:	8b 45 08             	mov    0x8(%ebp),%eax
    14d6:	89 04 24             	mov    %eax,(%esp)
    14d9:	e8 7a fe ff ff       	call   1358 <printint>
        ap++;
    14de:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    14e2:	e9 b4 00 00 00       	jmp    159b <printf+0x194>
      } else if(c == 's'){
    14e7:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
    14eb:	75 46                	jne    1533 <printf+0x12c>
        s = (char*)*ap;
    14ed:	8b 45 e8             	mov    -0x18(%ebp),%eax
    14f0:	8b 00                	mov    (%eax),%eax
    14f2:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
    14f5:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
    14f9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    14fd:	75 27                	jne    1526 <printf+0x11f>
          s = "(null)";
    14ff:	c7 45 f4 04 19 00 00 	movl   $0x1904,-0xc(%ebp)
        while(*s != 0){
    1506:	eb 1e                	jmp    1526 <printf+0x11f>
          putc(fd, *s);
    1508:	8b 45 f4             	mov    -0xc(%ebp),%eax
    150b:	0f b6 00             	movzbl (%eax),%eax
    150e:	0f be c0             	movsbl %al,%eax
    1511:	89 44 24 04          	mov    %eax,0x4(%esp)
    1515:	8b 45 08             	mov    0x8(%ebp),%eax
    1518:	89 04 24             	mov    %eax,(%esp)
    151b:	e8 10 fe ff ff       	call   1330 <putc>
          s++;
    1520:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    1524:	eb 01                	jmp    1527 <printf+0x120>
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
    1526:	90                   	nop
    1527:	8b 45 f4             	mov    -0xc(%ebp),%eax
    152a:	0f b6 00             	movzbl (%eax),%eax
    152d:	84 c0                	test   %al,%al
    152f:	75 d7                	jne    1508 <printf+0x101>
    1531:	eb 68                	jmp    159b <printf+0x194>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
    1533:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
    1537:	75 1d                	jne    1556 <printf+0x14f>
        putc(fd, *ap);
    1539:	8b 45 e8             	mov    -0x18(%ebp),%eax
    153c:	8b 00                	mov    (%eax),%eax
    153e:	0f be c0             	movsbl %al,%eax
    1541:	89 44 24 04          	mov    %eax,0x4(%esp)
    1545:	8b 45 08             	mov    0x8(%ebp),%eax
    1548:	89 04 24             	mov    %eax,(%esp)
    154b:	e8 e0 fd ff ff       	call   1330 <putc>
        ap++;
    1550:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    1554:	eb 45                	jmp    159b <printf+0x194>
      } else if(c == '%'){
    1556:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
    155a:	75 17                	jne    1573 <printf+0x16c>
        putc(fd, c);
    155c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    155f:	0f be c0             	movsbl %al,%eax
    1562:	89 44 24 04          	mov    %eax,0x4(%esp)
    1566:	8b 45 08             	mov    0x8(%ebp),%eax
    1569:	89 04 24             	mov    %eax,(%esp)
    156c:	e8 bf fd ff ff       	call   1330 <putc>
    1571:	eb 28                	jmp    159b <printf+0x194>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
    1573:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
    157a:	00 
    157b:	8b 45 08             	mov    0x8(%ebp),%eax
    157e:	89 04 24             	mov    %eax,(%esp)
    1581:	e8 aa fd ff ff       	call   1330 <putc>
        putc(fd, c);
    1586:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    1589:	0f be c0             	movsbl %al,%eax
    158c:	89 44 24 04          	mov    %eax,0x4(%esp)
    1590:	8b 45 08             	mov    0x8(%ebp),%eax
    1593:	89 04 24             	mov    %eax,(%esp)
    1596:	e8 95 fd ff ff       	call   1330 <putc>
      }
      state = 0;
    159b:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    15a2:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
    15a6:	8b 55 0c             	mov    0xc(%ebp),%edx
    15a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
    15ac:	01 d0                	add    %edx,%eax
    15ae:	0f b6 00             	movzbl (%eax),%eax
    15b1:	84 c0                	test   %al,%al
    15b3:	0f 85 70 fe ff ff    	jne    1429 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
    15b9:	c9                   	leave  
    15ba:	c3                   	ret    
    15bb:	90                   	nop

000015bc <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    15bc:	55                   	push   %ebp
    15bd:	89 e5                	mov    %esp,%ebp
    15bf:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
    15c2:	8b 45 08             	mov    0x8(%ebp),%eax
    15c5:	83 e8 08             	sub    $0x8,%eax
    15c8:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    15cb:	a1 8c de 01 00       	mov    0x1de8c,%eax
    15d0:	89 45 fc             	mov    %eax,-0x4(%ebp)
    15d3:	eb 24                	jmp    15f9 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    15d5:	8b 45 fc             	mov    -0x4(%ebp),%eax
    15d8:	8b 00                	mov    (%eax),%eax
    15da:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    15dd:	77 12                	ja     15f1 <free+0x35>
    15df:	8b 45 f8             	mov    -0x8(%ebp),%eax
    15e2:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    15e5:	77 24                	ja     160b <free+0x4f>
    15e7:	8b 45 fc             	mov    -0x4(%ebp),%eax
    15ea:	8b 00                	mov    (%eax),%eax
    15ec:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    15ef:	77 1a                	ja     160b <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    15f1:	8b 45 fc             	mov    -0x4(%ebp),%eax
    15f4:	8b 00                	mov    (%eax),%eax
    15f6:	89 45 fc             	mov    %eax,-0x4(%ebp)
    15f9:	8b 45 f8             	mov    -0x8(%ebp),%eax
    15fc:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    15ff:	76 d4                	jbe    15d5 <free+0x19>
    1601:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1604:	8b 00                	mov    (%eax),%eax
    1606:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    1609:	76 ca                	jbe    15d5 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    160b:	8b 45 f8             	mov    -0x8(%ebp),%eax
    160e:	8b 40 04             	mov    0x4(%eax),%eax
    1611:	c1 e0 03             	shl    $0x3,%eax
    1614:	89 c2                	mov    %eax,%edx
    1616:	03 55 f8             	add    -0x8(%ebp),%edx
    1619:	8b 45 fc             	mov    -0x4(%ebp),%eax
    161c:	8b 00                	mov    (%eax),%eax
    161e:	39 c2                	cmp    %eax,%edx
    1620:	75 24                	jne    1646 <free+0x8a>
    bp->s.size += p->s.ptr->s.size;
    1622:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1625:	8b 50 04             	mov    0x4(%eax),%edx
    1628:	8b 45 fc             	mov    -0x4(%ebp),%eax
    162b:	8b 00                	mov    (%eax),%eax
    162d:	8b 40 04             	mov    0x4(%eax),%eax
    1630:	01 c2                	add    %eax,%edx
    1632:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1635:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
    1638:	8b 45 fc             	mov    -0x4(%ebp),%eax
    163b:	8b 00                	mov    (%eax),%eax
    163d:	8b 10                	mov    (%eax),%edx
    163f:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1642:	89 10                	mov    %edx,(%eax)
    1644:	eb 0a                	jmp    1650 <free+0x94>
  } else
    bp->s.ptr = p->s.ptr;
    1646:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1649:	8b 10                	mov    (%eax),%edx
    164b:	8b 45 f8             	mov    -0x8(%ebp),%eax
    164e:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
    1650:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1653:	8b 40 04             	mov    0x4(%eax),%eax
    1656:	c1 e0 03             	shl    $0x3,%eax
    1659:	03 45 fc             	add    -0x4(%ebp),%eax
    165c:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    165f:	75 20                	jne    1681 <free+0xc5>
    p->s.size += bp->s.size;
    1661:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1664:	8b 50 04             	mov    0x4(%eax),%edx
    1667:	8b 45 f8             	mov    -0x8(%ebp),%eax
    166a:	8b 40 04             	mov    0x4(%eax),%eax
    166d:	01 c2                	add    %eax,%edx
    166f:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1672:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
    1675:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1678:	8b 10                	mov    (%eax),%edx
    167a:	8b 45 fc             	mov    -0x4(%ebp),%eax
    167d:	89 10                	mov    %edx,(%eax)
    167f:	eb 08                	jmp    1689 <free+0xcd>
  } else
    p->s.ptr = bp;
    1681:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1684:	8b 55 f8             	mov    -0x8(%ebp),%edx
    1687:	89 10                	mov    %edx,(%eax)
  freep = p;
    1689:	8b 45 fc             	mov    -0x4(%ebp),%eax
    168c:	a3 8c de 01 00       	mov    %eax,0x1de8c
}
    1691:	c9                   	leave  
    1692:	c3                   	ret    

00001693 <morecore>:

static Header*
morecore(uint nu)
{
    1693:	55                   	push   %ebp
    1694:	89 e5                	mov    %esp,%ebp
    1696:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
    1699:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
    16a0:	77 07                	ja     16a9 <morecore+0x16>
    nu = 4096;
    16a2:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
    16a9:	8b 45 08             	mov    0x8(%ebp),%eax
    16ac:	c1 e0 03             	shl    $0x3,%eax
    16af:	89 04 24             	mov    %eax,(%esp)
    16b2:	e8 49 fc ff ff       	call   1300 <sbrk>
    16b7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
    16ba:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
    16be:	75 07                	jne    16c7 <morecore+0x34>
    return 0;
    16c0:	b8 00 00 00 00       	mov    $0x0,%eax
    16c5:	eb 22                	jmp    16e9 <morecore+0x56>
  hp = (Header*)p;
    16c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
    16ca:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
    16cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
    16d0:	8b 55 08             	mov    0x8(%ebp),%edx
    16d3:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
    16d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
    16d9:	83 c0 08             	add    $0x8,%eax
    16dc:	89 04 24             	mov    %eax,(%esp)
    16df:	e8 d8 fe ff ff       	call   15bc <free>
  return freep;
    16e4:	a1 8c de 01 00       	mov    0x1de8c,%eax
}
    16e9:	c9                   	leave  
    16ea:	c3                   	ret    

000016eb <malloc>:

void*
malloc(uint nbytes)
{
    16eb:	55                   	push   %ebp
    16ec:	89 e5                	mov    %esp,%ebp
    16ee:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    16f1:	8b 45 08             	mov    0x8(%ebp),%eax
    16f4:	83 c0 07             	add    $0x7,%eax
    16f7:	c1 e8 03             	shr    $0x3,%eax
    16fa:	83 c0 01             	add    $0x1,%eax
    16fd:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
    1700:	a1 8c de 01 00       	mov    0x1de8c,%eax
    1705:	89 45 f0             	mov    %eax,-0x10(%ebp)
    1708:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    170c:	75 23                	jne    1731 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
    170e:	c7 45 f0 84 de 01 00 	movl   $0x1de84,-0x10(%ebp)
    1715:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1718:	a3 8c de 01 00       	mov    %eax,0x1de8c
    171d:	a1 8c de 01 00       	mov    0x1de8c,%eax
    1722:	a3 84 de 01 00       	mov    %eax,0x1de84
    base.s.size = 0;
    1727:	c7 05 88 de 01 00 00 	movl   $0x0,0x1de88
    172e:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    1731:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1734:	8b 00                	mov    (%eax),%eax
    1736:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
    1739:	8b 45 f4             	mov    -0xc(%ebp),%eax
    173c:	8b 40 04             	mov    0x4(%eax),%eax
    173f:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    1742:	72 4d                	jb     1791 <malloc+0xa6>
      if(p->s.size == nunits)
    1744:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1747:	8b 40 04             	mov    0x4(%eax),%eax
    174a:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    174d:	75 0c                	jne    175b <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
    174f:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1752:	8b 10                	mov    (%eax),%edx
    1754:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1757:	89 10                	mov    %edx,(%eax)
    1759:	eb 26                	jmp    1781 <malloc+0x96>
      else {
        p->s.size -= nunits;
    175b:	8b 45 f4             	mov    -0xc(%ebp),%eax
    175e:	8b 40 04             	mov    0x4(%eax),%eax
    1761:	89 c2                	mov    %eax,%edx
    1763:	2b 55 ec             	sub    -0x14(%ebp),%edx
    1766:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1769:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
    176c:	8b 45 f4             	mov    -0xc(%ebp),%eax
    176f:	8b 40 04             	mov    0x4(%eax),%eax
    1772:	c1 e0 03             	shl    $0x3,%eax
    1775:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
    1778:	8b 45 f4             	mov    -0xc(%ebp),%eax
    177b:	8b 55 ec             	mov    -0x14(%ebp),%edx
    177e:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
    1781:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1784:	a3 8c de 01 00       	mov    %eax,0x1de8c
      return (void*)(p + 1);
    1789:	8b 45 f4             	mov    -0xc(%ebp),%eax
    178c:	83 c0 08             	add    $0x8,%eax
    178f:	eb 38                	jmp    17c9 <malloc+0xde>
    }
    if(p == freep)
    1791:	a1 8c de 01 00       	mov    0x1de8c,%eax
    1796:	39 45 f4             	cmp    %eax,-0xc(%ebp)
    1799:	75 1b                	jne    17b6 <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
    179b:	8b 45 ec             	mov    -0x14(%ebp),%eax
    179e:	89 04 24             	mov    %eax,(%esp)
    17a1:	e8 ed fe ff ff       	call   1693 <morecore>
    17a6:	89 45 f4             	mov    %eax,-0xc(%ebp)
    17a9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    17ad:	75 07                	jne    17b6 <malloc+0xcb>
        return 0;
    17af:	b8 00 00 00 00       	mov    $0x0,%eax
    17b4:	eb 13                	jmp    17c9 <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    17b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
    17b9:	89 45 f0             	mov    %eax,-0x10(%ebp)
    17bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
    17bf:	8b 00                	mov    (%eax),%eax
    17c1:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
    17c4:	e9 70 ff ff ff       	jmp    1739 <malloc+0x4e>
}
    17c9:	c9                   	leave  
    17ca:	c3                   	ret    
