module uim.infrastructure.infobox.domain.entities.job;

import std.conv : to;

enum JobType {
    docker,
    docker_compose,
    docker_image,
    git,
    workflow
}

enum JobStatus {
    queued,
    scheduled,
    running,
    success,
    failure,
    error,
    cancelled,
    skipped
}

struct ResourceLimits {
    uint cpuMillis;
    uint memoryMb;
    uint timeoutSeconds;
}

struct Dependency {
    string jobName;
    bool onSuccess;
    bool onFailure;
}

struct EnvironmentVar {
    string name;
    string value;
    bool isSecret;
}

struct Job {
    string id;
    string projectId;
    string buildId;
    string name;
    JobType type;
    JobStatus status;
    string dockerFile;
    string image;
    string command;
    string buildContext;
    ResourceLimits resources;
    Dependency[] dependencies;
    EnvironmentVar[] environment;
    string output;
    uint durationSeconds;
    string startedAt;
    string finishedAt;

    string summary() const {
        return name ~ " [" ~ type.to!string ~ "] (" ~ status.to!string ~ ")";
    }
}

unittest {
    auto j = Job(
        "job-001", "proj-001", "build-001", "compile",
        JobType.docker, JobStatus.success,
        "Dockerfile", "", "dub build", ".",
        ResourceLimits(2000, 4096, 600),
        [], [], "Build succeeded", 42,
        "2026-04-19T00:00:00Z", "2026-04-19T00:00:42Z"
    );
    assert(j.summary() == "compile [docker] (success)");
}
