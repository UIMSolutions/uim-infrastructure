/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.ui5server.domain.entities.project;

enum ProjectType {
    application,
    library,
    themeLibrary,
    module_
}

struct Dependency {
    string name;
    string version_;
}

struct Project {
    string id;
    string name;
    ProjectType type;
    string rootPath;
    string version_;
    string namespace_;
    Dependency[] dependencies;

    string summary() {
        import std.conv : to;
        return name ~ " (" ~ type.to!string ~ ") v" ~ version_ ~ " at " ~ rootPath;
    }

    unittest {
        auto p = Project("p1", "myapp", ProjectType.application, "/app", "1.0.0", "com.example");
        assert(p.name == "myapp");
        assert(p.type == ProjectType.application);
    }
}
