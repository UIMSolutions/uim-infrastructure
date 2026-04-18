module uim.infrastructure.waf.application.use_cases.list_rules;

import uim.infrastructure.waf.domain.entities.waf_rule : WafRule;
import uim.infrastructure.waf.domain.ports.repositories.waf_rule : IWafRuleRepository;

class ListRulesUseCase {
    private IWafRuleRepository repository;

    this(IWafRuleRepository repository) {
        this.repository = repository;
    }

    WafRule[] execute() {
        return repository.list();
    }
}
