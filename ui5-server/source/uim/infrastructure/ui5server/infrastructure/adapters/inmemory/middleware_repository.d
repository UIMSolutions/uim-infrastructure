/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.ui5server.infrastructure.adapters.inmemory.middleware_repository;

import core.sync.mutex : Mutex;
import std.algorithm : sort;
import std.array : array;
import uim.infrastructure.ui5server.domain.entities.middleware : Middleware;
import uim.infrastructure.ui5server.domain.ports.repositories.middleware : IMiddlewareRepository;

class InMemoryMiddlewareRepository : IMiddlewareRepository {
    private Middleware[string] store;
    private Mutex mtx;

    this() {
        mtx = new Mutex();
    }

    bool save(Middleware mw) {
        mtx.lock();
        scope(exit) mtx.unlock();
        store[mw.name] = mw;
        return true;
    }

    Middleware* findByName(string name) {
        mtx.lock();
        scope(exit) mtx.unlock();
        auto p = name in store;
        return p;
    }

    Middleware[] findAll() {
        mtx.lock();
        scope(exit) mtx.unlock();
        return store.values;
    }

    Middleware[] findAllOrdered() {
        mtx.lock();
        scope(exit) mtx.unlock();
        auto vals = store.values;
        vals.sort!((a, b) => a.order < b.order);
        return vals;
    }

    bool remove(string name) {
        mtx.lock();
        scope(exit) mtx.unlock();
        if (name in store) {
            store.remove(name);
            return true;
        }
        return false;
    }

    bool updateOrder(string name, uint newOrder) {
        mtx.lock();
        scope(exit) mtx.unlock();
        auto p = name in store;
        if (p is null) return false;
        p.order = newOrder;
        return true;
    }

    bool updateEnabled(string name, bool enabled) {
        mtx.lock();
        scope(exit) mtx.unlock();
        auto p = name in store;
        if (p is null) return false;
        p.enabled = enabled;
        return true;
    }
}
