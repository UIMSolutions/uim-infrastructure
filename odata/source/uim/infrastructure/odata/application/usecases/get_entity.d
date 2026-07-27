/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.odata.application.usecases.get_entity;

import uim.infrastructure.odata.domain.ports.repositories.entity : IEntityRepository;
import uim.infrastructure.odata.application.dtos.entity : EntityResponseDTO;

class GetEntityUseCase {
    private IEntityRepository repo;

    this(IEntityRepository repo) {
        this.repo = repo;
    }

    EntityResponseDTO* execute(string entitySetName, string id) {
        auto entity = repo.findById(entitySetName, id);
        if (entity is null) return null;
        return new EntityResponseDTO(
            entity.entitySetName,
            entity.entityTypeName,
            entity.id,
            entity.properties.dup,
        );
    }
}
