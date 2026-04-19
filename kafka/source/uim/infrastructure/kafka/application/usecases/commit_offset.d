module uim.infrastructure.kafka.application.usecases.commit_offset;

import uim.infrastructure.kafka.domain.ports.repositories.consumer_group : IConsumerGroupRepository;
import uim.infrastructure.kafka.application.dtos.consumer_group : CommitOffsetDTO;

class CommitOffsetUseCase {
    private IConsumerGroupRepository repo;

    this(IConsumerGroupRepository repo) {
        this.repo = repo;
    }

    bool execute(in CommitOffsetDTO dto) {
        auto group = repo.findByGroupId(dto.groupId);
        if (group is null) return false;
        repo.commitOffset(dto.groupId, dto.topic, dto.partition, dto.offset);
        return true;
    }
}
