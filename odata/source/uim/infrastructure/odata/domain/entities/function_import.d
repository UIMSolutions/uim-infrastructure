/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.odata.domain.entities.function_import;

enum OperationType {
    function_,
    action
}

struct Parameter {
    string name;
    string type;
    bool nullable;
}

struct FunctionImport {
    string name;
    OperationType operationType;
    string returnType;
    bool isBound;
    string boundToType;
    Parameter[] parameters;
}

unittest {
    auto f = FunctionImport(
        "GetNearestAirport",
        OperationType.function_,
        "Airport",
        false,
        "",
        [Parameter("lat", "Edm.Double", false), Parameter("lon", "Edm.Double", false)],
    );
    assert(f.name == "GetNearestAirport");
    assert(f.parameters.length == 2);
}
