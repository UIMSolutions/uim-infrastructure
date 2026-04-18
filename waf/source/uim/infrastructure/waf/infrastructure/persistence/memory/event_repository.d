module uim.infrastructure.waf.infrastructure.persistence.memory.event_repository;

import core.sync.mutex : Mutex;
import waf_service.domain.entities.waf_event : WafEvent;
import waf_service.domain.ports.repositories.waf_event : IWafEventRepository;

class InMemoryEventRepository : IWafEventRepository {
    private WafEvent[] events;
    private Mutex mutex;

    this() {
        mutex = new Mutex;
    }

    override void save(in WafEvent event) {
        synchronized (mutex) {
            events ~= event;
        }
    }

    override WafEvent[] list() {
        synchronized (mutex) {
            return events.dup;
        }
    }

    override WafEvent[] findBySourceIp(string sourceIp) {
        synchronized (mutex) {
            WafEvent[] result;
            foreach (event; events) {
                if (event.sourceIp == sourceIp)
                    result ~= event;
            }
            return result;
        }
    }

    override WafEvent[] findByRuleId(string ruleId) {
        synchronized (mutex) {
            WafEvent[] result;
            foreach (event; events) {
                if (event.ruleId == ruleId)
                    result ~= event;
            }
            return result;
        }
    }
}

unittest {
    import waf_service.domain.entities.waf_rule : RuleAction;

    auto repo = new InMemoryEventRepository();
    auto event = WafEvent("e1", "r1", "test", "192.168.1.1", "GET", "/test", RuleAction.BLOCK, "pattern", "detail", "2026-04-18T00:00:00Z");
    repo.save(event);

    assert(repo.list().length == 1);
    assert(repo.findBySourceIp("192.168.1.1").length == 1);
    assert(repo.findByRuleId("r1").length == 1);
    assert(repo.findBySourceIp("10.0.0.1").length == 0);
}
