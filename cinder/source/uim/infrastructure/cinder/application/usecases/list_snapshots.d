module uim.infrastructure.cinder.application.usecases.list_snapshots;

import uim.infrastructure.cinder.domain.entities.snapshot : Snapshot;
import uim.infrastructure.cinder.domain.ports.repositories.snapshot : ISnapshotRepository;

class ListSnapshotsUseCase {
    private ISnapshotRepository repository;

    this(ISnapshotRepository repository) {
        this.repository = repository;
    }

    Snapshot[] execute(string projectIdFilter = "") {
        return repository.list(projectIdFilter);
    }
}
