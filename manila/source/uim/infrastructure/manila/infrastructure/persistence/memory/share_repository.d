module uim.infrastructure.manila.infrastructure.persistence.memory.share_repository;

import core.sync.mutex : Mutex;
import uim.infrastructure.manila.domain.entities.share : Share;
import uim.infrastructure.manila.domain.ports.repositories.share : IShareRepository;

class InMemoryShareRepository : IShareRepository {
    private Share[] shares;
    private Mutex mutex;

    this() {
        mutex = new Mutex;
    }

    override void save(Share share) {
        synchronized (mutex) {
            foreach (index, existing; shares) {
                if (existing.id == share.id) {
                    shares[index] = share;
                    return;
                }
            }
            shares ~= share;
        }
    }

    override Share[] list() {
        synchronized (mutex) {
            return shares.dup;
        }
    }

    override Share[] listByProject(string projectId) {
        synchronized (mutex) {
            Share[] result;
            foreach (share; shares) {
                if (share.projectId == projectId) {
                    result ~= share;
                }
            }
            return result;
        }
    }

    override Share* findById(string id) {
        synchronized (mutex) {
            foreach (ref share; shares) {
                if (share.id == id) {
                    return new Share(
                        share.id,
                        share.projectId,
                        share.name,
                        share.description,
                        share.sizeGiB,
                        share.protocol,
                        share.shareTypeId,
                        share.availabilityZone,
                        share.status,
                        share.exportLocations.dup,
                        share.createdAt
                    );
                }
            }
            return null;
        }
    }

    override void remove(string id) {
        synchronized (mutex) {
            Share[] remaining;
            foreach (share; shares) {
                if (share.id != id) {
                    remaining ~= share;
                }
            }
            shares = remaining;
        }
    }
}

unittest {
    import std.datetime : Clock;
    import uim.infrastructure.manila.domain.entities.share : Share, ShareStatus;
    import uim.infrastructure.manila.domain.entities.share_type : ShareProtocol;

    auto repository = new InMemoryShareRepository();
    repository.save(Share("1", "p1", "team", "", 10, ShareProtocol.nfs, "gold", "zone-a", ShareStatus.available, ["nfs://a"], Clock.currTime()));
    repository.save(Share("2", "p2", "ops", "", 20, ShareProtocol.cifs, "silver", "zone-b", ShareStatus.available, ["//b"], Clock.currTime()));

    assert(repository.list().length == 2);
    assert(repository.listByProject("p1").length == 1);
    assert(repository.findById("1") !is null);
    repository.remove("1");
    assert(repository.findById("1") is null);
}