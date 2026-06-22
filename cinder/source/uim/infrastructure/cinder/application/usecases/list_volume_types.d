module uim.infrastructure.cinder.application.usecases.list_volume_types;

import uim.infrastructure.cinder.domain.entities.volume_type : VolumeType;
import uim.infrastructure.cinder.domain.ports.repositories.volume_type : IVolumeTypeRepository;

class ListVolumeTypesUseCase {
    private IVolumeTypeRepository repository;

    this(IVolumeTypeRepository repository) {
        this.repository = repository;
    }

    VolumeType[] execute() {
        return repository.list();
    }
}
