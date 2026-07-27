/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.ui5server.application.usecases.serve_resource;

import uim.infrastructure.ui5server.domain.ports.repositories.resource : IResourceRepository;
import uim.infrastructure.ui5server.domain.entities.resource : Resource;

class ServeResourceUseCase {
    private IResourceRepository repo;

    this(IResourceRepository repo) {
        this.repo = repo;
    }

    Resource* execute(string path) {
        return repo.findByPath(path);
    }
}
