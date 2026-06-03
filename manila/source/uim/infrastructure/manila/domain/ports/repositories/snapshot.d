module uim.infrastructure.manila.domain.ports.repositories.snapshot;

import uim.infrastructure.manila.domain.entities.share_snapshot : ShareSnapshot;

interface ISnapshotRepository {
    void save(ShareSnapshot snapshot);
    ShareSnapshot[] list();
    ShareSnapshot[] listByProject(string projectId);
    void removeByShareId(string shareId);
}