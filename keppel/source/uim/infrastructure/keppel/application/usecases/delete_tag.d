/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.keppel.application.usecases.delete_tag;

import uim.infrastructure.keppel.domain.ports.repositories.registry_catalog : IRegistryCatalogRepository;

class DeleteTagUseCase {
    private IRegistryCatalogRepository repository;

    this(IRegistryCatalogRepository repository) {
        this.repository = repository;
    }

    void execute(string repositoryName, string tagName) {
        if (!repository.deleteTag(repositoryName, tagName)) {
            throw new Exception("tag not found");
        }
    }
}
