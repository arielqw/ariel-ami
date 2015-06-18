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
void itoa(int n, char s[])
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
}




int 
procfsisdir(struct inode *ip) {
	//cprintf("procfsisdir isdir:%d\n", ip->minor == PROCCFS_DIRECTORY);
	//todo: check if should bring from disk if not valid
	return (ip->minor == PROCCFS_DIRECTORY);
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
		if (dp->inum == PROC_FOLDER_INUM)	//dp is "proc" folder
		{
			ip->minor = PROCCFS_DIRECTORY;
			ip->size = 512;
		}
		else if (dp->inum % 100 == 0)	//dp is "pid" folder
		{
			ip->minor = PROCCFS_DIRECTORY;
			ip->size = 512;
//			struct dirent dir[32] ;
//			int numOfEntries = buildPidFolder(dp, ip, dir);
//			memmove((void*)(ip->addrs[0]), dir, sizeof(struct dirent)*numOfEntries);
		}
		else								//children are files
		{
			cprintf("IREAD FILE!!!\n");
			ip->minor = PROCCFS_FILE;
		}
		//todo: place prev folder in data
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

//fills dir
int buildPidFolder(struct dirent* dir, struct inode *ip)
{
	int numOfEntries = 7;

	addDirent(dir, 0, ".", 	ip->inum);
	addDirent(dir, 1, "..", PROC_FOLDER_INUM);

	addDirent(dir, 2, "cmdline", 	ip->inum + VFILE_CMDLINE);
	addDirent(dir, 3, "cwd", 		ip->inum + VFILE_CWD);
	addDirent(dir, 4, "exe", 		ip->inum + VFILE_EXE);
	addDirent(dir, 5, "fdinfo", 	ip->inum + VFILE_FDINFO);
	addDirent(dir, 6, "status", 	ip->inum + VFILE_STATUS);

	return numOfEntries;
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
		else								//"pid" or "fdinfo" dir
		{
			numOfEntries = buildPidFolder(dir, ip);
		}
		if ((off/16)+1 > numOfEntries)	return 0;	//out of bounds

		memmove(dst, dir+(off/16), n);
	}
	else
	{
		//todo: implement read file
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
