module uim.infrastructure.ui5server.infrastructure.adapters.inmemory.server_repository;

import core.sync.mutex : Mutex;
import uim.infrastructure.ui5server.domain.entities.server : Server, ServerStatus;
import uim.infrastructure.ui5server.domain.ports.repositories.server : IServerRepository;

class InMemoryServerRepository : IServerRepository {
    private Server[string] store;
    private Mutex mtx;

    this() {
        mtx = new Mutex();
    }

    bool save(Server server) {
        mtx.lock();
        scope(exit) mtx.unlock();
        store[server.id] = server;
        return true;
    }

    Server* findById(string id) {
        mtx.lock();
        scope(exit) mtx.unlock();
        auto p = id in store;
        return p;
    }

    Server* findByName(string name) {
        mtx.lock();
        scope(exit) mtx.unlock();
        foreach (ref s; store) {
            if (s.name == name) return &s;
        }
        return null;
    }

    Server[] findAll() {
        mtx.lock();
        scope(exit) mtx.unlock();
        return store.values;
    }

    bool remove(string id) {
        mtx.lock();
        scope(exit) mtx.unlock();
        if (id in store) {
            store.remove(id);
            return true;
        }
        return false;
    }

    bool updateStatus(string id, ServerStatus status) {
        mtx.lock();
        scope(exit) mtx.unlock();
        auto p = id in store;
        if (p is null) return false;
        p.status = status;
        return true;
    }
}
