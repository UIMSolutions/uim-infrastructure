/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
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
