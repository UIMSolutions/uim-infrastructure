module uim.infrastructure.cinder.application.usecases.get_snapshot;

import uim.infrastructure.cinder.domain.entities.snapshot : Snapshot;
import uim.infrastructure.cinder.domain.ports.repositories.snapshot : ISnapshotRepository;

class GetSnapshotUseCase {
    private ISnapshotRepository repository;

    this(ISnapshotRepository repository) {
        this.repository = repository;
    }

    Snapshot* execute(string id) {
        return repository.getById(id);
    }
}
