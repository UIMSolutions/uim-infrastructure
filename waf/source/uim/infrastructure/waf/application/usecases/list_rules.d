module waf_service.application.use_cases.list_rules;

import waf_service.domain.entities.waf_rule : WafRule;
import waf_service.domain.ports.repositories.waf_rule : IWafRuleRepository;

class ListRulesUseCase {
    private IWafRuleRepository repository;

    this(IWafRuleRepository repository) {
        this.repository = repository;
    }

    WafRule[] execute() {
        return repository.list();
    }
}
