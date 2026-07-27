/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.kafka.application.usecases.delete_consumer_group;

import uim.infrastructure.kafka.domain.ports.repositories.consumer_group : IConsumerGroupRepository;

class DeleteConsumerGroupUseCase {
    private IConsumerGroupRepository repo;

    this(IConsumerGroupRepository repo) {
        this.repo = repo;
    }

    bool execute(string groupId) {
        auto existing = repo.findByGroupId(groupId);
        if (existing is null) return false;
        repo.deleteByGroupId(groupId);
        return true;
    }
}
