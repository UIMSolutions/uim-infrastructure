module uim.infrastructure.archer.application.usecases.agent_usecases;

import uim.infrastructure.archer.domain.entities.agent : ArcherAgent;
import uim.infrastructure.archer.domain.ports.repositories.agent : IAgentRepository;

class ListAgentsUseCase {
    private IAgentRepository repository;

    this(IAgentRepository repository) {
        this.repository = repository;
    }

    ArcherAgent[] execute() {
        return repository.list();
    }
}

class GetAgentUseCase {
    private IAgentRepository repository;

    this(IAgentRepository repository) {
        this.repository = repository;
    }

    ArcherAgent* execute(string host) {
        return repository.findByHost(host);
    }
}
