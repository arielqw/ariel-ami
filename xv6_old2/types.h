enum status { EXIT_STATUS_FAILURE, EXIT_STATUS_SUCCESS, EXIT_STATUS_DEFAULT };
enum wait_options { BLOCKING, NONBLOCKING, WAIT_GROUP };
enum priority { PRIORITY_NONE, PRIORITY_HIGH, PRIORITY_MEDIUM, PRIORITY_LOW };


typedef unsigned int   uint;
typedef unsigned short ushort;
typedef unsigned char  uchar;
typedef uint pde_t;

typedef struct process_info_entry{
  int pid;
  char name[16];
} process_info_entry;
