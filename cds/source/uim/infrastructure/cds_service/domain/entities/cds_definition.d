module uim.infrastructure.cds_service.domain.entities.cds_definition;

import std.datetime.systime : SysTime;

struct CdsField {
    string name;
    string typeName;
    bool nullable;
    bool key;
}

struct CdsDefinition {
    string id;
    string namespaceName;
    string name;
    string modelVersion;
    bool deprecated_;
    CdsField[] fields;
    SysTime createdAt;
}

struct MaybeCdsDefinition {
    bool found;
    CdsDefinition value;
}
