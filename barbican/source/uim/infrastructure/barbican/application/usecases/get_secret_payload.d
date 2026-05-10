module uim.infrastructure.barbican.application.usecases.get_secret_payload;

import uim.infrastructure.barbican.domain.ports.repositories.secret : ISecretRepository;

struct PayloadResult {
    string payload;
    string contentType;
}

class GetSecretPayloadUseCase {
    private ISecretRepository repository;

    this(ISecretRepository repository) {
        this.repository = repository;
    }

    PayloadResult execute(string id) {
        auto ptr = repository.findById(id);
        if (ptr is null)
            throw new Exception("Secret not found: " ~ id);
        if (!ptr.hasPayload())
            throw new Exception("Secret has no payload: " ~ id);
        return PayloadResult(ptr.payload, ptr.payloadContentType);
    }
}
