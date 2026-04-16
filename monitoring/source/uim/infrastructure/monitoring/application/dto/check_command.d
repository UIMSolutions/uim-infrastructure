module monitoring_service.application.dto.check_command;

struct RegisterCheckCommand {
    string id;
    string name;
    string host;
    ushort port;
    uint intervalSecs;
}

struct DeregisterCheckCommand {
    string id;
}

struct RunCheckCommand {
    string id;
}
