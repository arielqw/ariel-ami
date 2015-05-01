#ifndef MESA_COND_H
#define	MESA_COND_H

typedef struct mesa_cond {
	//Your code here...
} mesa_cond_t;

mesa_cond_t* mesa_cond_alloc();
int mesa_cond_dealloc(mesa_cond_t*);
int mesa_cond_wait(mesa_cond_t*,int);
int mesa_cond_signal(mesa_cond_t*);

#endif	/* MESA_COND_H */