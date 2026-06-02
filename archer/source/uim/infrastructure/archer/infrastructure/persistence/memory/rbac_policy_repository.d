module uim.infrastructure.archer.infrastructure.persistence.memory.rbac_policy_repository;

import core.sync.mutex : Mutex;
import uim.infrastructure.archer.domain.entities.rbac_policy : ArcherRbacPolicy;
import uim.infrastructure.archer.domain.ports.repositories.rbac_policy : IRbacPolicyRepository;

class InMemoryRbacPolicyRepository : IRbacPolicyRepository {
    private ArcherRbacPolicy[] policies;
    private Mutex mutex;

    this() {
        mutex = new Mutex;
    }

    override void save(in ArcherRbacPolicy policy) {
        synchronized (mutex) {
            foreach (i, ref existing; policies) {
                if (existing.id == policy.id) {
                    policies[i] = copyPolicy(policy);
                    return;
                }
            }
            policies ~= copyPolicy(policy);
        }
    }

    override ArcherRbacPolicy[] list() {
        synchronized (mutex) {
            return policies.dup;
        }
    }

    override ArcherRbacPolicy* findById(string id) {
        synchronized (mutex) {
            foreach (ref policy; policies) {
                if (policy.id == id) return &policy;
            }
            return null;
        }
    }

    override void remove(string id) {
        synchronized (mutex) {
            ArcherRbacPolicy[] filtered;
            foreach (policy; policies) {
                if (policy.id != id) filtered ~= policy;
            }
            policies = filtered;
        }
    }

    private ArcherRbacPolicy copyPolicy(in ArcherRbacPolicy src) {
        ArcherRbacPolicy dst;
        dst.id = src.id;
        dst.targetType = src.targetType;
        dst.target = src.target;
        dst.serviceId = src.serviceId;
        dst.createdAt = src.createdAt;
        dst.updatedAt = src.updatedAt;
        dst.projectId = src.projectId;
        return dst;
    }
}
