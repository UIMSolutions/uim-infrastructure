module uim.infrastructure.cinder.application.usecases.delete_snapshot;

import uim.infrastructure.cinder.domain.ports.repositories.snapshot : ISnapshotRepository;

class DeleteSnapshotUseCase {
    private ISnapshotRepository repository;

    this(ISnapshotRepository repository) {
        this.repository = repository;
    }

    bool execute(string id) {
        return repository.deleteById(id);
    }
}
