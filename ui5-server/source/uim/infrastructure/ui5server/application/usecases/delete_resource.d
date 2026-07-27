/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.ui5server.application.usecases.delete_resource;

import uim.infrastructure.ui5server.domain.ports.repositories.resource : IResourceRepository;

class DeleteResourceUseCase {
    private IResourceRepository repo;

    this(IResourceRepository repo) {
        this.repo = repo;
    }

    bool execute(string path) {
        return repo.remove(path);
    }
}
