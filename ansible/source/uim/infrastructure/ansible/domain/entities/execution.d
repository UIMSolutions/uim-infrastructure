module uim.infrastructure.ansible.domain.entities.execution;

import std.conv : to;
import std.string : toUpper;

enum ExecutionStatus {
    PENDING,
    RUNNING,
    SUCCESS,
    FAILED,
    CANCELLED
}

struct TaskResult {
    string taskId;
    string taskName;
    string hostId;
    string hostname;
    bool changed;
    bool failed;
    string output;
    string error;
}

struct Execution {
    string id;
    string playbookId;
    string playbookName;
    string inventoryId;
    ExecutionStatus status;
    TaskResult[] results;
    string startedAt;
    string finishedAt;

    string summary() const {
        return playbookName ~ " [" ~ status.to!string ~ "] (" ~ results.length.to!string ~ " results)";
    }

    uint okCount() const {
        uint count = 0;
        foreach (r; results) {
            if (!r.failed)
                count++;
        }
        return count;
    }

    uint failedCount() const {
        uint count = 0;
        foreach (r; results) {
            if (r.failed)
                count++;
        }
        return count;
    }

    uint changedCount() const {
        uint count = 0;
        foreach (r; results) {
            if (r.changed)
                count++;
        }
        return count;
    }
}

ExecutionStatus parseExecutionStatus(string raw) {
    auto normalized = raw.toUpper();
    foreach (candidate; __traits(allMembers, ExecutionStatus)) {
        if (candidate == normalized)
            return to!ExecutionStatus(normalized);
    }
    throw new Exception("Unsupported execution status: " ~ raw);
}

unittest {
    assert(parseExecutionStatus("pending") == ExecutionStatus.PENDING);
    assert(parseExecutionStatus("RUNNING") == ExecutionStatus.RUNNING);

    auto exec = Execution("e1", "pb1", "Deploy", "i1", ExecutionStatus.SUCCESS, [
        TaskResult("t1", "Install nginx", "h1", "web01", true, false, "ok", ""),
        TaskResult("t2", "Start nginx", "h1", "web01", false, false, "ok", ""),
        TaskResult("t1", "Install nginx", "h2", "web02", true, true, "", "connection refused")
    ], "2026-04-18T10:00:00Z", "2026-04-18T10:05:00Z");

    assert(exec.summary() == "Deploy [SUCCESS] (3 results)");
    assert(exec.okCount() == 2);
    assert(exec.failedCount() == 1);
    assert(exec.changedCount() == 2);
}
