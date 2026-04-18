module waf_service.application.use_cases.list_policies;

import waf_service.domain.entities.waf_policy : WafPolicy;
import waf_service.domain.ports.repositories.waf_policy : IWafPolicyRepository;

class ListPoliciesUseCase {
    private IWafPolicyRepository repository;

    this(IWafPolicyRepository repository) {
        this.repository = repository;
    }

    WafPolicy[] execute() {
        return repository.list();
    }
}
