module uim.infrastructure.infobox.application.usecases.delete_secret;

import uim.infrastructure.infobox.domain.ports.repositories.secret : ISecretRepository;

class DeleteSecretUseCase {
    private ISecretRepository repository;

    this(ISecretRepository repository) {
        this.repository = repository;
    }

    void execute(string secretId) {
        if (secretId.length == 0) {
            throw new Exception("secret id must not be empty");
        }

        auto existing = repository.findById(secretId);
        if (existing is null) {
            throw new Exception("secret not found: " ~ secretId);
        }

        repository.deleteById(secretId);
    }
}
