/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.keppel.application.usecases.get_repository;

import uim.infrastructure.keppel.domain.entities.repository : Repository;
import uim.infrastructure.keppel.domain.ports.repositories.registry_catalog : IRegistryCatalogRepository;

class GetRepositoryUseCase {
    private IRegistryCatalogRepository repository;

    this(IRegistryCatalogRepository repository) {
        this.repository = repository;
    }

    Repository* execute(string name) {
        return repository.findByName(name);
    }
}
