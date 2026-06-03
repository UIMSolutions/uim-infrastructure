module uim.infrastructure.manila.infrastructure.persistence.memory.snapshot_repository;

import core.sync.mutex : Mutex;
import uim.infrastructure.manila.domain.entities.share_snapshot : ShareSnapshot;
import uim.infrastructure.manila.domain.ports.repositories.snapshot : ISnapshotRepository;

class InMemorySnapshotRepository : ISnapshotRepository {
    private ShareSnapshot[] snapshots;
    private Mutex mutex;

    this() {
        mutex = new Mutex;
    }

    override void save(ShareSnapshot snapshot) {
        synchronized (mutex) {
            foreach (index, existing; snapshots) {
                if (existing.id == snapshot.id) {
                    snapshots[index] = snapshot;
                    return;
                }
            }
            snapshots ~= snapshot;
        }
    }

    override ShareSnapshot[] list() {
        synchronized (mutex) {
            return snapshots.dup;
        }
    }

    override ShareSnapshot[] listByProject(string projectId) {
        synchronized (mutex) {
            ShareSnapshot[] result;
            foreach (snapshot; snapshots) {
                if (snapshot.projectId == projectId) {
                    result ~= snapshot;
                }
            }
            return result;
        }
    }

    override void removeByShareId(string shareId) {
        synchronized (mutex) {
            ShareSnapshot[] remaining;
            foreach (snapshot; snapshots) {
                if (snapshot.shareId != shareId) {
                    remaining ~= snapshot;
                }
            }
            snapshots = remaining;
        }
    }
}

unittest {
    import std.datetime : Clock;
    import uim.infrastructure.manila.domain.entities.share_snapshot : ShareSnapshot, SnapshotStatus;

    auto repository = new InMemorySnapshotRepository();
    repository.save(ShareSnapshot("s1", "share-1", "p1", "snap", "", 10, SnapshotStatus.available, Clock.currTime()));
    repository.save(ShareSnapshot("s2", "share-2", "p1", "snap-2", "", 12, SnapshotStatus.available, Clock.currTime()));

    assert(repository.list().length == 2);
    assert(repository.listByProject("p1").length == 2);
    repository.removeByShareId("share-1");
    assert(repository.list().length == 1);
}