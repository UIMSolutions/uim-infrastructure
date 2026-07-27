/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
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
