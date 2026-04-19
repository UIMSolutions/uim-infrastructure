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
