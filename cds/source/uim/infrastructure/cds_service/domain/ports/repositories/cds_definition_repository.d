module uim.infrastructure.cds_service.domain.ports.repositories.cds_definition_repository;

import uim.infrastructure.cds_service.domain.entities.cds_definition : CdsDefinition, MaybeCdsDefinition;

interface ICdsDefinitionRepository {
    CdsDefinition add(CdsDefinition definition);
    CdsDefinition[] listAll();
    MaybeCdsDefinition getById(string id);
    bool removeById(string id);
}
