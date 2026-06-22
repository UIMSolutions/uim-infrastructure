module uim.infrastructure.cinder.domain.ports.repositories.snapshot;

import uim.infrastructure.cinder.domain.entities.snapshot : Snapshot;

interface ISnapshotRepository {
    Snapshot[] list(string projectIdFilter = "");
    Snapshot create(string projectId, string volumeId, string name, string description, ulong sizeGiB);
    Snapshot* getById(string id);
    bool deleteById(string id);
}
