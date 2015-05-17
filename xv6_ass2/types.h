typedef unsigned int   uint;
typedef unsigned short ushort;
typedef unsigned char  uchar;
typedef uint pde_t;

#define DEBUG 0

#define debug_print(fmt, ...) \
            do { if (DEBUG) cprintf(fmt, __VA_ARGS__); } while (0)
