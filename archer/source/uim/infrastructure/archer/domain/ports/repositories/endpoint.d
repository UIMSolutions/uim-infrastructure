module uim.infrastructure.archer.domain.ports.repositories.endpoint;

import uim.infrastructure.archer.domain.entities.endpoint : ArcherEndpoint;

interface IEndpointRepository {
    void save(in ArcherEndpoint endpoint);
    ArcherEndpoint[] list();
    ArcherEndpoint[] listByService(string serviceId);
    ArcherEndpoint* findById(string id);
    void remove(string id);
    void removeByService(string serviceId);
}
