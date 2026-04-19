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
