#ifndef GLOBALADDON_H_
#define GLOBALADDON_H_
#include <string>
#include <vector>
#include <atomic>
#include <fstream>
#include <iostream>
#include <algorithm>
#include <unordered_map>
#include <boost/date_time/posix_time/posix_time.hpp>
#include <boost/thread/mutex.hpp>
#include <boost/thread/lock_guard.hpp>
#include "Global-Type.h"

class nodelock
{
private:
    std::atomic_flag* locker;
public:
    nodelock(std::atomic_flag* n_locker)
    {
        while (n_locker->test_and_set(std::memory_order_acquire));
        locker = n_locker;
    }
    ~nodelock()
    {
        locker->clear(std::memory_order_release);
    }
};

class nodelist
{
private:
    std::atomic_flag locker = ATOMIC_FLAG_INIT;
    std::unordered_map<std::string, vecstr> node;
public:
    vecstr& operator[](std::string id)
    {
        nodelock lock(&locker);
        return node[id];
    }
    unsigned int size()
    {
        return node.size();
    }
    void erase(std::unordered_map<std::string, vecstr>::iterator iter)
    {
        nodelock lock(&locker);
        node.erase(iter);
    }
    std::unordered_map<std::string, vecstr>::iterator find(std::string key)
    {
        nodelock lock(&locker);
        return node.find(key);
    }
};

template<typename subclass>
class safeStringMap : public std::map<std::string, subclass>
{
private:
    std::atomic_flag locker = ATOMIC_FLAG_INIT;
    using base = std::map<std::string, subclass>;
public:
    subclass& operator[](std::string key)
    {
        nodelock lock(&locker);
        return base::try_emplace(std::move(key)).first->second;
    }
    typename base::iterator find(const std::string& keyval)
    {
        nodelock lock(&locker);
        return base::lower_bound(keyval);
    }
};

template<typename subclass>
class safeStringUMap : public std::unordered_map<std::string, subclass>
{
private:
    std::atomic_flag locker = ATOMIC_FLAG_INIT;
    using base = std::unordered_map<std::string, subclass>;
public:
    subclass& operator[](std::string key)
    {
        nodelock lock(&locker);
        return base::try_emplace(std::move(key)).first->second;
    }
    subclass& at(std::string key)
    {
        nodelock lock(&locker);
        typename base::iterator where = base::find(key);
        if (where == base::end()) std::cout << "invalid unordered_map<K, T> key" << std::endl;
        return where->second;
    }
    typename base::iterator find(const std::string& keyval)
    {
        nodelock lock(&locker);
        return base::find(keyval);
    }
    typename base::iterator end()
    {
        nodelock lock(&locker);
        return base::end();
    }
};

typedef safeStringMap<std::shared_ptr<hkbobject>> hkRefPtr;

void NemesisReaderFormat(int id, vecstr& output);
void FolderCreate(std::string curBehaviorPath);
void GetFunctionLines(std::string filename, vecstr& storeline);
std::string NodeIDCheck(std::string ID);
vecstr GetElements(std::string number, std::unordered_map<std::string, vecstr>& functionlines, bool isTransition = false, std::string key = "");
bool isOnlyNumber(std::string line);
bool hasAlpha(std::string line);

#endif
