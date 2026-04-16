module lb_service.application.usecases.list_backends;

import lb_service.domain.entities.backend : Backend;
import lb_service.domain.ports.repositories.backend : IBackendRepository;

class ListBackendsUseCase {
    private IBackendRepository repository;

    this(IBackendRepository repository) {
        this.repository = repository;
    }

    Backend[] execute() {
        return repository.list();
    }
}
