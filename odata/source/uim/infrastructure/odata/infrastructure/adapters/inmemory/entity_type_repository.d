/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.odata.infrastructure.adapters.inmemory.entity_type_repository;

import core.sync.mutex : Mutex;
import uim.infrastructure.odata.domain.entities.entity_type : EntityType;
import uim.infrastructure.odata.domain.ports.repositories.entity_type : IEntityTypeRepository;

class InMemoryEntityTypeRepository : IEntityTypeRepository {
    private EntityType[string] types;
    private Mutex mtx;

    this() {
        mtx = new Mutex();
    }

    void save(in EntityType entityType) {
        mtx.lock();
        scope(exit) mtx.unlock();
        types[entityType.name] = cast(EntityType) entityType;
    }

    void update(in EntityType entityType) {
        mtx.lock();
        scope(exit) mtx.unlock();
        types[entityType.name] = cast(EntityType) entityType;
    }

    EntityType[] list() {
        mtx.lock();
        scope(exit) mtx.unlock();
        return types.values;
    }

    EntityType* findByName(string name) {
        mtx.lock();
        scope(exit) mtx.unlock();
        auto p = name in types;
        if (p is null) return null;
        return p;
    }

    void deleteByName(string name) {
        mtx.lock();
        scope(exit) mtx.unlock();
        types.remove(name);
    }
}
