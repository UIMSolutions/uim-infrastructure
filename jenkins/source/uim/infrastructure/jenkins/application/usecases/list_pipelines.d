/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.jenkins.application.usecases.list_pipelines;

import jenkins_service.domain.entities.pipeline : Pipeline;
import jenkins_service.domain.ports.pipeline_repository : IPipelineRepository;

class ListPipelinesUseCase {
    private IPipelineRepository repository;

    this(IPipelineRepository repository) {
        this.repository = repository;
    }

    Pipeline[] execute() {
        return repository.list();
    }
}
