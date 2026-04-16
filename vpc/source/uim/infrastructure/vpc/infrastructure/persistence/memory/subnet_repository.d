module vpc_service.infrastructure.persistence.memory.subnet_repository;

import core.sync.mutex : Mutex;
import vpc_service.domain.entities.subnet : Subnet;
import vpc_service.domain.ports.repositories.subnet : ISubnetRepository;

class InMemorySubnetRepository : ISubnetRepository {
    private Subnet[] subnets;
    private Mutex mutex;

    this() {
        mutex = new Mutex;
    }

    override void save(in Subnet subnet) {
        synchronized (mutex) {
            foreach (i, ref s; subnets) {
                if (s.id == subnet.id) {
                    subnets[i] = subnet;
                    return;
                }
            }
            subnets ~= subnet;
        }
    }

    override void remove(string id) {
        synchronized (mutex) {
            Subnet[] remaining;
            foreach (s; subnets) {
                if (s.id != id) {
                    remaining ~= s;
                }
            }
            subnets = remaining;
        }
    }

    override Subnet[] list() {
        synchronized (mutex) {
            return subnets.dup;
        }
    }

    override Subnet[] listByVpc(string vpcId) {
        synchronized (mutex) {
            Subnet[] result;
            foreach (s; subnets) {
                if (s.vpcId == vpcId) {
                    result ~= s;
                }
            }
            return result;
        }
    }

    override Subnet* findById(string id) {
        synchronized (mutex) {
            foreach (ref s; subnets) {
                if (s.id == id) {
                    auto copy = new Subnet(s.id, s.vpcId, s.name, s.cidr, s.availabilityZone, s.state);
                    return copy;
                }
            }
            return null;
        }
    }
}

unittest {
    import vpc_service.domain.entities.subnet : SubnetState;

    auto repo = new InMemorySubnetRepository();
    repo.save(Subnet("subnet-001", "vpc-001", "public-a", "10.0.1.0/24", "eu-west-1a", SubnetState.available));
    repo.save(Subnet("subnet-002", "vpc-001", "private-a", "10.0.2.0/24", "eu-west-1a", SubnetState.available));
    repo.save(Subnet("subnet-003", "vpc-002", "public-b", "10.1.1.0/24", "eu-west-1b", SubnetState.available));

    assert(repo.list().length == 3);

    auto byVpc = repo.listByVpc("vpc-001");
    assert(byVpc.length == 2);

    repo.remove("subnet-001");
    assert(repo.list().length == 2);
    assert(repo.listByVpc("vpc-001").length == 1);

    auto found = repo.findById("subnet-002");
    assert(found !is null);
    assert(found.cidr == "10.0.2.0/24");

    assert(repo.findById("subnet-999") is null);
}
