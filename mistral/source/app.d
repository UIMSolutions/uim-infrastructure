module app;

import std.conv : to;
import std.process : environment;

import vibe.vibe;

import uim.infrastructure.mistral.application.usecases.workflow_usecases : WorkflowUseCases;
import uim.infrastructure.mistral.infrastructure.http.controllers.mistral : MistralController;
import uim.infrastructure.mistral.infrastructure.persistence.memory.workflow_engine_repository : InMemoryWorkflowEngineRepository;

shared static this() {
    const bindAddress = environment.get("BIND_ADDRESS", "0.0.0.0");
    const port = environment.get("PORT", "8080").to!ushort;

    auto router = new URLRouter;

    auto repository = new InMemoryWorkflowEngineRepository();
    auto useCases = new WorkflowUseCases(repository);
    auto controller = new MistralController(useCases);
    controller.register(router);

    auto settings = new HTTPServerSettings;
    settings.port = port;
    settings.bindAddresses = [bindAddress];

    listenHTTP(settings, router);

    logInfo("uim-mistral-service listening on %s:%s", bindAddress, port);
}

void main() {
    runApplication();
}
