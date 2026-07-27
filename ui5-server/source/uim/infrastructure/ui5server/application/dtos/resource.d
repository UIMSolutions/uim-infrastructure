/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
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
