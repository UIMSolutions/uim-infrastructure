module uim.infrastructure.cds_service.application.usecases.get_definition;

import uim.infrastructure.cds_service.domain.entities.cds_definition : MaybeCdsDefinition;
import uim.infrastructure.cds_service.domain.ports.repositories.cds_definition_repository :
    ICdsDefinitionRepository;
import std.string : strip;

class GetDefinitionUseCase {
    private ICdsDefinitionRepository repository;

    this(ICdsDefinitionRepository repository) {
        this.repository = repository;
    }

    MaybeCdsDefinition execute(string id) {
        auto normalized = id.strip;
        if (normalized.length == 0) {
            return MaybeCdsDefinition(false);
        }
        return repository.getById(normalized);
    }
}
