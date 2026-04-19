module uim.infrastructure.infobox.infrastructure.persistence.memory.secret_repository;

import core.sync.mutex : Mutex;
import uim.infrastructure.infobox.domain.entities.secret : Secret;
import uim.infrastructure.infobox.domain.ports.repositories.secret : ISecretRepository;

class InMemorySecretRepository : ISecretRepository {
    private Secret[] secrets;
    private Mutex mutex;

    this() {
        mutex = new Mutex;
    }

    override void save(in Secret secret) {
        synchronized (mutex) {
            secrets ~= secret;
        }
    }

    override Secret[] listByProject(string projectId) {
        synchronized (mutex) {
            Secret[] result;
            foreach (s; secrets) {
                if (s.projectId == projectId) {
                    result ~= s;
                }
            }
            return result;
        }
    }

    override Secret* findById(string id) {
        synchronized (mutex) {
            foreach (ref s; secrets) {
                if (s.id == id) {
                    return &s;
                }
            }
            return null;
        }
    }

    override Secret* findByName(string projectId, string name) {
        synchronized (mutex) {
            foreach (ref s; secrets) {
                if (s.projectId == projectId && s.name == name) {
                    return &s;
                }
            }
            return null;
        }
    }

    override void deleteById(string id) {
        synchronized (mutex) {
            Secret[] remaining;
            foreach (s; secrets) {
                if (s.id != id) {
                    remaining ~= s;
                }
            }
            secrets = remaining;
        }
    }
}

unittest {
    auto repo = new InMemorySecretRepository();
    repo.save(Secret("sec-1", "proj-1", "DB_PASS", "encrypted", "now"));

    assert(repo.listByProject("proj-1").length == 1);
    assert(repo.findById("sec-1") !is null);
    assert(repo.findByName("proj-1", "DB_PASS") !is null);
    assert(repo.findByName("proj-1", "MISSING") is null);

    repo.deleteById("sec-1");
    assert(repo.listByProject("proj-1").length == 0);
}
