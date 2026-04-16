module lb_service.infrastructure.persistence.memory.backend_repository;

import core.sync.mutex : Mutex;
import lb_service.domain.entities.backend : Backend;
import lb_service.domain.ports.repositories.backend : IBackendRepository;

class InMemoryBackendRepository : IBackendRepository {
    private Backend[] backends;
    private Mutex mutex;

    this() {
        mutex = new Mutex;
    }

    override void save(in Backend backend) {
        synchronized (mutex) {
            foreach (i, ref b; backends) {
                if (b.id == backend.id) {
                    backends[i] = backend;
                    return;
                }
            }
            backends ~= backend;
        }
    }

    override void remove(string id) {
        synchronized (mutex) {
            Backend[] remaining;
            foreach (b; backends) {
                if (b.id != id) {
                    remaining ~= b;
                }
            }
            backends = remaining;
        }
    }

    override Backend[] list() {
        synchronized (mutex) {
            return backends.dup;
        }
    }

    override Backend* findById(string id) {
        synchronized (mutex) {
            foreach (ref b; backends) {
                if (b.id == id) {
                    // Heap-copy the struct so the returned pointer remains valid
                    // after the synchronized block exits and the internal array
                    // may be reallocated by a concurrent save/remove.
                    auto copy = new Backend(b.id, b.host, b.port, b.weight, b.healthy);
                    return copy;
                }
            }
            return null;
        }
    }
}

unittest {
    auto repo = new InMemoryBackendRepository();
    repo.save(Backend("b1", "10.0.0.1", 8080, 1, true));
    repo.save(Backend("b2", "10.0.0.2", 8080, 1, true));

    assert(repo.list().length == 2);

    repo.remove("b1");
    assert(repo.list().length == 1);
    assert(repo.list()[0].id == "b2");

    // upsert: saving again with same id should replace
    repo.save(Backend("b2", "10.0.0.2", 9090, 1, true));
    assert(repo.list().length == 1);
    assert(repo.list()[0].port == 9090);
}
