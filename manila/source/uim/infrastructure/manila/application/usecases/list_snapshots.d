module uim.infrastructure.manila.application.usecases.list_snapshots;

import uim.infrastructure.manila.domain.entities.share_snapshot : ShareSnapshot;
import uim.infrastructure.manila.domain.ports.repositories.snapshot : ISnapshotRepository;

class ListSnapshotsUseCase {
    private ISnapshotRepository repository;

    this(ISnapshotRepository repository) {
        this.repository = repository;
    }

    ShareSnapshot[] execute(string projectId = "") {
        if (projectId.length == 0) {
            return repository.list();
        }
        return repository.listByProject(projectId);
    }
}