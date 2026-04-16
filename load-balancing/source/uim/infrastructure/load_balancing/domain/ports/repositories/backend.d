module lb_service.domain.ports.repositories.backend;

import lb_service.domain.entities.backend : Backend;

interface IBackendRepository {
    void save(in Backend backend);
    void remove(string id);
    Backend[] list();
    Backend* findById(string id);
}
