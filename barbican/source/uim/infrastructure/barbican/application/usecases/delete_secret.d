module uim.infrastructure.barbican.application.usecases.delete_secret;

import uim.infrastructure.barbican.domain.ports.repositories.secret : ISecretRepository;

class DeleteSecretUseCase {
    private ISecretRepository repository;

    this(ISecretRepository repository) {
        this.repository = repository;
    }

    void execute(string id) {
        auto ptr = repository.findById(id);
        if (ptr is null)
            throw new Exception("Secret not found: " ~ id);
        repository.remove(id);
    }
}
