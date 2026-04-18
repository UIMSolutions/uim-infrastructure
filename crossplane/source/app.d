module app;

import uim.infrastructure.crossplane.application.usecases.create_provider : CreateProviderUseCase;
import uim.infrastructure.crossplane.application.usecases.list_providers : ListProvidersUseCase;
import uim.infrastructure.crossplane.application.usecases.get_provider : GetProviderUseCase;
import uim.infrastructure.crossplane.application.usecases.delete_provider : DeleteProviderUseCase;
import uim.infrastructure.crossplane.application.usecases.create_composition : CreateCompositionUseCase;
import uim.infrastructure.crossplane.application.usecases.list_compositions : ListCompositionsUseCase;
import uim.infrastructure.crossplane.application.usecases.get_composition : GetCompositionUseCase;
import uim.infrastructure.crossplane.application.usecases.delete_composition : DeleteCompositionUseCase;
import uim.infrastructure.crossplane.application.usecases.create_managed_resource : CreateManagedResourceUseCase;
import uim.infrastructure.crossplane.application.usecases.list_managed_resources : ListManagedResourcesUseCase;
import uim.infrastructure.crossplane.application.usecases.get_managed_resource : GetManagedResourceUseCase;
import uim.infrastructure.crossplane.application.usecases.delete_managed_resource : DeleteManagedResourceUseCase;
import uim.infrastructure.crossplane.application.usecases.create_claim : CreateClaimUseCase;
import uim.infrastructure.crossplane.application.usecases.list_claims : ListClaimsUseCase;
import uim.infrastructure.crossplane.application.usecases.get_claim : GetClaimUseCase;
import uim.infrastructure.crossplane.application.usecases.delete_claim : DeleteClaimUseCase;
import uim.infrastructure.crossplane.application.usecases.reconcile_claim : ReconcileClaimUseCase;
import uim.infrastructure.crossplane.application.usecases.list_composite_resources : ListCompositeResourcesUseCase;
import uim.infrastructure.crossplane.application.usecases.get_composite_resource : GetCompositeResourceUseCase;
import uim.infrastructure.crossplane.infrastructure.http.controllers.crossplane : CrossplaneController;
import uim.infrastructure.crossplane.infrastructure.persistence.memory.provider_repository : InMemoryProviderRepository;
import uim.infrastructure.crossplane.infrastructure.persistence.memory.composition_repository : InMemoryCompositionRepository;
import uim.infrastructure.crossplane.infrastructure.persistence.memory.managed_resource_repository : InMemoryManagedResourceRepository;
import uim.infrastructure.crossplane.infrastructure.persistence.memory.claim_repository : InMemoryClaimRepository;
import uim.infrastructure.crossplane.infrastructure.persistence.memory.composite_resource_repository : InMemoryCompositeResourceRepository;
import std.conv : to;
import std.exception : collectException;
import std.string : fromStringz;
import core.stdc.stdlib : getenv;
import vibe.vibe;

void main() {
    auto settings = new HTTPServerSettings;
    settings.port = readPort();
    settings.bindAddresses = [readBindAddress()];

    // --- Outbound adapters (repositories) ---
    auto providerRepo = new InMemoryProviderRepository();
    auto compositionRepo = new InMemoryCompositionRepository();
    auto managedResourceRepo = new InMemoryManagedResourceRepository();
    auto claimRepo = new InMemoryClaimRepository();
    auto compositeResourceRepo = new InMemoryCompositeResourceRepository();

    // --- Use cases ---
    auto createProviderUC = new CreateProviderUseCase(providerRepo);
    auto listProvidersUC = new ListProvidersUseCase(providerRepo);
    auto getProviderUC = new GetProviderUseCase(providerRepo);
    auto deleteProviderUC = new DeleteProviderUseCase(providerRepo);
    auto createCompositionUC = new CreateCompositionUseCase(compositionRepo);
    auto listCompositionsUC = new ListCompositionsUseCase(compositionRepo);
    auto getCompositionUC = new GetCompositionUseCase(compositionRepo);
    auto deleteCompositionUC = new DeleteCompositionUseCase(compositionRepo);
    auto createManagedResourceUC = new CreateManagedResourceUseCase(managedResourceRepo);
    auto listManagedResourcesUC = new ListManagedResourcesUseCase(managedResourceRepo);
    auto getManagedResourceUC = new GetManagedResourceUseCase(managedResourceRepo);
    auto deleteManagedResourceUC = new DeleteManagedResourceUseCase(managedResourceRepo);
    auto createClaimUC = new CreateClaimUseCase(claimRepo);
    auto listClaimsUC = new ListClaimsUseCase(claimRepo);
    auto getClaimUC = new GetClaimUseCase(claimRepo);
    auto deleteClaimUC = new DeleteClaimUseCase(claimRepo);
    auto reconcileClaimUC = new ReconcileClaimUseCase(claimRepo, compositionRepo, compositeResourceRepo, managedResourceRepo);
    auto listCompositeResourcesUC = new ListCompositeResourcesUseCase(compositeResourceRepo);
    auto getCompositeResourceUC = new GetCompositeResourceUseCase(compositeResourceRepo);

    // --- Inbound adapter (HTTP controller) ---
    auto controller = new CrossplaneController(
        createProviderUC, listProvidersUC, getProviderUC, deleteProviderUC,
        createCompositionUC, listCompositionsUC, getCompositionUC, deleteCompositionUC,
        createManagedResourceUC, listManagedResourcesUC, getManagedResourceUC, deleteManagedResourceUC,
        createClaimUC, listClaimsUC, getClaimUC, deleteClaimUC,
        reconcileClaimUC, listCompositeResourcesUC, getCompositeResourceUC
    );

    auto router = new URLRouter;
    controller.registerRoutes(router);

    logInfo("Crossplane infrastructure composition service starting on %s:%d", settings.bindAddresses[0], settings.port);
    listenHTTP(settings, router);
    runApplication();
}

private ushort readPort() {
    auto raw = getenv("PORT");
    if (raw is null) {
        return 8080;
    }

    ushort parsed;
    auto err = collectException(parsed = fromStringz(raw).to!ushort);
    return err is null ? parsed : cast(ushort) 8080;
}

private string readBindAddress() {
    auto raw = getenv("BIND_ADDRESS");
    return raw is null ? "0.0.0.0".idup : fromStringz(raw).idup;
}
