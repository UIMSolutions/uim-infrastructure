/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.cinder.domain.ports.repositories.snapshot;

import uim.infrastructure.cinder.domain.entities.snapshot : Snapshot;

interface ISnapshotRepository {
    Snapshot[] list(string projectIdFilter = "");
    Snapshot create(string projectId, string volumeId, string name, string description, ulong sizeGiB);
    Snapshot* getById(string id);
    bool deleteById(string id);
}
