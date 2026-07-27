/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
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
