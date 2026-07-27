/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
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
