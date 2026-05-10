module uim.infrastructure.barbican.domain.entities.order;

import std.conv : to;
import std.string : toLower;

enum OrderType {
    key,
    asymmetric,
    certificate
}

enum OrderStatus {
    pending,
    active,
    error_,
    submitted
}

struct OrderMeta {
    string algorithm;
    uint bitLength;
    string mode;
    string payloadContentType;
    string expiration;
    string name;
}

struct Order {
    string id;
    OrderType orderType;
    OrderStatus status;
    OrderMeta meta;
    string secretRef;        // URI of the resulting secret once fulfilled
    string createdAt;
    string updatedAt;
    string projectId;
    string errorStatusCode;
    string errorReason;

    string summary() const {
        return id ~ " [" ~ orderType.to!string ~ "] " ~ status.to!string;
    }
}

OrderType parseOrderType(string raw) {
    auto normalized = raw.toLower();
    switch (normalized) {
        case "key":         return OrderType.key;
        case "asymmetric":  return OrderType.asymmetric;
        case "certificate": return OrderType.certificate;
        default: throw new Exception("Unsupported order type: " ~ raw);
    }
}

unittest {
    assert(parseOrderType("key") == OrderType.key);
    assert(parseOrderType("ASYMMETRIC") == OrderType.asymmetric);
    auto o = Order("o1", OrderType.key, OrderStatus.pending,
        OrderMeta("aes", 256, "cbc", "application/octet-stream", "", "mykey"),
        "", "", "", "proj1", "", "");
    assert(o.status == OrderStatus.pending);
}
