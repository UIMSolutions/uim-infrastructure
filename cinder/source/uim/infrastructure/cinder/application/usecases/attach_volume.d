/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.cinder.application.usecases.attach_volume;

import uim.infrastructure.cinder.application.dto.cinder_command : VolumeAttachCommand;
import uim.infrastructure.cinder.domain.ports.repositories.volume : IVolumeRepository;

class AttachVolumeUseCase {
    private IVolumeRepository repository;

    this(IVolumeRepository repository) {
        this.repository = repository;
    }

    bool execute(VolumeAttachCommand command) {
        auto attachmentRef = command.instanceUuid ~ ":" ~ command.mountpoint;
        return repository.attachById(command.volumeId, attachmentRef);
    }
}
