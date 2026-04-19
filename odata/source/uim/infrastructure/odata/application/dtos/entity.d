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
