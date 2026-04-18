module uim.infrastructure.crossplane.infrastructure.http.controllers.crossplane;

import uim.infrastructure.crossplane.application.dto.commands;
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
import uim.infrastructure.crossplane.domain.entities.provider : Provider;
import uim.infrastructure.crossplane.domain.entities.composition : Composition;
import uim.infrastructure.crossplane.domain.entities.managed_resource : ManagedResource;
import uim.infrastructure.crossplane.domain.entities.claim : Claim;
import uim.infrastructure.crossplane.domain.entities.composite_resource : CompositeResource, ResourceRef;
import std.conv : to;
import std.string : startsWith;
import vibe.http.router : URLRouter;
import vibe.http.server : HTTPServerRequest, HTTPServerResponse;
import vibe.http.common : HTTPStatus;
import vibe.data.json : Json, serializeToJsonString;

// --- View structs ---

struct ProviderView {
    string id;
    string name;
    string providerType;
    string packageRef;
    string status;
    string region;
    string createdAt;
}

struct CompositionView {
    string id;
    string name;
    string compositeTypeRef;
    uint resourceCount;
    string createdAt;
}

struct ManagedResourceView {
    string id;
    string name;
    string providerId;
    string apiGroup;
    string kind;
    string status;
    string ready;
    string externalName;
    string createdAt;
}

struct ClaimView {
    string id;
    string name;
    string namespace;
    string compositionRef;
    string status;
    string boundResourceId;
    string createdAt;
}

struct ResourceRefView {
    string resourceId;
    string name;
    string kind;
    string ready;
}

struct CompositeResourceView {
    string id;
    string name;
    string compositionId;
    string claimId;
    string status;
    uint readyCount;
    uint totalCount;
    string createdAt;
}

struct CompositeResourceDetailView {
    string id;
    string name;
    string compositionId;
    string claimId;
    string status;
    ResourceRefView[] resourceRefs;
    string createdAt;
    string updatedAt;
}

class CrossplaneController {
    private CreateProviderUseCase createProviderUC;
    private ListProvidersUseCase listProvidersUC;
    private GetProviderUseCase getProviderUC;
    private DeleteProviderUseCase deleteProviderUC;
    private CreateCompositionUseCase createCompositionUC;
    private ListCompositionsUseCase listCompositionsUC;
    private GetCompositionUseCase getCompositionUC;
    private DeleteCompositionUseCase deleteCompositionUC;
    private CreateManagedResourceUseCase createManagedResourceUC;
    private ListManagedResourcesUseCase listManagedResourcesUC;
    private GetManagedResourceUseCase getManagedResourceUC;
    private DeleteManagedResourceUseCase deleteManagedResourceUC;
    private CreateClaimUseCase createClaimUC;
    private ListClaimsUseCase listClaimsUC;
    private GetClaimUseCase getClaimUC;
    private DeleteClaimUseCase deleteClaimUC;
    private ReconcileClaimUseCase reconcileClaimUC;
    private ListCompositeResourcesUseCase listCompositeResourcesUC;
    private GetCompositeResourceUseCase getCompositeResourceUC;

    this(
        CreateProviderUseCase createProviderUC,
        ListProvidersUseCase listProvidersUC,
        GetProviderUseCase getProviderUC,
        DeleteProviderUseCase deleteProviderUC,
        CreateCompositionUseCase createCompositionUC,
        ListCompositionsUseCase listCompositionsUC,
        GetCompositionUseCase getCompositionUC,
        DeleteCompositionUseCase deleteCompositionUC,
        CreateManagedResourceUseCase createManagedResourceUC,
        ListManagedResourcesUseCase listManagedResourcesUC,
        GetManagedResourceUseCase getManagedResourceUC,
        DeleteManagedResourceUseCase deleteManagedResourceUC,
        CreateClaimUseCase createClaimUC,
        ListClaimsUseCase listClaimsUC,
        GetClaimUseCase getClaimUC,
        DeleteClaimUseCase deleteClaimUC,
        ReconcileClaimUseCase reconcileClaimUC,
        ListCompositeResourcesUseCase listCompositeResourcesUC,
        GetCompositeResourceUseCase getCompositeResourceUC
    ) {
        this.createProviderUC = createProviderUC;
        this.listProvidersUC = listProvidersUC;
        this.getProviderUC = getProviderUC;
        this.deleteProviderUC = deleteProviderUC;
        this.createCompositionUC = createCompositionUC;
        this.listCompositionsUC = listCompositionsUC;
        this.getCompositionUC = getCompositionUC;
        this.deleteCompositionUC = deleteCompositionUC;
        this.createManagedResourceUC = createManagedResourceUC;
        this.listManagedResourcesUC = listManagedResourcesUC;
        this.getManagedResourceUC = getManagedResourceUC;
        this.deleteManagedResourceUC = deleteManagedResourceUC;
        this.createClaimUC = createClaimUC;
        this.listClaimsUC = listClaimsUC;
        this.getClaimUC = getClaimUC;
        this.deleteClaimUC = deleteClaimUC;
        this.reconcileClaimUC = reconcileClaimUC;
        this.listCompositeResourcesUC = listCompositeResourcesUC;
        this.getCompositeResourceUC = getCompositeResourceUC;
    }

    void registerRoutes(URLRouter router) {
        router.get("/health", &health);

        // Providers
        router.get("/v1/providers", &listProviders);
        router.post("/v1/providers", &createProvider);
        router.get("/v1/providers/*", &getProvider);
        router.delete_("/v1/providers/*", &deleteProvider);

        // Compositions
        router.get("/v1/compositions", &listCompositions);
        router.post("/v1/compositions", &createComposition);
        router.get("/v1/compositions/*", &getComposition);
        router.delete_("/v1/compositions/*", &deleteComposition);

        // Managed Resources
        router.get("/v1/managed-resources", &listManagedResources);
        router.post("/v1/managed-resources", &createManagedResource);
        router.get("/v1/managed-resources/*", &getManagedResource);
        router.delete_("/v1/managed-resources/*", &deleteManagedResource);

        // Claims
        router.get("/v1/claims", &listClaims);
        router.post("/v1/claims", &createClaim);
        router.get("/v1/claims/*", &getClaim);
        router.delete_("/v1/claims/*", &deleteClaim);

        // Reconcile
        router.post("/v1/reconcile", &reconcileClaim);

        // Composite Resources
        router.get("/v1/composite-resources", &listCompositeResources);
        router.get("/v1/composite-resources/*", &getCompositeResource);
    }

    // --- Health ---

    void health(HTTPServerRequest req, HTTPServerResponse res) {
        writeJson(res, `{ "status": "ok", "service": "uim-crossplane-service" }`, HTTPStatus.ok);
    }

    // --- Providers ---

    void listProviders(HTTPServerRequest req, HTTPServerResponse res) {
        auto providers = listProvidersUC.execute();
        writeJson(res, serializeToJsonString(providersToViews(providers)), HTTPStatus.ok);
    }

    void createProvider(HTTPServerRequest req, HTTPServerResponse res) {
        try {
            auto json = req.json;
            CredentialDef[] creds;
            if ("credentials" in json) {
                foreach (c; json["credentials"])
                    creds ~= CredentialDef(c["key"].get!string, c["secretRef"].get!string);
            }
            string[string] cfg;
            if ("config" in json) {
                foreach (string k, v; json["config"]) cfg[k] = v.get!string;
            }
            auto cmd = CreateProviderCommand(
                json["name"].get!string,
                json["providerType"].get!string,
                ("packageRef" in json) ? json["packageRef"].get!string : "",
                ("region" in json) ? json["region"].get!string : "",
                creds,
                cfg
            );
            auto created = createProviderUC.execute(cmd);
            writeJson(res, serializeToJsonString(providerToView(created)), HTTPStatus.created);
        } catch (Exception ex) { writeJson(res, `{ "error": "` ~ ex.msg ~ `" }`, HTTPStatus.badRequest); }
    }

    void getProvider(HTTPServerRequest req, HTTPServerResponse res) {
        auto id = extractId(req.requestPath.to!string, "/v1/providers/");
        if (id.length == 0) { writeJson(res, `{ "error": "missing id" }`, HTTPStatus.badRequest); return; }
        auto ptr = getProviderUC.execute(id);
        if (ptr is null) { writeJson(res, `{ "error": "provider not found" }`, HTTPStatus.notFound); return; }
        writeJson(res, serializeToJsonString(providerToView(*ptr)), HTTPStatus.ok);
    }

    void deleteProvider(HTTPServerRequest req, HTTPServerResponse res) {
        auto id = extractId(req.requestPath.to!string, "/v1/providers/");
        if (id.length == 0) { writeJson(res, `{ "error": "missing id" }`, HTTPStatus.badRequest); return; }
        deleteProviderUC.execute(id);
        writeJson(res, `{ "status": "deleted" }`, HTTPStatus.ok);
    }

    // --- Compositions ---

    void listCompositions(HTTPServerRequest req, HTTPServerResponse res) {
        auto compositions = listCompositionsUC.execute();
        writeJson(res, serializeToJsonString(compositionsToViews(compositions)), HTTPStatus.ok);
    }

    void createComposition(HTTPServerRequest req, HTTPServerResponse res) {
        try {
            auto json = req.json;
            ComposedTemplateDef[] resources;
            if ("resources" in json) {
                foreach (r; json["resources"]) {
                    string[string] patches;
                    if ("patches" in r) foreach (string k, v; r["patches"]) patches[k] = v.get!string;
                    string[string] base;
                    if ("base" in r) foreach (string k, v; r["base"]) base[k] = v.get!string;
                    resources ~= ComposedTemplateDef(
                        r["name"].get!string,
                        r["kind"].get!string,
                        ("apiGroup" in r) ? r["apiGroup"].get!string : "",
                        patches, base
                    );
                }
            }
            string[string] secretsRef;
            if ("writeConnectionSecretsToRef" in json) {
                foreach (string k, v; json["writeConnectionSecretsToRef"]) secretsRef[k] = v.get!string;
            }
            auto cmd = CreateCompositionCommand(
                json["name"].get!string,
                json["compositeTypeRef"].get!string,
                resources,
                secretsRef
            );
            auto created = createCompositionUC.execute(cmd);
            writeJson(res, serializeToJsonString(compositionToView(created)), HTTPStatus.created);
        } catch (Exception ex) { writeJson(res, `{ "error": "` ~ ex.msg ~ `" }`, HTTPStatus.badRequest); }
    }

    void getComposition(HTTPServerRequest req, HTTPServerResponse res) {
        auto id = extractId(req.requestPath.to!string, "/v1/compositions/");
        if (id.length == 0) { writeJson(res, `{ "error": "missing id" }`, HTTPStatus.badRequest); return; }
        auto ptr = getCompositionUC.execute(id);
        if (ptr is null) { writeJson(res, `{ "error": "composition not found" }`, HTTPStatus.notFound); return; }
        writeJson(res, serializeToJsonString(compositionToView(*ptr)), HTTPStatus.ok);
    }

    void deleteComposition(HTTPServerRequest req, HTTPServerResponse res) {
        auto id = extractId(req.requestPath.to!string, "/v1/compositions/");
        if (id.length == 0) { writeJson(res, `{ "error": "missing id" }`, HTTPStatus.badRequest); return; }
        deleteCompositionUC.execute(id);
        writeJson(res, `{ "status": "deleted" }`, HTTPStatus.ok);
    }

    // --- Managed Resources ---

    void listManagedResources(HTTPServerRequest req, HTTPServerResponse res) {
        auto resources = listManagedResourcesUC.execute();
        writeJson(res, serializeToJsonString(managedResourcesToViews(resources)), HTTPStatus.ok);
    }

    void createManagedResource(HTTPServerRequest req, HTTPServerResponse res) {
        try {
            auto json = req.json;
            string[string] spec;
            if ("spec" in json) foreach (string k, v; json["spec"]) spec[k] = v.get!string;
            auto cmd = CreateManagedResourceCommand(
                json["name"].get!string,
                ("providerId" in json) ? json["providerId"].get!string : "",
                ("apiGroup" in json) ? json["apiGroup"].get!string : "",
                json["kind"].get!string,
                spec
            );
            auto created = createManagedResourceUC.execute(cmd);
            writeJson(res, serializeToJsonString(managedResourceToView(created)), HTTPStatus.created);
        } catch (Exception ex) { writeJson(res, `{ "error": "` ~ ex.msg ~ `" }`, HTTPStatus.badRequest); }
    }

    void getManagedResource(HTTPServerRequest req, HTTPServerResponse res) {
        auto id = extractId(req.requestPath.to!string, "/v1/managed-resources/");
        if (id.length == 0) { writeJson(res, `{ "error": "missing id" }`, HTTPStatus.badRequest); return; }
        auto ptr = getManagedResourceUC.execute(id);
        if (ptr is null) { writeJson(res, `{ "error": "managed resource not found" }`, HTTPStatus.notFound); return; }
        writeJson(res, serializeToJsonString(managedResourceToView(*ptr)), HTTPStatus.ok);
    }

    void deleteManagedResource(HTTPServerRequest req, HTTPServerResponse res) {
        auto id = extractId(req.requestPath.to!string, "/v1/managed-resources/");
        if (id.length == 0) { writeJson(res, `{ "error": "missing id" }`, HTTPStatus.badRequest); return; }
        deleteManagedResourceUC.execute(id);
        writeJson(res, `{ "status": "deleted" }`, HTTPStatus.ok);
    }

    // --- Claims ---

    void listClaims(HTTPServerRequest req, HTTPServerResponse res) {
        auto claims = listClaimsUC.execute();
        writeJson(res, serializeToJsonString(claimsToViews(claims)), HTTPStatus.ok);
    }

    void createClaim(HTTPServerRequest req, HTTPServerResponse res) {
        try {
            auto json = req.json;
            string[string] params;
            if ("parameters" in json) foreach (string k, v; json["parameters"]) params[k] = v.get!string;
            auto cmd = CreateClaimCommand(
                json["name"].get!string,
                ("namespace" in json) ? json["namespace"].get!string : "default",
                json["compositionRef"].get!string,
                params
            );
            auto created = createClaimUC.execute(cmd);
            writeJson(res, serializeToJsonString(claimToView(created)), HTTPStatus.created);
        } catch (Exception ex) { writeJson(res, `{ "error": "` ~ ex.msg ~ `" }`, HTTPStatus.badRequest); }
    }

    void getClaim(HTTPServerRequest req, HTTPServerResponse res) {
        auto id = extractId(req.requestPath.to!string, "/v1/claims/");
        if (id.length == 0) { writeJson(res, `{ "error": "missing id" }`, HTTPStatus.badRequest); return; }
        auto ptr = getClaimUC.execute(id);
        if (ptr is null) { writeJson(res, `{ "error": "claim not found" }`, HTTPStatus.notFound); return; }
        writeJson(res, serializeToJsonString(claimToView(*ptr)), HTTPStatus.ok);
    }

    void deleteClaim(HTTPServerRequest req, HTTPServerResponse res) {
        auto id = extractId(req.requestPath.to!string, "/v1/claims/");
        if (id.length == 0) { writeJson(res, `{ "error": "missing id" }`, HTTPStatus.badRequest); return; }
        deleteClaimUC.execute(id);
        writeJson(res, `{ "status": "deleted" }`, HTTPStatus.ok);
    }

    // --- Reconcile ---

    void reconcileClaim(HTTPServerRequest req, HTTPServerResponse res) {
        try {
            auto json = req.json;
            auto cmd = ReconcileClaimCommand(json["claimId"].get!string);
            auto xr = reconcileClaimUC.execute(cmd);
            writeJson(res, serializeToJsonString(compositeResourceToDetailView(xr)), HTTPStatus.created);
        } catch (Exception ex) { writeJson(res, `{ "error": "` ~ ex.msg ~ `" }`, HTTPStatus.badRequest); }
    }

    // --- Composite Resources ---

    void listCompositeResources(HTTPServerRequest req, HTTPServerResponse res) {
        auto resources = listCompositeResourcesUC.execute();
        writeJson(res, serializeToJsonString(compositeResourcesToViews(resources)), HTTPStatus.ok);
    }

    void getCompositeResource(HTTPServerRequest req, HTTPServerResponse res) {
        auto id = extractId(req.requestPath.to!string, "/v1/composite-resources/");
        if (id.length == 0) { writeJson(res, `{ "error": "missing id" }`, HTTPStatus.badRequest); return; }
        auto ptr = getCompositeResourceUC.execute(id);
        if (ptr is null) { writeJson(res, `{ "error": "composite resource not found" }`, HTTPStatus.notFound); return; }
        writeJson(res, serializeToJsonString(compositeResourceToDetailView(*ptr)), HTTPStatus.ok);
    }

    // --- View converters ---

    private ProviderView providerToView(in Provider p) {
        return ProviderView(p.id, p.name, p.providerType.to!string, p.packageRef,
            p.status.to!string, p.region, p.createdAt);
    }

    private ProviderView[] providersToViews(scope const Provider[] providers) {
        ProviderView[] views;
        foreach (p; providers) views ~= providerToView(p);
        return views;
    }

    private CompositionView compositionToView(in Composition c) {
        return CompositionView(c.id, c.name, c.compositeTypeRef,
            cast(uint) c.resources.length, c.createdAt);
    }

    private CompositionView[] compositionsToViews(scope const Composition[] compositions) {
        CompositionView[] views;
        foreach (c; compositions) views ~= compositionToView(c);
        return views;
    }

    private ManagedResourceView managedResourceToView(in ManagedResource r) {
        return ManagedResourceView(r.id, r.name, r.providerId, r.apiGroup, r.kind,
            r.status.to!string, r.ready.to!string, r.externalName, r.createdAt);
    }

    private ManagedResourceView[] managedResourcesToViews(scope const ManagedResource[] resources) {
        ManagedResourceView[] views;
        foreach (r; resources) views ~= managedResourceToView(r);
        return views;
    }

    private ClaimView claimToView(in Claim c) {
        return ClaimView(c.id, c.name, c.namespace, c.compositionRef,
            c.status.to!string, c.boundResourceId, c.createdAt);
    }

    private ClaimView[] claimsToViews(scope const Claim[] claims) {
        ClaimView[] views;
        foreach (c; claims) views ~= claimToView(c);
        return views;
    }

    private CompositeResourceView compositeResourceToView(in CompositeResource xr) {
        return CompositeResourceView(xr.id, xr.name, xr.compositionId, xr.claimId,
            xr.status.to!string, xr.readyCount(), xr.totalCount(), xr.createdAt);
    }

    private CompositeResourceView[] compositeResourcesToViews(scope const CompositeResource[] resources) {
        CompositeResourceView[] views;
        foreach (xr; resources) views ~= compositeResourceToView(xr);
        return views;
    }

    private CompositeResourceDetailView compositeResourceToDetailView(in CompositeResource xr) {
        ResourceRefView[] refs;
        foreach (r; xr.resourceRefs)
            refs ~= ResourceRefView(r.resourceId, r.name, r.kind, r.ready.to!string);
        return CompositeResourceDetailView(xr.id, xr.name, xr.compositionId, xr.claimId,
            xr.status.to!string, refs, xr.createdAt, xr.updatedAt);
    }

    // --- Helpers ---

    private string extractId(string requestPath, string prefix) {
        if (!requestPath.startsWith(prefix)) return "";
        return requestPath[prefix.length .. $];
    }

    private void writeJson(HTTPServerResponse res, string body, HTTPStatus status) {
        res.writeBody(body, cast(int) status, "application/json");
    }
}
