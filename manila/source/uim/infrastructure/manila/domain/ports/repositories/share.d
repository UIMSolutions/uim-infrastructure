module uim.infrastructure.manila.domain.ports.repositories.share;

import uim.infrastructure.manila.domain.entities.share : Share;

interface IShareRepository {
    void save(Share share);
    Share[] list();
    Share[] listByProject(string projectId);
    Share* findById(string id);
    void remove(string id);
}