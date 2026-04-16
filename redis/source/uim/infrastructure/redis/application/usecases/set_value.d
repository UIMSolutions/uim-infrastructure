module redis_service.application.usecases.set_value;

import redis_service.application.dto.cache_command : SetValueCommand;
import redis_service.domain.entities.cache_entry : CacheEntry;
import redis_service.domain.ports.repositories.cache : ICacheRepository;
import std.datetime.systime : Clock;

class SetValueUseCase {
    private ICacheRepository repository;

    this(ICacheRepository repository) {
        this.repository = repository;
    }

    CacheEntry execute(in SetValueCommand command) {
        enforceCommand(command);

        long expiresAtUnixMs = 0;
        if (command.ttlSeconds > 0) {
            expiresAtUnixMs = (Clock.currTime().toUnixTime!long + command.ttlSeconds) * 1000;
        }

        auto entry = CacheEntry(command.key, command.value, expiresAtUnixMs);
        repository.set(entry);
        return entry;
    }

    private void enforceCommand(in SetValueCommand command) {
        if (command.key.length == 0) {
            throw new Exception("key must not be empty");
        }
    }
}
