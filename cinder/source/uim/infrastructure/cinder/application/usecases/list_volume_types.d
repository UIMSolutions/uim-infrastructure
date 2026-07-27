/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.cinder.application.usecases.list_volume_types;

import uim.infrastructure.cinder.domain.entities.volume_type : VolumeType;
import uim.infrastructure.cinder.domain.ports.repositories.volume_type : IVolumeTypeRepository;

class ListVolumeTypesUseCase {
    private IVolumeTypeRepository repository;

    this(IVolumeTypeRepository repository) {
        this.repository = repository;
    }

    VolumeType[] execute() {
        return repository.list();
    }
}
