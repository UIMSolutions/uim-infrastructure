module uim.infrastructure.kafka.application.usecases.create_consumer_group;

import std.conv : to;
import uim.infrastructure.kafka.domain.entities.consumer_group;
import uim.infrastructure.kafka.domain.ports.repositories.consumer_group : IConsumerGroupRepository;
import uim.infrastructure.kafka.application.dtos.consumer_group;

class CreateConsumerGroupUseCase {
    private IConsumerGroupRepository repo;

    this(IConsumerGroupRepository repo) {
        this.repo = repo;
    }

    ConsumerGroupResponseDTO execute(in CreateConsumerGroupDTO dto) {
        auto existing = repo.findByGroupId(dto.groupId);
        if (existing !is null) {
            throw new Exception("Consumer group '" ~ dto.groupId ~ "' already exists");
        }

        auto group = ConsumerGroup(
            dto.groupId,
            [],
            "Empty",
            "2026-04-19T00:00:00Z",
        );

        repo.save(group);

        return ConsumerGroupResponseDTO(
            group.groupId,
            group.state,
            cast(uint) group.members.length,
            group.createdAt,
        );
    }
}
