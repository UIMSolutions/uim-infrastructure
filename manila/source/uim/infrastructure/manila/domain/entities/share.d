/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.manila.domain.entities.share;

import std.datetime : SysTime;
import std.string : toLower;
import uim.infrastructure.manila.domain.entities.share_type : ShareProtocol;

enum ShareStatus {
    creating,
    available,
    deleting
}

string shareStatusToString(ShareStatus status) {
    final switch (status) {
        case ShareStatus.creating: return "creating";
        case ShareStatus.available: return "available";
        case ShareStatus.deleting: return "deleting";
    }
}

ShareStatus shareStatusFromString(string value) {
    final switch (toLower(value)) {
        case "creating": return ShareStatus.creating;
        case "available": return ShareStatus.available;
        case "deleting": return ShareStatus.deleting;
    }
    throw new Exception("unsupported share status: " ~ value);
}

struct Share {
    string id;
    string projectId;
    string name;
    string description;
    ulong sizeGiB;
    ShareProtocol protocol;
    string shareTypeId;
    string availabilityZone;
    ShareStatus status;
    string[] exportLocations;
    SysTime createdAt;
}

unittest {
    import std.datetime : Clock;
    auto share = Share(
        "share-1",
        "project-a",
        "engineering",
        "team share",
        20,
        ShareProtocol.nfs,
        "gold",
        "zone-a",
        ShareStatus.available,
        ["nfs://manila.local/shares/share-1"],
        Clock.currTime()
    );
    assert(share.exportLocations.length == 1);
}