module uim.infrastructure.kafka.application.usecases.create_topic;

import std.conv : to;
import uim.infrastructure.kafka.domain.entities.topic;
import uim.infrastructure.kafka.domain.ports.repositories.topic : ITopicRepository;
import uim.infrastructure.kafka.application.dtos.topic;

class CreateTopicUseCase {
    private ITopicRepository repo;

    this(ITopicRepository repo) {
        this.repo = repo;
    }

    TopicResponseDTO execute(in CreateTopicDTO dto) {
        auto existing = repo.findByName(dto.name);
        if (existing !is null) {
            throw new Exception("Topic '" ~ dto.name ~ "' already exists");
        }

        auto topicEntity = Topic(
            dto.name,
            TopicConfig(
                dto.numPartitions > 0 ? dto.numPartitions : 1,
                dto.replicationFactor > 0 ? dto.replicationFactor : 1,
                dto.retentionMs > 0 ? dto.retentionMs : 604_800_000,
                dto.retentionBytes,
                dto.cleanupPolicy.length > 0 ? dto.cleanupPolicy : "delete",
            ),
            TopicStatus.active,
            "2026-04-19T00:00:00Z",
        );

        repo.save(topicEntity);

        return toResponse(topicEntity);
    }

    private TopicResponseDTO toResponse(in Topic t) {
        return TopicResponseDTO(
            t.name,
            t.config.numPartitions,
            t.config.replicationFactor,
            t.config.retentionMs,
            t.config.retentionBytes,
            t.config.cleanupPolicy,
            t.status.to!string,
            t.createdAt,
        );
    }
}
