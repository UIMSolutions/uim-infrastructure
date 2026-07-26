module uim.infrastructure.gardener.infrastructure.adapters.http.controller;

import std.conv : to;
import std.string : split, startsWith;
import vibe.data.json : Json, serializeToJsonString;
import vibe.http.common : HTTPStatus;
import vibe.http.router : URLRouter;
import vibe.http.server : HTTPServerRequest, HTTPServerResponse;

import uim.infrastructure.gardener.application.dtos :
    DiscoveryView,
    ErrorView,
    ProjectCreateCommand,
    ProjectView,
    GardenCreateCommand,
    GardenView,
    HealthView,
    RootView,
    SecretCreateCommand,
    SecretView,
    CertificateCreateCommand,
    CertificateView,
    SeedCreateCommand,
    SeedView,
    ShootCreateCommand,
    ShootReconcileCommand,
    ShootStatusCommand,
    ShootView;
import uim.infrastructure.gardener.application.usecases :
    CreateGardenUseCase,
    CreateProjectUseCase,
    CreateSecretUseCase,
    CreateCertificateUseCase,
    CreateSeedUseCase,
    CreateShootUseCase,
    DeleteGardenUseCase,
    DeleteProjectUseCase,
    DeleteSecretUseCase,
    DeleteCertificateUseCase,
    DeleteSeedUseCase,
    DeleteShootUseCase,
    GetGardenUseCase,
    GetProjectUseCase,
    GetSecretUseCase,
    GetCertificateUseCase,
    GetSeedUseCase,
    GetShootUseCase,
    ListGardensUseCase,
    ListProjectsUseCase,
    ListSecretsUseCase,
    ListCertificatesUseCase,
    ListSeedsUseCase,
    ListShootsUseCase,
    ReconcileShootUseCase,
    UpdateShootStatusUseCase;
import uim.infrastructure.gardener.domain.entities : Garden, Project, Secret, Certificate, Seed, Shoot;

class GardenerController {
    private CreateGardenUseCase createGardenUC;
    private ListGardensUseCase listGardensUC;
    private GetGardenUseCase getGardenUC;
    private DeleteGardenUseCase deleteGardenUC;

    private CreateProjectUseCase createProjectUC;
    private ListProjectsUseCase listProjectsUC;
    private GetProjectUseCase getProjectUC;
    private DeleteProjectUseCase deleteProjectUC;

    private CreateSecretUseCase createSecretUC;
    private ListSecretsUseCase listSecretsUC;
    private GetSecretUseCase getSecretUC;
    private DeleteSecretUseCase deleteSecretUC;

    private CreateCertificateUseCase createCertificateUC;
    private ListCertificatesUseCase listCertificatesUC;
    private GetCertificateUseCase getCertificateUC;
    private DeleteCertificateUseCase deleteCertificateUC;

    private CreateSeedUseCase createSeedUC;
    private ListSeedsUseCase listSeedsUC;
    private GetSeedUseCase getSeedUC;
    private DeleteSeedUseCase deleteSeedUC;

    private CreateShootUseCase createShootUC;
    private ListShootsUseCase listShootsUC;
    private GetShootUseCase getShootUC;
    private ReconcileShootUseCase reconcileShootUC;
    private UpdateShootStatusUseCase updateShootStatusUC;
    private DeleteShootUseCase deleteShootUC;

    this(
        CreateGardenUseCase createGardenUC,
        ListGardensUseCase listGardensUC,
        GetGardenUseCase getGardenUC,
        DeleteGardenUseCase deleteGardenUC,
        CreateProjectUseCase createProjectUC,
        ListProjectsUseCase listProjectsUC,
        GetProjectUseCase getProjectUC,
        DeleteProjectUseCase deleteProjectUC,
        CreateSecretUseCase createSecretUC,
        ListSecretsUseCase listSecretsUC,
        GetSecretUseCase getSecretUC,
        DeleteSecretUseCase deleteSecretUC,
        CreateCertificateUseCase createCertificateUC,
        ListCertificatesUseCase listCertificatesUC,
        GetCertificateUseCase getCertificateUC,
        DeleteCertificateUseCase deleteCertificateUC,
        CreateSeedUseCase createSeedUC,
        ListSeedsUseCase listSeedsUC,
        GetSeedUseCase getSeedUC,
        DeleteSeedUseCase deleteSeedUC,
        CreateShootUseCase createShootUC,
        ListShootsUseCase listShootsUC,
        GetShootUseCase getShootUC,
        ReconcileShootUseCase reconcileShootUC,
        UpdateShootStatusUseCase updateShootStatusUC,
        DeleteShootUseCase deleteShootUC,
    ) {
        this.createGardenUC = createGardenUC;
        this.listGardensUC = listGardensUC;
        this.getGardenUC = getGardenUC;
        this.deleteGardenUC = deleteGardenUC;

        this.createProjectUC = createProjectUC;
        this.listProjectsUC = listProjectsUC;
        this.getProjectUC = getProjectUC;
        this.deleteProjectUC = deleteProjectUC;

        this.createSecretUC = createSecretUC;
        this.listSecretsUC = listSecretsUC;
        this.getSecretUC = getSecretUC;
        this.deleteSecretUC = deleteSecretUC;

        this.createCertificateUC = createCertificateUC;
        this.listCertificatesUC = listCertificatesUC;
        this.getCertificateUC = getCertificateUC;
        this.deleteCertificateUC = deleteCertificateUC;

        this.createSeedUC = createSeedUC;
        this.listSeedsUC = listSeedsUC;
        this.getSeedUC = getSeedUC;
        this.deleteSeedUC = deleteSeedUC;

        this.createShootUC = createShootUC;
        this.listShootsUC = listShootsUC;
        this.getShootUC = getShootUC;
        this.reconcileShootUC = reconcileShootUC;
        this.updateShootStatusUC = updateShootStatusUC;
        this.deleteShootUC = deleteShootUC;
    }

    void registerRoutes(URLRouter router) {
        router.get("/", &root);
        router.get("/health", &health);
        router.get("/api/v1", &discovery);

        router.get("/api/v1/gardens", &listGardens);
        router.post("/api/v1/gardens", &createGarden);
        router.get("/api/v1/gardens/*", &getGarden);
        router.delete_("/api/v1/gardens/*", &deleteGarden);

        router.get("/api/v1/projects", &listProjects);
        router.post("/api/v1/projects", &createProject);
        router.get("/api/v1/projects/*", &getProject);
        router.delete_("/api/v1/projects/*", &deleteProject);

        router.get("/api/v1/secrets", &listSecrets);
        router.post("/api/v1/secrets", &createSecret);
        router.get("/api/v1/secrets/*", &getSecret);
        router.delete_("/api/v1/secrets/*", &deleteSecret);

        router.get("/api/v1/certificates", &listCertificates);
        router.post("/api/v1/certificates", &createCertificate);
        router.get("/api/v1/certificates/*", &getCertificate);
        router.delete_("/api/v1/certificates/*", &deleteCertificate);

        router.get("/api/v1/seeds", &listSeeds);
        router.post("/api/v1/seeds", &createSeed);
        router.get("/api/v1/seeds/*", &getSeed);
        router.delete_("/api/v1/seeds/*", &deleteSeed);

        router.get("/api/v1/shoots", &listShoots);
        router.post("/api/v1/shoots", &createShoot);
        router.get("/api/v1/shoots/*", &getShoot);
        router.post("/api/v1/shoots/*", &reconcileShoot);
        router.patch("/api/v1/shoots/*", &updateShootStatus);
        router.delete_("/api/v1/shoots/*", &deleteShoot);
    }

    void root(HTTPServerRequest req, HTTPServerResponse res) {
        writeJson(res, serializeToJsonString(RootView(
            "uim-gardener-service",
            "Gardener-inspired cloud control plane service built with vibe.d and D"
        )), HTTPStatus.ok);
    }

    void health(HTTPServerRequest req, HTTPServerResponse res) {
        writeJson(res, serializeToJsonString(HealthView("ok")), HTTPStatus.ok);
    }

    void discovery(HTTPServerRequest req, HTTPServerResponse res) {
        writeJson(res, serializeToJsonString(DiscoveryView(
            "uim-gardener-service",
            "Gardener-inspired cloud control plane service built with vibe.d and D",
            [
                "/health",
                "/api/v1",
                "/api/v1/gardens",
                "/api/v1/projects",
                "/api/v1/secrets",
                "/api/v1/certificates",
                "/api/v1/seeds",
                "/api/v1/shoots"
            ],
            [
                "garden-management",
                "project-management",
                "secret-management",
                "certificate-management",
                "seed-registry",
                "shoot-lifecycle",
                "shoot-reconciliation"
            ]
        )), HTTPStatus.ok);
    }

    void createGarden(HTTPServerRequest req, HTTPServerResponse res) {
        try {
            auto json = req.json;
            auto created = createGardenUC.execute(GardenCreateCommand(
                requiredString(json, "name"),
                optionalString(json, "purpose"),
                requiredString(json, "owner"),
                requiredString(json, "region"),
            ));
            writeJson(res, serializeToJsonString(toGardenView(created)), HTTPStatus.created);
        } catch (Exception ex) {
            writeError(res, ex.msg, HTTPStatus.badRequest);
        }
    }

    void listGardens(HTTPServerRequest req, HTTPServerResponse res) {
        auto gardens = listGardensUC.execute();
        GardenView[] views;
        foreach (garden; gardens) {
            views ~= toGardenView(garden);
        }

        writeJson(res, serializeToJsonString(views), HTTPStatus.ok);
    }

    void getGarden(HTTPServerRequest req, HTTPServerResponse res) {
        auto parts = splitPathAfterPrefix(req.requestPath.to!string, "/api/v1/gardens/");
        if (parts.length != 1) {
            writeError(res, "expected /api/v1/gardens/{name}", HTTPStatus.badRequest);
            return;
        }

        try {
            auto garden = getGardenUC.execute(parts[0]);
            writeJson(res, serializeToJsonString(toGardenView(garden)), HTTPStatus.ok);
        } catch (Exception ex) {
            writeError(res, ex.msg, HTTPStatus.notFound);
        }
    }

    void deleteGarden(HTTPServerRequest req, HTTPServerResponse res) {
        auto parts = splitPathAfterPrefix(req.requestPath.to!string, "/api/v1/gardens/");
        if (parts.length != 1) {
            writeError(res, "expected /api/v1/gardens/{name}", HTTPStatus.badRequest);
            return;
        }

        try {
            deleteGardenUC.execute(parts[0]);
            writeJson(res, `{"status":"deleted"}`, HTTPStatus.ok);
        } catch (Exception ex) {
            writeError(res, ex.msg, HTTPStatus.notFound);
        }
    }

    void createProject(HTTPServerRequest req, HTTPServerResponse res) {
        try {
            auto json = req.json;
            auto created = createProjectUC.execute(ProjectCreateCommand(
                requiredString(json, "name"),
                requiredString(json, "owner"),
                requiredString(json, "region"),
                optionalString(json, "description"),
            ));
            writeJson(res, serializeToJsonString(toProjectView(created)), HTTPStatus.created);
        } catch (Exception ex) {
            writeError(res, ex.msg, HTTPStatus.badRequest);
        }
    }

    void listProjects(HTTPServerRequest req, HTTPServerResponse res) {
        auto projects = listProjectsUC.execute();
        ProjectView[] views;
        foreach (project; projects) {
            views ~= toProjectView(project);
        }

        writeJson(res, serializeToJsonString(views), HTTPStatus.ok);
    }

    void getProject(HTTPServerRequest req, HTTPServerResponse res) {
        auto parts = splitPathAfterPrefix(req.requestPath.to!string, "/api/v1/projects/");
        if (parts.length != 1) {
            writeError(res, "expected /api/v1/projects/{name}", HTTPStatus.badRequest);
            return;
        }

        try {
            auto project = getProjectUC.execute(parts[0]);
            writeJson(res, serializeToJsonString(toProjectView(project)), HTTPStatus.ok);
        } catch (Exception ex) {
            writeError(res, ex.msg, HTTPStatus.notFound);
        }
    }

    void deleteProject(HTTPServerRequest req, HTTPServerResponse res) {
        auto parts = splitPathAfterPrefix(req.requestPath.to!string, "/api/v1/projects/");
        if (parts.length != 1) {
            writeError(res, "expected /api/v1/projects/{name}", HTTPStatus.badRequest);
            return;
        }

        try {
            deleteProjectUC.execute(parts[0]);
            writeJson(res, `{"status":"deleted"}`, HTTPStatus.ok);
        } catch (Exception ex) {
            writeError(res, ex.msg, HTTPStatus.notFound);
        }
    }

    void createSecret(HTTPServerRequest req, HTTPServerResponse res) {
        try {
            auto json = req.json;
            auto created = createSecretUC.execute(SecretCreateCommand(
                requiredString(json, "name"),
                requiredString(json, "namespace"),
                requiredString(json, "type"),
                optionalString(json, "purpose"),
            ));
            writeJson(res, serializeToJsonString(toSecretView(created)), HTTPStatus.created);
        } catch (Exception ex) {
            writeError(res, ex.msg, HTTPStatus.badRequest);
        }
    }

    void listSecrets(HTTPServerRequest req, HTTPServerResponse res) {
        auto secrets = listSecretsUC.execute();
        SecretView[] views;
        foreach (secret; secrets) {
            views ~= toSecretView(secret);
        }

        writeJson(res, serializeToJsonString(views), HTTPStatus.ok);
    }

    void getSecret(HTTPServerRequest req, HTTPServerResponse res) {
        auto parts = splitPathAfterPrefix(req.requestPath.to!string, "/api/v1/secrets/");
        if (parts.length != 1) {
            writeError(res, "expected /api/v1/secrets/{name}", HTTPStatus.badRequest);
            return;
        }

        try {
            auto secret = getSecretUC.execute(parts[0]);
            writeJson(res, serializeToJsonString(toSecretView(secret)), HTTPStatus.ok);
        } catch (Exception ex) {
            writeError(res, ex.msg, HTTPStatus.notFound);
        }
    }

    void deleteSecret(HTTPServerRequest req, HTTPServerResponse res) {
        auto parts = splitPathAfterPrefix(req.requestPath.to!string, "/api/v1/secrets/");
        if (parts.length != 1) {
            writeError(res, "expected /api/v1/secrets/{name}", HTTPStatus.badRequest);
            return;
        }

        try {
            deleteSecretUC.execute(parts[0]);
            writeJson(res, `{"status":"deleted"}`, HTTPStatus.ok);
        } catch (Exception ex) {
            writeError(res, ex.msg, HTTPStatus.notFound);
        }
    }

    void createCertificate(HTTPServerRequest req, HTTPServerResponse res) {
        try {
            auto json = req.json;
            auto created = createCertificateUC.execute(CertificateCreateCommand(
                requiredString(json, "name"),
                requiredString(json, "secretName"),
                requiredString(json, "commonName"),
                optionalString(json, "purpose"),
            ));
            writeJson(res, serializeToJsonString(toCertificateView(created)), HTTPStatus.created);
        } catch (Exception ex) {
            writeError(res, ex.msg, HTTPStatus.badRequest);
        }
    }

    void listCertificates(HTTPServerRequest req, HTTPServerResponse res) {
        auto certificates = listCertificatesUC.execute();
        CertificateView[] views;
        foreach (certificate; certificates) {
            views ~= toCertificateView(certificate);
        }

        writeJson(res, serializeToJsonString(views), HTTPStatus.ok);
    }

    void getCertificate(HTTPServerRequest req, HTTPServerResponse res) {
        auto parts = splitPathAfterPrefix(req.requestPath.to!string, "/api/v1/certificates/");
        if (parts.length != 1) {
            writeError(res, "expected /api/v1/certificates/{name}", HTTPStatus.badRequest);
            return;
        }

        try {
            auto certificate = getCertificateUC.execute(parts[0]);
            writeJson(res, serializeToJsonString(toCertificateView(certificate)), HTTPStatus.ok);
        } catch (Exception ex) {
            writeError(res, ex.msg, HTTPStatus.notFound);
        }
    }

    void deleteCertificate(HTTPServerRequest req, HTTPServerResponse res) {
        auto parts = splitPathAfterPrefix(req.requestPath.to!string, "/api/v1/certificates/");
        if (parts.length != 1) {
            writeError(res, "expected /api/v1/certificates/{name}", HTTPStatus.badRequest);
            return;
        }

        try {
            deleteCertificateUC.execute(parts[0]);
            writeJson(res, `{"status":"deleted"}`, HTTPStatus.ok);
        } catch (Exception ex) {
            writeError(res, ex.msg, HTTPStatus.notFound);
        }
    }

    void createSeed(HTTPServerRequest req, HTTPServerResponse res) {
        try {
            auto json = req.json;
            auto created = createSeedUC.execute(SeedCreateCommand(
                requiredString(json, "name"),
                requiredString(json, "provider"),
                requiredString(json, "region"),
                optionalString(json, "kubeconfigRef"),
            ));
            writeJson(res, serializeToJsonString(toSeedView(created)), HTTPStatus.created);
        } catch (Exception ex) {
            writeError(res, ex.msg, HTTPStatus.badRequest);
        }
    }

    void listSeeds(HTTPServerRequest req, HTTPServerResponse res) {
        auto seeds = listSeedsUC.execute();
        SeedView[] views;
        foreach (seed; seeds) {
            views ~= toSeedView(seed);
        }

        writeJson(res, serializeToJsonString(views), HTTPStatus.ok);
    }

    void getSeed(HTTPServerRequest req, HTTPServerResponse res) {
        auto parts = splitPathAfterPrefix(req.requestPath.to!string, "/api/v1/seeds/");
        if (parts.length != 1) {
            writeError(res, "expected /api/v1/seeds/{name}", HTTPStatus.badRequest);
            return;
        }

        try {
            auto seed = getSeedUC.execute(parts[0]);
            writeJson(res, serializeToJsonString(toSeedView(seed)), HTTPStatus.ok);
        } catch (Exception ex) {
            writeError(res, ex.msg, HTTPStatus.notFound);
        }
    }

    void deleteSeed(HTTPServerRequest req, HTTPServerResponse res) {
        auto parts = splitPathAfterPrefix(req.requestPath.to!string, "/api/v1/seeds/");
        if (parts.length != 1) {
            writeError(res, "expected /api/v1/seeds/{name}", HTTPStatus.badRequest);
            return;
        }

        try {
            deleteSeedUC.execute(parts[0]);
            writeJson(res, `{"status":"deleted"}`, HTTPStatus.ok);
        } catch (Exception ex) {
            writeError(res, ex.msg, HTTPStatus.notFound);
        }
    }

    void createShoot(HTTPServerRequest req, HTTPServerResponse res) {
        try {
            auto json = req.json;
            auto created = createShootUC.execute(ShootCreateCommand(
                requiredString(json, "name"),
                requiredString(json, "projectName"),
                requiredString(json, "gardenName"),
                requiredString(json, "seedName"),
                requiredString(json, "region"),
                requiredString(json, "kubernetesVersion"),
                optionalString(json, "purpose"),
            ));
            writeJson(res, serializeToJsonString(toShootView(created)), HTTPStatus.created);
        } catch (Exception ex) {
            writeError(res, ex.msg, HTTPStatus.badRequest);
        }
    }

    void reconcileShoot(HTTPServerRequest req, HTTPServerResponse res) {
        auto parts = splitPathAfterPrefix(req.requestPath.to!string, "/api/v1/shoots/");
        if (parts.length != 2 || parts[1] != "reconcile") {
            writeError(res, "expected /api/v1/shoots/{name}/reconcile", HTTPStatus.badRequest);
            return;
        }

        try {
            auto json = req.json;
            auto reason = optionalString(json, "reason");
            auto updated = reconcileShootUC.execute(parts[0], ShootReconcileCommand(reason));
            writeJson(res, serializeToJsonString(toShootView(updated)), HTTPStatus.ok);
        } catch (Exception ex) {
            writeError(res, ex.msg, HTTPStatus.notFound);
        }
    }

    void listShoots(HTTPServerRequest req, HTTPServerResponse res) {
        auto shoots = listShootsUC.execute();
        ShootView[] views;
        foreach (shoot; shoots) {
            views ~= toShootView(shoot);
        }

        writeJson(res, serializeToJsonString(views), HTTPStatus.ok);
    }

    void getShoot(HTTPServerRequest req, HTTPServerResponse res) {
        auto parts = splitPathAfterPrefix(req.requestPath.to!string, "/api/v1/shoots/");
        if (parts.length != 1) {
            writeError(res, "expected /api/v1/shoots/{name}", HTTPStatus.badRequest);
            return;
        }

        try {
            auto shoot = getShootUC.execute(parts[0]);
            writeJson(res, serializeToJsonString(toShootView(shoot)), HTTPStatus.ok);
        } catch (Exception ex) {
            writeError(res, ex.msg, HTTPStatus.notFound);
        }
    }

    void updateShootStatus(HTTPServerRequest req, HTTPServerResponse res) {
        auto parts = splitPathAfterPrefix(req.requestPath.to!string, "/api/v1/shoots/");
        if (parts.length != 2 || parts[1] != "status") {
            writeError(res, "expected /api/v1/shoots/{name}/status", HTTPStatus.badRequest);
            return;
        }

        try {
            auto json = req.json;
            auto updated = updateShootStatusUC.execute(parts[0], ShootStatusCommand(requiredString(json, "state")));
            writeJson(res, serializeToJsonString(toShootView(updated)), HTTPStatus.ok);
        } catch (Exception ex) {
            writeError(res, ex.msg, HTTPStatus.badRequest);
        }
    }

    void deleteShoot(HTTPServerRequest req, HTTPServerResponse res) {
        auto parts = splitPathAfterPrefix(req.requestPath.to!string, "/api/v1/shoots/");
        if (parts.length != 1) {
            writeError(res, "expected /api/v1/shoots/{name}", HTTPStatus.badRequest);
            return;
        }

        try {
            deleteShootUC.execute(parts[0]);
            writeJson(res, `{"status":"deleted"}`, HTTPStatus.ok);
        } catch (Exception ex) {
            writeError(res, ex.msg, HTTPStatus.notFound);
        }
    }

    private GardenView toGardenView(Garden garden) {
        return GardenView(garden.id, garden.name, garden.purpose, garden.owner, garden.region, garden.state, garden.createdAt, garden.updatedAt);
    }

    private ProjectView toProjectView(Project project) {
        return ProjectView(project.id, project.name, project.owner, project.region, project.description, project.state, project.createdAt, project.updatedAt);
    }

    private SecretView toSecretView(Secret secret) {
        return SecretView(secret.id, secret.name, secret.namespace_, secret.type, secret.purpose, secret.state, secret.createdAt, secret.updatedAt);
    }

    private CertificateView toCertificateView(Certificate certificate) {
        return CertificateView(certificate.id, certificate.name, certificate.secretName, certificate.commonName, certificate.purpose, certificate.state, certificate.createdAt, certificate.updatedAt);
    }

    private SeedView toSeedView(Seed seed) {
        return SeedView(seed.id, seed.name, seed.provider, seed.region, seed.kubeconfigRef, seed.state, seed.createdAt, seed.updatedAt);
    }

    private ShootView toShootView(Shoot shoot) {
        return ShootView(shoot.id, shoot.name, shoot.projectName, shoot.gardenName, shoot.seedName, shoot.region, shoot.kubernetesVersion, shoot.purpose, shoot.state, shoot.createdAt, shoot.updatedAt);
    }

    private string requiredString(Json json, string key) {
        auto value = key in json;
        if (value is null || value.type == Json.Type.undefined || value.type != Json.Type.string) {
            throw new Exception(key ~ " is required");
        }

        auto result = value.get!string;
        if (result.length == 0) {
            throw new Exception(key ~ " is required");
        }

        return result;
    }

    private string optionalString(Json json, string key, string fallback = "") {
        auto value = key in json;
        if (value is null || value.type == Json.Type.undefined || value.type != Json.Type.string) {
            return fallback;
        }

        return value.get!string;
    }

    private string[] splitPathAfterPrefix(string requestPath, string prefix) {
        if (!requestPath.startsWith(prefix)) {
            return [];
        }

        return split(requestPath[prefix.length .. $], "/");
    }

    private void writeJson(HTTPServerResponse res, string body, HTTPStatus status) {
        res.writeBody(body, cast(int) status, "application/json");
    }

    private void writeError(HTTPServerResponse res, string message, HTTPStatus status) {
        writeJson(res, serializeToJsonString(ErrorView(message)), status);
    }
}
