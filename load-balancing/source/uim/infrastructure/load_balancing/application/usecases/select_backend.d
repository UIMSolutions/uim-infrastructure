module lb_service.application.usecases.select_backend;

import lb_service.domain.entities.backend : Backend;
import lb_service.domain.ports.repositories.backend : IBackendRepository;
import lb_service.domain.ports.selectors.backend : IBackendSelector;

class SelectBackendUseCase {
    private IBackendRepository repository;
    private IBackendSelector selector;

    this(IBackendRepository repository, IBackendSelector selector) {
        this.repository = repository;
        this.selector = selector;
    }

    /// Returns a pointer to the chosen backend, or null when the pool is empty
    /// or no backend is healthy.
    Backend* execute() {
        auto backends = repository.list();
        return selector.select(backends);
    }
}
