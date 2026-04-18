module uim.infrastructure.waf.application.use_cases.delete_rule;

import uim.infrastructure.waf.domain.ports.repositories.waf_rule : IWafRuleRepository;

class DeleteRuleUseCase {
    private IWafRuleRepository repository;

    this(IWafRuleRepository repository) {
        this.repository = repository;
    }

    void execute(string id) {
        if (id.length == 0)
            throw new Exception("rule id must not be empty");
        repository.remove(id);
    }
}
