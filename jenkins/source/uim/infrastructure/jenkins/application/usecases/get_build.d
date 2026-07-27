/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.jenkins.application.usecases.get_build;

import jenkins_service.application.dto.commands : GetBuildQuery;
import jenkins_service.domain.entities.build : Build;
import jenkins_service.domain.ports.build_repository : IBuildRepository;

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
