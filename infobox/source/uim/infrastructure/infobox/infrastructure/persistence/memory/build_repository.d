module uim.infrastructure.infobox.infrastructure.persistence.memory.build_repository;

import core.sync.mutex : Mutex;
import uim.infrastructure.infobox.domain.entities.build : Build;
import uim.infrastructure.infobox.domain.ports.repositories.build : IBuildRepository;

class InMemoryBuildRepository : IBuildRepository {
    private Build[] builds;
    private Mutex mutex;

    this() {
        mutex = new Mutex;
    }

    override void save(in Build build) {
        synchronized (mutex) {
            builds ~= build;
        }
    }

    override void update(in Build build) {
        synchronized (mutex) {
            foreach (ref b; builds) {
                if (b.id == build.id) {
                    b = build;
                    return;
                }
            }
        }
    }

    override Build[] listByProject(string projectId) {
        synchronized (mutex) {
            Build[] result;
            foreach (b; builds) {
                if (b.projectId == projectId) {
                    result ~= b;
                }
            }
            return result;
        }
    }

    override Build* findById(string id) {
        synchronized (mutex) {
            foreach (ref b; builds) {
                if (b.id == id) {
                    return &b;
                }
            }
            return null;
        }
    }

    override uint nextBuildNumber(string projectId) {
        synchronized (mutex) {
            uint max = 0;
            foreach (b; builds) {
                if (b.projectId == projectId && b.buildNumber > max) {
                    max = b.buildNumber;
                }
            }
            return max + 1;
        }
    }
}

unittest {
    import uim.infrastructure.infobox.domain.entities.build : BuildStatus, BuildTrigger;

    auto repo = new InMemoryBuildRepository();
    assert(repo.nextBuildNumber("proj-1") == 1);

    repo.save(Build("b-1", "proj-1", 1, BuildStatus.queued, BuildTrigger.manual, "", "main", "user", 0, 0, "now", ""));
    assert(repo.nextBuildNumber("proj-1") == 2);
    assert(repo.listByProject("proj-1").length == 1);
    assert(repo.findById("b-1") !is null);
    assert(repo.findById("b-999") is null);
}
