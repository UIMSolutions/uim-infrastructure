module uim.infrastructure.openstack.application.dto.reboot_server_command;

struct RebootServerCommand {
    string token;
    string serverId;
    string rebootType;
    string region;
}
