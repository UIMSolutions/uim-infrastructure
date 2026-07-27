/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.crossplane.domain.entities.composition;

struct ComposedTemplate {
    string name;
    string kind;
    string apiGroup;
    string[string] patches;
    string[string] base;
}

struct Composition {
    string id;
    string name;
    string compositeTypeRef;
    ComposedTemplate[] resources;
    string[string] writeConnectionSecretsToRef;
    string createdAt;
    string updatedAt;
}

unittest {
    auto tpl = ComposedTemplate("bucket", "Bucket", "s3.aws.crossplane.io", null, null);
    auto c = Composition("c1", "s3-with-policy", "XObjectStorage",
        [tpl], null, "2026-04-19T10:00:00Z", "");
    assert(c.name == "s3-with-policy");
    assert(c.resources.length == 1);
    assert(c.resources[0].name == "bucket");
}
