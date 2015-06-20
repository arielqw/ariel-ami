#include "types.h"
#include "stat.h"
#include "defs.h"
#include "param.h"
#include "traps.h"
#include "spinlock.h"
#include "fs.h"
#include "file.h"
#include "memlayout.h"
#include "mmu.h"
#include "proc.h"
#include "x86.h"

#define PROC_FOLDER_INUM	18

#define PROCCFS_DIRECTORY 	0
#define PROCCFS_FILE 		1

#define PID_FROM_MINOR(a) (((a)) / 100)

enum procfs_pid_cmd { VFILE_PID_FOLDER, VFILE_CMDLINE, VFILE_CWD, VFILE_EXE, VFILE_FDINFO, VFILE_STATUS };


void printInode(struct inode *ip)
{
	cprintf("inum:%d\n", ip->inum);
}

/* reverse:  reverse string s in place */
void reverse(char s[])
{
    int i, j;
    char c;

    for (i = 0, j = strlen(s)-1; i<j; i++, j--) {
        c = s[i];
        s[i] = s[j];
        s[j] = c;
    }
}

/* itoa:  convert n to characters in s */
int itoa(int n, char s[])
{
    int i, sign;

    if ((sign = n) < 0)  /* record sign */
        n = -n;          /* make n positive */
    i = 0;
    do {       /* generate digits in reverse order */
        s[i++] = n % 10 + '0';   /* get next digit */
    } while ((n /= 10) > 0);     /* delete it */
    if (sign < 0)
        s[i++] = '-';
    s[i] = '\0';
    reverse(s);
    return i+1;
}




int 
procfsisdir(struct inode *ip) {
	//cprintf("procfsisdir isdir:%d\n", ip->minor == PROCCFS_DIRECTORY);
	//todo: check if should bring from disk if not valid
	return (ip->minor % 10 == PROCCFS_DIRECTORY);
}

//fills dir at index
void addDirent(struct dirent* dir, uint index, char* name, uint inum)
{
	strncpy(dir[index].name, name, strlen(name)+1);
	dir[index].inum = inum;
}



void 
procfsiread(struct inode* dp, struct inode *ip) {
	//cprintf("procfsiread\n:");


	if (ip->inum > NINODE)	//some virtual folder/file i created
	{
		ip->major = PROCFS;
		ip->type = T_DEV;
		ip->flags |= I_VALID;
		if (	ip->inum == PROC_FOLDER_INUM 		|| 		//dp is 'proc' folder
				ip->inum % 100 == VFILE_PID_FOLDER	||		//dp is 'pid' folder
				ip->inum % 100 == VFILE_FDINFO			)	//dp is 'fdinfo' folder
		{
//			if (ip->inum % 100 == VFILE_STATUS)
//			{
//				ip->minor = PROCCFS_FILE;
//				ip->size = 4;
//				memmove((void*)ip->addrs[0], "kaki", 5);
//			}
//			else
//			{
				ip->minor = PROCCFS_DIRECTORY;
				ip->size = 512;
//			}
		}
		else								//children are files
		{
			ip->size = 512;
			ip->minor = PROCCFS_FILE;
		}
	}

}

struct {
  struct spinlock lock;
  struct proc proc[NPROC];
} ptable;


//returns num of entries
int buildProcFolder(struct dirent* dir)
{
	int numOfEntries = 2;

	addDirent(dir, 0, ".", 	PROC_FOLDER_INUM);
	addDirent(dir, 1, "..", ROOTINO);

	//add processes folders
	int i = 1;
	struct proc* p;
	acquire(&ptable.lock);
	for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
	{
		if(p->state != UNUSED)
		{
			char buff[64];
			itoa(p->pid, buff);
			addDirent(dir, i+1, buff, p->pid * 100);
			numOfEntries++;
			i++;
		}
	}
	release(&ptable.lock);
	return numOfEntries;
}

ushort getInodeInum(struct inode* ip)
{
	return ip->inum;
}

//fills dir - ip is 'PID' folder
int buildPidFolder(struct dirent* dir, struct inode *ip)
{
	int numOfEntries = 7;

	addDirent(dir, 0, ".", 	ip->inum);
	addDirent(dir, 1, "..", PROC_FOLDER_INUM);

	addDirent(dir, 2, "cmdline", 	ip->inum + VFILE_CMDLINE);
	struct proc* p = getProcById(ip->inum/100);
	addDirent(dir, 3, "cwd", 		p->cwd->inum);
	addDirent(dir, 4, "exe", 		p->executableInum);
	addDirent(dir, 5, "fdinfo", 	ip->inum + VFILE_FDINFO);
	addDirent(dir, 6, "status", 	ip->inum + VFILE_STATUS);

	return numOfEntries;
}

//fills dir - ip is 'fdinfo' folder
int buildFdinfoFolder(struct dirent* dir, struct inode *ip)
{
	addDirent(dir, 0, ".", 	ip->inum);
	addDirent(dir, 1, "..", PROC_FOLDER_INUM);

	int numOfEntries = 2;

	struct proc* p = getProcById(ip->inum/100);
	int fd;
	for(fd = 0; fd < NOFILE; fd++){
		if(p->ofile[fd]){
			//active fd
			char buff[4];
			itoa(fd, buff);
			addDirent(dir, numOfEntries++, buff, ip->inum - VFILE_FDINFO +10 + fd);
		}
	}
	return numOfEntries;
}

void appendStringToCharBuff(char* buff, int* index, char* string)
{
	int len = strlen(string);
	memmove(buff + *index, string, len);
	*index += len;
}

void appendIntToCharBuff(char* buff, int* index, int num)
{
	char itoa_buff[32];
	itoa(num, itoa_buff);
	appendStringToCharBuff(buff, index, itoa_buff);
}

int buildFdInfoFile(char* buff, int pid, int fd)
{
	struct proc* p = getProcById(pid);
	static char* types[] = { "FD_NONE", "FD_PIPE", "FD_INODE" };

	int i = 0;

	//header
	appendStringToCharBuff(buff, &i, "Information of fd ");
	appendIntToCharBuff(buff, &i, fd);
	appendStringToCharBuff(buff, &i, "\n");


	//type
	appendStringToCharBuff(buff, &i, "type: \n");
	appendStringToCharBuff(buff, &i, "  ");
	appendStringToCharBuff(buff, &i, types[p->ofile[fd]->type]);
	appendStringToCharBuff(buff, &i, "\n");

	//offset
	appendStringToCharBuff(buff, &i, "offset: \n");
	appendStringToCharBuff(buff, &i, "  ");
	appendIntToCharBuff(buff, &i, p->ofile[fd]->off);
	appendStringToCharBuff(buff, &i, "\n");

	//flags
	appendStringToCharBuff(buff, &i, "flags: \n");
	if(p->ofile[fd]->readable) appendStringToCharBuff(buff, &i, "  *Readable\n");
	if(p->ofile[fd]->writable) appendStringToCharBuff(buff, &i, "  *Writable\n");
	appendStringToCharBuff(buff, &i, "\n\0");

	return i;
}

int buildStatusInfoFile(char* buff, int pid){
	struct proc* p = getProcById(pid);
	static char* run_types[] = { "UNUSED", "EMBRYO", "SLEEPING", "RUNNABLE", "RUNNING", "ZOMBIE" };

	int i = 0;

	//header
	appendStringToCharBuff(buff, &i, "Information of process ");
	appendIntToCharBuff(buff, &i, pid);
	appendStringToCharBuff(buff, &i, "\n");


	//type
	appendStringToCharBuff(buff, &i, "state: \n");
	appendStringToCharBuff(buff, &i, "  ");
	appendStringToCharBuff(buff, &i, run_types[p->state]);
	appendStringToCharBuff(buff, &i, "\n");

	//size
	appendStringToCharBuff(buff, &i, "size: \n");
	appendStringToCharBuff(buff, &i, "  ");
	appendIntToCharBuff(buff, &i, p->sz);

	appendStringToCharBuff(buff, &i, "\n\0");

	return i;

}


int
procfsread(struct inode *ip, char *dst, int off, int n) {
	//cprintf("%s | [%s] start\n", proc->pid, __FUNCTION__);
	//cprintf("read inum:%d, off:%d, n:%d\n", ip->inum, off, n);

	if (procfsisdir(ip))
	{
		int numOfEntries = 0;
		struct dirent dir[32];
		if (ip->inum == PROC_FOLDER_INUM)	//"proc" dir
		{
			numOfEntries = buildProcFolder(dir);
		}
		else if (ip->inum % 100 == VFILE_PID_FOLDER)	//"pid" dir
		{
			numOfEntries = buildPidFolder(dir, ip);
		}
		else	//"fdinfo" dir
		{
			numOfEntries = buildFdinfoFolder(dir, ip);
		}
		if ((off/16)+1 > numOfEntries)	return 0;	//out of bounds

		memmove(dst, dir+(off/16), n);
	}
	else
	{

		char buff[100];
		int size = 0;
		int pid = ip->inum / 100;
		int fd = ip->inum % 100 -10;

		//status file
		if (ip->inum % 100 == VFILE_STATUS)
		{
			size = buildStatusInfoFile(buff, pid);

		}
		//cmdline file
		else if(ip->inum % 100 == VFILE_CMDLINE) {
			memmove(buff, getProcById(pid)->cmdline, sizeof(buff));
			size = strlen(buff);
		}
		//fdinfo file
		else{
			size = buildFdInfoFile(buff, pid, fd);
		}

		int readLength = (n < size-off)? n : size-off;
		memmove(dst, buff+off, readLength);
		return readLength;
	}

	return sizeof(struct dirent);
}

int
procfswrite(struct inode *ip, char *buf, int n)
{
	cprintf("procfswrite\n");
	panic("cant write to procfs");

  return 0;
}

void
procfsinit(void)
{
  devsw[PROCFS].isdir = procfsisdir;
  devsw[PROCFS].iread = procfsiread;
  devsw[PROCFS].write = procfswrite;
  devsw[PROCFS].read = procfsread;
}
