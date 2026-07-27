/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.infobox.domain.entities.secret;

struct Secret {
    string id;
    string projectId;
    string name;
    string encryptedValue;
    string createdAt;
}

unittest {
    auto s = Secret("sec-001", "proj-001", "DB_PASSWORD", "***encrypted***", "2026-04-19T00:00:00Z");
    assert(s.name == "DB_PASSWORD");
}
