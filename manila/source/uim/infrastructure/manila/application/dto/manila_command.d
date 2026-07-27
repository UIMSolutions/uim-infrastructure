/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.manila.application.dto.manila_command;

import uim.infrastructure.manila.domain.entities.share_type : ShareProtocol;

struct CreateShareCommand {
    string projectId;
    string name;
    string description;
    ulong sizeGiB;
    ShareProtocol protocol;
    string shareTypeId;
    string availabilityZone;
}

struct CreateSnapshotCommand {
    string projectId;
    string shareId;
    string name;
    string description;
}