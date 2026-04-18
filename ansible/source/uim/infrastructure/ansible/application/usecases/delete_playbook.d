module uim.infrastructure.ansible.application.usecases.delete_playbook;

import uim.infrastructure.ansible.domain.ports.repositories.playbook : IPlaybookRepository;

class DeletePlaybookUseCase {
    private IPlaybookRepository repository;

    this(IPlaybookRepository repository) {
        this.repository = repository;
    }

    void execute(string id) {
        if (id.length == 0)
            throw new Exception("playbook id must not be empty");
        repository.remove(id);
    }
}
