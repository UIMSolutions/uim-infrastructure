/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.ui5server.application.usecases.delete_project;

import uim.infrastructure.ui5server.domain.ports.repositories.project : IProjectRepository;

class DeleteProjectUseCase {
    private IProjectRepository repo;

    this(IProjectRepository repo) {
        this.repo = repo;
    }

    bool execute(string id) {
        return repo.remove(id);
    }
}
