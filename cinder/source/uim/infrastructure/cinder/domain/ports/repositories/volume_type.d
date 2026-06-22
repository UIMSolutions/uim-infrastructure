module uim.infrastructure.cinder.domain.ports.repositories.volume_type;

import uim.infrastructure.cinder.domain.entities.volume_type : VolumeType;

interface IVolumeTypeRepository {
    VolumeType[] list();
    VolumeType* getById(string id);
}
