/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.waf.application.usecases.delete_rule;

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
