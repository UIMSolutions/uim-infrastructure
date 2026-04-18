module uim.infrastructure.crossplane.application.usecases.delete_claim;

import uim.infrastructure.crossplane.domain.ports.repositories.claim : IClaimRepository;

class DeleteClaimUseCase {
    private IClaimRepository repo;

    this(IClaimRepository repo) { this.repo = repo; }

    void execute(string id) { repo.remove(id); }
}
