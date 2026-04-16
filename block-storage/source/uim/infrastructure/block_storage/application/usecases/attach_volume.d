module bs_service.application.usecases.attach_volume;

import bs_service.application.dto.volume_command : AttachVolumeCommand;
import bs_service.domain.entities.block_volume : BlockVolume, VolumeState;
import bs_service.domain.ports.repositories.block_volume : IBlockVolumeRepository;

class AttachVolumeUseCase {
    private IBlockVolumeRepository repository;

    this(IBlockVolumeRepository repository) {
        this.repository = repository;
    }

    BlockVolume execute(in AttachVolumeCommand command) {
        if (command.id.length == 0) {
            throw new Exception("id must not be empty");
        }
        if (command.instanceId.length == 0) {
            throw new Exception("instanceId must not be empty");
        }

        auto vol = repository.findById(command.id);
        if (vol is null) {
            throw new Exception("volume not found");
        }
        if (vol.state == VolumeState.attached) {
            throw new Exception("volume is already attached");
        }
        if (vol.state == VolumeState.deleting) {
            throw new Exception("volume is being deleted");
        }

        vol.state                = VolumeState.attached;
        vol.attachedToInstanceId = command.instanceId;
        repository.save(*vol);
        return *vol;
    }
}
