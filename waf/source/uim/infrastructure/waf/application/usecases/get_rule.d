module uim.infrastructure.waf.application.use_cases.get_rule;

import uim.infrastructure.waf.domain.entities.waf_rule : WafRule;
import uim.infrastructure.waf.domain.ports.repositories.waf_rule : IWafRuleRepository;

class GetRuleUseCase {
    private IWafRuleRepository repository;

    this(IWafRuleRepository repository) {
        this.repository = repository;
    }

    WafRule* execute(string id) {
        if (id.length == 0)
            throw new Exception("rule id must not be empty");
        return repository.findById(id);
    }
}
