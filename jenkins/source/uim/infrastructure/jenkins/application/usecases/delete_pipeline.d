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
