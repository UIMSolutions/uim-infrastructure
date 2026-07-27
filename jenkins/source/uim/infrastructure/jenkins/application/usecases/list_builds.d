/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.jenkins.application.usecases.list_builds;

import jenkins_service.application.dto.commands : ListBuildsQuery;
import jenkins_service.domain.entities.build : Build;
import jenkins_service.domain.ports.build_repository : IBuildRepository;

class ListBuildsUseCase {
    private IBuildRepository repository;

    this(IBuildRepository repository) {
        this.repository = repository;
    }

    Build[] execute(in ListBuildsQuery query) {
        if (query.pipelineId.length == 0) {
            throw new Exception("pipeline id must not be empty");
        }
        return repository.listByPipeline(query.pipelineId);
    }
}
