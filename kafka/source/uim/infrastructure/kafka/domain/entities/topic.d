module uim.infrastructure.kafka.domain.entities.topic;

import std.conv : to;

struct TopicConfig {
    uint numPartitions;
    uint replicationFactor;
    long retentionMs;
    long retentionBytes;
    string cleanupPolicy;
}

enum TopicStatus {
    active,
    marked_for_deletion,
    inactive
}

struct Topic {
    string name;
    TopicConfig config;
    TopicStatus status;
    string createdAt;

    string summary() const {
        return name ~ " [" ~ config.numPartitions.to!string ~ " partitions, rf="
            ~ config.replicationFactor.to!string ~ "] (" ~ status.to!string ~ ")";
    }
}

unittest {
    auto t = Topic(
        "payments",
        TopicConfig(4, 3, 604_800_000, -1, "delete"),
        TopicStatus.active,
        "2026-04-19T00:00:00Z"
    );
    assert(t.summary() == "payments [4 partitions, rf=3] (active)");
}
