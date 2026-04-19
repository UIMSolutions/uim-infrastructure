module uim.infrastructure.kafka.domain.entities.record;

struct Header {
    string key;
    string value;
}

struct Record {
    string topic;
    uint partition;
    long offset;
    string key;
    string value;
    long timestamp;
    Header[] headers;
}

unittest {
    auto r = Record(
        "payments", 0, 42, "alice",
        "Made a payment of 200 to Bob",
        1_718_290_000_000,
        [Header("source", "payment-service")]
    );
    assert(r.topic == "payments");
    assert(r.offset == 42);
    assert(r.key == "alice");
}
