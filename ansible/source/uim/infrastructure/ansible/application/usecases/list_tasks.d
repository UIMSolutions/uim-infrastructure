module uim.infrastructure.ansible.application.usecases.list_tasks;

import uim.infrastructure.ansible.domain.entities.task : Task;
import uim.infrastructure.ansible.domain.ports.repositories.task : ITaskRepository;

class ListTasksUseCase {
    private ITaskRepository repository;

    this(ITaskRepository repository) {
        this.repository = repository;
    }

    Task[] execute() {
        return repository.list();
    }
}
