#include "types.h"

#include "user.h"

#include "mesa_slots_monitor.h"

mesa_slots_monitor_t* mesa_slots_monitor_alloc()
{
	printf(1, "%d | [%s] start \n", kthread_id(), __FUNCTION__);

	// allocating memory for monitor
	mesa_slots_monitor_t* monitor = malloc(sizeof(mesa_slots_monitor_t));

	if (monitor == 0) {
		printf(1, "%d | [%s] malloc failed \n", kthread_id(), __FUNCTION__);
		return 0;
	}

	// allocating memory for noSlotsAvailable CV
	if ((monitor->event_noSlotsAvailable = mesa_cond_alloc()) == 0) {
		printf(1, "%d | [%s] mesa_cond_alloc failed \n", kthread_id(),__FUNCTION__);
		return 0;
	}
	// allocating memory for freeSlotsAvailable CV
	if ((monitor->event_freeSlotsAvailable = mesa_cond_alloc()) == 0) {
		printf(1, "%d | [%s] mesa_cond_alloc failed \n", kthread_id(),__FUNCTION__);
		return 0;
	}

	monitor->numOfFreeSlots = 0;
	monitor->shouldStopAddingSlots = 0;

	//allocating inner mutex for race conditions
	if ((monitor->innerMutex = kthread_mutex_alloc()) == 0) {
		printf(1, "%d | [%s] kthread_mutex_alloc failed \n", kthread_id(),__FUNCTION__);
		return 0;

	}

	printf(1, "%d | [%s] success. done \n", kthread_id(), __FUNCTION__);

	return monitor;

}

int mesa_slots_monitor_dealloc(mesa_slots_monitor_t* monitor)
{
	printf(1, "%d | [%s] start \n", kthread_id(), __FUNCTION__);

	if (mesa_cond_dealloc(monitor->event_noSlotsAvailable) < 0) {
		printf(1, "%d | [%s] mesa_cond_dealloc failed \n", kthread_id(),__FUNCTION__);
		return -1;
	}

	if (mesa_cond_dealloc(monitor->event_freeSlotsAvailable) < 0) {
		printf(1, "%d | [%s] mesa_cond_dealloc failed \n", kthread_id(),__FUNCTION__);
		return -1;

	}

	if (kthread_mutex_dealloc(monitor->innerMutex) < 0) {
		printf(1, "%d | [%s] kthread_mutex_dealloc failed \n", kthread_id(),__FUNCTION__);
		return -1;

	}

	monitor->numOfFreeSlots = 0;
	monitor->shouldStopAddingSlots = 0;
	free(monitor);

	printf(1, "%d | [%s] success. done \n", kthread_id(), __FUNCTION__);
	return 0;

}

int mesa_slots_monitor_addslots(mesa_slots_monitor_t* monitor, int n)
{
	// entering code with inner mutex
	if (kthread_mutex_lock(monitor->innerMutex) < 0) return -1;

	printf(1, "%d | [%s] start \n", kthread_id(), __FUNCTION__);


	int slotsNum;
	//go to sleep if there are free slots (and there are more students that wants to take)
	while (!monitor->shouldStopAddingSlots && ((slotsNum = monitor->numOfFreeSlots) > 0)) {
		printf(1,"%d | [%s] %d free slots available, waiting for full or stopped \n",kthread_id(), __FUNCTION__, slotsNum);

		//wait until someone signals you
		if (mesa_cond_wait(monitor->event_noSlotsAvailable, monitor->innerMutex)< 0) {
			return -1;
		}
	}

	//if left waiting because no more students available (shouldStop = 1)
	if (monitor->shouldStopAddingSlots) {
		printf(1, "%d | [%s] got shouldStopAddingSlots=1 \n", kthread_id(),__FUNCTION__);
		printf(1, "%d | [%s] success. done \n", kthread_id(), __FUNCTION__);
		if (kthread_mutex_unlock(monitor->innerMutex) < 0)
			return -1;
		return 0;
	}

	//adding slots
	monitor->numOfFreeSlots = n;
	printf(1, "%d | [%s] added %d slots (%d students waiting) \n", kthread_id(), __FUNCTION__, n,monitor->event_freeSlotsAvailable->numOfThreadsWaiting);

	//signal a student that slots where added
	if (mesa_cond_signal(monitor->event_freeSlotsAvailable) < 0) {
		//could fail if no student is waiting
		if (kthread_mutex_unlock(monitor->innerMutex) < 0)
			return -1;
		return -1;
	}

	//exit code - releasing inner mutex
	printf(1, "%d | [%s] success. done \n", kthread_id(), __FUNCTION__);
	if (kthread_mutex_unlock(monitor->innerMutex) < 0) return -1;

	return 0;

}

int mesa_slots_monitor_takeslot(mesa_slots_monitor_t* monitor)
{
	// entering code with inner mutex
	if (kthread_mutex_lock(monitor->innerMutex) < 0) return -1;

	printf(1, "%d | [%s] start \n", kthread_id(), __FUNCTION__);

	//waiting if no free slots
	while (monitor->numOfFreeSlots == 0) {
		printf(1,"%d | [%s] no free slots available, waiting for Grader to add \n",kthread_id(), __FUNCTION__);
		printf(1, "%d | [%s] signal Grader that we need more slots \n",kthread_id(), __FUNCTION__);

		//signaling grader, i will continue running with lock so i could go to sleep before she signals back
		if (mesa_cond_signal(monitor->event_noSlotsAvailable) < 0) {
			if (kthread_mutex_unlock(monitor->innerMutex) < 0) return -1;
			return -1;
		}

		//going to sleep till free slots available
		if (mesa_cond_wait(monitor->event_freeSlotsAvailable,monitor->innerMutex) < 0) return -1;
	}

	//taking a slot
	monitor->numOfFreeSlots--;
	printf(1, "%d | [%s] took a slot, %d slots remain \n", kthread_id(), __FUNCTION__, monitor->numOfFreeSlots);

	//if there are more free slots, wake up another student
	if (monitor->numOfFreeSlots > 0) {
		printf(1, "%d | [%s] signaling another student \n", kthread_id(),__FUNCTION__);

		if (mesa_cond_signal(monitor->event_freeSlotsAvailable) < 0) {
			if (kthread_mutex_unlock(monitor->innerMutex) < 0) return -1;
			return -1;
		}
	}

	//otherwise, 0 free slots -> wake up grader for more slots
	else {
		printf(1, "%d | [%s] signaling grader \n", kthread_id(), __FUNCTION__);
		if (mesa_cond_signal(monitor->event_noSlotsAvailable) < 0) {
			if (kthread_mutex_unlock(monitor->innerMutex) < 0)return -1;
			return -1;
		}
	}

	//exit code - releasing inner mutex
	printf(1, "%d | [%s] success. done \n", kthread_id(), __FUNCTION__);
	if (kthread_mutex_unlock(monitor->innerMutex) < 0) return -1;

	return 0;
}

int mesa_slots_monitor_stopadding(mesa_slots_monitor_t* monitor)
{
	// entering code with inner mutex
	if (kthread_mutex_lock(monitor->innerMutex) < 0)
		return -1;

	printf(1, "%d | [%s] start \n", kthread_id(), __FUNCTION__);

	//changing shouldStop flag
	monitor->shouldStopAddingSlots = 1;

	//waking up grader if sleeping
	if (mesa_cond_signal(monitor->event_noSlotsAvailable) < 0) {
		//could fail if grader isnt sleeping
		if (kthread_mutex_unlock(monitor->innerMutex) < 0) return -1;
		return -1;
	}

	printf(1, "%d | [%s] success. done \n", kthread_id(), __FUNCTION__);

	//exit code - releasing inner mutex
	if (kthread_mutex_unlock(monitor->innerMutex) < 0) return -1;

	return 0;
}

