module uim.infrastructure.ui5server.domain.ports.repositories.server;

import uim.infrastructure.ui5server.domain.entities.server : Server;

interface IServerRepository {
    bool save(Server server);
    Server* findById(string id);
    Server* findByName(string name);
    Server[] findAll();
    bool remove(string id);
    bool updateStatus(string id, uim.infrastructure.ui5server.domain.entities.server.ServerStatus status);
}
