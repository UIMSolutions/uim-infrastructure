module uim.infrastructure.odata.application.usecases.list_function_imports;

import std.algorithm : map;
import std.array : array;
import std.conv : to;
import uim.infrastructure.odata.domain.entities.function_import : FunctionImport;
import uim.infrastructure.odata.domain.ports.repositories.function_import : IFunctionImportRepository;
import uim.infrastructure.odata.application.dtos.function_import;

class ListFunctionImportsUseCase {
    private IFunctionImportRepository repo;

    this(IFunctionImportRepository repo) {
        this.repo = repo;
    }

    FunctionImportResponseDTO[] execute() {
        return repo.list().map!(fi => toResponse(fi)).array;
    }

    private FunctionImportResponseDTO toResponse(in FunctionImport fi) {
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
