module uim.infrastructure.openstack.application.usecases.list_servers;

import uim.infrastructure.openstack.domain.entities.server : Server;
import uim.infrastructure.openstack.domain.ports.openstack_gateway : IOpenStackGateway;

class ListServersUseCase {
    private IOpenStackGateway gateway;

    this(IOpenStackGateway gateway) {
        this.gateway = gateway;
    }

    Server[] execute(string token, string projectId, string region) {
        return gateway.listServers(token, projectId, region);
    }
}
