
.code32
.globl implicit_exit
.globl implicit_exit_end

implicit_exit:
	push %eax
	push $0xffffffff #fake address

	movl $2, %eax;
	int $64;

implicit_exit_end:
