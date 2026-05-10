module uim.infrastructure.barbican.application.dto.commands;

// --- Secret commands ---

struct CreateSecretCommand {
    string name;
    string secretType;      // symmetric, asymmetric, certificate, opaque, passphrase
    string algorithm;       // aes, rsa, ec, hmac
    uint   bitLength;
    string mode;            // cbc, gcm, etc.
    string payload;         // optional at creation (two-step flow)
    string payloadContentType;
    string expiration;
    string projectId;
}

struct SetSecretPayloadCommand {
    string secretId;
    string payload;
    string payloadContentType;
}

// --- Container commands ---

struct SecretRefCommand {
    string name;
    string secretId;
}

struct CreateContainerCommand {
    string name;
    string containerType;   // generic, rsa, certificate
    SecretRefCommand[] secretRefs;
    string projectId;
}

// --- Order commands ---

struct CreateOrderCommand {
    string orderType;       // key, asymmetric, certificate
    string algorithm;
    uint   bitLength;
    string mode;
    string payloadContentType;
    string expiration;
    string name;
    string projectId;
}
