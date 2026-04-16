module bs_service.domain.ports.repositories.block_volume;

import bs_service.domain.entities.block_volume : BlockVolume;

interface IBlockVolumeRepository {
    void          save(BlockVolume volume);
    void          remove(string id);
    BlockVolume[] list();
    BlockVolume*  findById(string id);
}
