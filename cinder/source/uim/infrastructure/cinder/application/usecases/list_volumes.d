/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.cinder.application.usecases.list_volumes;

import uim.infrastructure.cinder.domain.entities.volume : Volume;
import uim.infrastructure.cinder.domain.ports.repositories.volume : IVolumeRepository;

class ListVolumesUseCase {
    private IVolumeRepository repository;

    this(IVolumeRepository repository) {
        this.repository = repository;
    }

    Volume[] execute(string projectIdFilter = "") {
        return repository.list(projectIdFilter);
    }
}
