module uim.infrastructure.cinder.application.usecases.create_volume;

import uim.infrastructure.cinder.application.dto.cinder_command : CreateVolumeCommand;
import uim.infrastructure.cinder.domain.entities.volume : Volume;
import uim.infrastructure.cinder.domain.ports.repositories.volume : IVolumeRepository;

class CreateVolumeUseCase {
    private IVolumeRepository repository;

    this(IVolumeRepository repository) {
        this.repository = repository;
    }

    Volume execute(CreateVolumeCommand command) {
        return repository.create(
            command.projectId,
            command.name,
            command.description,
            command.sizeGiB,
            command.volumeTypeId,
            command.availabilityZone
        );
    }
}
