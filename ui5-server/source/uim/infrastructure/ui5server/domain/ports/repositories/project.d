module uim.infrastructure.ui5server.domain.ports.repositories.project;

import uim.infrastructure.ui5server.domain.entities.project : Project;

interface IProjectRepository {
    bool save(Project project);
    Project* findById(string id);
    Project* findByName(string name);
    Project[] findAll();
    bool remove(string id);
}
