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
