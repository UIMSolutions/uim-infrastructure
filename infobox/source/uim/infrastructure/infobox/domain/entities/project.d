module uim.infrastructure.infobox.domain.entities.project;

import std.conv : to;

enum ProjectStatus {
    active,
    disabled,
    archived
}

struct Project {
    string id;
    string name;
    string description;
    string repository;
    string branch;
    ProjectStatus status;
    string[] collaborators;
    string createdAt;
    string updatedAt;

    string summary() const {
        return name ~ " (" ~ status.to!string ~ ")";
    }
}

unittest {
    auto p = Project(
        "proj-001", "my-app", "My application", "https://git.example.com/app.git",
        "main", ProjectStatus.active, ["alice", "bob"],
        "2026-04-19T00:00:00Z", "2026-04-19T00:00:00Z"
    );
    assert(p.summary() == "my-app (active)");
}
