module lb_service.application.dto.backend_command;

struct RegisterBackendCommand {
    string id;
    string host;
    ushort port;
    uint weight;
}

struct DeregisterBackendCommand {
    string id;
}
