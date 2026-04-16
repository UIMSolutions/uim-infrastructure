module bs_service.application.usecases.delete_volume;

import bs_service.application.dto.volume_command : DeleteVolumeCommand;
import bs_service.domain.entities.block_volume : VolumeState;
import bs_service.domain.ports.repositories.block_volume : IBlockVolumeRepository;

class DeleteVolumeUseCase {
    private IBlockVolumeRepository repository;

    this(IBlockVolumeRepository repository) {
        this.repository = repository;
    }

    void execute(in DeleteVolumeCommand command) {
        if (command.id.length == 0) {
            throw new Exception("id must not be empty");
        }

        auto vol = repository.findById(command.id);
        if (vol is null) {
            throw new Exception("volume not found");
        }
        if (vol.state == VolumeState.attached) {
            throw new Exception("cannot delete an attached volume; detach it first");
        }

        repository.remove(command.id);
    }
}
