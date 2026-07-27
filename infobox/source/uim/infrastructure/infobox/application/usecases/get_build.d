/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.infobox.application.usecases.get_build;

import uim.infrastructure.infobox.application.dto.commands : GetBuildQuery;
import uim.infrastructure.infobox.domain.entities.build : Build;
import uim.infrastructure.infobox.domain.ports.repositories.build : IBuildRepository;

class GetBuildUseCase {
    private IBuildRepository repository;

    this(IBuildRepository repository) {
        this.repository = repository;
    }

    Build execute(in GetBuildQuery query) {
        if (query.id.length == 0) {
            throw new Exception("build id must not be empty");
        }

        auto result = repository.findById(query.id);
        if (result is null) {
            throw new Exception("build not found: " ~ query.id);
        }
        return *result;
    }
}
