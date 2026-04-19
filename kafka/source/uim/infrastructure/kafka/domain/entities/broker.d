module uim.infrastructure.kafka.domain.entities.broker;

import std.conv : to;

enum BrokerStatus {
    active,
    draining,
    offline
}

struct Broker {
    uint id;
    string host;
    ushort port;
    BrokerStatus status;
    string rack;
    string startedAt;

    string summary() const {
        return "broker-" ~ id.to!string ~ " (" ~ host ~ ":" ~ port.to!string
            ~ ") [" ~ status.to!string ~ "]";
    }
}

unittest {
    auto b = Broker(1, "kafka-0.kafka.svc", 9092, BrokerStatus.active, "rack-a", "2026-04-19T00:00:00Z");
    assert(b.summary() == "broker-1 (kafka-0.kafka.svc:9092) [active]");
}
