/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.manila.domain.entities.share_type;

import std.string : toLower;

enum ShareProtocol {
    nfs,
    cifs,
    cephfs
}

string shareProtocolToString(ShareProtocol protocol) {
    final switch (protocol) {
        case ShareProtocol.nfs: return "NFS";
        case ShareProtocol.cifs: return "CIFS";
        case ShareProtocol.cephfs: return "CEPHFS";
    }
}

ShareProtocol shareProtocolFromString(string value) {
    final switch (toLower(value)) {
        case "nfs": return ShareProtocol.nfs;
        case "cifs": return ShareProtocol.cifs;
        case "cephfs": return ShareProtocol.cephfs;
    }
    throw new Exception("unsupported share protocol: " ~ value);
}

struct ShareType {
    string id;
    string name;
    string description;
    ShareProtocol protocol;
    bool driverHandlesShareServers;
    bool snapshotSupport;
}

unittest {
    auto shareType = ShareType("gold", "gold", "high throughput", ShareProtocol.nfs, true, true);
    assert(shareType.id == "gold");
    assert(shareProtocolToString(shareType.protocol) == "NFS");
}