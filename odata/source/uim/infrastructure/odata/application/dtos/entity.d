/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.odata.application.dtos.entity;

struct CreateEntityDTO {
    string entitySetName;
    string[string] properties;
}

struct UpdateEntityDTO {
    string[string] properties;
}

struct EntityResponseDTO {
    string entitySetName;
    string entityTypeName;
    string id;
    string[string] properties;
}

struct EntityCollectionResponseDTO {
    string context;
    ulong count;
    bool hasCount;
    EntityResponseDTO[] value;
}
