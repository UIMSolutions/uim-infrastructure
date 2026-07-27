/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module redis_service.application.usecases.get_value;

import redis_service.application.dto.cache_command : GetValueCommand;
import redis_service.domain.entities.cache_entry : CacheEntry;
import redis_service.domain.ports.repositories.cache : ICacheRepository;
import std.typecons : Nullable;

class GetValueUseCase {
    private ICacheRepository repository;

    this(ICacheRepository repository) {
        this.repository = repository;
    }

    /// Returns the cache entry, or a null Nullable when the key does not exist
    /// or has expired.
    Nullable!CacheEntry execute(in GetValueCommand command) {
        if (command.key.length == 0) {
            throw new Exception("key must not be empty");
        }
        return repository.get(command.key);
    }
}
