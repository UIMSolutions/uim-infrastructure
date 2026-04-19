module uim.infrastructure.jenkins.domain.entities.pipeline;

import std.conv : to;
import std.datetime : SysTime, Clock;

enum PipelineStatus {
    active,
    disabled,
    archived
}

struct Stage {
    string name;
    string command;
    uint timeoutSeconds;
}

struct Pipeline {
    string id;
    string name;
    string description;
    string repository;
    string branch;
    PipelineStatus status;
    Stage[] stages;
    string createdAt;

    string summary() const {
        return name ~ " (" ~ status.to!string ~ ") [" ~ stages.length.to!string ~ " stages]";
    }
}

unittest {
    auto p = Pipeline(
        "p-001", "build-app", "Build the application", "https://git.example.com/app.git",
        "main", PipelineStatus.active,
        [Stage("compile", "dub build", 300), Stage("test", "dub test", 600)],
        "2026-04-19T00:00:00Z"
    );
    assert(p.summary() == "build-app (active) [2 stages]");
}
