module uim.infrastructure.ui5server.application.usecases.delete_resource;

import uim.infrastructure.ui5server.domain.ports.repositories.resource : IResourceRepository;

class DeleteResourceUseCase {
    private IResourceRepository repo;

    this(IResourceRepository repo) {
        this.repo = repo;
    }

    bool execute(string path) {
        return repo.remove(path);
    }
}
