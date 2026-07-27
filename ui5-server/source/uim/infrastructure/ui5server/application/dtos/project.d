/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.ui5server.application.dtos.project;

struct DependencyDTO {
    string name;
    string version_;
}

struct CreateProjectDTO {
    string name;
    string type;
    string rootPath;
    string version_;
    string namespace_;
    DependencyDTO[] dependencies;
}

struct ProjectResponseDTO {
    string id;
    string name;
    string type;
    string rootPath;
    string version_;
    string namespace_;
    DependencyDTO[] dependencies;
}
