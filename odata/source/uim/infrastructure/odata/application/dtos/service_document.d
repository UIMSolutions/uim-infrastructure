/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.odata.application.dtos.service_document;

struct ServiceEndpointDTO {
    string name;
    string kind;
    string url;
}

struct ServiceDocumentResponseDTO {
    string context;
    ServiceEndpointDTO[] value;
}
