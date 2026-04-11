module dns_service.domain.entities.dns_record;

import std.conv : to;
import std.string : toUpper;

enum RecordType {
    A,
    AAAA,
    CNAME,
    TXT
}

struct DNSRecord {
    string zone;
    string name;
    RecordType type;
    string value;
    uint ttl;

    string fqdn() const {
        return name.length == 0 ? zone : name ~ "." ~ zone;
    }
}

RecordType parseRecordType(string rawType) {
    auto normalized = rawType.toUpper();
    foreach (candidate; __traits(allMembers, RecordType)) {
        if (candidate == normalized) {
            return to!RecordType(normalized);
        }
    }
    throw new Exception("Unsupported record type: " ~ rawType);
}

unittest {
    assert(parseRecordType("a") == RecordType.A);
    assert(parseRecordType("TXT") == RecordType.TXT);

    DNSRecord record = DNSRecord("example.local", "api", RecordType.A, "10.0.0.5", 120);
    assert(record.fqdn() == "api.example.local");
}
