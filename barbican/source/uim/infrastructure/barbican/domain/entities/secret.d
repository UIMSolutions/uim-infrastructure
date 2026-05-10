module uim.infrastructure.barbican.domain.entities.secret;

import std.conv : to;
import std.string : toUpper, toLower;

enum SecretType {
    symmetric,
    asymmetric,
    certificate,
    opaque,
    passphrase
}

enum SecretStatus {
    active,
    deleted_,
    pending
}

enum SecretAlgorithm {
    aes,
    rsa,
    ec,
    hmac,
    none_
}

struct Secret {
    string id;
    string name;
    SecretType secretType;
    SecretAlgorithm algorithm;
    uint bitLength;
    string mode;                // e.g. "cbc" for AES
    string payload;             // base64-encoded value
    string payloadContentType;  // e.g. "application/octet-stream"
    string expiration;          // ISO 8601 or empty
    SecretStatus status;
    string createdAt;
    string updatedAt;
    string projectId;

    bool hasPayload() const {
        return payload.length > 0;
    }

    string summary() const {
        return name ~ " [" ~ secretType.to!string ~ "/" ~ algorithm.to!string ~ "] " ~ status.to!string;
    }
}

SecretType parseSecretType(string raw) {
    import std.exception : enforce;
    auto normalized = raw.toLower();
    switch (normalized) {
        case "symmetric":    return SecretType.symmetric;
        case "asymmetric":   return SecretType.asymmetric;
        case "certificate":  return SecretType.certificate;
        case "opaque":       return SecretType.opaque;
        case "passphrase":   return SecretType.passphrase;
        default: throw new Exception("Unsupported secret type: " ~ raw);
    }
}

SecretAlgorithm parseSecretAlgorithm(string raw) {
    if (raw.length == 0) return SecretAlgorithm.none_;
    auto normalized = raw.toLower();
    switch (normalized) {
        case "aes":  return SecretAlgorithm.aes;
        case "rsa":  return SecretAlgorithm.rsa;
        case "ec":   return SecretAlgorithm.ec;
        case "hmac": return SecretAlgorithm.hmac;
        case "":     return SecretAlgorithm.none_;
        default: throw new Exception("Unsupported algorithm: " ~ raw);
    }
}

unittest {
    assert(parseSecretType("symmetric") == SecretType.symmetric);
    assert(parseSecretType("OPAQUE") == SecretType.opaque);
    assert(parseSecretAlgorithm("aes") == SecretAlgorithm.aes);
    assert(parseSecretAlgorithm("") == SecretAlgorithm.none_);
    auto s = Secret("id1", "mykey", SecretType.symmetric, SecretAlgorithm.aes,
                    256, "cbc", "", "application/octet-stream", "", SecretStatus.active,
                    "", "", "proj1");
    assert(!s.hasPayload);
    s.payload = "base64data==";
    assert(s.hasPayload);
}
