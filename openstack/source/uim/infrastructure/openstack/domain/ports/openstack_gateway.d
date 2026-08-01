module uim.infrastructure.openstack.domain.ports.openstack_gateway;

import uim.infrastructure.openstack.domain.entities.project : Project;
import uim.infrastructure.openstack.domain.entities.server : Server;

interface IOpenStackGateway {
    Project[] listProjects(string token);
    Server[] listServers(string token, string projectId, string region);
    bool rebootServer(string token, string serverId, string rebootType, string region);
}
