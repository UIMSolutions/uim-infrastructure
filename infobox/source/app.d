module app;

import uim.infrastructure.infobox.application.usecases.create_project : CreateProjectUseCase;
import uim.infrastructure.infobox.application.usecases.list_projects : ListProjectsUseCase;
import uim.infrastructure.infobox.application.usecases.get_project : GetProjectUseCase;
import uim.infrastructure.infobox.application.usecases.delete_project : DeleteProjectUseCase;
import uim.infrastructure.infobox.application.usecases.trigger_build : TriggerBuildUseCase;
import uim.infrastructure.infobox.application.usecases.get_build : GetBuildUseCase;
import uim.infrastructure.infobox.application.usecases.list_builds : ListBuildsUseCase;
import uim.infrastructure.infobox.application.usecases.create_job : CreateJobUseCase;
import uim.infrastructure.infobox.application.usecases.get_job : GetJobUseCase;
import uim.infrastructure.infobox.application.usecases.list_jobs : ListJobsUseCase;
import uim.infrastructure.infobox.application.usecases.create_secret : CreateSecretUseCase;
import uim.infrastructure.infobox.application.usecases.list_secrets : ListSecretsUseCase;
import uim.infrastructure.infobox.application.usecases.delete_secret : DeleteSecretUseCase;
import uim.infrastructure.infobox.infrastructure.http.controllers.infobox : InfoboxController;
import uim.infrastructure.infobox.infrastructure.persistence.memory.project_repository : InMemoryProjectRepository;
import uim.infrastructure.infobox.infrastructure.persistence.memory.build_repository : InMemoryBuildRepository;
import uim.infrastructure.infobox.infrastructure.persistence.memory.job_repository : InMemoryJobRepository;
import uim.infrastructure.infobox.infrastructure.persistence.memory.secret_repository : InMemorySecretRepository;
import std.conv : to;
import std.exception : collectException;
import std.string : fromStringz;
import core.stdc.stdlib : getenv;
import vibe.vibe;

void main() {
    auto settings = new HTTPServerSettings;
    settings.port = readPort();
    settings.bindAddresses = [readBindAddress()];

    auto projectRepo = new InMemoryProjectRepository();
    auto buildRepo = new InMemoryBuildRepository();
    auto jobRepo = new InMemoryJobRepository();
    auto secretRepo = new InMemorySecretRepository();

    auto controller = new InfoboxController(
        new CreateProjectUseCase(projectRepo),
        new ListProjectsUseCase(projectRepo),
        new GetProjectUseCase(projectRepo),
        new DeleteProjectUseCase(projectRepo),
        new TriggerBuildUseCase(projectRepo, buildRepo),
        new GetBuildUseCase(buildRepo),
        new ListBuildsUseCase(buildRepo),
        new CreateJobUseCase(jobRepo, buildRepo),
        new GetJobUseCase(jobRepo),
        new ListJobsUseCase(jobRepo),
        new CreateSecretUseCase(secretRepo, projectRepo),
        new ListSecretsUseCase(secretRepo),
        new DeleteSecretUseCase(secretRepo),
    );

    auto router = new URLRouter;
    controller.registerRoutes(router);

    logInfo("Infobox service starting on %s:%d", settings.bindAddresses[0], settings.port);
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
