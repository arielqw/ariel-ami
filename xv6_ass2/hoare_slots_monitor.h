#ifndef HOARE_SLOTS_MONITOR_H
#define	HOARE_SLOTS_MONITOR_H

typedef struct hoare_slots_monitor {
    //Your code here...
} hoare_slots_monitor_t;

hoare_slots_monitor_t* hoare_slots_monitor_alloc();
int hoare_slots_monitor_dealloc(hoare_slots_monitor_t*);
int hoare_slots_monitor_addslots(hoare_slots_monitor_t*,int);
int hoare_slots_monitor_takeslot(hoare_slots_monitor_t*);
int hoare_slots_monitor_stopadding(hoare_slots_monitor_t*);

#endif	/* HOARE_SLOTS_MONITOR_H */

