module vpc_service.infrastructure.persistence.memory.vpc_repository;

import core.sync.mutex : Mutex;
import vpc_service.domain.entities.vpc : Vpc;
import vpc_service.domain.ports.repositories.vpc : IVpcRepository;

class InMemoryVpcRepository : IVpcRepository {
    private Vpc[] vpcs;
    private Mutex mutex;

    this() {
        mutex = new Mutex;
    }

    override void save(in Vpc vpc) {
        synchronized (mutex) {
            foreach (i, ref v; vpcs) {
                if (v.id == vpc.id) {
                    vpcs[i] = vpc;
                    return;
                }
            }
            vpcs ~= vpc;
        }
    }

    override void remove(string id) {
        synchronized (mutex) {
            Vpc[] remaining;
            foreach (v; vpcs) {
                if (v.id != id) {
                    remaining ~= v;
                }
            }
            vpcs = remaining;
        }
    }

    override Vpc[] list() {
        synchronized (mutex) {
            return vpcs.dup;
        }
    }

    override Vpc* findById(string id) {
        synchronized (mutex) {
            foreach (ref v; vpcs) {
                if (v.id == id) {
                    auto copy = new Vpc(v.id, v.name, v.cidr, v.region, v.state);
                    return copy;
                }
            }
            return null;
        }
    }
}

unittest {
    import vpc_service.domain.entities.vpc : VpcState;

    auto repo = new InMemoryVpcRepository();
    repo.save(Vpc("vpc-001", "production", "10.0.0.0/16", "eu-west-1", VpcState.available));
    repo.save(Vpc("vpc-002", "staging", "10.1.0.0/16", "eu-west-1", VpcState.available));

    assert(repo.list().length == 2);

    repo.remove("vpc-001");
    assert(repo.list().length == 1);
    assert(repo.list()[0].id == "vpc-002");

    // upsert: saving again with the same id should replace
    repo.save(Vpc("vpc-002", "staging-updated", "10.1.0.0/16", "eu-west-1", VpcState.available));
    assert(repo.list().length == 1);
    assert(repo.list()[0].name == "staging-updated");

    auto found = repo.findById("vpc-002");
    assert(found !is null);
    assert(found.name == "staging-updated");

    assert(repo.findById("vpc-999") is null);
}
