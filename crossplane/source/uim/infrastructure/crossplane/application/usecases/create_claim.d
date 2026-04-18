module uim.infrastructure.crossplane.application.usecases.create_claim;

import uim.infrastructure.crossplane.application.dto.commands : CreateClaimCommand;
import uim.infrastructure.crossplane.domain.entities.claim : Claim, ClaimStatus;
import uim.infrastructure.crossplane.domain.ports.repositories.claim : IClaimRepository;
import std.datetime.systime : Clock;

class CreateClaimUseCase {
    private IClaimRepository repo;

    this(IClaimRepository repo) { this.repo = repo; }

    Claim execute(CreateClaimCommand cmd) {
        auto now = Clock.currTime.toISOExtString;
        auto claim = Claim(
            generateId(),
            cmd.name,
            cmd.namespace,
            "",
            cmd.compositionRef,
            cmd.parameters.dup,
            ClaimStatus.PENDING,
            "",
            now,
            now
        );
        repo.save(claim);
        return claim;
    }

    private string generateId() {
        import std.uuid : randomUUID;
        return randomUUID().toString();
    }
}
