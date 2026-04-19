module uim.infrastructure.odata.application.usecases.list_entity_sets;

import std.algorithm : map;
import std.array : array;
import uim.infrastructure.odata.domain.entities.entity_set : EntitySet;
import uim.infrastructure.odata.domain.ports.repositories.entity_set : IEntitySetRepository;
import uim.infrastructure.odata.application.dtos.entity_set : EntitySetResponseDTO;

class ListEntitySetsUseCase {
    private IEntitySetRepository repo;

    this(IEntitySetRepository repo) {
        this.repo = repo;
    }

    EntitySetResponseDTO[] execute() {
        return repo.list().map!(es => EntitySetResponseDTO(es.name, es.entityTypeName)).array;
    }
}
