#include "types.h"
#include "user.h"
#include "hoare_slots_monitor.h"

hoare_slots_monitor_t* hoare_slots_monitor_alloc()
{
	printf(1,"%d | [%s] start \n",kthread_id(), __FUNCTION__);

	hoare_slots_monitor_t* monitor = malloc(sizeof(hoare_slots_monitor_t));
	if(monitor == 0){
		printf(1,"%d | [%s] malloc failed \n",kthread_id(), __FUNCTION__);
		return 0;
	}
	if( (monitor->event_noSlotsAvailable = hoare_cond_alloc()) == 0){
		printf(1,"%d | [%s] hoare_cond_alloc failed \n",kthread_id(), __FUNCTION__);
		return 0;
	}
	if( (monitor->event_freeSlotsAvailable = hoare_cond_alloc()) == 0){
		printf(1,"%d | [%s] hoare_cond_alloc failed \n",kthread_id(), __FUNCTION__);
		return 0;
	}

	monitor->numOfFreeSlots = 0;
	if( (monitor->innerMutex = kthread_mutex_alloc()) == 0 ){
		printf(1,"%d | [%s] kthread_mutex_alloc failed \n",kthread_id(), __FUNCTION__);
		return 0;
	}
	monitor->shouldStopAddingSlots = 0;

	printf(1,"%d | [%s] success. done \n",kthread_id(), __FUNCTION__);

	return monitor;
}

int hoare_slots_monitor_dealloc(hoare_slots_monitor_t* monitor)
{
	printf(1,"%d | [%s] start \n",kthread_id(), __FUNCTION__);

	if( hoare_cond_dealloc(monitor->event_noSlotsAvailable) < 0){
		printf(1,"%d | [%s] hoare_cond_dealloc failed \n",kthread_id(), __FUNCTION__);
		return -1;
	}

	if( hoare_cond_dealloc(monitor->event_freeSlotsAvailable) < 0){
		printf(1,"%d | [%s] hoare_cond_dealloc failed \n",kthread_id(), __FUNCTION__);
		return -1;
	}

	if( kthread_mutex_dealloc(monitor->innerMutex) < 0 ){
		printf(1,"%d | [%s] kthread_mutex_dealloc failed \n",kthread_id(), __FUNCTION__);
		return -1;
	}

	monitor->numOfFreeSlots = 0;
	monitor->shouldStopAddingSlots = 0;

	free(monitor);

	printf(1,"%d | [%s] success. done \n",kthread_id(), __FUNCTION__);

	return 0;
}

int hoare_slots_monitor_addslots(hoare_slots_monitor_t* monitor, int n)
{
	if( kthread_mutex_lock(monitor->innerMutex)  < 0 ) return -1;
	printf(1,"%d | [%s] start \n",kthread_id(), __FUNCTION__);
	int slotsNum;
	//go to sleep if there are free slots (and there are more students that wants to take)
	while(!monitor->shouldStopAddingSlots && ( (slotsNum =monitor->numOfFreeSlots) > 0) ){
		printf(1,"%d | [%s] %d free slots available, waiting for full or stopped \n",kthread_id(), __FUNCTION__, slotsNum);
		if(hoare_cond_wait(monitor->event_noSlotsAvailable, monitor->innerMutex) < 0) return -1;
	}

	//if left waiting because no more students available (shouldStop = 1)
	if(monitor->shouldStopAddingSlots){
		printf(1,"%d | [%s] got shouldStopAddingSlots=1 \n",kthread_id(), __FUNCTION__);
		printf(1,"%d | [%s] success. done \n",kthread_id(), __FUNCTION__);
		if(kthread_mutex_unlock(monitor->innerMutex) < 0) return -1;
		return 0;
	}

	//adding slots
	monitor->numOfFreeSlots = n;
	printf(1,"%d | [%s] added %d slots \n",kthread_id(), __FUNCTION__,n);

	if(hoare_cond_signal(monitor->event_freeSlotsAvailable, monitor->innerMutex) < 0) return -1;

	//notify a student free slots available
	if(  kthread_mutex_unlock(monitor->innerMutex) < 0) return -1;

	printf(1,"%d | [%s] success. done \n",kthread_id(), __FUNCTION__);
	return 0;

}

int hoare_slots_monitor_takeslot(hoare_slots_monitor_t* monitor)
{
	if( kthread_mutex_lock(monitor->innerMutex)  < 0 ) return -1;
	printf(1,"%d | [%s] start \n",kthread_id(), __FUNCTION__);

	//waiting if no free slots
	while(monitor->numOfFreeSlots == 0 ){
		printf(1,"%d | [%s] no free slots available, waiting for Grader to add \n",kthread_id(), __FUNCTION__);
		printf(1,"%d | [%s] signal Grader that we need more slots \n",kthread_id(), __FUNCTION__);
		//signaling grader, i will continue running with lock so i could go to sleep before she signals back
		if(hoare_cond_signal(monitor->event_noSlotsAvailable, monitor->innerMutex)) return -1;
		//going to sleep till free slots available
		if(hoare_cond_wait(monitor->event_freeSlotsAvailable, monitor->innerMutex) < 0) return -1;
	}
	monitor->numOfFreeSlots--;
	printf(1,"%d | [%s] took a slot, %d slots remain \n",kthread_id(), __FUNCTION__, monitor->numOfFreeSlots);

	//if there are more free slots, wakeup another student
	if(monitor->numOfFreeSlots > 0){
		printf(1,"%d | [%s] signaling another student \n",kthread_id(), __FUNCTION__);
		if(hoare_cond_signal(monitor->event_freeSlotsAvailable, monitor->innerMutex) < 0) return -1;
	}
	//otherwise , wakeup grader for more slots
	else{
		printf(1,"%d | [%s] signaling grader \n",kthread_id(), __FUNCTION__);
		if(hoare_cond_signal(monitor->event_noSlotsAvailable, monitor->innerMutex) < 0) return -1;
	}

	printf(1,"%d | [%s] success. done \n",kthread_id(), __FUNCTION__);
	if(  kthread_mutex_unlock(monitor->innerMutex) < 0) return -1;

	return 0;
}

int hoare_slots_monitor_stopadding(hoare_slots_monitor_t* monitor)
{
	if( kthread_mutex_lock(monitor->innerMutex)  < 0 ) return -1;
	printf(1,"%d | [%s] start \n",kthread_id(), __FUNCTION__);
	monitor->shouldStopAddingSlots = 1;
	hoare_cond_signal(monitor->event_noSlotsAvailable, monitor->innerMutex);
	printf(1,"%d | [%s] success. done \n",kthread_id(), __FUNCTION__);
	if(  kthread_mutex_unlock(monitor->innerMutex) < 0) return -1;
	return 0;
}
