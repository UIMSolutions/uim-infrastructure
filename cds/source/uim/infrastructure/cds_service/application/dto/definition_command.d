module uim.infrastructure.cds_service.application.dto.definition_command;

struct CdsFieldCommand {
    string name;
    string typeName;
    bool nullable;
    bool key;
}

struct CreateDefinitionCommand {
    string namespaceName;
    string name;
    string modelVersion;
    bool deprecated_;
    CdsFieldCommand[] fields;
}
