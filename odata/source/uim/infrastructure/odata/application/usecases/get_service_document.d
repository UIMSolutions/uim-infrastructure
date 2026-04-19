module uim.infrastructure.odata.application.usecases.get_service_document;

import std.algorithm : map;
import std.array : array;
import uim.infrastructure.odata.domain.ports.repositories.entity_set : IEntitySetRepository;
import uim.infrastructure.odata.domain.ports.repositories.function_import : IFunctionImportRepository;
import uim.infrastructure.odata.application.dtos.service_document;

class GetServiceDocumentUseCase {
    private IEntitySetRepository entitySetRepo;
    private IFunctionImportRepository funcRepo;

    this(IEntitySetRepository entitySetRepo, IFunctionImportRepository funcRepo) {
        this.entitySetRepo = entitySetRepo;
        this.funcRepo = funcRepo;
    }

    ServiceDocumentResponseDTO execute() {
        auto entitySets = entitySetRepo.list();
        auto funcs = funcRepo.list();

        ServiceEndpointDTO[] endpoints;
        foreach (es; entitySets) {
            endpoints ~= ServiceEndpointDTO(es.name, "EntitySet", es.name);
        }
        foreach (f; funcs) {
            import uim.infrastructure.odata.domain.entities.function_import : OperationType;
            auto kind = f.operationType == OperationType.function_ ? "FunctionImport" : "ActionImport";
            endpoints ~= ServiceEndpointDTO(f.name, kind, f.name);
        }

        return ServiceDocumentResponseDTO("$metadata", endpoints);
    }
}
