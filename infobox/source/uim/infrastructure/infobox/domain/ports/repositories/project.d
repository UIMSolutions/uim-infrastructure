module uim.infrastructure.infobox.domain.ports.repositories.project;

import uim.infrastructure.infobox.domain.entities.project : Project;

interface IProjectRepository {
    void save(in Project project);
    void update(in Project project);
    Project[] list();
    Project* findById(string id);
    void deleteById(string id);
}
