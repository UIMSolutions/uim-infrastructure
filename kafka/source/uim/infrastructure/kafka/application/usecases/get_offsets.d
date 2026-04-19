module uim.infrastructure.kafka.application.usecases.get_offsets;

import std.algorithm : map;
import std.array : array;
import uim.infrastructure.kafka.domain.ports.repositories.consumer_group : IConsumerGroupRepository;
import uim.infrastructure.kafka.application.dtos.consumer_group : ConsumerOffsetResponseDTO;

class GetOffsetsUseCase {
    private IConsumerGroupRepository repo;

    this(IConsumerGroupRepository repo) {
        this.repo = repo;
    }

    ConsumerOffsetResponseDTO[] execute(string groupId, string topic) {
        return repo.getOffsets(groupId, topic).map!(o => ConsumerOffsetResponseDTO(
            o.groupId,
            o.topic,
            o.partition,
            o.committedOffset,
            o.logEndOffset,
            o.lag,
        )).array;
    }
}
