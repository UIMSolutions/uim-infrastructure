module uim.infrastructure.odata.application.usecases.query_entities;

import std.conv : to;
import uim.infrastructure.odata.domain.entities.query_options : QueryOptions;
import uim.infrastructure.odata.domain.ports.repositories.entity : IEntityRepository;
import uim.infrastructure.odata.application.dtos.entity;

class QueryEntitiesUseCase {
    private IEntityRepository repo;

    this(IEntityRepository repo) {
        this.repo = repo;
    }

    EntityCollectionResponseDTO execute(string entitySetName, in QueryOptions options) {
        auto entities = repo.query(entitySetName, options);
        ulong totalCount = 0;
        if (options.count) {
            totalCount = repo.count(entitySetName);
        }

        EntityResponseDTO[] results;
        foreach (e; entities) {
            results ~= EntityResponseDTO(
                e.entitySetName,
                e.entityTypeName,
                e.id,
                e.properties.dup,
            );
        }

        return EntityCollectionResponseDTO(
            "$metadata#" ~ entitySetName,
            totalCount,
            options.count,
            results,
        );
    }
}
