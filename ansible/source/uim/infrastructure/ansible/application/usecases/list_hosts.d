module uim.infrastructure.ansible.application.usecases.list_hosts;

import uim.infrastructure.ansible.domain.entities.host : Host;
import uim.infrastructure.ansible.domain.ports.repositories.host : IHostRepository;

class ListHostsUseCase {
    private IHostRepository repository;

    this(IHostRepository repository) {
        this.repository = repository;
    }

    Host[] execute() {
        return repository.list();
    }
}
