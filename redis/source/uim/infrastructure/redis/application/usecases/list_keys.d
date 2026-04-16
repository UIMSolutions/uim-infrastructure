module redis_service.application.usecases.list_keys;

import redis_service.domain.ports.repositories.cache : ICacheRepository;

class ListKeysUseCase {
    private ICacheRepository repository;

    this(ICacheRepository repository) {
        this.repository = repository;
    }

    string[] execute() {
        return repository.listKeys();
    }
}
