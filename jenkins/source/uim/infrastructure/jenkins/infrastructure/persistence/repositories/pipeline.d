module uim.infrastructure.jenkins.infrastructure.persistence.memory.pipeline_repository;

import core.sync.mutex : Mutex;
import jenkins_service.domain.entities.pipeline : Pipeline;
import jenkins_service.domain.ports.pipeline_repository : IPipelineRepository;

class InMemoryPipelineRepository : IPipelineRepository {
    private Pipeline[] pipelines;
    private Mutex mutex;

    this() {
        mutex = new Mutex;
    }

    override void save(in Pipeline pipeline) {
        synchronized (mutex) {
            pipelines ~= pipeline;
        }
    }

    override Pipeline[] list() {
        synchronized (mutex) {
            return pipelines.dup;
        }
    }

    override Pipeline* findById(string id) {
        synchronized (mutex) {
            foreach (ref p; pipelines) {
                if (p.id == id) {
                    return &p;
                }
            }
            return null;
        }
    }

    override void deleteById(string id) {
        synchronized (mutex) {
            Pipeline[] remaining;
            foreach (p; pipelines) {
                if (p.id != id) {
                    remaining ~= p;
                }
            }
            pipelines = remaining;
        }
    }
}

unittest {
    import jenkins_service.domain.entities.pipeline : PipelineStatus, Stage;

    auto repo = new InMemoryPipelineRepository();
    auto pipeline = Pipeline("p-1", "test", "desc", "repo", "main", PipelineStatus.active,
        [Stage("build", "dub build", 300)], "2026-04-19T00:00:00Z");

    repo.save(pipeline);
    assert(repo.list().length == 1);
    assert(repo.findById("p-1") !is null);
    assert(repo.findById("p-999") is null);

    repo.deleteById("p-1");
    assert(repo.list().length == 0);
}
