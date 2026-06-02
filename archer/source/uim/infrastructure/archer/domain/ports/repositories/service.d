module uim.infrastructure.archer.domain.ports.repositories.service;

import uim.infrastructure.archer.domain.entities.service : ArcherService;

interface IServiceRepository {
    void save(in ArcherService service);
    ArcherService[] list();
    ArcherService* findById(string id);
    void remove(string id);
}
