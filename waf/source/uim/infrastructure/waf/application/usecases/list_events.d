/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.waf.application.usecases.list_events;

import uim.infrastructure.waf.domain.entities.waf_event : WafEvent;
import uim.infrastructure.waf.domain.ports.repositories.waf_event : IWafEventRepository;

class ListEventsUseCase {
    private IWafEventRepository repository;

    this(IWafEventRepository repository) {
        this.repository = repository;
    }

    WafEvent[] execute() {
        return repository.list();
    }
}
