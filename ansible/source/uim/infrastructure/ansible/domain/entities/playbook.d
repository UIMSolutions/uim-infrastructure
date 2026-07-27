/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.ansible.domain.entities.playbook;

import std.conv : to;

struct Play {
    string name;
    string targetGroup;
    string[] taskIds;
    string[string] vars;
    bool become;
}

struct Playbook {
    string id;
    string name;
    string description;
    Play[] plays;

    string summary() const {
        return name ~ " (" ~ plays.length.to!string ~ " plays)";
    }
}

unittest {
    auto pb = Playbook("pb1", "Deploy Web App", "Deploys the web application", [
        Play("Install packages", "webservers", ["t1", "t2"], null, true),
        Play("Configure DB", "dbservers", ["t3"], null, true)
    ]);
    assert(pb.summary() == "Deploy Web App (2 plays)");
}
