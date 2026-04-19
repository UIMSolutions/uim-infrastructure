module uim.infrastructure.infobox.domain.entities.build;

import std.conv : to;

enum BuildStatus {
    queued,
    running,
    success,
    failure,
    error,
    cancelled
}

enum BuildTrigger {
    manual,
    push,
    pull_request,
    schedule,
    api
}

struct Build {
    string id;
    string projectId;
    uint buildNumber;
    BuildStatus status;
    BuildTrigger trigger;
    string commitSha;
    string branch;
    string triggeredBy;
    uint totalJobs;
    uint completedJobs;
    string startedAt;
    string finishedAt;

    string summary() const {
        return "Build #" ~ buildNumber.to!string ~ " (" ~ status.to!string
            ~ ") [" ~ completedJobs.to!string ~ "/" ~ totalJobs.to!string ~ " jobs]";
    }
}

unittest {
    auto b = Build(
        "build-001", "proj-001", 1, BuildStatus.running, BuildTrigger.push,
        "abc123", "main", "alice", 3, 1,
        "2026-04-19T00:00:00Z", ""
    );
    assert(b.summary() == "Build #1 (running) [1/3 jobs]");
}
