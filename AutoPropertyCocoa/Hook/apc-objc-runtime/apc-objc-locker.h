//
//  apc-objc-os.cpp
//  AutoPropertyCocoa
//
//  Created by Meterwhite on 2019/5/13.
//  Copyright (c) 2019 GitHub, Inc. All rights reserved.
//

#ifdef __cplusplus

#include <Foundation/Foundation.h>
#include <pthread.h>

class apc_nocopy_t {
private:
    apc_nocopy_t(const apc_nocopy_t&) = delete;
    const apc_nocopy_t& operator=(const apc_nocopy_t&) = delete;
protected:
    apc_nocopy_t() { }
    ~apc_nocopy_t() { }
};


class apc_runtimelock_reader_t : apc_nocopy_t {
    pthread_rwlock_t& lock;
public:
    apc_runtimelock_reader_t(pthread_rwlock_t& newLock) : lock(newLock)
    {
        const int err __attribute__((unused)) = pthread_rwlock_rdlock(&lock);
        NSCAssert(err == 0, @"pthread_rwlock_rdlock failed (%d)", err);
    }
    ~apc_runtimelock_reader_t()
    {
        const int err __attribute__((unused)) = pthread_rwlock_unlock(&lock);
        NSCAssert(err == 0, @"pthread_rwlock_unlock failed (%d)", err);
    }
};

class apc_runtimelock_writer_t : apc_nocopy_t {
    pthread_rwlock_t& lock;
public:
    apc_runtimelock_writer_t(pthread_rwlock_t& newLock) : lock(newLock)
    {
        const int err __attribute__((unused))
        =
        pthread_rwlock_wrlock(&lock);
        
        NSCAssert(err == 0, @"pthread_rwlock_wrlock failed (%d)", err);
    }
    ~apc_runtimelock_writer_t()
    {
        const int err __attribute__((unused))
        =
        pthread_rwlock_unlock(&lock);
        
        NSCAssert(err == 0, @"pthread_rwlock_unlock failed (%d)", err);
    }
};

#endif
