module uim.infrastructure.cinder.application.usecases.list_volumes;

import uim.infrastructure.cinder.domain.entities.volume : Volume;
import uim.infrastructure.cinder.domain.ports.repositories.volume : IVolumeRepository;

class ListVolumesUseCase {
    private IVolumeRepository repository;

    this(IVolumeRepository repository) {
        this.repository = repository;
    }

    Volume[] execute(string projectIdFilter = "") {
        return repository.list(projectIdFilter);
    }
}
