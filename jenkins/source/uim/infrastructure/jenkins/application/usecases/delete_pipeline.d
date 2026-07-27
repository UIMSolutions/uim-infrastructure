/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.jenkins.application.usecases.delete_pipeline;

import jenkins_service.domain.ports.pipeline_repository : IPipelineRepository;

class DeletePipelineUseCase {
    private IPipelineRepository repository;

    this(IPipelineRepository repository) {
        this.repository = repository;
    }

    void execute(string pipelineId) {
        if (pipelineId.length == 0) {
            throw new Exception("pipeline id must not be empty");
        }

        auto existing = repository.findById(pipelineId);
        if (existing is null) {
            throw new Exception("pipeline not found: " ~ pipelineId);
        }

        repository.deleteById(pipelineId);
    }
}
