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
