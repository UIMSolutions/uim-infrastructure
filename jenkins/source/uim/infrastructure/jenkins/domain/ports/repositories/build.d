module uim.infrastructure.jenkins.domain.ports.repositories.build;

import jenkins_service.domain.entities.build : Build;

interface IBuildRepository {
    void save(in Build build);
    Build[] listByPipeline(string pipelineId);
    Build* findById(string id);
    uint nextBuildNumber(string pipelineId);
}
