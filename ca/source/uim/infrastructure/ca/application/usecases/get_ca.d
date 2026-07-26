module uim.infrastructure.ca.application.usecases.get_ca;

import uim.infrastructure.ca.domain.entities.ca_state : CaState;
import uim.infrastructure.ca.domain.ports.repositories.ca_state : ICaStateRepository;

class GetCaUseCase {
    private ICaStateRepository repository;

    this(ICaStateRepository repository) {
        this.repository = repository;
    }

    CaState* execute() {
        return repository.get();
    }
}
