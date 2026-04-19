module uim.infrastructure.odata.application.usecases.create_function_import;

import std.conv : to;
import uim.infrastructure.odata.domain.entities.function_import;
import uim.infrastructure.odata.domain.ports.repositories.function_import : IFunctionImportRepository;
import uim.infrastructure.odata.application.dtos.function_import;

class CreateFunctionImportUseCase {
    private IFunctionImportRepository repo;

    this(IFunctionImportRepository repo) {
        this.repo = repo;
    }

    FunctionImportResponseDTO execute(in CreateFunctionImportDTO dto) {
        auto existing = repo.findByName(dto.name);
        if (existing !is null) {
            throw new Exception("FunctionImport '" ~ dto.name ~ "' already exists");
        }

        Parameter[] params;
        foreach (p; dto.parameters) {
            params ~= Parameter(p.name, p.type, p.nullable);
        }

        auto opType = dto.operationType == "action" ? OperationType.action : OperationType.function_;

        auto fi = FunctionImport(
            dto.name,
            opType,
            dto.returnType,
            dto.isBound,
            dto.boundToType,
            params,
        );

        repo.save(fi);

        ParameterDTO[] paramDTOs;
        foreach (p; fi.parameters) {
            paramDTOs ~= ParameterDTO(p.name, p.type, p.nullable);
        }

        return FunctionImportResponseDTO(
            fi.name,
            fi.operationType.to!string,
            fi.returnType,
            fi.isBound,
            fi.boundToType,
            paramDTOs,
        );
    }
}
