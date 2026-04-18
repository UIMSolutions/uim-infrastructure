module uim.infrastructure.crossplane.application.usecases.delete_provider;

import uim.infrastructure.crossplane.domain.ports.repositories.provider : IProviderRepository;

class DeleteProviderUseCase {
    private IProviderRepository repo;

    this(IProviderRepository repo) { this.repo = repo; }

    void execute(string id) { repo.remove(id); }
}
