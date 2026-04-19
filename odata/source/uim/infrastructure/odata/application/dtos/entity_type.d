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
