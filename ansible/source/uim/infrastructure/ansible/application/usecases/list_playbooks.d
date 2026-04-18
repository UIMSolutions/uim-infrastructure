module uim.infrastructure.ansible.application.usecases.list_playbooks;

import uim.infrastructure.ansible.domain.entities.playbook : Playbook;
import uim.infrastructure.ansible.domain.ports.repositories.playbook : IPlaybookRepository;

class ListPlaybooksUseCase {
    private IPlaybookRepository repository;

    this(IPlaybookRepository repository) {
        this.repository = repository;
    }

    Playbook[] execute() {
        return repository.list();
    }
}
