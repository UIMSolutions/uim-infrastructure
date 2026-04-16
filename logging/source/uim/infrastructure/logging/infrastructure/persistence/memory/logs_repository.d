module log_service.infrastructure.persistence.memory.logs_repository;

import core.sync.mutex : Mutex;
import log_service.domain.entities.log_entry : LogEntry, LogLevel;
import log_service.domain.ports.repositories.logs : ILogsRepository;

class InMemoryLogsRepository : ILogsRepository {
    private LogEntry[] entries;
    private Mutex mutex;

    this() {
        mutex = new Mutex;
    }

    override void save(in LogEntry entry) {
        synchronized (mutex) {
            entries ~= entry;
        }
    }

    override LogEntry[] list() {
        synchronized (mutex) {
            return entries.dup;
        }
    }

    override LogEntry[] findByService(string service) {
        synchronized (mutex) {
            LogEntry[] result;
            foreach (entry; entries) {
                if (entry.service == service) {
                    result ~= entry;
                }
            }
            return result;
        }
    }

    override LogEntry[] findByServiceAndLevel(string service, LogLevel level) {
        synchronized (mutex) {
            LogEntry[] result;
            foreach (entry; entries) {
                if (entry.service == service && entry.level == level) {
                    result ~= entry;
                }
            }
            return result;
        }
    }
}

unittest {
    auto repo = new InMemoryLogsRepository();
    repo.save(LogEntry("1", LogLevel.INFO,  "started", "svc-a", "2026-01-01T00:00:00Z"));
    repo.save(LogEntry("2", LogLevel.ERROR, "failed",  "svc-a", "2026-01-01T00:01:00Z"));
    repo.save(LogEntry("3", LogLevel.INFO,  "started", "svc-b", "2026-01-01T00:02:00Z"));

    assert(repo.list().length == 3);

    auto bySvc = repo.findByService("svc-a");
    assert(bySvc.length == 2);

    auto bySvcAndLevel = repo.findByServiceAndLevel("svc-a", LogLevel.ERROR);
    assert(bySvcAndLevel.length == 1);
    assert(bySvcAndLevel[0].message == "failed");

    assert(repo.findByService("svc-b").length == 1);
    assert(repo.findByServiceAndLevel("svc-b", LogLevel.ERROR).length == 0);
}
