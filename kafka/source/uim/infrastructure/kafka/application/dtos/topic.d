/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.kafka.application.dtos.topic;

struct CreateTopicDTO {
    string name;
    uint numPartitions;
    uint replicationFactor;
    long retentionMs;
    long retentionBytes;
    string cleanupPolicy;
}

struct UpdateTopicDTO {
    uint numPartitions;
    uint replicationFactor;
    long retentionMs;
    long retentionBytes;
    string cleanupPolicy;
}

struct TopicResponseDTO {
    string name;
    uint numPartitions;
    uint replicationFactor;
    long retentionMs;
    long retentionBytes;
    string cleanupPolicy;
    string status;
    string createdAt;
}
