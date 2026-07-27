/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.kafka.infrastructure.adapters.inmemory.broker_repository;

import core.sync.mutex : Mutex;
import std.conv : to;
import uim.infrastructure.kafka.domain.entities.broker : Broker;
import uim.infrastructure.kafka.domain.ports.repositories.broker : IBrokerRepository;

class InMemoryBrokerRepository : IBrokerRepository {
    private Broker[uint] brokers;
    private Mutex mtx;

    this() {
        mtx = new Mutex();
    }

    void save(in Broker broker) {
        mtx.lock();
        scope(exit) mtx.unlock();
        brokers[broker.id] = cast(Broker) broker;
    }

    void update(in Broker broker) {
        mtx.lock();
        scope(exit) mtx.unlock();
        brokers[broker.id] = cast(Broker) broker;
    }

    Broker[] list() {
        mtx.lock();
        scope(exit) mtx.unlock();
        return brokers.values;
    }

    Broker* findById(uint id) {
        mtx.lock();
        scope(exit) mtx.unlock();
        auto p = id in brokers;
        if (p is null) return null;
        return p;
    }

    void deleteById(uint id) {
        mtx.lock();
        scope(exit) mtx.unlock();
        brokers.remove(id);
    }
}
