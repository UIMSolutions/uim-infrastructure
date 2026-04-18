module uim.infrastructure.crossplane.application.usecases.list_providers;

import uim.infrastructure.crossplane.domain.entities.provider : Provider;
import uim.infrastructure.crossplane.domain.ports.repositories.provider : IProviderRepository;

class ListProvidersUseCase {
    private IProviderRepository repo;

    this(IProviderRepository repo) { this.repo = repo; }

    Provider[] execute() { return repo.list(); }
}
