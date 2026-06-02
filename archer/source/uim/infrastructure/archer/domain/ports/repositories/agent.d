module uim.infrastructure.archer.domain.ports.repositories.agent;

import uim.infrastructure.archer.domain.entities.agent : ArcherAgent;

interface IAgentRepository {
    ArcherAgent[] list();
    ArcherAgent* findByHost(string host);
}
