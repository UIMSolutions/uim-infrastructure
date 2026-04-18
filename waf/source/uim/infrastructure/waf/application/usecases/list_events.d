module uim.infrastructure.waf.application.use_cases.list_events;

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
