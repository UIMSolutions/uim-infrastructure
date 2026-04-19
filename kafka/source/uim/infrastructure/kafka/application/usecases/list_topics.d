module uim.infrastructure.kafka.application.usecases.list_topics;

import std.algorithm : map;
import std.array : array;
import std.conv : to;
import uim.infrastructure.kafka.domain.entities.topic : Topic, TopicStatus;
import uim.infrastructure.kafka.domain.ports.repositories.topic : ITopicRepository;
import uim.infrastructure.kafka.application.dtos.topic : TopicResponseDTO;

class ListTopicsUseCase {
    private ITopicRepository repo;

    this(ITopicRepository repo) {
        this.repo = repo;
    }

    TopicResponseDTO[] execute() {
        return repo.list().map!(t => toResponse(t)).array;
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
