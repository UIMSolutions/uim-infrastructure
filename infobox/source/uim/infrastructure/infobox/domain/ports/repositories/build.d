module uim.infrastructure.infobox.domain.ports.repositories.build;

import uim.infrastructure.infobox.domain.entities.build : Build;

interface IBuildRepository {
    void save(in Build build);
    void update(in Build build);
    Build[] listByProject(string projectId);
    Build* findById(string id);
    uint nextBuildNumber(string projectId);
}
