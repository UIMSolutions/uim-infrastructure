/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.ansible.application.dto.commands;

struct CreateHostCommand {
    string hostname;
    string ipAddress;
    ushort port;
    string user;
    string[string] variables;
}

struct CreateInventoryCommand {
    string name;
    string description;
    GroupDef[] groups;
}

struct GroupDef {
    string name;
    string[] hostIds;
    string[string] groupVars;
}

struct CreateTaskCommand {
    string name;
    string taskModule;
    string[string] parameters;
    bool ignoreErrors;
    string when;
}

struct CreatePlaybookCommand {
    string name;
    string description;
    PlayDef[] plays;
}

struct PlayDef {
    string name;
    string targetGroup;
    string[] taskIds;
    string[string] vars;
    bool become;
}

struct RunPlaybookCommand {
    string playbookId;
    string inventoryId;
}
