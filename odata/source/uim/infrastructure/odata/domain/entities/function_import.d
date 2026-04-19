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
