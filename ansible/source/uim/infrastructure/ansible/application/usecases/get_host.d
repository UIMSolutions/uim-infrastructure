module uim.infrastructure.ansible.application.usecases.get_host;

import uim.infrastructure.ansible.domain.entities.host : Host;
import uim.infrastructure.ansible.domain.ports.repositories.host : IHostRepository;

class GetHostUseCase {
    private IHostRepository repository;

    this(IHostRepository repository) {
        this.repository = repository;
    }

    Host* execute(string id) {
        if (id.length == 0)
            throw new Exception("host id must not be empty");
        return repository.findById(id);
    }
}
