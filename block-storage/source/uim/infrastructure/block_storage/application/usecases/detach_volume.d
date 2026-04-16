module bs_service.application.usecases.detach_volume;

import bs_service.application.dto.volume_command : DetachVolumeCommand;
import bs_service.domain.entities.block_volume : BlockVolume, VolumeState;
import bs_service.domain.ports.repositories.block_volume : IBlockVolumeRepository;

class DetachVolumeUseCase {
    private IBlockVolumeRepository repository;

    this(IBlockVolumeRepository repository) {
        this.repository = repository;
    }

    BlockVolume execute(in DetachVolumeCommand command) {
        if (command.id.length == 0) {
            throw new Exception("id must not be empty");
        }

        auto vol = repository.findById(command.id);
        if (vol is null) {
            throw new Exception("volume not found");
        }
        if (vol.state != VolumeState.attached) {
            throw new Exception("volume is not attached");
        }

        vol.state                = VolumeState.available;
        vol.attachedToInstanceId = "";
        repository.save(*vol);
        return *vol;
    }
}
