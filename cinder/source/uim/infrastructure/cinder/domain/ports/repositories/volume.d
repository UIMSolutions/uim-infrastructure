module uim.infrastructure.cinder.domain.ports.repositories.volume;

import uim.infrastructure.cinder.domain.entities.volume : Volume;

interface IVolumeRepository {
    Volume[] list(string projectIdFilter = "");
    Volume create(
        string projectId,
        string name,
        string description,
        ulong sizeGiB,
        string volumeTypeId,
        string availabilityZone
    );
    Volume* getById(string id);
    bool deleteById(string id);
    bool attachById(string id, string attachmentRef);
    bool detachById(string id, string attachmentRef);
}
