module uim.infrastructure.ansible.infrastructure.persistence.memory.host_repository;

import core.sync.mutex : Mutex;
import uim.infrastructure.ansible.domain.entities.host : Host;
import uim.infrastructure.ansible.domain.ports.repositories.host : IHostRepository;

class InMemoryHostRepository : IHostRepository {
    private Host[] hosts;
    private Mutex mutex;

    this() {
        mutex = new Mutex;
    }

    private Host copyHost(in Host h) {
        string[string] vars;
        foreach (k, v; h.variables)
            vars[k] = v;
        return Host(h.id, h.hostname, h.ipAddress, h.port, h.user, h.status, vars);
    }

    override void save(in Host host) {
        synchronized (mutex) {
            auto copy = copyHost(host);
            foreach (i, ref existing; hosts) {
                if (existing.id == host.id) {
                    hosts[i] = copy;
                    return;
                }
            }
            hosts ~= copy;
        }
    }

    override void remove(string id) {
        synchronized (mutex) {
            Host[] filtered;
            foreach (h; hosts) {
                if (h.id != id)
                    filtered ~= h;
            }
            hosts = filtered;
        }
    }

    override Host[] list() {
        synchronized (mutex) {
            return hosts.dup;
        }
    }

    override Host* findById(string id) {
        synchronized (mutex) {
            foreach (ref h; hosts) {
                if (h.id == id)
                    return &h;
            }
            return null;
        }
    }

    override Host[] findByGroup(string groupName) {
        return list();
    }
}

unittest {
    import uim.infrastructure.ansible.domain.entities.host : HostStatus;

    auto repo = new InMemoryHostRepository();
    auto host = Host("h1", "web01", "10.0.0.1", 22, "root", HostStatus.REACHABLE, null);
    repo.save(host);

    assert(repo.list().length == 1);
    assert(repo.findById("h1") !is null);
    assert(repo.findById("h1").hostname == "web01");

    repo.remove("h1");
    assert(repo.list().length == 0);
}
