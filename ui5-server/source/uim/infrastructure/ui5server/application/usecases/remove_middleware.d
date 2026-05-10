module uim.infrastructure.ui5server.application.usecases.remove_middleware;

import uim.infrastructure.ui5server.domain.ports.repositories.middleware : IMiddlewareRepository;

class RemoveMiddlewareUseCase {
    private IMiddlewareRepository repo;

    this(IMiddlewareRepository repo) {
        this.repo = repo;
    }

    bool execute(string name) {
        return repo.remove(name);
    }
}
