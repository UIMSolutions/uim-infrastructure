module bs_service.application.usecases.create_volume;

import bs_service.application.dto.volume_command : CreateVolumeCommand;
import bs_service.domain.entities.block_volume : BlockVolume, VolumeState;
import bs_service.domain.ports.repositories.block_volume : IBlockVolumeRepository;
import std.datetime : Clock;
import std.uuid : randomUUID;

class CreateVolumeUseCase {
    private IBlockVolumeRepository repository;

    this(IBlockVolumeRepository repository) {
        this.repository = repository;
    }

    BlockVolume execute(in CreateVolumeCommand command) {
        enforceCommand(command);

        auto volume = BlockVolume(
            randomUUID().toString(),
            command.name,
            command.sizeGiB,
            VolumeState.available,
            "",
            Clock.currTime()
        );

        repository.save(volume);
        return volume;
    }

    private void enforceCommand(in CreateVolumeCommand command) {
        if (command.name.length == 0) {
            throw new Exception("name must not be empty");
        }
        if (command.sizeGiB == 0) {
            throw new Exception("sizeGiB must be greater than zero");
        }
    }
}
