/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.cinder.domain.ports.repositories.volume;

import uim.infrastructure.cinder.domain.entities.volume : Volume;

interface IVolumeRepository {
    Volume[] list(string projectIdFilter = "");
    Volume create(
        string projectId,
        string name,
        string description,
        ulong sizeGiB,
        string volumeTypeId,
        string availabilityZone
    );
    Volume* getById(string id);
    bool deleteById(string id);
    bool attachById(string id, string attachmentRef);
    bool detachById(string id, string attachmentRef);
}
