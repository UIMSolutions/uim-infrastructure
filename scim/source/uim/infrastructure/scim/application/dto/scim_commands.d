/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.scim.application.dto.scim_commands;

struct CreateUserCommand {
    string externalId;
    string userName;
    string displayName;
    string givenName;
    string familyName;
    string[] emails;
}

struct ReplaceUserCommand {
    string externalId;
    string userName;
    string displayName;
    string givenName;
    string familyName;
    string[] emails;
}

struct CreateGroupCommand {
    string externalId;
    string displayName;
    string[] memberIds;
}

struct ReplaceGroupCommand {
    string externalId;
    string displayName;
    string[] memberIds;
}
