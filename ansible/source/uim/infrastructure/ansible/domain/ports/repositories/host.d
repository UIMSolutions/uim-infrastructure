module uim.infrastructure.ansible.domain.ports.repositories.host;

import uim.infrastructure.ansible.domain.entities.host : Host;

interface IHostRepository {
    void save(in Host host);
    void remove(string id);
    Host[] list();
    Host* findById(string id);
    Host[] findByGroup(string groupName);
}
