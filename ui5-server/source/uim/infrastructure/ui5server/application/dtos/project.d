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
