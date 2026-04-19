module uim.infrastructure.jenkins.domain.entities.build;

import std.conv : to;

enum BuildStatus {
    pending,
    running,
    success,
    failure,
    cancelled
}

struct StageResult {
    string stageName;
    BuildStatus status;
    string output;
    uint durationSeconds;
}

struct Build {
    string id;
    string pipelineId;
    uint buildNumber;
    BuildStatus status;
    StageResult[] stageResults;
    string triggeredBy;
    string startedAt;
    string finishedAt;

    string summary() const {
        return "Build #" ~ buildNumber.to!string ~ " (" ~ status.to!string ~ ")";
    }
}

unittest {
    auto b = Build("b-001", "p-001", 1, BuildStatus.success, [], "user", "2026-04-19T00:00:00Z", "2026-04-19T00:05:00Z");
    assert(b.summary() == "Build #1 (success)");
}
