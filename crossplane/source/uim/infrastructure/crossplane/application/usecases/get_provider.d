module uim.infrastructure.crossplane.application.usecases.get_provider;

import uim.infrastructure.crossplane.domain.entities.provider : Provider;
import uim.infrastructure.crossplane.domain.ports.repositories.provider : IProviderRepository;

class GetProviderUseCase {
    private IProviderRepository repo;

    this(IProviderRepository repo) { this.repo = repo; }

    Provider* execute(string id) { return repo.findById(id); }
}
