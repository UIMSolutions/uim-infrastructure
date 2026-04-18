module uim.infrastructure.crossplane.application.usecases.reconcile_claim;

import uim.infrastructure.crossplane.application.dto.commands : ReconcileClaimCommand;
import uim.infrastructure.crossplane.domain.entities.claim : Claim, ClaimStatus;
import uim.infrastructure.crossplane.domain.entities.composition : Composition;
import uim.infrastructure.crossplane.domain.entities.composite_resource : CompositeResource, CompositeStatus, ResourceRef;
import uim.infrastructure.crossplane.domain.entities.managed_resource : ManagedResource, ResourceStatus, ReadyCondition;
import uim.infrastructure.crossplane.domain.ports.repositories.claim : IClaimRepository;
import uim.infrastructure.crossplane.domain.ports.repositories.composition : ICompositionRepository;
import uim.infrastructure.crossplane.domain.ports.repositories.composite_resource : ICompositeResourceRepository;
import uim.infrastructure.crossplane.domain.ports.repositories.managed_resource : IManagedResourceRepository;
import std.datetime.systime : Clock;

class ReconcileClaimUseCase {
    private IClaimRepository claimRepo;
    private ICompositionRepository compositionRepo;
    private ICompositeResourceRepository compositeRepo;
    private IManagedResourceRepository managedRepo;

    this(
        IClaimRepository claimRepo,
        ICompositionRepository compositionRepo,
        ICompositeResourceRepository compositeRepo,
        IManagedResourceRepository managedRepo
    ) {
        this.claimRepo = claimRepo;
        this.compositionRepo = compositionRepo;
        this.compositeRepo = compositeRepo;
        this.managedRepo = managedRepo;
    }

    CompositeResource execute(ReconcileClaimCommand cmd) {
        auto claimPtr = claimRepo.findById(cmd.claimId);
        if (claimPtr is null)
            throw new Exception("Claim not found: " ~ cmd.claimId);

        auto claim = *claimPtr;

        auto compPtr = compositionRepo.findById(claim.compositionRef);
        if (compPtr is null)
            throw new Exception("Composition not found: " ~ claim.compositionRef);

        auto composition = *compPtr;
        auto now = Clock.currTime.toISOExtString;

        // Create managed resources from composition templates
        ResourceRef[] refs;
        foreach (tpl; composition.resources) {
            string[string] spec;
            // Merge template base with claim parameters
            foreach (k, v; tpl.base)
                spec[k] = v;
            foreach (k, v; claim.parameters)
                spec[k] = v;

            auto mrId = generateId();
            auto mr = ManagedResource(
                mrId,
                claim.name ~ "-" ~ tpl.name,
                "",
                tpl.apiGroup,
                tpl.kind,
                spec,
                null,
                ResourceStatus.AVAILABLE,
                ReadyCondition.TRUE,
                claim.name ~ "-" ~ tpl.name,
                "",
                now,
                now
            );
            managedRepo.save(mr);
            refs ~= ResourceRef(mrId, tpl.name, tpl.kind, ReadyCondition.TRUE);
        }

        // Create composite resource
        auto xrId = generateId();
        auto xr = CompositeResource(
            xrId,
            claim.name ~ "-xr",
            composition.id,
            claim.id,
            claim.parameters.dup,
            refs,
            CompositeStatus.READY,
            null,
            now,
            now
        );
        compositeRepo.save(xr);

        // Update claim to BOUND
        auto updatedClaim = Claim(
            claim.id,
            claim.name,
            claim.namespace,
            xrId,
            claim.compositionRef,
            claim.parameters.dup,
            ClaimStatus.BOUND,
            xrId,
            claim.createdAt,
            now
        );
        claimRepo.save(updatedClaim);

        return xr;
    }

    private string generateId() {
        import std.uuid : randomUUID;
        return randomUUID().toString();
    }
}
