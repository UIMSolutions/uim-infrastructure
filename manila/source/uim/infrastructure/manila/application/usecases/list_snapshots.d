/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.manila.application.usecases.list_snapshots;

import uim.infrastructure.manila.domain.entities.share_snapshot : ShareSnapshot;
import uim.infrastructure.manila.domain.ports.repositories.snapshot : ISnapshotRepository;

class ListSnapshotsUseCase {
    private ISnapshotRepository repository;

    this(ISnapshotRepository repository) {
        this.repository = repository;
    }

    ShareSnapshot[] execute(string projectId = "") {
        if (projectId.length == 0) {
            return repository.list();
        }
        return repository.listByProject(projectId);
    }
}