
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
      53:	e8 74 13 00 00       	call   13cc <exit>
  
  switch(cmd->type){
      58:	8b 45 08             	mov    0x8(%ebp),%eax
      5b:	8b 00                	mov    (%eax),%eax
      5d:	83 f8 05             	cmp    $0x5,%eax
      60:	77 09                	ja     6b <runcmd+0x2b>
      62:	8b 04 85 5c 19 00 00 	mov    0x195c(,%eax,4),%eax
      69:	ff e0                	jmp    *%eax
  default:
    panic("runcmd");
      6b:	c7 04 24 30 19 00 00 	movl   $0x1930,(%esp)
      72:	e8 49 07 00 00       	call   7c0 <panic>

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
      8e:	e8 39 13 00 00       	call   13cc <exit>
    exec(ecmd->argv[0], ecmd->argv);
      93:	8b 45 f4             	mov    -0xc(%ebp),%eax
      96:	8d 50 04             	lea    0x4(%eax),%edx
      99:	8b 45 f4             	mov    -0xc(%ebp),%eax
      9c:	8b 40 04             	mov    0x4(%eax),%eax
      9f:	89 54 24 04          	mov    %edx,0x4(%esp)
      a3:	89 04 24             	mov    %eax,(%esp)
      a6:	e8 59 13 00 00       	call   1404 <exec>
    printf(2, "exec %s failed\n", ecmd->argv[0]);
      ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
      ae:	8b 40 04             	mov    0x4(%eax),%eax
      b1:	89 44 24 08          	mov    %eax,0x8(%esp)
      b5:	c7 44 24 04 37 19 00 	movl   $0x1937,0x4(%esp)
      bc:	00 
      bd:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
      c4:	e8 a2 14 00 00       	call   156b <printf>
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
      dd:	e8 12 13 00 00       	call   13f4 <close>
    if(open(rcmd->file, rcmd->mode) < 0){
      e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
      e5:	8b 50 10             	mov    0x10(%eax),%edx
      e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
      eb:	8b 40 08             	mov    0x8(%eax),%eax
      ee:	89 54 24 04          	mov    %edx,0x4(%esp)
      f2:	89 04 24             	mov    %eax,(%esp)
      f5:	e8 12 13 00 00       	call   140c <open>
      fa:	85 c0                	test   %eax,%eax
      fc:	79 2a                	jns    128 <runcmd+0xe8>
      printf(2, "open %s failed\n", rcmd->file);
      fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
     101:	8b 40 08             	mov    0x8(%eax),%eax
     104:	89 44 24 08          	mov    %eax,0x8(%esp)
     108:	c7 44 24 04 47 19 00 	movl   $0x1947,0x4(%esp)
     10f:	00 
     110:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     117:	e8 4f 14 00 00       	call   156b <printf>
      exit(EXIT_STATUS_DEFAULT);
     11c:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     123:	e8 a4 12 00 00       	call   13cc <exit>
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
     141:	e8 a7 06 00 00       	call   7ed <fork1>
     146:	85 c0                	test   %eax,%eax
     148:	75 0e                	jne    158 <runcmd+0x118>
      runcmd(lcmd->left);
     14a:	8b 45 ec             	mov    -0x14(%ebp),%eax
     14d:	8b 40 04             	mov    0x4(%eax),%eax
     150:	89 04 24             	mov    %eax,(%esp)
     153:	e8 e8 fe ff ff       	call   40 <runcmd>
    wait(0);
     158:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
     15f:	e8 70 12 00 00       	call   13d4 <wait>
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
     183:	e8 54 12 00 00       	call   13dc <pipe>
     188:	85 c0                	test   %eax,%eax
     18a:	79 0c                	jns    198 <runcmd+0x158>
      panic("pipe");
     18c:	c7 04 24 57 19 00 00 	movl   $0x1957,(%esp)
     193:	e8 28 06 00 00       	call   7c0 <panic>

    if( (left = fork1()) == 0){
     198:	e8 50 06 00 00       	call   7ed <fork1>
     19d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
     1a0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
     1a4:	75 3b                	jne    1e1 <runcmd+0x1a1>
      close(1);
     1a6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     1ad:	e8 42 12 00 00       	call   13f4 <close>
      dup(p[1]);
     1b2:	8b 45 d8             	mov    -0x28(%ebp),%eax
     1b5:	89 04 24             	mov    %eax,(%esp)
     1b8:	e8 87 12 00 00       	call   1444 <dup>
      close(p[0]);
     1bd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
     1c0:	89 04 24             	mov    %eax,(%esp)
     1c3:	e8 2c 12 00 00       	call   13f4 <close>
      close(p[1]);
     1c8:	8b 45 d8             	mov    -0x28(%ebp),%eax
     1cb:	89 04 24             	mov    %eax,(%esp)
     1ce:	e8 21 12 00 00       	call   13f4 <close>
      runcmd(pcmd->left);
     1d3:	8b 45 e8             	mov    -0x18(%ebp),%eax
     1d6:	8b 40 04             	mov    0x4(%eax),%eax
     1d9:	89 04 24             	mov    %eax,(%esp)
     1dc:	e8 5f fe ff ff       	call   40 <runcmd>
    }

    if( (right = fork1() ) == 0){
     1e1:	e8 07 06 00 00       	call   7ed <fork1>
     1e6:	89 45 e0             	mov    %eax,-0x20(%ebp)
     1e9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
     1ed:	75 3b                	jne    22a <runcmd+0x1ea>
      close(0);
     1ef:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
     1f6:	e8 f9 11 00 00       	call   13f4 <close>
      dup(p[0]);
     1fb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
     1fe:	89 04 24             	mov    %eax,(%esp)
     201:	e8 3e 12 00 00       	call   1444 <dup>
      close(p[0]);
     206:	8b 45 d4             	mov    -0x2c(%ebp),%eax
     209:	89 04 24             	mov    %eax,(%esp)
     20c:	e8 e3 11 00 00       	call   13f4 <close>
      close(p[1]);
     211:	8b 45 d8             	mov    -0x28(%ebp),%eax
     214:	89 04 24             	mov    %eax,(%esp)
     217:	e8 d8 11 00 00       	call   13f4 <close>
      runcmd(pcmd->right);
     21c:	8b 45 e8             	mov    -0x18(%ebp),%eax
     21f:	8b 40 08             	mov    0x8(%eax),%eax
     222:	89 04 24             	mov    %eax,(%esp)
     225:	e8 16 fe ff ff       	call   40 <runcmd>
    }
    close(p[0]);
     22a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
     22d:	89 04 24             	mov    %eax,(%esp)
     230:	e8 bf 11 00 00       	call   13f4 <close>
    close(p[1]);
     235:	8b 45 d8             	mov    -0x28(%ebp),%eax
     238:	89 04 24             	mov    %eax,(%esp)
     23b:	e8 b4 11 00 00       	call   13f4 <close>
    wait(0);
     240:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
     247:	e8 88 11 00 00       	call   13d4 <wait>
    wait(0);
     24c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
     253:	e8 7c 11 00 00       	call   13d4 <wait>
    break;
     258:	eb 1e                	jmp    278 <runcmd+0x238>
    
  case BACK:
    bcmd = (struct backcmd*)cmd;
     25a:	8b 45 08             	mov    0x8(%ebp),%eax
     25d:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(fork1() == 0)
     260:	e8 88 05 00 00       	call   7ed <fork1>
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
     27f:	e8 48 11 00 00       	call   13cc <exit>

00000284 <getcmd>:
}

int
getcmd(char *buf, int nbuf)
{
     284:	55                   	push   %ebp
     285:	89 e5                	mov    %esp,%ebp
     287:	83 ec 18             	sub    $0x18,%esp
  printf(2, "$ ");
     28a:	c7 44 24 04 74 19 00 	movl   $0x1974,0x4(%esp)
     291:	00 
     292:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     299:	e8 cd 12 00 00       	call   156b <printf>
  memset(buf, 0, nbuf);
     29e:	8b 45 0c             	mov    0xc(%ebp),%eax
     2a1:	89 44 24 08          	mov    %eax,0x8(%esp)
     2a5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     2ac:	00 
     2ad:	8b 45 08             	mov    0x8(%ebp),%eax
     2b0:	89 04 24             	mov    %eax,(%esp)
     2b3:	e8 6f 0f 00 00       	call   1227 <memset>
  gets(buf, nbuf);
     2b8:	8b 45 0c             	mov    0xc(%ebp),%eax
     2bb:	89 44 24 04          	mov    %eax,0x4(%esp)
     2bf:	8b 45 08             	mov    0x8(%ebp),%eax
     2c2:	89 04 24             	mov    %eax,(%esp)
     2c5:	e8 b4 0f 00 00       	call   127e <gets>
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
     30d:	8d 82 e0 1f 00 00    	lea    0x1fe0(%edx),%eax
     313:	8b 40 0c             	mov    0xc(%eax),%eax
     316:	85 c0                	test   %eax,%eax
     318:	0f 84 16 01 00 00    	je     434 <listJobs+0x152>
			list_pgroup(jobs_table[i].gid, arr, &size);
     31e:	8b 45 f4             	mov    -0xc(%ebp),%eax
     321:	c1 e0 04             	shl    $0x4,%eax
     324:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
     32b:	29 c2                	sub    %eax,%edx
     32d:	8d 82 e0 1f 00 00    	lea    0x1fe0(%edx),%eax
     333:	8b 40 08             	mov    0x8(%eax),%eax
     336:	8d 55 e8             	lea    -0x18(%ebp),%edx
     339:	89 54 24 08          	mov    %edx,0x8(%esp)
     33d:	8d 95 e8 fa ff ff    	lea    -0x518(%ebp),%edx
     343:	89 54 24 04          	mov    %edx,0x4(%esp)
     347:	89 04 24             	mov    %eax,(%esp)
     34a:	e8 2d 11 00 00       	call   147c <list_pgroup>
			if( size > 0){
     34f:	8b 45 e8             	mov    -0x18(%ebp),%eax
     352:	85 c0                	test   %eax,%eax
     354:	0f 8e be 00 00 00    	jle    418 <listJobs+0x136>
				hasJobs = 1;
     35a:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
				printf(1,"Job %d: %s (%d) \n", i, jobs_table[i].cmd, jobs_table[i].gid);
     361:	8b 45 f4             	mov    -0xc(%ebp),%eax
     364:	c1 e0 04             	shl    $0x4,%eax
     367:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
     36e:	29 c2                	sub    %eax,%edx
     370:	8d 82 e0 1f 00 00    	lea    0x1fe0(%edx),%eax
     376:	8b 48 08             	mov    0x8(%eax),%ecx
     379:	8b 45 f4             	mov    -0xc(%ebp),%eax
     37c:	c1 e0 04             	shl    $0x4,%eax
     37f:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
     386:	29 c2                	sub    %eax,%edx
     388:	8d 82 80 1f 00 00    	lea    0x1f80(%edx),%eax
     38e:	83 c0 04             	add    $0x4,%eax
     391:	89 4c 24 10          	mov    %ecx,0x10(%esp)
     395:	89 44 24 0c          	mov    %eax,0xc(%esp)
     399:	8b 45 f4             	mov    -0xc(%ebp),%eax
     39c:	89 44 24 08          	mov    %eax,0x8(%esp)
     3a0:	c7 44 24 04 77 19 00 	movl   $0x1977,0x4(%esp)
     3a7:	00 
     3a8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     3af:	e8 b7 11 00 00       	call   156b <printf>
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
     3f6:	c7 44 24 04 89 19 00 	movl   $0x1989,0x4(%esp)
     3fd:	00 
     3fe:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     405:	e8 61 11 00 00       	call   156b <printf>
		if(jobs_table[i].active){
			list_pgroup(jobs_table[i].gid, arr, &size);
			if( size > 0){
				hasJobs = 1;
				printf(1,"Job %d: %s (%d) \n", i, jobs_table[i].cmd, jobs_table[i].gid);
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
     427:	8d 82 e0 1f 00 00    	lea    0x1fe0(%edx),%eax
     42d:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
	int i,j;
	int size;
	int hasJobs = 0;
	process_info_entry arr[64];

	for(i=0; i< jobs_counter; i++){
     434:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
     438:	a1 80 df 01 00       	mov    0x1df80,%eax
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
     44c:	c7 44 24 04 92 19 00 	movl   $0x1992,0x4(%esp)
     453:	00 
     454:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     45b:	e8 0b 11 00 00       	call   156b <printf>
	}
}
     460:	c9                   	leave  
     461:	c3                   	ret    

00000462 <move_to_foreground>:

int move_to_foreground(int job_id){
     462:	55                   	push   %ebp
     463:	89 e5                	mov    %esp,%ebp
     465:	83 ec 28             	sub    $0x28,%esp
	int i;//, desired_job_idx;
	int fgRet = -1;
     468:	c7 45 f0 ff ff ff ff 	movl   $0xffffffff,-0x10(%ebp)
	//printf(1," asked to fg %d \n", job_id);

	if(job_id == -1){
     46f:	83 7d 08 ff          	cmpl   $0xffffffff,0x8(%ebp)
     473:	0f 85 81 00 00 00    	jne    4fa <move_to_foreground+0x98>
		for (i = 0; i < jobs_counter; i++) {
     479:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     480:	eb 6c                	jmp    4ee <move_to_foreground+0x8c>
			if( jobs_table[i].active){
     482:	8b 45 f4             	mov    -0xc(%ebp),%eax
     485:	c1 e0 04             	shl    $0x4,%eax
     488:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
     48f:	29 c2                	sub    %eax,%edx
     491:	8d 82 e0 1f 00 00    	lea    0x1fe0(%edx),%eax
     497:	8b 40 0c             	mov    0xc(%eax),%eax
     49a:	85 c0                	test   %eax,%eax
     49c:	74 4c                	je     4ea <move_to_foreground+0x88>
				fgRet = foreground(jobs_table[i].gid);
     49e:	8b 45 f4             	mov    -0xc(%ebp),%eax
     4a1:	c1 e0 04             	shl    $0x4,%eax
     4a4:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
     4ab:	29 c2                	sub    %eax,%edx
     4ad:	8d 82 e0 1f 00 00    	lea    0x1fe0(%edx),%eax
     4b3:	8b 40 08             	mov    0x8(%eax),%eax
     4b6:	89 04 24             	mov    %eax,(%esp)
     4b9:	e8 c6 0f 00 00       	call   1484 <foreground>
     4be:	89 45 f0             	mov    %eax,-0x10(%ebp)
				jobs_table[i].active = 0;
     4c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
     4c4:	c1 e0 04             	shl    $0x4,%eax
     4c7:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
     4ce:	29 c2                	sub    %eax,%edx
     4d0:	8d 82 e0 1f 00 00    	lea    0x1fe0(%edx),%eax
     4d6:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
				if (fgRet != -1) return 0;
     4dd:	83 7d f0 ff          	cmpl   $0xffffffff,-0x10(%ebp)
     4e1:	74 07                	je     4ea <move_to_foreground+0x88>
     4e3:	b8 00 00 00 00       	mov    $0x0,%eax
     4e8:	eb 74                	jmp    55e <move_to_foreground+0xfc>
	int i;//, desired_job_idx;
	int fgRet = -1;
	//printf(1," asked to fg %d \n", job_id);

	if(job_id == -1){
		for (i = 0; i < jobs_counter; i++) {
     4ea:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
     4ee:	a1 80 df 01 00       	mov    0x1df80,%eax
     4f3:	39 45 f4             	cmp    %eax,-0xc(%ebp)
     4f6:	7c 8a                	jl     482 <move_to_foreground+0x20>
     4f8:	eb 5f                	jmp    559 <move_to_foreground+0xf7>
				jobs_table[i].active = 0;
				if (fgRet != -1) return 0;
			}
		}
	}
	else if( jobs_table[job_id].active){
     4fa:	8b 45 08             	mov    0x8(%ebp),%eax
     4fd:	c1 e0 04             	shl    $0x4,%eax
     500:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
     507:	29 c2                	sub    %eax,%edx
     509:	8d 82 e0 1f 00 00    	lea    0x1fe0(%edx),%eax
     50f:	8b 40 0c             	mov    0xc(%eax),%eax
     512:	85 c0                	test   %eax,%eax
     514:	74 43                	je     559 <move_to_foreground+0xf7>
		foreground(jobs_table[job_id].gid);
     516:	8b 45 08             	mov    0x8(%ebp),%eax
     519:	c1 e0 04             	shl    $0x4,%eax
     51c:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
     523:	29 c2                	sub    %eax,%edx
     525:	8d 82 e0 1f 00 00    	lea    0x1fe0(%edx),%eax
     52b:	8b 40 08             	mov    0x8(%eax),%eax
     52e:	89 04 24             	mov    %eax,(%esp)
     531:	e8 4e 0f 00 00       	call   1484 <foreground>
		jobs_table[job_id].active = 0;
     536:	8b 45 08             	mov    0x8(%ebp),%eax
     539:	c1 e0 04             	shl    $0x4,%eax
     53c:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
     543:	29 c2                	sub    %eax,%edx
     545:	8d 82 e0 1f 00 00    	lea    0x1fe0(%edx),%eax
     54b:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
		return 0;
     552:	b8 00 00 00 00       	mov    $0x0,%eax
     557:	eb 05                	jmp    55e <move_to_foreground+0xfc>
	}

	return -1;
     559:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
     55e:	c9                   	leave  
     55f:	c3                   	ret    

00000560 <main>:
//	printf(1," asta la vista babe ;\n");
//	return (found? 0 : -1);
//}
int
main(void)
{
     560:	55                   	push   %ebp
     561:	89 e5                	mov    %esp,%ebp
     563:	83 e4 f0             	and    $0xfffffff0,%esp
     566:	83 ec 20             	sub    $0x20,%esp
  static char buf[100];
  int fd;
  int child_pid;
  int job_id;
  
  jobs_table[0].active = 0;
     569:	c7 05 ec 1f 00 00 00 	movl   $0x0,0x1fec
     570:	00 00 00 
  if(jobs_table[0].active) printf(1, " just so it wont cry on unused");
     573:	a1 ec 1f 00 00       	mov    0x1fec,%eax
     578:	85 c0                	test   %eax,%eax
     57a:	74 2f                	je     5ab <main+0x4b>
     57c:	c7 44 24 04 a8 19 00 	movl   $0x19a8,0x4(%esp)
     583:	00 
     584:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     58b:	e8 db 0f 00 00       	call   156b <printf>

  // Assumes three file descriptors open.
  while((fd = open("console", O_RDWR)) >= 0){
     590:	eb 19                	jmp    5ab <main+0x4b>
    if(fd >= 3){
     592:	83 7c 24 18 02       	cmpl   $0x2,0x18(%esp)
     597:	7e 12                	jle    5ab <main+0x4b>
      close(fd);
     599:	8b 44 24 18          	mov    0x18(%esp),%eax
     59d:	89 04 24             	mov    %eax,(%esp)
     5a0:	e8 4f 0e 00 00       	call   13f4 <close>
      break;
     5a5:	90                   	nop
    }
  }
  
  // Read and run input commands.
  while(getcmd(buf, sizeof(buf)) >= 0){
     5a6:	e9 ed 01 00 00       	jmp    798 <main+0x238>
  
  jobs_table[0].active = 0;
  if(jobs_table[0].active) printf(1, " just so it wont cry on unused");

  // Assumes three file descriptors open.
  while((fd = open("console", O_RDWR)) >= 0){
     5ab:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
     5b2:	00 
     5b3:	c7 04 24 c7 19 00 00 	movl   $0x19c7,(%esp)
     5ba:	e8 4d 0e 00 00       	call   140c <open>
     5bf:	89 44 24 18          	mov    %eax,0x18(%esp)
     5c3:	83 7c 24 18 00       	cmpl   $0x0,0x18(%esp)
     5c8:	79 c8                	jns    592 <main+0x32>
      break;
    }
  }
  
  // Read and run input commands.
  while(getcmd(buf, sizeof(buf)) >= 0){
     5ca:	e9 c9 01 00 00       	jmp    798 <main+0x238>
    if(buf[0] == 'c' && buf[1] == 'd' && buf[2] == ' '){
     5cf:	0f b6 05 a0 df 01 00 	movzbl 0x1dfa0,%eax
     5d6:	3c 63                	cmp    $0x63,%al
     5d8:	75 61                	jne    63b <main+0xdb>
     5da:	0f b6 05 a1 df 01 00 	movzbl 0x1dfa1,%eax
     5e1:	3c 64                	cmp    $0x64,%al
     5e3:	75 56                	jne    63b <main+0xdb>
     5e5:	0f b6 05 a2 df 01 00 	movzbl 0x1dfa2,%eax
     5ec:	3c 20                	cmp    $0x20,%al
     5ee:	75 4b                	jne    63b <main+0xdb>
      // Clumsy but will have to do for now.
      // Chdir has no effect on the parent if run in the child.
      buf[strlen(buf)-1] = 0;  // chop \n
     5f0:	c7 04 24 a0 df 01 00 	movl   $0x1dfa0,(%esp)
     5f7:	e8 06 0c 00 00       	call   1202 <strlen>
     5fc:	83 e8 01             	sub    $0x1,%eax
     5ff:	c6 80 a0 df 01 00 00 	movb   $0x0,0x1dfa0(%eax)
      if(chdir(buf+3) < 0)
     606:	c7 04 24 a3 df 01 00 	movl   $0x1dfa3,(%esp)
     60d:	e8 2a 0e 00 00       	call   143c <chdir>
     612:	85 c0                	test   %eax,%eax
     614:	0f 89 7d 01 00 00    	jns    797 <main+0x237>
        printf(2, "cannot cd %s\n", buf+3);
     61a:	c7 44 24 08 a3 df 01 	movl   $0x1dfa3,0x8(%esp)
     621:	00 
     622:	c7 44 24 04 cf 19 00 	movl   $0x19cf,0x4(%esp)
     629:	00 
     62a:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     631:	e8 35 0f 00 00       	call   156b <printf>
      continue;
     636:	e9 5c 01 00 00       	jmp    797 <main+0x237>
    }

    if(buf[0] == 'j' && buf[1] == 'o' && buf[2] == 'b' && buf[3] == 's' && buf[4] == '\n'){
     63b:	0f b6 05 a0 df 01 00 	movzbl 0x1dfa0,%eax
     642:	3c 6a                	cmp    $0x6a,%al
     644:	75 36                	jne    67c <main+0x11c>
     646:	0f b6 05 a1 df 01 00 	movzbl 0x1dfa1,%eax
     64d:	3c 6f                	cmp    $0x6f,%al
     64f:	75 2b                	jne    67c <main+0x11c>
     651:	0f b6 05 a2 df 01 00 	movzbl 0x1dfa2,%eax
     658:	3c 62                	cmp    $0x62,%al
     65a:	75 20                	jne    67c <main+0x11c>
     65c:	0f b6 05 a3 df 01 00 	movzbl 0x1dfa3,%eax
     663:	3c 73                	cmp    $0x73,%al
     665:	75 15                	jne    67c <main+0x11c>
     667:	0f b6 05 a4 df 01 00 	movzbl 0x1dfa4,%eax
     66e:	3c 0a                	cmp    $0xa,%al
     670:	75 0a                	jne    67c <main+0x11c>
      listJobs();
     672:	e8 6b fc ff ff       	call   2e2 <listJobs>
	  continue;
     677:	e9 1c 01 00 00       	jmp    798 <main+0x238>
	}

    if(buf[0] == 'f' && buf[1] == 'g' ){
     67c:	0f b6 05 a0 df 01 00 	movzbl 0x1dfa0,%eax
     683:	3c 66                	cmp    $0x66,%al
     685:	75 4c                	jne    6d3 <main+0x173>
     687:	0f b6 05 a1 df 01 00 	movzbl 0x1dfa1,%eax
     68e:	3c 67                	cmp    $0x67,%al
     690:	75 41                	jne    6d3 <main+0x173>
		if( buf[2] == '\n' ){
     692:	0f b6 05 a2 df 01 00 	movzbl 0x1dfa2,%eax
     699:	3c 0a                	cmp    $0xa,%al
     69b:	75 0a                	jne    6a7 <main+0x147>
			job_id = -1;
     69d:	c7 44 24 1c ff ff ff 	movl   $0xffffffff,0x1c(%esp)
     6a4:	ff 
     6a5:	eb 1b                	jmp    6c2 <main+0x162>
		}
		else if( buf[2] == ' ' ){
     6a7:	0f b6 05 a2 df 01 00 	movzbl 0x1dfa2,%eax
     6ae:	3c 20                	cmp    $0x20,%al
     6b0:	75 10                	jne    6c2 <main+0x162>
			job_id = atoi(buf+3);
     6b2:	c7 04 24 a3 df 01 00 	movl   $0x1dfa3,(%esp)
     6b9:	e8 7d 0c 00 00       	call   133b <atoi>
     6be:	89 44 24 1c          	mov    %eax,0x1c(%esp)
		}

		move_to_foreground(job_id);
     6c2:	8b 44 24 1c          	mov    0x1c(%esp),%eax
     6c6:	89 04 24             	mov    %eax,(%esp)
     6c9:	e8 94 fd ff ff       	call   462 <move_to_foreground>
		continue;
     6ce:	e9 c5 00 00 00       	jmp    798 <main+0x238>
	}

    if((child_pid = fork1()) == 0){
     6d3:	e8 15 01 00 00       	call   7ed <fork1>
     6d8:	89 44 24 14          	mov    %eax,0x14(%esp)
     6dc:	83 7c 24 14 00       	cmpl   $0x0,0x14(%esp)
     6e1:	75 14                	jne    6f7 <main+0x197>
        runcmd(parsecmd(buf));
     6e3:	c7 04 24 a0 df 01 00 	movl   $0x1dfa0,(%esp)
     6ea:	e8 70 04 00 00       	call   b5f <parsecmd>
     6ef:	89 04 24             	mov    %eax,(%esp)
     6f2:	e8 49 f9 ff ff       	call   40 <runcmd>
    }
    //keep track on jobs
    jobs_table[jobs_counter].gid = child_pid;
     6f7:	a1 80 df 01 00       	mov    0x1df80,%eax
     6fc:	c1 e0 04             	shl    $0x4,%eax
     6ff:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
     706:	29 c2                	sub    %eax,%edx
     708:	81 c2 e0 1f 00 00    	add    $0x1fe0,%edx
     70e:	8b 44 24 14          	mov    0x14(%esp),%eax
     712:	89 42 08             	mov    %eax,0x8(%edx)
    jobs_table[jobs_counter].num = jobs_counter;
     715:	a1 80 df 01 00       	mov    0x1df80,%eax
     71a:	8b 0d 80 df 01 00    	mov    0x1df80,%ecx
     720:	c1 e0 04             	shl    $0x4,%eax
     723:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
     72a:	29 c2                	sub    %eax,%edx
     72c:	8d 82 80 1f 00 00    	lea    0x1f80(%edx),%eax
     732:	89 08                	mov    %ecx,(%eax)
    jobs_table[jobs_counter].active = 1;
     734:	a1 80 df 01 00       	mov    0x1df80,%eax
     739:	c1 e0 04             	shl    $0x4,%eax
     73c:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
     743:	29 c2                	sub    %eax,%edx
     745:	8d 82 e0 1f 00 00    	lea    0x1fe0(%edx),%eax
     74b:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
    copyString(jobs_table[jobs_counter].cmd, buf);
     752:	a1 80 df 01 00       	mov    0x1df80,%eax
     757:	c1 e0 04             	shl    $0x4,%eax
     75a:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
     761:	29 c2                	sub    %eax,%edx
     763:	8d 82 80 1f 00 00    	lea    0x1f80(%edx),%eax
     769:	83 c0 04             	add    $0x4,%eax
     76c:	c7 44 24 04 a0 df 01 	movl   $0x1dfa0,0x4(%esp)
     773:	00 
     774:	89 04 24             	mov    %eax,(%esp)
     777:	e8 84 f8 ff ff       	call   0 <copyString>
	jobs_counter++;
     77c:	a1 80 df 01 00       	mov    0x1df80,%eax
     781:	83 c0 01             	add    $0x1,%eax
     784:	a3 80 df 01 00       	mov    %eax,0x1df80

    wait(0);
     789:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
     790:	e8 3f 0c 00 00       	call   13d4 <wait>
     795:	eb 01                	jmp    798 <main+0x238>
      // Clumsy but will have to do for now.
      // Chdir has no effect on the parent if run in the child.
      buf[strlen(buf)-1] = 0;  // chop \n
      if(chdir(buf+3) < 0)
        printf(2, "cannot cd %s\n", buf+3);
      continue;
     797:	90                   	nop
      break;
    }
  }
  
  // Read and run input commands.
  while(getcmd(buf, sizeof(buf)) >= 0){
     798:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
     79f:	00 
     7a0:	c7 04 24 a0 df 01 00 	movl   $0x1dfa0,(%esp)
     7a7:	e8 d8 fa ff ff       	call   284 <getcmd>
     7ac:	85 c0                	test   %eax,%eax
     7ae:	0f 89 1b fe ff ff    	jns    5cf <main+0x6f>
    copyString(jobs_table[jobs_counter].cmd, buf);
	jobs_counter++;

    wait(0);
  }
  exit(EXIT_STATUS_DEFAULT);
     7b4:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     7bb:	e8 0c 0c 00 00       	call   13cc <exit>

000007c0 <panic>:
}

void
panic(char *s)
{
     7c0:	55                   	push   %ebp
     7c1:	89 e5                	mov    %esp,%ebp
     7c3:	83 ec 18             	sub    $0x18,%esp
  printf(2, "%s\n", s);
     7c6:	8b 45 08             	mov    0x8(%ebp),%eax
     7c9:	89 44 24 08          	mov    %eax,0x8(%esp)
     7cd:	c7 44 24 04 dd 19 00 	movl   $0x19dd,0x4(%esp)
     7d4:	00 
     7d5:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     7dc:	e8 8a 0d 00 00       	call   156b <printf>
  exit(EXIT_STATUS_DEFAULT);
     7e1:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     7e8:	e8 df 0b 00 00       	call   13cc <exit>

000007ed <fork1>:
}

int
fork1(void)
{
     7ed:	55                   	push   %ebp
     7ee:	89 e5                	mov    %esp,%ebp
     7f0:	83 ec 28             	sub    $0x28,%esp
  int pid;
  
  pid = fork();
     7f3:	e8 cc 0b 00 00       	call   13c4 <fork>
     7f8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pid == -1)
     7fb:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
     7ff:	75 0c                	jne    80d <fork1+0x20>
    panic("fork");
     801:	c7 04 24 e1 19 00 00 	movl   $0x19e1,(%esp)
     808:	e8 b3 ff ff ff       	call   7c0 <panic>
  return pid;
     80d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     810:	c9                   	leave  
     811:	c3                   	ret    

00000812 <execcmd>:
//PAGEBREAK!
// Constructors

struct cmd*
execcmd(void)
{
     812:	55                   	push   %ebp
     813:	89 e5                	mov    %esp,%ebp
     815:	83 ec 28             	sub    $0x28,%esp
  struct execcmd *cmd;

  cmd = malloc(sizeof(*cmd));
     818:	c7 04 24 54 00 00 00 	movl   $0x54,(%esp)
     81f:	e8 2b 10 00 00       	call   184f <malloc>
     824:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(cmd, 0, sizeof(*cmd));
     827:	c7 44 24 08 54 00 00 	movl   $0x54,0x8(%esp)
     82e:	00 
     82f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     836:	00 
     837:	8b 45 f4             	mov    -0xc(%ebp),%eax
     83a:	89 04 24             	mov    %eax,(%esp)
     83d:	e8 e5 09 00 00       	call   1227 <memset>
  cmd->type = EXEC;
     842:	8b 45 f4             	mov    -0xc(%ebp),%eax
     845:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  return (struct cmd*)cmd;
     84b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     84e:	c9                   	leave  
     84f:	c3                   	ret    

00000850 <redircmd>:

struct cmd*
redircmd(struct cmd *subcmd, char *file, char *efile, int mode, int fd)
{
     850:	55                   	push   %ebp
     851:	89 e5                	mov    %esp,%ebp
     853:	83 ec 28             	sub    $0x28,%esp
  struct redircmd *cmd;

  cmd = malloc(sizeof(*cmd));
     856:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
     85d:	e8 ed 0f 00 00       	call   184f <malloc>
     862:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(cmd, 0, sizeof(*cmd));
     865:	c7 44 24 08 18 00 00 	movl   $0x18,0x8(%esp)
     86c:	00 
     86d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     874:	00 
     875:	8b 45 f4             	mov    -0xc(%ebp),%eax
     878:	89 04 24             	mov    %eax,(%esp)
     87b:	e8 a7 09 00 00       	call   1227 <memset>
  cmd->type = REDIR;
     880:	8b 45 f4             	mov    -0xc(%ebp),%eax
     883:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  cmd->cmd = subcmd;
     889:	8b 45 f4             	mov    -0xc(%ebp),%eax
     88c:	8b 55 08             	mov    0x8(%ebp),%edx
     88f:	89 50 04             	mov    %edx,0x4(%eax)
  cmd->file = file;
     892:	8b 45 f4             	mov    -0xc(%ebp),%eax
     895:	8b 55 0c             	mov    0xc(%ebp),%edx
     898:	89 50 08             	mov    %edx,0x8(%eax)
  cmd->efile = efile;
     89b:	8b 45 f4             	mov    -0xc(%ebp),%eax
     89e:	8b 55 10             	mov    0x10(%ebp),%edx
     8a1:	89 50 0c             	mov    %edx,0xc(%eax)
  cmd->mode = mode;
     8a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
     8a7:	8b 55 14             	mov    0x14(%ebp),%edx
     8aa:	89 50 10             	mov    %edx,0x10(%eax)
  cmd->fd = fd;
     8ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
     8b0:	8b 55 18             	mov    0x18(%ebp),%edx
     8b3:	89 50 14             	mov    %edx,0x14(%eax)
  return (struct cmd*)cmd;
     8b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     8b9:	c9                   	leave  
     8ba:	c3                   	ret    

000008bb <pipecmd>:

struct cmd*
pipecmd(struct cmd *left, struct cmd *right)
{
     8bb:	55                   	push   %ebp
     8bc:	89 e5                	mov    %esp,%ebp
     8be:	83 ec 28             	sub    $0x28,%esp
  struct pipecmd *cmd;

  cmd = malloc(sizeof(*cmd));
     8c1:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
     8c8:	e8 82 0f 00 00       	call   184f <malloc>
     8cd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(cmd, 0, sizeof(*cmd));
     8d0:	c7 44 24 08 0c 00 00 	movl   $0xc,0x8(%esp)
     8d7:	00 
     8d8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     8df:	00 
     8e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
     8e3:	89 04 24             	mov    %eax,(%esp)
     8e6:	e8 3c 09 00 00       	call   1227 <memset>
  cmd->type = PIPE;
     8eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
     8ee:	c7 00 03 00 00 00    	movl   $0x3,(%eax)
  cmd->left = left;
     8f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
     8f7:	8b 55 08             	mov    0x8(%ebp),%edx
     8fa:	89 50 04             	mov    %edx,0x4(%eax)
  cmd->right = right;
     8fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
     900:	8b 55 0c             	mov    0xc(%ebp),%edx
     903:	89 50 08             	mov    %edx,0x8(%eax)
  return (struct cmd*)cmd;
     906:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     909:	c9                   	leave  
     90a:	c3                   	ret    

0000090b <listcmd>:

struct cmd*
listcmd(struct cmd *left, struct cmd *right)
{
     90b:	55                   	push   %ebp
     90c:	89 e5                	mov    %esp,%ebp
     90e:	83 ec 28             	sub    $0x28,%esp
  struct listcmd *cmd;

  cmd = malloc(sizeof(*cmd));
     911:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
     918:	e8 32 0f 00 00       	call   184f <malloc>
     91d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(cmd, 0, sizeof(*cmd));
     920:	c7 44 24 08 0c 00 00 	movl   $0xc,0x8(%esp)
     927:	00 
     928:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     92f:	00 
     930:	8b 45 f4             	mov    -0xc(%ebp),%eax
     933:	89 04 24             	mov    %eax,(%esp)
     936:	e8 ec 08 00 00       	call   1227 <memset>
  cmd->type = LIST;
     93b:	8b 45 f4             	mov    -0xc(%ebp),%eax
     93e:	c7 00 04 00 00 00    	movl   $0x4,(%eax)
  cmd->left = left;
     944:	8b 45 f4             	mov    -0xc(%ebp),%eax
     947:	8b 55 08             	mov    0x8(%ebp),%edx
     94a:	89 50 04             	mov    %edx,0x4(%eax)
  cmd->right = right;
     94d:	8b 45 f4             	mov    -0xc(%ebp),%eax
     950:	8b 55 0c             	mov    0xc(%ebp),%edx
     953:	89 50 08             	mov    %edx,0x8(%eax)
  return (struct cmd*)cmd;
     956:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     959:	c9                   	leave  
     95a:	c3                   	ret    

0000095b <backcmd>:

struct cmd*
backcmd(struct cmd *subcmd)
{
     95b:	55                   	push   %ebp
     95c:	89 e5                	mov    %esp,%ebp
     95e:	83 ec 28             	sub    $0x28,%esp
  struct backcmd *cmd;

  cmd = malloc(sizeof(*cmd));
     961:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
     968:	e8 e2 0e 00 00       	call   184f <malloc>
     96d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(cmd, 0, sizeof(*cmd));
     970:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
     977:	00 
     978:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     97f:	00 
     980:	8b 45 f4             	mov    -0xc(%ebp),%eax
     983:	89 04 24             	mov    %eax,(%esp)
     986:	e8 9c 08 00 00       	call   1227 <memset>
  cmd->type = BACK;
     98b:	8b 45 f4             	mov    -0xc(%ebp),%eax
     98e:	c7 00 05 00 00 00    	movl   $0x5,(%eax)
  cmd->cmd = subcmd;
     994:	8b 45 f4             	mov    -0xc(%ebp),%eax
     997:	8b 55 08             	mov    0x8(%ebp),%edx
     99a:	89 50 04             	mov    %edx,0x4(%eax)
  return (struct cmd*)cmd;
     99d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     9a0:	c9                   	leave  
     9a1:	c3                   	ret    

000009a2 <gettoken>:
char whitespace[] = " \t\r\n\v";
char symbols[] = "<|>&;()";

int
gettoken(char **ps, char *es, char **q, char **eq)
{
     9a2:	55                   	push   %ebp
     9a3:	89 e5                	mov    %esp,%ebp
     9a5:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int ret;
  
  s = *ps;
     9a8:	8b 45 08             	mov    0x8(%ebp),%eax
     9ab:	8b 00                	mov    (%eax),%eax
     9ad:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(s < es && strchr(whitespace, *s))
     9b0:	eb 04                	jmp    9b6 <gettoken+0x14>
    s++;
     9b2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
{
  char *s;
  int ret;
  
  s = *ps;
  while(s < es && strchr(whitespace, *s))
     9b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
     9b9:	3b 45 0c             	cmp    0xc(%ebp),%eax
     9bc:	73 1d                	jae    9db <gettoken+0x39>
     9be:	8b 45 f4             	mov    -0xc(%ebp),%eax
     9c1:	0f b6 00             	movzbl (%eax),%eax
     9c4:	0f be c0             	movsbl %al,%eax
     9c7:	89 44 24 04          	mov    %eax,0x4(%esp)
     9cb:	c7 04 24 50 1f 00 00 	movl   $0x1f50,(%esp)
     9d2:	e8 74 08 00 00       	call   124b <strchr>
     9d7:	85 c0                	test   %eax,%eax
     9d9:	75 d7                	jne    9b2 <gettoken+0x10>
    s++;
  if(q)
     9db:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
     9df:	74 08                	je     9e9 <gettoken+0x47>
    *q = s;
     9e1:	8b 45 10             	mov    0x10(%ebp),%eax
     9e4:	8b 55 f4             	mov    -0xc(%ebp),%edx
     9e7:	89 10                	mov    %edx,(%eax)
  ret = *s;
     9e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
     9ec:	0f b6 00             	movzbl (%eax),%eax
     9ef:	0f be c0             	movsbl %al,%eax
     9f2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  switch(*s){
     9f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
     9f8:	0f b6 00             	movzbl (%eax),%eax
     9fb:	0f be c0             	movsbl %al,%eax
     9fe:	83 f8 3c             	cmp    $0x3c,%eax
     a01:	7f 1e                	jg     a21 <gettoken+0x7f>
     a03:	83 f8 3b             	cmp    $0x3b,%eax
     a06:	7d 23                	jge    a2b <gettoken+0x89>
     a08:	83 f8 29             	cmp    $0x29,%eax
     a0b:	7f 3f                	jg     a4c <gettoken+0xaa>
     a0d:	83 f8 28             	cmp    $0x28,%eax
     a10:	7d 19                	jge    a2b <gettoken+0x89>
     a12:	85 c0                	test   %eax,%eax
     a14:	0f 84 83 00 00 00    	je     a9d <gettoken+0xfb>
     a1a:	83 f8 26             	cmp    $0x26,%eax
     a1d:	74 0c                	je     a2b <gettoken+0x89>
     a1f:	eb 2b                	jmp    a4c <gettoken+0xaa>
     a21:	83 f8 3e             	cmp    $0x3e,%eax
     a24:	74 0b                	je     a31 <gettoken+0x8f>
     a26:	83 f8 7c             	cmp    $0x7c,%eax
     a29:	75 21                	jne    a4c <gettoken+0xaa>
  case '(':
  case ')':
  case ';':
  case '&':
  case '<':
    s++;
     a2b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    break;
     a2f:	eb 73                	jmp    aa4 <gettoken+0x102>
  case '>':
    s++;
     a31:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(*s == '>'){
     a35:	8b 45 f4             	mov    -0xc(%ebp),%eax
     a38:	0f b6 00             	movzbl (%eax),%eax
     a3b:	3c 3e                	cmp    $0x3e,%al
     a3d:	75 61                	jne    aa0 <gettoken+0xfe>
      ret = '+';
     a3f:	c7 45 f0 2b 00 00 00 	movl   $0x2b,-0x10(%ebp)
      s++;
     a46:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    }
    break;
     a4a:	eb 54                	jmp    aa0 <gettoken+0xfe>
  default:
    ret = 'a';
     a4c:	c7 45 f0 61 00 00 00 	movl   $0x61,-0x10(%ebp)
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
     a53:	eb 04                	jmp    a59 <gettoken+0xb7>
      s++;
     a55:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      s++;
    }
    break;
  default:
    ret = 'a';
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
     a59:	8b 45 f4             	mov    -0xc(%ebp),%eax
     a5c:	3b 45 0c             	cmp    0xc(%ebp),%eax
     a5f:	73 42                	jae    aa3 <gettoken+0x101>
     a61:	8b 45 f4             	mov    -0xc(%ebp),%eax
     a64:	0f b6 00             	movzbl (%eax),%eax
     a67:	0f be c0             	movsbl %al,%eax
     a6a:	89 44 24 04          	mov    %eax,0x4(%esp)
     a6e:	c7 04 24 50 1f 00 00 	movl   $0x1f50,(%esp)
     a75:	e8 d1 07 00 00       	call   124b <strchr>
     a7a:	85 c0                	test   %eax,%eax
     a7c:	75 25                	jne    aa3 <gettoken+0x101>
     a7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
     a81:	0f b6 00             	movzbl (%eax),%eax
     a84:	0f be c0             	movsbl %al,%eax
     a87:	89 44 24 04          	mov    %eax,0x4(%esp)
     a8b:	c7 04 24 56 1f 00 00 	movl   $0x1f56,(%esp)
     a92:	e8 b4 07 00 00       	call   124b <strchr>
     a97:	85 c0                	test   %eax,%eax
     a99:	74 ba                	je     a55 <gettoken+0xb3>
      s++;
    break;
     a9b:	eb 06                	jmp    aa3 <gettoken+0x101>
  if(q)
    *q = s;
  ret = *s;
  switch(*s){
  case 0:
    break;
     a9d:	90                   	nop
     a9e:	eb 04                	jmp    aa4 <gettoken+0x102>
    s++;
    if(*s == '>'){
      ret = '+';
      s++;
    }
    break;
     aa0:	90                   	nop
     aa1:	eb 01                	jmp    aa4 <gettoken+0x102>
  default:
    ret = 'a';
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
      s++;
    break;
     aa3:	90                   	nop
  }
  if(eq)
     aa4:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
     aa8:	74 0e                	je     ab8 <gettoken+0x116>
    *eq = s;
     aaa:	8b 45 14             	mov    0x14(%ebp),%eax
     aad:	8b 55 f4             	mov    -0xc(%ebp),%edx
     ab0:	89 10                	mov    %edx,(%eax)
  
  while(s < es && strchr(whitespace, *s))
     ab2:	eb 04                	jmp    ab8 <gettoken+0x116>
    s++;
     ab4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    break;
  }
  if(eq)
    *eq = s;
  
  while(s < es && strchr(whitespace, *s))
     ab8:	8b 45 f4             	mov    -0xc(%ebp),%eax
     abb:	3b 45 0c             	cmp    0xc(%ebp),%eax
     abe:	73 1d                	jae    add <gettoken+0x13b>
     ac0:	8b 45 f4             	mov    -0xc(%ebp),%eax
     ac3:	0f b6 00             	movzbl (%eax),%eax
     ac6:	0f be c0             	movsbl %al,%eax
     ac9:	89 44 24 04          	mov    %eax,0x4(%esp)
     acd:	c7 04 24 50 1f 00 00 	movl   $0x1f50,(%esp)
     ad4:	e8 72 07 00 00       	call   124b <strchr>
     ad9:	85 c0                	test   %eax,%eax
     adb:	75 d7                	jne    ab4 <gettoken+0x112>
    s++;
  *ps = s;
     add:	8b 45 08             	mov    0x8(%ebp),%eax
     ae0:	8b 55 f4             	mov    -0xc(%ebp),%edx
     ae3:	89 10                	mov    %edx,(%eax)
  return ret;
     ae5:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
     ae8:	c9                   	leave  
     ae9:	c3                   	ret    

00000aea <peek>:

int
peek(char **ps, char *es, char *toks)
{
     aea:	55                   	push   %ebp
     aeb:	89 e5                	mov    %esp,%ebp
     aed:	83 ec 28             	sub    $0x28,%esp
  char *s;
  
  s = *ps;
     af0:	8b 45 08             	mov    0x8(%ebp),%eax
     af3:	8b 00                	mov    (%eax),%eax
     af5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(s < es && strchr(whitespace, *s))
     af8:	eb 04                	jmp    afe <peek+0x14>
    s++;
     afa:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
peek(char **ps, char *es, char *toks)
{
  char *s;
  
  s = *ps;
  while(s < es && strchr(whitespace, *s))
     afe:	8b 45 f4             	mov    -0xc(%ebp),%eax
     b01:	3b 45 0c             	cmp    0xc(%ebp),%eax
     b04:	73 1d                	jae    b23 <peek+0x39>
     b06:	8b 45 f4             	mov    -0xc(%ebp),%eax
     b09:	0f b6 00             	movzbl (%eax),%eax
     b0c:	0f be c0             	movsbl %al,%eax
     b0f:	89 44 24 04          	mov    %eax,0x4(%esp)
     b13:	c7 04 24 50 1f 00 00 	movl   $0x1f50,(%esp)
     b1a:	e8 2c 07 00 00       	call   124b <strchr>
     b1f:	85 c0                	test   %eax,%eax
     b21:	75 d7                	jne    afa <peek+0x10>
    s++;
  *ps = s;
     b23:	8b 45 08             	mov    0x8(%ebp),%eax
     b26:	8b 55 f4             	mov    -0xc(%ebp),%edx
     b29:	89 10                	mov    %edx,(%eax)
  return *s && strchr(toks, *s);
     b2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
     b2e:	0f b6 00             	movzbl (%eax),%eax
     b31:	84 c0                	test   %al,%al
     b33:	74 23                	je     b58 <peek+0x6e>
     b35:	8b 45 f4             	mov    -0xc(%ebp),%eax
     b38:	0f b6 00             	movzbl (%eax),%eax
     b3b:	0f be c0             	movsbl %al,%eax
     b3e:	89 44 24 04          	mov    %eax,0x4(%esp)
     b42:	8b 45 10             	mov    0x10(%ebp),%eax
     b45:	89 04 24             	mov    %eax,(%esp)
     b48:	e8 fe 06 00 00       	call   124b <strchr>
     b4d:	85 c0                	test   %eax,%eax
     b4f:	74 07                	je     b58 <peek+0x6e>
     b51:	b8 01 00 00 00       	mov    $0x1,%eax
     b56:	eb 05                	jmp    b5d <peek+0x73>
     b58:	b8 00 00 00 00       	mov    $0x0,%eax
}
     b5d:	c9                   	leave  
     b5e:	c3                   	ret    

00000b5f <parsecmd>:
struct cmd *parseexec(char**, char*);
struct cmd *nulterminate(struct cmd*);

struct cmd*
parsecmd(char *s)
{
     b5f:	55                   	push   %ebp
     b60:	89 e5                	mov    %esp,%ebp
     b62:	53                   	push   %ebx
     b63:	83 ec 24             	sub    $0x24,%esp
  char *es;
  struct cmd *cmd;

  es = s + strlen(s);
     b66:	8b 5d 08             	mov    0x8(%ebp),%ebx
     b69:	8b 45 08             	mov    0x8(%ebp),%eax
     b6c:	89 04 24             	mov    %eax,(%esp)
     b6f:	e8 8e 06 00 00       	call   1202 <strlen>
     b74:	01 d8                	add    %ebx,%eax
     b76:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cmd = parseline(&s, es);
     b79:	8b 45 f4             	mov    -0xc(%ebp),%eax
     b7c:	89 44 24 04          	mov    %eax,0x4(%esp)
     b80:	8d 45 08             	lea    0x8(%ebp),%eax
     b83:	89 04 24             	mov    %eax,(%esp)
     b86:	e8 60 00 00 00       	call   beb <parseline>
     b8b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  peek(&s, es, "");
     b8e:	c7 44 24 08 e6 19 00 	movl   $0x19e6,0x8(%esp)
     b95:	00 
     b96:	8b 45 f4             	mov    -0xc(%ebp),%eax
     b99:	89 44 24 04          	mov    %eax,0x4(%esp)
     b9d:	8d 45 08             	lea    0x8(%ebp),%eax
     ba0:	89 04 24             	mov    %eax,(%esp)
     ba3:	e8 42 ff ff ff       	call   aea <peek>
  if(s != es){
     ba8:	8b 45 08             	mov    0x8(%ebp),%eax
     bab:	3b 45 f4             	cmp    -0xc(%ebp),%eax
     bae:	74 27                	je     bd7 <parsecmd+0x78>
    printf(2, "leftovers: %s\n", s);
     bb0:	8b 45 08             	mov    0x8(%ebp),%eax
     bb3:	89 44 24 08          	mov    %eax,0x8(%esp)
     bb7:	c7 44 24 04 e7 19 00 	movl   $0x19e7,0x4(%esp)
     bbe:	00 
     bbf:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     bc6:	e8 a0 09 00 00       	call   156b <printf>
    panic("syntax");
     bcb:	c7 04 24 f6 19 00 00 	movl   $0x19f6,(%esp)
     bd2:	e8 e9 fb ff ff       	call   7c0 <panic>
  }
  nulterminate(cmd);
     bd7:	8b 45 f0             	mov    -0x10(%ebp),%eax
     bda:	89 04 24             	mov    %eax,(%esp)
     bdd:	e8 a5 04 00 00       	call   1087 <nulterminate>
  return cmd;
     be2:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
     be5:	83 c4 24             	add    $0x24,%esp
     be8:	5b                   	pop    %ebx
     be9:	5d                   	pop    %ebp
     bea:	c3                   	ret    

00000beb <parseline>:

struct cmd*
parseline(char **ps, char *es)
{
     beb:	55                   	push   %ebp
     bec:	89 e5                	mov    %esp,%ebp
     bee:	83 ec 28             	sub    $0x28,%esp
  struct cmd *cmd;

  cmd = parsepipe(ps, es);
     bf1:	8b 45 0c             	mov    0xc(%ebp),%eax
     bf4:	89 44 24 04          	mov    %eax,0x4(%esp)
     bf8:	8b 45 08             	mov    0x8(%ebp),%eax
     bfb:	89 04 24             	mov    %eax,(%esp)
     bfe:	e8 bc 00 00 00       	call   cbf <parsepipe>
     c03:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(peek(ps, es, "&")){
     c06:	eb 30                	jmp    c38 <parseline+0x4d>
    gettoken(ps, es, 0, 0);
     c08:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
     c0f:	00 
     c10:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
     c17:	00 
     c18:	8b 45 0c             	mov    0xc(%ebp),%eax
     c1b:	89 44 24 04          	mov    %eax,0x4(%esp)
     c1f:	8b 45 08             	mov    0x8(%ebp),%eax
     c22:	89 04 24             	mov    %eax,(%esp)
     c25:	e8 78 fd ff ff       	call   9a2 <gettoken>
    cmd = backcmd(cmd);
     c2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
     c2d:	89 04 24             	mov    %eax,(%esp)
     c30:	e8 26 fd ff ff       	call   95b <backcmd>
     c35:	89 45 f4             	mov    %eax,-0xc(%ebp)
parseline(char **ps, char *es)
{
  struct cmd *cmd;

  cmd = parsepipe(ps, es);
  while(peek(ps, es, "&")){
     c38:	c7 44 24 08 fd 19 00 	movl   $0x19fd,0x8(%esp)
     c3f:	00 
     c40:	8b 45 0c             	mov    0xc(%ebp),%eax
     c43:	89 44 24 04          	mov    %eax,0x4(%esp)
     c47:	8b 45 08             	mov    0x8(%ebp),%eax
     c4a:	89 04 24             	mov    %eax,(%esp)
     c4d:	e8 98 fe ff ff       	call   aea <peek>
     c52:	85 c0                	test   %eax,%eax
     c54:	75 b2                	jne    c08 <parseline+0x1d>
    gettoken(ps, es, 0, 0);
    cmd = backcmd(cmd);
  }
  if(peek(ps, es, ";")){
     c56:	c7 44 24 08 ff 19 00 	movl   $0x19ff,0x8(%esp)
     c5d:	00 
     c5e:	8b 45 0c             	mov    0xc(%ebp),%eax
     c61:	89 44 24 04          	mov    %eax,0x4(%esp)
     c65:	8b 45 08             	mov    0x8(%ebp),%eax
     c68:	89 04 24             	mov    %eax,(%esp)
     c6b:	e8 7a fe ff ff       	call   aea <peek>
     c70:	85 c0                	test   %eax,%eax
     c72:	74 46                	je     cba <parseline+0xcf>
    gettoken(ps, es, 0, 0);
     c74:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
     c7b:	00 
     c7c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
     c83:	00 
     c84:	8b 45 0c             	mov    0xc(%ebp),%eax
     c87:	89 44 24 04          	mov    %eax,0x4(%esp)
     c8b:	8b 45 08             	mov    0x8(%ebp),%eax
     c8e:	89 04 24             	mov    %eax,(%esp)
     c91:	e8 0c fd ff ff       	call   9a2 <gettoken>
    cmd = listcmd(cmd, parseline(ps, es));
     c96:	8b 45 0c             	mov    0xc(%ebp),%eax
     c99:	89 44 24 04          	mov    %eax,0x4(%esp)
     c9d:	8b 45 08             	mov    0x8(%ebp),%eax
     ca0:	89 04 24             	mov    %eax,(%esp)
     ca3:	e8 43 ff ff ff       	call   beb <parseline>
     ca8:	89 44 24 04          	mov    %eax,0x4(%esp)
     cac:	8b 45 f4             	mov    -0xc(%ebp),%eax
     caf:	89 04 24             	mov    %eax,(%esp)
     cb2:	e8 54 fc ff ff       	call   90b <listcmd>
     cb7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  }
  return cmd;
     cba:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     cbd:	c9                   	leave  
     cbe:	c3                   	ret    

00000cbf <parsepipe>:

struct cmd*
parsepipe(char **ps, char *es)
{
     cbf:	55                   	push   %ebp
     cc0:	89 e5                	mov    %esp,%ebp
     cc2:	83 ec 28             	sub    $0x28,%esp
  struct cmd *cmd;

  cmd = parseexec(ps, es);
     cc5:	8b 45 0c             	mov    0xc(%ebp),%eax
     cc8:	89 44 24 04          	mov    %eax,0x4(%esp)
     ccc:	8b 45 08             	mov    0x8(%ebp),%eax
     ccf:	89 04 24             	mov    %eax,(%esp)
     cd2:	e8 68 02 00 00       	call   f3f <parseexec>
     cd7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(peek(ps, es, "|")){
     cda:	c7 44 24 08 01 1a 00 	movl   $0x1a01,0x8(%esp)
     ce1:	00 
     ce2:	8b 45 0c             	mov    0xc(%ebp),%eax
     ce5:	89 44 24 04          	mov    %eax,0x4(%esp)
     ce9:	8b 45 08             	mov    0x8(%ebp),%eax
     cec:	89 04 24             	mov    %eax,(%esp)
     cef:	e8 f6 fd ff ff       	call   aea <peek>
     cf4:	85 c0                	test   %eax,%eax
     cf6:	74 46                	je     d3e <parsepipe+0x7f>
    gettoken(ps, es, 0, 0);
     cf8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
     cff:	00 
     d00:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
     d07:	00 
     d08:	8b 45 0c             	mov    0xc(%ebp),%eax
     d0b:	89 44 24 04          	mov    %eax,0x4(%esp)
     d0f:	8b 45 08             	mov    0x8(%ebp),%eax
     d12:	89 04 24             	mov    %eax,(%esp)
     d15:	e8 88 fc ff ff       	call   9a2 <gettoken>
    cmd = pipecmd(cmd, parsepipe(ps, es));
     d1a:	8b 45 0c             	mov    0xc(%ebp),%eax
     d1d:	89 44 24 04          	mov    %eax,0x4(%esp)
     d21:	8b 45 08             	mov    0x8(%ebp),%eax
     d24:	89 04 24             	mov    %eax,(%esp)
     d27:	e8 93 ff ff ff       	call   cbf <parsepipe>
     d2c:	89 44 24 04          	mov    %eax,0x4(%esp)
     d30:	8b 45 f4             	mov    -0xc(%ebp),%eax
     d33:	89 04 24             	mov    %eax,(%esp)
     d36:	e8 80 fb ff ff       	call   8bb <pipecmd>
     d3b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  }
  return cmd;
     d3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     d41:	c9                   	leave  
     d42:	c3                   	ret    

00000d43 <parseredirs>:

struct cmd*
parseredirs(struct cmd *cmd, char **ps, char *es)
{
     d43:	55                   	push   %ebp
     d44:	89 e5                	mov    %esp,%ebp
     d46:	83 ec 38             	sub    $0x38,%esp
  int tok;
  char *q, *eq;

  while(peek(ps, es, "<>")){
     d49:	e9 f6 00 00 00       	jmp    e44 <parseredirs+0x101>
    tok = gettoken(ps, es, 0, 0);
     d4e:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
     d55:	00 
     d56:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
     d5d:	00 
     d5e:	8b 45 10             	mov    0x10(%ebp),%eax
     d61:	89 44 24 04          	mov    %eax,0x4(%esp)
     d65:	8b 45 0c             	mov    0xc(%ebp),%eax
     d68:	89 04 24             	mov    %eax,(%esp)
     d6b:	e8 32 fc ff ff       	call   9a2 <gettoken>
     d70:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(gettoken(ps, es, &q, &eq) != 'a')
     d73:	8d 45 ec             	lea    -0x14(%ebp),%eax
     d76:	89 44 24 0c          	mov    %eax,0xc(%esp)
     d7a:	8d 45 f0             	lea    -0x10(%ebp),%eax
     d7d:	89 44 24 08          	mov    %eax,0x8(%esp)
     d81:	8b 45 10             	mov    0x10(%ebp),%eax
     d84:	89 44 24 04          	mov    %eax,0x4(%esp)
     d88:	8b 45 0c             	mov    0xc(%ebp),%eax
     d8b:	89 04 24             	mov    %eax,(%esp)
     d8e:	e8 0f fc ff ff       	call   9a2 <gettoken>
     d93:	83 f8 61             	cmp    $0x61,%eax
     d96:	74 0c                	je     da4 <parseredirs+0x61>
      panic("missing file for redirection");
     d98:	c7 04 24 03 1a 00 00 	movl   $0x1a03,(%esp)
     d9f:	e8 1c fa ff ff       	call   7c0 <panic>
    switch(tok){
     da4:	8b 45 f4             	mov    -0xc(%ebp),%eax
     da7:	83 f8 3c             	cmp    $0x3c,%eax
     daa:	74 0f                	je     dbb <parseredirs+0x78>
     dac:	83 f8 3e             	cmp    $0x3e,%eax
     daf:	74 38                	je     de9 <parseredirs+0xa6>
     db1:	83 f8 2b             	cmp    $0x2b,%eax
     db4:	74 61                	je     e17 <parseredirs+0xd4>
     db6:	e9 89 00 00 00       	jmp    e44 <parseredirs+0x101>
    case '<':
      cmd = redircmd(cmd, q, eq, O_RDONLY, 0);
     dbb:	8b 55 ec             	mov    -0x14(%ebp),%edx
     dbe:	8b 45 f0             	mov    -0x10(%ebp),%eax
     dc1:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
     dc8:	00 
     dc9:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
     dd0:	00 
     dd1:	89 54 24 08          	mov    %edx,0x8(%esp)
     dd5:	89 44 24 04          	mov    %eax,0x4(%esp)
     dd9:	8b 45 08             	mov    0x8(%ebp),%eax
     ddc:	89 04 24             	mov    %eax,(%esp)
     ddf:	e8 6c fa ff ff       	call   850 <redircmd>
     de4:	89 45 08             	mov    %eax,0x8(%ebp)
      break;
     de7:	eb 5b                	jmp    e44 <parseredirs+0x101>
    case '>':
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE, 1);
     de9:	8b 55 ec             	mov    -0x14(%ebp),%edx
     dec:	8b 45 f0             	mov    -0x10(%ebp),%eax
     def:	c7 44 24 10 01 00 00 	movl   $0x1,0x10(%esp)
     df6:	00 
     df7:	c7 44 24 0c 01 02 00 	movl   $0x201,0xc(%esp)
     dfe:	00 
     dff:	89 54 24 08          	mov    %edx,0x8(%esp)
     e03:	89 44 24 04          	mov    %eax,0x4(%esp)
     e07:	8b 45 08             	mov    0x8(%ebp),%eax
     e0a:	89 04 24             	mov    %eax,(%esp)
     e0d:	e8 3e fa ff ff       	call   850 <redircmd>
     e12:	89 45 08             	mov    %eax,0x8(%ebp)
      break;
     e15:	eb 2d                	jmp    e44 <parseredirs+0x101>
    case '+':  // >>
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE, 1);
     e17:	8b 55 ec             	mov    -0x14(%ebp),%edx
     e1a:	8b 45 f0             	mov    -0x10(%ebp),%eax
     e1d:	c7 44 24 10 01 00 00 	movl   $0x1,0x10(%esp)
     e24:	00 
     e25:	c7 44 24 0c 01 02 00 	movl   $0x201,0xc(%esp)
     e2c:	00 
     e2d:	89 54 24 08          	mov    %edx,0x8(%esp)
     e31:	89 44 24 04          	mov    %eax,0x4(%esp)
     e35:	8b 45 08             	mov    0x8(%ebp),%eax
     e38:	89 04 24             	mov    %eax,(%esp)
     e3b:	e8 10 fa ff ff       	call   850 <redircmd>
     e40:	89 45 08             	mov    %eax,0x8(%ebp)
      break;
     e43:	90                   	nop
parseredirs(struct cmd *cmd, char **ps, char *es)
{
  int tok;
  char *q, *eq;

  while(peek(ps, es, "<>")){
     e44:	c7 44 24 08 20 1a 00 	movl   $0x1a20,0x8(%esp)
     e4b:	00 
     e4c:	8b 45 10             	mov    0x10(%ebp),%eax
     e4f:	89 44 24 04          	mov    %eax,0x4(%esp)
     e53:	8b 45 0c             	mov    0xc(%ebp),%eax
     e56:	89 04 24             	mov    %eax,(%esp)
     e59:	e8 8c fc ff ff       	call   aea <peek>
     e5e:	85 c0                	test   %eax,%eax
     e60:	0f 85 e8 fe ff ff    	jne    d4e <parseredirs+0xb>
    case '+':  // >>
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE, 1);
      break;
    }
  }
  return cmd;
     e66:	8b 45 08             	mov    0x8(%ebp),%eax
}
     e69:	c9                   	leave  
     e6a:	c3                   	ret    

00000e6b <parseblock>:

struct cmd*
parseblock(char **ps, char *es)
{
     e6b:	55                   	push   %ebp
     e6c:	89 e5                	mov    %esp,%ebp
     e6e:	83 ec 28             	sub    $0x28,%esp
  struct cmd *cmd;

  if(!peek(ps, es, "("))
     e71:	c7 44 24 08 23 1a 00 	movl   $0x1a23,0x8(%esp)
     e78:	00 
     e79:	8b 45 0c             	mov    0xc(%ebp),%eax
     e7c:	89 44 24 04          	mov    %eax,0x4(%esp)
     e80:	8b 45 08             	mov    0x8(%ebp),%eax
     e83:	89 04 24             	mov    %eax,(%esp)
     e86:	e8 5f fc ff ff       	call   aea <peek>
     e8b:	85 c0                	test   %eax,%eax
     e8d:	75 0c                	jne    e9b <parseblock+0x30>
    panic("parseblock");
     e8f:	c7 04 24 25 1a 00 00 	movl   $0x1a25,(%esp)
     e96:	e8 25 f9 ff ff       	call   7c0 <panic>
  gettoken(ps, es, 0, 0);
     e9b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
     ea2:	00 
     ea3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
     eaa:	00 
     eab:	8b 45 0c             	mov    0xc(%ebp),%eax
     eae:	89 44 24 04          	mov    %eax,0x4(%esp)
     eb2:	8b 45 08             	mov    0x8(%ebp),%eax
     eb5:	89 04 24             	mov    %eax,(%esp)
     eb8:	e8 e5 fa ff ff       	call   9a2 <gettoken>
  cmd = parseline(ps, es);
     ebd:	8b 45 0c             	mov    0xc(%ebp),%eax
     ec0:	89 44 24 04          	mov    %eax,0x4(%esp)
     ec4:	8b 45 08             	mov    0x8(%ebp),%eax
     ec7:	89 04 24             	mov    %eax,(%esp)
     eca:	e8 1c fd ff ff       	call   beb <parseline>
     ecf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(!peek(ps, es, ")"))
     ed2:	c7 44 24 08 30 1a 00 	movl   $0x1a30,0x8(%esp)
     ed9:	00 
     eda:	8b 45 0c             	mov    0xc(%ebp),%eax
     edd:	89 44 24 04          	mov    %eax,0x4(%esp)
     ee1:	8b 45 08             	mov    0x8(%ebp),%eax
     ee4:	89 04 24             	mov    %eax,(%esp)
     ee7:	e8 fe fb ff ff       	call   aea <peek>
     eec:	85 c0                	test   %eax,%eax
     eee:	75 0c                	jne    efc <parseblock+0x91>
    panic("syntax - missing )");
     ef0:	c7 04 24 32 1a 00 00 	movl   $0x1a32,(%esp)
     ef7:	e8 c4 f8 ff ff       	call   7c0 <panic>
  gettoken(ps, es, 0, 0);
     efc:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
     f03:	00 
     f04:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
     f0b:	00 
     f0c:	8b 45 0c             	mov    0xc(%ebp),%eax
     f0f:	89 44 24 04          	mov    %eax,0x4(%esp)
     f13:	8b 45 08             	mov    0x8(%ebp),%eax
     f16:	89 04 24             	mov    %eax,(%esp)
     f19:	e8 84 fa ff ff       	call   9a2 <gettoken>
  cmd = parseredirs(cmd, ps, es);
     f1e:	8b 45 0c             	mov    0xc(%ebp),%eax
     f21:	89 44 24 08          	mov    %eax,0x8(%esp)
     f25:	8b 45 08             	mov    0x8(%ebp),%eax
     f28:	89 44 24 04          	mov    %eax,0x4(%esp)
     f2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
     f2f:	89 04 24             	mov    %eax,(%esp)
     f32:	e8 0c fe ff ff       	call   d43 <parseredirs>
     f37:	89 45 f4             	mov    %eax,-0xc(%ebp)
  return cmd;
     f3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     f3d:	c9                   	leave  
     f3e:	c3                   	ret    

00000f3f <parseexec>:

struct cmd*
parseexec(char **ps, char *es)
{
     f3f:	55                   	push   %ebp
     f40:	89 e5                	mov    %esp,%ebp
     f42:	83 ec 38             	sub    $0x38,%esp
  char *q, *eq;
  int tok, argc;
  struct execcmd *cmd;
  struct cmd *ret;
  
  if(peek(ps, es, "("))
     f45:	c7 44 24 08 23 1a 00 	movl   $0x1a23,0x8(%esp)
     f4c:	00 
     f4d:	8b 45 0c             	mov    0xc(%ebp),%eax
     f50:	89 44 24 04          	mov    %eax,0x4(%esp)
     f54:	8b 45 08             	mov    0x8(%ebp),%eax
     f57:	89 04 24             	mov    %eax,(%esp)
     f5a:	e8 8b fb ff ff       	call   aea <peek>
     f5f:	85 c0                	test   %eax,%eax
     f61:	74 17                	je     f7a <parseexec+0x3b>
    return parseblock(ps, es);
     f63:	8b 45 0c             	mov    0xc(%ebp),%eax
     f66:	89 44 24 04          	mov    %eax,0x4(%esp)
     f6a:	8b 45 08             	mov    0x8(%ebp),%eax
     f6d:	89 04 24             	mov    %eax,(%esp)
     f70:	e8 f6 fe ff ff       	call   e6b <parseblock>
     f75:	e9 0b 01 00 00       	jmp    1085 <parseexec+0x146>

  ret = execcmd();
     f7a:	e8 93 f8 ff ff       	call   812 <execcmd>
     f7f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  cmd = (struct execcmd*)ret;
     f82:	8b 45 f0             	mov    -0x10(%ebp),%eax
     f85:	89 45 ec             	mov    %eax,-0x14(%ebp)

  argc = 0;
     f88:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  ret = parseredirs(ret, ps, es);
     f8f:	8b 45 0c             	mov    0xc(%ebp),%eax
     f92:	89 44 24 08          	mov    %eax,0x8(%esp)
     f96:	8b 45 08             	mov    0x8(%ebp),%eax
     f99:	89 44 24 04          	mov    %eax,0x4(%esp)
     f9d:	8b 45 f0             	mov    -0x10(%ebp),%eax
     fa0:	89 04 24             	mov    %eax,(%esp)
     fa3:	e8 9b fd ff ff       	call   d43 <parseredirs>
     fa8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  while(!peek(ps, es, "|)&;")){
     fab:	e9 8e 00 00 00       	jmp    103e <parseexec+0xff>
    if((tok=gettoken(ps, es, &q, &eq)) == 0)
     fb0:	8d 45 e0             	lea    -0x20(%ebp),%eax
     fb3:	89 44 24 0c          	mov    %eax,0xc(%esp)
     fb7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
     fba:	89 44 24 08          	mov    %eax,0x8(%esp)
     fbe:	8b 45 0c             	mov    0xc(%ebp),%eax
     fc1:	89 44 24 04          	mov    %eax,0x4(%esp)
     fc5:	8b 45 08             	mov    0x8(%ebp),%eax
     fc8:	89 04 24             	mov    %eax,(%esp)
     fcb:	e8 d2 f9 ff ff       	call   9a2 <gettoken>
     fd0:	89 45 e8             	mov    %eax,-0x18(%ebp)
     fd3:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
     fd7:	0f 84 85 00 00 00    	je     1062 <parseexec+0x123>
      break;
    if(tok != 'a')
     fdd:	83 7d e8 61          	cmpl   $0x61,-0x18(%ebp)
     fe1:	74 0c                	je     fef <parseexec+0xb0>
      panic("syntax");
     fe3:	c7 04 24 f6 19 00 00 	movl   $0x19f6,(%esp)
     fea:	e8 d1 f7 ff ff       	call   7c0 <panic>
    cmd->argv[argc] = q;
     fef:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
     ff2:	8b 45 ec             	mov    -0x14(%ebp),%eax
     ff5:	8b 55 f4             	mov    -0xc(%ebp),%edx
     ff8:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
    cmd->eargv[argc] = eq;
     ffc:	8b 55 e0             	mov    -0x20(%ebp),%edx
     fff:	8b 45 ec             	mov    -0x14(%ebp),%eax
    1002:	8b 4d f4             	mov    -0xc(%ebp),%ecx
    1005:	83 c1 08             	add    $0x8,%ecx
    1008:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    argc++;
    100c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(argc >= MAXARGS)
    1010:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
    1014:	7e 0c                	jle    1022 <parseexec+0xe3>
      panic("too many args");
    1016:	c7 04 24 45 1a 00 00 	movl   $0x1a45,(%esp)
    101d:	e8 9e f7 ff ff       	call   7c0 <panic>
    ret = parseredirs(ret, ps, es);
    1022:	8b 45 0c             	mov    0xc(%ebp),%eax
    1025:	89 44 24 08          	mov    %eax,0x8(%esp)
    1029:	8b 45 08             	mov    0x8(%ebp),%eax
    102c:	89 44 24 04          	mov    %eax,0x4(%esp)
    1030:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1033:	89 04 24             	mov    %eax,(%esp)
    1036:	e8 08 fd ff ff       	call   d43 <parseredirs>
    103b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  ret = execcmd();
  cmd = (struct execcmd*)ret;

  argc = 0;
  ret = parseredirs(ret, ps, es);
  while(!peek(ps, es, "|)&;")){
    103e:	c7 44 24 08 53 1a 00 	movl   $0x1a53,0x8(%esp)
    1045:	00 
    1046:	8b 45 0c             	mov    0xc(%ebp),%eax
    1049:	89 44 24 04          	mov    %eax,0x4(%esp)
    104d:	8b 45 08             	mov    0x8(%ebp),%eax
    1050:	89 04 24             	mov    %eax,(%esp)
    1053:	e8 92 fa ff ff       	call   aea <peek>
    1058:	85 c0                	test   %eax,%eax
    105a:	0f 84 50 ff ff ff    	je     fb0 <parseexec+0x71>
    1060:	eb 01                	jmp    1063 <parseexec+0x124>
    if((tok=gettoken(ps, es, &q, &eq)) == 0)
      break;
    1062:	90                   	nop
    argc++;
    if(argc >= MAXARGS)
      panic("too many args");
    ret = parseredirs(ret, ps, es);
  }
  cmd->argv[argc] = 0;
    1063:	8b 45 ec             	mov    -0x14(%ebp),%eax
    1066:	8b 55 f4             	mov    -0xc(%ebp),%edx
    1069:	c7 44 90 04 00 00 00 	movl   $0x0,0x4(%eax,%edx,4)
    1070:	00 
  cmd->eargv[argc] = 0;
    1071:	8b 45 ec             	mov    -0x14(%ebp),%eax
    1074:	8b 55 f4             	mov    -0xc(%ebp),%edx
    1077:	83 c2 08             	add    $0x8,%edx
    107a:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
    1081:	00 
  return ret;
    1082:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
    1085:	c9                   	leave  
    1086:	c3                   	ret    

00001087 <nulterminate>:

// NUL-terminate all the counted strings.
struct cmd*
nulterminate(struct cmd *cmd)
{
    1087:	55                   	push   %ebp
    1088:	89 e5                	mov    %esp,%ebp
    108a:	83 ec 38             	sub    $0x38,%esp
  struct execcmd *ecmd;
  struct listcmd *lcmd;
  struct pipecmd *pcmd;
  struct redircmd *rcmd;

  if(cmd == 0)
    108d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
    1091:	75 0a                	jne    109d <nulterminate+0x16>
    return 0;
    1093:	b8 00 00 00 00       	mov    $0x0,%eax
    1098:	e9 c9 00 00 00       	jmp    1166 <nulterminate+0xdf>
  
  switch(cmd->type){
    109d:	8b 45 08             	mov    0x8(%ebp),%eax
    10a0:	8b 00                	mov    (%eax),%eax
    10a2:	83 f8 05             	cmp    $0x5,%eax
    10a5:	0f 87 b8 00 00 00    	ja     1163 <nulterminate+0xdc>
    10ab:	8b 04 85 58 1a 00 00 	mov    0x1a58(,%eax,4),%eax
    10b2:	ff e0                	jmp    *%eax
  case EXEC:
    ecmd = (struct execcmd*)cmd;
    10b4:	8b 45 08             	mov    0x8(%ebp),%eax
    10b7:	89 45 f0             	mov    %eax,-0x10(%ebp)
    for(i=0; ecmd->argv[i]; i++)
    10ba:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    10c1:	eb 14                	jmp    10d7 <nulterminate+0x50>
      *ecmd->eargv[i] = 0;
    10c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
    10c6:	8b 55 f4             	mov    -0xc(%ebp),%edx
    10c9:	83 c2 08             	add    $0x8,%edx
    10cc:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
    10d0:	c6 00 00             	movb   $0x0,(%eax)
    return 0;
  
  switch(cmd->type){
  case EXEC:
    ecmd = (struct execcmd*)cmd;
    for(i=0; ecmd->argv[i]; i++)
    10d3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    10d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
    10da:	8b 55 f4             	mov    -0xc(%ebp),%edx
    10dd:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
    10e1:	85 c0                	test   %eax,%eax
    10e3:	75 de                	jne    10c3 <nulterminate+0x3c>
      *ecmd->eargv[i] = 0;
    break;
    10e5:	eb 7c                	jmp    1163 <nulterminate+0xdc>

  case REDIR:
    rcmd = (struct redircmd*)cmd;
    10e7:	8b 45 08             	mov    0x8(%ebp),%eax
    10ea:	89 45 ec             	mov    %eax,-0x14(%ebp)
    nulterminate(rcmd->cmd);
    10ed:	8b 45 ec             	mov    -0x14(%ebp),%eax
    10f0:	8b 40 04             	mov    0x4(%eax),%eax
    10f3:	89 04 24             	mov    %eax,(%esp)
    10f6:	e8 8c ff ff ff       	call   1087 <nulterminate>
    *rcmd->efile = 0;
    10fb:	8b 45 ec             	mov    -0x14(%ebp),%eax
    10fe:	8b 40 0c             	mov    0xc(%eax),%eax
    1101:	c6 00 00             	movb   $0x0,(%eax)
    break;
    1104:	eb 5d                	jmp    1163 <nulterminate+0xdc>

  case PIPE:
    pcmd = (struct pipecmd*)cmd;
    1106:	8b 45 08             	mov    0x8(%ebp),%eax
    1109:	89 45 e8             	mov    %eax,-0x18(%ebp)
    nulterminate(pcmd->left);
    110c:	8b 45 e8             	mov    -0x18(%ebp),%eax
    110f:	8b 40 04             	mov    0x4(%eax),%eax
    1112:	89 04 24             	mov    %eax,(%esp)
    1115:	e8 6d ff ff ff       	call   1087 <nulterminate>
    nulterminate(pcmd->right);
    111a:	8b 45 e8             	mov    -0x18(%ebp),%eax
    111d:	8b 40 08             	mov    0x8(%eax),%eax
    1120:	89 04 24             	mov    %eax,(%esp)
    1123:	e8 5f ff ff ff       	call   1087 <nulterminate>
    break;
    1128:	eb 39                	jmp    1163 <nulterminate+0xdc>
    
  case LIST:
    lcmd = (struct listcmd*)cmd;
    112a:	8b 45 08             	mov    0x8(%ebp),%eax
    112d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    nulterminate(lcmd->left);
    1130:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    1133:	8b 40 04             	mov    0x4(%eax),%eax
    1136:	89 04 24             	mov    %eax,(%esp)
    1139:	e8 49 ff ff ff       	call   1087 <nulterminate>
    nulterminate(lcmd->right);
    113e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    1141:	8b 40 08             	mov    0x8(%eax),%eax
    1144:	89 04 24             	mov    %eax,(%esp)
    1147:	e8 3b ff ff ff       	call   1087 <nulterminate>
    break;
    114c:	eb 15                	jmp    1163 <nulterminate+0xdc>

  case BACK:
    bcmd = (struct backcmd*)cmd;
    114e:	8b 45 08             	mov    0x8(%ebp),%eax
    1151:	89 45 e0             	mov    %eax,-0x20(%ebp)
    nulterminate(bcmd->cmd);
    1154:	8b 45 e0             	mov    -0x20(%ebp),%eax
    1157:	8b 40 04             	mov    0x4(%eax),%eax
    115a:	89 04 24             	mov    %eax,(%esp)
    115d:	e8 25 ff ff ff       	call   1087 <nulterminate>
    break;
    1162:	90                   	nop
  }
  return cmd;
    1163:	8b 45 08             	mov    0x8(%ebp),%eax
}
    1166:	c9                   	leave  
    1167:	c3                   	ret    

00001168 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
    1168:	55                   	push   %ebp
    1169:	89 e5                	mov    %esp,%ebp
    116b:	57                   	push   %edi
    116c:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
    116d:	8b 4d 08             	mov    0x8(%ebp),%ecx
    1170:	8b 55 10             	mov    0x10(%ebp),%edx
    1173:	8b 45 0c             	mov    0xc(%ebp),%eax
    1176:	89 cb                	mov    %ecx,%ebx
    1178:	89 df                	mov    %ebx,%edi
    117a:	89 d1                	mov    %edx,%ecx
    117c:	fc                   	cld    
    117d:	f3 aa                	rep stos %al,%es:(%edi)
    117f:	89 ca                	mov    %ecx,%edx
    1181:	89 fb                	mov    %edi,%ebx
    1183:	89 5d 08             	mov    %ebx,0x8(%ebp)
    1186:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
    1189:	5b                   	pop    %ebx
    118a:	5f                   	pop    %edi
    118b:	5d                   	pop    %ebp
    118c:	c3                   	ret    

0000118d <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
    118d:	55                   	push   %ebp
    118e:	89 e5                	mov    %esp,%ebp
    1190:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
    1193:	8b 45 08             	mov    0x8(%ebp),%eax
    1196:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
    1199:	90                   	nop
    119a:	8b 45 0c             	mov    0xc(%ebp),%eax
    119d:	0f b6 10             	movzbl (%eax),%edx
    11a0:	8b 45 08             	mov    0x8(%ebp),%eax
    11a3:	88 10                	mov    %dl,(%eax)
    11a5:	8b 45 08             	mov    0x8(%ebp),%eax
    11a8:	0f b6 00             	movzbl (%eax),%eax
    11ab:	84 c0                	test   %al,%al
    11ad:	0f 95 c0             	setne  %al
    11b0:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    11b4:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
    11b8:	84 c0                	test   %al,%al
    11ba:	75 de                	jne    119a <strcpy+0xd>
    ;
  return os;
    11bc:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
    11bf:	c9                   	leave  
    11c0:	c3                   	ret    

000011c1 <strcmp>:

int
strcmp(const char *p, const char *q)
{
    11c1:	55                   	push   %ebp
    11c2:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
    11c4:	eb 08                	jmp    11ce <strcmp+0xd>
    p++, q++;
    11c6:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    11ca:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
    11ce:	8b 45 08             	mov    0x8(%ebp),%eax
    11d1:	0f b6 00             	movzbl (%eax),%eax
    11d4:	84 c0                	test   %al,%al
    11d6:	74 10                	je     11e8 <strcmp+0x27>
    11d8:	8b 45 08             	mov    0x8(%ebp),%eax
    11db:	0f b6 10             	movzbl (%eax),%edx
    11de:	8b 45 0c             	mov    0xc(%ebp),%eax
    11e1:	0f b6 00             	movzbl (%eax),%eax
    11e4:	38 c2                	cmp    %al,%dl
    11e6:	74 de                	je     11c6 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
    11e8:	8b 45 08             	mov    0x8(%ebp),%eax
    11eb:	0f b6 00             	movzbl (%eax),%eax
    11ee:	0f b6 d0             	movzbl %al,%edx
    11f1:	8b 45 0c             	mov    0xc(%ebp),%eax
    11f4:	0f b6 00             	movzbl (%eax),%eax
    11f7:	0f b6 c0             	movzbl %al,%eax
    11fa:	89 d1                	mov    %edx,%ecx
    11fc:	29 c1                	sub    %eax,%ecx
    11fe:	89 c8                	mov    %ecx,%eax
}
    1200:	5d                   	pop    %ebp
    1201:	c3                   	ret    

00001202 <strlen>:

uint
strlen(char *s)
{
    1202:	55                   	push   %ebp
    1203:	89 e5                	mov    %esp,%ebp
    1205:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
    1208:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    120f:	eb 04                	jmp    1215 <strlen+0x13>
    1211:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
    1215:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1218:	03 45 08             	add    0x8(%ebp),%eax
    121b:	0f b6 00             	movzbl (%eax),%eax
    121e:	84 c0                	test   %al,%al
    1220:	75 ef                	jne    1211 <strlen+0xf>
    ;
  return n;
    1222:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
    1225:	c9                   	leave  
    1226:	c3                   	ret    

00001227 <memset>:

void*
memset(void *dst, int c, uint n)
{
    1227:	55                   	push   %ebp
    1228:	89 e5                	mov    %esp,%ebp
    122a:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
    122d:	8b 45 10             	mov    0x10(%ebp),%eax
    1230:	89 44 24 08          	mov    %eax,0x8(%esp)
    1234:	8b 45 0c             	mov    0xc(%ebp),%eax
    1237:	89 44 24 04          	mov    %eax,0x4(%esp)
    123b:	8b 45 08             	mov    0x8(%ebp),%eax
    123e:	89 04 24             	mov    %eax,(%esp)
    1241:	e8 22 ff ff ff       	call   1168 <stosb>
  return dst;
    1246:	8b 45 08             	mov    0x8(%ebp),%eax
}
    1249:	c9                   	leave  
    124a:	c3                   	ret    

0000124b <strchr>:

char*
strchr(const char *s, char c)
{
    124b:	55                   	push   %ebp
    124c:	89 e5                	mov    %esp,%ebp
    124e:	83 ec 04             	sub    $0x4,%esp
    1251:	8b 45 0c             	mov    0xc(%ebp),%eax
    1254:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
    1257:	eb 14                	jmp    126d <strchr+0x22>
    if(*s == c)
    1259:	8b 45 08             	mov    0x8(%ebp),%eax
    125c:	0f b6 00             	movzbl (%eax),%eax
    125f:	3a 45 fc             	cmp    -0x4(%ebp),%al
    1262:	75 05                	jne    1269 <strchr+0x1e>
      return (char*)s;
    1264:	8b 45 08             	mov    0x8(%ebp),%eax
    1267:	eb 13                	jmp    127c <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
    1269:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    126d:	8b 45 08             	mov    0x8(%ebp),%eax
    1270:	0f b6 00             	movzbl (%eax),%eax
    1273:	84 c0                	test   %al,%al
    1275:	75 e2                	jne    1259 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
    1277:	b8 00 00 00 00       	mov    $0x0,%eax
}
    127c:	c9                   	leave  
    127d:	c3                   	ret    

0000127e <gets>:

char*
gets(char *buf, int max)
{
    127e:	55                   	push   %ebp
    127f:	89 e5                	mov    %esp,%ebp
    1281:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    1284:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    128b:	eb 44                	jmp    12d1 <gets+0x53>
    cc = read(0, &c, 1);
    128d:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
    1294:	00 
    1295:	8d 45 ef             	lea    -0x11(%ebp),%eax
    1298:	89 44 24 04          	mov    %eax,0x4(%esp)
    129c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    12a3:	e8 3c 01 00 00       	call   13e4 <read>
    12a8:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
    12ab:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    12af:	7e 2d                	jle    12de <gets+0x60>
      break;
    buf[i++] = c;
    12b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
    12b4:	03 45 08             	add    0x8(%ebp),%eax
    12b7:	0f b6 55 ef          	movzbl -0x11(%ebp),%edx
    12bb:	88 10                	mov    %dl,(%eax)
    12bd:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(c == '\n' || c == '\r')
    12c1:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    12c5:	3c 0a                	cmp    $0xa,%al
    12c7:	74 16                	je     12df <gets+0x61>
    12c9:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    12cd:	3c 0d                	cmp    $0xd,%al
    12cf:	74 0e                	je     12df <gets+0x61>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    12d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
    12d4:	83 c0 01             	add    $0x1,%eax
    12d7:	3b 45 0c             	cmp    0xc(%ebp),%eax
    12da:	7c b1                	jl     128d <gets+0xf>
    12dc:	eb 01                	jmp    12df <gets+0x61>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    12de:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
    12df:	8b 45 f4             	mov    -0xc(%ebp),%eax
    12e2:	03 45 08             	add    0x8(%ebp),%eax
    12e5:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
    12e8:	8b 45 08             	mov    0x8(%ebp),%eax
}
    12eb:	c9                   	leave  
    12ec:	c3                   	ret    

000012ed <stat>:

int
stat(char *n, struct stat *st)
{
    12ed:	55                   	push   %ebp
    12ee:	89 e5                	mov    %esp,%ebp
    12f0:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
    12f3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    12fa:	00 
    12fb:	8b 45 08             	mov    0x8(%ebp),%eax
    12fe:	89 04 24             	mov    %eax,(%esp)
    1301:	e8 06 01 00 00       	call   140c <open>
    1306:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
    1309:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    130d:	79 07                	jns    1316 <stat+0x29>
    return -1;
    130f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    1314:	eb 23                	jmp    1339 <stat+0x4c>
  r = fstat(fd, st);
    1316:	8b 45 0c             	mov    0xc(%ebp),%eax
    1319:	89 44 24 04          	mov    %eax,0x4(%esp)
    131d:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1320:	89 04 24             	mov    %eax,(%esp)
    1323:	e8 fc 00 00 00       	call   1424 <fstat>
    1328:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
    132b:	8b 45 f4             	mov    -0xc(%ebp),%eax
    132e:	89 04 24             	mov    %eax,(%esp)
    1331:	e8 be 00 00 00       	call   13f4 <close>
  return r;
    1336:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
    1339:	c9                   	leave  
    133a:	c3                   	ret    

0000133b <atoi>:

int
atoi(const char *s)
{
    133b:	55                   	push   %ebp
    133c:	89 e5                	mov    %esp,%ebp
    133e:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
    1341:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
    1348:	eb 23                	jmp    136d <atoi+0x32>
    n = n*10 + *s++ - '0';
    134a:	8b 55 fc             	mov    -0x4(%ebp),%edx
    134d:	89 d0                	mov    %edx,%eax
    134f:	c1 e0 02             	shl    $0x2,%eax
    1352:	01 d0                	add    %edx,%eax
    1354:	01 c0                	add    %eax,%eax
    1356:	89 c2                	mov    %eax,%edx
    1358:	8b 45 08             	mov    0x8(%ebp),%eax
    135b:	0f b6 00             	movzbl (%eax),%eax
    135e:	0f be c0             	movsbl %al,%eax
    1361:	01 d0                	add    %edx,%eax
    1363:	83 e8 30             	sub    $0x30,%eax
    1366:	89 45 fc             	mov    %eax,-0x4(%ebp)
    1369:	83 45 08 01          	addl   $0x1,0x8(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
    136d:	8b 45 08             	mov    0x8(%ebp),%eax
    1370:	0f b6 00             	movzbl (%eax),%eax
    1373:	3c 2f                	cmp    $0x2f,%al
    1375:	7e 0a                	jle    1381 <atoi+0x46>
    1377:	8b 45 08             	mov    0x8(%ebp),%eax
    137a:	0f b6 00             	movzbl (%eax),%eax
    137d:	3c 39                	cmp    $0x39,%al
    137f:	7e c9                	jle    134a <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
    1381:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
    1384:	c9                   	leave  
    1385:	c3                   	ret    

00001386 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
    1386:	55                   	push   %ebp
    1387:	89 e5                	mov    %esp,%ebp
    1389:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
    138c:	8b 45 08             	mov    0x8(%ebp),%eax
    138f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
    1392:	8b 45 0c             	mov    0xc(%ebp),%eax
    1395:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
    1398:	eb 13                	jmp    13ad <memmove+0x27>
    *dst++ = *src++;
    139a:	8b 45 f8             	mov    -0x8(%ebp),%eax
    139d:	0f b6 10             	movzbl (%eax),%edx
    13a0:	8b 45 fc             	mov    -0x4(%ebp),%eax
    13a3:	88 10                	mov    %dl,(%eax)
    13a5:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
    13a9:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
    13ad:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
    13b1:	0f 9f c0             	setg   %al
    13b4:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    13b8:	84 c0                	test   %al,%al
    13ba:	75 de                	jne    139a <memmove+0x14>
    *dst++ = *src++;
  return vdst;
    13bc:	8b 45 08             	mov    0x8(%ebp),%eax
}
    13bf:	c9                   	leave  
    13c0:	c3                   	ret    
    13c1:	90                   	nop
    13c2:	90                   	nop
    13c3:	90                   	nop

000013c4 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
    13c4:	b8 01 00 00 00       	mov    $0x1,%eax
    13c9:	cd 40                	int    $0x40
    13cb:	c3                   	ret    

000013cc <exit>:
SYSCALL(exit)
    13cc:	b8 02 00 00 00       	mov    $0x2,%eax
    13d1:	cd 40                	int    $0x40
    13d3:	c3                   	ret    

000013d4 <wait>:
SYSCALL(wait)
    13d4:	b8 03 00 00 00       	mov    $0x3,%eax
    13d9:	cd 40                	int    $0x40
    13db:	c3                   	ret    

000013dc <pipe>:
SYSCALL(pipe)
    13dc:	b8 04 00 00 00       	mov    $0x4,%eax
    13e1:	cd 40                	int    $0x40
    13e3:	c3                   	ret    

000013e4 <read>:
SYSCALL(read)
    13e4:	b8 05 00 00 00       	mov    $0x5,%eax
    13e9:	cd 40                	int    $0x40
    13eb:	c3                   	ret    

000013ec <write>:
SYSCALL(write)
    13ec:	b8 10 00 00 00       	mov    $0x10,%eax
    13f1:	cd 40                	int    $0x40
    13f3:	c3                   	ret    

000013f4 <close>:
SYSCALL(close)
    13f4:	b8 15 00 00 00       	mov    $0x15,%eax
    13f9:	cd 40                	int    $0x40
    13fb:	c3                   	ret    

000013fc <kill>:
SYSCALL(kill)
    13fc:	b8 06 00 00 00       	mov    $0x6,%eax
    1401:	cd 40                	int    $0x40
    1403:	c3                   	ret    

00001404 <exec>:
SYSCALL(exec)
    1404:	b8 07 00 00 00       	mov    $0x7,%eax
    1409:	cd 40                	int    $0x40
    140b:	c3                   	ret    

0000140c <open>:
SYSCALL(open)
    140c:	b8 0f 00 00 00       	mov    $0xf,%eax
    1411:	cd 40                	int    $0x40
    1413:	c3                   	ret    

00001414 <mknod>:
SYSCALL(mknod)
    1414:	b8 11 00 00 00       	mov    $0x11,%eax
    1419:	cd 40                	int    $0x40
    141b:	c3                   	ret    

0000141c <unlink>:
SYSCALL(unlink)
    141c:	b8 12 00 00 00       	mov    $0x12,%eax
    1421:	cd 40                	int    $0x40
    1423:	c3                   	ret    

00001424 <fstat>:
SYSCALL(fstat)
    1424:	b8 08 00 00 00       	mov    $0x8,%eax
    1429:	cd 40                	int    $0x40
    142b:	c3                   	ret    

0000142c <link>:
SYSCALL(link)
    142c:	b8 13 00 00 00       	mov    $0x13,%eax
    1431:	cd 40                	int    $0x40
    1433:	c3                   	ret    

00001434 <mkdir>:
SYSCALL(mkdir)
    1434:	b8 14 00 00 00       	mov    $0x14,%eax
    1439:	cd 40                	int    $0x40
    143b:	c3                   	ret    

0000143c <chdir>:
SYSCALL(chdir)
    143c:	b8 09 00 00 00       	mov    $0x9,%eax
    1441:	cd 40                	int    $0x40
    1443:	c3                   	ret    

00001444 <dup>:
SYSCALL(dup)
    1444:	b8 0a 00 00 00       	mov    $0xa,%eax
    1449:	cd 40                	int    $0x40
    144b:	c3                   	ret    

0000144c <getpid>:
SYSCALL(getpid)
    144c:	b8 0b 00 00 00       	mov    $0xb,%eax
    1451:	cd 40                	int    $0x40
    1453:	c3                   	ret    

00001454 <sbrk>:
SYSCALL(sbrk)
    1454:	b8 0c 00 00 00       	mov    $0xc,%eax
    1459:	cd 40                	int    $0x40
    145b:	c3                   	ret    

0000145c <sleep>:
SYSCALL(sleep)
    145c:	b8 0d 00 00 00       	mov    $0xd,%eax
    1461:	cd 40                	int    $0x40
    1463:	c3                   	ret    

00001464 <uptime>:
SYSCALL(uptime)
    1464:	b8 0e 00 00 00       	mov    $0xe,%eax
    1469:	cd 40                	int    $0x40
    146b:	c3                   	ret    

0000146c <waitpid>:
SYSCALL(waitpid)
    146c:	b8 16 00 00 00       	mov    $0x16,%eax
    1471:	cd 40                	int    $0x40
    1473:	c3                   	ret    

00001474 <wait_stat>:
SYSCALL(wait_stat)
    1474:	b8 17 00 00 00       	mov    $0x17,%eax
    1479:	cd 40                	int    $0x40
    147b:	c3                   	ret    

0000147c <list_pgroup>:
SYSCALL(list_pgroup)
    147c:	b8 18 00 00 00       	mov    $0x18,%eax
    1481:	cd 40                	int    $0x40
    1483:	c3                   	ret    

00001484 <foreground>:
SYSCALL(foreground)
    1484:	b8 19 00 00 00       	mov    $0x19,%eax
    1489:	cd 40                	int    $0x40
    148b:	c3                   	ret    

0000148c <set_priority>:
SYSCALL(set_priority)
    148c:	b8 1a 00 00 00       	mov    $0x1a,%eax
    1491:	cd 40                	int    $0x40
    1493:	c3                   	ret    

00001494 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
    1494:	55                   	push   %ebp
    1495:	89 e5                	mov    %esp,%ebp
    1497:	83 ec 28             	sub    $0x28,%esp
    149a:	8b 45 0c             	mov    0xc(%ebp),%eax
    149d:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
    14a0:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
    14a7:	00 
    14a8:	8d 45 f4             	lea    -0xc(%ebp),%eax
    14ab:	89 44 24 04          	mov    %eax,0x4(%esp)
    14af:	8b 45 08             	mov    0x8(%ebp),%eax
    14b2:	89 04 24             	mov    %eax,(%esp)
    14b5:	e8 32 ff ff ff       	call   13ec <write>
}
    14ba:	c9                   	leave  
    14bb:	c3                   	ret    

000014bc <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
    14bc:	55                   	push   %ebp
    14bd:	89 e5                	mov    %esp,%ebp
    14bf:	83 ec 48             	sub    $0x48,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
    14c2:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
    14c9:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
    14cd:	74 17                	je     14e6 <printint+0x2a>
    14cf:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
    14d3:	79 11                	jns    14e6 <printint+0x2a>
    neg = 1;
    14d5:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
    14dc:	8b 45 0c             	mov    0xc(%ebp),%eax
    14df:	f7 d8                	neg    %eax
    14e1:	89 45 ec             	mov    %eax,-0x14(%ebp)
    14e4:	eb 06                	jmp    14ec <printint+0x30>
  } else {
    x = xx;
    14e6:	8b 45 0c             	mov    0xc(%ebp),%eax
    14e9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
    14ec:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
    14f3:	8b 4d 10             	mov    0x10(%ebp),%ecx
    14f6:	8b 45 ec             	mov    -0x14(%ebp),%eax
    14f9:	ba 00 00 00 00       	mov    $0x0,%edx
    14fe:	f7 f1                	div    %ecx
    1500:	89 d0                	mov    %edx,%eax
    1502:	0f b6 90 60 1f 00 00 	movzbl 0x1f60(%eax),%edx
    1509:	8d 45 dc             	lea    -0x24(%ebp),%eax
    150c:	03 45 f4             	add    -0xc(%ebp),%eax
    150f:	88 10                	mov    %dl,(%eax)
    1511:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  }while((x /= base) != 0);
    1515:	8b 55 10             	mov    0x10(%ebp),%edx
    1518:	89 55 d4             	mov    %edx,-0x2c(%ebp)
    151b:	8b 45 ec             	mov    -0x14(%ebp),%eax
    151e:	ba 00 00 00 00       	mov    $0x0,%edx
    1523:	f7 75 d4             	divl   -0x2c(%ebp)
    1526:	89 45 ec             	mov    %eax,-0x14(%ebp)
    1529:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    152d:	75 c4                	jne    14f3 <printint+0x37>
  if(neg)
    152f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    1533:	74 2a                	je     155f <printint+0xa3>
    buf[i++] = '-';
    1535:	8d 45 dc             	lea    -0x24(%ebp),%eax
    1538:	03 45 f4             	add    -0xc(%ebp),%eax
    153b:	c6 00 2d             	movb   $0x2d,(%eax)
    153e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

  while(--i >= 0)
    1542:	eb 1b                	jmp    155f <printint+0xa3>
    putc(fd, buf[i]);
    1544:	8d 45 dc             	lea    -0x24(%ebp),%eax
    1547:	03 45 f4             	add    -0xc(%ebp),%eax
    154a:	0f b6 00             	movzbl (%eax),%eax
    154d:	0f be c0             	movsbl %al,%eax
    1550:	89 44 24 04          	mov    %eax,0x4(%esp)
    1554:	8b 45 08             	mov    0x8(%ebp),%eax
    1557:	89 04 24             	mov    %eax,(%esp)
    155a:	e8 35 ff ff ff       	call   1494 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
    155f:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
    1563:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    1567:	79 db                	jns    1544 <printint+0x88>
    putc(fd, buf[i]);
}
    1569:	c9                   	leave  
    156a:	c3                   	ret    

0000156b <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
    156b:	55                   	push   %ebp
    156c:	89 e5                	mov    %esp,%ebp
    156e:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
    1571:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
    1578:	8d 45 0c             	lea    0xc(%ebp),%eax
    157b:	83 c0 04             	add    $0x4,%eax
    157e:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
    1581:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    1588:	e9 7d 01 00 00       	jmp    170a <printf+0x19f>
    c = fmt[i] & 0xff;
    158d:	8b 55 0c             	mov    0xc(%ebp),%edx
    1590:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1593:	01 d0                	add    %edx,%eax
    1595:	0f b6 00             	movzbl (%eax),%eax
    1598:	0f be c0             	movsbl %al,%eax
    159b:	25 ff 00 00 00       	and    $0xff,%eax
    15a0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
    15a3:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    15a7:	75 2c                	jne    15d5 <printf+0x6a>
      if(c == '%'){
    15a9:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
    15ad:	75 0c                	jne    15bb <printf+0x50>
        state = '%';
    15af:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
    15b6:	e9 4b 01 00 00       	jmp    1706 <printf+0x19b>
      } else {
        putc(fd, c);
    15bb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    15be:	0f be c0             	movsbl %al,%eax
    15c1:	89 44 24 04          	mov    %eax,0x4(%esp)
    15c5:	8b 45 08             	mov    0x8(%ebp),%eax
    15c8:	89 04 24             	mov    %eax,(%esp)
    15cb:	e8 c4 fe ff ff       	call   1494 <putc>
    15d0:	e9 31 01 00 00       	jmp    1706 <printf+0x19b>
      }
    } else if(state == '%'){
    15d5:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
    15d9:	0f 85 27 01 00 00    	jne    1706 <printf+0x19b>
      if(c == 'd'){
    15df:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
    15e3:	75 2d                	jne    1612 <printf+0xa7>
        printint(fd, *ap, 10, 1);
    15e5:	8b 45 e8             	mov    -0x18(%ebp),%eax
    15e8:	8b 00                	mov    (%eax),%eax
    15ea:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
    15f1:	00 
    15f2:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
    15f9:	00 
    15fa:	89 44 24 04          	mov    %eax,0x4(%esp)
    15fe:	8b 45 08             	mov    0x8(%ebp),%eax
    1601:	89 04 24             	mov    %eax,(%esp)
    1604:	e8 b3 fe ff ff       	call   14bc <printint>
        ap++;
    1609:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    160d:	e9 ed 00 00 00       	jmp    16ff <printf+0x194>
      } else if(c == 'x' || c == 'p'){
    1612:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
    1616:	74 06                	je     161e <printf+0xb3>
    1618:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
    161c:	75 2d                	jne    164b <printf+0xe0>
        printint(fd, *ap, 16, 0);
    161e:	8b 45 e8             	mov    -0x18(%ebp),%eax
    1621:	8b 00                	mov    (%eax),%eax
    1623:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
    162a:	00 
    162b:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
    1632:	00 
    1633:	89 44 24 04          	mov    %eax,0x4(%esp)
    1637:	8b 45 08             	mov    0x8(%ebp),%eax
    163a:	89 04 24             	mov    %eax,(%esp)
    163d:	e8 7a fe ff ff       	call   14bc <printint>
        ap++;
    1642:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    1646:	e9 b4 00 00 00       	jmp    16ff <printf+0x194>
      } else if(c == 's'){
    164b:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
    164f:	75 46                	jne    1697 <printf+0x12c>
        s = (char*)*ap;
    1651:	8b 45 e8             	mov    -0x18(%ebp),%eax
    1654:	8b 00                	mov    (%eax),%eax
    1656:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
    1659:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
    165d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    1661:	75 27                	jne    168a <printf+0x11f>
          s = "(null)";
    1663:	c7 45 f4 70 1a 00 00 	movl   $0x1a70,-0xc(%ebp)
        while(*s != 0){
    166a:	eb 1e                	jmp    168a <printf+0x11f>
          putc(fd, *s);
    166c:	8b 45 f4             	mov    -0xc(%ebp),%eax
    166f:	0f b6 00             	movzbl (%eax),%eax
    1672:	0f be c0             	movsbl %al,%eax
    1675:	89 44 24 04          	mov    %eax,0x4(%esp)
    1679:	8b 45 08             	mov    0x8(%ebp),%eax
    167c:	89 04 24             	mov    %eax,(%esp)
    167f:	e8 10 fe ff ff       	call   1494 <putc>
          s++;
    1684:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    1688:	eb 01                	jmp    168b <printf+0x120>
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
    168a:	90                   	nop
    168b:	8b 45 f4             	mov    -0xc(%ebp),%eax
    168e:	0f b6 00             	movzbl (%eax),%eax
    1691:	84 c0                	test   %al,%al
    1693:	75 d7                	jne    166c <printf+0x101>
    1695:	eb 68                	jmp    16ff <printf+0x194>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
    1697:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
    169b:	75 1d                	jne    16ba <printf+0x14f>
        putc(fd, *ap);
    169d:	8b 45 e8             	mov    -0x18(%ebp),%eax
    16a0:	8b 00                	mov    (%eax),%eax
    16a2:	0f be c0             	movsbl %al,%eax
    16a5:	89 44 24 04          	mov    %eax,0x4(%esp)
    16a9:	8b 45 08             	mov    0x8(%ebp),%eax
    16ac:	89 04 24             	mov    %eax,(%esp)
    16af:	e8 e0 fd ff ff       	call   1494 <putc>
        ap++;
    16b4:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    16b8:	eb 45                	jmp    16ff <printf+0x194>
      } else if(c == '%'){
    16ba:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
    16be:	75 17                	jne    16d7 <printf+0x16c>
        putc(fd, c);
    16c0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    16c3:	0f be c0             	movsbl %al,%eax
    16c6:	89 44 24 04          	mov    %eax,0x4(%esp)
    16ca:	8b 45 08             	mov    0x8(%ebp),%eax
    16cd:	89 04 24             	mov    %eax,(%esp)
    16d0:	e8 bf fd ff ff       	call   1494 <putc>
    16d5:	eb 28                	jmp    16ff <printf+0x194>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
    16d7:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
    16de:	00 
    16df:	8b 45 08             	mov    0x8(%ebp),%eax
    16e2:	89 04 24             	mov    %eax,(%esp)
    16e5:	e8 aa fd ff ff       	call   1494 <putc>
        putc(fd, c);
    16ea:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    16ed:	0f be c0             	movsbl %al,%eax
    16f0:	89 44 24 04          	mov    %eax,0x4(%esp)
    16f4:	8b 45 08             	mov    0x8(%ebp),%eax
    16f7:	89 04 24             	mov    %eax,(%esp)
    16fa:	e8 95 fd ff ff       	call   1494 <putc>
      }
      state = 0;
    16ff:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    1706:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
    170a:	8b 55 0c             	mov    0xc(%ebp),%edx
    170d:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1710:	01 d0                	add    %edx,%eax
    1712:	0f b6 00             	movzbl (%eax),%eax
    1715:	84 c0                	test   %al,%al
    1717:	0f 85 70 fe ff ff    	jne    158d <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
    171d:	c9                   	leave  
    171e:	c3                   	ret    
    171f:	90                   	nop

00001720 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    1720:	55                   	push   %ebp
    1721:	89 e5                	mov    %esp,%ebp
    1723:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
    1726:	8b 45 08             	mov    0x8(%ebp),%eax
    1729:	83 e8 08             	sub    $0x8,%eax
    172c:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    172f:	a1 0c e0 01 00       	mov    0x1e00c,%eax
    1734:	89 45 fc             	mov    %eax,-0x4(%ebp)
    1737:	eb 24                	jmp    175d <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    1739:	8b 45 fc             	mov    -0x4(%ebp),%eax
    173c:	8b 00                	mov    (%eax),%eax
    173e:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    1741:	77 12                	ja     1755 <free+0x35>
    1743:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1746:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    1749:	77 24                	ja     176f <free+0x4f>
    174b:	8b 45 fc             	mov    -0x4(%ebp),%eax
    174e:	8b 00                	mov    (%eax),%eax
    1750:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    1753:	77 1a                	ja     176f <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    1755:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1758:	8b 00                	mov    (%eax),%eax
    175a:	89 45 fc             	mov    %eax,-0x4(%ebp)
    175d:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1760:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    1763:	76 d4                	jbe    1739 <free+0x19>
    1765:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1768:	8b 00                	mov    (%eax),%eax
    176a:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    176d:	76 ca                	jbe    1739 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    176f:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1772:	8b 40 04             	mov    0x4(%eax),%eax
    1775:	c1 e0 03             	shl    $0x3,%eax
    1778:	89 c2                	mov    %eax,%edx
    177a:	03 55 f8             	add    -0x8(%ebp),%edx
    177d:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1780:	8b 00                	mov    (%eax),%eax
    1782:	39 c2                	cmp    %eax,%edx
    1784:	75 24                	jne    17aa <free+0x8a>
    bp->s.size += p->s.ptr->s.size;
    1786:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1789:	8b 50 04             	mov    0x4(%eax),%edx
    178c:	8b 45 fc             	mov    -0x4(%ebp),%eax
    178f:	8b 00                	mov    (%eax),%eax
    1791:	8b 40 04             	mov    0x4(%eax),%eax
    1794:	01 c2                	add    %eax,%edx
    1796:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1799:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
    179c:	8b 45 fc             	mov    -0x4(%ebp),%eax
    179f:	8b 00                	mov    (%eax),%eax
    17a1:	8b 10                	mov    (%eax),%edx
    17a3:	8b 45 f8             	mov    -0x8(%ebp),%eax
    17a6:	89 10                	mov    %edx,(%eax)
    17a8:	eb 0a                	jmp    17b4 <free+0x94>
  } else
    bp->s.ptr = p->s.ptr;
    17aa:	8b 45 fc             	mov    -0x4(%ebp),%eax
    17ad:	8b 10                	mov    (%eax),%edx
    17af:	8b 45 f8             	mov    -0x8(%ebp),%eax
    17b2:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
    17b4:	8b 45 fc             	mov    -0x4(%ebp),%eax
    17b7:	8b 40 04             	mov    0x4(%eax),%eax
    17ba:	c1 e0 03             	shl    $0x3,%eax
    17bd:	03 45 fc             	add    -0x4(%ebp),%eax
    17c0:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    17c3:	75 20                	jne    17e5 <free+0xc5>
    p->s.size += bp->s.size;
    17c5:	8b 45 fc             	mov    -0x4(%ebp),%eax
    17c8:	8b 50 04             	mov    0x4(%eax),%edx
    17cb:	8b 45 f8             	mov    -0x8(%ebp),%eax
    17ce:	8b 40 04             	mov    0x4(%eax),%eax
    17d1:	01 c2                	add    %eax,%edx
    17d3:	8b 45 fc             	mov    -0x4(%ebp),%eax
    17d6:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
    17d9:	8b 45 f8             	mov    -0x8(%ebp),%eax
    17dc:	8b 10                	mov    (%eax),%edx
    17de:	8b 45 fc             	mov    -0x4(%ebp),%eax
    17e1:	89 10                	mov    %edx,(%eax)
    17e3:	eb 08                	jmp    17ed <free+0xcd>
  } else
    p->s.ptr = bp;
    17e5:	8b 45 fc             	mov    -0x4(%ebp),%eax
    17e8:	8b 55 f8             	mov    -0x8(%ebp),%edx
    17eb:	89 10                	mov    %edx,(%eax)
  freep = p;
    17ed:	8b 45 fc             	mov    -0x4(%ebp),%eax
    17f0:	a3 0c e0 01 00       	mov    %eax,0x1e00c
}
    17f5:	c9                   	leave  
    17f6:	c3                   	ret    

000017f7 <morecore>:

static Header*
morecore(uint nu)
{
    17f7:	55                   	push   %ebp
    17f8:	89 e5                	mov    %esp,%ebp
    17fa:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
    17fd:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
    1804:	77 07                	ja     180d <morecore+0x16>
    nu = 4096;
    1806:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
    180d:	8b 45 08             	mov    0x8(%ebp),%eax
    1810:	c1 e0 03             	shl    $0x3,%eax
    1813:	89 04 24             	mov    %eax,(%esp)
    1816:	e8 39 fc ff ff       	call   1454 <sbrk>
    181b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
    181e:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
    1822:	75 07                	jne    182b <morecore+0x34>
    return 0;
    1824:	b8 00 00 00 00       	mov    $0x0,%eax
    1829:	eb 22                	jmp    184d <morecore+0x56>
  hp = (Header*)p;
    182b:	8b 45 f4             	mov    -0xc(%ebp),%eax
    182e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
    1831:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1834:	8b 55 08             	mov    0x8(%ebp),%edx
    1837:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
    183a:	8b 45 f0             	mov    -0x10(%ebp),%eax
    183d:	83 c0 08             	add    $0x8,%eax
    1840:	89 04 24             	mov    %eax,(%esp)
    1843:	e8 d8 fe ff ff       	call   1720 <free>
  return freep;
    1848:	a1 0c e0 01 00       	mov    0x1e00c,%eax
}
    184d:	c9                   	leave  
    184e:	c3                   	ret    

0000184f <malloc>:

void*
malloc(uint nbytes)
{
    184f:	55                   	push   %ebp
    1850:	89 e5                	mov    %esp,%ebp
    1852:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    1855:	8b 45 08             	mov    0x8(%ebp),%eax
    1858:	83 c0 07             	add    $0x7,%eax
    185b:	c1 e8 03             	shr    $0x3,%eax
    185e:	83 c0 01             	add    $0x1,%eax
    1861:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
    1864:	a1 0c e0 01 00       	mov    0x1e00c,%eax
    1869:	89 45 f0             	mov    %eax,-0x10(%ebp)
    186c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    1870:	75 23                	jne    1895 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
    1872:	c7 45 f0 04 e0 01 00 	movl   $0x1e004,-0x10(%ebp)
    1879:	8b 45 f0             	mov    -0x10(%ebp),%eax
    187c:	a3 0c e0 01 00       	mov    %eax,0x1e00c
    1881:	a1 0c e0 01 00       	mov    0x1e00c,%eax
    1886:	a3 04 e0 01 00       	mov    %eax,0x1e004
    base.s.size = 0;
    188b:	c7 05 08 e0 01 00 00 	movl   $0x0,0x1e008
    1892:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    1895:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1898:	8b 00                	mov    (%eax),%eax
    189a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
    189d:	8b 45 f4             	mov    -0xc(%ebp),%eax
    18a0:	8b 40 04             	mov    0x4(%eax),%eax
    18a3:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    18a6:	72 4d                	jb     18f5 <malloc+0xa6>
      if(p->s.size == nunits)
    18a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
    18ab:	8b 40 04             	mov    0x4(%eax),%eax
    18ae:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    18b1:	75 0c                	jne    18bf <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
    18b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
    18b6:	8b 10                	mov    (%eax),%edx
    18b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
    18bb:	89 10                	mov    %edx,(%eax)
    18bd:	eb 26                	jmp    18e5 <malloc+0x96>
      else {
        p->s.size -= nunits;
    18bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
    18c2:	8b 40 04             	mov    0x4(%eax),%eax
    18c5:	89 c2                	mov    %eax,%edx
    18c7:	2b 55 ec             	sub    -0x14(%ebp),%edx
    18ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
    18cd:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
    18d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
    18d3:	8b 40 04             	mov    0x4(%eax),%eax
    18d6:	c1 e0 03             	shl    $0x3,%eax
    18d9:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
    18dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
    18df:	8b 55 ec             	mov    -0x14(%ebp),%edx
    18e2:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
    18e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
    18e8:	a3 0c e0 01 00       	mov    %eax,0x1e00c
      return (void*)(p + 1);
    18ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
    18f0:	83 c0 08             	add    $0x8,%eax
    18f3:	eb 38                	jmp    192d <malloc+0xde>
    }
    if(p == freep)
    18f5:	a1 0c e0 01 00       	mov    0x1e00c,%eax
    18fa:	39 45 f4             	cmp    %eax,-0xc(%ebp)
    18fd:	75 1b                	jne    191a <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
    18ff:	8b 45 ec             	mov    -0x14(%ebp),%eax
    1902:	89 04 24             	mov    %eax,(%esp)
    1905:	e8 ed fe ff ff       	call   17f7 <morecore>
    190a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    190d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    1911:	75 07                	jne    191a <malloc+0xcb>
        return 0;
    1913:	b8 00 00 00 00       	mov    $0x0,%eax
    1918:	eb 13                	jmp    192d <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    191a:	8b 45 f4             	mov    -0xc(%ebp),%eax
    191d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    1920:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1923:	8b 00                	mov    (%eax),%eax
    1925:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
    1928:	e9 70 ff ff ff       	jmp    189d <malloc+0x4e>
}
    192d:	c9                   	leave  
    192e:	c3                   	ret    
