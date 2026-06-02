module uim.infrastructure.keppel.application.dto.commands;

struct CreateRepositoryCommand {
    string name;
    string projectId;
    string visibility;
}

struct UpsertTagCommand {
    string repositoryName;
    string tag;
    string digest;
    long sizeBytes;
    string mediaType;
}
