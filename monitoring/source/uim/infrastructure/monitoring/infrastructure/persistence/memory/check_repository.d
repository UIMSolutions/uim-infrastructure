module monitoring_service.infrastructure.persistence.memory.check_repository;

import core.sync.mutex : Mutex;
import monitoring_service.domain.entities.check : Check;
import monitoring_service.domain.entities.check_result : CheckResult;
import monitoring_service.domain.ports.repositories.check : ICheckRepository;

class InMemoryCheckRepository : ICheckRepository {
    private Check[] checks;
    private CheckResult[] results;
    private Mutex mutex;

    this() {
        mutex = new Mutex;
    }

    override void save(in Check check) {
        synchronized (mutex) {
            foreach (i, ref c; checks) {
                if (c.id == check.id) {
                    checks[i] = check;
                    return;
                }
            }
            checks ~= check;
        }
    }

    override void remove(string id) {
        synchronized (mutex) {
            Check[] remaining;
            foreach (c; checks) {
                if (c.id != id) {
                    remaining ~= c;
                }
            }
            checks = remaining;
        }
    }

    override Check[] list() {
        synchronized (mutex) {
            return checks.dup;
        }
    }

    override Check* findById(string id) {
        synchronized (mutex) {
            foreach (ref c; checks) {
                if (c.id == id) {
                    auto copy = new Check(c.id, c.name, c.host, c.port, c.intervalSecs, c.active);
                    return copy;
                }
            }
            return null;
        }
    }

    override void saveResult(in CheckResult result) {
        synchronized (mutex) {
            results ~= result;
        }
    }

    override CheckResult[] listResults(string checkId) {
        synchronized (mutex) {
            CheckResult[] out_;
            foreach (r; results) {
                if (r.checkId == checkId) {
                    out_ ~= r;
                }
            }
            return out_;
        }
    }
}

unittest {
    auto repo = new InMemoryCheckRepository();
    repo.save(Check("c1", "api", "10.0.0.1", 8080, 30, true));
    repo.save(Check("c2", "db",  "10.0.0.2", 5432, 60, true));

    assert(repo.list().length == 2);

    repo.remove("c1");
    assert(repo.list().length == 1);
    assert(repo.list()[0].id == "c2");

    // upsert: saving again with same id should replace
    repo.save(Check("c2", "db", "10.0.0.2", 5433, 60, true));
    assert(repo.list().length == 1);
    assert(repo.list()[0].port == 5433);

    // results
    repo.saveResult(CheckResult("c2", true, 200, "ok", 1_000_000));
    repo.saveResult(CheckResult("c2", false, 503, "down", 1_000_060));
    assert(repo.listResults("c2").length == 2);
    assert(repo.listResults("c1").length == 0);
}
