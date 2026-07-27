/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.manila.domain.entities.share_snapshot;

import std.datetime : SysTime;
import std.string : toLower;

enum SnapshotStatus {
    creating,
    available,
    deleting
}

string snapshotStatusToString(SnapshotStatus status) {
    final switch (status) {
        case SnapshotStatus.creating: return "creating";
        case SnapshotStatus.available: return "available";
        case SnapshotStatus.deleting: return "deleting";
    }
}

SnapshotStatus snapshotStatusFromString(string value) {
    final switch (toLower(value)) {
        case "creating": return SnapshotStatus.creating;
        case "available": return SnapshotStatus.available;
        case "deleting": return SnapshotStatus.deleting;
    }
    throw new Exception("unsupported snapshot status: " ~ value);
}

struct ShareSnapshot {
    string id;
    string shareId;
    string projectId;
    string name;
    string description;
    ulong sizeGiB;
    SnapshotStatus status;
    SysTime createdAt;
}

unittest {
    import std.datetime : Clock;
    auto snapshot = ShareSnapshot(
        "snap-1",
        "share-1",
        "project-a",
        "nightly",
        "nightly backup",
        20,
        SnapshotStatus.available,
        Clock.currTime()
    );
    assert(snapshot.shareId == "share-1");
}