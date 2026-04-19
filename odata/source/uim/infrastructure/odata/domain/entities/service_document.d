module uim.infrastructure.odata.domain.entities.service_document;

struct ServiceEndpoint {
    string name;
    string kind;
    string url;
}

struct ServiceDocument {
    string serviceRoot;
    string metadataUrl;
    ServiceEndpoint[] entitySets;
    ServiceEndpoint[] functions;
    ServiceEndpoint[] actions;
}

unittest {
    auto sd = ServiceDocument(
        "http://localhost:8080/odata/",
        "http://localhost:8080/odata/$metadata",
        [ServiceEndpoint("People", "EntitySet", "People")],
        [],
        [],
    );
    assert(sd.entitySets.length == 1);
    assert(sd.entitySets[0].name == "People");
}
