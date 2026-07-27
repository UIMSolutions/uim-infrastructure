/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.odata.application.usecases.delete_entity_type;

import uim.infrastructure.odata.domain.ports.repositories.entity_type : IEntityTypeRepository;

class DeleteEntityTypeUseCase {
    private IEntityTypeRepository repo;

    this(IEntityTypeRepository repo) {
        this.repo = repo;
    }

    bool execute(string name) {
        auto existing = repo.findByName(name);
        if (existing is null) return false;
        repo.deleteByName(name);
        return true;
    }
}
