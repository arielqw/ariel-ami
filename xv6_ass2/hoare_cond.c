#include "types.h"
#include "user.h"
#include "hoare_cond.h"

hoare_cond_t* hoare_cond_alloc()
{
	printf(1,"%d | [%s] start \n",kthread_id(), __FUNCTION__);

	hoare_cond_t* cv = malloc(sizeof(hoare_cond_t));
	if(cv == 0){
		printf(1,"%d | [%s] malloc cv failed \n",kthread_id(), __FUNCTION__);
		return 0;
	}
	cv->inner_mutex_id = kthread_mutex_alloc();
	cv->numOfThreadsWaiting = 0;

	kthread_mutex_lock(cv->inner_mutex_id);

	if(cv->inner_mutex_id < 0){
		printf(1,"%d | [%s] inner mutex alloc failed \n",kthread_id(), __FUNCTION__);
		return 0;
	}
	printf(1,"%d | [%s] success \n",kthread_id(), __FUNCTION__);

	return cv;
}

int hoare_cond_dealloc(hoare_cond_t* cond)
{
	printf(1,"%d | [%s] start \n",kthread_id(), __FUNCTION__);
	if(cond->numOfThreadsWaiting > 0){
		printf(1,"%d | [%s] failed, there are %d threads waiting on this cv \n",kthread_id(), __FUNCTION__, cond->numOfThreadsWaiting);
		//return -1;
	}
	if(kthread_mutex_unlock(cond->inner_mutex_id) < 0){
		printf(1,"%d | [%s] failed, unlocking of inner mutex %d failed \n",kthread_id(), __FUNCTION__, cond->inner_mutex_id);
		//return -1;
	}
	cond->inner_mutex_id = 0;
	cond->numOfThreadsWaiting = 0;
	free(cond);

	printf(1,"%d | [%s] success \n",kthread_id(), __FUNCTION__);
	return 0;
}

int hoare_cond_wait(hoare_cond_t* cond, int mutex_id)
{
	printf(1,"%d | [%s] start \n",kthread_id(), __FUNCTION__);
	cond->numOfThreadsWaiting++;

	//releasing given mutex
	if( kthread_mutex_unlock(mutex_id) < 0){
		printf(1,"%d | [%s] failed, unlocking of given mutex %d failed \n",kthread_id(), __FUNCTION__, mutex_id);
		//return -1;
	}

	//waiting till signaled
	if( kthread_mutex_lock(cond->inner_mutex_id) < 0){
		printf(1,"%d | [%s] failed, locking of  inner mutex %d after signaled failed \n",kthread_id(), __FUNCTION__, cond->inner_mutex_id);
		//return -1;
	}

	cond->numOfThreadsWaiting--;

	printf(1,"%d | [%s] success \n",kthread_id(), __FUNCTION__);
	return 0;
}

//MUST HOLD mutex_id for this
int hoare_cond_signal(hoare_cond_t* cond, int mutex_id)
{
	printf(1,"%d | [%s] start \n",kthread_id(), __FUNCTION__);

	if(cond->numOfThreadsWaiting == 0){
		goto end;
	}
	if( kthread_mutex_yieldlock(mutex_id, cond->inner_mutex_id) < 0){
		printf(1,"%d | [%s] failed, yeild lock with mutexes %d,%d failed \n",kthread_id(), __FUNCTION__, mutex_id, cond->inner_mutex_id);
		//		return -1;
	}


	if( kthread_mutex_unlock(cond->inner_mutex_id) < 0){
		printf(1,"%d | [%s] failed, unlocking inner mutex %d failed \n",kthread_id(), __FUNCTION__, cond->inner_mutex_id);
		//return -1;
	}


	if( kthread_mutex_lock(mutex_id) < 0){
		printf(1,"%d | [%s] failed, unlocking inner mutex %d failed \n",kthread_id(), __FUNCTION__, cond->inner_mutex_id);
		//return -1;
	}
	end:
	printf(1,"%d | [%s] success \n",kthread_id(), __FUNCTION__);

	return 0;
}
