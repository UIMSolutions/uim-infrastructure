module uim.infrastructure.ui5server.application.dtos.resource;

struct UploadResourceDTO {
    string path;
    string contentType;
    string content;
    bool isDirectory = false;
}

struct ResourceResponseDTO {
    string path;
    string contentType;
    ulong size;
    string lastModified;
    bool isDirectory;
}

struct DirectoryListingDTO {
    string path;
    ResourceResponseDTO[] entries;
}
