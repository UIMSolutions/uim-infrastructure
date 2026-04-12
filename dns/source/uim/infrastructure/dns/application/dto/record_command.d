module dns_service.application.dto.record_command;

struct RegisterRecordCommand {
    string zone;
    string name;
    string recordType;
    string value;
    uint ttl;
}

struct ResolveRecordQuery {
    string zone;
    string name;
    string recordType;
}
