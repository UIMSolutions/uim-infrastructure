module uim.infrastructure.cinder.application.usecases.detach_volume;

import uim.infrastructure.cinder.application.dto.cinder_command : VolumeDetachCommand;
import uim.infrastructure.cinder.domain.ports.repositories.volume : IVolumeRepository;

class DetachVolumeUseCase {
    private IVolumeRepository repository;

    this(IVolumeRepository repository) {
        this.repository = repository;
    }

    bool execute(VolumeDetachCommand command) {
        return repository.detachById(command.volumeId, command.attachmentRef);
    }
}
