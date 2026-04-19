module uim.infrastructure.infobox.infrastructure.persistence.memory.job_repository;

import core.sync.mutex : Mutex;
import uim.infrastructure.infobox.domain.entities.job : Job;
import uim.infrastructure.infobox.domain.ports.repositories.job : IJobRepository;

class InMemoryJobRepository : IJobRepository {
    private Job[] jobs;
    private Mutex mutex;

    this() {
        mutex = new Mutex;
    }

    override void save(in Job job) {
        synchronized (mutex) {
            jobs ~= job;
        }
    }

    override void update(in Job job) {
        synchronized (mutex) {
            foreach (ref j; jobs) {
                if (j.id == job.id) {
                    j = job;
                    return;
                }
            }
        }
    }

    override Job[] listByBuild(string buildId) {
        synchronized (mutex) {
            Job[] result;
            foreach (j; jobs) {
                if (j.buildId == buildId) {
                    result ~= j;
                }
            }
            return result;
        }
    }

    override Job* findById(string id) {
        synchronized (mutex) {
            foreach (ref j; jobs) {
                if (j.id == id) {
                    return &j;
                }
            }
            return null;
        }
    }

    override Job[] findByName(string buildId, string jobName) {
        synchronized (mutex) {
            Job[] result;
            foreach (j; jobs) {
                if (j.buildId == buildId && j.name == jobName) {
                    result ~= j;
                }
            }
            return result;
        }
    }
}

unittest {
    import uim.infrastructure.infobox.domain.entities.job : JobType, JobStatus, ResourceLimits;

    auto repo = new InMemoryJobRepository();
    auto job = Job("j-1", "proj-1", "b-1", "compile", JobType.docker, JobStatus.queued,
        "Dockerfile", "", "dub build", ".", ResourceLimits(1000, 2048, 600), [], [], "", 0, "", "");

    repo.save(job);
    assert(repo.listByBuild("b-1").length == 1);
    assert(repo.findById("j-1") !is null);
    assert(repo.findByName("b-1", "compile").length == 1);
}
