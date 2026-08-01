module uim.infrastructure.openstack.application.usecases.list_projects;

import uim.infrastructure.openstack.domain.entities.project : Project;
import uim.infrastructure.openstack.domain.ports.openstack_gateway : IOpenStackGateway;

class ListProjectsUseCase {
    private IOpenStackGateway gateway;

    this(IOpenStackGateway gateway) {
        this.gateway = gateway;
    }

    Project[] execute(string token) {
        return gateway.listProjects(token);
    }
}
