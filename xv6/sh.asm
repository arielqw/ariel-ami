
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
      53:	e8 7c 13 00 00       	call   13d4 <exit>
  
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
      72:	e8 50 07 00 00       	call   7c7 <panic>

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
      8e:	e8 41 13 00 00       	call   13d4 <exit>
    exec(ecmd->argv[0], ecmd->argv);
      93:	8b 45 f4             	mov    -0xc(%ebp),%eax
      96:	8d 50 04             	lea    0x4(%eax),%edx
      99:	8b 45 f4             	mov    -0xc(%ebp),%eax
      9c:	8b 40 04             	mov    0x4(%eax),%eax
      9f:	89 54 24 04          	mov    %edx,0x4(%esp)
      a3:	89 04 24             	mov    %eax,(%esp)
      a6:	e8 61 13 00 00       	call   140c <exec>
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
      dd:	e8 1a 13 00 00       	call   13fc <close>
    if(open(rcmd->file, rcmd->mode) < 0){
      e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
      e5:	8b 50 10             	mov    0x10(%eax),%edx
      e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
      eb:	8b 40 08             	mov    0x8(%eax),%eax
      ee:	89 54 24 04          	mov    %edx,0x4(%esp)
      f2:	89 04 24             	mov    %eax,(%esp)
      f5:	e8 1a 13 00 00       	call   1414 <open>
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
     123:	e8 ac 12 00 00       	call   13d4 <exit>
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
     141:	e8 ae 06 00 00       	call   7f4 <fork1>
     146:	85 c0                	test   %eax,%eax
     148:	75 0e                	jne    158 <runcmd+0x118>
      runcmd(lcmd->left);
     14a:	8b 45 ec             	mov    -0x14(%ebp),%eax
     14d:	8b 40 04             	mov    0x4(%eax),%eax
     150:	89 04 24             	mov    %eax,(%esp)
     153:	e8 e8 fe ff ff       	call   40 <runcmd>
    wait(0);
     158:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
     15f:	e8 78 12 00 00       	call   13dc <wait>
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
     183:	e8 5c 12 00 00       	call   13e4 <pipe>
     188:	85 c0                	test   %eax,%eax
     18a:	79 0c                	jns    198 <runcmd+0x158>
      panic("pipe");
     18c:	c7 04 24 57 19 00 00 	movl   $0x1957,(%esp)
     193:	e8 2f 06 00 00       	call   7c7 <panic>

    if( (left = fork1()) == 0){
     198:	e8 57 06 00 00       	call   7f4 <fork1>
     19d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
     1a0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
     1a4:	75 3b                	jne    1e1 <runcmd+0x1a1>
      close(1);
     1a6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     1ad:	e8 4a 12 00 00       	call   13fc <close>
      dup(p[1]);
     1b2:	8b 45 d8             	mov    -0x28(%ebp),%eax
     1b5:	89 04 24             	mov    %eax,(%esp)
     1b8:	e8 8f 12 00 00       	call   144c <dup>
      close(p[0]);
     1bd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
     1c0:	89 04 24             	mov    %eax,(%esp)
     1c3:	e8 34 12 00 00       	call   13fc <close>
      close(p[1]);
     1c8:	8b 45 d8             	mov    -0x28(%ebp),%eax
     1cb:	89 04 24             	mov    %eax,(%esp)
     1ce:	e8 29 12 00 00       	call   13fc <close>
      runcmd(pcmd->left);
     1d3:	8b 45 e8             	mov    -0x18(%ebp),%eax
     1d6:	8b 40 04             	mov    0x4(%eax),%eax
     1d9:	89 04 24             	mov    %eax,(%esp)
     1dc:	e8 5f fe ff ff       	call   40 <runcmd>
    }

    if( (right = fork1() ) == 0){
     1e1:	e8 0e 06 00 00       	call   7f4 <fork1>
     1e6:	89 45 e0             	mov    %eax,-0x20(%ebp)
     1e9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
     1ed:	75 3b                	jne    22a <runcmd+0x1ea>
      close(0);
     1ef:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
     1f6:	e8 01 12 00 00       	call   13fc <close>
      dup(p[0]);
     1fb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
     1fe:	89 04 24             	mov    %eax,(%esp)
     201:	e8 46 12 00 00       	call   144c <dup>
      close(p[0]);
     206:	8b 45 d4             	mov    -0x2c(%ebp),%eax
     209:	89 04 24             	mov    %eax,(%esp)
     20c:	e8 eb 11 00 00       	call   13fc <close>
      close(p[1]);
     211:	8b 45 d8             	mov    -0x28(%ebp),%eax
     214:	89 04 24             	mov    %eax,(%esp)
     217:	e8 e0 11 00 00       	call   13fc <close>
      runcmd(pcmd->right);
     21c:	8b 45 e8             	mov    -0x18(%ebp),%eax
     21f:	8b 40 08             	mov    0x8(%eax),%eax
     222:	89 04 24             	mov    %eax,(%esp)
     225:	e8 16 fe ff ff       	call   40 <runcmd>
    }
    close(p[0]);
     22a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
     22d:	89 04 24             	mov    %eax,(%esp)
     230:	e8 c7 11 00 00       	call   13fc <close>
    close(p[1]);
     235:	8b 45 d8             	mov    -0x28(%ebp),%eax
     238:	89 04 24             	mov    %eax,(%esp)
     23b:	e8 bc 11 00 00       	call   13fc <close>
    wait(0);
     240:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
     247:	e8 90 11 00 00       	call   13dc <wait>
    wait(0);
     24c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
     253:	e8 84 11 00 00       	call   13dc <wait>
    break;
     258:	eb 1e                	jmp    278 <runcmd+0x238>
    
  case BACK:
    bcmd = (struct backcmd*)cmd;
     25a:	8b 45 08             	mov    0x8(%ebp),%eax
     25d:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(fork1() == 0)
     260:	e8 8f 05 00 00       	call   7f4 <fork1>
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
     27f:	e8 50 11 00 00       	call   13d4 <exit>

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
     2b3:	e8 77 0f 00 00       	call   122f <memset>
  gets(buf, nbuf);
     2b8:	8b 45 0c             	mov    0xc(%ebp),%eax
     2bb:	89 44 24 04          	mov    %eax,0x4(%esp)
     2bf:	8b 45 08             	mov    0x8(%ebp),%eax
     2c2:	89 04 24             	mov    %eax,(%esp)
     2c5:	e8 bc 0f 00 00       	call   1286 <gets>
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
     30d:	8d 82 00 20 00 00    	lea    0x2000(%edx),%eax
     313:	8b 40 0c             	mov    0xc(%eax),%eax
     316:	85 c0                	test   %eax,%eax
     318:	0f 84 16 01 00 00    	je     434 <listJobs+0x152>
			list_pgroup(jobs_table[i].gid, arr, &size);
     31e:	8b 45 f4             	mov    -0xc(%ebp),%eax
     321:	c1 e0 04             	shl    $0x4,%eax
     324:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
     32b:	29 c2                	sub    %eax,%edx
     32d:	8d 82 00 20 00 00    	lea    0x2000(%edx),%eax
     333:	8b 40 08             	mov    0x8(%eax),%eax
     336:	8d 55 e8             	lea    -0x18(%ebp),%edx
     339:	89 54 24 08          	mov    %edx,0x8(%esp)
     33d:	8d 95 e8 fa ff ff    	lea    -0x518(%ebp),%edx
     343:	89 54 24 04          	mov    %edx,0x4(%esp)
     347:	89 04 24             	mov    %eax,(%esp)
     34a:	e8 35 11 00 00       	call   1484 <list_pgroup>
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
     370:	8d 82 00 20 00 00    	lea    0x2000(%edx),%eax
     376:	8b 48 08             	mov    0x8(%eax),%ecx
     379:	8b 45 f4             	mov    -0xc(%ebp),%eax
     37c:	c1 e0 04             	shl    $0x4,%eax
     37f:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
     386:	29 c2                	sub    %eax,%edx
     388:	8d 82 a0 1f 00 00    	lea    0x1fa0(%edx),%eax
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
     427:	8d 82 00 20 00 00    	lea    0x2000(%edx),%eax
     42d:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
	int i,j;
	int size;
	int hasJobs = 0;
	process_info_entry arr[64];

	for(i=0; i< jobs_counter; i++){
     434:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
     438:	a1 a0 df 01 00       	mov    0x1dfa0,%eax
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
	printf(1," asked to fg %d \n", job_id);
     468:	8b 45 08             	mov    0x8(%ebp),%eax
     46b:	89 44 24 08          	mov    %eax,0x8(%esp)
     46f:	c7 44 24 04 a5 19 00 	movl   $0x19a5,0x4(%esp)
     476:	00 
     477:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     47e:	e8 e8 10 00 00       	call   156b <printf>

	if(job_id == -1){
     483:	83 7d 08 ff          	cmpl   $0xffffffff,0x8(%ebp)
     487:	75 78                	jne    501 <move_to_foreground+0x9f>
		for (i = 0; i < jobs_counter; i++) {
     489:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     490:	eb 63                	jmp    4f5 <move_to_foreground+0x93>
			if( jobs_table[i].active){
     492:	8b 45 f4             	mov    -0xc(%ebp),%eax
     495:	c1 e0 04             	shl    $0x4,%eax
     498:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
     49f:	29 c2                	sub    %eax,%edx
     4a1:	8d 82 00 20 00 00    	lea    0x2000(%edx),%eax
     4a7:	8b 40 0c             	mov    0xc(%eax),%eax
     4aa:	85 c0                	test   %eax,%eax
     4ac:	74 43                	je     4f1 <move_to_foreground+0x8f>
				foreground(jobs_table[i].gid);
     4ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
     4b1:	c1 e0 04             	shl    $0x4,%eax
     4b4:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
     4bb:	29 c2                	sub    %eax,%edx
     4bd:	8d 82 00 20 00 00    	lea    0x2000(%edx),%eax
     4c3:	8b 40 08             	mov    0x8(%eax),%eax
     4c6:	89 04 24             	mov    %eax,(%esp)
     4c9:	e8 be 0f 00 00       	call   148c <foreground>
				jobs_table[i].active = 0;
     4ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
     4d1:	c1 e0 04             	shl    $0x4,%eax
     4d4:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
     4db:	29 c2                	sub    %eax,%edx
     4dd:	8d 82 00 20 00 00    	lea    0x2000(%edx),%eax
     4e3:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
				return 0;
     4ea:	b8 00 00 00 00       	mov    $0x0,%eax
     4ef:	eb 74                	jmp    565 <move_to_foreground+0x103>
int move_to_foreground(int job_id){
	int i;//, desired_job_idx;
	printf(1," asked to fg %d \n", job_id);

	if(job_id == -1){
		for (i = 0; i < jobs_counter; i++) {
     4f1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
     4f5:	a1 a0 df 01 00       	mov    0x1dfa0,%eax
     4fa:	39 45 f4             	cmp    %eax,-0xc(%ebp)
     4fd:	7c 93                	jl     492 <move_to_foreground+0x30>
     4ff:	eb 5f                	jmp    560 <move_to_foreground+0xfe>
				jobs_table[i].active = 0;
				return 0;
			}
		}
	}
	else if( jobs_table[job_id].active){
     501:	8b 45 08             	mov    0x8(%ebp),%eax
     504:	c1 e0 04             	shl    $0x4,%eax
     507:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
     50e:	29 c2                	sub    %eax,%edx
     510:	8d 82 00 20 00 00    	lea    0x2000(%edx),%eax
     516:	8b 40 0c             	mov    0xc(%eax),%eax
     519:	85 c0                	test   %eax,%eax
     51b:	74 43                	je     560 <move_to_foreground+0xfe>
		foreground(jobs_table[job_id].gid);
     51d:	8b 45 08             	mov    0x8(%ebp),%eax
     520:	c1 e0 04             	shl    $0x4,%eax
     523:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
     52a:	29 c2                	sub    %eax,%edx
     52c:	8d 82 00 20 00 00    	lea    0x2000(%edx),%eax
     532:	8b 40 08             	mov    0x8(%eax),%eax
     535:	89 04 24             	mov    %eax,(%esp)
     538:	e8 4f 0f 00 00       	call   148c <foreground>
		jobs_table[job_id].active = 0;
     53d:	8b 45 08             	mov    0x8(%ebp),%eax
     540:	c1 e0 04             	shl    $0x4,%eax
     543:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
     54a:	29 c2                	sub    %eax,%edx
     54c:	8d 82 00 20 00 00    	lea    0x2000(%edx),%eax
     552:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
		return 0;
     559:	b8 00 00 00 00       	mov    $0x0,%eax
     55e:	eb 05                	jmp    565 <move_to_foreground+0x103>
	}

	return -1;
     560:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
     565:	c9                   	leave  
     566:	c3                   	ret    

00000567 <main>:
//	printf(1," asta la vista babe ;\n");
//	return (found? 0 : -1);
//}
int
main(void)
{
     567:	55                   	push   %ebp
     568:	89 e5                	mov    %esp,%ebp
     56a:	83 e4 f0             	and    $0xfffffff0,%esp
     56d:	83 ec 20             	sub    $0x20,%esp
  static char buf[100];
  int fd;
  int child_pid;
  int job_id;
  
  jobs_table[0].active = 0;
     570:	c7 05 0c 20 00 00 00 	movl   $0x0,0x200c
     577:	00 00 00 
  if(jobs_table[0].active) printf(1, " just so it wont cry on unused");
     57a:	a1 0c 20 00 00       	mov    0x200c,%eax
     57f:	85 c0                	test   %eax,%eax
     581:	74 2f                	je     5b2 <main+0x4b>
     583:	c7 44 24 04 b8 19 00 	movl   $0x19b8,0x4(%esp)
     58a:	00 
     58b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     592:	e8 d4 0f 00 00       	call   156b <printf>

  // Assumes three file descriptors open.
  while((fd = open("console", O_RDWR)) >= 0){
     597:	eb 19                	jmp    5b2 <main+0x4b>
    if(fd >= 3){
     599:	83 7c 24 18 02       	cmpl   $0x2,0x18(%esp)
     59e:	7e 12                	jle    5b2 <main+0x4b>
      close(fd);
     5a0:	8b 44 24 18          	mov    0x18(%esp),%eax
     5a4:	89 04 24             	mov    %eax,(%esp)
     5a7:	e8 50 0e 00 00       	call   13fc <close>
      break;
     5ac:	90                   	nop
    }
  }
  
  // Read and run input commands.
  while(getcmd(buf, sizeof(buf)) >= 0){
     5ad:	e9 ed 01 00 00       	jmp    79f <main+0x238>
  
  jobs_table[0].active = 0;
  if(jobs_table[0].active) printf(1, " just so it wont cry on unused");

  // Assumes three file descriptors open.
  while((fd = open("console", O_RDWR)) >= 0){
     5b2:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
     5b9:	00 
     5ba:	c7 04 24 d7 19 00 00 	movl   $0x19d7,(%esp)
     5c1:	e8 4e 0e 00 00       	call   1414 <open>
     5c6:	89 44 24 18          	mov    %eax,0x18(%esp)
     5ca:	83 7c 24 18 00       	cmpl   $0x0,0x18(%esp)
     5cf:	79 c8                	jns    599 <main+0x32>
      break;
    }
  }
  
  // Read and run input commands.
  while(getcmd(buf, sizeof(buf)) >= 0){
     5d1:	e9 c9 01 00 00       	jmp    79f <main+0x238>
    if(buf[0] == 'c' && buf[1] == 'd' && buf[2] == ' '){
     5d6:	0f b6 05 c0 df 01 00 	movzbl 0x1dfc0,%eax
     5dd:	3c 63                	cmp    $0x63,%al
     5df:	75 61                	jne    642 <main+0xdb>
     5e1:	0f b6 05 c1 df 01 00 	movzbl 0x1dfc1,%eax
     5e8:	3c 64                	cmp    $0x64,%al
     5ea:	75 56                	jne    642 <main+0xdb>
     5ec:	0f b6 05 c2 df 01 00 	movzbl 0x1dfc2,%eax
     5f3:	3c 20                	cmp    $0x20,%al
     5f5:	75 4b                	jne    642 <main+0xdb>
      // Clumsy but will have to do for now.
      // Chdir has no effect on the parent if run in the child.
      buf[strlen(buf)-1] = 0;  // chop \n
     5f7:	c7 04 24 c0 df 01 00 	movl   $0x1dfc0,(%esp)
     5fe:	e8 07 0c 00 00       	call   120a <strlen>
     603:	83 e8 01             	sub    $0x1,%eax
     606:	c6 80 c0 df 01 00 00 	movb   $0x0,0x1dfc0(%eax)
      if(chdir(buf+3) < 0)
     60d:	c7 04 24 c3 df 01 00 	movl   $0x1dfc3,(%esp)
     614:	e8 2b 0e 00 00       	call   1444 <chdir>
     619:	85 c0                	test   %eax,%eax
     61b:	0f 89 7d 01 00 00    	jns    79e <main+0x237>
        printf(2, "cannot cd %s\n", buf+3);
     621:	c7 44 24 08 c3 df 01 	movl   $0x1dfc3,0x8(%esp)
     628:	00 
     629:	c7 44 24 04 df 19 00 	movl   $0x19df,0x4(%esp)
     630:	00 
     631:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     638:	e8 2e 0f 00 00       	call   156b <printf>
      continue;
     63d:	e9 5c 01 00 00       	jmp    79e <main+0x237>
    }

    if(buf[0] == 'j' && buf[1] == 'o' && buf[2] == 'b' && buf[3] == 's' && buf[4] == '\n'){
     642:	0f b6 05 c0 df 01 00 	movzbl 0x1dfc0,%eax
     649:	3c 6a                	cmp    $0x6a,%al
     64b:	75 36                	jne    683 <main+0x11c>
     64d:	0f b6 05 c1 df 01 00 	movzbl 0x1dfc1,%eax
     654:	3c 6f                	cmp    $0x6f,%al
     656:	75 2b                	jne    683 <main+0x11c>
     658:	0f b6 05 c2 df 01 00 	movzbl 0x1dfc2,%eax
     65f:	3c 62                	cmp    $0x62,%al
     661:	75 20                	jne    683 <main+0x11c>
     663:	0f b6 05 c3 df 01 00 	movzbl 0x1dfc3,%eax
     66a:	3c 73                	cmp    $0x73,%al
     66c:	75 15                	jne    683 <main+0x11c>
     66e:	0f b6 05 c4 df 01 00 	movzbl 0x1dfc4,%eax
     675:	3c 0a                	cmp    $0xa,%al
     677:	75 0a                	jne    683 <main+0x11c>
      listJobs();
     679:	e8 64 fc ff ff       	call   2e2 <listJobs>
	  continue;
     67e:	e9 1c 01 00 00       	jmp    79f <main+0x238>
	}

    if(buf[0] == 'f' && buf[1] == 'g' ){
     683:	0f b6 05 c0 df 01 00 	movzbl 0x1dfc0,%eax
     68a:	3c 66                	cmp    $0x66,%al
     68c:	75 4c                	jne    6da <main+0x173>
     68e:	0f b6 05 c1 df 01 00 	movzbl 0x1dfc1,%eax
     695:	3c 67                	cmp    $0x67,%al
     697:	75 41                	jne    6da <main+0x173>
		if( buf[2] == '\n' ){
     699:	0f b6 05 c2 df 01 00 	movzbl 0x1dfc2,%eax
     6a0:	3c 0a                	cmp    $0xa,%al
     6a2:	75 0a                	jne    6ae <main+0x147>
			job_id = -1;
     6a4:	c7 44 24 1c ff ff ff 	movl   $0xffffffff,0x1c(%esp)
     6ab:	ff 
     6ac:	eb 1b                	jmp    6c9 <main+0x162>
		}
		else if( buf[2] == ' ' ){
     6ae:	0f b6 05 c2 df 01 00 	movzbl 0x1dfc2,%eax
     6b5:	3c 20                	cmp    $0x20,%al
     6b7:	75 10                	jne    6c9 <main+0x162>
			job_id = atoi(buf+3);
     6b9:	c7 04 24 c3 df 01 00 	movl   $0x1dfc3,(%esp)
     6c0:	e8 7e 0c 00 00       	call   1343 <atoi>
     6c5:	89 44 24 1c          	mov    %eax,0x1c(%esp)
		}

		move_to_foreground(job_id);
     6c9:	8b 44 24 1c          	mov    0x1c(%esp),%eax
     6cd:	89 04 24             	mov    %eax,(%esp)
     6d0:	e8 8d fd ff ff       	call   462 <move_to_foreground>
		continue;
     6d5:	e9 c5 00 00 00       	jmp    79f <main+0x238>
	}

    if((child_pid = fork1()) == 0){
     6da:	e8 15 01 00 00       	call   7f4 <fork1>
     6df:	89 44 24 14          	mov    %eax,0x14(%esp)
     6e3:	83 7c 24 14 00       	cmpl   $0x0,0x14(%esp)
     6e8:	75 14                	jne    6fe <main+0x197>
        runcmd(parsecmd(buf));
     6ea:	c7 04 24 c0 df 01 00 	movl   $0x1dfc0,(%esp)
     6f1:	e8 70 04 00 00       	call   b66 <parsecmd>
     6f6:	89 04 24             	mov    %eax,(%esp)
     6f9:	e8 42 f9 ff ff       	call   40 <runcmd>
    }
    //keep track on jobs
    jobs_table[jobs_counter].gid = child_pid;
     6fe:	a1 a0 df 01 00       	mov    0x1dfa0,%eax
     703:	c1 e0 04             	shl    $0x4,%eax
     706:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
     70d:	29 c2                	sub    %eax,%edx
     70f:	81 c2 00 20 00 00    	add    $0x2000,%edx
     715:	8b 44 24 14          	mov    0x14(%esp),%eax
     719:	89 42 08             	mov    %eax,0x8(%edx)
    jobs_table[jobs_counter].num = jobs_counter;
     71c:	a1 a0 df 01 00       	mov    0x1dfa0,%eax
     721:	8b 0d a0 df 01 00    	mov    0x1dfa0,%ecx
     727:	c1 e0 04             	shl    $0x4,%eax
     72a:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
     731:	29 c2                	sub    %eax,%edx
     733:	8d 82 a0 1f 00 00    	lea    0x1fa0(%edx),%eax
     739:	89 08                	mov    %ecx,(%eax)
    jobs_table[jobs_counter].active = 1;
     73b:	a1 a0 df 01 00       	mov    0x1dfa0,%eax
     740:	c1 e0 04             	shl    $0x4,%eax
     743:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
     74a:	29 c2                	sub    %eax,%edx
     74c:	8d 82 00 20 00 00    	lea    0x2000(%edx),%eax
     752:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
    copyString(jobs_table[jobs_counter].cmd, buf);
     759:	a1 a0 df 01 00       	mov    0x1dfa0,%eax
     75e:	c1 e0 04             	shl    $0x4,%eax
     761:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
     768:	29 c2                	sub    %eax,%edx
     76a:	8d 82 a0 1f 00 00    	lea    0x1fa0(%edx),%eax
     770:	83 c0 04             	add    $0x4,%eax
     773:	c7 44 24 04 c0 df 01 	movl   $0x1dfc0,0x4(%esp)
     77a:	00 
     77b:	89 04 24             	mov    %eax,(%esp)
     77e:	e8 7d f8 ff ff       	call   0 <copyString>
	jobs_counter++;
     783:	a1 a0 df 01 00       	mov    0x1dfa0,%eax
     788:	83 c0 01             	add    $0x1,%eax
     78b:	a3 a0 df 01 00       	mov    %eax,0x1dfa0

    wait(0);
     790:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
     797:	e8 40 0c 00 00       	call   13dc <wait>
     79c:	eb 01                	jmp    79f <main+0x238>
      // Clumsy but will have to do for now.
      // Chdir has no effect on the parent if run in the child.
      buf[strlen(buf)-1] = 0;  // chop \n
      if(chdir(buf+3) < 0)
        printf(2, "cannot cd %s\n", buf+3);
      continue;
     79e:	90                   	nop
      break;
    }
  }
  
  // Read and run input commands.
  while(getcmd(buf, sizeof(buf)) >= 0){
     79f:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
     7a6:	00 
     7a7:	c7 04 24 c0 df 01 00 	movl   $0x1dfc0,(%esp)
     7ae:	e8 d1 fa ff ff       	call   284 <getcmd>
     7b3:	85 c0                	test   %eax,%eax
     7b5:	0f 89 1b fe ff ff    	jns    5d6 <main+0x6f>
    copyString(jobs_table[jobs_counter].cmd, buf);
	jobs_counter++;

    wait(0);
  }
  exit(EXIT_STATUS_DEFAULT);
     7bb:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     7c2:	e8 0d 0c 00 00       	call   13d4 <exit>

000007c7 <panic>:
}

void
panic(char *s)
{
     7c7:	55                   	push   %ebp
     7c8:	89 e5                	mov    %esp,%ebp
     7ca:	83 ec 18             	sub    $0x18,%esp
  printf(2, "%s\n", s);
     7cd:	8b 45 08             	mov    0x8(%ebp),%eax
     7d0:	89 44 24 08          	mov    %eax,0x8(%esp)
     7d4:	c7 44 24 04 ed 19 00 	movl   $0x19ed,0x4(%esp)
     7db:	00 
     7dc:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     7e3:	e8 83 0d 00 00       	call   156b <printf>
  exit(EXIT_STATUS_DEFAULT);
     7e8:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     7ef:	e8 e0 0b 00 00       	call   13d4 <exit>

000007f4 <fork1>:
}

int
fork1(void)
{
     7f4:	55                   	push   %ebp
     7f5:	89 e5                	mov    %esp,%ebp
     7f7:	83 ec 28             	sub    $0x28,%esp
  int pid;
  
  pid = fork();
     7fa:	e8 cd 0b 00 00       	call   13cc <fork>
     7ff:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pid == -1)
     802:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
     806:	75 0c                	jne    814 <fork1+0x20>
    panic("fork");
     808:	c7 04 24 f1 19 00 00 	movl   $0x19f1,(%esp)
     80f:	e8 b3 ff ff ff       	call   7c7 <panic>
  return pid;
     814:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     817:	c9                   	leave  
     818:	c3                   	ret    

00000819 <execcmd>:
//PAGEBREAK!
// Constructors

struct cmd*
execcmd(void)
{
     819:	55                   	push   %ebp
     81a:	89 e5                	mov    %esp,%ebp
     81c:	83 ec 28             	sub    $0x28,%esp
  struct execcmd *cmd;

  cmd = malloc(sizeof(*cmd));
     81f:	c7 04 24 54 00 00 00 	movl   $0x54,(%esp)
     826:	e8 24 10 00 00       	call   184f <malloc>
     82b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(cmd, 0, sizeof(*cmd));
     82e:	c7 44 24 08 54 00 00 	movl   $0x54,0x8(%esp)
     835:	00 
     836:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     83d:	00 
     83e:	8b 45 f4             	mov    -0xc(%ebp),%eax
     841:	89 04 24             	mov    %eax,(%esp)
     844:	e8 e6 09 00 00       	call   122f <memset>
  cmd->type = EXEC;
     849:	8b 45 f4             	mov    -0xc(%ebp),%eax
     84c:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  return (struct cmd*)cmd;
     852:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     855:	c9                   	leave  
     856:	c3                   	ret    

00000857 <redircmd>:

struct cmd*
redircmd(struct cmd *subcmd, char *file, char *efile, int mode, int fd)
{
     857:	55                   	push   %ebp
     858:	89 e5                	mov    %esp,%ebp
     85a:	83 ec 28             	sub    $0x28,%esp
  struct redircmd *cmd;

  cmd = malloc(sizeof(*cmd));
     85d:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
     864:	e8 e6 0f 00 00       	call   184f <malloc>
     869:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(cmd, 0, sizeof(*cmd));
     86c:	c7 44 24 08 18 00 00 	movl   $0x18,0x8(%esp)
     873:	00 
     874:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     87b:	00 
     87c:	8b 45 f4             	mov    -0xc(%ebp),%eax
     87f:	89 04 24             	mov    %eax,(%esp)
     882:	e8 a8 09 00 00       	call   122f <memset>
  cmd->type = REDIR;
     887:	8b 45 f4             	mov    -0xc(%ebp),%eax
     88a:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  cmd->cmd = subcmd;
     890:	8b 45 f4             	mov    -0xc(%ebp),%eax
     893:	8b 55 08             	mov    0x8(%ebp),%edx
     896:	89 50 04             	mov    %edx,0x4(%eax)
  cmd->file = file;
     899:	8b 45 f4             	mov    -0xc(%ebp),%eax
     89c:	8b 55 0c             	mov    0xc(%ebp),%edx
     89f:	89 50 08             	mov    %edx,0x8(%eax)
  cmd->efile = efile;
     8a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
     8a5:	8b 55 10             	mov    0x10(%ebp),%edx
     8a8:	89 50 0c             	mov    %edx,0xc(%eax)
  cmd->mode = mode;
     8ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
     8ae:	8b 55 14             	mov    0x14(%ebp),%edx
     8b1:	89 50 10             	mov    %edx,0x10(%eax)
  cmd->fd = fd;
     8b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
     8b7:	8b 55 18             	mov    0x18(%ebp),%edx
     8ba:	89 50 14             	mov    %edx,0x14(%eax)
  return (struct cmd*)cmd;
     8bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     8c0:	c9                   	leave  
     8c1:	c3                   	ret    

000008c2 <pipecmd>:

struct cmd*
pipecmd(struct cmd *left, struct cmd *right)
{
     8c2:	55                   	push   %ebp
     8c3:	89 e5                	mov    %esp,%ebp
     8c5:	83 ec 28             	sub    $0x28,%esp
  struct pipecmd *cmd;

  cmd = malloc(sizeof(*cmd));
     8c8:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
     8cf:	e8 7b 0f 00 00       	call   184f <malloc>
     8d4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(cmd, 0, sizeof(*cmd));
     8d7:	c7 44 24 08 0c 00 00 	movl   $0xc,0x8(%esp)
     8de:	00 
     8df:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     8e6:	00 
     8e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
     8ea:	89 04 24             	mov    %eax,(%esp)
     8ed:	e8 3d 09 00 00       	call   122f <memset>
  cmd->type = PIPE;
     8f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
     8f5:	c7 00 03 00 00 00    	movl   $0x3,(%eax)
  cmd->left = left;
     8fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
     8fe:	8b 55 08             	mov    0x8(%ebp),%edx
     901:	89 50 04             	mov    %edx,0x4(%eax)
  cmd->right = right;
     904:	8b 45 f4             	mov    -0xc(%ebp),%eax
     907:	8b 55 0c             	mov    0xc(%ebp),%edx
     90a:	89 50 08             	mov    %edx,0x8(%eax)
  return (struct cmd*)cmd;
     90d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     910:	c9                   	leave  
     911:	c3                   	ret    

00000912 <listcmd>:

struct cmd*
listcmd(struct cmd *left, struct cmd *right)
{
     912:	55                   	push   %ebp
     913:	89 e5                	mov    %esp,%ebp
     915:	83 ec 28             	sub    $0x28,%esp
  struct listcmd *cmd;

  cmd = malloc(sizeof(*cmd));
     918:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
     91f:	e8 2b 0f 00 00       	call   184f <malloc>
     924:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(cmd, 0, sizeof(*cmd));
     927:	c7 44 24 08 0c 00 00 	movl   $0xc,0x8(%esp)
     92e:	00 
     92f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     936:	00 
     937:	8b 45 f4             	mov    -0xc(%ebp),%eax
     93a:	89 04 24             	mov    %eax,(%esp)
     93d:	e8 ed 08 00 00       	call   122f <memset>
  cmd->type = LIST;
     942:	8b 45 f4             	mov    -0xc(%ebp),%eax
     945:	c7 00 04 00 00 00    	movl   $0x4,(%eax)
  cmd->left = left;
     94b:	8b 45 f4             	mov    -0xc(%ebp),%eax
     94e:	8b 55 08             	mov    0x8(%ebp),%edx
     951:	89 50 04             	mov    %edx,0x4(%eax)
  cmd->right = right;
     954:	8b 45 f4             	mov    -0xc(%ebp),%eax
     957:	8b 55 0c             	mov    0xc(%ebp),%edx
     95a:	89 50 08             	mov    %edx,0x8(%eax)
  return (struct cmd*)cmd;
     95d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     960:	c9                   	leave  
     961:	c3                   	ret    

00000962 <backcmd>:

struct cmd*
backcmd(struct cmd *subcmd)
{
     962:	55                   	push   %ebp
     963:	89 e5                	mov    %esp,%ebp
     965:	83 ec 28             	sub    $0x28,%esp
  struct backcmd *cmd;

  cmd = malloc(sizeof(*cmd));
     968:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
     96f:	e8 db 0e 00 00       	call   184f <malloc>
     974:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(cmd, 0, sizeof(*cmd));
     977:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
     97e:	00 
     97f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     986:	00 
     987:	8b 45 f4             	mov    -0xc(%ebp),%eax
     98a:	89 04 24             	mov    %eax,(%esp)
     98d:	e8 9d 08 00 00       	call   122f <memset>
  cmd->type = BACK;
     992:	8b 45 f4             	mov    -0xc(%ebp),%eax
     995:	c7 00 05 00 00 00    	movl   $0x5,(%eax)
  cmd->cmd = subcmd;
     99b:	8b 45 f4             	mov    -0xc(%ebp),%eax
     99e:	8b 55 08             	mov    0x8(%ebp),%edx
     9a1:	89 50 04             	mov    %edx,0x4(%eax)
  return (struct cmd*)cmd;
     9a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     9a7:	c9                   	leave  
     9a8:	c3                   	ret    

000009a9 <gettoken>:
char whitespace[] = " \t\r\n\v";
char symbols[] = "<|>&;()";

int
gettoken(char **ps, char *es, char **q, char **eq)
{
     9a9:	55                   	push   %ebp
     9aa:	89 e5                	mov    %esp,%ebp
     9ac:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int ret;
  
  s = *ps;
     9af:	8b 45 08             	mov    0x8(%ebp),%eax
     9b2:	8b 00                	mov    (%eax),%eax
     9b4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(s < es && strchr(whitespace, *s))
     9b7:	eb 04                	jmp    9bd <gettoken+0x14>
    s++;
     9b9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
{
  char *s;
  int ret;
  
  s = *ps;
  while(s < es && strchr(whitespace, *s))
     9bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
     9c0:	3b 45 0c             	cmp    0xc(%ebp),%eax
     9c3:	73 1d                	jae    9e2 <gettoken+0x39>
     9c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
     9c8:	0f b6 00             	movzbl (%eax),%eax
     9cb:	0f be c0             	movsbl %al,%eax
     9ce:	89 44 24 04          	mov    %eax,0x4(%esp)
     9d2:	c7 04 24 60 1f 00 00 	movl   $0x1f60,(%esp)
     9d9:	e8 75 08 00 00       	call   1253 <strchr>
     9de:	85 c0                	test   %eax,%eax
     9e0:	75 d7                	jne    9b9 <gettoken+0x10>
    s++;
  if(q)
     9e2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
     9e6:	74 08                	je     9f0 <gettoken+0x47>
    *q = s;
     9e8:	8b 45 10             	mov    0x10(%ebp),%eax
     9eb:	8b 55 f4             	mov    -0xc(%ebp),%edx
     9ee:	89 10                	mov    %edx,(%eax)
  ret = *s;
     9f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
     9f3:	0f b6 00             	movzbl (%eax),%eax
     9f6:	0f be c0             	movsbl %al,%eax
     9f9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  switch(*s){
     9fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
     9ff:	0f b6 00             	movzbl (%eax),%eax
     a02:	0f be c0             	movsbl %al,%eax
     a05:	83 f8 3c             	cmp    $0x3c,%eax
     a08:	7f 1e                	jg     a28 <gettoken+0x7f>
     a0a:	83 f8 3b             	cmp    $0x3b,%eax
     a0d:	7d 23                	jge    a32 <gettoken+0x89>
     a0f:	83 f8 29             	cmp    $0x29,%eax
     a12:	7f 3f                	jg     a53 <gettoken+0xaa>
     a14:	83 f8 28             	cmp    $0x28,%eax
     a17:	7d 19                	jge    a32 <gettoken+0x89>
     a19:	85 c0                	test   %eax,%eax
     a1b:	0f 84 83 00 00 00    	je     aa4 <gettoken+0xfb>
     a21:	83 f8 26             	cmp    $0x26,%eax
     a24:	74 0c                	je     a32 <gettoken+0x89>
     a26:	eb 2b                	jmp    a53 <gettoken+0xaa>
     a28:	83 f8 3e             	cmp    $0x3e,%eax
     a2b:	74 0b                	je     a38 <gettoken+0x8f>
     a2d:	83 f8 7c             	cmp    $0x7c,%eax
     a30:	75 21                	jne    a53 <gettoken+0xaa>
  case '(':
  case ')':
  case ';':
  case '&':
  case '<':
    s++;
     a32:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    break;
     a36:	eb 73                	jmp    aab <gettoken+0x102>
  case '>':
    s++;
     a38:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(*s == '>'){
     a3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
     a3f:	0f b6 00             	movzbl (%eax),%eax
     a42:	3c 3e                	cmp    $0x3e,%al
     a44:	75 61                	jne    aa7 <gettoken+0xfe>
      ret = '+';
     a46:	c7 45 f0 2b 00 00 00 	movl   $0x2b,-0x10(%ebp)
      s++;
     a4d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    }
    break;
     a51:	eb 54                	jmp    aa7 <gettoken+0xfe>
  default:
    ret = 'a';
     a53:	c7 45 f0 61 00 00 00 	movl   $0x61,-0x10(%ebp)
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
     a5a:	eb 04                	jmp    a60 <gettoken+0xb7>
      s++;
     a5c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      s++;
    }
    break;
  default:
    ret = 'a';
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
     a60:	8b 45 f4             	mov    -0xc(%ebp),%eax
     a63:	3b 45 0c             	cmp    0xc(%ebp),%eax
     a66:	73 42                	jae    aaa <gettoken+0x101>
     a68:	8b 45 f4             	mov    -0xc(%ebp),%eax
     a6b:	0f b6 00             	movzbl (%eax),%eax
     a6e:	0f be c0             	movsbl %al,%eax
     a71:	89 44 24 04          	mov    %eax,0x4(%esp)
     a75:	c7 04 24 60 1f 00 00 	movl   $0x1f60,(%esp)
     a7c:	e8 d2 07 00 00       	call   1253 <strchr>
     a81:	85 c0                	test   %eax,%eax
     a83:	75 25                	jne    aaa <gettoken+0x101>
     a85:	8b 45 f4             	mov    -0xc(%ebp),%eax
     a88:	0f b6 00             	movzbl (%eax),%eax
     a8b:	0f be c0             	movsbl %al,%eax
     a8e:	89 44 24 04          	mov    %eax,0x4(%esp)
     a92:	c7 04 24 66 1f 00 00 	movl   $0x1f66,(%esp)
     a99:	e8 b5 07 00 00       	call   1253 <strchr>
     a9e:	85 c0                	test   %eax,%eax
     aa0:	74 ba                	je     a5c <gettoken+0xb3>
      s++;
    break;
     aa2:	eb 06                	jmp    aaa <gettoken+0x101>
  if(q)
    *q = s;
  ret = *s;
  switch(*s){
  case 0:
    break;
     aa4:	90                   	nop
     aa5:	eb 04                	jmp    aab <gettoken+0x102>
    s++;
    if(*s == '>'){
      ret = '+';
      s++;
    }
    break;
     aa7:	90                   	nop
     aa8:	eb 01                	jmp    aab <gettoken+0x102>
  default:
    ret = 'a';
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
      s++;
    break;
     aaa:	90                   	nop
  }
  if(eq)
     aab:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
     aaf:	74 0e                	je     abf <gettoken+0x116>
    *eq = s;
     ab1:	8b 45 14             	mov    0x14(%ebp),%eax
     ab4:	8b 55 f4             	mov    -0xc(%ebp),%edx
     ab7:	89 10                	mov    %edx,(%eax)
  
  while(s < es && strchr(whitespace, *s))
     ab9:	eb 04                	jmp    abf <gettoken+0x116>
    s++;
     abb:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    break;
  }
  if(eq)
    *eq = s;
  
  while(s < es && strchr(whitespace, *s))
     abf:	8b 45 f4             	mov    -0xc(%ebp),%eax
     ac2:	3b 45 0c             	cmp    0xc(%ebp),%eax
     ac5:	73 1d                	jae    ae4 <gettoken+0x13b>
     ac7:	8b 45 f4             	mov    -0xc(%ebp),%eax
     aca:	0f b6 00             	movzbl (%eax),%eax
     acd:	0f be c0             	movsbl %al,%eax
     ad0:	89 44 24 04          	mov    %eax,0x4(%esp)
     ad4:	c7 04 24 60 1f 00 00 	movl   $0x1f60,(%esp)
     adb:	e8 73 07 00 00       	call   1253 <strchr>
     ae0:	85 c0                	test   %eax,%eax
     ae2:	75 d7                	jne    abb <gettoken+0x112>
    s++;
  *ps = s;
     ae4:	8b 45 08             	mov    0x8(%ebp),%eax
     ae7:	8b 55 f4             	mov    -0xc(%ebp),%edx
     aea:	89 10                	mov    %edx,(%eax)
  return ret;
     aec:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
     aef:	c9                   	leave  
     af0:	c3                   	ret    

00000af1 <peek>:

int
peek(char **ps, char *es, char *toks)
{
     af1:	55                   	push   %ebp
     af2:	89 e5                	mov    %esp,%ebp
     af4:	83 ec 28             	sub    $0x28,%esp
  char *s;
  
  s = *ps;
     af7:	8b 45 08             	mov    0x8(%ebp),%eax
     afa:	8b 00                	mov    (%eax),%eax
     afc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(s < es && strchr(whitespace, *s))
     aff:	eb 04                	jmp    b05 <peek+0x14>
    s++;
     b01:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
peek(char **ps, char *es, char *toks)
{
  char *s;
  
  s = *ps;
  while(s < es && strchr(whitespace, *s))
     b05:	8b 45 f4             	mov    -0xc(%ebp),%eax
     b08:	3b 45 0c             	cmp    0xc(%ebp),%eax
     b0b:	73 1d                	jae    b2a <peek+0x39>
     b0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
     b10:	0f b6 00             	movzbl (%eax),%eax
     b13:	0f be c0             	movsbl %al,%eax
     b16:	89 44 24 04          	mov    %eax,0x4(%esp)
     b1a:	c7 04 24 60 1f 00 00 	movl   $0x1f60,(%esp)
     b21:	e8 2d 07 00 00       	call   1253 <strchr>
     b26:	85 c0                	test   %eax,%eax
     b28:	75 d7                	jne    b01 <peek+0x10>
    s++;
  *ps = s;
     b2a:	8b 45 08             	mov    0x8(%ebp),%eax
     b2d:	8b 55 f4             	mov    -0xc(%ebp),%edx
     b30:	89 10                	mov    %edx,(%eax)
  return *s && strchr(toks, *s);
     b32:	8b 45 f4             	mov    -0xc(%ebp),%eax
     b35:	0f b6 00             	movzbl (%eax),%eax
     b38:	84 c0                	test   %al,%al
     b3a:	74 23                	je     b5f <peek+0x6e>
     b3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
     b3f:	0f b6 00             	movzbl (%eax),%eax
     b42:	0f be c0             	movsbl %al,%eax
     b45:	89 44 24 04          	mov    %eax,0x4(%esp)
     b49:	8b 45 10             	mov    0x10(%ebp),%eax
     b4c:	89 04 24             	mov    %eax,(%esp)
     b4f:	e8 ff 06 00 00       	call   1253 <strchr>
     b54:	85 c0                	test   %eax,%eax
     b56:	74 07                	je     b5f <peek+0x6e>
     b58:	b8 01 00 00 00       	mov    $0x1,%eax
     b5d:	eb 05                	jmp    b64 <peek+0x73>
     b5f:	b8 00 00 00 00       	mov    $0x0,%eax
}
     b64:	c9                   	leave  
     b65:	c3                   	ret    

00000b66 <parsecmd>:
struct cmd *parseexec(char**, char*);
struct cmd *nulterminate(struct cmd*);

struct cmd*
parsecmd(char *s)
{
     b66:	55                   	push   %ebp
     b67:	89 e5                	mov    %esp,%ebp
     b69:	53                   	push   %ebx
     b6a:	83 ec 24             	sub    $0x24,%esp
  char *es;
  struct cmd *cmd;

  es = s + strlen(s);
     b6d:	8b 5d 08             	mov    0x8(%ebp),%ebx
     b70:	8b 45 08             	mov    0x8(%ebp),%eax
     b73:	89 04 24             	mov    %eax,(%esp)
     b76:	e8 8f 06 00 00       	call   120a <strlen>
     b7b:	01 d8                	add    %ebx,%eax
     b7d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cmd = parseline(&s, es);
     b80:	8b 45 f4             	mov    -0xc(%ebp),%eax
     b83:	89 44 24 04          	mov    %eax,0x4(%esp)
     b87:	8d 45 08             	lea    0x8(%ebp),%eax
     b8a:	89 04 24             	mov    %eax,(%esp)
     b8d:	e8 60 00 00 00       	call   bf2 <parseline>
     b92:	89 45 f0             	mov    %eax,-0x10(%ebp)
  peek(&s, es, "");
     b95:	c7 44 24 08 f6 19 00 	movl   $0x19f6,0x8(%esp)
     b9c:	00 
     b9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
     ba0:	89 44 24 04          	mov    %eax,0x4(%esp)
     ba4:	8d 45 08             	lea    0x8(%ebp),%eax
     ba7:	89 04 24             	mov    %eax,(%esp)
     baa:	e8 42 ff ff ff       	call   af1 <peek>
  if(s != es){
     baf:	8b 45 08             	mov    0x8(%ebp),%eax
     bb2:	3b 45 f4             	cmp    -0xc(%ebp),%eax
     bb5:	74 27                	je     bde <parsecmd+0x78>
    printf(2, "leftovers: %s\n", s);
     bb7:	8b 45 08             	mov    0x8(%ebp),%eax
     bba:	89 44 24 08          	mov    %eax,0x8(%esp)
     bbe:	c7 44 24 04 f7 19 00 	movl   $0x19f7,0x4(%esp)
     bc5:	00 
     bc6:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     bcd:	e8 99 09 00 00       	call   156b <printf>
    panic("syntax");
     bd2:	c7 04 24 06 1a 00 00 	movl   $0x1a06,(%esp)
     bd9:	e8 e9 fb ff ff       	call   7c7 <panic>
  }
  nulterminate(cmd);
     bde:	8b 45 f0             	mov    -0x10(%ebp),%eax
     be1:	89 04 24             	mov    %eax,(%esp)
     be4:	e8 a5 04 00 00       	call   108e <nulterminate>
  return cmd;
     be9:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
     bec:	83 c4 24             	add    $0x24,%esp
     bef:	5b                   	pop    %ebx
     bf0:	5d                   	pop    %ebp
     bf1:	c3                   	ret    

00000bf2 <parseline>:

struct cmd*
parseline(char **ps, char *es)
{
     bf2:	55                   	push   %ebp
     bf3:	89 e5                	mov    %esp,%ebp
     bf5:	83 ec 28             	sub    $0x28,%esp
  struct cmd *cmd;

  cmd = parsepipe(ps, es);
     bf8:	8b 45 0c             	mov    0xc(%ebp),%eax
     bfb:	89 44 24 04          	mov    %eax,0x4(%esp)
     bff:	8b 45 08             	mov    0x8(%ebp),%eax
     c02:	89 04 24             	mov    %eax,(%esp)
     c05:	e8 bc 00 00 00       	call   cc6 <parsepipe>
     c0a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(peek(ps, es, "&")){
     c0d:	eb 30                	jmp    c3f <parseline+0x4d>
    gettoken(ps, es, 0, 0);
     c0f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
     c16:	00 
     c17:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
     c1e:	00 
     c1f:	8b 45 0c             	mov    0xc(%ebp),%eax
     c22:	89 44 24 04          	mov    %eax,0x4(%esp)
     c26:	8b 45 08             	mov    0x8(%ebp),%eax
     c29:	89 04 24             	mov    %eax,(%esp)
     c2c:	e8 78 fd ff ff       	call   9a9 <gettoken>
    cmd = backcmd(cmd);
     c31:	8b 45 f4             	mov    -0xc(%ebp),%eax
     c34:	89 04 24             	mov    %eax,(%esp)
     c37:	e8 26 fd ff ff       	call   962 <backcmd>
     c3c:	89 45 f4             	mov    %eax,-0xc(%ebp)
parseline(char **ps, char *es)
{
  struct cmd *cmd;

  cmd = parsepipe(ps, es);
  while(peek(ps, es, "&")){
     c3f:	c7 44 24 08 0d 1a 00 	movl   $0x1a0d,0x8(%esp)
     c46:	00 
     c47:	8b 45 0c             	mov    0xc(%ebp),%eax
     c4a:	89 44 24 04          	mov    %eax,0x4(%esp)
     c4e:	8b 45 08             	mov    0x8(%ebp),%eax
     c51:	89 04 24             	mov    %eax,(%esp)
     c54:	e8 98 fe ff ff       	call   af1 <peek>
     c59:	85 c0                	test   %eax,%eax
     c5b:	75 b2                	jne    c0f <parseline+0x1d>
    gettoken(ps, es, 0, 0);
    cmd = backcmd(cmd);
  }
  if(peek(ps, es, ";")){
     c5d:	c7 44 24 08 0f 1a 00 	movl   $0x1a0f,0x8(%esp)
     c64:	00 
     c65:	8b 45 0c             	mov    0xc(%ebp),%eax
     c68:	89 44 24 04          	mov    %eax,0x4(%esp)
     c6c:	8b 45 08             	mov    0x8(%ebp),%eax
     c6f:	89 04 24             	mov    %eax,(%esp)
     c72:	e8 7a fe ff ff       	call   af1 <peek>
     c77:	85 c0                	test   %eax,%eax
     c79:	74 46                	je     cc1 <parseline+0xcf>
    gettoken(ps, es, 0, 0);
     c7b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
     c82:	00 
     c83:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
     c8a:	00 
     c8b:	8b 45 0c             	mov    0xc(%ebp),%eax
     c8e:	89 44 24 04          	mov    %eax,0x4(%esp)
     c92:	8b 45 08             	mov    0x8(%ebp),%eax
     c95:	89 04 24             	mov    %eax,(%esp)
     c98:	e8 0c fd ff ff       	call   9a9 <gettoken>
    cmd = listcmd(cmd, parseline(ps, es));
     c9d:	8b 45 0c             	mov    0xc(%ebp),%eax
     ca0:	89 44 24 04          	mov    %eax,0x4(%esp)
     ca4:	8b 45 08             	mov    0x8(%ebp),%eax
     ca7:	89 04 24             	mov    %eax,(%esp)
     caa:	e8 43 ff ff ff       	call   bf2 <parseline>
     caf:	89 44 24 04          	mov    %eax,0x4(%esp)
     cb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
     cb6:	89 04 24             	mov    %eax,(%esp)
     cb9:	e8 54 fc ff ff       	call   912 <listcmd>
     cbe:	89 45 f4             	mov    %eax,-0xc(%ebp)
  }
  return cmd;
     cc1:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     cc4:	c9                   	leave  
     cc5:	c3                   	ret    

00000cc6 <parsepipe>:

struct cmd*
parsepipe(char **ps, char *es)
{
     cc6:	55                   	push   %ebp
     cc7:	89 e5                	mov    %esp,%ebp
     cc9:	83 ec 28             	sub    $0x28,%esp
  struct cmd *cmd;

  cmd = parseexec(ps, es);
     ccc:	8b 45 0c             	mov    0xc(%ebp),%eax
     ccf:	89 44 24 04          	mov    %eax,0x4(%esp)
     cd3:	8b 45 08             	mov    0x8(%ebp),%eax
     cd6:	89 04 24             	mov    %eax,(%esp)
     cd9:	e8 68 02 00 00       	call   f46 <parseexec>
     cde:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(peek(ps, es, "|")){
     ce1:	c7 44 24 08 11 1a 00 	movl   $0x1a11,0x8(%esp)
     ce8:	00 
     ce9:	8b 45 0c             	mov    0xc(%ebp),%eax
     cec:	89 44 24 04          	mov    %eax,0x4(%esp)
     cf0:	8b 45 08             	mov    0x8(%ebp),%eax
     cf3:	89 04 24             	mov    %eax,(%esp)
     cf6:	e8 f6 fd ff ff       	call   af1 <peek>
     cfb:	85 c0                	test   %eax,%eax
     cfd:	74 46                	je     d45 <parsepipe+0x7f>
    gettoken(ps, es, 0, 0);
     cff:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
     d06:	00 
     d07:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
     d0e:	00 
     d0f:	8b 45 0c             	mov    0xc(%ebp),%eax
     d12:	89 44 24 04          	mov    %eax,0x4(%esp)
     d16:	8b 45 08             	mov    0x8(%ebp),%eax
     d19:	89 04 24             	mov    %eax,(%esp)
     d1c:	e8 88 fc ff ff       	call   9a9 <gettoken>
    cmd = pipecmd(cmd, parsepipe(ps, es));
     d21:	8b 45 0c             	mov    0xc(%ebp),%eax
     d24:	89 44 24 04          	mov    %eax,0x4(%esp)
     d28:	8b 45 08             	mov    0x8(%ebp),%eax
     d2b:	89 04 24             	mov    %eax,(%esp)
     d2e:	e8 93 ff ff ff       	call   cc6 <parsepipe>
     d33:	89 44 24 04          	mov    %eax,0x4(%esp)
     d37:	8b 45 f4             	mov    -0xc(%ebp),%eax
     d3a:	89 04 24             	mov    %eax,(%esp)
     d3d:	e8 80 fb ff ff       	call   8c2 <pipecmd>
     d42:	89 45 f4             	mov    %eax,-0xc(%ebp)
  }
  return cmd;
     d45:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     d48:	c9                   	leave  
     d49:	c3                   	ret    

00000d4a <parseredirs>:

struct cmd*
parseredirs(struct cmd *cmd, char **ps, char *es)
{
     d4a:	55                   	push   %ebp
     d4b:	89 e5                	mov    %esp,%ebp
     d4d:	83 ec 38             	sub    $0x38,%esp
  int tok;
  char *q, *eq;

  while(peek(ps, es, "<>")){
     d50:	e9 f6 00 00 00       	jmp    e4b <parseredirs+0x101>
    tok = gettoken(ps, es, 0, 0);
     d55:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
     d5c:	00 
     d5d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
     d64:	00 
     d65:	8b 45 10             	mov    0x10(%ebp),%eax
     d68:	89 44 24 04          	mov    %eax,0x4(%esp)
     d6c:	8b 45 0c             	mov    0xc(%ebp),%eax
     d6f:	89 04 24             	mov    %eax,(%esp)
     d72:	e8 32 fc ff ff       	call   9a9 <gettoken>
     d77:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(gettoken(ps, es, &q, &eq) != 'a')
     d7a:	8d 45 ec             	lea    -0x14(%ebp),%eax
     d7d:	89 44 24 0c          	mov    %eax,0xc(%esp)
     d81:	8d 45 f0             	lea    -0x10(%ebp),%eax
     d84:	89 44 24 08          	mov    %eax,0x8(%esp)
     d88:	8b 45 10             	mov    0x10(%ebp),%eax
     d8b:	89 44 24 04          	mov    %eax,0x4(%esp)
     d8f:	8b 45 0c             	mov    0xc(%ebp),%eax
     d92:	89 04 24             	mov    %eax,(%esp)
     d95:	e8 0f fc ff ff       	call   9a9 <gettoken>
     d9a:	83 f8 61             	cmp    $0x61,%eax
     d9d:	74 0c                	je     dab <parseredirs+0x61>
      panic("missing file for redirection");
     d9f:	c7 04 24 13 1a 00 00 	movl   $0x1a13,(%esp)
     da6:	e8 1c fa ff ff       	call   7c7 <panic>
    switch(tok){
     dab:	8b 45 f4             	mov    -0xc(%ebp),%eax
     dae:	83 f8 3c             	cmp    $0x3c,%eax
     db1:	74 0f                	je     dc2 <parseredirs+0x78>
     db3:	83 f8 3e             	cmp    $0x3e,%eax
     db6:	74 38                	je     df0 <parseredirs+0xa6>
     db8:	83 f8 2b             	cmp    $0x2b,%eax
     dbb:	74 61                	je     e1e <parseredirs+0xd4>
     dbd:	e9 89 00 00 00       	jmp    e4b <parseredirs+0x101>
    case '<':
      cmd = redircmd(cmd, q, eq, O_RDONLY, 0);
     dc2:	8b 55 ec             	mov    -0x14(%ebp),%edx
     dc5:	8b 45 f0             	mov    -0x10(%ebp),%eax
     dc8:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
     dcf:	00 
     dd0:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
     dd7:	00 
     dd8:	89 54 24 08          	mov    %edx,0x8(%esp)
     ddc:	89 44 24 04          	mov    %eax,0x4(%esp)
     de0:	8b 45 08             	mov    0x8(%ebp),%eax
     de3:	89 04 24             	mov    %eax,(%esp)
     de6:	e8 6c fa ff ff       	call   857 <redircmd>
     deb:	89 45 08             	mov    %eax,0x8(%ebp)
      break;
     dee:	eb 5b                	jmp    e4b <parseredirs+0x101>
    case '>':
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE, 1);
     df0:	8b 55 ec             	mov    -0x14(%ebp),%edx
     df3:	8b 45 f0             	mov    -0x10(%ebp),%eax
     df6:	c7 44 24 10 01 00 00 	movl   $0x1,0x10(%esp)
     dfd:	00 
     dfe:	c7 44 24 0c 01 02 00 	movl   $0x201,0xc(%esp)
     e05:	00 
     e06:	89 54 24 08          	mov    %edx,0x8(%esp)
     e0a:	89 44 24 04          	mov    %eax,0x4(%esp)
     e0e:	8b 45 08             	mov    0x8(%ebp),%eax
     e11:	89 04 24             	mov    %eax,(%esp)
     e14:	e8 3e fa ff ff       	call   857 <redircmd>
     e19:	89 45 08             	mov    %eax,0x8(%ebp)
      break;
     e1c:	eb 2d                	jmp    e4b <parseredirs+0x101>
    case '+':  // >>
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE, 1);
     e1e:	8b 55 ec             	mov    -0x14(%ebp),%edx
     e21:	8b 45 f0             	mov    -0x10(%ebp),%eax
     e24:	c7 44 24 10 01 00 00 	movl   $0x1,0x10(%esp)
     e2b:	00 
     e2c:	c7 44 24 0c 01 02 00 	movl   $0x201,0xc(%esp)
     e33:	00 
     e34:	89 54 24 08          	mov    %edx,0x8(%esp)
     e38:	89 44 24 04          	mov    %eax,0x4(%esp)
     e3c:	8b 45 08             	mov    0x8(%ebp),%eax
     e3f:	89 04 24             	mov    %eax,(%esp)
     e42:	e8 10 fa ff ff       	call   857 <redircmd>
     e47:	89 45 08             	mov    %eax,0x8(%ebp)
      break;
     e4a:	90                   	nop
parseredirs(struct cmd *cmd, char **ps, char *es)
{
  int tok;
  char *q, *eq;

  while(peek(ps, es, "<>")){
     e4b:	c7 44 24 08 30 1a 00 	movl   $0x1a30,0x8(%esp)
     e52:	00 
     e53:	8b 45 10             	mov    0x10(%ebp),%eax
     e56:	89 44 24 04          	mov    %eax,0x4(%esp)
     e5a:	8b 45 0c             	mov    0xc(%ebp),%eax
     e5d:	89 04 24             	mov    %eax,(%esp)
     e60:	e8 8c fc ff ff       	call   af1 <peek>
     e65:	85 c0                	test   %eax,%eax
     e67:	0f 85 e8 fe ff ff    	jne    d55 <parseredirs+0xb>
    case '+':  // >>
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE, 1);
      break;
    }
  }
  return cmd;
     e6d:	8b 45 08             	mov    0x8(%ebp),%eax
}
     e70:	c9                   	leave  
     e71:	c3                   	ret    

00000e72 <parseblock>:

struct cmd*
parseblock(char **ps, char *es)
{
     e72:	55                   	push   %ebp
     e73:	89 e5                	mov    %esp,%ebp
     e75:	83 ec 28             	sub    $0x28,%esp
  struct cmd *cmd;

  if(!peek(ps, es, "("))
     e78:	c7 44 24 08 33 1a 00 	movl   $0x1a33,0x8(%esp)
     e7f:	00 
     e80:	8b 45 0c             	mov    0xc(%ebp),%eax
     e83:	89 44 24 04          	mov    %eax,0x4(%esp)
     e87:	8b 45 08             	mov    0x8(%ebp),%eax
     e8a:	89 04 24             	mov    %eax,(%esp)
     e8d:	e8 5f fc ff ff       	call   af1 <peek>
     e92:	85 c0                	test   %eax,%eax
     e94:	75 0c                	jne    ea2 <parseblock+0x30>
    panic("parseblock");
     e96:	c7 04 24 35 1a 00 00 	movl   $0x1a35,(%esp)
     e9d:	e8 25 f9 ff ff       	call   7c7 <panic>
  gettoken(ps, es, 0, 0);
     ea2:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
     ea9:	00 
     eaa:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
     eb1:	00 
     eb2:	8b 45 0c             	mov    0xc(%ebp),%eax
     eb5:	89 44 24 04          	mov    %eax,0x4(%esp)
     eb9:	8b 45 08             	mov    0x8(%ebp),%eax
     ebc:	89 04 24             	mov    %eax,(%esp)
     ebf:	e8 e5 fa ff ff       	call   9a9 <gettoken>
  cmd = parseline(ps, es);
     ec4:	8b 45 0c             	mov    0xc(%ebp),%eax
     ec7:	89 44 24 04          	mov    %eax,0x4(%esp)
     ecb:	8b 45 08             	mov    0x8(%ebp),%eax
     ece:	89 04 24             	mov    %eax,(%esp)
     ed1:	e8 1c fd ff ff       	call   bf2 <parseline>
     ed6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(!peek(ps, es, ")"))
     ed9:	c7 44 24 08 40 1a 00 	movl   $0x1a40,0x8(%esp)
     ee0:	00 
     ee1:	8b 45 0c             	mov    0xc(%ebp),%eax
     ee4:	89 44 24 04          	mov    %eax,0x4(%esp)
     ee8:	8b 45 08             	mov    0x8(%ebp),%eax
     eeb:	89 04 24             	mov    %eax,(%esp)
     eee:	e8 fe fb ff ff       	call   af1 <peek>
     ef3:	85 c0                	test   %eax,%eax
     ef5:	75 0c                	jne    f03 <parseblock+0x91>
    panic("syntax - missing )");
     ef7:	c7 04 24 42 1a 00 00 	movl   $0x1a42,(%esp)
     efe:	e8 c4 f8 ff ff       	call   7c7 <panic>
  gettoken(ps, es, 0, 0);
     f03:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
     f0a:	00 
     f0b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
     f12:	00 
     f13:	8b 45 0c             	mov    0xc(%ebp),%eax
     f16:	89 44 24 04          	mov    %eax,0x4(%esp)
     f1a:	8b 45 08             	mov    0x8(%ebp),%eax
     f1d:	89 04 24             	mov    %eax,(%esp)
     f20:	e8 84 fa ff ff       	call   9a9 <gettoken>
  cmd = parseredirs(cmd, ps, es);
     f25:	8b 45 0c             	mov    0xc(%ebp),%eax
     f28:	89 44 24 08          	mov    %eax,0x8(%esp)
     f2c:	8b 45 08             	mov    0x8(%ebp),%eax
     f2f:	89 44 24 04          	mov    %eax,0x4(%esp)
     f33:	8b 45 f4             	mov    -0xc(%ebp),%eax
     f36:	89 04 24             	mov    %eax,(%esp)
     f39:	e8 0c fe ff ff       	call   d4a <parseredirs>
     f3e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  return cmd;
     f41:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     f44:	c9                   	leave  
     f45:	c3                   	ret    

00000f46 <parseexec>:

struct cmd*
parseexec(char **ps, char *es)
{
     f46:	55                   	push   %ebp
     f47:	89 e5                	mov    %esp,%ebp
     f49:	83 ec 38             	sub    $0x38,%esp
  char *q, *eq;
  int tok, argc;
  struct execcmd *cmd;
  struct cmd *ret;
  
  if(peek(ps, es, "("))
     f4c:	c7 44 24 08 33 1a 00 	movl   $0x1a33,0x8(%esp)
     f53:	00 
     f54:	8b 45 0c             	mov    0xc(%ebp),%eax
     f57:	89 44 24 04          	mov    %eax,0x4(%esp)
     f5b:	8b 45 08             	mov    0x8(%ebp),%eax
     f5e:	89 04 24             	mov    %eax,(%esp)
     f61:	e8 8b fb ff ff       	call   af1 <peek>
     f66:	85 c0                	test   %eax,%eax
     f68:	74 17                	je     f81 <parseexec+0x3b>
    return parseblock(ps, es);
     f6a:	8b 45 0c             	mov    0xc(%ebp),%eax
     f6d:	89 44 24 04          	mov    %eax,0x4(%esp)
     f71:	8b 45 08             	mov    0x8(%ebp),%eax
     f74:	89 04 24             	mov    %eax,(%esp)
     f77:	e8 f6 fe ff ff       	call   e72 <parseblock>
     f7c:	e9 0b 01 00 00       	jmp    108c <parseexec+0x146>

  ret = execcmd();
     f81:	e8 93 f8 ff ff       	call   819 <execcmd>
     f86:	89 45 f0             	mov    %eax,-0x10(%ebp)
  cmd = (struct execcmd*)ret;
     f89:	8b 45 f0             	mov    -0x10(%ebp),%eax
     f8c:	89 45 ec             	mov    %eax,-0x14(%ebp)

  argc = 0;
     f8f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  ret = parseredirs(ret, ps, es);
     f96:	8b 45 0c             	mov    0xc(%ebp),%eax
     f99:	89 44 24 08          	mov    %eax,0x8(%esp)
     f9d:	8b 45 08             	mov    0x8(%ebp),%eax
     fa0:	89 44 24 04          	mov    %eax,0x4(%esp)
     fa4:	8b 45 f0             	mov    -0x10(%ebp),%eax
     fa7:	89 04 24             	mov    %eax,(%esp)
     faa:	e8 9b fd ff ff       	call   d4a <parseredirs>
     faf:	89 45 f0             	mov    %eax,-0x10(%ebp)
  while(!peek(ps, es, "|)&;")){
     fb2:	e9 8e 00 00 00       	jmp    1045 <parseexec+0xff>
    if((tok=gettoken(ps, es, &q, &eq)) == 0)
     fb7:	8d 45 e0             	lea    -0x20(%ebp),%eax
     fba:	89 44 24 0c          	mov    %eax,0xc(%esp)
     fbe:	8d 45 e4             	lea    -0x1c(%ebp),%eax
     fc1:	89 44 24 08          	mov    %eax,0x8(%esp)
     fc5:	8b 45 0c             	mov    0xc(%ebp),%eax
     fc8:	89 44 24 04          	mov    %eax,0x4(%esp)
     fcc:	8b 45 08             	mov    0x8(%ebp),%eax
     fcf:	89 04 24             	mov    %eax,(%esp)
     fd2:	e8 d2 f9 ff ff       	call   9a9 <gettoken>
     fd7:	89 45 e8             	mov    %eax,-0x18(%ebp)
     fda:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
     fde:	0f 84 85 00 00 00    	je     1069 <parseexec+0x123>
      break;
    if(tok != 'a')
     fe4:	83 7d e8 61          	cmpl   $0x61,-0x18(%ebp)
     fe8:	74 0c                	je     ff6 <parseexec+0xb0>
      panic("syntax");
     fea:	c7 04 24 06 1a 00 00 	movl   $0x1a06,(%esp)
     ff1:	e8 d1 f7 ff ff       	call   7c7 <panic>
    cmd->argv[argc] = q;
     ff6:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
     ff9:	8b 45 ec             	mov    -0x14(%ebp),%eax
     ffc:	8b 55 f4             	mov    -0xc(%ebp),%edx
     fff:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
    cmd->eargv[argc] = eq;
    1003:	8b 55 e0             	mov    -0x20(%ebp),%edx
    1006:	8b 45 ec             	mov    -0x14(%ebp),%eax
    1009:	8b 4d f4             	mov    -0xc(%ebp),%ecx
    100c:	83 c1 08             	add    $0x8,%ecx
    100f:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    argc++;
    1013:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(argc >= MAXARGS)
    1017:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
    101b:	7e 0c                	jle    1029 <parseexec+0xe3>
      panic("too many args");
    101d:	c7 04 24 55 1a 00 00 	movl   $0x1a55,(%esp)
    1024:	e8 9e f7 ff ff       	call   7c7 <panic>
    ret = parseredirs(ret, ps, es);
    1029:	8b 45 0c             	mov    0xc(%ebp),%eax
    102c:	89 44 24 08          	mov    %eax,0x8(%esp)
    1030:	8b 45 08             	mov    0x8(%ebp),%eax
    1033:	89 44 24 04          	mov    %eax,0x4(%esp)
    1037:	8b 45 f0             	mov    -0x10(%ebp),%eax
    103a:	89 04 24             	mov    %eax,(%esp)
    103d:	e8 08 fd ff ff       	call   d4a <parseredirs>
    1042:	89 45 f0             	mov    %eax,-0x10(%ebp)
  ret = execcmd();
  cmd = (struct execcmd*)ret;

  argc = 0;
  ret = parseredirs(ret, ps, es);
  while(!peek(ps, es, "|)&;")){
    1045:	c7 44 24 08 63 1a 00 	movl   $0x1a63,0x8(%esp)
    104c:	00 
    104d:	8b 45 0c             	mov    0xc(%ebp),%eax
    1050:	89 44 24 04          	mov    %eax,0x4(%esp)
    1054:	8b 45 08             	mov    0x8(%ebp),%eax
    1057:	89 04 24             	mov    %eax,(%esp)
    105a:	e8 92 fa ff ff       	call   af1 <peek>
    105f:	85 c0                	test   %eax,%eax
    1061:	0f 84 50 ff ff ff    	je     fb7 <parseexec+0x71>
    1067:	eb 01                	jmp    106a <parseexec+0x124>
    if((tok=gettoken(ps, es, &q, &eq)) == 0)
      break;
    1069:	90                   	nop
    argc++;
    if(argc >= MAXARGS)
      panic("too many args");
    ret = parseredirs(ret, ps, es);
  }
  cmd->argv[argc] = 0;
    106a:	8b 45 ec             	mov    -0x14(%ebp),%eax
    106d:	8b 55 f4             	mov    -0xc(%ebp),%edx
    1070:	c7 44 90 04 00 00 00 	movl   $0x0,0x4(%eax,%edx,4)
    1077:	00 
  cmd->eargv[argc] = 0;
    1078:	8b 45 ec             	mov    -0x14(%ebp),%eax
    107b:	8b 55 f4             	mov    -0xc(%ebp),%edx
    107e:	83 c2 08             	add    $0x8,%edx
    1081:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
    1088:	00 
  return ret;
    1089:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
    108c:	c9                   	leave  
    108d:	c3                   	ret    

0000108e <nulterminate>:

// NUL-terminate all the counted strings.
struct cmd*
nulterminate(struct cmd *cmd)
{
    108e:	55                   	push   %ebp
    108f:	89 e5                	mov    %esp,%ebp
    1091:	83 ec 38             	sub    $0x38,%esp
  struct execcmd *ecmd;
  struct listcmd *lcmd;
  struct pipecmd *pcmd;
  struct redircmd *rcmd;

  if(cmd == 0)
    1094:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
    1098:	75 0a                	jne    10a4 <nulterminate+0x16>
    return 0;
    109a:	b8 00 00 00 00       	mov    $0x0,%eax
    109f:	e9 c9 00 00 00       	jmp    116d <nulterminate+0xdf>
  
  switch(cmd->type){
    10a4:	8b 45 08             	mov    0x8(%ebp),%eax
    10a7:	8b 00                	mov    (%eax),%eax
    10a9:	83 f8 05             	cmp    $0x5,%eax
    10ac:	0f 87 b8 00 00 00    	ja     116a <nulterminate+0xdc>
    10b2:	8b 04 85 68 1a 00 00 	mov    0x1a68(,%eax,4),%eax
    10b9:	ff e0                	jmp    *%eax
  case EXEC:
    ecmd = (struct execcmd*)cmd;
    10bb:	8b 45 08             	mov    0x8(%ebp),%eax
    10be:	89 45 f0             	mov    %eax,-0x10(%ebp)
    for(i=0; ecmd->argv[i]; i++)
    10c1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    10c8:	eb 14                	jmp    10de <nulterminate+0x50>
      *ecmd->eargv[i] = 0;
    10ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
    10cd:	8b 55 f4             	mov    -0xc(%ebp),%edx
    10d0:	83 c2 08             	add    $0x8,%edx
    10d3:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
    10d7:	c6 00 00             	movb   $0x0,(%eax)
    return 0;
  
  switch(cmd->type){
  case EXEC:
    ecmd = (struct execcmd*)cmd;
    for(i=0; ecmd->argv[i]; i++)
    10da:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    10de:	8b 45 f0             	mov    -0x10(%ebp),%eax
    10e1:	8b 55 f4             	mov    -0xc(%ebp),%edx
    10e4:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
    10e8:	85 c0                	test   %eax,%eax
    10ea:	75 de                	jne    10ca <nulterminate+0x3c>
      *ecmd->eargv[i] = 0;
    break;
    10ec:	eb 7c                	jmp    116a <nulterminate+0xdc>

  case REDIR:
    rcmd = (struct redircmd*)cmd;
    10ee:	8b 45 08             	mov    0x8(%ebp),%eax
    10f1:	89 45 ec             	mov    %eax,-0x14(%ebp)
    nulterminate(rcmd->cmd);
    10f4:	8b 45 ec             	mov    -0x14(%ebp),%eax
    10f7:	8b 40 04             	mov    0x4(%eax),%eax
    10fa:	89 04 24             	mov    %eax,(%esp)
    10fd:	e8 8c ff ff ff       	call   108e <nulterminate>
    *rcmd->efile = 0;
    1102:	8b 45 ec             	mov    -0x14(%ebp),%eax
    1105:	8b 40 0c             	mov    0xc(%eax),%eax
    1108:	c6 00 00             	movb   $0x0,(%eax)
    break;
    110b:	eb 5d                	jmp    116a <nulterminate+0xdc>

  case PIPE:
    pcmd = (struct pipecmd*)cmd;
    110d:	8b 45 08             	mov    0x8(%ebp),%eax
    1110:	89 45 e8             	mov    %eax,-0x18(%ebp)
    nulterminate(pcmd->left);
    1113:	8b 45 e8             	mov    -0x18(%ebp),%eax
    1116:	8b 40 04             	mov    0x4(%eax),%eax
    1119:	89 04 24             	mov    %eax,(%esp)
    111c:	e8 6d ff ff ff       	call   108e <nulterminate>
    nulterminate(pcmd->right);
    1121:	8b 45 e8             	mov    -0x18(%ebp),%eax
    1124:	8b 40 08             	mov    0x8(%eax),%eax
    1127:	89 04 24             	mov    %eax,(%esp)
    112a:	e8 5f ff ff ff       	call   108e <nulterminate>
    break;
    112f:	eb 39                	jmp    116a <nulterminate+0xdc>
    
  case LIST:
    lcmd = (struct listcmd*)cmd;
    1131:	8b 45 08             	mov    0x8(%ebp),%eax
    1134:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    nulterminate(lcmd->left);
    1137:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    113a:	8b 40 04             	mov    0x4(%eax),%eax
    113d:	89 04 24             	mov    %eax,(%esp)
    1140:	e8 49 ff ff ff       	call   108e <nulterminate>
    nulterminate(lcmd->right);
    1145:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    1148:	8b 40 08             	mov    0x8(%eax),%eax
    114b:	89 04 24             	mov    %eax,(%esp)
    114e:	e8 3b ff ff ff       	call   108e <nulterminate>
    break;
    1153:	eb 15                	jmp    116a <nulterminate+0xdc>

  case BACK:
    bcmd = (struct backcmd*)cmd;
    1155:	8b 45 08             	mov    0x8(%ebp),%eax
    1158:	89 45 e0             	mov    %eax,-0x20(%ebp)
    nulterminate(bcmd->cmd);
    115b:	8b 45 e0             	mov    -0x20(%ebp),%eax
    115e:	8b 40 04             	mov    0x4(%eax),%eax
    1161:	89 04 24             	mov    %eax,(%esp)
    1164:	e8 25 ff ff ff       	call   108e <nulterminate>
    break;
    1169:	90                   	nop
  }
  return cmd;
    116a:	8b 45 08             	mov    0x8(%ebp),%eax
}
    116d:	c9                   	leave  
    116e:	c3                   	ret    
    116f:	90                   	nop

00001170 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
    1170:	55                   	push   %ebp
    1171:	89 e5                	mov    %esp,%ebp
    1173:	57                   	push   %edi
    1174:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
    1175:	8b 4d 08             	mov    0x8(%ebp),%ecx
    1178:	8b 55 10             	mov    0x10(%ebp),%edx
    117b:	8b 45 0c             	mov    0xc(%ebp),%eax
    117e:	89 cb                	mov    %ecx,%ebx
    1180:	89 df                	mov    %ebx,%edi
    1182:	89 d1                	mov    %edx,%ecx
    1184:	fc                   	cld    
    1185:	f3 aa                	rep stos %al,%es:(%edi)
    1187:	89 ca                	mov    %ecx,%edx
    1189:	89 fb                	mov    %edi,%ebx
    118b:	89 5d 08             	mov    %ebx,0x8(%ebp)
    118e:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
    1191:	5b                   	pop    %ebx
    1192:	5f                   	pop    %edi
    1193:	5d                   	pop    %ebp
    1194:	c3                   	ret    

00001195 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
    1195:	55                   	push   %ebp
    1196:	89 e5                	mov    %esp,%ebp
    1198:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
    119b:	8b 45 08             	mov    0x8(%ebp),%eax
    119e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
    11a1:	90                   	nop
    11a2:	8b 45 0c             	mov    0xc(%ebp),%eax
    11a5:	0f b6 10             	movzbl (%eax),%edx
    11a8:	8b 45 08             	mov    0x8(%ebp),%eax
    11ab:	88 10                	mov    %dl,(%eax)
    11ad:	8b 45 08             	mov    0x8(%ebp),%eax
    11b0:	0f b6 00             	movzbl (%eax),%eax
    11b3:	84 c0                	test   %al,%al
    11b5:	0f 95 c0             	setne  %al
    11b8:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    11bc:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
    11c0:	84 c0                	test   %al,%al
    11c2:	75 de                	jne    11a2 <strcpy+0xd>
    ;
  return os;
    11c4:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
    11c7:	c9                   	leave  
    11c8:	c3                   	ret    

000011c9 <strcmp>:

int
strcmp(const char *p, const char *q)
{
    11c9:	55                   	push   %ebp
    11ca:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
    11cc:	eb 08                	jmp    11d6 <strcmp+0xd>
    p++, q++;
    11ce:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    11d2:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
    11d6:	8b 45 08             	mov    0x8(%ebp),%eax
    11d9:	0f b6 00             	movzbl (%eax),%eax
    11dc:	84 c0                	test   %al,%al
    11de:	74 10                	je     11f0 <strcmp+0x27>
    11e0:	8b 45 08             	mov    0x8(%ebp),%eax
    11e3:	0f b6 10             	movzbl (%eax),%edx
    11e6:	8b 45 0c             	mov    0xc(%ebp),%eax
    11e9:	0f b6 00             	movzbl (%eax),%eax
    11ec:	38 c2                	cmp    %al,%dl
    11ee:	74 de                	je     11ce <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
    11f0:	8b 45 08             	mov    0x8(%ebp),%eax
    11f3:	0f b6 00             	movzbl (%eax),%eax
    11f6:	0f b6 d0             	movzbl %al,%edx
    11f9:	8b 45 0c             	mov    0xc(%ebp),%eax
    11fc:	0f b6 00             	movzbl (%eax),%eax
    11ff:	0f b6 c0             	movzbl %al,%eax
    1202:	89 d1                	mov    %edx,%ecx
    1204:	29 c1                	sub    %eax,%ecx
    1206:	89 c8                	mov    %ecx,%eax
}
    1208:	5d                   	pop    %ebp
    1209:	c3                   	ret    

0000120a <strlen>:

uint
strlen(char *s)
{
    120a:	55                   	push   %ebp
    120b:	89 e5                	mov    %esp,%ebp
    120d:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
    1210:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    1217:	eb 04                	jmp    121d <strlen+0x13>
    1219:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
    121d:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1220:	03 45 08             	add    0x8(%ebp),%eax
    1223:	0f b6 00             	movzbl (%eax),%eax
    1226:	84 c0                	test   %al,%al
    1228:	75 ef                	jne    1219 <strlen+0xf>
    ;
  return n;
    122a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
    122d:	c9                   	leave  
    122e:	c3                   	ret    

0000122f <memset>:

void*
memset(void *dst, int c, uint n)
{
    122f:	55                   	push   %ebp
    1230:	89 e5                	mov    %esp,%ebp
    1232:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
    1235:	8b 45 10             	mov    0x10(%ebp),%eax
    1238:	89 44 24 08          	mov    %eax,0x8(%esp)
    123c:	8b 45 0c             	mov    0xc(%ebp),%eax
    123f:	89 44 24 04          	mov    %eax,0x4(%esp)
    1243:	8b 45 08             	mov    0x8(%ebp),%eax
    1246:	89 04 24             	mov    %eax,(%esp)
    1249:	e8 22 ff ff ff       	call   1170 <stosb>
  return dst;
    124e:	8b 45 08             	mov    0x8(%ebp),%eax
}
    1251:	c9                   	leave  
    1252:	c3                   	ret    

00001253 <strchr>:

char*
strchr(const char *s, char c)
{
    1253:	55                   	push   %ebp
    1254:	89 e5                	mov    %esp,%ebp
    1256:	83 ec 04             	sub    $0x4,%esp
    1259:	8b 45 0c             	mov    0xc(%ebp),%eax
    125c:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
    125f:	eb 14                	jmp    1275 <strchr+0x22>
    if(*s == c)
    1261:	8b 45 08             	mov    0x8(%ebp),%eax
    1264:	0f b6 00             	movzbl (%eax),%eax
    1267:	3a 45 fc             	cmp    -0x4(%ebp),%al
    126a:	75 05                	jne    1271 <strchr+0x1e>
      return (char*)s;
    126c:	8b 45 08             	mov    0x8(%ebp),%eax
    126f:	eb 13                	jmp    1284 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
    1271:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    1275:	8b 45 08             	mov    0x8(%ebp),%eax
    1278:	0f b6 00             	movzbl (%eax),%eax
    127b:	84 c0                	test   %al,%al
    127d:	75 e2                	jne    1261 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
    127f:	b8 00 00 00 00       	mov    $0x0,%eax
}
    1284:	c9                   	leave  
    1285:	c3                   	ret    

00001286 <gets>:

char*
gets(char *buf, int max)
{
    1286:	55                   	push   %ebp
    1287:	89 e5                	mov    %esp,%ebp
    1289:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    128c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    1293:	eb 44                	jmp    12d9 <gets+0x53>
    cc = read(0, &c, 1);
    1295:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
    129c:	00 
    129d:	8d 45 ef             	lea    -0x11(%ebp),%eax
    12a0:	89 44 24 04          	mov    %eax,0x4(%esp)
    12a4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    12ab:	e8 3c 01 00 00       	call   13ec <read>
    12b0:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
    12b3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    12b7:	7e 2d                	jle    12e6 <gets+0x60>
      break;
    buf[i++] = c;
    12b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
    12bc:	03 45 08             	add    0x8(%ebp),%eax
    12bf:	0f b6 55 ef          	movzbl -0x11(%ebp),%edx
    12c3:	88 10                	mov    %dl,(%eax)
    12c5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(c == '\n' || c == '\r')
    12c9:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    12cd:	3c 0a                	cmp    $0xa,%al
    12cf:	74 16                	je     12e7 <gets+0x61>
    12d1:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    12d5:	3c 0d                	cmp    $0xd,%al
    12d7:	74 0e                	je     12e7 <gets+0x61>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    12d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
    12dc:	83 c0 01             	add    $0x1,%eax
    12df:	3b 45 0c             	cmp    0xc(%ebp),%eax
    12e2:	7c b1                	jl     1295 <gets+0xf>
    12e4:	eb 01                	jmp    12e7 <gets+0x61>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    12e6:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
    12e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
    12ea:	03 45 08             	add    0x8(%ebp),%eax
    12ed:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
    12f0:	8b 45 08             	mov    0x8(%ebp),%eax
}
    12f3:	c9                   	leave  
    12f4:	c3                   	ret    

000012f5 <stat>:

int
stat(char *n, struct stat *st)
{
    12f5:	55                   	push   %ebp
    12f6:	89 e5                	mov    %esp,%ebp
    12f8:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
    12fb:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    1302:	00 
    1303:	8b 45 08             	mov    0x8(%ebp),%eax
    1306:	89 04 24             	mov    %eax,(%esp)
    1309:	e8 06 01 00 00       	call   1414 <open>
    130e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
    1311:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    1315:	79 07                	jns    131e <stat+0x29>
    return -1;
    1317:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    131c:	eb 23                	jmp    1341 <stat+0x4c>
  r = fstat(fd, st);
    131e:	8b 45 0c             	mov    0xc(%ebp),%eax
    1321:	89 44 24 04          	mov    %eax,0x4(%esp)
    1325:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1328:	89 04 24             	mov    %eax,(%esp)
    132b:	e8 fc 00 00 00       	call   142c <fstat>
    1330:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
    1333:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1336:	89 04 24             	mov    %eax,(%esp)
    1339:	e8 be 00 00 00       	call   13fc <close>
  return r;
    133e:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
    1341:	c9                   	leave  
    1342:	c3                   	ret    

00001343 <atoi>:

int
atoi(const char *s)
{
    1343:	55                   	push   %ebp
    1344:	89 e5                	mov    %esp,%ebp
    1346:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
    1349:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
    1350:	eb 23                	jmp    1375 <atoi+0x32>
    n = n*10 + *s++ - '0';
    1352:	8b 55 fc             	mov    -0x4(%ebp),%edx
    1355:	89 d0                	mov    %edx,%eax
    1357:	c1 e0 02             	shl    $0x2,%eax
    135a:	01 d0                	add    %edx,%eax
    135c:	01 c0                	add    %eax,%eax
    135e:	89 c2                	mov    %eax,%edx
    1360:	8b 45 08             	mov    0x8(%ebp),%eax
    1363:	0f b6 00             	movzbl (%eax),%eax
    1366:	0f be c0             	movsbl %al,%eax
    1369:	01 d0                	add    %edx,%eax
    136b:	83 e8 30             	sub    $0x30,%eax
    136e:	89 45 fc             	mov    %eax,-0x4(%ebp)
    1371:	83 45 08 01          	addl   $0x1,0x8(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
    1375:	8b 45 08             	mov    0x8(%ebp),%eax
    1378:	0f b6 00             	movzbl (%eax),%eax
    137b:	3c 2f                	cmp    $0x2f,%al
    137d:	7e 0a                	jle    1389 <atoi+0x46>
    137f:	8b 45 08             	mov    0x8(%ebp),%eax
    1382:	0f b6 00             	movzbl (%eax),%eax
    1385:	3c 39                	cmp    $0x39,%al
    1387:	7e c9                	jle    1352 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
    1389:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
    138c:	c9                   	leave  
    138d:	c3                   	ret    

0000138e <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
    138e:	55                   	push   %ebp
    138f:	89 e5                	mov    %esp,%ebp
    1391:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
    1394:	8b 45 08             	mov    0x8(%ebp),%eax
    1397:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
    139a:	8b 45 0c             	mov    0xc(%ebp),%eax
    139d:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
    13a0:	eb 13                	jmp    13b5 <memmove+0x27>
    *dst++ = *src++;
    13a2:	8b 45 f8             	mov    -0x8(%ebp),%eax
    13a5:	0f b6 10             	movzbl (%eax),%edx
    13a8:	8b 45 fc             	mov    -0x4(%ebp),%eax
    13ab:	88 10                	mov    %dl,(%eax)
    13ad:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
    13b1:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
    13b5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
    13b9:	0f 9f c0             	setg   %al
    13bc:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    13c0:	84 c0                	test   %al,%al
    13c2:	75 de                	jne    13a2 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
    13c4:	8b 45 08             	mov    0x8(%ebp),%eax
}
    13c7:	c9                   	leave  
    13c8:	c3                   	ret    
    13c9:	90                   	nop
    13ca:	90                   	nop
    13cb:	90                   	nop

000013cc <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
    13cc:	b8 01 00 00 00       	mov    $0x1,%eax
    13d1:	cd 40                	int    $0x40
    13d3:	c3                   	ret    

000013d4 <exit>:
SYSCALL(exit)
    13d4:	b8 02 00 00 00       	mov    $0x2,%eax
    13d9:	cd 40                	int    $0x40
    13db:	c3                   	ret    

000013dc <wait>:
SYSCALL(wait)
    13dc:	b8 03 00 00 00       	mov    $0x3,%eax
    13e1:	cd 40                	int    $0x40
    13e3:	c3                   	ret    

000013e4 <pipe>:
SYSCALL(pipe)
    13e4:	b8 04 00 00 00       	mov    $0x4,%eax
    13e9:	cd 40                	int    $0x40
    13eb:	c3                   	ret    

000013ec <read>:
SYSCALL(read)
    13ec:	b8 05 00 00 00       	mov    $0x5,%eax
    13f1:	cd 40                	int    $0x40
    13f3:	c3                   	ret    

000013f4 <write>:
SYSCALL(write)
    13f4:	b8 10 00 00 00       	mov    $0x10,%eax
    13f9:	cd 40                	int    $0x40
    13fb:	c3                   	ret    

000013fc <close>:
SYSCALL(close)
    13fc:	b8 15 00 00 00       	mov    $0x15,%eax
    1401:	cd 40                	int    $0x40
    1403:	c3                   	ret    

00001404 <kill>:
SYSCALL(kill)
    1404:	b8 06 00 00 00       	mov    $0x6,%eax
    1409:	cd 40                	int    $0x40
    140b:	c3                   	ret    

0000140c <exec>:
SYSCALL(exec)
    140c:	b8 07 00 00 00       	mov    $0x7,%eax
    1411:	cd 40                	int    $0x40
    1413:	c3                   	ret    

00001414 <open>:
SYSCALL(open)
    1414:	b8 0f 00 00 00       	mov    $0xf,%eax
    1419:	cd 40                	int    $0x40
    141b:	c3                   	ret    

0000141c <mknod>:
SYSCALL(mknod)
    141c:	b8 11 00 00 00       	mov    $0x11,%eax
    1421:	cd 40                	int    $0x40
    1423:	c3                   	ret    

00001424 <unlink>:
SYSCALL(unlink)
    1424:	b8 12 00 00 00       	mov    $0x12,%eax
    1429:	cd 40                	int    $0x40
    142b:	c3                   	ret    

0000142c <fstat>:
SYSCALL(fstat)
    142c:	b8 08 00 00 00       	mov    $0x8,%eax
    1431:	cd 40                	int    $0x40
    1433:	c3                   	ret    

00001434 <link>:
SYSCALL(link)
    1434:	b8 13 00 00 00       	mov    $0x13,%eax
    1439:	cd 40                	int    $0x40
    143b:	c3                   	ret    

0000143c <mkdir>:
SYSCALL(mkdir)
    143c:	b8 14 00 00 00       	mov    $0x14,%eax
    1441:	cd 40                	int    $0x40
    1443:	c3                   	ret    

00001444 <chdir>:
SYSCALL(chdir)
    1444:	b8 09 00 00 00       	mov    $0x9,%eax
    1449:	cd 40                	int    $0x40
    144b:	c3                   	ret    

0000144c <dup>:
SYSCALL(dup)
    144c:	b8 0a 00 00 00       	mov    $0xa,%eax
    1451:	cd 40                	int    $0x40
    1453:	c3                   	ret    

00001454 <getpid>:
SYSCALL(getpid)
    1454:	b8 0b 00 00 00       	mov    $0xb,%eax
    1459:	cd 40                	int    $0x40
    145b:	c3                   	ret    

0000145c <sbrk>:
SYSCALL(sbrk)
    145c:	b8 0c 00 00 00       	mov    $0xc,%eax
    1461:	cd 40                	int    $0x40
    1463:	c3                   	ret    

00001464 <sleep>:
SYSCALL(sleep)
    1464:	b8 0d 00 00 00       	mov    $0xd,%eax
    1469:	cd 40                	int    $0x40
    146b:	c3                   	ret    

0000146c <uptime>:
SYSCALL(uptime)
    146c:	b8 0e 00 00 00       	mov    $0xe,%eax
    1471:	cd 40                	int    $0x40
    1473:	c3                   	ret    

00001474 <waitpid>:
SYSCALL(waitpid)
    1474:	b8 16 00 00 00       	mov    $0x16,%eax
    1479:	cd 40                	int    $0x40
    147b:	c3                   	ret    

0000147c <wait_stat>:
SYSCALL(wait_stat)
    147c:	b8 17 00 00 00       	mov    $0x17,%eax
    1481:	cd 40                	int    $0x40
    1483:	c3                   	ret    

00001484 <list_pgroup>:
SYSCALL(list_pgroup)
    1484:	b8 18 00 00 00       	mov    $0x18,%eax
    1489:	cd 40                	int    $0x40
    148b:	c3                   	ret    

0000148c <foreground>:
SYSCALL(foreground)
    148c:	b8 19 00 00 00       	mov    $0x19,%eax
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
    14b5:	e8 3a ff ff ff       	call   13f4 <write>
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
    1502:	0f b6 90 70 1f 00 00 	movzbl 0x1f70(%eax),%edx
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
    1663:	c7 45 f4 80 1a 00 00 	movl   $0x1a80,-0xc(%ebp)
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
    172f:	a1 2c e0 01 00       	mov    0x1e02c,%eax
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
    17f0:	a3 2c e0 01 00       	mov    %eax,0x1e02c
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
    1816:	e8 41 fc ff ff       	call   145c <sbrk>
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
    1848:	a1 2c e0 01 00       	mov    0x1e02c,%eax
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
    1864:	a1 2c e0 01 00       	mov    0x1e02c,%eax
    1869:	89 45 f0             	mov    %eax,-0x10(%ebp)
    186c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    1870:	75 23                	jne    1895 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
    1872:	c7 45 f0 24 e0 01 00 	movl   $0x1e024,-0x10(%ebp)
    1879:	8b 45 f0             	mov    -0x10(%ebp),%eax
    187c:	a3 2c e0 01 00       	mov    %eax,0x1e02c
    1881:	a1 2c e0 01 00       	mov    0x1e02c,%eax
    1886:	a3 24 e0 01 00       	mov    %eax,0x1e024
    base.s.size = 0;
    188b:	c7 05 28 e0 01 00 00 	movl   $0x0,0x1e028
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
    18e8:	a3 2c e0 01 00       	mov    %eax,0x1e02c
      return (void*)(p + 1);
    18ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
    18f0:	83 c0 08             	add    $0x8,%eax
    18f3:	eb 38                	jmp    192d <malloc+0xde>
    }
    if(p == freep)
    18f5:	a1 2c e0 01 00       	mov    0x1e02c,%eax
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
