module monitoring_service.application.usecases.list_checks;

import monitoring_service.domain.entities.check : Check;
import monitoring_service.domain.ports.repositories.check : ICheckRepository;

class ListChecksUseCase {
    private ICheckRepository repository;

    this(ICheckRepository repository) {
        this.repository = repository;
    }

    Check[] execute() {
        return repository.list();
    }
}
