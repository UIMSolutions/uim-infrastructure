module uim.infrastructure.crossplane.application.usecases.list_claims;

import uim.infrastructure.crossplane.domain.entities.claim : Claim;
import uim.infrastructure.crossplane.domain.ports.repositories.claim : IClaimRepository;

class ListClaimsUseCase {
    private IClaimRepository repo;

    this(IClaimRepository repo) { this.repo = repo; }

    Claim[] execute() { return repo.list(); }
}
