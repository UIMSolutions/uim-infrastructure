/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.odata.application.usecases.update_entity;

import uim.infrastructure.odata.domain.entities.entity : Entity;
import uim.infrastructure.odata.domain.ports.repositories.entity : IEntityRepository;
import uim.infrastructure.odata.application.dtos.entity;

class UpdateEntityUseCase {
    private IEntityRepository repo;

    this(IEntityRepository repo) {
        this.repo = repo;
    }

    bool execute(string entitySetName, string id, in UpdateEntityDTO dto) {
        auto existing = repo.findById(entitySetName, id);
        if (existing is null) return false;

        auto merged = existing.properties.dup;
        foreach (k, v; dto.properties) {
            merged[k] = v;
        }

        auto updated = Entity(
            existing.entitySetName,
            existing.entityTypeName,
            merged,
            existing.id,
        );

        repo.update(entitySetName, id, updated);
        return true;
    }
}
