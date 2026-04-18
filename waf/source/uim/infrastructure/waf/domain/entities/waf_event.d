module uim.infrastructure.waf.domain.entities.waf_event;

import std.conv : to;
import uim.infrastructure.waf.domain.entities.waf_rule : RuleAction;

struct WafEvent {
    string id;
    string ruleId;
    string ruleName;
    string sourceIp;
    string requestMethod;
    string requestPath;
    RuleAction action;
    string matchedPattern;
    string details;
    string timestamp;

    string summary() const {
        return action.to!string ~ " " ~ sourceIp ~ " " ~ requestMethod ~ " " ~ requestPath ~ " [" ~ ruleName ~ "]";
    }
}

unittest {
    auto event = WafEvent("e1", "r1", "Block SQLi", "192.168.1.100", "GET", "/api?id=1 OR 1=1", RuleAction.BLOCK, "OR 1=1", "SQL injection attempt", "2026-04-18T12:00:00Z");
    assert(event.summary() == "BLOCK 192.168.1.100 GET /api?id=1 OR 1=1 [Block SQLi]");
}
