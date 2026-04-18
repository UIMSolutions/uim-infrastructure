module uim.infrastructure.ansible.application.usecases.get_playbook;

import uim.infrastructure.ansible.domain.entities.playbook : Playbook;
import uim.infrastructure.ansible.domain.ports.repositories.playbook : IPlaybookRepository;

class GetPlaybookUseCase {
    private IPlaybookRepository repository;

    this(IPlaybookRepository repository) {
        this.repository = repository;
    }

    Playbook* execute(string id) {
        if (id.length == 0)
            throw new Exception("playbook id must not be empty");
        return repository.findById(id);
    }
}
