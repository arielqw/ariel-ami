#ifndef MESA_SLOTS_MONITOR_H
#define	MESA_SLOTS_MONITOR_H
#include "mesa_cond.h"

typedef struct mesa_slots_monitor {
    mesa_cond_t* event_noSlotsAvailable;
    mesa_cond_t* event_freeSlotsAvailable;
    int numOfFreeSlots;
    int innerMutex;
    int shouldStopAddingSlots;
} mesa_slots_monitor_t;

mesa_slots_monitor_t* mesa_slots_monitor_alloc();
int mesa_slots_monitor_dealloc(mesa_slots_monitor_t*);
int mesa_slots_monitor_addslots(mesa_slots_monitor_t*,int);
int mesa_slots_monitor_takeslot(mesa_slots_monitor_t*);
int mesa_slots_monitor_stopadding(mesa_slots_monitor_t*);

#endif	/* MESA_SLOTS_MONITOR_H */

