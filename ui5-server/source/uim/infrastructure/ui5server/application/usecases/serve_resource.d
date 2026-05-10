module uim.infrastructure.ui5server.application.usecases.serve_resource;

import uim.infrastructure.ui5server.domain.ports.repositories.resource : IResourceRepository;
import uim.infrastructure.ui5server.domain.entities.resource : Resource;

class ServeResourceUseCase {
    private IResourceRepository repo;

    this(IResourceRepository repo) {
        this.repo = repo;
    }

    Resource* execute(string path) {
        return repo.findByPath(path);
    }
}
