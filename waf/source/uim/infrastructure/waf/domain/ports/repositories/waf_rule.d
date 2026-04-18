module uim.infrastructure.waf.domain.ports.repositories.waf_rule;

import waf_service.domain.entities.waf_rule : WafRule;

interface IWafRuleRepository {
    void save(in WafRule rule);
    void remove(string id);
    WafRule[] list();
    WafRule* findById(string id);
    WafRule[] findEnabled();
}
