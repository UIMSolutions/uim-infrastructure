/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.kafka.application.usecases.get_topic;

import std.conv : to;
import uim.infrastructure.kafka.domain.entities.topic : Topic;
import uim.infrastructure.kafka.domain.ports.repositories.topic : ITopicRepository;
import uim.infrastructure.kafka.application.dtos.topic : TopicResponseDTO;

class GetTopicUseCase {
    private ITopicRepository repo;

    this(ITopicRepository repo) {
        this.repo = repo;
    }

    TopicResponseDTO* execute(string name) {
        auto topic = repo.findByName(name);
        if (topic is null) return null;
        auto response = toResponse(*topic);
        return new TopicResponseDTO(
            response.name,
            response.numPartitions,
            response.replicationFactor,
            response.retentionMs,
            response.retentionBytes,
            response.cleanupPolicy,
            response.status,
            response.createdAt,
        );
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
