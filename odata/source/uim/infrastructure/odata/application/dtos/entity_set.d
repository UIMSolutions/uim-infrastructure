module uim.infrastructure.odata.application.dtos.entity_set;

struct CreateEntitySetDTO {
    string name;
    string entityTypeName;
}

struct EntitySetResponseDTO {
    string name;
    string entityTypeName;
}
