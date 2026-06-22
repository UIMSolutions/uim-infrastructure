module uim.infrastructure.cinder.domain.entities.volume;

enum VolumeStatus {
    creating,
    available,
    in_use,
    deleting,
    error
}

string volumeStatusToString(VolumeStatus status) {
    final switch (status) {
        case VolumeStatus.creating:
            return "creating";
        case VolumeStatus.available:
            return "available";
        case VolumeStatus.in_use:
            return "in-use";
        case VolumeStatus.deleting:
            return "deleting";
        case VolumeStatus.error:
            return "error";
    }
}

struct Volume {
    string id;
    string projectId;
    string name;
    string description;
    ulong sizeGiB;
    string volumeTypeId;
    string availabilityZone;
    VolumeStatus status;
    string[] attachments;
    string createdAt;
}
