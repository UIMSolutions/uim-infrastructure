module uim.infrastructure.jenkins.infrastructure.persistence.memory.build_repository;

import core.sync.mutex : Mutex;
import jenkins_service.domain.entities.build : Build;
import jenkins_service.domain.ports.build_repository : IBuildRepository;

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

    override Build[] listByPipeline(string pipelineId) {
        synchronized (mutex) {
            Build[] result;
            foreach (b; builds) {
                if (b.pipelineId == pipelineId) {
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

    override uint nextBuildNumber(string pipelineId) {
        synchronized (mutex) {
            uint max = 0;
            foreach (b; builds) {
                if (b.pipelineId == pipelineId && b.buildNumber > max) {
                    max = b.buildNumber;
                }
            }
            return max + 1;
        }
    }
}

unittest {
    import jenkins_service.domain.entities.build : BuildStatus;

    auto repo = new InMemoryBuildRepository();
    assert(repo.nextBuildNumber("p-1") == 1);

    repo.save(Build("b-1", "p-1", 1, BuildStatus.pending, [], "user", "now", ""));
    assert(repo.nextBuildNumber("p-1") == 2);
    assert(repo.listByPipeline("p-1").length == 1);
    assert(repo.findById("b-1") !is null);
    assert(repo.findById("b-999") is null);
}
