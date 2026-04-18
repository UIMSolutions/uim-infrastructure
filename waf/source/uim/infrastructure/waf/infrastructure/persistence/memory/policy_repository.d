module uim.infrastructure.waf.infrastructure.persistence.memory.policy_repository;

import core.sync.mutex : Mutex;
import waf_service.domain.entities.waf_policy : WafPolicy;
import waf_service.domain.ports.repositories.waf_policy : IWafPolicyRepository;

class InMemoryPolicyRepository : IWafPolicyRepository {
    private WafPolicy[] policies;
    private Mutex mutex;

    this() {
        mutex = new Mutex;
    }

    override void save(in WafPolicy policy) {
        synchronized (mutex) {
            foreach (i, ref existing; policies) {
                if (existing.id == policy.id) {
                    policies[i] = policy;
                    return;
                }
            }
            policies ~= policy;
        }
    }

    override void remove(string id) {
        synchronized (mutex) {
            WafPolicy[] filtered;
            foreach (policy; policies) {
                if (policy.id != id)
                    filtered ~= policy;
            }
            policies = filtered;
        }
    }

    override WafPolicy[] list() {
        synchronized (mutex) {
            return policies.dup;
        }
    }

    override WafPolicy* findById(string id) {
        synchronized (mutex) {
            foreach (ref policy; policies) {
                if (policy.id == id)
                    return &policy;
            }
            return null;
        }
    }
}

unittest {
    import waf_service.domain.entities.waf_policy : PolicyMode;

    auto repo = new InMemoryPolicyRepository();
    auto policy = WafPolicy("p1", "Default", ["r1"], PolicyMode.PREVENTION, "test");
    repo.save(policy);

    assert(repo.list().length == 1);
    assert(repo.findById("p1") !is null);
    assert(repo.findById("p1").name == "Default");

    repo.remove("p1");
    assert(repo.list().length == 0);
}
