typedef unsigned int   uint;
typedef unsigned short ushort;
typedef unsigned char  uchar;
typedef uint pde_t;
#define TLB_MAX_SIZE 2

struct tlb_entry_wrapper{
	char isUsed;
	uint* pte;
};

struct tlb_t{
	struct tlb_entry_wrapper arr[TLB_MAX_SIZE];
	int size;
};
