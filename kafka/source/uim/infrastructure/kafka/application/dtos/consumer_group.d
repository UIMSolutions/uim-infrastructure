module uim.infrastructure.kafka.application.dtos.consumer_group;

struct CreateConsumerGroupDTO {
    string groupId;
}

struct ConsumerGroupResponseDTO {
    string groupId;
    string state;
    uint memberCount;
    string createdAt;
}

struct CommitOffsetDTO {
    string groupId;
    string topic;
    uint partition;
    long offset;
}

struct ConsumerOffsetResponseDTO {
    string groupId;
    string topic;
    uint partition;
    long committedOffset;
    long logEndOffset;
    long lag;
}
