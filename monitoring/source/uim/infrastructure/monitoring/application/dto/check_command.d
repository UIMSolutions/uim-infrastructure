/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module monitoring_service.application.dto.check_command;

struct RegisterCheckCommand {
    string id;
    string name;
    string host;
    ushort port;
    uint intervalSecs;
}

struct DeregisterCheckCommand {
    string id;
}

struct RunCheckCommand {
    string id;
}
