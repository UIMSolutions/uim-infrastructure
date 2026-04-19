module app;

import jenkins_service.application.use_cases.create_pipeline : CreatePipelineUseCase;
import jenkins_service.application.use_cases.list_pipelines : ListPipelinesUseCase;
import jenkins_service.application.use_cases.get_pipeline : GetPipelineUseCase;
import jenkins_service.application.use_cases.delete_pipeline : DeletePipelineUseCase;
import jenkins_service.application.use_cases.trigger_build : TriggerBuildUseCase;
import jenkins_service.application.use_cases.get_build : GetBuildUseCase;
import jenkins_service.application.use_cases.list_builds : ListBuildsUseCase;
import jenkins_service.infrastructure.http.jenkins_controller : JenkinsController;
import jenkins_service.infrastructure.persistence.in_memory_pipeline_repository : InMemoryPipelineRepository;
import jenkins_service.infrastructure.persistence.in_memory_build_repository : InMemoryBuildRepository;
import std.conv : to;
import std.exception : collectException;
import std.string : fromStringz;
import core.stdc.stdlib : getenv;
import vibe.vibe;

void main() {
    auto settings = new HTTPServerSettings;
    settings.port = readPort();
    settings.bindAddresses = [readBindAddress()];

    auto pipelineRepo = new InMemoryPipelineRepository();
    auto buildRepo = new InMemoryBuildRepository();

    auto controller = new JenkinsController(
        new CreatePipelineUseCase(pipelineRepo),
        new ListPipelinesUseCase(pipelineRepo),
        new GetPipelineUseCase(pipelineRepo),
        new DeletePipelineUseCase(pipelineRepo),
        new TriggerBuildUseCase(pipelineRepo, buildRepo),
        new GetBuildUseCase(buildRepo),
        new ListBuildsUseCase(buildRepo),
    );

    auto router = new URLRouter;
    controller.registerRoutes(router);

    logInfo("Jenkins service starting on %s:%d", settings.bindAddresses[0], settings.port);
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
