module uim.infrastructure.kafka.domain.entities.partition;

import std.conv : to;

struct PartitionInfo {
    string topic;
    uint partitionId;
    long startOffset;
    long endOffset;
    long messageCount;

    string summary() const {
        return topic ~ "-" ~ partitionId.to!string
            ~ " [" ~ startOffset.to!string ~ ".." ~ endOffset.to!string
            ~ ", " ~ messageCount.to!string ~ " msgs]";
    }
}

unittest {
    auto p = PartitionInfo("payments", 0, 0, 99, 100);
    assert(p.summary() == "payments-0 [0..99, 100 msgs]");
}
