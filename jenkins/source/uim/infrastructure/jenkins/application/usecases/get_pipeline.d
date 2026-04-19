module uim.infrastructure.jenkins.application.usecases.get_pipeline;

import jenkins_service.application.dto.commands : GetPipelineQuery;
import jenkins_service.domain.entities.pipeline : Pipeline;
import jenkins_service.domain.ports.pipeline_repository : IPipelineRepository;

class GetPipelineUseCase {
    private IPipelineRepository repository;

    this(IPipelineRepository repository) {
        this.repository = repository;
    }

    Pipeline execute(in GetPipelineQuery query) {
        if (query.id.length == 0) {
            throw new Exception("pipeline id must not be empty");
        }

        auto result = repository.findById(query.id);
        if (result is null) {
            throw new Exception("pipeline not found: " ~ query.id);
        }
        return *result;
    }
}
