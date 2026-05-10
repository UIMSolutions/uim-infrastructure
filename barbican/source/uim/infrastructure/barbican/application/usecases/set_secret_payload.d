module uim.infrastructure.barbican.application.usecases.set_secret_payload;

import uim.infrastructure.barbican.application.dto.commands : SetSecretPayloadCommand;
import uim.infrastructure.barbican.domain.ports.repositories.secret : ISecretRepository;

class SetSecretPayloadUseCase {
    private ISecretRepository repository;

    this(ISecretRepository repository) {
        this.repository = repository;
    }

    void execute(in SetSecretPayloadCommand cmd) {
        if (cmd.secretId.length == 0)
            throw new Exception("secretId must not be empty");
        if (cmd.payload.length == 0)
            throw new Exception("payload must not be empty");

        auto ptr = repository.findById(cmd.secretId);
        if (ptr is null)
            throw new Exception("Secret not found: " ~ cmd.secretId);
        if (ptr.hasPayload())
            throw new Exception("Secret already has a payload");

        bool ok = repository.setPayload(cmd.secretId, cmd.payload, cmd.payloadContentType);
        if (!ok)
            throw new Exception("Failed to set payload for secret: " ~ cmd.secretId);
    }
}
