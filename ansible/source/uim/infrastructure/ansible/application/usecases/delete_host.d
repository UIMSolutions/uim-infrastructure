module uim.infrastructure.ansible.application.usecases.delete_host;

import uim.infrastructure.ansible.domain.ports.repositories.host : IHostRepository;

class DeleteHostUseCase {
    private IHostRepository repository;

    this(IHostRepository repository) {
        this.repository = repository;
    }

    void execute(string id) {
        if (id.length == 0)
            throw new Exception("host id must not be empty");
        repository.remove(id);
    }
}
