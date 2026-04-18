module uim.infrastructure.ansible.application.usecases.list_executions;

import uim.infrastructure.ansible.domain.entities.execution : Execution;
import uim.infrastructure.ansible.domain.ports.repositories.execution : IExecutionRepository;

class ListExecutionsUseCase {
    private IExecutionRepository repository;

    this(IExecutionRepository repository) {
        this.repository = repository;
    }

    Execution[] execute() {
        return repository.list();
    }
}
