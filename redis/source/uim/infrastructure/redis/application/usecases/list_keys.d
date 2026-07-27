/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
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
