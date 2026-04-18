module uim.infrastructure.ansible.domain.entities.task;

import std.conv : to;
import std.string : toUpper;

enum TaskModule {
    COMMAND,
    SHELL,
    COPY,
    TEMPLATE,
    PACKAGE,
    SERVICE,
    FILE,
    USER,
    LINEINFILE,
    CUSTOM
}

struct Task {
    string id;
    string name;
    TaskModule taskModule;
    string[string] parameters;
    bool ignoreErrors;
    string when;

    string summary() const {
        return name ~ " [" ~ taskModule.to!string ~ "]";
    }
}

TaskModule parseTaskModule(string raw) {
    auto normalized = raw.toUpper();
    foreach (candidate; __traits(allMembers, TaskModule)) {
        if (candidate == normalized)
            return to!TaskModule(normalized);
    }
    throw new Exception("Unsupported task module: " ~ raw);
}

unittest {
    assert(parseTaskModule("command") == TaskModule.COMMAND);
    assert(parseTaskModule("PACKAGE") == TaskModule.PACKAGE);

    string[string] params;
    params["cmd"] = "echo hello";
    auto t = Task("t1", "Say hello", TaskModule.COMMAND, params, false, "");
    assert(t.summary() == "Say hello [COMMAND]");
}
