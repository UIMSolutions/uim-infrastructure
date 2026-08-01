module uim.infrastructure.openstack.application.usecases.reboot_server;

import std.string : toLower;
import uim.infrastructure.openstack.application.dto.reboot_server_command : RebootServerCommand;
import uim.infrastructure.openstack.domain.ports.openstack_gateway : IOpenStackGateway;

class RebootServerUseCase {
    private IOpenStackGateway gateway;

    this(IOpenStackGateway gateway) {
        this.gateway = gateway;
    }

    bool execute(RebootServerCommand command) {
        if (command.rebootType.length == 0) {
            command.rebootType = "SOFT";
        }

        auto normalized = command.rebootType.toLower();
        if (normalized != "soft" && normalized != "hard") {
            command.rebootType = "SOFT";
        } else {
            command.rebootType = normalized == "hard" ? "HARD" : "SOFT";
        }

        return gateway.rebootServer(command.token, command.serverId, command.rebootType, command.region);
    }
}
