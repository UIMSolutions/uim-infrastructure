module waf_service.application.use_cases.list_events;

import waf_service.domain.entities.waf_event : WafEvent;
import waf_service.domain.ports.repositories.waf_event : IWafEventRepository;

class ListEventsUseCase {
    private IWafEventRepository repository;

    this(IWafEventRepository repository) {
        this.repository = repository;
    }

    WafEvent[] execute() {
        return repository.list();
    }
}
