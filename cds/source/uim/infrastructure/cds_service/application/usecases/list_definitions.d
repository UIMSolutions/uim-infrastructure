module uim.infrastructure.cds_service.application.usecases.list_definitions;

import uim.infrastructure.cds_service.domain.entities.cds_definition : CdsDefinition;
import uim.infrastructure.cds_service.domain.ports.repositories.cds_definition_repository :
    ICdsDefinitionRepository;

class ListDefinitionsUseCase {
    private ICdsDefinitionRepository repository;

    this(ICdsDefinitionRepository repository) {
        this.repository = repository;
    }

    CdsDefinition[] execute() {
        return repository.listAll();
    }
}
