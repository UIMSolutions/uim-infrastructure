module waf_service.application.use_cases.delete_policy;

import waf_service.domain.ports.repositories.waf_policy : IWafPolicyRepository;

class DeletePolicyUseCase {
    private IWafPolicyRepository repository;

    this(IWafPolicyRepository repository) {
        this.repository = repository;
    }

    void execute(string id) {
        if (id.length == 0)
            throw new Exception("policy id must not be empty");
        repository.remove(id);
    }
}
