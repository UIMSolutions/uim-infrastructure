module uim.infrastructure.waf.domain.ports.repositories.waf_event;

import uim.infrastructure.waf.domain.entities.waf_event : WafEvent;

interface IWafEventRepository {
    void save(in WafEvent event);
    WafEvent[] list();
    WafEvent[] findBySourceIp(string sourceIp);
    WafEvent[] findByRuleId(string ruleId);
}
