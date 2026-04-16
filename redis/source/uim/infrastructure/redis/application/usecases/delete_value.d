module redis_service.application.usecases.delete_value;

import redis_service.application.dto.cache_command : DeleteValueCommand;
import redis_service.domain.ports.repositories.cache : ICacheRepository;

class DeleteValueUseCase {
    private ICacheRepository repository;

    this(ICacheRepository repository) {
        this.repository = repository;
    }

    void execute(in DeleteValueCommand command) {
        if (command.key.length == 0) {
            throw new Exception("key must not be empty");
        }
        repository.remove(command.key);
    }
}
