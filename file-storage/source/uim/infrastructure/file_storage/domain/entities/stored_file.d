/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module fs_service.domain.entities.stored_file;

import std.datetime : SysTime;

/// Represents a file stored in the service.
struct StoredFile {
    string   id;
    string   name;
    string   contentType;
    ulong    size;
    SysTime  createdAt;
    ubyte[]  data;
}

unittest {
    import std.datetime : Clock;
    auto f = StoredFile("abc", "hello.txt", "text/plain", 5, Clock.currTime(), cast(ubyte[]) "hello");
    assert(f.id   == "abc");
    assert(f.size == 5);
}
