module redis_service.application.dto.cache_command;

struct SetValueCommand {
    string key;
    string value;
    uint ttlSeconds;
}

struct GetValueCommand {
    string key;
}

struct DeleteValueCommand {
    string key;
}
