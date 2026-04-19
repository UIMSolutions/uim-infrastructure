module uim.infrastructure.kafka.application.dtos.record;

struct ProduceRecordDTO {
    string topic;
    string key;
    string value;
    string[string] headers;
}

struct RecordResponseDTO {
    string topic;
    uint partition;
    long offset;
    string key;
    string value;
    long timestamp;
    string[string] headers;
}
