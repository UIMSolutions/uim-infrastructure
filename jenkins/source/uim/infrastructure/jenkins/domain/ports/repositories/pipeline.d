module uim.infrastructure.jenkins.domain.ports.repositories.pipeline;

import jenkins_service.domain.entities.pipeline : Pipeline;

interface IPipelineRepository {
    void save(in Pipeline pipeline);
    Pipeline[] list();
    Pipeline* findById(string id);
    void deleteById(string id);
}
