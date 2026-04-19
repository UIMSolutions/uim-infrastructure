module uim.infrastructure.kafka.application.usecases.list_consumer_groups;

import std.algorithm : map;
import std.array : array;
import uim.infrastructure.kafka.domain.entities.consumer_group : ConsumerGroup;
import uim.infrastructure.kafka.domain.ports.repositories.consumer_group : IConsumerGroupRepository;
import uim.infrastructure.kafka.application.dtos.consumer_group : ConsumerGroupResponseDTO;

class ListConsumerGroupsUseCase {
    private IConsumerGroupRepository repo;

    this(IConsumerGroupRepository repo) {
        this.repo = repo;
    }

    ConsumerGroupResponseDTO[] execute() {
        return repo.list().map!(g => ConsumerGroupResponseDTO(
            g.groupId,
            g.state,
            cast(uint) g.members.length,
            g.createdAt,
        )).array;
    }
}
