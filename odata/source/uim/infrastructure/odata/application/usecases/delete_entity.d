/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.odata.application.usecases.delete_entity;

import uim.infrastructure.odata.domain.ports.repositories.entity : IEntityRepository;

class DeleteEntityUseCase {
    private IEntityRepository repo;

    this(IEntityRepository repo) {
        this.repo = repo;
    }

    bool execute(string entitySetName, string id) {
        auto existing = repo.findById(entitySetName, id);
        if (existing is null) return false;
        repo.deleteById(entitySetName, id);
        return true;
    }
}
