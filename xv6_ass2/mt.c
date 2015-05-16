/*
 * mutextest.c
 *
 *  Created on: Apr 26, 2015
 *      Author: hodai
 */


#include "kthread.h"
#include "user.h"

#define STACK_SIZE 1000

/* globals */
int mutex1;
int mutex2;
int resource1[20];
int resource2;

/* utils */
#define ASSERT(cond, ...) \
    if(cond){ \
      printf(2, "FAIL at %s:%d - ", __FUNCTION__, __LINE__); \
      printf(2, __VA_ARGS__); \
      printf(2, "\n"); \
      exit(); \
    }


void* safeThread(){
  int i;

  /* part one use mutual array of resources */
  ASSERT((kthread_mutex_lock(mutex1) == -1), "kthread_mutex_lock(%d) fail", mutex1);

  resource1[0] = kthread_id();
  for(i = 1 ;i < 20; i++){
    //sleep(i % 2);   // make some more troubles
    resource1[i] = resource1[i-1];
  }
  //sleep(kthread_id() % 2);   // make some more troubles
  ASSERT((resource1[i-1] != kthread_id()), "(resource1[%d] != kthread_id:%d) fail", i, kthread_id());

  ASSERT((kthread_mutex_unlock(mutex1) == -1), "kthread_mutex_unlock(%d) fail", mutex1);

  /* part two - mutual calculation */
  ASSERT((kthread_mutex_lock(mutex2) == -1), "kthread_mutex_lock(%d) fail", mutex2);
  //sleep(kthread_id() % 2);   // make some more troubles
  resource2 = resource2 + kthread_id();
  ASSERT((kthread_mutex_unlock(mutex2) == -1), "kthread_mutex_unlock(%d) fail", mutex2);

  kthread_exit();
  return 0;
}

void* unsafeThread(){
  int i;

  resource1[0] = kthread_id();
  for(i = 1 ;i < 20; i++){
    sleep(i % 2);   // make some more troubles
    resource1[i] = resource1[i-1];
  }
  sleep(kthread_id());   // make some more troubles
  //ASSERT((resource1[i-1] != kthread_id()), "(resource1[%d] != kthread_id()) fail", i);

  resource2 = resource2 + resource1[i-1];

  kthread_exit();
  return 0;
}

void* loopThread(){
  for(;;){};
  return 0;
}

void stressTest1(int count){


  int tid[count];
  int i,ans;
  int c=0;
  char* stack;

  printf(1, "starting %s test\n", __FUNCTION__);

  for (i = 0 ; i < 20; i++)
    resource1[i] = 0;
  resource2 = 0;
  mutex1 = kthread_mutex_alloc();
  mutex2 = kthread_mutex_alloc();
  ASSERT((mutex1 == mutex2), "(mutex1 == mutex2)");

  for (i = 0 ; i < count; i++){
    stack = malloc(STACK_SIZE);
    tid[i] = kthread_create(safeThread, stack, STACK_SIZE);
    ASSERT((tid[i] <= 0), "kthread_create return with: %d, for index:%d", tid[i], i);
    c += tid[i];
    //sleep(i % 2);   // make some more troubles
  }

  for (i = 0 ; i < count; i++){
    ans = kthread_join(tid[i]);
    // if fail here it's not always error!
    ASSERT((ans != 0), "kthread_join(%d) return with: %d", tid[i], ans)
  }

  // free the mutexes
  ASSERT( (kthread_mutex_dealloc(mutex1) != 0), "dealloc");
  ASSERT( (kthread_mutex_dealloc(mutex2) != 0), "dealloc");

  ASSERT((c != resource2), "(c != resource2) : (%d != %d)" , c, resource2);

  printf(1, "%s test PASS!\n", __FUNCTION__);

}

/* this test should fail most of the time because synchronization error */
void stressTest2Fail(int count){
  int tid[count];
  int i,ans;
  int c=0;
  char* stack;

  printf(1, "starting %s test\n", __FUNCTION__);

  for (i = 0 ; i < 20; i++)
    resource1[i] = 0;
  resource2 = 0;

  for (i = 0 ; i < count; i++){
    stack = malloc(STACK_SIZE);
    tid[i] = kthread_create(&unsafeThread, stack+STACK_SIZE, STACK_SIZE);
    sleep(i %3);   // make some more troubles
    ASSERT((tid[i] <= 0), "kthread_create return with: %d, for index:%d", tid[i], i);
    c += tid[i];
  }

  for (i = 0 ; i < count; i++){
    ans = kthread_join(tid[i]);
    // if fail here it's not always error!
    ASSERT((ans != 0), "kthread_join(%d) return with: %d", tid[i], ans)
  }

  ASSERT((c == resource2), "(c == resource2) : (%d != %d), we expect to fail here!!" , c, resource2);

  printf(1, "%s test PASS!\n", __FUNCTION__);

}

/* this test check that we can't create more then 16(count) threads  */
void stressTest3toMuchTreads(int count){
  int tid[count*2];
  int i;
  char* stack;

  printf(1, "starting %s test\n", __FUNCTION__);

  for (i = 0 ; i < count; i++){
    stack = malloc(STACK_SIZE);
    tid[i] = kthread_create(&loopThread, stack+STACK_SIZE, STACK_SIZE);
    ASSERT((tid[i] <= 0), "kthread_create return with: %d, for index:%d", tid[i], i);
  }

  if(kthread_create(&loopThread, stack+STACK_SIZE, STACK_SIZE) >= 0){
    printf(1, "%s test FAIL!\n", __FUNCTION__);
  } else {
    printf(1, "%s test PASS!\n", __FUNCTION__);
  }

  // the threads do not kill themself
  exit();

}

void* yieldThread(){
  int i;

  sleep(kthread_id() % 3);  // change the order of the waiters threads

  /* part one use mutual array of resources */
  ASSERT((kthread_mutex_lock(mutex2) == -1), "kthread_mutex_lock(%d) fail", mutex2);

  resource1[0] = kthread_id();
  for(i = 1 ;i < 20; i++){
    sleep(i % 2);   // make some more troubles
    resource1[i] = resource1[i-1];
  }
  sleep(kthread_id() % 2);   // make some more troubles
  ASSERT((resource1[i-1] != kthread_id()), "(resource1[%d] != kthread_id:%d) fail", i, kthread_id());

  /* part two - mutual calculation */
  sleep(kthread_id() % 2);   // make some more troubles
  resource2 = resource2 + kthread_id();

  // pass the mutex to the next thread
  ASSERT((kthread_mutex_yieldlock(mutex1, mutex2) != 0), "mutex yield");


  kthread_exit();
  return 0;
}

void* trubleThread(){

  ASSERT((kthread_mutex_lock(mutex1) == -1), "kthread_mutex_lock(%d) fail", mutex1);
  resource2 = -10;

  ASSERT((kthread_mutex_unlock(mutex1) == -1), "kthread_mutex_unlock(%d) fail", mutex1);

  kthread_exit();
  return 0;
}

void mutexYieldTest(){
  int tid[10], ttid =0;
  int i,ans;
  int c=0;
  char* stack;

  printf(1, "starting %s test\n", __FUNCTION__);

  for (i = 0 ; i < 20; i++)
    resource1[i] = 0;
  resource2 = 0;
  mutex1 = kthread_mutex_alloc();
  mutex2 = kthread_mutex_alloc();
  ASSERT((mutex1 < 0), "(mutex1 < 0)");
  ASSERT((mutex2 < 0), "(mutex2 < 0)");
  ASSERT((mutex1 == mutex2), "(mutex1 == mutex2)");

  ASSERT((kthread_mutex_lock(mutex1) != 0), "mutex lock");
  ASSERT((kthread_mutex_lock(mutex2) != 0), "mutex lock");

  stack = malloc(STACK_SIZE);
  ttid = kthread_create(&trubleThread, stack+STACK_SIZE, STACK_SIZE);

  for (i = 0 ; i < 10; i++){
    stack = malloc(STACK_SIZE);
    tid[i] = kthread_create(&yieldThread, stack+STACK_SIZE, STACK_SIZE);
    sleep(i %3);   // make some more troubles
    c += tid[i];
  }

  sleep(1);   // wait all threads to sleep on mutex2
  ASSERT((kthread_mutex_yieldlock(mutex1, mutex2) != 0), "mutex yield");


  for (i = 0 ; i < 10; i++){
    ASSERT((resource2 < 0), "(resource2 < 0)")
    ans = kthread_join(tid[i]);
    // if fail here it's not always error!
    ASSERT((ans != 0), "kthread_join(%d) return with: %d", tid[i], ans)
  }

  kthread_mutex_lock(mutex1);
  ASSERT((resource2 != -10), "expect resource2=-10, but resource2=%d, c=%d" , resource2, c);
  kthread_mutex_unlock(mutex1);

  // wait for the truble thread
  kthread_join(ttid);

  // check that the last yield release the mutexes
  ASSERT((kthread_mutex_lock(mutex1) != 0), "mutex lock");
  ASSERT((kthread_mutex_lock(mutex2) != 0), "mutex lock");
  ASSERT((kthread_mutex_unlock(mutex1) != 0), "mutex unlock");
  ASSERT((kthread_mutex_unlock(mutex2) != 0), "mutex unlock");

  // free the mutexes
  ASSERT( (kthread_mutex_dealloc(mutex1) != 0), "dealloc");
  ASSERT( (kthread_mutex_dealloc(mutex2) != 0), "dealloc");

  printf(1, "%s test PASS!\n", __FUNCTION__);

}

void senaty(int count){
  int i, j;
  int mutex[MAX_MUTEXES];

  printf(1, "starting %s test\n", __FUNCTION__);
  for(j=0 ; j<2 ; j++){ // run the test twice to check that mutexes can be reused
    for(i=0 ; i < count ; i++){
      mutex[i] = kthread_mutex_alloc();
      ASSERT((mutex[i] == -1), "kthread_mutex_alloc fail, i=%d", i);
      ASSERT((kthread_mutex_lock(mutex[i]) == -1), "kthread_mutex_lock(%d) fail", mutex[i]);
      ASSERT((kthread_mutex_unlock(mutex[i]) == -1), "kthread_mutex_unlock(%d) fail", mutex[i]);
      ASSERT((kthread_mutex_unlock(mutex[i]) != -1), "second kthread_mutex_unlock(%d) didn't fail as expected", mutex[i]);
    }

    for(i=0 ; i < count ; i++){
      ASSERT((kthread_mutex_lock(mutex[i]) == -1), "kthread_mutex_lock(%d) fail", mutex[i]);
    }

    for(i=0 ; i < count ; i++){
      ASSERT((kthread_mutex_unlock(mutex[i]) == -1), "kthread_mutex_unlock(%d) fail", mutex[i]);
      ASSERT((kthread_mutex_unlock(mutex[i]) != -1), "second kthread_mutex_unlock(%d) didn't fail as expected", mutex[i]);
    }

    for(i=0 ; i < count ; i++){
      ASSERT((kthread_mutex_dealloc(mutex[i]) == -1), "kthread_mutex_dealloc(%d) fail", mutex[i]);
      ASSERT((kthread_mutex_dealloc(mutex[i]) != -1), "second kthread_mutex_dealloc(%d) didn't fail as expected", mutex[i]);
      ASSERT((kthread_mutex_lock(mutex[i]) != -1), "kthread_mutex_lock(%d) didn't fail after dealloc", mutex[i]);
      ASSERT((kthread_mutex_unlock(mutex[i]) != -1), "kthread_mutex_unlock(%d) didn't fail after dealloc", mutex[i]);
    }
  }

  /* chack that mutexes are really limited by MAX_MUTEXES */
  for (i=0 ; i<MAX_MUTEXES ; i++){
    mutex[i] = kthread_mutex_alloc();
    ASSERT((mutex[i] == -1), "kthread_mutex_alloc (limit) fail, i=%d, expected fail at:%d", i, MAX_MUTEXES);
  }

  ASSERT((kthread_mutex_alloc() != -1), "limit test didn't fail as expected create %d mutexes instad of %d", i+1, MAX_MUTEXES);

  // release all mutexes
  for (i=0 ; i<MAX_MUTEXES ; i++){
    ASSERT((kthread_mutex_dealloc(mutex[i]) == -1), "kthread_mutex_dealloc(%d) fail, i=%d", mutex[i], i);
  }

  printf(1, "%s test PASS!\n", __FUNCTION__);
}


int main(){
  //senaty(MAX_MUTEXES);
  stressTest1(15);
//  mutexYieldTest();
//  stressTest2Fail(15);
//  stressTest3toMuchTreads(15); //this test must be the last



  exit();
}

