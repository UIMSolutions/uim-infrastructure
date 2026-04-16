module bs_service.application.dto.volume_command;

struct CreateVolumeCommand {
    string name;
    ulong  sizeGiB;
}

struct DeleteVolumeCommand {
    string id;
}

struct AttachVolumeCommand {
    string id;
    string instanceId;
}

struct DetachVolumeCommand {
    string id;
}

struct GetVolumeQuery {
    string id;
}
