module uim.infrastructure.cinder.application.usecases.delete_volume;

import uim.infrastructure.cinder.domain.ports.repositories.volume : IVolumeRepository;

class DeleteVolumeUseCase {
    private IVolumeRepository repository;

    this(IVolumeRepository repository) {
        this.repository = repository;
    }

    bool execute(string id) {
        return repository.deleteById(id);
    }
}
