module uim.infrastructure.waf.domain.ports.repositories.waf_policy;

import waf_service.domain.entities.waf_policy : WafPolicy;

interface IWafPolicyRepository {
    void save(in WafPolicy policy);
    void remove(string id);
    WafPolicy[] list();
    WafPolicy* findById(string id);
}
