module app;

import vibe.http.router : URLRouter;
import vibe.http.server : HTTPServerSettings;
import vibe.core.core : runApplication;

import uim.infrastructure.odata.infrastructure.adapters.inmemory.entity_type_repository : InMemoryEntityTypeRepository;
import uim.infrastructure.odata.infrastructure.adapters.inmemory.entity_set_repository : InMemoryEntitySetRepository;
import uim.infrastructure.odata.infrastructure.adapters.inmemory.entity_repository : InMemoryEntityRepository;
import uim.infrastructure.odata.infrastructure.adapters.inmemory.function_import_repository : InMemoryFunctionImportRepository;

import uim.infrastructure.odata.application.usecases.create_entity_type : CreateEntityTypeUseCase;
import uim.infrastructure.odata.application.usecases.list_entity_types : ListEntityTypesUseCase;
import uim.infrastructure.odata.application.usecases.delete_entity_type : DeleteEntityTypeUseCase;
import uim.infrastructure.odata.application.usecases.create_entity_set : CreateEntitySetUseCase;
import uim.infrastructure.odata.application.usecases.list_entity_sets : ListEntitySetsUseCase;
import uim.infrastructure.odata.application.usecases.delete_entity_set : DeleteEntitySetUseCase;
import uim.infrastructure.odata.application.usecases.create_entity : CreateEntityUseCase;
import uim.infrastructure.odata.application.usecases.get_entity : GetEntityUseCase;
import uim.infrastructure.odata.application.usecases.query_entities : QueryEntitiesUseCase;
import uim.infrastructure.odata.application.usecases.update_entity : UpdateEntityUseCase;
import uim.infrastructure.odata.application.usecases.delete_entity : DeleteEntityUseCase;
import uim.infrastructure.odata.application.usecases.get_service_document : GetServiceDocumentUseCase;
import uim.infrastructure.odata.application.usecases.create_function_import : CreateFunctionImportUseCase;
import uim.infrastructure.odata.application.usecases.list_function_imports : ListFunctionImportsUseCase;

import uim.infrastructure.odata.infrastructure.adapters.http.controller : ODataController;

void main() {
    // --- Outbound adapters (repositories) ---
    auto entityTypeRepo = new InMemoryEntityTypeRepository();
    auto entitySetRepo = new InMemoryEntitySetRepository();
    auto entityRepo = new InMemoryEntityRepository();
    auto funcImportRepo = new InMemoryFunctionImportRepository();

    // --- Application use cases ---
    auto createEntityTypeUC = new CreateEntityTypeUseCase(entityTypeRepo);
    auto listEntityTypesUC = new ListEntityTypesUseCase(entityTypeRepo);
    auto deleteEntityTypeUC = new DeleteEntityTypeUseCase(entityTypeRepo);
    auto createEntitySetUC = new CreateEntitySetUseCase(entitySetRepo, entityTypeRepo);
    auto listEntitySetsUC = new ListEntitySetsUseCase(entitySetRepo);
    auto deleteEntitySetUC = new DeleteEntitySetUseCase(entitySetRepo);
    auto createEntityUC = new CreateEntityUseCase(entityRepo, entitySetRepo, entityTypeRepo);
    auto getEntityUC = new GetEntityUseCase(entityRepo);
    auto queryEntitiesUC = new QueryEntitiesUseCase(entityRepo);
    auto updateEntityUC = new UpdateEntityUseCase(entityRepo);
    auto deleteEntityUC = new DeleteEntityUseCase(entityRepo);
    auto getServiceDocUC = new GetServiceDocumentUseCase(entitySetRepo, funcImportRepo);
    auto createFuncImportUC = new CreateFunctionImportUseCase(funcImportRepo);
    auto listFuncImportsUC = new ListFunctionImportsUseCase(funcImportRepo);

    // --- Inbound adapter (HTTP controller) ---
    auto controller = new ODataController(
        createEntityTypeUC,
        listEntityTypesUC,
        deleteEntityTypeUC,
        createEntitySetUC,
        listEntitySetsUC,
        deleteEntitySetUC,
        createEntityUC,
        getEntityUC,
        queryEntitiesUC,
        updateEntityUC,
        deleteEntityUC,
        getServiceDocUC,
        createFuncImportUC,
        listFuncImportsUC,
    );

    auto router = new URLRouter();
    controller.registerRoutes(router);

    auto settings = new HTTPServerSettings();
    settings.port = 8080;
    settings.bindAddresses = ["0.0.0.0"];

    auto listener = listenHTTP(settings, router);
    scope(exit) listener.stopListening();

    import vibe.core.log : logInfo;
    logInfo("UIM OData Service running on http://0.0.0.0:8080");

    runApplication();
}

private auto listenHTTP(HTTPServerSettings settings, URLRouter router) {
    import vibe.http.server : listenHTTP;
    return listenHTTP(settings, router);
}
