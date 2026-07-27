/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.cinder.application.dto.cinder_command;

struct CreateVolumeCommand {
    string projectId;
    string name;
    string description;
    ulong sizeGiB;
    string volumeTypeId;
    string availabilityZone;
}

struct CreateSnapshotCommand {
    string projectId;
    string volumeId;
    string name;
    string description;
}

struct VolumeAttachCommand {
    string volumeId;
    string instanceUuid;
    string mountpoint;
}

struct VolumeDetachCommand {
    string volumeId;
    string attachmentRef;
}
