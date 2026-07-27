/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.infobox.application.usecases.list_projects;

import uim.infrastructure.infobox.domain.entities.project : Project;
import uim.infrastructure.infobox.domain.ports.repositories.project : IProjectRepository;

class ListProjectsUseCase {
    private IProjectRepository repository;

    this(IProjectRepository repository) {
        this.repository = repository;
    }

    Project[] execute() {
        return repository.list();
    }
}
