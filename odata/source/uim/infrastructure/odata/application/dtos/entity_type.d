/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.odata.application.dtos.entity_type;

struct PropertyDTO {
    string name;
    string type;
    bool nullable;
    string defaultValue;
    uint maxLength;
}

struct NavigationPropertyDTO {
    string name;
    string targetEntityType;
    string multiplicity;
    string partner;
}

struct CreateEntityTypeDTO {
    string name;
    string namespace_;
    string[] keyProperties;
    PropertyDTO[] properties;
    NavigationPropertyDTO[] navigationProperties;
}

struct EntityTypeResponseDTO {
    string name;
    string namespace_;
    string fullName;
    string[] keyProperties;
    PropertyDTO[] properties;
    NavigationPropertyDTO[] navigationProperties;
}
