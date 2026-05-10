module uim.infrastructure.barbican.domain.entities.secret_container;

import std.conv : to;
import std.string : toLower;

enum ContainerType {
    generic,
    rsa,
    certificate
}

struct SecretRef {
    string name;
    string secretId;
}

struct SecretContainer {
    string id;
    string name;
    ContainerType containerType;
    SecretRef[] secretRefs;
    string createdAt;
    string updatedAt;
    string projectId;

    string summary() const {
        import std.conv : to;
        return name ~ " [" ~ containerType.to!string ~ "] refs=" ~ secretRefs.length.to!string;
    }
}

ContainerType parseContainerType(string raw) {
    auto normalized = raw.toLower();
    switch (normalized) {
        case "generic":     return ContainerType.generic;
        case "rsa":         return ContainerType.rsa;
        case "certificate": return ContainerType.certificate;
        default: throw new Exception("Unsupported container type: " ~ raw);
    }
}

unittest {
    assert(parseContainerType("generic") == ContainerType.generic);
    assert(parseContainerType("RSA") == ContainerType.rsa);
    assert(parseContainerType("certificate") == ContainerType.certificate);
    auto c = SecretContainer("c1", "myrsa", ContainerType.rsa,
        [SecretRef("private_key", "s1"), SecretRef("public_key", "s2")],
        "", "", "proj1");
    assert(c.secretRefs.length == 2);
}
