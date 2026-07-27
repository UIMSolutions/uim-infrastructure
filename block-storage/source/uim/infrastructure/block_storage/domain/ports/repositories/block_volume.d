/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module bs_service.domain.ports.repositories.block_volume;

import bs_service.domain.entities.block_volume : BlockVolume;

interface IBlockVolumeRepository {
    void          save(BlockVolume volume);
    void          remove(string id);
    BlockVolume[] list();
    BlockVolume*  findById(string id);
}
