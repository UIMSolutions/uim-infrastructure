module uim.infrastructure.cinder.application.usecases.get_volume;

import uim.infrastructure.cinder.domain.entities.volume : Volume;
import uim.infrastructure.cinder.domain.ports.repositories.volume : IVolumeRepository;

class GetVolumeUseCase {
    private IVolumeRepository repository;

    this(IVolumeRepository repository) {
        this.repository = repository;
    }

    Volume* execute(string id) {
        return repository.getById(id);
    }
}
