module bs_service.domain.entities.block_volume;

import std.datetime : SysTime;

/// Lifecycle state of a block volume.
enum VolumeState : string {
    available = "available",
    attached  = "attached",
    deleting  = "deleting",
}

/// Represents a raw block-storage volume.
struct BlockVolume {
    string      id;
    string      name;
    ulong       sizeGiB;
    VolumeState state;
    /// Non-empty when state == VolumeState.attached.
    string      attachedToInstanceId;
    SysTime     createdAt;
}

unittest {
    import std.datetime : Clock;

    auto v = BlockVolume("vol-1", "data", 100, VolumeState.available, "", Clock.currTime());
    assert(v.id      == "vol-1");
    assert(v.sizeGiB == 100);
    assert(v.state   == VolumeState.available);
}
