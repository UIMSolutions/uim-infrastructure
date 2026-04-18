module uim.infrastructure.crossplane.application.usecases.get_claim;

import uim.infrastructure.crossplane.domain.entities.claim : Claim;
import uim.infrastructure.crossplane.domain.ports.repositories.claim : IClaimRepository;

class GetClaimUseCase {
    private IClaimRepository repo;

    this(IClaimRepository repo) { this.repo = repo; }

    Claim* execute(string id) { return repo.findById(id); }
}
