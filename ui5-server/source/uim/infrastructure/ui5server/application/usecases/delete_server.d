module uim.infrastructure.ui5server.application.usecases.delete_server;

import uim.infrastructure.ui5server.domain.ports.repositories.server : IServerRepository;

class DeleteServerUseCase {
    private IServerRepository repo;

    this(IServerRepository repo) {
        this.repo = repo;
    }

    bool execute(string id) {
        return repo.remove(id);
    }
}
