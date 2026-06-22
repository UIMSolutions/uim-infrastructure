module uim.infrastructure.scim.infrastructure.persistence.memory.group_repository;

import core.sync.mutex : Mutex;
import std.string : toLower;
import uim.infrastructure.scim.domain.entities.group : ScimGroup;
import uim.infrastructure.scim.domain.ports.repositories.group : IGroupRepository;

class InMemoryGroupRepository : IGroupRepository {
    private ScimGroup[] groups;
    private Mutex mutex;

    this() {
        mutex = new Mutex;
    }

    override void save(ScimGroup group) {
        synchronized (mutex) {
            foreach (index, existing; groups) {
                if (existing.id == group.id) {
                    groups[index] = group;
                    return;
                }
            }
            groups ~= group;
        }
    }

    override ScimGroup[] list() {
        synchronized (mutex) {
            return groups.dup;
        }
    }

    override ScimGroup* findById(string id) {
        synchronized (mutex) {
            foreach (ref group; groups) {
                if (group.id == id) {
                    return clone(group);
                }
            }
            return null;
        }
    }

    override ScimGroup* findByDisplayName(string displayName) {
        synchronized (mutex) {
            foreach (ref group; groups) {
                if (toLower(group.displayName) == toLower(displayName)) {
                    return clone(group);
                }
            }
            return null;
        }
    }

    override void remove(string id) {
        synchronized (mutex) {
            ScimGroup[] remaining;
            foreach (group; groups) {
                if (group.id != id) {
                    remaining ~= group;
                }
            }
            groups = remaining;
        }
    }

    private ScimGroup* clone(ScimGroup group) {
        return new ScimGroup(
            group.id,
            group.externalId,
            group.displayName,
            group.memberIds.dup,
            group.createdAt,
            group.lastModifiedAt,
            group.versionTag
        );
    }
}

unittest {
    import std.datetime : Clock;

    auto repo = new InMemoryGroupRepository();
    repo.save(ScimGroup("g1", "sales", "Sales", ["u1"], Clock.currTime(), Clock.currTime(), "W/\"v1\""));
    assert(repo.list().length == 1);
    assert(repo.findById("g1") !is null);
    assert(repo.findByDisplayName("sales") !is null);
    repo.remove("g1");
    assert(repo.findById("g1") is null);
}
