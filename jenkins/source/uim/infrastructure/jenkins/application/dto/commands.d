module uim.infrastructure.jenkins.application.dto.commands;

struct CreatePipelineCommand {
    string name;
    string description;
    string repository;
    string branch;
    string[] stageNames;
    string[] stageCommands;
    uint[] stageTimeouts;
}

struct UpdatePipelineCommand {
    string id;
    string name;
    string description;
    string repository;
    string branch;
    string statusStr;
}

struct TriggerBuildCommand {
    string pipelineId;
    string triggeredBy;
}

struct GetPipelineQuery {
    string id;
}

struct GetBuildQuery {
    string id;
}

struct ListBuildsQuery {
    string pipelineId;
}
