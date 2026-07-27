/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module dns_service.application.dto.record_command;

struct RegisterRecordCommand {
    string zone;
    string name;
    string recordType;
    string value;
    uint ttl;
}

struct ResolveRecordQuery {
    string zone;
    string name;
    string recordType;
}
