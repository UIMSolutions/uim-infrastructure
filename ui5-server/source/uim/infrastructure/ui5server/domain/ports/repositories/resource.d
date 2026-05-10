module uim.infrastructure.ui5server.domain.ports.repositories.resource;

import uim.infrastructure.ui5server.domain.entities.resource : Resource;

interface IResourceRepository {
    bool save(Resource resource);
    Resource* findByPath(string path);
    Resource[] findByDirectory(string directoryPath);
    Resource[] findAll();
    bool remove(string path);
    bool exists(string path);
}
