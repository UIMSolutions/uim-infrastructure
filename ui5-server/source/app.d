module app;

import vibe.http.router : URLRouter;
import vibe.http.server : HTTPServerSettings;
import vibe.core.core : runApplication;

import uim.infrastructure.ui5server.infrastructure.adapters.inmemory.server_repository : InMemoryServerRepository;
import uim.infrastructure.ui5server.infrastructure.adapters.inmemory.middleware_repository : InMemoryMiddlewareRepository;
import uim.infrastructure.ui5server.infrastructure.adapters.inmemory.resource_repository : InMemoryResourceRepository;
import uim.infrastructure.ui5server.infrastructure.adapters.inmemory.project_repository : InMemoryProjectRepository;
import uim.infrastructure.ui5server.infrastructure.adapters.inmemory.csp_report_repository : InMemoryCspReportRepository;

import uim.infrastructure.ui5server.application.usecases.create_server : CreateServerUseCase;
import uim.infrastructure.ui5server.application.usecases.get_server : GetServerUseCase;
import uim.infrastructure.ui5server.application.usecases.list_servers : ListServersUseCase;
import uim.infrastructure.ui5server.application.usecases.delete_server : DeleteServerUseCase;
import uim.infrastructure.ui5server.application.usecases.update_server_status : UpdateServerStatusUseCase;
import uim.infrastructure.ui5server.application.usecases.register_middleware : RegisterMiddlewareUseCase;
import uim.infrastructure.ui5server.application.usecases.list_middleware : ListMiddlewareUseCase;
import uim.infrastructure.ui5server.application.usecases.remove_middleware : RemoveMiddlewareUseCase;
import uim.infrastructure.ui5server.application.usecases.upload_resource : UploadResourceUseCase;
import uim.infrastructure.ui5server.application.usecases.serve_resource : ServeResourceUseCase;
import uim.infrastructure.ui5server.application.usecases.list_resources : ListResourcesUseCase;
import uim.infrastructure.ui5server.application.usecases.delete_resource : DeleteResourceUseCase;
import uim.infrastructure.ui5server.application.usecases.create_project : CreateProjectUseCase;
import uim.infrastructure.ui5server.application.usecases.list_projects : ListProjectsUseCase;
import uim.infrastructure.ui5server.application.usecases.delete_project : DeleteProjectUseCase;
import uim.infrastructure.ui5server.application.usecases.get_csp_reports : GetCspReportsUseCase;

import uim.infrastructure.ui5server.infrastructure.adapters.http.controller : UI5ServerController;

void main() {
    // --- Outbound adapters (repositories) ---
    auto serverRepo = new InMemoryServerRepository();
    auto middlewareRepo = new InMemoryMiddlewareRepository();
    auto resourceRepo = new InMemoryResourceRepository();
    auto projectRepo = new InMemoryProjectRepository();
    auto cspReportRepo = new InMemoryCspReportRepository();

    // --- Application use cases ---
    auto createServerUC = new CreateServerUseCase(serverRepo);
    auto getServerUC = new GetServerUseCase(serverRepo);
    auto listServersUC = new ListServersUseCase(serverRepo);
    auto deleteServerUC = new DeleteServerUseCase(serverRepo);
    auto updateServerStatusUC = new UpdateServerStatusUseCase(serverRepo);
    auto registerMiddlewareUC = new RegisterMiddlewareUseCase(middlewareRepo);
    auto listMiddlewareUC = new ListMiddlewareUseCase(middlewareRepo);
    auto removeMiddlewareUC = new RemoveMiddlewareUseCase(middlewareRepo);
    auto uploadResourceUC = new UploadResourceUseCase(resourceRepo);
    auto serveResourceUC = new ServeResourceUseCase(resourceRepo);
    auto listResourcesUC = new ListResourcesUseCase(resourceRepo);
    auto deleteResourceUC = new DeleteResourceUseCase(resourceRepo);
    auto createProjectUC = new CreateProjectUseCase(projectRepo);
    auto listProjectsUC = new ListProjectsUseCase(projectRepo);
    auto deleteProjectUC = new DeleteProjectUseCase(projectRepo);
    auto getCspReportsUC = new GetCspReportsUseCase(cspReportRepo);

    // --- Inbound adapter (HTTP controller) ---
    auto controller = new UI5ServerController(
        createServerUC,
        getServerUC,
        listServersUC,
        deleteServerUC,
        updateServerStatusUC,
        registerMiddlewareUC,
        listMiddlewareUC,
        removeMiddlewareUC,
        uploadResourceUC,
        serveResourceUC,
        listResourcesUC,
        deleteResourceUC,
        createProjectUC,
        listProjectsUC,
        deleteProjectUC,
        getCspReportsUC,
    );

    auto router = new URLRouter();
    controller.registerRoutes(router);

    auto settings = new HTTPServerSettings();
    settings.port = 8080;
    settings.bindAddresses = ["0.0.0.0"];

    auto listener = listenHTTP(settings, router);
    scope(exit) listener.stopListening();

    import vibe.core.log : logInfo;
    logInfo("UIM UI5 Server Service running on http://0.0.0.0:8080");

    runApplication();
}

private auto listenHTTP(HTTPServerSettings settings, URLRouter router) {
    import vibe.http.server : listenHTTP;
    return listenHTTP(settings, router);
}
