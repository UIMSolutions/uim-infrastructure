module uim.infrastructure.waf.infrastructure.persistence.memory.rule_repository;

import core.sync.mutex : Mutex;
import waf_service.domain.entities.waf_rule : WafRule;
import waf_service.domain.ports.repositories.waf_rule : IWafRuleRepository;

class InMemoryRuleRepository : IWafRuleRepository {
    private WafRule[] rules;
    private Mutex mutex;

    this() {
        mutex = new Mutex;
    }

    override void save(in WafRule rule) {
        synchronized (mutex) {
            foreach (i, ref existing; rules) {
                if (existing.id == rule.id) {
                    rules[i] = rule;
                    return;
                }
            }
            rules ~= rule;
        }
    }

    override void remove(string id) {
        synchronized (mutex) {
            WafRule[] filtered;
            foreach (rule; rules) {
                if (rule.id != id)
                    filtered ~= rule;
            }
            rules = filtered;
        }
    }

    override WafRule[] list() {
        synchronized (mutex) {
            return rules.dup;
        }
    }

    override WafRule* findById(string id) {
        synchronized (mutex) {
            foreach (ref rule; rules) {
                if (rule.id == id)
                    return &rule;
            }
            return null;
        }
    }

    override WafRule[] findEnabled() {
        synchronized (mutex) {
            WafRule[] result;
            foreach (rule; rules) {
                if (rule.enabled)
                    result ~= rule;
            }
            return result;
        }
    }
}

unittest {
    import waf_service.domain.entities.waf_rule : RuleAction, RuleType;

    auto repo = new InMemoryRuleRepository();
    auto rule = WafRule("r1", "Block SQLi", `union\s+select`, RuleAction.BLOCK, RuleType.SQL_INJECTION, 1, true, "test");
    repo.save(rule);

    assert(repo.list().length == 1);
    assert(repo.findById("r1") !is null);
    assert(repo.findById("r1").name == "Block SQLi");
    assert(repo.findEnabled().length == 1);

    repo.remove("r1");
    assert(repo.list().length == 0);
}
