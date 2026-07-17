module uim.infrastructure.ansible.infrastructure.persistence.memory.playbook_repository;

import core.sync.mutex : Mutex;
import uim.infrastructure.ansible.domain.entities.playbook : Playbook, Play;
import uim.infrastructure.ansible.domain.ports.repositories.playbook : IPlaybookRepository;

class InMemoryPlaybookRepository : IPlaybookRepository {
    private Playbook[] playbooks;
    private Mutex mutex;

    this() {
        mutex = new Mutex;
    }

    private Playbook copyPlaybook(in Playbook pb) {
        Play[] plays;
        foreach (p; pb.plays) {
            string[string] pv;
            foreach (k, v; p.vars)
                pv[k] = v;
            plays ~= Play(p.name, p.targetGroup, p.taskIds.dup, pv, p.become);
        }
        return Playbook(pb.id, pb.name, pb.description, plays);
    }

    override void save(in Playbook playbook) {
        synchronized (mutex) {
            auto copy = copyPlaybook(playbook);
            foreach (i, ref existing; playbooks) {
                if (existing.id == playbook.id) {
                    playbooks[i] = copy;
                    return;
                }
            }
            playbooks ~= copy;
        }
    }

    override void remove(string id) {
        synchronized (mutex) {
            Playbook[] filtered;
            foreach (pb; playbooks) {
                if (pb.id != id)
                    filtered ~= pb;
            }
            playbooks = filtered;
        }
    }

    override Playbook[] list() {
        synchronized (mutex) {
            return playbooks.dup;
        }
    }

    override Playbook* findById(string id) {
        synchronized (mutex) {
            foreach (ref pb; playbooks) {
                if (pb.id == id)
                    return &pb;
            }
            return null;
        }
    }
}

unittest {
    auto repo = new InMemoryPlaybookRepository();
    auto pb = Playbook("pb1", "Deploy", "Deploy app", [
        Play("Install", "web", ["t1"], null, true)
    ]);
    repo.save(pb);

    assert(repo.list().length == 1);
    assert(repo.findById("pb1") !is null);
    assert(repo.findById("pb1").name == "Deploy");

    repo.remove("pb1");
    assert(repo.list().length == 0);
}
