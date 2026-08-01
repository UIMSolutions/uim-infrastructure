module uim.infrastructure.cds_service.application.usecases.delete_definition;

import uim.infrastructure.cds_service.domain.ports.repositories.cds_definition_repository :
    ICdsDefinitionRepository;
import std.string : strip;

class DeleteDefinitionUseCase {
    private ICdsDefinitionRepository repository;

    this(ICdsDefinitionRepository repository) {
        this.repository = repository;
    }

    void execute(string id) {
        auto normalized = id.strip;
        if (normalized.length == 0) {
            throw new Exception("id is required");
        }

        if (!repository.removeById(normalized)) {
            throw new Exception("definition not found");
        }
    }
}
