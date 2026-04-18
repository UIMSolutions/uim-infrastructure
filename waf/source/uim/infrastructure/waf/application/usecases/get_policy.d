module uim.infrastructure.waf.application.use_cases.get_policy;

import uim.infrastructure.waf.domain.entities.waf_policy : WafPolicy;
import uim.infrastructure.waf.domain.ports.repositories.waf_policy : IWafPolicyRepository;

class GetPolicyUseCase {
    private IWafPolicyRepository repository;

    this(IWafPolicyRepository repository) {
        this.repository = repository;
    }

    WafPolicy* execute(string id) {
        if (id.length == 0)
            throw new Exception("policy id must not be empty");
        return repository.findById(id);
    }
}
