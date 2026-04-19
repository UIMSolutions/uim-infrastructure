module uim.infrastructure.odata.application.dtos.function_import;

struct ParameterDTO {
    string name;
    string type;
    bool nullable;
}

struct CreateFunctionImportDTO {
    string name;
    string operationType;
    string returnType;
    bool isBound;
    string boundToType;
    ParameterDTO[] parameters;
}

struct FunctionImportResponseDTO {
    string name;
    string operationType;
    string returnType;
    bool isBound;
    string boundToType;
    ParameterDTO[] parameters;
}
