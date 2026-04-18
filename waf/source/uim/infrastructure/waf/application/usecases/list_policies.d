module uim.infrastructure.waf.application.use_cases.list_policies;

import uim.infrastructure.waf.domain.entities.waf_policy : WafPolicy;
import uim.infrastructure.waf.domain.ports.repositories.waf_policy : IWafPolicyRepository;

class ListPoliciesUseCase {
    private IWafPolicyRepository repository;

    this(IWafPolicyRepository repository) {
        this.repository = repository;
    }

    WafPolicy[] execute() {
        return repository.list();
    }
}
