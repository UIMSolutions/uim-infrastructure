/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.cinder.application.usecases.detach_volume;

import uim.infrastructure.cinder.application.dto.cinder_command : VolumeDetachCommand;
import uim.infrastructure.cinder.domain.ports.repositories.volume : IVolumeRepository;

class DetachVolumeUseCase {
    private IVolumeRepository repository;

    this(IVolumeRepository repository) {
        this.repository = repository;
    }

    bool execute(VolumeDetachCommand command) {
        return repository.detachById(command.volumeId, command.attachmentRef);
    }
}
