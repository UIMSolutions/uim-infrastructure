module uim.infrastructure.cds_service.infrastructure.persistence.memory.cds_definition_repository;

import uim.infrastructure.cds_service.domain.entities.cds_definition : CdsDefinition, MaybeCdsDefinition;
import uim.infrastructure.cds_service.domain.ports.repositories.cds_definition_repository :
    ICdsDefinitionRepository;

class InMemoryCdsDefinitionRepository : ICdsDefinitionRepository {
    private CdsDefinition[string] byId;
    private string[] idOrder;

    override CdsDefinition add(CdsDefinition definition) {
        byId[definition.id] = definition;
        idOrder ~= definition.id;
        return definition;
    }

    override CdsDefinition[] listAll() {
        CdsDefinition[] output;
        foreach (id; idOrder) {
            if (auto item = id in byId) {
                output ~= *item;
            }
        }
        return output;
    }

    override MaybeCdsDefinition getById(string id) {
        if (auto item = id in byId) {
            return MaybeCdsDefinition(true, *item);
        }
        return MaybeCdsDefinition(false);
    }

    override bool removeById(string id) {
        if (!byId.remove(id)) {
            return false;
        }

        string[] newOrder;
        foreach (existingId; idOrder) {
            if (existingId != id) {
                newOrder ~= existingId;
            }
        }
        idOrder = newOrder;

        return true;
    }
}
