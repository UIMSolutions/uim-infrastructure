module uim.infrastructure.cinder.application.usecases.create_snapshot;

import uim.infrastructure.cinder.application.dto.cinder_command : CreateSnapshotCommand;
import uim.infrastructure.cinder.domain.entities.snapshot : Snapshot;
import uim.infrastructure.cinder.domain.entities.volume : Volume;
import uim.infrastructure.cinder.domain.ports.repositories.snapshot : ISnapshotRepository;
import uim.infrastructure.cinder.domain.ports.repositories.volume : IVolumeRepository;

class CreateSnapshotUseCase {
    private ISnapshotRepository snapshotRepository;
    private IVolumeRepository volumeRepository;

    this(ISnapshotRepository snapshotRepository, IVolumeRepository volumeRepository) {
        this.snapshotRepository = snapshotRepository;
        this.volumeRepository = volumeRepository;
    }

    Snapshot execute(CreateSnapshotCommand command) {
        auto volume = volumeRepository.getById(command.volumeId);
        if (volume is null) {
            throw new Exception("volume not found");
        }

        return snapshotRepository.create(
            command.projectId,
            command.volumeId,
            command.name,
            command.description,
            volume.sizeGiB
        );
    }
}
