module uim.infrastructure.odata.infrastructure.adapters.inmemory.entity_set_repository;

import core.sync.mutex : Mutex;
import uim.infrastructure.odata.domain.entities.entity_set : EntitySet;
import uim.infrastructure.odata.domain.ports.repositories.entity_set : IEntitySetRepository;

class InMemoryEntitySetRepository : IEntitySetRepository {
    private EntitySet[string] sets;
    private Mutex mtx;

    this() {
        mtx = new Mutex();
    }

    void save(in EntitySet entitySet) {
        mtx.lock();
        scope(exit) mtx.unlock();
        sets[entitySet.name] = cast(EntitySet) entitySet;
    }

    EntitySet[] list() {
        mtx.lock();
        scope(exit) mtx.unlock();
        return sets.values;
    }

    EntitySet* findByName(string name) {
        mtx.lock();
        scope(exit) mtx.unlock();
        auto p = name in sets;
        if (p is null) return null;
        return p;
    }

    void deleteByName(string name) {
        mtx.lock();
        scope(exit) mtx.unlock();
        sets.remove(name);
    }
}
