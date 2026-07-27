/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.cinder.domain.entities.snapshot;

enum SnapshotStatus {
    creating,
    available,
    deleting,
    error
}

string snapshotStatusToString(SnapshotStatus status) {
    final switch (status) {
        case SnapshotStatus.creating:
            return "creating";
        case SnapshotStatus.available:
            return "available";
        case SnapshotStatus.deleting:
            return "deleting";
        case SnapshotStatus.error:
            return "error";
    }
}

struct Snapshot {
    string id;
    string volumeId;
    string projectId;
    string name;
    string description;
    ulong sizeGiB;
    SnapshotStatus status;
    string createdAt;
}
