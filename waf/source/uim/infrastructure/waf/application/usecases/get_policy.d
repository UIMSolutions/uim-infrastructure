module waf_service.application.use_cases.get_policy;

import waf_service.domain.entities.waf_policy : WafPolicy;
import waf_service.domain.ports.repositories.waf_policy : IWafPolicyRepository;

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
