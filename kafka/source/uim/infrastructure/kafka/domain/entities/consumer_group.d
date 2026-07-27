/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.infrastructure.kafka.domain.entities.consumer_group;

import std.conv : to;

struct MemberAssignment {
    string memberId;
    string clientId;
    string topic;
    uint[] partitions;
}

struct ConsumerGroup {
    string groupId;
    MemberAssignment[] members;
    string state;
    string createdAt;

    string summary() const {
        return groupId ~ " (" ~ state ~ ") [" ~ members.length.to!string ~ " members]";
    }
}

struct ConsumerOffset {
    string groupId;
    string topic;
    uint partition;
    long committedOffset;
    long logEndOffset;
    long lag;
}

unittest {
    auto cg = ConsumerGroup(
        "payment-processors",
        [MemberAssignment("m-1", "client-1", "payments", [0, 1])],
        "Stable",
        "2026-04-19T00:00:00Z"
    );
    assert(cg.summary() == "payment-processors (Stable) [1 members]");
}
