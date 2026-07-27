/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.cinder.application.usecases.get_snapshot;

import uim.infrastructure.cinder.domain.entities.snapshot : Snapshot;
import uim.infrastructure.cinder.domain.ports.repositories.snapshot : ISnapshotRepository;

class GetSnapshotUseCase {
    private ISnapshotRepository repository;

    this(ISnapshotRepository repository) {
        this.repository = repository;
    }

    Snapshot* execute(string id) {
        return repository.getById(id);
    }
}
