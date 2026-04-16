module bs_service.application.usecases.get_volume;

import bs_service.application.dto.volume_command : GetVolumeQuery;
import bs_service.domain.entities.block_volume : BlockVolume;
import bs_service.domain.ports.repositories.block_volume : IBlockVolumeRepository;

class GetVolumeUseCase {
    private IBlockVolumeRepository repository;

    this(IBlockVolumeRepository repository) {
        this.repository = repository;
    }

    /// Returns a pointer to the matching volume, or null when not found.
    BlockVolume* execute(in GetVolumeQuery query) {
        if (query.id.length == 0) {
            throw new Exception("id must not be empty");
        }
        return repository.findById(query.id);
    }
}
