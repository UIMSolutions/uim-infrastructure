module uim.infrastructure.infobox.application.dto.commands;

struct CreateProjectCommand {
    string name;
    string description;
    string repository;
    string branch;
}

struct UpdateProjectCommand {
    string id;
    string name;
    string description;
    string repository;
    string branch;
    string statusStr;
}

struct TriggerBuildCommand {
    string projectId;
    string commitSha;
    string branch;
    string triggeredBy;
    string triggerType;
}

struct CreateJobCommand {
    string projectId;
    string buildId;
    string name;
    string jobType;
    string dockerFile;
    string image;
    string command;
    string buildContext;
    uint cpuMillis;
    uint memoryMb;
    uint timeoutSeconds;
    string[] dependencyNames;
    string[] envNames;
    string[] envValues;
    bool[] envIsSecret;
}

struct CreateSecretCommand {
    string projectId;
    string name;
    string value;
}

struct GetProjectQuery {
    string id;
}

struct GetBuildQuery {
    string id;
}

struct ListBuildsQuery {
    string projectId;
}

struct GetJobQuery {
    string id;
}

struct ListJobsQuery {
    string buildId;
}

struct ListSecretsQuery {
    string projectId;
}
