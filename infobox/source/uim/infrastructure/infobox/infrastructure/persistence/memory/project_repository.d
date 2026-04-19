module uim.infrastructure.infobox.infrastructure.persistence.memory.project_repository;

import core.sync.mutex : Mutex;
import uim.infrastructure.infobox.domain.entities.project : Project;
import uim.infrastructure.infobox.domain.ports.repositories.project : IProjectRepository;

class InMemoryProjectRepository : IProjectRepository {
    private Project[] projects;
    private Mutex mutex;

    this() {
        mutex = new Mutex;
    }

    override void save(in Project project) {
        synchronized (mutex) {
            projects ~= project;
        }
    }

    override void update(in Project project) {
        synchronized (mutex) {
            foreach (ref p; projects) {
                if (p.id == project.id) {
                    p = project;
                    return;
                }
            }
        }
    }

    override Project[] list() {
        synchronized (mutex) {
            return projects.dup;
        }
    }

    override Project* findById(string id) {
        synchronized (mutex) {
            foreach (ref p; projects) {
                if (p.id == id) {
                    return &p;
                }
            }
            return null;
        }
    }

    override void deleteById(string id) {
        synchronized (mutex) {
            Project[] remaining;
            foreach (p; projects) {
                if (p.id != id) {
                    remaining ~= p;
                }
            }
            projects = remaining;
        }
    }
}

unittest {
    import uim.infrastructure.infobox.domain.entities.project : ProjectStatus;

    auto repo = new InMemoryProjectRepository();
    auto project = Project("proj-1", "test", "desc", "repo", "main", ProjectStatus.active, [], "now", "now");

    repo.save(project);
    assert(repo.list().length == 1);
    assert(repo.findById("proj-1") !is null);
    assert(repo.findById("proj-999") is null);

    repo.deleteById("proj-1");
    assert(repo.list().length == 0);
}
