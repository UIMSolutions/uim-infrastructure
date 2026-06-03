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