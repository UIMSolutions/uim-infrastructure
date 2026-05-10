module uim.infrastructure.barbican.application.usecases.delete_container;

import uim.infrastructure.barbican.domain.ports.repositories.secret_container : ISecretContainerRepository;

class DeleteContainerUseCase {
    private ISecretContainerRepository repository;

    this(ISecretContainerRepository repository) {
        this.repository = repository;
    }

    void execute(string id) {
        auto ptr = repository.findById(id);
        if (ptr is null)
            throw new Exception("Container not found: " ~ id);
        repository.remove(id);
    }
}
