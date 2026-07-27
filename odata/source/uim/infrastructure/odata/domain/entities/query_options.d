/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.odata.domain.entities.query_options;

struct QueryOptions {
    string filter;
    string orderby;
    uint top;
    uint skip;
    bool count;
    string select;
    string expand;
    string search;
    bool hasTop;
    bool hasSkip;
}

unittest {
    auto qo = QueryOptions("FirstName eq 'Scott'", "LastName asc", 10, 0, true, "FirstName,LastName", "", "", true, true);
    assert(qo.filter == "FirstName eq 'Scott'");
    assert(qo.top == 10);
    assert(qo.count);
}
