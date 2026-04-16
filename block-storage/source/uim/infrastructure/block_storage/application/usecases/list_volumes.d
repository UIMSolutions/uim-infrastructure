module bs_service.application.usecases.list_volumes;

import bs_service.domain.entities.block_volume : BlockVolume;
import bs_service.domain.ports.repositories.block_volume : IBlockVolumeRepository;

class ListVolumesUseCase {
    private IBlockVolumeRepository repository;

    this(IBlockVolumeRepository repository) {
        this.repository = repository;
    }

    BlockVolume[] execute() {
        return repository.list();
    }
}
